pageextension 90013 "Sales Return Order Subform Ext" extends "Sales Return Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Scanned Date"; Rec."Scanned Date")
            {
                ApplicationArea = All;
            }

            field("Channel Order ID"; Rec."Channel Order ID")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}