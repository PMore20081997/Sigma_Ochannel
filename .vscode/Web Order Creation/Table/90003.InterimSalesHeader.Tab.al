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
        field(36; "Payment Method"; code[10])
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
            ValidateTableRelation = false;
        }
        field(61; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
        }
        field(62; "Shipping Agent Service Code"; Code[250])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            ValidateTableRelation = false;
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

        field(50081; "No. of Items"; Integer)
        {
        }


        field(50090; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50093; "FullFillment Status"; Option)
        {
            OptionMembers = "Not Acknowledged",Acknowledged,Fullfilled,Cancelled,Confirmed;
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
        field(50044; "Trolley No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50045; "Bay No."; Code[20])
        {

        }
        field(50047; "Old MultiLine Order No."; Code[250])
        {

        }
        field(50108; "MultiLine Order No."; Code[250])
        {
            //Use this ID to move data in handled via transfer fields
        }
        field(90021; "Shelf No."; Code[20])
        {
            Editable = false;
            // FieldClass = FlowField;     // Irshad
            // CalcFormula = lookup("Interim Sales Line"."Shelf No." where("Document Type" = field("Document Type"), "Document No" = field("No.")));    // Irshad
        }

        field(90022; "Order Discount Amount"; Decimal)
        {

        }
        //US-13166++
        field(90028; "Shipping Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(90029; "Net Order Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        //US-13166--
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

        field(90044; order_id; Text[250])
        {
            DataClassification = ToBeClassified;
        }

        field(90046; "Reason Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90045; "Reason Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(90047; "Ready to process"; Boolean)
        {

        }
        field(90048; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(90049; "ET Access Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90050; "Sales Order Created"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Web Buffer" where("Web Document No." = field("No.")));
        }
        field(90056; "Weekend Ship Agent Serv Code"; Code[250])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
            Caption = 'Weekend Shipping Agent Service Code';
            ValidateTableRelation = false;
        }
        field(90057; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(90058; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
            Caption = 'SalesPerson/Purchaser Code';
        }

    }


    keys
    {
        key(PK; "Document Type", "No.")
        {
            Clustered = true;
        }
    }
    procedure UpdateSalesLinesByFieldNo(ChangedFieldNo: Integer; AskQuestion: Boolean)
    var
        IntrimSalesLine: Record "Interim Sales Line";
        Field: Record Field;
        JobTransferLine: Codeunit "Job Transfer Line";
        PermissionManager: Codeunit "Permission Manager";
        Question: Text[250];
        NotRunningOnSaaS: Boolean;
        IsHandled: Boolean;
    begin

        // IF NOT SalesLinesExist THEN
        //     EXIT;

        // IF NOT Field.GET(DATABASE::"Interim Sales Header", ChangedFieldNo) THEN
        //     Field.GET(DATABASE::"Interim Sales Line", ChangedFieldNo);

        // NotRunningOnSaaS := TRUE;
        // CASE ChangedFieldNo OF
        //     FIELDNO("Shipping Agent Code"),
        //   FIELDNO("Shipping Agent Service Code"):
        //         NotRunningOnSaaS := NOT PermissionManager.SoftwareAsAService;
        // END;
        /* blocked by alok need to review again
        IF AskQuestion THEN BEGIN
            Question := STRSUBSTNO(Text031, Field."Field Caption");
            IF GUIALLOWED THEN
                IF NotRunningOnSaaS THEN
                    IF DIALOG.CONFIRM(Question, TRUE) THEN
                        CASE ChangedFieldNo OF
                            FIELDNO("Shipment Date"),
                          FIELDNO("Shipping Agent Code"),
                          FIELDNO("Shipping Agent Service Code"),
                          FIELDNO("Shipping Time"),
                          FIELDNO("Requested Delivery Date"),
                          FIELDNO("Promised Delivery Date"),
//                                ConfirmResvDateConflict;
                        END;
                    ELSE
                        EXIT
                ELSE
                    ConfirmResvDateConflict;
        END;}

        IntrimSalesLine.LOCKTABLE;
        MODIFY;

        IntrimSalesLine.RESET;
        IntrimSalesLine.SETRANGE("Document Type", "Document Type");
        IntrimSalesLine.SETRANGE("Document No", "No.");
        IF IntrimSalesLine.FINDSET THEN
            REPEAT
                OnBeforeSalesLineByChangedFieldNo(InterimSalesHeader, IntrimSalesLine, ChangedFieldNo, IsHandled);
                IF NOT IsHandled THEN
                    CASE ChangedFieldNo OF
                        FIELDNO("Shipment Date"):
                            IF IntrimSalesLine."No." <> '' THEN
                                IntrimSalesLine.VALIDATE("Shipment Date", "Shipment Date");
                        FIELDNO("Currency Factor"):
                            IF IntrimSalesLine.Type <> IntrimSalesLine.Type::" " THEN BEGIN
                                IntrimSalesLine.VALIDATE("Unit Price");
                                IntrimSalesLine.VALIDATE("Unit Cost (LCY)");
                                //IF IntrimSalesLine."Job No." <> '' THEN
                                // JobTransferLine.FromSalesHeaderToPlanningLine(IntrimSalesLine, "Currency Factor");}
                            END;

                        FIELDNO("Shipping Agent Code"):
                            IntrimSalesLine.VALIDATE("Shipping Agent Code", "Shipping Agent Code");
                        FIELDNO("Shipping Agent Service Code"):
                            IF IntrimSalesLine."No." <> '' THEN
                                IntrimSalesLine.VALIDATE("Shipping Agent Service Code", "Shipping Agent Service Code");
                        FIELDNO("Shipping Time"):
                            IF IntrimSalesLine."No." <> '' THEN
                                IntrimSalesLine.VALIDATE("Shipping Time", "Shipping Time");
                        FIELDNO("Requested Delivery Date"):
                            IF IntrimSalesLine."No." <> '' THEN
                                IntrimSalesLine.VALIDATE("Requested Delivery Date", "Requested Delivery Date");
                        FIELDNO("Promised Delivery Date"):
                            IF IntrimSalesLine."No." <> '' THEN
                                IntrimSalesLine.VALIDATE("Promised Delivery Date", "Promised Delivery Date");
                    

                        ELSE
                            OnUpdateSalesLineByChangedFieldName(Rec, IntrimSalesLine, Field."Field Caption");
                    END;
                //SalesLineReserve.AssignForPlanning(IntrimSalesLine);
                IntrimSalesLine.MODIFY(TRUE);
            UNTIL IntrimSalesLine.NEXT = 0;
    end;
    
    */
    end;

    procedure UpdateSalesLines(ChangedFieldName: Text[100]; AskQuestion: Boolean)
    var
        IntrimSalesLine: Record "Interim Sales Line";
        Field: Record Field;
    begin

        field.SETRANGE(TableNo, DATABASE::"Interim Sales Header");
        Field.SETRANGE("Field Caption", ChangedFieldName);
        Field.FIND('-');
        IF Field.NEXT <> 0 THEN
            UpdateSalesLinesByFieldNo(Field."No.", AskQuestion);
    end;

    procedure SalesLinesExist(): Boolean
    begin
        IntrimSalesLine.RESET;
        IntrimSalesLine.SETRANGE("Document Type", "Document Type");
        IntrimSalesLine.SETRANGE("Document No", "No.");
        EXIT(IntrimSalesLine.FINDFIRST);
    end;

    local procedure ConfirmResvDateConflict()
    Begin

    End;

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
        InterimSalesHeader: Record "Interim Sales Header";
        ChannelMedia: Record "Channel Media";
        ErrorLog: Record "Incoming/Outgoing Error Log";
        Text031: Label 'You have modified %1.\\Do you want to update the lines?';

    //US-13166++
    trigger OnInsert()
    var
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GeneralSetup.Get();
        GeneralSetup.TestField("Web Order Nos");
        if "No." = '' then
            "No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
    end;
    //US-13166--

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        ShipmentTracking: Record "Shipment Tracking";
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin

        //code to delete web order line

        IntrimSalesLine.RESET;
        IntrimSalesLine.SetRange("Document Type", Rec."Document Type");
        IntrimSalesLine.SETRANGE("Document No", Rec."No.");
        IntrimSalesLine.DELETEALL(TRUE);

        ShipmentTracking.Reset();
        ShipmentTracking.SetRange("Agent Shipment No.", "Channel Order ID");
        ShipmentTracking.DeleteAll(true);

        HandledInterimSalesHeader.Reset();
        HandledInterimSalesHeader.SetRange("Channel Order ID", Rec."Channel Order ID");
        if not HandledInterimSalesHeader.FindFirst() then begin
            ChannelMedia.Reset();
            ChannelMedia.SetRange("Web Order No.", Rec."No.");
            ChannelMedia.SetRange("Channel Order ID", "Channel Order ID");//khan++
            if ChannelMedia.FindSet() then
                ChannelMedia.DeleteAll(true);
        end;

        //code to delete error log
        ErrorLog.RESET;
        ErrorLog.SETRANGE("Document No.", "No.");
        ErrorLog.DELETEALL;

    end;

    trigger OnRename()
    begin

    end;


}