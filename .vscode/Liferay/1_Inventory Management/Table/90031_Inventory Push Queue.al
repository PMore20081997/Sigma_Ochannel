table 90031 "Inventory Push Queue"
{
    Caption = 'Inventory Push Queue';
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
            TableRelation = "Trade Partner".Code;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(4; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,Processing,Done,Failed;
            OptionCaption = 'Pending,Processing,Done,Failed';
        }
        field(6; "Trigger Source"; Text[50])
        {
            Caption = 'Trigger Source';
            // ILE | Sales Order | Inventory Pick | Web Order
        }
        field(7; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(K1; Status, "Created At") { }
        key(K2; "Channel Code", "Item No.", Status) { }
    }
}