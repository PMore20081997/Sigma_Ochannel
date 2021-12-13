table 90010 "Incoming/Outgoing Error Log"
{
    DrillDownPageID = "Web Order Error Log";
    LookupPageID = "Web Order Error Log";

    fields
    {
        field(1; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Date; Date)
        {
            Caption = 'Date';
        }
        field(6; Comment; Text[50])
        {
            Caption = 'Comment';
        }
        field(8; "Error Text"; Text[250])
        {
        }
        field(9; "Error Text2"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
        }
    }


}