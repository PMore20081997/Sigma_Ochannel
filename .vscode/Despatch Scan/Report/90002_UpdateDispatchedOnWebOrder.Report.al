report 90002 "Update Dispatched On Web Order"
{
    Permissions = TableData 5772 = rm,
                  tabledata 5773 = rm,
                  TableData 6550 = rmd;
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
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

    trigger OnPreReport()
    begin
        Despatch.RESET;
        //Despatch.SETFILTER("Scanned Date",'>=%1',CREATEDATETIME(TODAY,0T));
        //Despatch.SETFILTER("Scanned Date",'%1',CREATEDATETIME(300619D,0T),CREATEDATETIME(040719D,0T));
        Despatch.SETFILTER("Scan Date Time", '<>%1', 0DT);
        Despatch.SETRANGE("web order updated", FALSE);
        Despatch.SETRANGE(Scanned, TRUE);
        //NoOfRecs:=Despatch.COUNT;
        IF Despatch.FINDSET THEN
            UpdatedDispatchOnWebOrder(Despatch);
        /*REPEAT
        ISL.RESET;
        ISL.SETRANGE("Document No",Despatch."Order No");
        ISL.SETRANGE("No.",Despatch."Item No");
        IF ISL.FINDFIRST THEN
        BEGIN
          ISL."Scanned Date":=Despatch."Scan Date Time";
          ISL."Dispatch Scan":=TRUE;
          ISL.MODIFY;
        
          Despatch."web order updated":=TRUE;
          Despatch.MODIFY;
          AddOrderNotoTemp(ISL."Document No");
        END;
        
        CurrRec += 1;
        IF GUIALLOWED THEN
        BEGIN
         IF NoOfRecs <= 100 THEN
           Window.UPDATE(1,(CurrRec / NoOfRecs * 10000) DIV 1)
         ELSE IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
           Window.UPDATE(1,(CurrRec / NoOfRecs * 10000) DIV 1);
        END;
        UNTIL Despatch.NEXT=0;
        UpdatedDispatchedonHeader;
        IF GUIALLOWED THEN
          Window.CLOSE;*/

    end;

    var
        CurrRec: Integer;
        NoOfRecs: Integer;
        Window: Dialog;
        ISH: Record "Interim Sales Header";
        Despatch: Record "Despatch Scan Line";
        ISL: Record "Interim Sales Line";
        TempOrderNo: Record item temporary;
        G_ArchivedScannedEntries: Record "Archive Scanned Entries";
        CalledFromDispatch: Boolean;
        R80020: Report "Move Scanned Order to Handled";
        G_ISH: Record "Interim Sales Header";

    local procedure UpdatedDispatchedonHeader(P_USERID: Text; var P_ISH: Record "Interim Sales Header")
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
                //ISH.SETFILTER("Sales Order No.",'<>%1','');
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

                        UpdateDispatchOnAssemblyBOM(ISH);//Update Scanned in Assembly BOM products

                        //Chandan++221020
                        UpdateDispatchOnGL(ISH);//Update Scanned on G/L lines if included e.g. (Shipping G/L in EBAY)

                        IF L_TradePartner.GET(ISH."Trade Partner Code") THEN;

                        ISH.Status := ISH.Status::Dispatched; //Prathamesh 25112021//Status to be cancelled.
                        ISH."Scanned Date" := GetLastScannedDate(RecScannedISL);

                        /*IF L_TradePartner."Export ASN" THEN
                            ISH.Status := ISH.Status::"Ready To Dispatch"
                        ELSE BEGIN
                            ISH.Status := ISH.Status::Dispatched;
                            ISH."Scanned Date" := GetLastScannedDate(RecScannedISL);//RecScannedISL."Scanned Date";
                        END;*///NG_no_need
                        //ISH.Dispatched := TRUE;//NG_no_need
                        // ISH."Scanned By":=P_USERID;//Chandan++140820
                        ISH.MODIFY;
                        IF P_ISH.GET(ISH."Document Type", ISH."No.") THEN
                            P_ISH.MARK(TRUE);
                        //code to move order to handeled
                        CLEAR(R80020);
                        R80020.SETTABLEVIEW(ISH);
                        R80020.USEREQUESTPAGE(FALSE);
                        R80020.SetChannelpartner(ISH."Trade Partner Code");
                        R80020.RUNMODAL();
                    END ELSE
                        IF (RecScannedISL.COUNT <> RecNotScannedISL.COUNT) AND (RecScannedISL.COUNT > 0) THEN BEGIN //alok 281220 ++
                            ISH.Status := ISH.Status::"Partially Scanned";
                            ISH.MODIFY;
                        END;
                    //alok 281220 --
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
        //ISH.MARKEDONLY(TRUE);
        //ISH.DELETEALL(TRUE);
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    local procedure AddOrderNotoTemp(OrderNo: Code[20])
    begin
        IF NOT TempOrderNo.GET(OrderNo) THEN BEGIN
            TempOrderNo.INIT;
            TempOrderNo."No." := OrderNo;
            TempOrderNo.INSERT;
        END;
    end;

    procedure UpdatedDispatchOnWebOrder(var RecDispatch: Record "Despatch Scan Line")
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Updating Lines.... @1@@@@@@@@@@');
        NoOfRecs := RecDispatch.COUNT;
        IF RecDispatch.FINDSET THEN
            REPEAT
                ISL.RESET;
                ISL.SETRANGE("Document No", RecDispatch."Order No");
                ISL.SETRANGE("No.", RecDispatch."Item No.");
                IF ISL.FINDFIRST THEN BEGIN
                    IF RecDispatch."Scan Date Time" <> 0DT THEN BEGIN
                        ISL."Scanned Date" := RecDispatch."Scan Date Time";
                        ISL."Dispatch Scan" := TRUE;
                        ISL.MODIFY;

                        IF ISL."Item Type" = ISL."Item Type"::Component THEN;
                    END;

                    RecDispatch."web order updated" := TRUE;
                    RecDispatch.MODIFY;
                    RecDispatch.MARK(TRUE);
                    AddOrderNotoTemp(ISL."Document No");
                END;

                CurrRec += 1;
                IF GUIALLOWED THEN BEGIN
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL RecDispatch.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;

        UpdatedDispatchedonHeader(RecDispatch."User ID", G_ISH);
        RecDispatch.MARKEDONLY(TRUE);
        RecDispatch.DELETEALL;
    end;

    local procedure UpdateDispatchOnAssemblyBOM(var P_ISH: Record "Interim Sales Header")
    var
        L_ISLAssBOM: Record "Interim Sales Line";
        L_ISLComponent: Record "Interim Sales Line";
    begin
        L_ISLAssBOM.RESET;
        L_ISLAssBOM.SETRANGE("Document No", ISH."No.");
        L_ISLAssBOM.SETRANGE(Type, L_ISLAssBOM.Type::Item);
        L_ISLAssBOM.SETFILTER("Item Type", '%1', L_ISLAssBOM."Item Type"::Assembly);
        L_ISLAssBOM.SETRANGE("Dispatch Scan", FALSE);
        IF L_ISLAssBOM.FINDSET THEN
            REPEAT
                L_ISLComponent.RESET;
                L_ISLComponent.SETRANGE("Document No", L_ISLAssBOM."Document No");
                L_ISLComponent.SETRANGE("Bom Item No.", L_ISLAssBOM."No.");
                IF L_ISLComponent.FINDFIRST THEN BEGIN
                    L_ISLAssBOM."Dispatch Scan" := TRUE;
                    L_ISLAssBOM."Scanned Date" := L_ISLComponent."Scanned Date";
                    L_ISLAssBOM.MODIFY;
                END;
            UNTIL L_ISLAssBOM.NEXT = 0;
    end;


    procedure UpdateTrolleyCloseOnPostedPick(P_TrolleyNo: Text; P_BayNo: Text)
    var
        L_RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr.";
        L_RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        L_RegisteredWhseActivityHdr.RESET;
        L_RegisteredWhseActivityHdr.SETRANGE(Type, L_RegisteredWhseActivityHdr.Type::Pick);
        L_RegisteredWhseActivityHdr.SETRANGE("Trolley No.", P_TrolleyNo);
        L_RegisteredWhseActivityHdr.SETRANGE("Trolley Closed", FALSE);//alok 180720
        IF L_RegisteredWhseActivityHdr.FINDSET THEN
            REPEAT
                L_RegisteredWhseActivityLine.Reset();
                L_RegisteredWhseActivityLine.SetRange("No.", L_RegisteredWhseActivityHdr."No.");
                if P_BayNo <> '' then
                    L_RegisteredWhseActivityLine.SetRange("Bay No.", P_BayNo);
                if L_RegisteredWhseActivityLine.FindFirst() then begin
                    repeat
                        if L_RegisteredWhseActivityLine."Bay No." <> '' then begin
                            L_RegisteredWhseActivityLine."Bay Closed" := true;
                            L_RegisteredWhseActivityLine.Modify();
                        end;
                    until L_RegisteredWhseActivityLine.Next() = 0;
                    if (P_BayNo = '') OR AllBayNoclosed(L_RegisteredWhseActivityHdr) then begin
                        L_RegisteredWhseActivityHdr."Trolley Closed" := TRUE;
                        L_RegisteredWhseActivityHdr.MODIFY;
                    end;
                end;
            UNTIL L_RegisteredWhseActivityHdr.NEXT = 0;
    end;

    procedure AllBayNoclosed(P_RegisteredWhseActivityH: record "Registered Whse. Activity Hdr."): Boolean
    var
        L_RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        L_RegisteredWhseActivityLine.Reset();
        L_RegisteredWhseActivityLine.SetRange("No.", P_RegisteredWhseActivityH."No.");
        L_RegisteredWhseActivityLine.SetFilter("Bay No.", '<>%1', '');
        L_RegisteredWhseActivityLine.SetRange("Bay Closed", false);
        if L_RegisteredWhseActivityLine.IsEmpty then
            exit(true)
        else
            exit(false)
    end;

    procedure CheckWebOrderLinesFoUnscannedQty(P_TrolleyNo: Text)
    var
        L_ISL: Record "Interim Sales Line";
        L_Dispatch: Record "Despatch Scan Line";
        OrderFilter: Text;
        ItemFilter: Text;
        WSHList: Page "Warehouse Shipment List";
        L_InterimOrderLinesPage: Page "Web Order Line List";
        L_ISL2: Record "Interim Sales Line";
        IsPendingLines: Boolean;
    begin
        CLEAR(ItemFilter);
        CLEAR(OrderFilter);
        CLEAR(IsPendingLines);
        L_ISL.RESET;
        L_ISL.SETRANGE("Trolley No.", P_TrolleyNo);
        L_ISL.SETRANGE(Type, L_ISL.Type::Item);//CHANDAN++211220**TO MANAGE GL LINES*
        L_ISL.SETRANGE("Dispatch Scan", FALSE);
        L_ISL.SETFILTER("Item Type", '<>%1', L_ISL."Item Type"::Assembly);
        IF L_ISL.FINDSET THEN
            REPEAT
                Despatch.RESET;
                Despatch.SETRANGE("Order No", L_ISL."Document No");
                Despatch.SETRANGE("Trolley No", L_ISL."Trolley No.");
                Despatch.SETRANGE("Item No.", L_ISL."No.");
                Despatch.SetRange("Variant Code", L_ISL."NAV Variant code");
                IF Despatch.FINDFIRST THEN BEGIN
                    IF (Despatch."Scanned Quantity" + L_ISL."Trolley Closed Quantity") < L_ISL.Quantity THEN BEGIN
                        AddToFilterText2(ItemFilter, '|', '', L_ISL."No.");
                        AddToFilterText2(OrderFilter, '|', '', L_ISL."Document No");
                        if L_ISL2.Get(L_ISL."Document Type", L_ISL."Document No", L_ISL."Line No.") then
                            L_ISL2.Mark(true);
                        IsPendingLines := TRUE;
                    END;
                END ELSE BEGIN
                    AddToFilterText2(ItemFilter, '|', '', L_ISL."No.");
                    AddToFilterText2(OrderFilter, '|', '', L_ISL."Document No");
                    if L_ISL2.Get(L_ISL."Document Type", L_ISL."Document No", L_ISL."Line No.") then
                        L_ISL2.Mark(true);
                    IsPendingLines := TRUE;
                END;
            UNTIL L_ISL.NEXT = 0;

        IF IsPendingLines THEN BEGIN
            MESSAGE('There are some unscanned orders in trolley. Please remove them from before closing');
            /*L_ISL2.RESET;
            L_ISL2.SETRANGE("Trolley No.", P_TrolleyNo);
            L_ISL2.SETRANGE(Type, L_ISL2.Type::Item);//CHANDAN++211220**TO MANAGE GL LINES
            L_ISL2.SETRANGE("Document Type", L_ISL2."Document Type"::Order);
            L_ISL2.SETFILTER("Document No", OrderFilter);
            L_ISL2.SETFILTER("No.", ItemFilter);*/
            L_ISL2.MarkedOnly(true);
            IF L_ISL2.FINDSET THEN BEGIN
                //L_InterimOrderLinesPage.LOOKUPMODE(TRUE);
                L_InterimOrderLinesPage.SETTABLEVIEW(L_ISL2);
                L_InterimOrderLinesPage.SetCalledFromDispatch(TRUE);
                L_InterimOrderLinesPage.SetParameter(TRUE);
                L_InterimOrderLinesPage.EDITABLE := FALSE;
                L_InterimOrderLinesPage.RunModal();
                //IF L_InterimOrderLinesPage.RUNMODAL = ACTION::LookupOK THEN;

                ERROR('');
            END;
        END;
    end;

    procedure RemoveSelectedLinesFromTrolley(var P_ISL: Record "Interim Sales Line"; UpdateOutOfStock: Boolean)
    var
        L_WhseActivityLine: Record "Warehouse Activity Line";
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Updating Lines.... @1@@@@@@@@@@');
        NoOfRecs := P_ISL.COUNT;
        P_ISL.CALCFIELDS(P_ISL."Order Status");
        P_ISL.SETRANGE("Order Status", P_ISL."Order Status"::Processing);
        P_ISL.SETRANGE("Dispatch Scan", FALSE);//ak 211120
        IF P_ISL.FINDSET THEN
            REPEAT
                L_WhseActivityLine.RESET;
                L_WhseActivityLine.SETRANGE("Activity Type", L_WhseActivityLine."Activity Type"::Pick);
                L_WhseActivityLine.SETRANGE("Source No.", P_ISL."Destination Doc No.");
                L_WhseActivityLine.SETRANGE("Trolley No.", P_ISL."Trolley No.");
                L_WhseActivityLine.SETRANGE("Item No.", P_ISL."No.");
                IF NOT L_WhseActivityLine.ISEMPTY THEN BEGIN
                    Window.CLOSE;
                    ERROR('You can not remove trolley if trolley is in picking!');
                END;
                IF UpdateOutOfStock THEN BEGIN
                    //P_ISL."Out Of Stock" := TRUE;//NG_no_need
                    AddOrderNotoTemp(P_ISL."Document No");
                END;
                IF NOT CheckifScanned(P_ISL."Trolley No.", P_ISL."Document No", P_ISL."No.", P_ISL."NAV Variant code") THEN BEGIN//ak 211120 check if line is already scanned
                    CLEAR(P_ISL."Trolley No.");
                    P_ISL.MODIFY;
                END;
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

        IF UpdateOutOfStock THEN
            UpdateRemovedOnHeader;
    end;

    local procedure UpdateRemovedOnHeader()
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
                //ISH.SETFILTER("Sales Order No.",'<>%1','');
                IF ISH.FINDFIRST THEN BEGIN
                    IF CheckIFAllOrderLineMarkedNoStock(ISH) THEN BEGIN
                        ISH.Status := ISH.Status::"No Stock";
                        /*CLEAR(ISH."Destination Doc No.");
                        CLEAR(ISH."Destination Doc Type");*/
                        ISH.MODIFY;
                    END;
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

    procedure ReProcessOrder(var P_ISH: Record "Interim Sales Header")
    begin
        IF P_ISH.FINDSET THEN
            REPEAT
                IF (P_ISH.Status = P_ISH.Status::"No Stock") OR (P_ISH.Status = P_ISH.Status::"Partially Scanned") THEN BEGIN
                    IF (P_ISH."Destination Doc No." <> '') THEN
                        P_ISH.Status := P_ISH.Status::Processing
                    ELSE
                        IF (P_ISH."Destination Doc No." = '') THEN
                            P_ISH.Status := P_ISH.Status::"In Progress";
                    P_ISH.MODIFY;

                    UpdateInStockOnLines(P_ISH);

                END;
            UNTIL P_ISH.NEXT = 0;
    end;

    local procedure UpdateInStockOnLines(var P_ISH: Record "Interim Sales Header")
    var
        L_ISL: Record "Interim Sales Line";
    begin
        L_ISL.RESET;
        L_ISL.SETRANGE("Document Type", P_ISH."Document Type");
        L_ISL.SETRANGE("Document No", P_ISH."No.");
        //L_ISL.SETRANGE("Out Of Stock", TRUE);//NG_No_need
        IF L_ISL.FINDSET THEN
            REPEAT
                //L_ISL."Out Of Stock" := FALSE;//NG_No_need
                L_ISL."Line Status" := L_ISL."Line Status"::" ";//ak 291220
                L_ISL.MODIFY;
            UNTIL L_ISL.NEXT = 0;
    end;

    procedure DeleteWhseTrackingLine(var P_SourceNo: Code[20])
    var
        L_WhseItemTrackingLine: Record "Whse. Item Tracking Line";
        L_WhseInternalPickLine: Record "Whse. Internal Pick Line";
    begin
        L_WhseItemTrackingLine.RESET;
        L_WhseItemTrackingLine.SETRANGE("Source ID", P_SourceNo);
        L_WhseItemTrackingLine.SETRANGE("Source Type", 7334);
        L_WhseItemTrackingLine.SETRANGE("Quantity Handled (Base)", 0);
        IF L_WhseItemTrackingLine.FINDSET THEN
            L_WhseItemTrackingLine.DELETEALL;
    end;

    local procedure UpdateDispatchOnGL(var P_ISH: Record "Interim Sales Header")
    var
        L_ISLAssBOM: Record "Interim Sales Line";
        L_ISLComponent: Record "Interim Sales Line";
    begin
        L_ISLAssBOM.RESET;
        L_ISLAssBOM.SETRANGE("Document No", ISH."No.");
        L_ISLAssBOM.SETRANGE(Type, L_ISLAssBOM.Type::"G/L Account");
        L_ISLAssBOM.SETRANGE("Dispatch Scan", FALSE);
        IF L_ISLAssBOM.FINDSET THEN
            REPEAT
                L_ISLAssBOM."Dispatch Scan" := TRUE;
                L_ISLAssBOM."Scanned Date" := CURRENTDATETIME;
                L_ISLAssBOM.MODIFY;
            UNTIL L_ISLAssBOM.NEXT = 0;
    end;

    procedure UpdatedDispatchOnWebOrderNew(var RecDispatch: Record "Despatch Scan Line"; P_TrolleyNo: Text; P_BayNo: Text; P_DispatchHeader: Record "Despatch Scan Header")
    var
        L_TradePartner: Record "Trade Partner";
        L_PostStock: Codeunit "Post Stock and Invoice";
        L_LocationCode: Code[20];
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Updating Lines.... @1@@@@@@@@@@');
        NoOfRecs := RecDispatch.COUNT;
        //RecDispatch.SETRANGE(Scanned,TRUE);
        IF RecDispatch.FINDSET THEN
            REPEAT
                ISL.RESET;
                ISL.SETRANGE("Document No", RecDispatch."Order No");
                ISL.SETRANGE("No.", RecDispatch."Item No.");
                ISL.SetRange("NAV Variant code", RecDispatch."Variant Code");
                ISL.SETRANGE("Dispatch Scan", FALSE);//ak 081220
                ISL.SETRANGE("Scanned Date", 0DT);//ak 081220
                IF ISL.FINDFIRST THEN BEGIN
                    L_LocationCode := L_LocationCode;
                    IF RecDispatch.Scanned THEN BEGIN //ak 211120 added validation so that system will mark dispatch scan only lines though are fully scanned
                        ISL."Scanned Date" := RecDispatch."Scan Date Time";
                        ISL."Dispatch Scan" := TRUE;
                        IF ISL."Item Type" = ISL."Item Type"::Component THEN;
                        RecDispatch."web order updated" := TRUE;
                        RecDispatch.MODIFY;
                    END;
                    ISL."Trolley Closed Quantity" += RecDispatch."Scanned Quantity";
                    ISL.Modify();
                    RecDispatch.MARK(TRUE);
                    MovedToArchive(RecDispatch);//ak 201120
                    AddOrderNotoTemp(ISL."Document No");
                END;

                CurrRec += 1;
                IF GUIALLOWED THEN BEGIN
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL RecDispatch.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;

        UpdatedDispatchedonHeader(RecDispatch."User ID", G_ISH);
        UpdateTrolleyCloseOnPostedPick(P_TrolleyNo, P_BayNo);
        /*IF L_TradePartner.GET(RecDispatch."Channel Parter Code") THEN BEGIN
            IF L_TradePartner."Scurry Validation Required" THEN
                PrintDeliveryNote;
        END;*///NG_No_need
        G_ArchivedScannedEntries.MARKEDONLY(TRUE);//ak 201120
        G_ArchivedScannedEntries.MODIFYALL("Trolley Closed", TRUE);//ak 201120
        G_ISH.MARKEDONLY(TRUE);
        G_ISH.DELETEALL(TRUE);
        RecDispatch.MARKEDONLY(TRUE);
        RecDispatch.SETRANGE(RecDispatch."Trolley No", P_TrolleyNo);
        RecDispatch.DELETEALL;
        //Sofyan++
        L_PostStock.CreateNPostWhseJnlLinesForTrolley(P_TrolleyNo);//CS++210921++ Post Warehouse journal at the time of stock posting.


        P_DispatchHeader.SetRange("Trolley No", P_TrolleyNo);
        P_DispatchHeader.SetRange("User ID", UserId);
        if P_DispatchHeader.FindSet() then begin
            repeat
                P_DispatchHeader.Delete();
            until P_DispatchHeader.Next() = 0;
        end;
        //Sofyan--
    end;

    procedure PrintDeliveryNote()
    var
        WSHList: Page "Warehouse Shipment List";
        OrderFilter: Text;
        ISH: Record "Interim Sales Header";
    begin
        COMMIT;
        IF TempOrderNo.FINDSET THEN
            REPEAT
                AddToFilterText2(OrderFilter, '|', '', TempOrderNo."No.");
            UNTIL TempOrderNo.NEXT = 0;


        COMMIT;
        ISH.SETRANGE("Document Type", ISH."Document Type"::Order);
        ISH.SETFILTER("No.", OrderFilter);
        IF ISH.FINDSET THEN
            REPORT.RUN(70194826, TRUE, FALSE, ISH);
    end;

    local procedure MovedToArchive(p_Despatch: Record "Despatch Scan Line")
    var
        L_ArchivedScannedEntries: Record "Archive Scanned Entries";
    begin
        G_ArchivedScannedEntries.INIT;
        G_ArchivedScannedEntries.TRANSFERFIELDS(p_Despatch);
        IF L_ArchivedScannedEntries.FINDLAST THEN
            G_ArchivedScannedEntries."Entry No." := L_ArchivedScannedEntries."Entry No." + 1
        ELSE
            G_ArchivedScannedEntries."Entry No." := 1;
        G_ArchivedScannedEntries.INSERT;
        G_ArchivedScannedEntries.MARK(TRUE);
    end;

    local procedure CheckifScanned(P_Trolley: Code[10]; P_WebOrderNo: Code[20]; P_ItemNo: Code[20]; P_varient: Code[20]): Boolean
    var
        L_Despatch: Record "Despatch Scan Line";
    begin
        L_Despatch.RESET;
        L_Despatch.SETRANGE(L_Despatch."Trolley No", P_Trolley);
        L_Despatch.SETRANGE("Order No", P_WebOrderNo);
        L_Despatch.SETRANGE("Item No.", P_ItemNo);
        L_Despatch.SetRange("Variant Code", P_varient);
        L_Despatch.SETRANGE(Scanned, TRUE);
        IF L_Despatch.FINDFIRST THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
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
        P_ISL.SETRANGE(Type, P_ISL.Type::Item);//Chandan++211220++ISSUE CAUSED IN HI HOUSE ORDER
        //P_ISL.SETRANGE(P_ISL."Order Status", P_ISL."Order Status"::Processing);
        P_ISL.SetFilter(P_ISL."Order Status", '%1|%2', P_ISL."Order Status"::Processing, P_ISL."Order Status"::"Partially Scanned");
        P_ISL.SETRANGE("Dispatch Scan", FALSE);//ak 211120
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
                        //P_ISL."Out Of Stock" := TRUE;//NG_No_Need
                        P_ISL."Line Status" := P_ISL."Line Status"::"No Stock";
                        AddOrderNotoTemp(P_ISL."Document No");
                    END;
                    IF NOT CheckifScanned(P_ISL."Trolley No.", P_ISL."Document No", P_ISL."No.", P_ISL."NAV Variant code") THEN BEGIN//ak 211120 check if line is already scanned
                        CLEAR(P_ISL."Trolley No.");
                        P_ISL.MODIFY;
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

        IF UpdateOutOfStock THEN
            UpdateRemovedOnHeader;
    end;

    local procedure CheckifInDispatchTable(P_Trolley: Code[10]; P_WebOrderNo: Code[20]; P_ItemNo: Code[20]): Boolean
    var
        L_Despatch: Record "Despatch Scan Line";
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

    local procedure CheckIFAllOrderLineMarkedNoStock(P_WebOrderH: Record "Interim Sales Header"): Boolean
    var
        L_WebOrderL: Record "Interim Sales Line";
    begin
        L_WebOrderL.RESET;
        L_WebOrderL.SETRANGE("Document Type", P_WebOrderH."Document Type");
        L_WebOrderL.SETRANGE("Document No", P_WebOrderH."No.");
        L_WebOrderL.SETRANGE(Type, L_WebOrderL.Type::Item);
        IF L_WebOrderL.COUNT < 2 THEN
            EXIT(TRUE);
        L_WebOrderL.SETFILTER("Line Status", '<>%1', L_WebOrderL."Line Status"::" ");
        IF L_WebOrderL.ISEMPTY THEN
            EXIT(TRUE);
    end;

    local procedure GetLastScannedDate(P_InterimSalesLine: Record "Interim Sales Line"): DateTime
    var
        L_ISL: Record "Interim Sales Line";
    begin
        L_ISL.RESET;
        L_ISL.SETCURRENTKEY("Scanned Date");
        L_ISL.SETRANGE("Document Type", P_InterimSalesLine."Document Type");
        L_ISL.SETRANGE("Document No", P_InterimSalesLine."Document No");
        L_ISL.SETASCENDING("Scanned Date", TRUE);
        IF L_ISL.FINDLAST THEN
            EXIT(L_ISL."Scanned Date");
    end;

    local procedure AddToFilterText2(VAR TextVar: Text; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;

    procedure CancelSelectedLines(var P_ISL: Record "Interim Sales Line")
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Cancelling Lines.... @1@@@@@@@@@@');
        NoOfRecs := P_ISL.COUNT;
        P_ISL.CALCFIELDS(Status);
        P_ISL.SETRANGE(Type, P_ISL.Type::Item);
        P_ISL.SETFILTER(Status, '%1|%2|%3', P_ISL.Status::Processing, P_ISL.Status::"Partially Scanned", P_ISL.Status::Cancelled); //Prathamesh 25112021
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
                    UpdatedDispatchedonHeader('', L_InterimSalesHeader);
            UNTIL TempOrderNo.NEXT = 0;
    end;

}

