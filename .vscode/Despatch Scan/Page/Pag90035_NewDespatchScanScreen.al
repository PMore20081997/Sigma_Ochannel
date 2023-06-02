page 90034 "New Despatch Scan"
{
    PageType = Card;
    SourceTable = "Despatch Scan Header";
    // ApplicationArea = All;
    //UsageCategory = Administration;
    Caption = 'Dispatch Scan';
    layout
    {
        area(Content)
        {
            group(Option)
            {
                field(G_ScanText; G_ScanText)
                {
                    Editable = false;
                    QuickEntry = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }
                field(G_Scan; G_Scan)
                {
                    Caption = 'SCAN';
                    ApplicationArea = All;
                    QuickEntry = true;
                    ShowCaption = false;
                    trigger OnValidate()
                    begin
                        if G_ScanText = 'SCAN TROLLEY NO.' then begin
                            G_TrolleyNo := G_Scan;
                            CheckTrollyNo(G_TrolleyNo);
                            FindtotalWeborders(G_TrolleyNo);
                            FillPickedItemsForTrolley(G_TrolleyNo);
                            CurrPage.UPDATE;
                            Rec.SetRange("User ID", UserId);
                            if Rec.FindFirst() then begin
                                Rec."Trolley No" := G_TrolleyNo;
                                Rec.Modify();
                            end;
                            if CheckBayInTrolley(G_TrolleyNo) then
                                G_ScanText := 'SCAN BAY NO.'
                            else
                                G_ScanText := 'SCAN ITEM BARCODE';
                            G_Scan := '';
                        end
                        else
                            //Scan BayNo++
                            if CheckBayInTrolley(G_TrolleyNo) then begin
                                if G_ScanText = 'SCAN BAY NO.' then begin
                                    Rec.Reset();
                                    Rec.SetRange("User ID", UserId);
                                    Rec.SetRange("Trolley No", G_TrolleyNo);
                                    IF Rec.FINDFIRST THEN
                                        UpdateLinesInBay(Rec."Order No");
                                    CurrPage.UPDATE(FALSE);
                                    if G_Scan <> '' then begin
                                        CheckTrolleyScanCompleted(Rec."Order No", true);
                                        PostWarehouseShipment(G_TrolleyNo);
                                        CheckAndCloseDispatchScan(Rec."Trolley No");
                                    end;
                                    CurrPage.UPDATE(false);
                                    if G_TrolleyNo = '' then
                                        G_ScanText := 'SCAN TROLLEY NO.'
                                    else
                                        G_ScanText := 'SCAN BAY NO.';
                                    G_Scan := '';
                                end;
                            end else begin
                                //Scan BayNo--
                                if G_ScanText = 'SCAN ITEM BARCODE' then begin
                                    Rec.Reset();
                                    Rec.SetRange("User ID", UserId);
                                    Rec.SetRange("Trolley No", G_TrolleyNo);
                                    IF Rec.FINDFIRST THEN
                                        UpdateLine(Rec."Order No");
                                    CurrPage.UPDATE(FALSE);

                                    CheckTrolleyScanCompleted(Rec."Order No", true);
                                    PostWarehouseShipment(G_TrolleyNo);
                                    CheckAndCloseDispatchScan(Rec."Trolley No");
                                    CurrPage.UPDATE(false);
                                    if G_TrolleyNo = '' then
                                        G_ScanText := 'SCAN TROLLEY NO.'
                                    else
                                        G_ScanText := 'SCAN ITEM BARCODE';
                                    G_Scan := '';
                                end;
                            end;
                    end;
                }
                field(G_TrolleyNo; G_TrolleyNo)
                {
                    Caption = 'Trolley No.';
                    ApplicationArea = All;
                    Editable = false;
                    QuickEntry = false;
                }
                field(G_TotalWebOrders; G_TotalWebOrders)
                {
                    Caption = 'Total No. Of Orders';
                    Enabled = false;
                    ApplicationArea = All;
                    QuickEntry = false;
                }

            }
            part("Despatch Lines"; "Despatch Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Trolley No." = field("Trolley No");
            }
            part("WH Shipment Lines"; "WH Shipment Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Trolley No." = field("Trolley No");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Close Trolley")
            {
                Caption = 'Close Trolley';
                Image = Shipment;
                ApplicationArea = All;
                //Visible = false;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;


                trigger OnAction()
                var
                    P_DispatchHeader: Record "Despatch Scan Header";
                begin
                    CheckTrolleyScanCompleted(Rec."Order No", false);
                    PostWarehouseShipment(G_TrolleyNo);
                    P_DispatchHeader.Reset();
                    P_DispatchHeader.SetRange("Trolley No", G_TrolleyNo);
                    P_DispatchHeader.SetRange("User ID", UserId);
                    if P_DispatchHeader.FindFirst() then begin
                        P_DispatchHeader.Delete();
                        //  CurrPage.Close();
                    end;

                end;
            }
            action("Remove Scanned Entries")
            {

                Image = RemoveLine;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                begin
                    CurrPage."Despatch Lines".Page.GetDetailsFromHeader();
                    CurrPage.Update(true);
                end;
            }
            action("Cancel Line")
            {
                Image = Cancel;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;

                trigger OnAction()
                var
                    L_WhseShipmentLine: Record "Warehouse Shipment Line";
                begin
                    CurrPage."Despatch Lines".Page.CancelLine();
                end;
            }
            action("Park Order")
            {
                Image = Archive;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                var
                    L_WhseShipmentLine: Record "Warehouse Shipment Line";
                    P_DispatchHeader: Record "Despatch Scan Header";
                begin
                    L_WhseShipmentLine.Reset();
                    L_WhseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
                    L_WhseShipmentLine.SetRange("Channel Order ID", Rec."Order No");
                    L_WhseShipmentLine.SetFilter("Scan Status", '<>%1', L_WhseShipmentLine."Scan Status"::Cancelled);
                    if L_WhseShipmentLine.FindSet() then begin
                        repeat
                            L_WhseShipmentLine."Scan Status" := L_WhseShipmentLine."Scan Status"::Parked;
                            Clear(L_WhseShipmentLine."Scanned Quantity");
                            L_WhseShipmentLine.Parked := true;
                            L_WhseShipmentLine.Modify();
                        until L_WhseShipmentLine.Next() = 0;
                        P_DispatchHeader.SetRange("Trolley No", G_TrolleyNo);
                        P_DispatchHeader.SetRange("User ID", UserId);
                        if P_DispatchHeader.FindFirst() then begin
                            Clear(P_DispatchHeader."Order No");
                            P_DispatchHeader.Modify();
                        end;
                    end;
                end;
            }
            action("Post & Print")
            {
                Image = PostPrint;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;

                trigger OnAction()
                var
                    WarehouseShipmentLine: Record "Warehouse Shipment Line";
                    PartiallyDespatchScanCount: Integer;
                    P_DispatchHeader: Record "Despatch Scan Header";
                    HISH: Record "Handled Interim Sales Header";
                    WarehouseShipmentHeader: Record "Warehouse Shipment Header";
                begin

                    Clear(PartiallyDespatchScanCount);
                    WarehouseShipmentLine.Reset();
                    WarehouseShipmentLine.SetRange("Trolley No.", Rec."Trolley No");
                    WarehouseShipmentLine.SetRange("Channel Order ID", Rec."Order No");
                    WarehouseShipmentLine.SetFilter("Scan Status", '<>%1&<>%2', WarehouseShipmentLine."Scan Status"::Cancelled, WarehouseShipmentLine."Scan Status"::Parked);
                    PartiallyDespatchScanCount := WarehouseShipmentLine.Count;

                    if PartiallyDespatchScanCount > 0 then begin
                        if WarehouseShipmentLine.FindSet() then begin
                            HISH.Reset();
                            HISH.SetRange("Document Type", HISH."Document Type"::Order);
                            HISH.SetRange("Channel Order ID", WarehouseShipmentLine."Channel Order ID");
                            if HISH.FindFirst() then
                                PrintPartiallyDespatchReport(HISH."No.");
                            repeat
                                if WarehouseShipmentLine."Scanned Quantity" > 0 then begin
                                    WarehouseShipmentLine.Validate("Qty. to Ship", WarehouseShipmentLine."Scanned Quantity");
                                    WarehouseShipmentLine."Dispatch Scan" := true;
                                    WarehouseShipmentLine."Scan Station" := Format(Rec."Entry No.");
                                    WarehouseShipmentLine."Scanned Date" := CurrentDateTime;
                                    WarehouseShipmentLine.Modify();
                                end;

                            until WarehouseShipmentLine.Next() = 0;

                            WarehouseShipmentHeader.Reset();
                            WarehouseShipmentHeader.SetRange("No.", WarehouseShipmentLine."No.");
                            if WarehouseShipmentHeader.FindFirst() then begin
                                WarehouseShipmentHeader.Validate("Posting Date", WorkDate());
                                WarehouseShipmentHeader.Modify();
                            end;

                            P_DispatchHeader.SetRange("Trolley No", G_TrolleyNo);
                            P_DispatchHeader.SetRange("User ID", UserId);
                            if P_DispatchHeader.FindFirst() then begin
                                Clear(P_DispatchHeader."Order No");
                                P_DispatchHeader.Modify();
                            end;
                            CurrPage."WH Shipment Lines".Page.Update();
                        end;
                    end;
                end;
            }
            action("Web Order")
            {
                Image = Open;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                var
                begin
                    CurrPage."Despatch Lines".Page.OpenWebOrder();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        L_Despatch: Record "Despatch Scan Header";
        L_WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        L_Despatch.Reset();
        L_Despatch.SetRange("Entry No.", 0);
        if L_Despatch.FindFirst() then
            L_Despatch.Delete();

        L_Despatch.Reset();
        L_Despatch.SetRange("Trolley No", 'DESPATCHSCAN');
        L_Despatch.SETRANGE("User ID", USERID);
        if L_Despatch.FindSet() then
            L_Despatch.DeleteAll();

        L_Despatch.RESET;
        L_Despatch.Ascending(false);
        L_Despatch.SETRANGE("User ID", USERID);
        IF L_Despatch.FINDFIRST THEN BEGIN
            L_WarehouseShipmentLine.RESET;
            L_WarehouseShipmentLine.SETRANGE("Trolley No.", L_Despatch."Trolley No");
            if L_WarehouseShipmentLine.FindSet() then begin
                G_TrolleyNo := L_WarehouseShipmentLine."Trolley No.";
                if G_TrolleyNo <> '' then begin
                    FindtotalWeborders(G_TrolleyNo);
                    FillPickedItemsForTrolley(G_TrolleyNo);
                    CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, '');
                    rec.SetRange("Trolley No", G_TrolleyNo);
                end;
            end;
        END
        ELSE BEGIN
            L_Despatch.Reset();
            if L_Despatch.FindLast() then begin
                L_Despatch.Init();
                L_Despatch."Entry No." := L_Despatch."Entry No." + 1;
                L_Despatch."User ID" := UserId;
                L_Despatch."Trolley No" := 'DespatchScan';
                L_Despatch.Insert(true);
            end
            else begin
                L_Despatch.Init();
                L_Despatch."Entry No." := 1;
                L_Despatch."User ID" := UserId;
                L_Despatch."Trolley No" := 'DespatchScan';
                L_Despatch.Insert(true);

            end;
        END;

        if G_TrolleyNo = '' then
            G_ScanText := 'SCAN TROLLEY NO.'
        else
            G_ScanText := 'SCAN ITEM BARCODE';
        CurrPage.UPDATE(false);
    end;

    trigger OnClosePage()
    var
        L_Despatch: Record "Despatch Scan Header";
    begin
        L_Despatch.Reset();
        L_Despatch.SETRANGE("User ID", USERID);
        L_Despatch.SetFilter("Trolley No", '%1', '');
        if L_Despatch.FindFirst() then
            L_Despatch.Delete();
    end;

    var
        G_Scan: Code[20];
        G_ScanText: Code[250];
        G_TotalWebOrders: Text;
        G_WarehouseShipmentLine: Record "Warehouse Shipment Line";
        G_TrolleyNo: Code[20];
        G_EntryNo: Integer;

    local procedure CheckTrollyNo(P_Trolly: Code[20])
    var
        L_WhseActivityLine: Record "Warehouse Activity Line";
        WarShipmentHeader: Record "Warehouse Shipment Header";
    begin
        WarShipmentHeader.Reset();
        WarShipmentHeader.SetRange("Trolley No.", P_Trolly);
        if not WarShipmentHeader.FindSet() then begin
            Error('Trolley does not exist');
        end;

        L_WhseActivityLine.RESET;
        L_WhseActivityLine.SETRANGE("Activity Type", L_WhseActivityLine."Activity Type"::Pick);
        L_WhseActivityLine.SETRANGE("Trolley No.", P_Trolly);
        IF NOT L_WhseActivityLine.ISEMPTY THEN
            ERROR(STRSUBSTNO('Trolley %1 is in picking', P_Trolly));
    end;

    local procedure FindtotalWeborders(L_TrolleyNo: Code[20])
    var
        Q50013: Query "Total No Orders By Trolley";
        i: Integer;
    begin
        CLEAR(Q50013);
        CLEAR(G_TotalWebOrders);
        CLEAR(i);
        Q50013.SETFILTER(Q50013.Trolley_No_, L_TrolleyNo);
        Q50013.OPEN;
        WHILE Q50013.READ DO BEGIN
            i := i + 1;
        END;
        Q50013.CLOSE;
        G_TotalWebOrders := FORMAT(i);
    end;

    local procedure FillPickedItemsForTrolley(P_TrolleyNo: Text)
    var
        Query50016: Query "Get Registered Qty From Pick";
        TempPickedStock: Record "Lot Bin Buffer" temporary;
    begin
        CLEAR(Query50016);
        Query50016.SETRANGE(Query50016.Trolley_No, P_TrolleyNo);
        Query50016.OPEN;
        WHILE Query50016.READ DO BEGIN
            TempPickedStock.RESET;
            TempPickedStock.SETRANGE("Item No.", Query50016.Item_No);
            TempPickedStock.SetRange("Variant Code", Query50016.Variant_Code);
            TempPickedStock.SETRANGE("Bin Code", Query50016.No);
            IF NOT TempPickedStock.FINDFIRST THEN BEGIN
                TempPickedStock.INIT;
                TempPickedStock."Item No." := Query50016.Item_No;
                TempPickedStock."Variant Code" := Query50016.Variant_Code;
                TempPickedStock."Bin Code" := Query50016.No;
                TempPickedStock."Qty. (Base)" := Query50016.Sum_Qty_Base;
                TempPickedStock."Lot No." := Query50016.Trolley_No;
                TempPickedStock.INSERT;
            END ELSE BEGIN
                TempPickedStock."Qty. (Base)" += Query50016.Sum_Qty_Base;
                TempPickedStock.MODIFY;
            END;
        END;
        Query50016.CLOSE;
    end;

    local procedure UpdateLine(P_OrderNo: Code[20])
    var
        L_DespatchH: Record "Despatch Scan Header";
        WSL: Record "Warehouse Shipment Line";
        WSL2: Record "Warehouse Shipment Line";
        WS: Record "Warehouse Shipment Line";
        v: Record "Warehouse Shipment Header" temporary;
    begin
        if P_OrderNo <> '' then begin
            if CheckOrderScanCompleted(P_OrderNo) = false then begin
                G_WarehouseShipmentLine.Reset();
                G_WarehouseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
                G_WarehouseShipmentLine.SetRange("Item No.", FindItem(G_Scan, 1));
                G_WarehouseShipmentLine.SetRange("Dispatch Scan", false);
                G_WarehouseShipmentLine.SetFilter("Scan Status", '<>%1', G_WarehouseShipmentLine."Scan Status"::Cancelled);
                G_WarehouseShipmentLine.SetRange("Channel Order ID", P_OrderNo);
                if G_WarehouseShipmentLine.FindFirst() then begin
                    L_DespatchH.Reset();
                    L_DespatchH.SetRange("Trolley No", G_TrolleyNo);
                    L_DespatchH.SetRange("User ID", UserId);
                    if L_DespatchH.FindFirst() then begin
                        Rec."Order No" := G_WarehouseShipmentLine."Channel Order ID";
                        Rec.Modify();
                    end;
                    WS.Reset();
                    WS.SetRange("Trolley No.", G_WarehouseShipmentLine."Trolley No.");
                    WS.SetRange("Channel Order ID", G_WarehouseShipmentLine."Channel Order ID");
                    WS.SetFilter("Scan Status", '<>%1&<>%2', WS."Scan Status"::Cancelled, WS."Scan Status"::Scanned);
                    if WS.FindSet() then begin
                        repeat
                            WS."User ID" := UserId;

                            if WS."Scan Status" = WS."Scan Status"::Parked then
                                WS."Scan Status" := WS."Scan Status"::" ";

                            if WS.Parked = true then
                                WS.Parked := false;


                            if WS."Item No." = G_WarehouseShipmentLine."Item No." then begin
                                if WS."Qty. Picked" > WS."Scanned Quantity" then begin
                                    CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                    WS.Validate("Scanned Quantity", WS."Scanned Quantity" + 1);
                                    WS.Validate("Scanned By", UserId);
                                    if WS."Qty. Picked" = WS."Scanned Quantity" then begin
                                        WS."Scan Station" := Format(Rec."Entry No.");
                                        WS.Validate("Scan Status", WS."Scan Status"::Scanned);
                                        WS.Validate("Scanned Date", CurrentDateTime);
                                    end;

                                end else
                                    Error('Item is completely scanned');
                            end;
                            WS.Modify();
                        until WS.Next() = 0;
                        CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                        CurrPage.Update();
                    end;
                end else
                    Error('Scanned Item does not belong the Order %1', P_OrderNo);
            end else begin
                G_WarehouseShipmentLine.Reset();
                G_WarehouseShipmentLine.SetCurrentKey("Channel Order ID");
                G_WarehouseShipmentLine.SetAscending("Channel Order ID", true);
                G_WarehouseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
                G_WarehouseShipmentLine.SetRange("Item No.", FindItem(G_Scan, 1));
                G_WarehouseShipmentLine.SetRange("Dispatch Scan", false);
                G_WarehouseShipmentLine.SetFilter("Scan Status", '<>%1&<>%2', G_WarehouseShipmentLine."Scan Status"::Cancelled, G_WarehouseShipmentLine."Scan Status"::Scanned);
                if G_WarehouseShipmentLine.FindFirst() then begin
                    L_DespatchH.Reset();
                    L_DespatchH.SetRange("Trolley No", G_TrolleyNo);
                    L_DespatchH.SetRange("User ID", UserId);
                    if L_DespatchH.FindFirst() then begin
                        Rec."Order No" := G_WarehouseShipmentLine."Channel Order ID";
                        Rec.Modify();
                    end;
                    WS.Reset();
                    WS.SetRange("Trolley No.", G_WarehouseShipmentLine."Trolley No.");
                    WS.SetRange("Channel Order ID", G_WarehouseShipmentLine."Channel Order ID");
                    WS.SetFilter("Scan Status", '<>%1&<>%2', WS."Scan Status"::Cancelled, WS."Scan Status"::Scanned);
                    if WS.FindSet() then begin
                        repeat
                            WS."User ID" := UserId;

                            if WS."Scan Status" = WS."Scan Status"::Parked then
                                WS."Scan Status" := WS."Scan Status"::" ";

                            if WS.Parked = true then
                                WS.Parked := false;


                            if WS."Item No." = G_WarehouseShipmentLine."Item No." then begin
                                if WS."Qty. Picked" > WS."Scanned Quantity" then begin
                                    CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                    WS.Validate("Scanned Quantity", WS."Scanned Quantity" + 1);
                                    WS.Validate("Scanned By", UserId);
                                    if WS."Qty. Picked" = WS."Scanned Quantity" then begin
                                        WS."Scan Station" := Format(Rec."Entry No.");
                                        WS.Validate("Scan Status", WS."Scan Status"::Scanned);
                                        WS.Validate("Scanned Date", CurrentDateTime);
                                    end;

                                end else
                                    Error('Item is completely scanned');
                            end;
                            WS.Modify();
                        until WS.Next() = 0;
                        CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                        CurrPage.Update();
                    end;


                end else
                    Error('Scanned Item does not belong to the below Order');
            end;
            //Error('Please Post and Print the Order %1', P_OrderNo);
        end else begin
            G_WarehouseShipmentLine.Reset();
            G_WarehouseShipmentLine.SetCurrentKey("Channel Order ID");
            G_WarehouseShipmentLine.SetAscending("Channel Order ID", true);
            G_WarehouseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
            G_WarehouseShipmentLine.SetRange("Item No.", FindItem(G_Scan, 1));
            G_WarehouseShipmentLine.SetRange("Dispatch Scan", false);
            G_WarehouseShipmentLine.SetFilter("Scan Status", '<>%1', G_WarehouseShipmentLine."Scan Status"::Cancelled);
            if G_WarehouseShipmentLine.FindFirst() then begin
                L_DespatchH.Reset();
                L_DespatchH.SetRange("Trolley No", G_TrolleyNo);
                L_DespatchH.SetRange("User ID", UserId);
                if L_DespatchH.FindFirst() then begin
                    Rec."Order No" := G_WarehouseShipmentLine."Channel Order ID";
                    Rec.Modify();
                end;
                WS.Reset();
                WS.SetRange("Trolley No.", G_WarehouseShipmentLine."Trolley No.");
                WS.SetRange("Channel Order ID", G_WarehouseShipmentLine."Channel Order ID");
                WS.SetFilter("Scan Status", '<>%1', WS."Scan Status"::Cancelled);
                if WS.FindSet() then begin
                    repeat
                        WS."User ID" := UserId;

                        if WS."Scan Status" = WS."Scan Status"::Parked then
                            WS."Scan Status" := WS."Scan Status"::" ";

                        if WS.Parked = true then
                            WS.Parked := false;

                        if WS."Item No." = G_WarehouseShipmentLine."Item No." then begin
                            if WS."Qty. Picked" > WS."Scanned Quantity" then begin
                                CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                WS.Validate("Scanned Quantity", WS."Scanned Quantity" + 1);
                                WS.Validate("Scanned By", UserId);
                                if WS."Qty. Picked" = WS."Scanned Quantity" then begin
                                    WS."Scan Station" := Format(Rec."Entry No.");
                                    WS.Validate("Scan Status", WS."Scan Status"::Scanned);
                                    WS.Validate("Scanned Date", CurrentDateTime);
                                end;

                            end else
                                Error('Item is completely scanned');
                        end;
                        WS.Modify();
                    until WS.Next() = 0;

                end;


            end else
                Error('Scanned Item does not belong to the below Order');
        end;
        Commit();
    end;

    local procedure CheckTrolleyScanCompleted(P_OrderNo: Code[20]; CallFrom: Boolean)
    var
        OrderLnneCount: Integer;
        DespatchCount: Integer;
        NewDeliveryNote: Report DelivryNote1;
        messagetext: Text;
        Text001: TextConst ENU = 'All items in this %1 are scanned..\\ Do you want to close %1?',
                          ENG = 'All items in this %1 are scanned..\\ Do you want to close %1?';
        UpdateDispatchedOnShipment: Report "Update Dispatched On Shipment";
        WSL1: Record "Warehouse Shipment Line";
        WSL2: Record "Warehouse Shipment Line";
        Window: Dialog;
        P_DispatchHeader: Record "Despatch Scan Header";
        CurrRec: Integer;
        NoOfRecs: Integer;
        HISH: Record "Handled Interim Sales Header";
        HISH2: Record "Handled Interim Sales Header";
        HISL: Record "Handled Interim Sales Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
    begin
        CLEAR(OrderLnneCount);
        CLEAR(DespatchCount);
        WSL1.Reset();
        WSL1.SetRange("Trolley No.", G_TrolleyNo);
        WSL1.SetFilter("Scan Status", '<>%1', WSL1."Scan Status"::Cancelled);
        WSL1.SetRange("Channel Order ID", P_OrderNo);
        if WSL1.FindSet() then
            OrderLnneCount := WSL1.COUNT;

        WSL2.Reset();
        WSL2.SetRange("Trolley No.", G_TrolleyNo);
        WSL2.SetRange("Channel Order ID", P_OrderNo);
        WSL2.SetRange("Scan Status", WSL2."Scan Status"::Scanned);
        if WSL2.FindSet() then
            DespatchCount := WSL2.COUNT;

        if OrderLnneCount > 0 then begin
            IF DespatchCount = OrderLnneCount THEN BEGIN
                IF CONFIRM('Do you want to close the order?', TRUE) THEN BEGIN
                    IF GUIALLOWED THEN
                        Window.OPEN('Updating Lines.... @1@@@@@@@@@@');


                    WSL1.Reset();
                    WSL1.SetRange("Trolley No.", G_TrolleyNo);
                    WSL1.SetRange("Scan Status", WSL1."Scan Status"::Scanned);
                    if WSL1.FindSet() then begin
                        HISH.Reset();
                        HISH.SetRange("Document Type", HISH."Document Type"::Order);
                        HISH.SetRange("Channel Order ID", P_OrderNo);
                        if HISH.FindFirst() then
                            if CallFrom = true then
                                PrintPartiallyDespatchReport(HISH."No.");
                        NoOfRecs := WSL1.COUNT;
                        repeat
                            WSL1.Validate("Qty. to Ship", WSL1."Scanned Quantity");
                            WSL1."Dispatch Scan" := true;
                            WSL1.Modify(true);
                            CurrRec += 1;
                            IF GUIALLOWED THEN BEGIN
                                IF NoOfRecs <= 100 THEN
                                    Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                                ELSE
                                    IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                            END;
                            //MarkDispatchOnWeb++
                            if WSL1."Scanned Quantity" = WSL1."Qty. to Ship" then begin
                                HISH2.Reset();
                                HISH2.SetRange("Document Type", HISH2."Document Type"::Order);
                                HISH2.SetRange("No.", WSL1."Source No.");
                                if HISH2.FindFirst() then begin
                                    HISH2.Validate(status, HISH2.status::Dispatched);
                                    HISH2.Validate("Scanned Date", WSL1."Scanned Date");
                                    HISH2.Validate("Scanned By", WSL1."Scanned By");
                                    HISH2.Modify(true);
                                    HISL.Reset();
                                    HISL.SetRange("Document Type", HISL."Document Type"::Order);
                                    HISL.SetRange("Document No", HISH."No.");
                                    HISL.SetRange(Type, HISL.Type::Item);
                                    if HISL.FindSet() then begin
                                        repeat
                                            HISL.Validate("Ordser Status", HISL."Ordser Status"::Dispatched);
                                            HISL.Modify(true);
                                        until HISL.Next() = 0;
                                    end;
                                end;
                            end;
                        //MarkDispatchOnWeb--
                        until WSL1.Next() = 0;

                        WarehouseShipmentHeader.Reset();
                        WarehouseShipmentHeader.SetRange("No.", WSL1."No.");
                        if WarehouseShipmentHeader.FindFirst() then begin
                            WarehouseShipmentHeader.Validate("Posting Date", WorkDate());
                            WarehouseShipmentHeader.Modify();
                        end;

                        IF GUIALLOWED THEN
                            Window.CLOSE;
                        P_DispatchHeader.SetRange("Trolley No", G_TrolleyNo);
                        P_DispatchHeader.SetRange("User ID", UserId);
                        if P_DispatchHeader.FindFirst() then
                            Clear(P_DispatchHeader."Order No");
                    end;
                END;
            END;
        end;
    end;

    local procedure CheckOrderScanCompleted(P_OrderNo: Code[20]): Boolean
    var
        OrderLnneCount: Integer;
        DespatchCount: Integer;
        WSL1: Record "Warehouse Shipment Line";
        WSL2: Record "Warehouse Shipment Line";
    begin
        CLEAR(OrderLnneCount);
        CLEAR(DespatchCount);
        WSL1.Reset();
        WSL1.SetRange("Trolley No.", G_TrolleyNo);
        WSL1.SetRange("Channel Order ID", P_OrderNo);
        WSL1.SetFilter("Scan Status", '<>%1&<>%2', WSL1."Scan Status"::Cancelled, WSL1."Scan Status"::Parked);
        if WSL1.FindSet() then
            OrderLnneCount := WSL1.COUNT;

        WSL2.Reset();
        WSL2.SetRange("Trolley No.", G_TrolleyNo);
        WSL2.SetRange("Scan Status", WSL2."Scan Status"::Scanned);
        WSL2.SetRange("Channel Order ID", P_OrderNo);
        if WSL2.FindSet() then
            DespatchCount := WSL2.COUNT;
        if OrderLnneCount > 0 then
            if OrderLnneCount = DespatchCount then
                exit(true);

    end;

    procedure PrintPartiallyDespatchReport(P_OrderNo: Code[20])
    var
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        G_GeneralSetup: Record "General Setup - Channels";
        G_WorkstationSelectionCodeUnit: Codeunit WorkstationSelection;
        R_DeliveryNote: Report "Handled Delivery Note";
        WebMgt: Codeunit "Web Order Mgt";
        FileOutStream: OutStream;
        FileInStream: InStream;
        outputFileName: Text[250];
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        L_ShipmentTracking: Record "Shipment Tracking";
        InStm: InStream;
        filename: Text;
        R_CourierLabel: Report "Courier Label";
        ShippingAgent: Record "Shipping Agent";
    begin
        //if Confirm('Do you want to print the label? ', true) then begin
        G_GeneralSetup.Get();
        if G_GeneralSetup."Despatch Printer Selection" then begin
            G_WorkstationSelectionCodeUnit.UpdateWorkstation();
        end;
        Clear(FileInStream);
        Clear(FileOutStream);
        Clear(outputFileName);
        Clear(TempBlob);
        Clear(FileMgt);
        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETRANGE("No.", P_OrderNo);
        IF HandledInterimSalesHeader.FindFirst() THEN BEGIN
            ShippingAgent.Reset();
            ShippingAgent.SetRange(Code, HandledInterimSalesHeader."Shipping Agent Code");
            if ShippingAgent.FindFirst() then begin
                if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
                    //RAW Printing Option Means it is For DPD EPL Label and PDF labels
                    WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
                end;
                if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
                    WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
                end;
            end;
            If (ShippingAgent.Code <> 'ROYALMAIL') and (HandledInterimSalesHeader."Trade Partner Code" <> 'LUST HOME') then // go live issue - no invoice on royal mail or lust home
            begin
                Clear(R_DeliveryNote);
                R_DeliveryNote.SetTableView(HandledInterimSalesHeader);
                R_DeliveryNote.UseRequestPage(false);
                R_DeliveryNote.Run();
            end;

        END;

    end;

    local procedure CheckAndCloseDispatchScan(P_TrolleyNo: Code[20])
    var
        OrderLnneCount: Integer;
        DespatchCount: Integer;
        NewDeliveryNote: Report DelivryNote1;
        messagetext: Text;
        Text001: TextConst ENU = 'All items in this %1 are scanned..\\ Do you want to close %1?',
                          ENG = 'All items in this %1 are scanned..\\ Do you want to close %1?';
        UpdateDispatchedOnShipment: Report "Update Dispatched On Shipment";
        WSL1: Record "Warehouse Shipment Line";
        WSL2: Record "Warehouse Shipment Line";
        Window: Dialog;
        P_DispatchHeader: Record "Despatch Scan Header";
        CurrRec: Integer;
        NoOfRecs: Integer;
        HISH: Record "Handled Interim Sales Header";
    begin
        CLEAR(OrderLnneCount);
        CLEAR(DespatchCount);
        WSL1.Reset();
        WSL1.SetRange("Trolley No.", P_TrolleyNo);
        WSL1.SetFilter("Scan Status", '<>%1', WSL1."Scan Status"::Cancelled);
        if WSL1.FindSet() then
            OrderLnneCount := WSL1.COUNT;

        WSL2.Reset();
        WSL2.SetRange("Trolley No.", G_TrolleyNo);
        WSL2.SetRange("Scan Status", WSL2."Scan Status"::Scanned);
        if WSL2.FindSet() then
            DespatchCount := WSL2.COUNT;

        if OrderLnneCount > 0 then begin
            IF DespatchCount = OrderLnneCount THEN BEGIN
                IF CONFIRM('All items in this trolley are scanned..\\ Do you want to close Trolley?', TRUE) THEN BEGIN
                    P_DispatchHeader.Reset();
                    P_DispatchHeader.SetRange("Trolley No", G_TrolleyNo);
                    P_DispatchHeader.SetRange("User ID", UserId);
                    if P_DispatchHeader.FindFirst() then begin
                        P_DispatchHeader.Delete();
                        CurrPage.Close();
                    end;


                END;
            END;
        end;
    end;

    procedure FindItem(P_Item: Code[20]; i: integer): Code[20]
    var
        L_ItemBarcode: Record "Item Reference";
        L_ItemNo: Record Item;
    begin
        L_ItemBarcode.RESET;
        L_ItemBarcode.SETRANGE("Reference Type", L_ItemBarcode."Reference Type"::"Bar Code");
        L_ItemBarcode.SETRANGE("Reference No.", P_Item);
        IF L_ItemBarcode.FINDFIRST THEN
            if i = 1 then
                EXIT(L_ItemBarcode."Item No.")
            else
                EXIT(L_ItemBarcode."Variant Code");

        L_ItemNo.RESET;
        L_ItemNo.SETRANGE("No.", P_Item);
        IF L_ItemNo.FINDFIRST THEN
            EXIT(L_ItemNo."No.");

        ERROR('Item not find');
    end;

    local procedure PostWarehouseShipment(P_TrolleyNo: Code[20])
    var
        L_WarehouseShipmentLines: Record "Warehouse Shipment Line";
        L_LinesCount: Integer;
        L_ScanLineCount: Integer;
        DispatchHeader: Record "Despatch Scan Header";
    begin
        Clear(L_LinesCount);
        L_WarehouseShipmentLines.Reset();
        L_WarehouseShipmentLines.SetRange("Trolley No.", P_TrolleyNo);
        L_WarehouseShipmentLines.SetFilter("Line Status", '<>%1', L_WarehouseShipmentLines."Line Status"::Cancelled);
        if L_WarehouseShipmentLines.FindSet() then
            L_LinesCount := L_WarehouseShipmentLines.Count;

        Clear(L_ScanLineCount);
        L_WarehouseShipmentLines.Reset();
        L_WarehouseShipmentLines.SetRange("Trolley No.", P_TrolleyNo);
        L_WarehouseShipmentLines.SetFilter("Line Status", '<>%1', L_WarehouseShipmentLines."Line Status"::Cancelled);
        L_WarehouseShipmentLines.SetFilter("Qty. to Ship", '<>%1', 0);
        if L_WarehouseShipmentLines.FindSet() then begin
            repeat
                if L_WarehouseShipmentLines."Qty. to Ship" = L_WarehouseShipmentLines.Quantity then
                    L_ScanLineCount += 1;
            until L_WarehouseShipmentLines.Next() = 0;
        end;


        if L_LinesCount > 0 then
            if L_ScanLineCount = L_LinesCount then begin
                CODEUNIT.Run(CODEUNIT::"Whse.-Post Shipment", L_WarehouseShipmentLines);
                DispatchHeader.Reset();
                DispatchHeader.SetRange("Trolley No", G_TrolleyNo);
                DispatchHeader.SetRange("User ID", UserId);
                if DispatchHeader.FindFirst() then begin
                    DispatchHeader.Delete();
                    //CurrPage.Close();
                end;
            end;


    end;

    local procedure CheckBayInTrolley(P_TrolleyNo: Code[20]): Boolean
    var
        L_WSL: Record "Warehouse Shipment Line";
        L_WSH: Record "Warehouse Shipment Header";
    begin
        L_WSH.Reset();
        L_WSH.SetRange("Trolley No.", P_TrolleyNo);
        L_WSH.SetRange("Shipping Agent Code", 'ROYALMAIL');//Check for Sample Item
        if L_WSH.FindFirst() then begin
            L_WSL.Reset();
            L_WSL.SetRange("No.", L_WSH."No.");
            L_WSL.SetFilter("Bay No.", '<>%1', '');
            if L_WSL.FindFirst() then
                exit(true);
        end;

    end;

    local procedure UpdateLinesInBay(P_OrderNo: Code[20])
    var
        L_DespatchH: Record "Despatch Scan Header";
        WSL: Record "Warehouse Shipment Line";
        WSL2: Record "Warehouse Shipment Line";
        WS: Record "Warehouse Shipment Line";
        v: Record "Warehouse Shipment Header" temporary;
    begin
        if G_Scan <> '' then begin
            if P_OrderNo <> '' then begin
                if CheckOrderScanCompleted(P_OrderNo) = false then begin
                    G_WarehouseShipmentLine.Reset();
                    G_WarehouseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
                    if G_Scan <> '' then
                        G_WarehouseShipmentLine.SetRange("Bay No.", G_Scan);
                    G_WarehouseShipmentLine.SetRange("Dispatch Scan", false);
                    G_WarehouseShipmentLine.SetFilter("Scan Status", '<>%1', G_WarehouseShipmentLine."Scan Status"::Cancelled);
                    G_WarehouseShipmentLine.SetRange("Channel Order ID", P_OrderNo);
                    if G_WarehouseShipmentLine.FindSet() then begin
                        repeat
                            L_DespatchH.Reset();
                            L_DespatchH.SetRange("Trolley No", G_TrolleyNo);
                            L_DespatchH.SetRange("User ID", UserId);
                            if L_DespatchH.FindFirst() then begin
                                Rec."Order No" := G_WarehouseShipmentLine."Channel Order ID";
                                Rec.Modify();
                            end;
                            WS.Reset();
                            WS.SetRange("Trolley No.", G_WarehouseShipmentLine."Trolley No.");
                            WS.SetRange("Channel Order ID", G_WarehouseShipmentLine."Channel Order ID");
                            WS.SetFilter("Scan Status", '<>%1&<>%2', WS."Scan Status"::Cancelled, WS."Scan Status"::Scanned);
                            if WS.FindSet() then begin
                                repeat
                                    WS."User ID" := UserId;

                                    if WS."Scan Status" = WS."Scan Status"::Parked then
                                        WS."Scan Status" := WS."Scan Status"::" ";

                                    if WS.Parked = true then
                                        WS.Parked := false;


                                    if WS."Item No." = G_WarehouseShipmentLine."Item No." then begin
                                        if WS."Qty. Picked" > WS."Scanned Quantity" then begin
                                            CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                            if WS."Bay No." <> '' then
                                                WS.Validate("Scanned Quantity", WS."Qty. Picked")
                                            else
                                                WS.Validate("Scanned Quantity", WS."Scanned Quantity" + 1);
                                            WS.Validate("Scanned By", UserId);
                                            if WS."Qty. Picked" = WS."Scanned Quantity" then begin
                                                WS."Scan Station" := Format(Rec."Entry No.");
                                                WS.Validate("Scan Status", WS."Scan Status"::Scanned);
                                                WS.Validate("Scanned Date", CurrentDateTime);
                                            end;

                                        end else
                                            Error('Item is completely scanned');
                                    end;
                                    WS.Modify();
                                until WS.Next() = 0;
                                CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                CurrPage.Update();
                            end;
                        until G_WarehouseShipmentLine.Next() = 0;
                    end else
                        Error('Scanned Bay does not belong the Order %1', P_OrderNo);
                end else begin
                    G_WarehouseShipmentLine.Reset();
                    G_WarehouseShipmentLine.SetCurrentKey("Channel Order ID");
                    G_WarehouseShipmentLine.SetAscending("Channel Order ID", true);
                    G_WarehouseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
                    if G_Scan <> '' then
                        G_WarehouseShipmentLine.SetRange("Bay No.", G_Scan);
                    G_WarehouseShipmentLine.SetRange("Dispatch Scan", false);
                    G_WarehouseShipmentLine.SetFilter("Scan Status", '<>%1&<>%2', G_WarehouseShipmentLine."Scan Status"::Cancelled, G_WarehouseShipmentLine."Scan Status"::Scanned);
                    if G_WarehouseShipmentLine.FindSet() then begin
                        repeat
                            L_DespatchH.Reset();
                            L_DespatchH.SetRange("Trolley No", G_TrolleyNo);
                            L_DespatchH.SetRange("User ID", UserId);
                            if L_DespatchH.FindFirst() then begin
                                Rec."Order No" := G_WarehouseShipmentLine."Channel Order ID";
                                Rec.Modify();
                            end;
                            WS.Reset();
                            WS.SetRange("Trolley No.", G_WarehouseShipmentLine."Trolley No.");
                            WS.SetRange("Channel Order ID", G_WarehouseShipmentLine."Channel Order ID");
                            WS.SetFilter("Scan Status", '<>%1&<>%2', WS."Scan Status"::Cancelled, WS."Scan Status"::Scanned);
                            if WS.FindSet() then begin
                                repeat
                                    WS."User ID" := UserId;

                                    if WS."Scan Status" = WS."Scan Status"::Parked then
                                        WS."Scan Status" := WS."Scan Status"::" ";

                                    if WS.Parked = true then
                                        WS.Parked := false;


                                    if WS."Item No." = G_WarehouseShipmentLine."Item No." then begin
                                        if WS."Qty. Picked" > WS."Scanned Quantity" then begin
                                            CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                            if WS."Bay No." <> '' then
                                                WS.Validate("Scanned Quantity", WS."Qty. Picked")
                                            else
                                                WS.Validate("Scanned Quantity", WS."Scanned Quantity" + 1);
                                            WS.Validate("Scanned By", UserId);
                                            if WS."Qty. Picked" = WS."Scanned Quantity" then begin
                                                WS."Scan Station" := Format(Rec."Entry No.");
                                                WS.Validate("Scan Status", WS."Scan Status"::Scanned);
                                                WS.Validate("Scanned Date", CurrentDateTime);
                                            end;

                                        end else
                                            Error('Item is completely scanned');
                                    end;
                                    WS.Modify();
                                until WS.Next() = 0;
                                CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                CurrPage.Update();
                            end;

                        until G_WarehouseShipmentLine.Next() = 0;
                    end else
                        Error('Scanned Bay does not belong to the below Order');
                end;
                //Error('Please Post and Print the Order %1', P_OrderNo);
            end else begin
                G_WarehouseShipmentLine.Reset();
                G_WarehouseShipmentLine.SetCurrentKey("Channel Order ID");
                G_WarehouseShipmentLine.SetAscending("Channel Order ID", true);
                G_WarehouseShipmentLine.SetRange("Trolley No.", G_TrolleyNo);
                if G_Scan <> '' then
                    G_WarehouseShipmentLine.SetRange("Bay No.", G_Scan);
                G_WarehouseShipmentLine.SetRange("Dispatch Scan", false);
                G_WarehouseShipmentLine.SetFilter("Scan Status", '<>%1', G_WarehouseShipmentLine."Scan Status"::Cancelled);
                if G_WarehouseShipmentLine.FindSet() then begin
                    repeat
                        L_DespatchH.Reset();
                        L_DespatchH.SetRange("Trolley No", G_TrolleyNo);
                        L_DespatchH.SetRange("User ID", UserId);
                        if L_DespatchH.FindFirst() then begin
                            Rec."Order No" := G_WarehouseShipmentLine."Channel Order ID";
                            Rec.Modify();
                        end;
                        WS.Reset();
                        WS.SetRange("Trolley No.", G_WarehouseShipmentLine."Trolley No.");
                        WS.SetRange("Channel Order ID", G_WarehouseShipmentLine."Channel Order ID");
                        WS.SetFilter("Scan Status", '<>%1', WS."Scan Status"::Cancelled);
                        if WS.FindSet() then begin
                            repeat
                                WS."User ID" := UserId;

                                if WS."Scan Status" = WS."Scan Status"::Parked then
                                    WS."Scan Status" := WS."Scan Status"::" ";

                                if WS.Parked = true then
                                    WS.Parked := false;

                                if WS."Item No." = G_WarehouseShipmentLine."Item No." then begin
                                    if WS."Qty. Picked" > WS."Scanned Quantity" then begin
                                        CurrPage."Despatch Lines".Page.Setfilter(G_TrolleyNo, UserId, WS."Channel Order ID");
                                        if WS."Bay No." <> '' then
                                            WS.Validate("Scanned Quantity", WS."Qty. Picked")
                                        else
                                            WS.Validate("Scanned Quantity", WS."Scanned Quantity" + 1);
                                        WS.Validate("Scanned By", UserId);
                                        if WS."Qty. Picked" = WS."Scanned Quantity" then begin
                                            WS."Scan Station" := Format(Rec."Entry No.");
                                            WS.Validate("Scan Status", WS."Scan Status"::Scanned);
                                            WS.Validate("Scanned Date", CurrentDateTime);
                                        end;

                                    end else
                                        Error('Item is completely scanned');
                                end;
                                WS.Modify();
                            until WS.Next() = 0;

                        end;

                    until G_WarehouseShipmentLine.Next() = 0;
                end else
                    Error('Scanned Bay does not belong to the below Order');
            end;
            Commit();
        end;
    end;
}