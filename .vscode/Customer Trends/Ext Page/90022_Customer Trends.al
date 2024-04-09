pageextension 90022 "OC Customer Trends" extends "Customer Trends"
{
    layout
    {

        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Qty. to be added to SO" <> 0 then begin
                    CurrPage.Update(); //Update Current Quantity++
                end;
            end;
        }


        // Add changes to page layout here
        addafter(Allocated)
        {
            field("Total Free"; TotalAvailableQty(rec))
            {
                Caption = 'Total Free';
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Total Physical - Total SO Allocated - Web Order Qty';
                StyleExpr = G_Colour;
            }
        }

        addafter("Allocated on SO")
        {
            field("Free"; TotalAvailableQtyForSealable(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
                Caption = 'Free';
                StyleExpr = G_Colour;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        G_Colour: Text;

    local procedure TotalAvailableQty(_Rec: Record CustomerTrends): Decimal
    var
        L_ILE: Record "Item Ledger Entry";
    begin
        //+++++Formula:- Total Free => "Total Physical - Total SO Allocated - Web Orders Qty"
        //Inventory is Total Physical
        //Total SO Allocated is Allocated
        //Web Orders Qty is Web order Qty------
        _Rec.CalcFields(Inventory, Allocated, "Web Orders Qty", "Qty On Customer Trends");
        if (_Rec.Inventory - _Rec.Allocated - _Rec."Web Orders Qty" - _Rec."Qty On Customer Trends") > 0 then
            exit(_Rec.Inventory - _Rec.Allocated - _Rec."Web Orders Qty" - _Rec."Qty On Customer Trends")
        else
            exit(0);
    end;

    local procedure TotalAvailableQtyForSealable(_Rec: Record CustomerTrends): Decimal
    var
        ItemVariant: Record "Item Variant";
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
        SaleableInventory: Decimal;
        L_SalesLine: Record "Sales Line";
        SaleableQtyOnSO: Decimal;
        item: Record Item;
    begin
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory", "Web Orders Qty", "Qty On Customer Trends");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty" - _Rec."Qty On Customer Trends") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty" - _Rec."Qty On Customer Trends")
            else
                exit(0)
        else
            exit(0);
    end;


    trigger OnAfterGetCurrRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
    begin
        //Set Color For Special Items on Top Screen++
        Clear(G_Colour);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CustomerTrends.SetRange("Customer No.", Rec."Customer No.");
        L_CustomerTrends.SetRange("Special Promotion", false); //For Top SCreen
        L_CustomerTrends.SetRange("Item No.", Rec."Item No.");
        if L_CustomerTrends.FindFirst() then begin
            if L_CustomerTrends."Special Item on Top SCreen" = true then
                G_Colour := 'Favorable';
        end;
    end;

    trigger OnAfterGetRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
    begin
        //Set Color For Special Items on Top Screen++
        Clear(G_Colour);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CustomerTrends.SetRange("Customer No.", Rec."Customer No.");
        L_CustomerTrends.SetRange("Special Promotion", false); //For Top SCreen
        L_CustomerTrends.SetRange("Item No.", Rec."Item No.");
        if L_CustomerTrends.FindFirst() then begin
            if L_CustomerTrends."Special Item on Top SCreen" = true then
                G_Colour := 'Favorable';
        end;
    end;
}