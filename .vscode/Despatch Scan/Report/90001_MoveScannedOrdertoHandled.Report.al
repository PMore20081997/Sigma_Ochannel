report 90001 "Move Scanned Order to Handled"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Interim Sales Header"; "Interim Sales Header")
        {
            DataItemTableView = SORTING("Document Type", "No.")
                                ORDER(Ascending)
                                WHERE("Moved In Handled" = CONST(false));
            RequestFilterFields = "Document Date", "No.", "Trade Partner Code", "Scanned Date";

            trigger OnAfterGetRecord()
            begin
                ProcessData("Interim Sales Header");
                // If "Interim Sales Header".Get("Interim Sales Header".RecordId) then
                //   "Interim Sales Header".MARK(TRUE);
            end;

            trigger OnPostDataItem()
            var
                tempcount: Integer;
                L_ISH: Record "Interim Sales Header";
            begin
                // "Interim Sales Header".MARKEDONLY(TRUE);
                L_ISH.Reset();
                //  L_ISH.CopyFilters("Interim Sales Header");
                L_ISH.SetRange("Moved In Handled", true);
                If L_ISH.FindSet() then
                    L_ISH.DeleteAll(true);
                /* If "Interim Sales Header".FindSet() then
                     tempcount := "Interim Sales Header".Count;
                 "Interim Sales Header".DELETEALL;*/
            end;

            trigger OnPreDataItem()
            var
                tradepartner: Record "Trade Partner";
            begin
                Window.OPEN('Processing data... @1@@@@@@@@@@');
                NoOfRecs := "Interim Sales Header".COUNT;
                GenSetupChannels.Get();
                //if not skipfilter then begin
                tradepartner.Get(G_channelcode);
                if tradepartner."Process Order Type" <> tradepartner."Process Order Type"::"Internal Pick" then
                    //if GenSetupChannels."Despatch Scan Enabled" = false then begin
                    "Interim Sales Header".SetRange(status, "Interim Sales Header".status::Processing)
                else
                    // "Interim Sales Header".SetFilter(status, '%1|%2', status::"Ready To Dispatch", status::Dispatched); 
                    "Interim Sales Header".SetFilter(status, '%1|%2|%3', status::"Ready To Dispatch", status::Dispatched, status::Cancelled); 
                //end;
                //end  
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

    trigger OnPostReport()
    begin
        Window.CLOSE;
    end;

    var
        NoOfRecs: Integer;
        CurrRec: Integer;
        Window: Dialog;
        GenSetupChannels: Record "General Setup - Channels";
        skipfilter: Boolean;

    local procedure MovingData(ISH: Record "Interim Sales Header")
    var
        ISL: Record "Interim Sales Line";
        HISH: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
        L_Customer: Record Customer;
    begin
        HISH.INIT;
        ISH.CALCFIELDS("No of Error", "Error Text", ISH."Error Text2", ISH."Amount Including VAT", ISH."Tracking No.");
        HISH.TransferFields(ISH);
        HISH.Insert(true);

    end;


    procedure ProcessData(var ISH: Record "Interim Sales Header")
    var
        ISL: Record "Interim Sales Line";
        HISH: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
        HandledIncomingMessage: Record "Handled Interim Sales Header";
        EntryNo: Integer;
        L_ISH: Record "Interim Sales Header";
    begin
        HandledIncomingMessage.RESET;
        HandledIncomingMessage.SETRANGE("Document Type", HandledIncomingMessage."Document Type"::Order);
        HandledIncomingMessage.SETRANGE(HandledIncomingMessage."No.", ISH."No.");
        //HandledIncomingMessage.SETRANGE("Transaction No.",ISH."Transaction No.");
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
            //ISL.SETRANGE("Transaction No.", ISH."Transaction No.");//NG_no_need
            IF ISL.FINDSET THEN BEGIN
                REPEAT
                    HISL.TRANSFERFIELDS(ISL);
                    ISL.CALCFIELDS("Document Date", "Location Code", "Tracking No.");
                    HISL."Tracking No." := ISL."Tracking No.";
                    //HISL."Line Action" := ISL."Line Action";//NG_no_need
                    HISL."Document Date" := ISL."Document Date";
                    HISL."Scanned Date" := ISL."Scanned Date";
                    HISL."Location Code" := ISL."Location Code";
                    HISL.Insert(true);
                /*IF L_ISH.GET(ISL."Document Type", ISL."Document No") THEN
                    HISL."ASN Date" := DT2DATE(L_ISH."Scanned Date");*///NG_no_need
                UNTIL ISL.NEXT = 0;
            END;

            //Move Shipment Details
            /*ShipmentTracking.RESET;
            ShipmentTracking.SETRANGE("Interim Document No",ISH."No.");
            IF ShipmentTracking.FINDFIRST THEN
            REPEAT
              HandledShipmentTracking.INIT;
              HandledShipmentTracking.TRANSFERFIELDS(ShipmentTracking);
              CLEAR(HandledShipmentTracking.Label);
              IF HandledShipmentTracking2.FINDLAST THEN
              BEGIN
                   EntryNo:=HandledShipmentTracking2."Entry No." + 1;
                   HandledShipmentTracking.VALIDATE("Entry No.",EntryNo);
              END;
              HandledShipmentTracking.INSERT(TRUE);
            UNTIL ShipmentTracking.NEXT=0;*/

            //ISH.MARK(TRUE);
            //ISH.MARK(TRUE);
            //**************Update Header****************
            ISH."Moved In Handled" := TRUE;
            ISH.MODIFY;
            UpdateMovedFlag(ISH);
            //**************Update Header****************
        END;
        CurrRec += 1;
        IF GUIALLOWED THEN BEGIN
            IF NoOfRecs <= 100 THEN
                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
        END;

    end;

    local procedure UpdateMovedFlag(var RecInterimSalesHeader: Record "Interim Sales Header")
    var
        RecInterimSalesLine: Record "Interim Sales Line";
    begin
        RecInterimSalesLine.RESET;
        RecInterimSalesLine.SETRANGE("Document Type", RecInterimSalesHeader."Document Type");
        RecInterimSalesLine.SETRANGE("Document No", RecInterimSalesHeader."No.");
        //RecInterimSalesLine.SETRANGE("Transaction No.", RecInterimSalesHeader."Transaction No.");//NG_no_need
        IF RecInterimSalesLine.FINDSET THEN
            RecInterimSalesLine.MODIFYALL("Moved In Handled", TRUE);
    end;

    procedure MovedDispatchedWebOrder()
    var
        L_ISH: Record "Interim Sales Header";
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Processing data... @1@@@@@@@@@@');
        L_ISH.RESET;
        L_ISH.SETRANGE(Status, L_ISH.Status::Dispatched);
        L_ISH.SETRANGE("Moved In Handled", FALSE);
        NoOfRecs := L_ISH.COUNT;
        IF L_ISH.FINDSET THEN
            REPEAT
                ProcessData(L_ISH);
            UNTIL L_ISH.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    procedure GetHandledStatus(ISHStatus: Option Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Cancelled): Integer
    begin
        CASE ISHStatus OF
            0:
                EXIT(4);
            1:
                EXIT(5);
            2:
                EXIT(6);
            3:
                EXIT(7);
            4:
                EXIT(8);
            5:
                EXIT(9);
            6:
                EXIT(10);
            7:
                EXIT(11);
            8:
                EXIT(3);
            9:
                EXIT(12)
        END;
    end;

    procedure Setskipfilter(P_skipfilter: Boolean)
    begin
        skipfilter := P_skipfilter;
    end;

    procedure SetWebOrder(var P_ISH: Record "Interim Sales Header"; P_channelcode: Code[20])
    var
    begin
        "Interim Sales Header".CopyFilters(P_ISH);
        If "Interim Sales Header".FindSet() then;
        NoOfRecs := "Interim Sales Header".Count;
        G_channelcode := P_channelcode;
    end;

    procedure SetChannelpartner(P_channelcode: Code[20])
    begin
        G_channelcode := P_channelcode;
    end;

    var
        G_channelcode: Code[20];

}

