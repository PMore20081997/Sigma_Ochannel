table 90007 "Despatch Scan Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Document Type"; Enum "Web Document Type")
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Order No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Variant Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Item Desciption"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Scanned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Pick Printed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Trolley No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Scan Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Channel Parter Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Web order updated"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Scanned Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Order Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Bay No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Trolley closed Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity Handeled';
        }

        field(20; "Warehouse Journal Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Item Journal Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Source No."; Code[20])
        {

        }
        field(26; "Source Line No."; Integer)
        {

        }
    }

    keys
    {
        key(PK; "Entry No.", "Trolley No")
        {
            Clustered = true;
        }
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