pageextension 90001 AssemblyOrderListExt extends "Assembly Orders"
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
