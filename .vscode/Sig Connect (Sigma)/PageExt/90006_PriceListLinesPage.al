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
            field("Listing Status"; Rec."Listing Status")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Status to show if the Price is Listed in the Portal or not';
            }
            field("Sync Price"; Rec."Sync Price")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Acknowledgment from Portal that Price has synced on their side';
            }
        }
    }
}