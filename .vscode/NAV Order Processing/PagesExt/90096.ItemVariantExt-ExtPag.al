pageextension 90096 "Item Variant Ext" extends "Item Variants"
{
    layout
    {
        addafter(Description)
        {
            field("VAT Prod. Posting Group"; Rec."VAT Prod Posting Group")
            {
                ApplicationArea = All;
            }
            field("Shelf No."; Rec."Shelf No.")
            {
                ApplicationArea = All;
            }
        }
        addbefore(Inventory)
        {
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Sucessfull Electronic Orders';
                //GHST Customization++
            }
        }

        addafter(Allocated)
        {
            field("Total Free"; TotalAvailableQty(rec))
            {
                Caption = 'Total Free';
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Total Physical - Total SO Allocated';
                //GHST Customization++
            }
        }

        addafter("Qty on SO(Saleable)")
        {
            field("Free"; TotalAvailableQtyForSaleable(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO';
                Caption = 'Free';
                //GHST Customization++
            }
        }
    }


    local procedure TotalAvailableQty(_Rec: Record "Item Variant"): Decimal
    var
        L_ILE: Record "Item Ledger Entry";
    begin
        _Rec.CalcFields(Inventory, Allocated, "Web Orders Qty");
        if (_Rec.Inventory - _Rec.Allocated) > 0 then
            exit(_Rec.Inventory - _Rec.Allocated)
        else
            exit(0);
    end;

    local procedure TotalAvailableQtyForSaleable(_Rec: Record "Item Variant"): Decimal
    var
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
    begin
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory", "Web Orders Qty");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)")
            else
                exit(0)
        else
            exit(0);
    end;
}