table 90026 "Polar Speed Barcode Details"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Tote/Order No."; Code[20])
        {
            Caption = 'Tote/Order No.';
            DataClassification = ToBeClassified;
        }
        field(3; "Sales Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "No. of Box / Tote Sequence"; Integer)
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
        field(10; "Print Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Order Category"; Option)
        {
            OptionMembers = " ",Manual,Knapp;
        }
        field(12; "Shipment Date"; Date)
        {

        }
        field(13; "Temprature"; Text[100])
        {
            //one lable consist only one temprature item+++
        }
        field(14; "No. of Print"; Integer)
        {

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