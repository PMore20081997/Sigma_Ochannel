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
        field(16; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Territory Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Location Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Salesperson Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Sell-to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Shipping Agent Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Net Weight"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Return Reason Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Ship-to Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "External Document No."; Code[35])
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Header No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Promised Delivery Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Currency Factor"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Header Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Inv/Cred"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Cred Reason"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Vendor No."; Code[20])
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