table 90005 "Handled Interim Sales Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Web Document Type")
        {
            DataClassification = ToBeClassified;

        }
        field(2; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(3; "Sell-to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Web Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(5; Address; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Address 2"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(7; City; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(8; "Post Code"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(9; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(10; status; Option)
        {
            OptionMembers = Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Cancelled,"Ready To Dispatch","No Stock","Partially Scanned";
            //OptionCaptionML = ENU = 'Confirmed,"In Progress",Processing,Dispatched,Rejected,Throttled,Cancelled,Ready To Dispatch,No Stock,Partially Scanned',
            //                  ENG = 'Confirmed,"In Progress",Processing,Dispatched,Rejected,Throttled,Cancelled,Ready To Dispatch,No Stock,Partially Scanned';
        }
        field(11; Remarks; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(13; "Bill-to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Ship-to Name"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(15; "Ship-to Address"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(16; "Ship-to Address 2"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(17; "Ship-to City"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(18; "Ship-to Post Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(19; "Ship-to County"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(20; "Ship-to Country"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(22; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(23; "Customer Phone Number"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(25; "External Document No."; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(26; "Buyer Email"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(27; "Buyer Name"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(28; "Earliest Delivery date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(29; "Earliest Ship Date"; Date)
        {
            DataClassification = ToBeClassified;

        }
        field(30; "Fullfillment Channel"; Option)
        {
            OptionMembers = Seller,Amazon;
            OptionCaptionML = ENU = 'Seller,Amazon', ENG = 'Seller,Amazon';
            DataClassification = ToBeClassified;

        }
        field(33; "Order Type"; Option)
        {
            OptionMembers = ,"Business Order","Premium Order","Prime Order";
            OptionCaptionML = ENU = '"Business Order","Premium Order","Prime Order"', ENG = '"Business Order","Premium Order","Prime Order"';
            DataClassification = ToBeClassified;

        }
        field(35; "Order Amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(36; "Payment Method"; code[20])
        {
            TableRelation = "Payment Method".Code;
            DataClassification = ToBeClassified;
        }
        field(38; "Channel Order ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Sell to Country"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(40; "Shipment Method Code"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(41; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;

        }
        field(43; "Gift Message"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(44; "Order Placed At"; DateTime)
        {
            DataClassification = ToBeClassified;

        }
        field(45; "Web Shipment Method"; Code[50])
        {
            DataClassification = ToBeClassified;

        }
        field(47; "Bill- to Name"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(48; "Web Shipping Agent"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(49; "Bill-to CompanyName"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(50; "Ship-to CompanyName"; Text[50])
        {
            DataClassification = ToBeClassified;

        }
        field(51; "Deal ID"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(52; "Bill-to County"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(55; IsLLOrder; Boolean)
        {
        }
        field(56; "No of Error"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Incoming/Outgoing Error Log" WHERE("Document No." = field("No.")));
            Editable = false;
        }
        field(57; "Error Text"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Incoming/Outgoing Error Log"."Error Text" WHERE("Document No." = field("No.")));
        }
        field(58; "Error Text2"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Incoming/Outgoing Error Log"."Error Text2" WHERE("Document No." = field("No.")));
            Editable = false;
        }
        field(60; "Trade Partner Code"; Code[250])
        {
            TableRelation = "Trade Partner";
        }
        field(61; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF xRec."Shipping Agent Code" = "Shipping Agent Code" THEN
                    EXIT;

                "Shipping Agent Service Code" := '';
            end;

        }
        field(62; "Shipping Agent Service Code"; Code[250])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(63; "Shipment Date"; Date)
        {
            Editable = false;
        }
        field(64; "Ship-to Country/Region Code"; Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(65; "Promised Delivery Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
        }
        field(66; "Amount Including VAT"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Interim Sales Line"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.")));
            AutoFormatExpression = "Currency Code";
            Editable = false;
        }
        field(67; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
        }
        field(68; "Requested Delivery Date"; Date)
        {
            AccessByPermission = tableData "Order Promising Line" = R;
        }
        field(70; "Currency Factor"; Decimal)
        {
            Editable = false;
            MinValue = 0;
        }
        field(71; Comments; Text[250])
        {
        }
        field(72; "Package Tracking No."; Text[30])
        {
        }
        field(73; "Location Code"; Code[20])
        {
        }
        field(74; "Ship to Address 3"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(75; "Order Fullfilled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(76; "Order Fullfillment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }

        field(77; "Order Amount 2"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Handled Interim Sales Line"."Amount Including VAT" where("Document No" = field("No."), "Document Type" = field("Document Type")));
        }




        field(50010; "Pickup Name"; Text[50])
        {
            Description = 'Channel Integration';
        }
        field(50011; "Pickup Address"; Text[100])
        {
            Description = 'Channel Integration';

        }
        field(50012; "Pickup Address 2"; Text[100])
        {
            Description = 'Channel Integration';
        }
        field(50013; "Pickup City"; Text[30])
        {
            Description = 'Channel Integration';
        }
        field(50014; "Pickup Post Code"; Code[20])
        {
            Description = 'Channel Integration';
        }
        field(50015; "Pickup County"; Text[30])
        {
            Description = 'Channel Integration';
        }
        field(50016; "Pickup Country/Region Code"; Code[10])
        {
            Description = 'Channel Integration';
            TableRelation = "Country/Region";
        }
        field(50017; "Total Weight"; Decimal)
        {
            Description = 'Channel Integration';
        }
        field(50018; "Pickup Date"; Date)
        {
            Description = 'Channel Integration';
        }
        field(50019; "Total Order Item Amount"; Decimal)
        {
            Description = 'Channel Integration';
        }
        field(50020; "Email (Location)"; Text[80])
        {
            ExtendedDatatype = EMail;
            Description = 'Channel Integration';
        }
        field(50021; "No. Of Parcels"; Integer)
        {
            Description = 'Channel Integration';
        }
        field(50022; "Tracking No."; Code[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Shipment Tracking"."Tracking No." WHERE("Document Type" = FILTER(Order), "Document No." = field("No.")));
            Description = 'Channel Integration';
        }
        field(50026; "Job Reference"; Code[50])
        {
            Description = 'Channel Integration';
        }
        field(50029; "Pickup Time"; Time)
        {
            Description = 'Channel Integration';
        }
        field(50041; "Cancelled By"; Code[50])
        {
            Description = 'Channel Integration';
        }
        field(50042; "Cancelled On"; DateTime)
        {
        }
        field(50054; "Order Tracking ID"; Code[20])
        {
        }
        field(50056; "Gift Wrap Required"; Boolean)
        {

        }
        field(50057; "Gift Wrap By"; Code[10])
        {
        }
        field(50058; "Gift Wrap date"; Date)
        {
        }
        field(50066; "Order Created On"; DateTime)
        {

        }
        field(50068; "Ship-to Phone"; Text[20])
        {
        }
        field(50069; "Ship-to Email"; Text[80])
        {
        }
        field(50075; Hazardous; Boolean)
        {

        }
        field(50081; "No. of Items"; Integer)
        {
        }


        field(50085; "Stock Posted"; Boolean)
        {
        }
        field(50086; "Financial Entry Posted"; Boolean)
        {
        }
        field(50088; "AmazonLogServiceOfferId"; Text[250])
        {
        }
        field(50089; Reserved; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = - Exist("Interim Sales Line" WHERE("Document Type" = FIELD("Document Type"), "Document No" = FIELD("No."), Reserved = FILTER(false)));
            ObsoleteState = Removed;
            ObsoleteReason = 'We are using field id 50102';
        }
        field(50090; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50093; "FullFillment Status"; Option)
        {
            OptionMembers = "Not Acknowledged",Acknowledged,Fullfilled,Cancelled,Confirmed;
        }
        field(50094; "Duplicate Order"; Boolean)
        {
        }
        field(50095; "Scanned Date"; DateTime)
        {
        }
        field(50096; "Scanned By"; Code[20])
        {
        }
        field(50097; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Sales Order","Internal Pick","Return Order";
            OptionCaptionML = ENU = ' ,Sales Order,Internal Pick ,Return Order',
                              ENG = ' ,Sales Order,Internal Pick, Return Order';
        }
        field(50098; "Destination Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50099; "Order Ack. Exported"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50100; "Moved In Handled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50101; "File Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(50102; ReservedFlag; Boolean)
        {
            Caption = 'Reserved';
        }
        field(50105; "Process Date"; date)
        {

        }
        field(50106; "Manifest No."; Code[20])
        {

        }
        field(50107; "Manifest Print Date"; DateTime)
        {

        }
        field(50108; "MultiLine Order No."; Code[250])
        {

        }
        field(50109; "Invoice No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        //CAS-27945-M1R5J2.MH -->
        field(50110; "WebInv Amt Incl VAT"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Handled Interim Sales Line"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.")
                              , "Web Sales Invoice No." = field("Web Sales Invoice No. Filter")));
            AutoFormatExpression = "Currency Code";
            Editable = false;
        }
        field(50111; "WebInv Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Handled Interim Sales Line"."Amount" WHERE("Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.")
                              , "Web Sales Invoice No." = field("Web Sales Invoice No. Filter")));
            AutoFormatExpression = "Currency Code";
            Editable = false;
        }
        field(50112; "Web Sales Invoice No. Filter"; Code[20])
        {
            Caption = 'Web Sales Invoice No.';
            FieldClass = FlowFilter;
        }

        field(50113; "Total Weight 2"; Decimal)
        {
            Caption = 'Total Weight';
            FieldClass = FlowField;
            CalcFormula = sum("Handled Interim Sales Line".Weight where("Document No" = field("No."), "Document Type" = field("Document Type")));
        }
        //CAS-27945-M1R5J2.MH <--
        field(90022; "Order Discount Amount"; Decimal)
        {

        }
        field(90023; Reconciled; Boolean)
        {

        }
        field(90024; "Email Send"; Boolean)
        {

        }
        field(90025; "Return Note Download"; Boolean)
        {

        }
        //Hermes Specific Fields US-8196++
        field(90028; "Child Client ID"; Text[100])
        {

        }
        field(90029; "Child Client Name"; Text[100])
        {

        }
        //Hermes Specific Fields US-8196--

        //Paarth D Dave - 8197-4  - Adding Posted Assembly Order No ---- Start
        field(90030; "Assembly Order Created"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Assembly Header" Where("Description 2" = field("Channel Order ID")));
        }


        field(90031; "Pstd. Assembly Order"; Boolean)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Posted Assembly Header" Where("Description 2" = field("Channel Order ID")));
            Caption = 'Posted Assembly Order';
        }

        field(90032; "Assemply Order"; Boolean)
        {

            Caption = 'Assembly Order';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Handled Interim Sales Line" where("Document No" = field("No."), "Auto Assembly Order" = filter(true)));
        }

        //Paarth D Dave - 8197-4  - Adding Posted Assembly Order No ---- End

        field(90033; "Total No. of Items"; Integer)
        {

        }
        //8862++
        field(90034; "Customer Posting Group"; Code[20])
        {

        }
        //8862--
        field(90035; "Gift Card"; Boolean)
        {
        }
        field(90036; "Gift Order Amount"; Decimal)
        {
        }
        field(90037; "Order Status"; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(90038; "Order Discount Amount 2"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Handled Interim Sales Line".Discount where("Document No" = field("No."), "Document Type" = field("Document Type")));

        }

        field(90039; "No of Item Lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Handled Interim Sales Line" where(Type = const(Item), "Document No" = field("No.")));
        }

        field(90040; "Total Number Of Items 2"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = COunt("Handled Interim Sales Line" where("Document No" = field("No.")));
        }
        field(90041; "Calculated Weight"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Handled Interim Sales Line".Weight where("Document No" = field("No."), "Document Type" = field("Document Type")));
        }

        field(90042; WarehouseShipmentNo; Code[20])
        {
            Caption = 'Warehouse Shipment No.';
            Editable = false;
            DataClassification = ToBeClassified;

        }
        field(90043; WarehousePick; Code[20])
        {
            Caption = 'Warehouse Pick No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }




        field(90044; order_id; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(90045;UpdatedDispatchedOnPortal; Boolean)
        {
            DataClassification = ToBeClassified;
        }


    }


    keys
    {
        key(PK; "Document Type", "No.")
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
    begin

    end;

    trigger OnRename()
    begin

    end;


}