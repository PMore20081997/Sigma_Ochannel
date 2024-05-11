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
            end;

            trigger OnPostDataItem()
            var
                L_ISH: Record "Interim Sales Header";
            begin
                L_ISH.Reset();
                L_ISH.SetRange("Moved In Handled", true);
                If L_ISH.FindSet() then
                    L_ISH.DeleteAll(true);
            end;

            trigger OnPreDataItem()
            var
                tradepartner: Record "Trade Partner";
            begin
                Window.OPEN('Processing data... @1@@@@@@@@@@');
                NoOfRecs := "Interim Sales Header".COUNT;
                GenSetupChannels.Get();
                tradepartner.Get(G_channelcode);
                if tradepartner."Process Order Type" <> tradepartner."Process Order Type"::"Internal Pick" then
                    if GenSetupChannels."Despatch Scan Enabled" = false then
                        "Interim Sales Header".SetRange(status, "Interim Sales Header".status::"SO Created")
                // else
                //     "Interim Sales Header".SetFilter(status, '%1', status::Dispatched);
                //else
                //"Interim Sales Header".SetFilter(status, '%1|%2', status::Dispatched, status::Cancelled);
            end;
        }
    }

    trigger OnPostReport()
    begin
        Window.CLOSE;
    end;

    local procedure MovingData(ISH: Record "Interim Sales Header")
    var
        HISH: Record "Handled Interim Sales Header";
    begin
        HISH.INIT;
        ISH.CALCFIELDS("No of Error", "Error Text", ISH."Error Text2", ISH."Amount Including VAT", ISH."Tracking No.");
        HISH.TransferFields(ISH);
        HISH.Insert(true);
    end;

    procedure ProcessData(var ISH: Record "Interim Sales Header")
    var
        ISL: Record "Interim Sales Line";
        HISL: Record "Handled Interim Sales Line";
        HandledIncomingMessage: Record "Handled Interim Sales Header";
    begin
        HandledIncomingMessage.RESET;
        HandledIncomingMessage.SETRANGE("Document Type", HandledIncomingMessage."Document Type"::Order);
        HandledIncomingMessage.SETRANGE(HandledIncomingMessage."No.", ISH."No.");
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
                    HISL."Document Date" := ISL."Document Date";
                    HISL."Scanned Date" := ISL."Scanned Date";
                    HISL."Location Code" := ISL."Location Code";
                    HISL.Insert(true);
                UNTIL ISL.NEXT = 0;
            END;

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
        IF RecInterimSalesLine.FINDSET THEN
            RecInterimSalesLine.MODIFYALL("Moved In Handled", TRUE);
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

    procedure SetWindowDialogueAndNoofRec(var P_ISH: Record "Interim Sales Header")
    var
    begin
        Window.OPEN('Processing data... @1@@@@@@@@@@');
        NoOfRecs := P_ISH.Count;
    end;

    var
        G_channelcode: Code[20];
        NoOfRecs: Integer;
        CurrRec: Integer;
        Window: Dialog;
        GenSetupChannels: Record "General Setup - Channels";
}