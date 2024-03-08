pageextension 90022 "OC Customer Trends" extends "Customer Trends"
{
    layout
    {
        // Add changes to page layout here
        addafter("Qty. to be added to SO")
        {
            field("Free"; TotalAvailableQtyForSealable(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
                //Caption = 'Total Available Quantity(Saleable)';
                Caption = 'Free';
            }
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                Editable = false;
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