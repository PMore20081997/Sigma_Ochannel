tableextension 90001 "Whse. Internal Pick Line Ext" extends "Whse. Internal Pick Line"
{

    fields
    {
        field(90000; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
        }
        field(90001; "Existing Order"; Boolean)
        {
            Caption = '"Existing Order"';
        }
        field(90002; "Channel Order ID"; Code[50])
        {

        }
        field(90003; "Bay No."; Code[20])
        {

        }


    }

    var
        myInt: Integer;
}