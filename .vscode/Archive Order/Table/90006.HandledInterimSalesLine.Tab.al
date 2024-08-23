table 90006 "Handled Interim Sales Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Web Document Type")
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
        }
        field(2; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Type; Enum "Sales Line Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Type';
        }
        field(4; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Discount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "VAT amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; Description2; Text[50])
        {
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(13; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "VAT Prod. Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
            DataClassification = ToBeClassified;
        }
        field(15; "Channel Identifier"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Channel Item Id"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Channel SKU"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Shipping Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Gift Wrap Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "VAT%"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Line Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
        }
        field(23; "Discount %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Gift Wrap"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "NAV Variant code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Variant Code';
        }
        field(26; "Channel Variant"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Units per Parcel"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Amount Including VAT"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Currency Code"; Code[10])
        {
            Editable = false;
            TableRelation = Currency;
            DataClassification = ToBeClassified;
        }
        field(30; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Shipping Agent Code"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Shipping Agent Code" WHERE("No." = field("Document No")));
            TableRelation = "Shipping Agent";
            AccessByPermission = TableData "Shipping Agent Services" = R;
        }
        field(32; "Shipping Agent Service Code"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(33; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DataClassification = ToBeClassified;
        }
        field(34; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;
        }
        field(35; "No of Error"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("Incoming/Outgoing Error Log" WHERE("Document No." = field("Document No")));
        }
        field(36; "Order Status"; Option)
        {
            OptionMembers = Rejected,Accepted,"SO Created";
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
            Editable = false;
        }
        field(37; "VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;
        }
        field(38; "Tracking No."; Code[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Shipment Tracking"."Tracking No." WHERE("Document Type" = FILTER(Order), "Document No." = field("No.")));
        }
        field(39; "Sell-to Customer No."; Code[20])
        {
            Editable = false;
        }
        field(40; "Channel Order ID"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Unit Cost(LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Quantity Allocated"; Decimal)
        {
            FieldClass = Normal;
        }
        field(43; "Allocated Status"; Option)
        {
            Editable = false;
            OptionMembers = "Not Allocated","Fully Allocated","Part Allocated","Ready To Dispatch","In Picking",Picked;
            DataClassification = ToBeClassified;
        }
        field(44; Hazardous; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(45; "Destination Doc. Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(46; Reserved; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(47; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));
        }
        field(48; "Document Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Handled Interim Sales Header"."Document Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(49; "Location Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Handled Interim Sales Header"."Location Code" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(50; "Scanned Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Quantity(Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Item Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Single,Assembly,Component;
            OptionCaptionML = ENU = 'Single, Assembly, Component',
                              ENG = 'Single, Assembly, Component';
        }
        field(53; "BOM Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Moved In Handled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Sales Order","Internal Pick";
            OptionCaptionML = ENU = ' ,Sales Order,Internal Pick',
                              ENG = ' ,Sales Order,Internal Pick';
        }
        field(56; "Destination Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Trolley No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(58; "Dispatch Scan"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Price Authorised"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60; FileName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Channel Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Pack Description"; Text[50])
        {
            Editable = true;
        }
        field(63; "ABV (%)"; Decimal)
        {
        }
        field(64; Status; Option)
        {
            Editable = false;
            OptionMembers = Rejected,Accepted,"SO Created";
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(65; "Pick No"; Code[20])
        {
        }
        field(66; "Pick Line No"; Integer)
        {
        }
        field(67; "Picking Status"; Option)
        {
            OptionMembers = " ","In Picking",Picked;
        }
        field(68; "Multiline Order"; Boolean)
        {
        }
        field(69; "Bay No."; Code[20])
        {
        }
        field(70; "Trolley Closed Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity Handled';
        }
        field(71; "Shelf No."; Code[20])
        {
        }
        field(72; "Reserved Qty"; Decimal)
        {
        }
        field(73; "Header Id"; Guid)
        {
        }
        field(74; "Gift Card"; Boolean)
        {
        }
        field(75; order_id; Text[250])
        {
        }
        field(76; order_line_id; Text[250])
        {
        }
        field(77; "Reason Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(78; "Reason Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(79; "ET Access Code"; Code[50])
        {
        }
        field(80; "Sales Order Created"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Web Buffer" where("Web Document No." = field("Document No")));
        }
        field(81; "Qty. to Deliver"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(82; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(83; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(84; "Sig Channel Item Id"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(85; "Variant Code Mandatory"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Item Variant" where("Item No." = field("No.")));
        }
        field(86; "Changed UnitPrice"; Boolean)
        {
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document Type", "Document No", "Line No.")
        {
            Clustered = true;
        }
        key(SK; Type, "No.", "NAV Variant code")
        {

        }
    }
}