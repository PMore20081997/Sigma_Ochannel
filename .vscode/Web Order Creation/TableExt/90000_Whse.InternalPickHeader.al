tableextension 90000 "Whse. Internal Pick Header Ext" extends "Whse. Internal Pick Header"
{
    fields
    {
        field(90000; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
        }
        field(90001; "Trolley No."; Code[20])
        {
            Caption = 'Trolley No.';
        }
        field(90002; "Order Line Type"; Option)
        {
            Caption = 'Order Line Type';
            OptionMembers = ,"Single Line Orders","Multi Line Order";
        }
        field(90003; "Created Date"; Date)
        {

        }
    }



}