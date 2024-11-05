table 90019 TempILE1
{
    DataClassification = ToBeClassified;
    //TableType = Temporary;

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
        field(4; "Depot Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "ILE Qty."; Decimal)
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