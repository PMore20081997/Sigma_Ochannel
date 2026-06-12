table 90032 "Price Push Queue"
{
    Caption = 'Price Push Queue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
            DataClassification = CustomerContent;
            TableRelation = "Trade Partner".Code;
        }
        field(3; "Price List Code"; Code[20])
        {
            Caption = 'Price List Code';
            DataClassification = CustomerContent;
            TableRelation = "Price List Header";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(6; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = Pending,Processing,Done,Failed;
            OptionCaption = 'Pending,Processing,Done,Failed';
        }
        field(7; "Trigger Source"; Text[50])
        {
            Caption = 'Trigger Source';
            DataClassification = CustomerContent;
            // Insert | Modify | Delete
        }
        field(8; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(9; Action; Option)
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
            OptionMembers = Update,Delete;
            OptionCaption = 'Update,Delete';
        }
        field(10; "Created On"; Date)
        {
            Caption = 'Created On';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(K1; Status, "Created At") { }
        key(K2; "Channel Code", "Price List Code", "Line No.", Status) { }
    }
}
