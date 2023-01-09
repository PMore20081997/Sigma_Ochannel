pageextension 90004 PostedAssemblyOrderCardExt extends "Posted Assembly Order"
{
    layout
    {
        addafter(Description)
        {
            field("Channel Order Id"; Rec."Description 2")
            {
                ApplicationArea = All;
                Caption = 'Channel Order Id';
            }
        }
    }
}