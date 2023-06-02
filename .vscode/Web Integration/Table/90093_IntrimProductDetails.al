table 90093 "Interim Product Details"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5; "Reference Type No."; Code[20])
        {
            Caption = 'Reference Type No.';
        }
        field(4; "Entry Type"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            NotBlank = true;
        }
        field(7; "Current Availability"; Decimal)
        {
        }
        field(8; "Last Availability"; Decimal)
        {
        }
        field(9; "Current Stock Status"; Text[50])
        {
        }
        field(10; "Last Stock Status"; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Entry Type", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
    }

    var

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