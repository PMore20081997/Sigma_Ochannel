table 90008 "Archive Scanned Entries"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Document Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
            OptionCaptionML = ENU = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order',
                              ENG = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        }
        field(3; "Order No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Variant Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Item Desciption"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Scanned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Pick Printed"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Trolley No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Scan Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Channel Parter Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Web order updated"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Scanned Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Order Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Trolley Closed"; Boolean)
        {
            Caption = '"Trolley Closed"';
        }
        field(18; "Bay No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Trolley closed Quantity"; Decimal)
        {
        }

        field(20; "Warehouse Journal Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Item Journal Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(22; "Invoice Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Web Inv No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Posting Error"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Source No."; Code[20])
        {

        }
        field(26; "Source Line No."; Integer)
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