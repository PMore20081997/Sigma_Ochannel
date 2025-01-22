table 90020 "Sales Line TOS"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Web Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Sales Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "PIP Code"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "ET Access Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Quantity Shipped"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Status; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}