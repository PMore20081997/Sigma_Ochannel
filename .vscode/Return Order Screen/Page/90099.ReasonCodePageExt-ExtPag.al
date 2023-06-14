pageextension 90099 "Reason Code Page Ext" extends "Reason Codes"
{
    layout
    {
        addafter(Description)
        {
            field("Zone Code"; Rec."Zone Code")
            {
                ApplicationArea = All;
            }
        }
    }
}