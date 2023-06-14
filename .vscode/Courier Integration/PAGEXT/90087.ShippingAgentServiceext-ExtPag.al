pageextension 90087 "Shipping Agent Service ext." extends "Shipping Agent Services"
{
    layout
    {
        addafter(Description)
        {
            field("Max. No. of Parcel"; Rec."Max. No. of Parcel")
            {
                ApplicationArea = All;
            }
        }
    }
}