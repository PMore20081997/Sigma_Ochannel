table 90029 "LifeRay Stock"
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
            DataClassification = ToBeClassified;
            TableRelation = "Trade Partner".Code WHERE("Partner Type" = FILTER("Channel"));
        }
        field(3; "Item No."; Code[20])
        {
            TableRelation = Item."No.";
        }
        field(4; "Item Description"; Text[100])
        {

        }
        field(5; "Variant Code"; Code[20])
        {
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(6; "Variant Description"; Text[100])
        {

        }
        field(7; "Variant Priority"; Integer)
        {
            // FieldClass = FlowField;
            // CalcFormula = lookup("Item Variant".Priority where("Item No." = field("Item No."), Code = field("Variant Code")));
        }
        field(8; "Location Code"; Code[10])
        {
            TableRelation = Location.Code;
        }
        field(9; Inventory; Decimal)
        {

        }
        field(11; "Created On"; Date)
        {

        }
        field(12; "Sync"; Boolean)
        {

        }
        field(13; "Sync Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Full,Delta;
        }
        field(14; "Transaction No."; Integer)
        {

        }
        field(15; "Allocated On SO"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allocated on SO + Allocate on KNAPP';

        }
        field(16; "Allocated On Pick"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(17; "Restricted Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(18; "Total Web Order Qty"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(19; "Allocated On WebOrder"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(20; "Total Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Allocated for KNAPP"; Decimal)
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