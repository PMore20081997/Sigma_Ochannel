table 90026 "Polar Speed Barcode"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            // AutoIncrement = true;
        }
        field(2; "Tote No."; Code[20])
        {
            Caption = 'Tote/Order No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Sales Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Box No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; Barcode; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Barcode No."; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Customer No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Order No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Document No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Print Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Order Category"; Option)
        {
            OptionMembers = " ",Manual,Knapp;

        }
    }

    keys
    {
        key(PK; "Entry No.")
        {

        }
    }

    fieldgroups
    {

    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}