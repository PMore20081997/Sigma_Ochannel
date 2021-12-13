pageextension 90007 UserSetupListExt extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field("Allow to Auth. Web Order Price"; Rec."Allow to Auth. Web Order Price")
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