pageextension 90021 "OC Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter(Allocated)
        {
            field("Total Free"; TotalAvailableQty(Rec))
            {
                Caption = 'Total Free';
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Total Physical - Total SO Allocated - Web Order Qty';
            }
        }
        addafter("Allocated on SO")
        {
            field("Free (Saleable)"; TotalAvailableQtyForSaleable(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical (Saleable) - Allocated on SO (Saleable) - Web Orders Qty';
                //Caption = 'Total Available Quantity(Saleable)';
                Caption = 'Free';
            }
        }
        addbefore("Direct Unit Cost")
        {
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Sucessfull Electronic Orders';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

    local procedure TotalAvailableQty(_Rec: Record "Purchase Line"): Decimal
    var
        L_ILE: Record "Item Ledger Entry";
    begin
        //+++++Formula:- Total Free => "Total Physical - Total SO Allocated - Web Orders Qty"
        //Inventory is Total Physical
        //Total SO Allocated is Allocated
        //Web Orders Qty is Web order Qty------
        _Rec.CalcFields(Inventory, Allocated, "Web Orders Qty");
        if (_Rec.Inventory - _Rec.Allocated - _Rec."Web Orders Qty") > 0 then
            exit(_Rec.Inventory - _Rec.Allocated - _Rec."Web Orders Qty")
        else
            exit(0);
    end;


    local procedure TotalAvailableQtyForSaleable(_Rec: Record "Purchase Line"): Decimal
    var
        ItemVariant: Record "Item Variant";
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
        SaleableInventory: Decimal;
        L_SalesLine: Record "Sales Line";
        SaleableQtyOnSO: Decimal;
        item: Record Item;
    begin
        //Free (Saleable) => Change the formula to "Physical (Saleable) - Allocated on SO (Saleable) - Web Orders Qty"
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)")
            else
                exit(0)
        else
            exit(0);
    end;
}