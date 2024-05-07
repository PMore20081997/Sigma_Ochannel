pageextension 90006 "Price List Line Ext" extends "Price List Lines"
{
    layout
    {
        addlast(Control1)
        {
            field("Listing Status Setting"; Rec."Listing Status Setting")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Sync Price"; Rec."Sync Price")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Listing Status';
            }
        }
    }
}