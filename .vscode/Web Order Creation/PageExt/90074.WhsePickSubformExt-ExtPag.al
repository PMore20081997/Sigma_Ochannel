pageextension 90074 "Whse. Pick Subform Ext" extends "Whse. Pick Subform"
{
    layout
    {
        addafter("Destination No.")
        {
            field("Channel Order ID"; Rec."Channel Order ID")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}