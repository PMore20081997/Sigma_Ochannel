table 90027 "Channel Price"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Price List Code"; Code[20])
        {
            Caption = 'Price List Code';
            DataClassification = CustomerContent;
            TableRelation = "Price List Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(3; "Source Type"; Enum "Price Source Type")
        {
            Caption = 'Assign-to Type';
            DataClassification = CustomerContent;
        }
        field(4; "Source No."; Code[20])
        {
            Caption = 'Assign-to No. (custom)';
            DataClassification = CustomerContent;
        }
        field(5; "Parent Source No."; Code[20])
        {
            Caption = 'Assign-to Parent No. (custom)';
            DataClassification = CustomerContent;
        }
        field(6; "Source ID"; Guid)
        {
            Caption = 'Assign-to ID';
            DataClassification = CustomerContent;

        }
        field(7; "Asset Type"; Enum "Price Asset Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
            InitValue = Item;
        }
        field(8; "Asset No."; Code[20])
        {
            Caption = 'Product No. (custom)';
            DataClassification = CustomerContent;
        }
        field(9; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code (custom)';
            DataClassification = CustomerContent;
        }
        field(10; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(11; "Work Type Code"; Code[10])
        {
            Caption = 'Work Type Code';
            DataClassification = CustomerContent;
            TableRelation = "Work Type";
        }
        field(12; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(13; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(14; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(15; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code (custom)';
            DataClassification = CustomerContent;
        }
        field(16; "Amount Type"; Enum "Price Amount Type")
        {
            Caption = 'Defines';
            DataClassification = CustomerContent;
        }
        field(17; "Unit Price"; Decimal)
        {
            AccessByPermission = tabledata "Sales Price Access" = R;
            DataClassification = CustomerContent;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Price';
            MinValue = 0;
        }
        field(18; "Cost Factor"; Decimal)
        {
            AccessByPermission = tabledata "Sales Price Access" = R;
            DataClassification = CustomerContent;
            Caption = 'Cost Factor';
        }
        field(19; "Unit Cost"; Decimal)
        {
            AccessByPermission = tabledata "Purchase Price Access" = R;
            DataClassification = CustomerContent;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Unit Cost';
            MinValue = 0;
        }
        field(20; "Line Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            Caption = 'Line Discount %';
            MaxValue = 100;
            MinValue = 0;
        }
        field(21; "Allow Line Disc."; Boolean)
        {
            Caption = 'Allow Line Disc.';
            DataClassification = CustomerContent;
        }
        field(22; "Allow Invoice Disc."; Boolean)
        {
            Caption = 'Allow Invoice Disc.';
            DataClassification = CustomerContent;
        }
        field(23; "Price Includes VAT"; Boolean)
        {
            Caption = 'Price Includes VAT';
            DataClassification = CustomerContent;
        }
        field(24; "VAT Bus. Posting Gr. (Price)"; Code[20])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(25; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";
        }
        field(26; "Asset ID"; Guid)
        {
            Caption = 'Asset ID';
            DataClassification = CustomerContent;
        }
        field(27; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Line Amount';
            MinValue = 0;
            Editable = false;
        }
        field(28; "Price Type"; Enum "Price Type")
        {
            Caption = 'Price Type';
            DataClassification = CustomerContent;
        }
        field(29; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Status; Enum "Price Status")
        {
            Caption = 'Price Status';
            DataClassification = CustomerContent;
        }
        field(31; "Direct Unit Cost"; Decimal)
        {
            AccessByPermission = tabledata "Purchase Price Access" = R;
            DataClassification = CustomerContent;
            AutoFormatExpression = Rec."Currency Code";
            AutoFormatType = 2;
            Caption = 'Direct Unit Cost';
            MinValue = 0;
        }
        field(32; "Source Group"; Enum "Price Source Group")
        {
            Caption = 'Source Group';
            DataClassification = CustomerContent;
        }
        field(33; "Product No."; Code[20])
        {
            Caption = 'Product No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Asset Type" = const(Item)) Item where("No." = field("Product No."))
            else
            if ("Asset Type" = const("G/L Account")) "G/L Account"
            else
            if ("Asset Type" = const(Resource)) Resource
            else
            if ("Asset Type" = const("Resource Group")) "Resource Group"
            else
            if ("Asset Type" = const("Item Discount Group")) "Item Discount Group"
            else
            if ("Asset Type" = const("Service Cost")) "Service Cost";
            ValidateTableRelation = false;
        }
        field(34; "Assign-to No."; Code[20])
        {
            Caption = 'Assign-to No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Type" = const(Campaign)) Campaign
            else
            if ("Source Type" = const(Contact)) Contact
            else
            if ("Source Type" = const(Customer)) Customer
            else
            if ("Source Type" = const("Customer Disc. Group")) "Customer Discount Group"
            else
            if ("Source Type" = const("Customer Price Group")) "Customer Price Group"
            else
            if ("Source Type" = const(Job)) Job
            else
            if ("Source Type" = const("Job Task")) "Job Task"."Job Task No." where("Job No." = field("Parent Source No."), "Job Task Type" = const(Posting))
            else
            if ("Source Type" = const(Vendor)) Vendor;
            ValidateTableRelation = false;
        }
        field(35; "Assign-to Parent No."; Code[20])
        {
            Caption = 'Assign-to Parent No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Type" = const("Job Task")) Job;
            ValidateTableRelation = false;
        }
        field(36; "Variant Code Lookup"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = if ("Asset Type" = const(Item)) "Item Variant".Code where("Item No." = field("Asset No."));
            ValidateTableRelation = false;
        }
        field(37; "Unit of Measure Code Lookup"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = if ("Asset Type" = const(Item)) "Item Unit of Measure".Code where("Item No." = field("Asset No."))
            else
            if ("Asset Type" = const(Resource)) "Resource Unit of Measure".Code where("Resource No." = field("Asset No."))
            else
            if ("Asset Type" = const("Resource Group")) "Unit of Measure";
            ValidateTableRelation = false;
        }
        field(39; "License Name"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Price List Header".Description where(Code = field("Price List Code")));
        }
        field(40; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Trade Partner".Code;
        }
        field(41; "Listing Status Setting"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';

            trigger OnValidate()
            begin
                if Rec.Status = Rec.Status::Inactive then
                    Rec."Sync Price" := false;
            end;
        }
        field(42; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(43; "Sync Price"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(44; "Price Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Price List Line" where("Price List Code" = field("Price List Code"), "Line No." = field("Line No.")));
        }
        field(45; "Transaction No."; Integer)
        {

        }
        field(46; "Base Volume"; Decimal)
        {
            Caption = 'Base Volume';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(47; "Cost Unit Thereafter"; Decimal)
        {
            Caption = 'Cost Unit Thereafter';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(48; "PIP Code"; code[7])
        {
            DataClassification = ToBeClassified;
        }
        field(5702; "Item Category Code"; Code[20])
        {
            Caption = 'Sub-Child Category';
            TableRelation = "Item Category";
            ValidateTableRelation = false;
        }
        field(85103; "Child Category"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Item Category"."Parent Category" where(Code = field("Item Category Code")));
        }
        field(85104; "Parent Category"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Item Category"."Parent Category" where(Code = field("Child Category")));
        }
        field(85105; "Channel Item Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Channel Item Listing" where("Item No." = field("Product No."), "Channel Code" = const('LIFERAY')));
        }
    }

    keys
    {
        key(Key1; "Channel Code", "Price List Code", "Line No.")
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