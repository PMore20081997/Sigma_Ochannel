table 90006 "Handled Interim Sales Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Web Document Type")
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Document No"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(3; Type; Option)
        {
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Cross reference","Common Item No.";
            DataClassification = ToBeClassified;
            OptionCaptionML = ENU = ',G/L Account,Item,Resource,Fixed Asset,Cross reference,Common Item No.',
            ENG = ' ,G/L Account,Item,Resource,Fixed Asset,Cross reference,Common Item No.';

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
        field(16; "VAT Prod. Posting Group"; Code[10])
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
        field(20; Remarks; Text[100])
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
        field(23; "Promotion Code"; Code[50])
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
        field(26; "Discount%"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(27; "Line Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
        }
        field(29; "Gift Wrap"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(31; "NAV Variant code"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(32; "Channel Variant"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(34; "Units per Parcel"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(35; "Amount Including VAT"; Decimal)
        {
            Editable = false;
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
        field(38; "Net Selling Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(39; "Shipping Agent Code"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Shipping Agent Code" WHERE("No." = field("Document No")));
            TableRelation = "Shipping Agent";
            AccessByPermission = TableData "Shipping Agent Services" = R;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF xRec."Shipping Agent Code" = "Shipping Agent Code" THEN
                    EXIT;

                "Shipping Agent Service Code" := '';
            end;

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
        field(42; "Promised Delivery Date"; Date)
        {
            AccessByPermission = tabledata "Order Promising Line" = R;
            DataClassification = ToBeClassified;

        }
        field(43; "Requested Delivery Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
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
        field(48; "Ordser Status"; Option)
        {
            OptionMembers = Confirmed,"In Progress",Processing,Dispatched,Rejected,Throttled,Cancelled,"Ready To Dispatch","No Stock","Partially Dispatched";
            //FieldClass = FlowField;
            //CalcFormula = Lookup ("Interim Sales Header".Status WHERE("No." = field("Document No")));
            //Editable = false;
        }
        field(50; "VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                VALIDATE("VAT Prod. Posting Group");
            end;

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
        field(50010; "	Actual Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Description = 'Channel Integration';

        }
        field(50011; "Quantity Allocated"; Decimal)
        {
            FieldClass = FlowField;
            ObsoleteState = Removed;
        }
        field(50015; "Allocated Status"; Option)
        {
            Editable = false;
            OptionMembers = "Not Allocated","Fully Allocated","Part Allocated","Ready To Dispatch","In Picking",Picked;
            DataClassification = ToBeClassified;
            ObsoleteState = Removed;
        }
        field(50026; Hazardous; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50027; "Item Shipping Group"; Code[10])
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
        field(50030; "Old Item No."; Code[20])
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
            CalcFormula = Lookup("Interim Sales Header"."Document Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));


        }
        field(50034; "Location Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Location Code" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
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
        field(50041; "Moved In Handled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50042; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Sales Order","Internal Pick";
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
        field(50100; "Volume(ml)"; Decimal)
        {
            CaptionML = ENU = 'Volume (ml)', ENG = 'Volume (ml)';
        }

        field(90009; Size; Code[20])
        {
        }
        field(90010; "Pack"; Decimal)
        {
            DecimalPlaces = 0 : 0;
            trigger OnValidate()
            var
                myInt: Integer;
            begin

            end;
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
        field(90013; "Web Sales Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Web Sales Invoice No.';
            Description = 'CAS-26633-Z8W1Y1.MH';
        }
        field(90014; "Order No."; Code[20])
        {

        }
        field(90015; "Order Line No."; Integer)
        {

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