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
            RequestFilterFields = "Document Date", "No.", "Trade Partner Code";

            trigger OnAfterGetRecord()
            begin
                "Interim Sales Header".CalcFields("Sales Order Created");
                if ("Interim Sales Header".status = "Interim Sales Header".status::Rejected) or ("Interim Sales Header"."Sales Order Created" = true) then
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
            begin
                Window.OPEN('Processing data... @1@@@@@@@@@@');
                NoOfRecs := "Interim Sales Header".Count;
            end;
        }
    }

    trigger OnPostReport()
    begin
        Window.Close();
    end;

    procedure ProcessData(var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        ISL: Record "Interim Sales Line";
        HISL: Record "Handled Interim Sales Line";
        L_HandledInterimHeader: Record "Handled Interim Sales Header";
    begin
        L_HandledInterimHeader.Reset();
        L_HandledInterimHeader.SetRange("Document Type", L_HandledInterimHeader."Document Type"::Order);
        L_HandledInterimHeader.SetRange(L_HandledInterimHeader."No.", P_InterimSalesHeader."No.");
        IF not L_HandledInterimHeader.FindFirst() THEN BEGIN
            //Move Header
            MovingHeaderData(P_InterimSalesHeader);

            //Move Lines
            HISL.Reset();
            HISL.Init();
            ISL.Reset();
            ISL.SetRange("Document Type", P_InterimSalesHeader."Document Type");
            ISL.SetRange("Document No", P_InterimSalesHeader."No.");
            if ISL.FindSet() then begin
                repeat
                    HISL.TransferFields(ISL);
                    ISL.CalcFields("Document Date", "Location Code", "Tracking No.");
                    HISL."Tracking No." := ISL."Tracking No.";
                    HISL."Document Date" := ISL."Document Date";
                    HISL."Scanned Date" := ISL."Scanned Date";
                    HISL."Location Code" := ISL."Location Code";
                    HISL.Insert(true);
                until ISL.Next() = 0;
            end;

            //**************Update Header****************
            P_InterimSalesHeader."Moved In Handled" := TRUE;
            P_InterimSalesHeader.Modify();
            //UpdateMovedFlag(P_InterimSalesHeader);
            //**************Update Header****************
        END;
        CurrRec += 1;
        IF GuiAllowed THEN BEGIN
            IF NoOfRecs <= 100 THEN
                Window.Update(1, (CurrRec / NoOfRecs * 10000) DIV 1)
            ELSE
                IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                    Window.Update(1, (CurrRec / NoOfRecs * 10000) DIV 1);
        END;
    end;

    local procedure MovingHeaderData(ISH: Record "Interim Sales Header")
    var
        L_HandledInterimHeader: Record "Handled Interim Sales Header";
    begin
        L_HandledInterimHeader.Init();
        ISH.SetAutoCalcFields("No of Error", "Error Text", ISH."Error Text2", ISH."Amount Including VAT", ISH."Tracking No.");
        L_HandledInterimHeader.TransferFields(ISH);
        L_HandledInterimHeader.Insert(true);
    end;

    local procedure UpdateMovedFlag(var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        IF L_InterimSalesLine.FindSet() THEN
            L_InterimSalesLine.ModifyAll("Moved In Handled", TRUE);
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
}