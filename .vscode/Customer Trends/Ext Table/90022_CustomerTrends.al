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
            begin
                if "Qty. to be added to SO" <> 0 then begin
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