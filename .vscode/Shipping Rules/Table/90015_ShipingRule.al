table 90015 "OCHANNEL Shipping Rule"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;

        }
        field(2; "NAV Shipment Method"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'NAV Shipment Method', ENG = 'NAV Shipment Method';
            TableRelation = "Shipment Method";
        }

        field(3; "Country To Deliver"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region";
        }
        field(4; "Order Value"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(5; "Item Shipping Group"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Shipping Agent"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Shipping Agent Code', ENG = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(7; "Shipping Agent Service"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Shipping Agent Service Code', ENG = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent"));
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF xRec."Shipping Agent" = "Shipping Agent" THEN
                    EXIT;

                "Shipping Agent Service" := '';
            end;
        }
        field(8; "Preference"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = First,Second,Third;
            OptionCaptionML = ENU = 'First,Second,Third', ENG = 'First,Second,Third';

        }

        field(9; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-08731-N5J3J9';
            TableRelation = "Trade Partner".Code;
        }
        field(10; "Web Shipping Agent"; Text[50])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-08731-N5J3J9';

        }
        field(11; "Web Shipment Method"; code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(12; "Delivery within"; DateFormula)
        {
            DataClassification = ToBeClassified;

        }
        field(13; "Carrier Name"; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(14; "Carrier Code"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(15; "Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Shipping,Carrier;
            OptionCaptionML = ENU = 'Shipping,Carrier';
        }
        field(16; "Shipping Charge"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }


}