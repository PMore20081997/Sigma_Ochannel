table 90030 "correlation-id Tracking"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Channel Code"; Code[20])
        {

        }
        field(3; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Product",FullIventory,DeltaInventory,Customer,Price,Order;
        }
        field(4; "Document No."; Code[20])
        {

        }
        field(5; "Sync Date"; Date)
        {

        }
        field(6; "Data Sync Timestamp"; DateTime)
        {

        }
        field(7; "Correlation-Id"; Code[100])
        {

        }
        field(8; "Data"; Blob)
        {

        }
        field(9; "Document Line No."; Integer)
        {

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