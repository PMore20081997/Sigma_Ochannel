tableextension 90003 "Reg. Whse. Activity Line Ext" extends "Registered Whse. Activity Line"
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
        field(90002; "Bay No."; code[20])
        {
        }
        field(90003; "Bay Closed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90004; "Channel Code"; code[20])
        {
        }
    }
}