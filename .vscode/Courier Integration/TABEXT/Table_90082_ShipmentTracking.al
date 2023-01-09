table 90082 "Shipment Tracking"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;

        }
        field(2; "Document Type"; Option)
        {
            OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order","Web Order";
            DataClassification = ToBeClassified;

        }
        field(3; "Document No."; Code[20])
        {

        }
        field(4; "Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            TableRelation = "Shipping Agent";
            DataClassification = ToBeClassified;

        }
        field(5; "Shipping Agent Service Code"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            DataClassification = ToBeClassified;

        }
        field(6; "Agent Shipment No."; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(7; "Tracking No."; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(8; Label; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
            Compressed = false;

        }
        field(9; Weight; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(10; "A6 Label1"; Blob)
        {
            Subtype = Bitmap;
            DataClassification = ToBeClassified;
            Compressed = false;
        }
        field(11; "Shipment Label Handled"; Boolean)
        {

        }
        field(12; "Entry Created"; Date)
        {

        }
        field(13; CheckForPrint; Boolean)
        {

        }
        field(14; "RAW Text"; Text[2048])
        {

        }
    }

    keys
    {
        key(PK; "Entry No.")
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