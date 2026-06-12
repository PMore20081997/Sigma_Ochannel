table 90028 "LifeRay Error Log"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Trade Partner".Code WHERE("Partner Type" = FILTER("Channel"));
        }
        field(4; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Product",FullIventory,DeltaInventory,Customer,Price,Order;
        }
        field(5; "Document No."; Code[20])
        {

        }
        field(6; "Document Line No."; Integer)
        {

        }
        field(7; "Sync Date"; Date)
        {

        }
        field(8; "Error Message"; Blob)
        {
            SubType = Memo;
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