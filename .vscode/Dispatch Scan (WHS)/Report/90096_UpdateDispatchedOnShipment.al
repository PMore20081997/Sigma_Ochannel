report 90096 "Update Dispatched On Shipment"
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


    end;

    var
        CurrRec: Integer;
        NoOfRecs: Integer;
        Window: Dialog;
        WSH: Record "Warehouse Shipment Header";
        Despatch: Record "Despatch Scan Line";
        WSL: Record "Warehouse Shipment Line";
        TempOrderNo: Record item temporary;
        CalledFromDispatch: Boolean;

        G_WSH: Record "Warehouse Shipment Header";

    local procedure UpdatedDispatchedonHeader(P_USERID: Text; var P_WSH: Record "Warehouse Shipment Header")
    var
        RecScannedISL: Record "Warehouse Shipment Line";
        RecNotScannedISL: Record "Warehouse Shipment Line";

    begin
        CLEAR(NoOfRecs);
        CLEAR(CurrRec);
        IF GUIALLOWED THEN
            Window.OPEN('Updating Header.... @1@@@@@@@@@@');
        NoOfRecs := TempOrderNo.COUNT;
        IF TempOrderNo.FINDSET THEN
            REPEAT
                WSH.RESET;
                WSH.SETFILTER("No.", '%1', TempOrderNo."No.");
                //ISH.SETFILTER("Sales Order No.",'<>%1','');
                IF WSH.FINDFIRST THEN BEGIN
                    RecScannedISL.RESET;
                    RecScannedISL.SETRANGE("No.", WSH."No.");
                    RecScannedISL.SETRANGE("Dispatch Scan", TRUE);
                    RecScannedISL.SETFILTER("Scanned Date", '<>%1', 0DT);
                    IF RecScannedISL.FINDSET THEN;

                    RecNotScannedISL.RESET;
                    RecNotScannedISL.SETRANGE("No.", WSH."No.");
                    IF RecNotScannedISL.FINDSET THEN;

                    IF RecScannedISL.COUNT = RecNotScannedISL.COUNT THEN BEGIN

                        IF P_WSH.GET(WSH."No.") THEN
                            P_WSH.MARK(TRUE);
                        //code to move order to handeled

                    END ELSE
                        IF (RecScannedISL.COUNT <> RecNotScannedISL.COUNT) AND (RecScannedISL.COUNT > 0) THEN BEGIN //alok 281220 ++
                                                                                                                    //   ISH.Status := ISH.Status::"Partially Scanned";
                                                                                                                    // ISH.MODIFY;
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
                WSL.RESET;
                WSL.SETRANGE("No.", RecDispatch."Order No");
                WSL.SETRANGE("Item No.", RecDispatch."Item No.");
                IF WSL.FINDFIRST THEN BEGIN
                    IF RecDispatch."Scan Date Time" <> 0DT THEN BEGIN
                        WSL."Scanned Date" := RecDispatch."Scan Date Time";
                        WSL.Validate("Qty. to Ship", RecDispatch.Quantity);
                        WSL."Dispatch Scan" := TRUE;
                        WSL.MODIFY;

                    END;

                    RecDispatch."web order updated" := TRUE;
                    RecDispatch.MODIFY;
                    RecDispatch.MARK(TRUE);
                    AddOrderNotoTemp(WSL."No.");
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

        //UpdatedDispatchedonHeader(RecDispatch."User ID", G_WSH);
        RecDispatch.MARKEDONLY(TRUE);
        RecDispatch.DELETEALL;
    end;

    local procedure UpdateDispatchOnAssemblyBOM(var P_WSH: Record "Warehouse Shipment Header")
    var
        L_ISLAssBOM: Record "Warehouse Shipment Line";
        L_ISLComponent: Record "Warehouse Shipment Line";
    begin
        L_ISLAssBOM.RESET;
        L_ISLAssBOM.SETRANGE("No.", P_WSH."No.");
        L_ISLAssBOM.SETRANGE("Dispatch Scan", FALSE);
        IF L_ISLAssBOM.FINDSET THEN
            REPEAT
                L_ISLComponent.RESET;
                L_ISLComponent.SETRANGE("No.", L_ISLAssBOM."No.");
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
                //  if P_BayNo <> '' then
                //    L_RegisteredWhseActivityLine.SetRange("Bay No.", P_BayNo);
                if L_RegisteredWhseActivityLine.FindFirst() then begin
                    /* repeat
                         if L_RegisteredWhseActivityLine."Bay No." <> '' then begin
                             L_RegisteredWhseActivityLine."Bay Closed" := true;
                             L_RegisteredWhseActivityLine.Modify();
                         end;
                     until L_RegisteredWhseActivityLine.Next() = 0;*/
                    //if (P_BayNo = '') OR AllBayNoclosed(L_RegisteredWhseActivityHdr) then begin
                    L_RegisteredWhseActivityHdr."Trolley Closed" := TRUE;
                    L_RegisteredWhseActivityHdr."Trolley No." := P_TrolleyNo;//Assign Trolley No.
                    L_RegisteredWhseActivityHdr.MODIFY;
                    // end;
                end;
            UNTIL L_RegisteredWhseActivityHdr.NEXT = 0;
    end;

    procedure AllBayNoclosed(P_RegisteredWhseActivityH: record "Registered Whse. Activity Hdr."): Boolean
    var
        L_RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        L_RegisteredWhseActivityLine.Reset();
        L_RegisteredWhseActivityLine.SetRange("No.", P_RegisteredWhseActivityH."No.");
        // L_RegisteredWhseActivityLine.SetFilter("Bay No.", '<>%1', '');
        //L_RegisteredWhseActivityLine.SetRange("Bay Closed", false);
        if L_RegisteredWhseActivityLine.IsEmpty then
            exit(true)
        else
            exit(false)
    end;

    procedure CheckWebOrderLinesFoUnscannedQty(P_TrolleyNo: Text)
    var
        L_WSL: Record "Warehouse Shipment Line";
        L_Dispatch: Record "Despatch Scan Line";
        OrderFilter: Text;
        ItemFilter: Text;
        WSHList: Page "Warehouse Shipment List";
        L_OrderLinesPage: Page "Warehouse Shipment List";
        L_WSL2: Record "Warehouse Shipment Line";
        IsPendingLines: Boolean;
    begin
        CLEAR(ItemFilter);
        CLEAR(OrderFilter);
        CLEAR(IsPendingLines);
        L_WSL.RESET;
        L_WSL.SETRANGE("No.", P_TrolleyNo);
        L_WSL.SETRANGE("Dispatch Scan", FALSE);
        IF L_WSL.FINDSET THEN
            REPEAT
                Despatch.RESET;
                Despatch.SETRANGE("Order No", L_WSL."No.");
                Despatch.SETRANGE("Trolley No", L_WSL."No.");
                Despatch.SETRANGE("Item No.", L_WSL."Item No.");
                Despatch.SetRange("Variant Code", L_WSL."Variant code");
                IF Despatch.FINDFIRST THEN BEGIN
                    IF (Despatch."Scanned Quantity" + L_WSL."Trolley Closed Quantity") < L_WSL.Quantity THEN BEGIN
                        AddToFilterText2(ItemFilter, '|', '', L_WSL."Item No.");
                        AddToFilterText2(OrderFilter, '|', '', L_WSL."No.");
                        if L_WSL2.Get(L_WSL."No.", L_WSL."Line No.") then
                            L_WSL2.Mark(true);
                        IsPendingLines := TRUE;
                    END;
                END ELSE BEGIN
                    AddToFilterText2(ItemFilter, '|', '', L_WSL."Item No.");
                    AddToFilterText2(OrderFilter, '|', '', L_WSL."No.");
                    if L_WSL2.Get(L_WSL."No.", L_WSL."Line No.") then
                        L_WSL2.Mark(true);
                    IsPendingLines := TRUE;
                END;
            UNTIL L_WSL.NEXT = 0;

        IF IsPendingLines THEN BEGIN
            MESSAGE('There are some unscanned orders in trolley. Please remove them from before closing');
            /*L_ISL2.RESET;
            L_ISL2.SETRANGE("Trolley No.", P_TrolleyNo);
            L_ISL2.SETRANGE(Type, L_ISL2.Type::Item);//CHANDAN++211220**TO MANAGE GL LINES
            L_ISL2.SETRANGE("Document Type", L_ISL2."Document Type"::Order);
            L_ISL2.SETFILTER("Document No", OrderFilter);
            L_ISL2.SETFILTER("No.", ItemFilter);*/
            L_WSL2.MarkedOnly(true);
            IF L_WSL2.FINDSET THEN BEGIN
                //L_InterimOrderLinesPage.LOOKUPMODE(TRUE);

                //IF L_InterimOrderLinesPage.RUNMODAL = ACTION::LookupOK THEN;

                //  ERROR('');
            END;
        END;
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



    procedure UpdatedDispatchOnWebOrderNew(var RecDispatch: Record "Despatch Scan Line"; P_TrolleyNo: Text; P_BayNo: Text; P_DispatchHeader: Record "Despatch Scan Header")
    var
        L_LocationCode: Code[20];
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Updating Lines.... @1@@@@@@@@@@');
        NoOfRecs := RecDispatch.COUNT;
        //RecDispatch.SETRANGE(Scanned,TRUE);
        IF RecDispatch.FINDSET THEN
            REPEAT
                WSL.RESET;
                WSL.SETRANGE("No.", RecDispatch."Order No");
                WSL.SETRANGE("Item No.", RecDispatch."Item No.");
                WSL.SetRange("Variant code", RecDispatch."Variant Code");
                WSL.SETRANGE("Dispatch Scan", FALSE);//ak 081220
                WSL.SETRANGE("Scanned Date", 0DT);//ak 081220
                IF WSL.FINDFIRST THEN BEGIN
                    L_LocationCode := L_LocationCode;
                    IF RecDispatch.Scanned THEN BEGIN //ak 211120 added validation so that system will mark dispatch scan only lines though are fully scanned
                        WSL."Scanned Date" := RecDispatch."Scan Date Time";
                        WSL."Dispatch Scan" := TRUE;
                        //  WSL."Qty. to Ship" := RecDispatch.Quantity;
                        WSL.Validate("Qty. to Ship", RecDispatch.Quantity);

                        RecDispatch."web order updated" := TRUE;
                        RecDispatch.MODIFY;
                    END;
                    WSL."Trolley Closed Quantity" += RecDispatch."Scanned Quantity";
                    WSL.Modify();
                    RecDispatch.MARK(TRUE);
                    //  MovedToArchive(RecDispatch);//ak 201120
                    AddOrderNotoTemp(WSL."No.");
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

        //  UpdatedDispatchedonHeader(RecDispatch."User ID", G_WSH);
        UpdateTrolleyCloseOnPostedPick(P_TrolleyNo, P_BayNo);
        /*IF L_TradePartner.GET(RecDispatch."Channel Parter Code") THEN BEGIN
            IF L_TradePartner."Scurry Validation Required" THEN
                PrintDeliveryNote;
        END;*///NG_No_need
        RecDispatch.MARKEDONLY(TRUE);
        RecDispatch.SETRANGE(RecDispatch."Trolley No", P_TrolleyNo);
        RecDispatch.DELETEALL;
        //Sofyan++


        P_DispatchHeader.SetRange("Trolley No", P_TrolleyNo);
        P_DispatchHeader.SetRange("User ID", UserId);
        if P_DispatchHeader.FindSet() then begin
            repeat
                P_DispatchHeader.Delete();
            until P_DispatchHeader.Next() = 0;
        end;
        //Sofyan--
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





    local procedure AddToFilterText2(VAR TextVar: Text; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;

    procedure CancelSelectedLines(var P_WSL: Record "Warehouse Shipment Line")
    var
        L_WareShipHeader: Record "Warehouse Shipment Header";
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Cancelling Lines.... @1@@@@@@@@@@');
        NoOfRecs := P_WSL.COUNT;
        P_WSL.SETRANGE("Dispatch Scan", FALSE);
        IF P_WSL.FINDSET THEN
            REPEAT

                Clear(P_WSL."Qty. to Ship");
                P_WSL.MODIFY;
                AddOrderNotoTemp(P_WSL."No.");
                CurrRec += 1;
                IF GUIALLOWED THEN BEGIN
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL P_WSL.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;

        IF TempOrderNo.FINDSET THEN
            REPEAT
                L_WareShipHeader.RESET;
                L_WareShipHeader.SETRANGE("No.", TempOrderNo."No.");
                IF L_WareShipHeader.FINDFIRST THEN;
            //    UpdatedDispatchedonHeader('', L_WareShipHeader);
            UNTIL TempOrderNo.NEXT = 0;
    end;

    procedure UpdateQtyOnWarehouseShipment(var RecDispatch: Record "Despatch Scan Line"; P_TrolleyNo: Text; P_BayNo: Text; P_DispatchHeader: Record "Despatch Scan Header")
    var
        L_LocationCode: Code[20];
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Updating Lines.... @1@@@@@@@@@@');
        NoOfRecs := RecDispatch.COUNT;
        IF RecDispatch.FINDSET THEN
            REPEAT
                WSL.RESET;
                WSL.SETRANGE("No.", RecDispatch."Order No");
                WSL.SETRANGE("Item No.", RecDispatch."Item No.");
                WSL.SetRange("Variant code", RecDispatch."Variant Code");
                WSL.SetRange("Line No.", RecDispatch."Order Line No.");
                IF WSL.FINDFIRST THEN BEGIN
                    L_LocationCode := L_LocationCode;
                    IF WSL."Qty. to Ship" <= WSL.Quantity THEN BEGIN
                        WSL."Scanned Date" := RecDispatch."Scan Date Time";
                        WSL."Dispatch Scan" := TRUE;

                        WSL.Validate("Qty. to Ship", WSL."Qty. to Ship" + RecDispatch."Scanned Quantity");

                        RecDispatch."web order updated" := TRUE;
                        RecDispatch.MODIFY;
                    END;
                    WSL."Trolley Closed Quantity" += RecDispatch."Scanned Quantity";
                    WSL.Modify();
                    RecDispatch.MARK(TRUE);
                    //  MovedToArchive(RecDispatch);//ak 201120
                    AddOrderNotoTemp(WSL."No.");
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


        UpdateTrolleyCloseOnPostedPick(P_TrolleyNo, P_BayNo);

        RecDispatch.MARKEDONLY(TRUE);
        RecDispatch.SETRANGE(RecDispatch."Trolley No", P_TrolleyNo);
        RecDispatch.DELETEALL;
        //Sofyan++


        P_DispatchHeader.SetRange("Trolley No", P_TrolleyNo);
        P_DispatchHeader.SetRange("User ID", UserId);
        if P_DispatchHeader.FindSet() then begin
            repeat
                P_DispatchHeader.Delete();
            until P_DispatchHeader.Next() = 0;
        end;
        //Sofyan--
    end;
}

