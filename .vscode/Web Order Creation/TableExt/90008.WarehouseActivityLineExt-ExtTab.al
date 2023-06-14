tableextension 90008 "Warehouse Activity Line Ext" extends "Warehouse Activity Line"
{
    fields
    {
        field(90000; "Trolley No."; Code[20])
        {
            Caption = 'Trolley No.';
        }
        field(90001; "Channel Order ID"; Code[50])
        {

        }
        field(90002; "Bay No."; Code[20])
        {

        }
        field(90004; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
        }
    }

    var
        myInt: Integer;
}