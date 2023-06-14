pageextension 90009 "CustomerListExt" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("Web Customer No. 2"; Rec."Web Customer No. 2")
            {
                ApplicationArea = All;
            }
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
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