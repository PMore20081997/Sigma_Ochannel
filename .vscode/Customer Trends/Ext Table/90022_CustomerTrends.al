tableextension 90022 "OC CustomerTrends" extends "CustomerTrends"
{
    fields
    {
        // Add changes to table fields here
        field(90022; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("Item No."), "Reason Message" = const('Successful'), "Sales Order Created" = const(true)));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }

        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            var
                L_CustomerTrend: Record CustomerTrends;
            begin
                if "Qty. to be added to SO" <> 0 then begin
                    //Check duplicate Item on both screen of customer trends Top and Bottom++
                    if Rec."Special Promotion" = true then begin
                        L_CustomerTrend.Reset();
                        L_CustomerTrend.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrend.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrend.SetRange("Item No.", Rec."Item No.");
                        L_CustomerTrend.SetRange("Special Promotion", false);
                        L_CustomerTrend.SetFilter("Qty on SO(Saleable)", '>%1', 0);
                        if L_CustomerTrend.FindFirst() then
                            Error('Qty. to be added to SO should be blank on top screen. current value is %1', L_CustomerTrend."Qty. to be added to SO");
                    end else begin
                        L_CustomerTrend.Reset();
                        L_CustomerTrend.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrend.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrend.SetRange("Item No.", Rec."Item No.");
                        L_CustomerTrend.SetRange("Special Promotion", true);
                        L_CustomerTrend.SetFilter("Qty on SO(Saleable)", '>%1', 0);
                        if L_CustomerTrend.FindFirst() then
                            Error('Qty. to be added to SO should be blank on the Special Promotions screen. current value is %1', L_CustomerTrend."Qty. to be added to SO");
                    end;


                    //Check Min Quantity (For Promotion Item)++
                    if Rec."Special Promotion" = true then begin
                        if Rec."Minimum Quantity" > Rec."Qty. to be added to SO" then
                            Error('Qty. to be added to SO should not be less than Minimum Quantity %1. Item Number: %2', Rec."Minimum Quantity", Rec."Item No.");
                    end;

                    //Check Free Quantity (For Both Promotion and Normal Item)++
                    if "Qty. to be added to SO" > TotalAvailableQtyForSaleable(Rec) then
                        Error('Qty. to be added to SO should be less than Free Inventory %1. Item Number: %2', TotalAvailableQtyForSaleable(Rec), Rec."Item No.");
                end;
            end;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    local procedure TotalAvailableQtyForSaleable(_Rec: Record CustomerTrends): Decimal
    var
        ItemVariant: Record "Item Variant";
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
        SaleableInventory: Decimal;
        L_SalesLine: Record "Sales Line";
        SaleableQtyOnSO: Decimal;
        item: Record Item;
    begin
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory", "Web Orders Qty");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty")
            else
                exit(0)
        else
            exit(0);
    end;
}