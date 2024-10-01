table 90201 "Item Variant With Free Qty"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; Priority; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Item No."; Code[20])
        {
            TableRelation = Item."No.";
        }
        field(3; "Variant Code"; Code[20])
        {
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(4; Quantity; Decimal)
        {

        }
    }

    keys
    {
        key(Key1; Priority)
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