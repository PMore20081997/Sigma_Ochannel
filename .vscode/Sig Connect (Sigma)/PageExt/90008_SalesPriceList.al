pageextension 90008 "Sales Price List Ext" extends "Sales Price List"
{
    layout
    {
        addafter(Status)
        {
            field("Listing Status Setting"; Rec."Listing Status Setting")
            {
                ApplicationArea = All;
                ToolTip = 'This is a user-editable field to enable/disable BC Prices in the portal';
            }
        }
    }
}