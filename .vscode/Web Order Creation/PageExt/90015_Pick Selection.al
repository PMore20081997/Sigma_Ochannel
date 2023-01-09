pageextension 90015 "Pick Selection" extends "Pick Selection"
{
    layout
    {
        // Add changes to page layout here
        addafter("Location Code")
        {

            field("Channel Order ID"; Rec."Channel Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Channel Order ID field.';
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