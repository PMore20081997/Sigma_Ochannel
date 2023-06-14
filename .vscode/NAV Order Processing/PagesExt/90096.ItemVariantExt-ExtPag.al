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
    }
}