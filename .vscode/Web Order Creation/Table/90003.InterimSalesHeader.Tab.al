table 90003 "Interim Sales Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Web Document Type")
        {
            Caption = 'Document Type';
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
            OptionMembers = Rejected,Accepted,"SO Created";
        }
        field(11; Remarks; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Bill-to Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Ship-to Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Ship-to Address"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Ship-to Address 2"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Ship-to City"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Ship-to Post Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Ship-to County"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Ship-to Country"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Customer Phone Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "External Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Buyer Email"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Buyer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Earliest Delivery date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Earliest Ship Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Fullfillment Channel"; Option)
        {
            OptionMembers = Seller,Amazon;
            OptionCaptionML = ENU = 'Seller,Amazon', ENG = 'Seller,Amazon';
            DataClassification = ToBeClassified;
        }
        field(28; "Order Type"; Option)
        {
            OptionMembers = ,"Business Order","Premium Order","Prime Order";
            OptionCaptionML = ENU = '"Business Order","Premium Order","Prime Order"', ENG = '"Business Order","Premium Order","Prime Order"';
            DataClassification = ToBeClassified;
        }
        field(29; "Order Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Payment Method"; code[10])
        {
            TableRelation = "Payment Method".Code;
            DataClassification = ToBeClassified;
        }
        field(31; "Channel Order ID"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Sell to Country"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Shipment Method Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Currency Code"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Gift Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Order Placed At"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Web Shipment Method"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(38; "Bill- to Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Web Shipping Agent"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Bill-to CompanyName"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Ship-to CompanyName"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Deal ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(43; "Bill-to County"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(44; "No of Error"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Incoming/Outgoing Error Log" WHERE("Document No." = field("No.")));
            Editable = false;
        }
        field(45; "Error Text"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Incoming/Outgoing Error Log"."Error Text" WHERE("Document No." = field("No.")));
        }
        field(46; "Error Text2"; Text[250])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Incoming/Outgoing Error Log"."Error Text2" WHERE("Document No." = field("No.")));
            Editable = false;
        }
        field(47; "Trade Partner Code"; Code[250])
        {
            TableRelation = "Trade Partner";
            ValidateTableRelation = false;
        }
        field(48; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
        }
        field(49; "Shipping Agent Service Code"; Code[250])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            ValidateTableRelation = false;
        }
        field(50; "Shipment Date"; Date)
        {
            Editable = false;
        }
        field(51; "Ship-to Country/Region Code"; Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(52; "Promised Delivery Date"; Date)
        {
            AccessByPermission = TableData "Order Promising Line" = R;
        }
        field(53; "Amount Including VAT"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Interim Sales Line"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.")));
            AutoFormatExpression = "Currency Code";
            Editable = false;
        }
        field(54; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
        }
        field(55; "Requested Delivery Date"; Date)
        {
            AccessByPermission = tableData "Order Promising Line" = R;
        }
        field(56; "Currency Factor"; Decimal)
        {
            Editable = false;
            MinValue = 0;
        }
        field(57; Comments; Text[250])
        {
        }
        field(58; "Package Tracking No."; Text[30])
        {
        }
        field(59; "Location Code"; Code[20])
        {
        }
        field(60; "Ship to Address 3"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Order Fullfilled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Order Fullfillment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(63; "Pickup Name"; Text[50])
        {
            Description = 'Channel Integration';
        }
        field(64; "Pickup Address"; Text[100])
        {
            Description = 'Channel Integration';
        }
        field(65; "Pickup Address 2"; Text[100])
        {
            Description = 'Channel Integration';
        }
        field(66; "Pickup City"; Text[30])
        {
            Description = 'Channel Integration';
        }
        field(67; "Pickup Post Code"; Code[20])
        {
            Description = 'Channel Integration';
        }
        field(68; "Pickup County"; Text[30])
        {
            Description = 'Channel Integration';
        }
        field(69; "Pickup Country/Region Code"; Code[10])
        {
            Description = 'Channel Integration';
            TableRelation = "Country/Region";
        }
        field(70; "Total Weight"; Decimal)
        {
            Description = 'Channel Integration';
        }
        field(71; "Pickup Date"; Date)
        {
            Description = 'Channel Integration';
        }
        field(72; "Total Order Item Amount"; Decimal)
        {
            Description = 'Channel Integration';
        }
        field(73; "Email (Location)"; Text[80])
        {
            ExtendedDatatype = EMail;
            Description = 'Channel Integration';
        }
        field(74; "No. Of Parcels"; Integer)
        {
            Description = 'Channel Integration';
        }
        field(75; "Tracking No."; Code[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Shipment Tracking"."Tracking No." WHERE("Document Type" = FILTER(Order), "Document No." = field("No.")));
            Description = 'Channel Integration';
        }
        field(76; "Job Reference"; Code[50])
        {
            Description = 'Channel Integration';
        }
        field(77; "Pickup Time"; Time)
        {
            Description = 'Channel Integration';
        }
        field(78; "Cancelled By"; Code[50])
        {
            Description = 'Channel Integration';
        }
        field(79; "Cancelled On"; DateTime)
        {
        }
        field(80; "Order Tracking ID"; Code[20])
        {
        }
        field(81; "Gift Wrap Required"; Boolean)
        {

        }
        field(82; "Gift Wrap By"; Code[10])
        {
        }
        field(83; "Gift Wrap date"; Date)
        {
        }
        field(84; "Order Created On"; DateTime)
        {
        }
        field(85; "Ship-to Phone"; Text[20])
        {
        }
        field(86; "Ship-to Email"; Text[80])
        {
        }
        field(87; "No. of Items"; Integer)
        {
        }
        field(88; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(89; "FullFillment Status"; Option)
        {
            OptionMembers = "Not Acknowledged",Acknowledged,Fullfilled,Cancelled,Confirmed;
        }
        field(90; "Scanned Date"; DateTime)
        {
        }
        field(91; "Scanned By"; Code[20])
        {
        }
        field(92; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Sales Order","Internal Pick","Return Order";
            OptionCaptionML = ENU = ' ,Sales Order,Internal Pick ,Return Order',
                              ENG = ' ,Sales Order,Internal Pick, Return Order';
        }
        field(93; "Destination Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(94; "Order Ack. Exported"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(95; "Moved In Handled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(96; "File Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(97; ReservedFlag; Boolean)
        {
            Caption = 'Reserved';
        }
        field(98; "Process Date"; date)
        {
        }
        field(99; "Trolley No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(100; "Bay No."; Code[20])
        {
        }
        field(101; "Old MultiLine Order No."; Code[250])
        {
        }
        field(102; "MultiLine Order No."; Code[250])
        {
            //Use this ID to move data in handled via transfer fields
        }
        field(103; "Shelf No."; Code[20])
        {
            Editable = false;
        }
        field(104; "Order Discount Amount"; Decimal)
        {
        }
        field(105; "Shipping Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(106; "Net Order Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(107; "Total No. of Items"; Integer)
        {
        }
        field(108; "Customer Posting Group"; Code[20])
        {
        }
        field(109; "Gift Card"; Boolean)
        {
        }
        field(110; "Gift Order Amount"; Decimal)
        {
        }
        field(111; "Order Status"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(112; order_id; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(113; "Reason Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(114; "Reason Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(115; "Ready to process"; Boolean)
        {
        }
        field(116; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(117; "ET Access Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(118; "Sales Order Created"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Web Buffer" where("Web Document No." = field("No.")));
        }
        field(119; "Weekend Ship Agent Serv Code"; Code[250])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Weekend Shipping Agent Code"));
            Caption = 'Weekend Shipping Agent Service Code';
            ValidateTableRelation = false;
        }
        field(120; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(121; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
            Caption = 'SalesPerson/Purchaser Code';
        }
        field(122; "Weekend Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
        }
        field(123; "Total Order Quantity"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line"."Qty. to Deliver" where("Document Type" = const(Order), "Document No" = field("No."), Type = const(Item)));
            DecimalPlaces = 0 : 5;
        }
        field(124; "Total Order Amount"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Amount where("Document Type" = const(Order), "Document No" = field("No."), Type = const(Item)));
            DecimalPlaces = 0 : 5;
        }
        field(125; "Total Order Amount Incl. VAT"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line"."Amount Including VAT" where("Document Type" = const(Order), "Document No" = field("No."), Type = const(Item)));
            DecimalPlaces = 0 : 5;
        }
    }


    keys
    {
        key(PK; "Document Type", "No.")
        {
            Clustered = true;
        }
    }

    [IntegrationEvent(true, false)]
    Local procedure OnBeforeSalesLineByChangedFieldNo(InterimSalesHeader: Record "Interim Sales Header"; VAR InterimSalesLine: Record "Interim Sales Line"; ChangedFieldNo: Integer; VAR IsHandled: Boolean)
    Begin
    End;

    [IntegrationEvent(true, false)]
    Local Procedure OnUpdateSalesLineByChangedFieldName(InterimSalesHeader: Record "Interim Sales Header"; VAR InterimSalesLine: Record "Interim Sales Line"; ChangedFieldName: Text[100])
    begin
    End;

    var
        IntrimSalesLine: Record "Interim Sales Line";
        ErrorLog: Record "Incoming/Outgoing Error Log";

    trigger OnInsert()
    var
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit "No. Series";
    begin
        GeneralSetup.Get();
        GeneralSetup.TestField("Web Order Nos");
        if "No." = '' then
            "No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
    begin
        IntrimSalesLine.RESET;
        IntrimSalesLine.SetRange("Document Type", Rec."Document Type");
        IntrimSalesLine.SETRANGE("Document No", Rec."No.");
        IntrimSalesLine.DELETEALL(TRUE);

        //code to delete error log
        ErrorLog.RESET;
        ErrorLog.SETRANGE("Document No.", "No.");
        ErrorLog.DELETEALL;
    end;
}