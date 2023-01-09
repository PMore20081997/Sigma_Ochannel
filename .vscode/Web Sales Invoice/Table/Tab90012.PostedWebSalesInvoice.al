table 90012 "Posted Web Sales Invoice"
{
    Caption = 'Posted Web Sales Invoice';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Web Sales Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
            end;
        }
        field(2; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                LinesRec: Record "Web Sales Invoice Line";
            begin
            end;
        }
        field(3; "Document Creation DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Posted"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = False;
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = ToBeClassified;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = ToBeClassified;
        }
        field(7; "Location Code"; code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(8; "Processing Error"; Text[250])
        {

            Caption = 'Processing Error';
            TableRelation = Location;
            Editable = false;
        }
        field(9; "Stock Posted"; Boolean)
        {
            Caption = 'Stock Posted';
            Editable = False;
        }

        field(10; "Invoice Posted"; Boolean)
        {
            Caption = 'Invoice Posted';
            Editable = False;
        }
        field(11; "Total Qty. to post"; Decimal)
        {
            Caption = 'Total Qty. to post';
            Editable = false;
        }
        field(12; "Total Amt. to post"; Decimal)
        {
            Caption = 'Total Amt. to post';
            Editable = false;
        }
        field(20; "Total Amt. to post(Inl. VAT)"; Decimal)
        {
            Caption = 'Total Amt. to post(Inl. VAT)';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Web Sales Invoice No.")
        {
            Clustered = true;
        }
    }

}
