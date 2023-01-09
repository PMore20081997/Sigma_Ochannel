tableextension 90013 AssemblyHeaderExt extends "Assembly Header"
{
    fields
    {
        field(90000; "Channel Order Line No."; Integer)
        {
            Caption = 'Channel Order Line No.';
            // DataClassification = ToBeClassified;
        }
        field(90001; Comments; Text[250])
        {
            Caption = 'Comments';
            DataClassification = ToBeClassified;
        }
    }
}
