table 90018 TempGRN
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;

        }
        field(2; "Item No."; Code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Variant Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[150])
        {
            DataClassification = ToBeClassified;
        }

        field(5; "Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Unit Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Unit Cost (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Original Order Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Line Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Item Reference No."; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Item Category Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Document No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }



    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
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