pageextension 90008 "Sales Price List Ext" extends "Sales Price List"
{
    layout
    {
        addafter(Status)
        {
            field("Listing Status Setting"; Rec."Listing Status Setting")
            {
                ApplicationArea = All;
            }
        }
    }
}