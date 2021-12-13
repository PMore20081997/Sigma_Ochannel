report 90068 "Move Data-Web orders"
{/*
    ProcessingOnly = true;
70194835
    dataset
    {
        dataitem("Interim Sales Header"; "Interim Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                ORDER(Ascending)
                                WHERE(//Status = CONST(),
                                      "Moved In Handled" = CONST(false));
            RequestFilterFields = "Document Date", "No.", "Trade Partner Code", "Scanned Date";

            trigger OnAfterGetRecord();
            var
                ISH: Record "Interim Sales Header";//
                ISL: Record "Interim Sales Line";
                HISH: Record "Handled Interim Sales Header";
                HISL: Record "Handled Interim Sales Line";
            begin
                ProcessData("Interim Sales Header");
            end;

            trigger OnPostDataItem();
            begin
                "Interim Sales Header".MARKEDONLY;
                "Interim Sales Header".DELETEALL(TRUE);
            end;

            trigger OnPreDataItem();
            begin
                Window.OPEN('Processing data... @1@@@@@@@@@@');
                NoOfRecs := "Interim Sales Header".COUNT;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport();
    begin
        Window.CLOSE;
    end;

    var
        NoOfRecs: Integer;
        CurrRec: Integer;
        Window: Dialog;
        

    local procedure MovingData(ISH: Record "Interim Sales Header");
    var
        ISL: Record "Interim Sales Line";
        HISH: Record "Handled Incoming Message";
        HISL: Record "Handled Interim Sales Line";
    begin
        HISH.INIT;
        //    ISH.Validate("Shipping Tracking Line", "Scanned Parcels");
        HISH.VALIDATE("Document Type", ISH."Document Type");
        HISH.VALIDATE("Document No.", ISH."No.");
        HISH.VALIDATE("Sell-to Customer No.", ISH."Sell-to Customer No.");
        HISH.VALIDATE("Web Customer No.", ISH."Web Customer No.");
        HISH.VALIDATE(Address, ISH.Address);
        HISH.VALIDATE("Address 2", ISH."Address 2");
        HISH.VALIDATE(City, ISH.City);
        HISH.VALIDATE("Post Code", ISH."Post Code");
        HISH.VALIDATE("Order Date", ISH."Order Date");
        
        //  HISH.VALIDATE(Status, OrderValidationEvent.GetHandledStatus(ISH.Status));
        HISH.VALIDATE(Remarks, ISH.Remarks);
        HISH.VALIDATE("Bill-to Customer No.", ISH."Bill-to Customer No.");
        HISH.VALIDATE("Ship-to Name", ISH."Ship-to Name");
        HISH.VALIDATE("Ship-to Address", ISH."Ship-to Address");
        HISH.VALIDATE("Ship-to Address 2", ISH."Ship-to Address 2");
        HISH.VALIDATE("Ship-to City", ISH."Ship-to City");
        HISH.VALIDATE("Ship-to Post Code", ISH."Ship-to Post Code");
        HISH.VALIDATE("Ship-to County", ISH."Ship-to County");
        HISH.VALIDATE("Ship-to Country", ISH."Ship-to Country");
        HISH.VALIDATE("Document Date", ISH."Document Date");
        HISH.VALIDATE("External Document No.", ISH."External Document No.");
        HISH.VALIDATE("Buyer Email", ISH."Buyer Email");
        HISH.VALIDATE("Buyer Name", ISH."Buyer Name");
        HISH.VALIDATE("Earliest Delivery date", ISH."Earliest Delivery date");
        HISH.VALIDATE("Earliest Ship Date", ISH."Earliest Ship Date");
        HISH.VALIDATE("Fullfillment Channel", ISH."Fullfillment Channel");
        HISH.VALIDATE("Order Type", ISH."Order Type");
        HISH.VALIDATE("Order Amount", ISH."Order Amount");
        HISH.VALIDATE("Channel Order ID", ISH."Channel Order ID");
        HISH.VALIDATE("Shipment Method Code", ISH."Shipment Method Code");
        HISH.VALIDATE("Currency Code", ISH."Currency Code");
        //HISH.VALIDATE("Ship-tp Phone No.",ISH."Ship-tp Phone No.");
        HISH.VALIDATE("Gift Message", ISH."Gift Message");
        HISH.VALIDATE("Order Placed At", ISH."Order Placed At");
        HISH.VALIDATE("Web Shipment Method", ISH."Web Shipment Method");
        HISH.VALIDATE("Bill- to Name", ISH."Bill- to Name");
        HISH.VALIDATE("Web Shipping Agent", ISH."Web Shipping Agent");
        HISH.VALIDATE("Bill-to CompanyName", ISH."Bill-to CompanyName");
        HISH.VALIDATE("Ship-to CompanyName", ISH."Ship-to CompanyName");
        HISH.VALIDATE("Deal ID", ISH."Deal ID");
        HISH.VALIDATE("Bill-to County", ISH."Bill-to County");
        HISH.VALIDATE("Trade Partner Code", ISH."Trade Partner Code");
        HISH.VALIDATE("Shipping Agent Code", ISH."Shipping Agent Code");
        HISH.VALIDATE("Shipping Agent Service Code", ISH."Shipping Agent Service Code");
        HISH.VALIDATE("Shipment Date", ISH."Shipment Date");
        //  HISH.VALIDATE("Ship-to Country/Region Code", ISH."Ship-to Country/Region Code"); PS
        HISH.VALIDATE("Promised Delivery Date", ISH."Promised Delivery Date");
        HISH.VALIDATE("Shipping Time", ISH."Shipping Time");
        HISH.VALIDATE("Requested Delivery Date", ISH."Requested Delivery Date");
        HISH.VALIDATE("Currency Factor", ISH."Currency Factor");
        HISH.VALIDATE(Comments, ISH.Comments);
        HISH.VALIDATE("Package Tracking No.", ISH."Package Tracking No.");
        //HISH.VALIDATE("Location Code", ISH."Location Code");
        HISH.VALIDATE("Pickup Name", ISH."Pickup Name");
        HISH.VALIDATE("Pickup Address", ISH."Pickup Address");
        HISH.VALIDATE("Pickup Address 2", ISH."Pickup Address 2");
        HISH.VALIDATE("Pickup City", ISH."Pickup City");
        HISH.VALIDATE("Pickup Post Code", ISH."Pickup Post Code");
        HISH.VALIDATE("Pickup County", ISH."Pickup County");
        HISH.VALIDATE("Pickup Country/Region Code", ISH."Pickup Country/Region Code");
        HISH.VALIDATE("Total Weight", ISH."Total Weight");
        HISH.VALIDATE("Pickup Date", ISH."Pickup Date");
        HISH.VALIDATE("Email (Location)", ISH."Email (Location)");
        HISH.VALIDATE("No. Of Parcels", ISH."No. Of Parcels");
        HISH.VALIDATE("Package Tracking No.", ISH."Package Tracking No.");
        HISH.VALIDATE("Job Reference", ISH."Job Reference");
        HISH.VALIDATE("Pickup Time", ISH."Pickup Time");
        HISH.VALIDATE("Cancelled By", ISH."Cancelled By");
        HISH.VALIDATE("Cancelled On", ISH."Cancelled On");
        HISH.VALIDATE("Order Tracking ID", ISH."Order Tracking ID");
        HISH.VALIDATE("Gift Wrap By", ISH."Gift Wrap By");
        HISH.VALIDATE("Gift Wrap date", ISH."Gift Wrap date");
        HISH.VALIDATE("Order Created On", ISH."Order Created On");
        HISH.VALIDATE("Ship-to Phone", ISH."Ship-to Phone");
        HISH.VALIDATE("Ship-to Email", ISH."Ship-to Email");
        HISH.VALIDATE("No. of Items", ISH."No. of Items");
        HISH.VALIDATE("Deal ID", ISH."Deal ID");
        HISH.VALIDATE("Ship-to Country/Region Code", ISH."Ship-to Country/Region Code");
        HISH.INSERT(TRUE);
    end;

    procedure ProcessData(var ISH: Record "Interim Sales Header");
    var
        ISL: Record "Interim Sales Line";
        HISH: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
        ShipmentTracking: Record "Shipment Tracking";
        HandledIncomingMessage: Record "Handled Incoming Message";
        EntryNo: Integer;
    begin
        HandledIncomingMessage.RESET;
        HandledIncomingMessage.SETRANGE("Document Type", HandledIncomingMessage."Document Type"::Order);
        HandledIncomingMessage.SETRANGE("Document No.", ISH."No.");
        //  IF NOT HandledIncomingMessage.GET(ISH."Transaction No.") THEN
        IF NOT HandledIncomingMessage.FINDFIRST THEN BEGIN
            //Move Header
            MovingData(ISH);

            //Move Lines
            HISL.RESET;
            HISL.INIT;
            ISL.RESET;
            ISL.SETRANGE("Document Type", ISH."Document Type");
            ISL.SETRANGE("Document No", ISH."No.");
            IF ISL.FINDSET THEN BEGIN
                REPEAT
                    HISL.TRANSFERFIELDS(ISL);
                    ISL.CALCFIELDS("Document Date", "Location Code", "Tracking No.");
                    HISL."Tracking No." := ISL."Tracking No.";
                    //  HISL."Line Action" := ISL."Line Action";
                    // HISL."Document Date" := ISL."Document Date";
                    // HISL."Scanned Date" := ISL."Scanned Date";
                    // HISL."Location Code" := ISL."Location Code";
                    // HISL."Assembly BOM" := ISL."Assembly BOM";
                    HISL.INSERT(TRUE);
                UNTIL ISL.NEXT = 0;
            END;

            //ISH.MARK(TRUE);
            //ISH.MARK(TRUE);
            //**************Update Header****************
            ISH."Moved In Handled" := TRUE;
            ISH.MODIFY;
            UpdateMovedFlag(ISH);
            //**************Update Header****************
        END;
        CurrRec += 1;
        IF NoOfRecs <= 100 THEN
            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
        ELSE
            IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
    end;

    local procedure UpdateMovedFlag(var RecInterimSalesHeader: Record "Interim Sales Header");
    var
        RecInterimSalesLine: Record "Interim Sales Line";
    begin
        RecInterimSalesLine.RESET;
        RecInterimSalesLine.SETRANGE("Document Type", RecInterimSalesHeader."Document Type");
        RecInterimSalesLine.SETRANGE("Document No", RecInterimSalesHeader."No.");
        IF RecInterimSalesLine.FINDSET THEN
            RecInterimSalesLine.MODIFYALL("Moved In Handled", TRUE);
    end;

    procedure ProcessDataTEMP(var ISH: Record "Interim Sales Header");
    var
        ISL: Record "Interim Sales Line";
        HISH: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
        ShipmentTracking: Record "Shipment Tracking";
        HandledIncomingMessage: Record "Handled Incoming Message";
        EntryNo: Integer;
    begin
        HandledIncomingMessage.RESET;
        HandledIncomingMessage.SETRANGE("Document Type", HandledIncomingMessage."Document Type"::Order);
        HandledIncomingMessage.SETRANGE("Document No.", ISH."No.");       
        //IF NOT HandledIncomingMessage.GET(ISH."Transaction No.") THEN
        IF NOT HandledIncomingMessage.FINDFIRST THEN BEGIN
            //Move Header
            MovingData(ISH);

            //Move Lines
            HISL.RESET;
            HISL.INIT;
            ISL.RESET;
            ISL.SETRANGE("Document Type", ISH."Document Type");
            ISL.SETRANGE("Document No", ISH."No.");
            IF ISL.FINDSET THEN BEGIN
                REPEAT
                    HISL.TRANSFERFIELDS(ISL);
                    ISL.CALCFIELDS("Document Date", "Location Code", "Tracking No.");
                    HISL."Tracking No." := ISL."Tracking No.";
                    //  HISL."Line Action" := ISL."Line Action";
                    //  HISL."Document Date" := ISL."Document Date";
                    //  HISL."Scanned Date" := ISL."Scanned Date";
                    //   HISL."Location Code" := ISL."Location Code";
                    // HISL."Assembly BOM" := ISL."Assembly BOM";
                    // HISL."Item Journal Posted" := TRUE;
                    HISL.INSERT(TRUE);
                UNTIL ISL.NEXT = 0;
            END;
            //ISH.MARK(TRUE);
            //ISH.MARK(TRUE);
            //**************Update Header****************
            ISH."Moved In Handled" := TRUE;
            ISH.MODIFY;
            UpdateMovedFlag(ISH);
            //**************Update Header****************
        END;
        /*CurrRec += 1;
        IF NoOfRecs <= 100 THEN
          Window.UPDATE(1,(CurrRec / NoOfRecs * 10000) DIV 1)
        ELSE IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
          Window.UPDATE(1,(CurrRec / NoOfRecs * 10000) DIV 1);

    end;*/
}

