pageextension 90093 "Customer Extended" extends "Customer Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("Payment Service Code"; Rec."Payment Service Code")
            {
                ApplicationArea = All;
            }
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = All;
            }
        }


    }



}
