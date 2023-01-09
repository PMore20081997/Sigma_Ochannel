pageextension 90003 PostedAssemblyOrderListExt extends "Posted Assembly Orders"
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