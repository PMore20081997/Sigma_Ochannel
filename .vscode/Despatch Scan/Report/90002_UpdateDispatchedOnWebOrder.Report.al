report 90002 "Update Dispatched On Web Order"
{
    Permissions = TableData 5772 = rm,
                  tabledata 5773 = rm,
                  TableData 6550 = rmd;
    ProcessingOnly = true;
    UseRequestPage = false;

    procedure CancelSelectedLines(var P_ISL: Record "Interim Sales Line")
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Cancelling Lines.... @1@@@@@@@@@@');
        NoOfRecs := P_ISL.COUNT;
        P_ISL.CALCFIELDS(Status);
        P_ISL.SETRANGE(Type, P_ISL.Type::Item);
        P_ISL.SETFILTER(Status, '%1', P_ISL.Status::"SO Created");
        P_ISL.SETRANGE("Dispatch Scan", FALSE);
        IF P_ISL.FINDSET THEN
            REPEAT
                P_ISL."Line Status" := P_ISL."Line Status"::Cancelled;
                CLEAR(P_ISL."Trolley No.");
                P_ISL.MODIFY;
                AddOrderNotoTemp(P_ISL."Document No");
                CurrRec += 1;
                IF GUIALLOWED THEN BEGIN
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL P_ISL.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;

        IF TempOrderNo.FINDSET THEN
            REPEAT
                L_InterimSalesHeader.RESET;
                L_InterimSalesHeader.SETRANGE("No.", TempOrderNo."No.");
                IF L_InterimSalesHeader.FINDFIRST THEN
                    UpdatedDispatchedonHeader(5, L_InterimSalesHeader);
            UNTIL TempOrderNo.NEXT = 0;
    end;

    local procedure AddOrderNotoTemp(OrderNo: Code[20])
    begin
        IF NOT TempOrderNo.GET(OrderNo) THEN BEGIN
            TempOrderNo.INIT;
            TempOrderNo."No." := OrderNo;
            TempOrderNo.INSERT;
        END;
    end;

    local procedure UpdatedDispatchedonHeader(P_Status: Integer; var P_ISH: Record "Interim Sales Header")
    var
        RecScannedISL: Record "Interim Sales Line";
        RecNotScannedISL: Record "Interim Sales Line";
        L_TradePartner: Record "Trade Partner";
    begin
        CLEAR(NoOfRecs);
        CLEAR(CurrRec);
        IF GUIALLOWED THEN
            Window.OPEN('Updating Header.... @1@@@@@@@@@@');
        NoOfRecs := TempOrderNo.COUNT;
        IF TempOrderNo.FINDSET THEN
            REPEAT
                ISH.RESET;
                ISH.SETRANGE("Document Type", ISH."Document Type"::Order);
                ISH.SETFILTER("No.", '%1', TempOrderNo."No.");
                IF ISH.FINDFIRST THEN BEGIN
                    RecScannedISL.RESET;
                    RecScannedISL.SETRANGE("Document No", ISH."No.");
                    RecScannedISL.SETRANGE(Type, RecScannedISL.Type::Item);
                    RecScannedISL.SETFILTER("Item Type", '<>%1', RecScannedISL."Item Type"::Assembly);
                    RecScannedISL.SETRANGE("Dispatch Scan", TRUE);
                    RecScannedISL.SETFILTER("Scanned Date", '<>%1', 0DT);
                    IF RecScannedISL.FINDSET THEN;

                    RecNotScannedISL.RESET;
                    RecNotScannedISL.SETRANGE("Document No", ISH."No.");
                    RecNotScannedISL.SETRANGE(Type, RecNotScannedISL.Type::Item);
                    RecNotScannedISL.SETFILTER("Item Type", '<>%1', RecNotScannedISL."Item Type"::Assembly);
                    RecNotScannedISL.SetFilter("Line Status", '<>%1', RecNotScannedISL."Line Status"::Cancelled);
                    IF RecNotScannedISL.FINDSET THEN;

                    IF RecScannedISL.COUNT = RecNotScannedISL.COUNT THEN BEGIN
                        IF L_TradePartner.GET(ISH."Trade Partner Code") THEN;

                        // if P_Status = 5 then
                        //     ISH.Status := ISH.Status::Dispatched
                        // else
                        //     if P_Status = 8 then
                        //         ISH.Status := ISH.Status::Cancelled;

                        ISH.MODIFY;
                        IF P_ISH.GET(ISH."Document Type", ISH."No.") THEN
                            P_ISH.MARK(TRUE);
                        //code to move order to handeled
                        CLEAR(R80020);
                        R80020.SETTABLEVIEW(ISH);
                        R80020.USEREQUESTPAGE(FALSE);
                        R80020.SetChannelpartner(ISH."Trade Partner Code");
                        R80020.RUNMODAL();
                    END;
                    // ELSE
                    //     IF (RecScannedISL.COUNT <> RecNotScannedISL.COUNT) AND (RecScannedISL.COUNT > 0) THEN BEGIN
                    //         ISH.Status := ISH.Status::"Partially Scanned";
                    //         ISH.MODIFY;
                    //     END;
                END;
                CurrRec += 1;
                IF GUIALLOWED THEN BEGIN
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL TempOrderNo.NEXT = 0;

        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    procedure SetCalledFromDispatch(P_bool: Boolean)
    begin
        CalledFromDispatch := P_bool;
    end;

    procedure RemoveSelectedLinesFromTrolleyNew(var P_ISL: Record "Interim Sales Line"; UpdateOutOfStock: Boolean)
    var
        L_WhseActivityLine: Record "Warehouse Activity Line";
        L_RegPick: Record "Registered Whse. Activity Hdr.";
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Updating Lines.... @1@@@@@@@@@@');
        NoOfRecs := P_ISL.COUNT;
        P_ISL.SETRANGE(Type, P_ISL.Type::Item);
        P_ISL.SetFilter(P_ISL."Order Status", '%1', P_ISL."Order Status"::"SO Created");
        P_ISL.SETRANGE("Dispatch Scan", FALSE);
        IF P_ISL.FINDSET THEN
            REPEAT
                IF (P_ISL."Trolley No." = '') AND (NOT UpdateOutOfStock) THEN BEGIN
                    Window.CLOSE;
                    P_ISL.TESTFIELD("Trolley No.");
                END;
                IF NOT CheckifInDispatchTable(P_ISL."Trolley No.", P_ISL."Document No", P_ISL."No.") THEN BEGIN
                    L_WhseActivityLine.RESET;
                    L_WhseActivityLine.SETRANGE("Activity Type", L_WhseActivityLine."Activity Type"::Pick);
                    L_WhseActivityLine.SETRANGE("Source No.", P_ISL."Destination Doc No.");
                    L_WhseActivityLine.SETRANGE("Trolley No.", P_ISL."Trolley No.");
                    L_WhseActivityLine.SETRANGE("Item No.", P_ISL."No.");
                    L_WhseActivityLine.SetRange("Variant Code", P_ISL."NAV Variant code");
                    IF NOT L_WhseActivityLine.ISEMPTY THEN BEGIN
                        Window.CLOSE;
                        ERROR('You can not remove trolley if trolley is in picking!');
                    END;
                    IF NOT CalledFromDispatch THEN BEGIN
                        IF P_ISL."Trolley No." <> '' THEN BEGIN
                            L_RegPick.RESET;
                            L_RegPick.SETRANGE(Type, L_RegPick.Type::Pick);
                            L_RegPick.SETRANGE("Trolley No.", P_ISL."Trolley No.");
                            L_RegPick.SETRANGE("Trolley Closed", FALSE);
                            IF L_RegPick.FINDFIRST THEN BEGIN
                                Window.CLOSE;
                                IF NOT UpdateOutOfStock THEN
                                    ERROR('You can not remove trolley from order until trolley closed!')
                                ELSE
                                    ERROR('You can not mark order as a no stock until trolley closed!');
                            END;
                        END;
                    END;

                    IF UpdateOutOfStock THEN BEGIN
                        P_ISL."Line Status" := P_ISL."Line Status"::"No Stock";
                        AddOrderNotoTemp(P_ISL."Document No");
                    END;

                    CurrRec += 1;
                    IF GUIALLOWED THEN BEGIN
                        IF NoOfRecs <= 100 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                        ELSE
                            IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                                Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                    END;
                END;
            UNTIL P_ISL.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    local procedure CheckifInDispatchTable(P_Trolley: Code[10]; P_WebOrderNo: Code[20]; P_ItemNo: Code[20]): Boolean
    var
        L_Despatch: Record "Despatch Scan Header";
    begin
        IF NOT CalledFromDispatch THEN BEGIN
            L_Despatch.RESET;
            L_Despatch.SETRANGE(L_Despatch."Trolley No", P_Trolley);
            IF L_Despatch.FINDFIRST THEN
                EXIT(TRUE)
            ELSE
                EXIT(FALSE);
        END ELSE
            EXIT(FALSE);
    end;

    var
        CurrRec: Integer;
        NoOfRecs: Integer;
        Window: Dialog;
        ISH: Record "Interim Sales Header";
        TempOrderNo: Record item temporary;
        CalledFromDispatch: Boolean;
        R80020: Report "Move Scanned Order to Handled";
}