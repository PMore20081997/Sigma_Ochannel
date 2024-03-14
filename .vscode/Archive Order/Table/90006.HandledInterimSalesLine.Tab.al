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
        field(16; "VAT Prod. Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
            DataClassification = ToBeClassified;


        }
        field(17; "Channel Identifier"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(18; "Channel Item Id"; Code[250])
        {
            DataClassification = ToBeClassified;

        }
        field(19; "Channel SKU"; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(21; "Shipping Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(22; "Gift Wrap Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(24; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "VAT%"; Text[30])
        {
            DataClassification = ToBeClassified;

        }

        field(27; "Line Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
        }

        field(28; "Discount %"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(29; "Gift Wrap"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(31; "NAV Variant code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Variant Code';

        }
        field(32; "Channel Variant"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(34; "Units per Parcel"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(35; "Amount Including VAT"; Decimal)
        {
            // Editable = false;
            DataClassification = ToBeClassified;

        }
        field(36; "Currency Code"; Code[10])
        {
            Editable = false;
            TableRelation = Currency;
            DataClassification = ToBeClassified;

        }
        field(37; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;

        }

        field(39; "Shipping Agent Code"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Shipping Agent Code" WHERE("No." = field("Document No")));
            TableRelation = "Shipping Agent";
            AccessByPermission = TableData "Shipping Agent Services" = R;


        }
        field(40; "Shipping Agent Service Code"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));


        }
        field(41; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DataClassification = ToBeClassified;

        }


        field(45; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;

        }
        field(47; "No of Error"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("Incoming/Outgoing Error Log" WHERE("Document No." = field("Document No")));

        }
        field(48; "Order Status"; Option)
        {
            OptionMembers = Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Cancelled,"Ready To Dispatch","No Stock","Partially Scanned";
            FieldClass = FlowField;
            //CalcFormula = Lookup("Interim Sales Header".Status WHERE("No." = field("Document No")));
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
            Editable = false;
        }
        field(50; "VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;


        }
        field(51; "Tracking No."; Code[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Shipment Tracking"."Tracking No." WHERE("Document Type" = FILTER(Order), "Document No." = field("No.")));


        }
        field(53; "Sell-to Customer No."; Code[20])
        {
            Editable = false;
        }
        field(54; "Channel Order ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Unit Cost(LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(50011; "Quantity Allocated"; Decimal)
        {
            FieldClass = Normal;
        }
        field(50015; "Allocated Status"; Option)
        {
            Editable = false;
            OptionMembers = "Not Allocated","Fully Allocated","Part Allocated","Ready To Dispatch","In Picking",Picked;
            DataClassification = ToBeClassified;

        }
        field(50026; Hazardous; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(50028; "Destination Doc. Line No"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(50029; Reserved; Boolean)
        {
            DataClassification = ToBeClassified;

        }

        field(50032; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

        }
        field(50033; "Document Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Handled Interim Sales Header"."Document Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));


        }
        field(50034; "Location Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Handled Interim Sales Header"."Location Code" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(50036; "Scanned Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(50037; "Quantity(Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50038; "Item Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Single,Assembly,Component;
            OptionCaptionML = ENU = 'Single, Assembly, Component',
                              ENG = 'Single, Assembly, Component';
        }
        field(50039; "BOM Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(50042; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Sales Order","Internal Pick";
            OptionCaptionML = ENU = ' ,Sales Order,Internal Pick',
                              ENG = ' ,Sales Order,Internal Pick';
        }
        field(50043; "Destination Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50044; "Trolley No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50045; "Dispatch Scan"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50046; "Price Authorised"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50047; FileName; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50048; "Channel Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(90011; "Pack Description"; Text[50])
        {
            Editable = true;
            // FieldClass = FlowField;
            // CalcFormula = lookup ("Item Unit of Measure"."Pack Description" WHERE("Item No." = field("No."), Code = field("Base Unit of Measure")));
        }
        field(90012; "ABV (%)"; Decimal)
        {

        }
        field(90013; Status; Option)
        {
            Editable = false;
            OptionMembers = Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Cancelled,"Ready To Dispatch","No Stock","Partially Scanned";
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(90014; "Pick No"; Code[20])
        {

        }
        field(90015; "Pick Line No"; Integer)
        {

        }
        field(90016; "Picking Status"; Option)
        {
            OptionMembers = " ","In Picking",Picked;

        }

        field(90018; "Multiline Order"; Boolean)
        {

        }
        field(90019; "Bay No."; Code[20])
        {

        }
        field(90020; "Trolley Closed Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity Handled';
        }
        field(90021; "Shelf No."; Code[20])
        {

        }
        field(90022; "Reserved Qty"; Decimal)
        {

        }


        field(90030; "Gift Card"; Boolean)
        {

        }

        field(90031; order_id; Text[250])
        {

        }

        field(90032; order_line_id; Text[250])
        {

        }
        field(90049; "ET Access Code"; Code[50])
        {

        }
        field(90051; "Qty. to Deliver"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(90052; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(70048; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(70049; "Sig Channel Item Id"; Integer)
        {
            DataClassification = ToBeClassified;

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