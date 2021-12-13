table 90017 "Posted Web Sales Inv. Line"
{
    Caption = 'Posted Web Sales Inv. Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Web Sales Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Web Sales Invoice No.';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;
        }
        field(4; Type; Option)
        {
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Cross reference","Common Item No.";
            DataClassification = ToBeClassified;
            OptionCaptionML = ENU = ',G/L Account,Item,Resource,Fixed Asset,Cross reference,Common Item No.',
            ENG = ' ,G/L Account,Item,Resource,Fixed Asset,Cross reference,Common Item No.';

        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account"))
                                     "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                               "Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF (Type = CONST(Resource)) Resource
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF (Type = CONST(Item)) Item;

        }
        field(6; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(7; "NAV Variant code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(9; "Quantity(Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Amount Including VAT"; Decimal)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(12; "Unit Price"; Decimal)
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(15; "Stock Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(16; "Invoice Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "VAT Prod. Posting Group"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "VAT%"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Vat Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(PK; "Web Sales Invoice No.", "Line No.")
        {
            Clustered = true;
        }
    }

}
