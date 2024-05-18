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
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Date; Date)
        {
            Caption = 'Date';
        }
        field(5; Comment; Text[50])
        {
            Caption = 'Comment';
        }
        field(6; "Error Text"; Text[250])
        {
        }
        field(7; "Error Text2"; Text[250])
        {
        }
        field(8; "Item No."; Code[20])
        {
        }
        field(9; "Error Code"; Code[20])
        {
        }
        field(10; "Sequence No."; Integer)
        {
        }
        field(11; "Attribute"; Code[20])
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