table 90002 "Interim Customer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'No', ENG = 'No';
        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Name', ENG = 'Name';
        }
        field(3; Address; Text[100])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Address', ENG = 'Address';
        }
        field(4; "Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Address 2', ENG = 'Address 2';
        }
        field(5; City; Text[30])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'City', ENG = 'City';
        }
        field(6; "Phone No"; Text[30])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Phone No.', ENG = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(7; "Post Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Post Code', ENG = 'Post Code';
        }
        field(8; "E-Mail"; Text[80])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'E-Mail', ENG = 'E-Mail';
            ExtendedDatatype = EMail;
        }
        field(9; Blocked; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Ship,Invoice,All;
            OptionCaptionML = ENU = ' ,Ship,Invoice,All', ENG = ',Ship,Invoice,All';
            CaptionML = ENU = 'Blocked', ENG = 'Blocked';
        }
        field(10; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = New,Update;
            OptionCaptionML = ENU = 'New,Update', ENG = 'New,Update';
            CaptionML = ENU = 'Status', ENG = 'Status';
        }
        field(11; "Transaction No."; Integer)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Transaction No.', ENG = 'Transaction No.';
        }
        field(12; "Customer Posting Group"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Customer Posting Group', ENG = 'Customer Posting Group';
            TableRelation = "Customer Posting Group";
        }
        field(13; "Gen. Bus. Posting Group"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Gen. Bus. Posting Group', ENG = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(14; "VAT Bus. Posting Group"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'VAT Bus. Posting Group', ENG = 'VAT Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(15; "Credit Limit (LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Responsibility Center"; Code[10])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Responsibility Center', ENG = 'Responsibility Centre';
            TableRelation = "Responsibility Center";
        }
        field(17; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Customer No.';
            TableRelation = Customer."No." WHERE("Web Customer No. 2" = FILTER(''));
            trigger OnValidate()
            var
                InterimCustomer: Record "Interim Customer";
            begin
                IF "Customer No." <> '' THEN BEGIN
                    Customer.GET("Customer No.");
                    "InterimCustomer".VALIDATE("Responsibility Center", Customer."Responsibility Center");
                    InterimCustomer.VALIDATE("Customer Posting Group", Customer."Customer Posting Group");
                    InterimCustomer.VALIDATE("Gen. Bus. Posting Group", Customer."Gen. Bus. Posting Group");
                    InterimCustomer.VALIDATE("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
                END;
            end;
        }
        field(18; "Company Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Company Name';
        }
        field(19; "Company Type"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Company Type';
        }
        field(20; "Company Reg No"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Company Reg No';
        }
        field(21; "VAT No"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'VAT No';
        }
        field(22; "Business Type"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Business Type';
        }
        field(23; "Website"; Text[80])
        {
            DataClassification = ToBeClassified;
            Caption = 'Website';
        }
        field(24; "Address 3"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Address 3';
        }
        field(25; "County"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'County';
        }
        field(26; "Country"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Country';
        }
        field(27; "Shipping Contact"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Contact';
        }
        field(28; "Shipping Address"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Address';
        }
        field(29; "Shipping Address 2"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Address 2';
        }
        field(30; "Shipping Address 3"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Address 3';
        }
        field(31; "Shipping City"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping City';
        }
        field(32; "Shipping Phone No."; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Phone No.';
        }
        field(33; "Shipping Post Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Post Code';
        }
        field(34; "Shipping County"; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping County';
        }
        field(35; "Shipping Country"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Country';
        }
        field(36; "AccountNo"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'AccountNo';
        }
        field(37; "Process"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Process';
        }
        field(38; "Job Title"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Job Title';
        }
        field(39; "Channel Code"; Code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Channel Code';
        }
        field(40; "Country Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Country Name';
        }
        field(41; "Shipping Country Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Shipping Country Name';
        }
        field(42; "Bill to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(43; "Bill to Customer Name"; Code[100])
        {
            DataClassification = ToBeClassified;
        }
        field(44; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Listing Status', ENG = 'Listing Status';
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(45; "Customer Price Group 1"; Code[10])
        {
            Caption = 'Customer Price Group 2';
            TableRelation = "Customer Price Group";
        }
        field(46; "Customer Price Group 2"; Code[10])
        {
            Caption = 'Customer Price Group 2';
            TableRelation = "Customer Price Group";
        }
        field(47; "Customer Price Group 3"; Code[10])
        {
            Caption = 'Customer Price Group 3';
            TableRelation = "Customer Price Group";
        }
        field(48; "Customer Price Group 4"; Code[10])
        {
            Caption = 'Customer Price Group 3';
            TableRelation = "Customer Price Group";
        }
        field(49; "Customer Price Group 5"; Code[10])
        {
            Caption = 'Customer Price Group 3';
            TableRelation = "Customer Price Group";
        }
        field(50; "Concerto Customer No."; Code[50])
        {
        }
        field(51; "Listing Status Setting"; Option)
        {
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
            trigger OnValidate()
            var
            begin
                if Rec."Listing Status Setting" = Rec."Listing Status Setting"::Inactive then
                    Rec."Customer Sync" := false
                else
                    Rec."Customer Sync" := true;
            end;
        }
        field(52; "Customer Sync"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        Customer: Record "Customer";
}