pageextension 90022 "Sales Price Lists Ext" extends "Sales Price Lists"
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