codeunit 90042 "Process Inventory Push Queue"
{
    // Job Queue processor — runs every 1–2 minutes.
    // For each pending queue entry it calculates the NET CHANGE in free inventory
    // since the channel's last sync time (TradePartner."Last Inventory Sync"),
    // stages LifeRay Stock records (Sync Type = Delta), then calls COD 90043
    // SyncDeltaInventoryToLiferay to push to /inventory/delta.
    //
    // LastSyncTime is read and immediately advanced to CurrentDateTime at the
    // start of each run, so transactions that arrive during this run are
    // captured in the next run — no entries are ever missed or double-counted.

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        PushQueue: Record "Inventory Push Queue";
        TradePartner: Record "Trade Partner";
        SyncAPI: Codeunit "Sync Product/Inv./Cust./Price";
        ChannelLastSyncTime: Dictionary of [Code[20], DateTime];
        ProcessedChannels: List of [Code[20]];
        ChannelCode: Code[20];
        LastSyncTime: DateTime;
        L_PushQueue: Record "Inventory Push Queue";
    begin
        // ── Step 0: Capture & advance LastSyncTime per channel ───────────────
        // Done before staging so any transaction arriving during this run is
        // captured in the NEXT delta run, not double-counted in this one.
        PushQueue.SetRange(Status, PushQueue.Status::Pending);
        if PushQueue.FindSet() then
            repeat
                if not ChannelLastSyncTime.ContainsKey(PushQueue."Channel Code") then
                    if TradePartner.Get(PushQueue."Channel Code") then begin
                        ChannelLastSyncTime.Add(PushQueue."Channel Code", TradePartner."Last Inventory Sync");
                        TradePartner."Last Inventory Sync" := CurrentDateTime;
                        TradePartner.Modify();
                    end;
            until PushQueue.Next() = 0;

        // ── Step 1: Stage delta inventory for each pending item ──────────────
        PushQueue.Reset();
        PushQueue.SetRange(Status, PushQueue.Status::Pending);
        PushQueue.SetCurrentKey(Status, "Created At");
        if not PushQueue.FindSet(true) then begin
            //This is in the case where there are no pending entries, but we still want to push any existing records with Sync = false to LifeRay.
            if TryPushDelta(SyncAPI, 'LIFERAY') then
                Commit();
            exit;
        end;


        repeat
            L_PushQueue.Reset();
            L_PushQueue.SetRange("Entry No.", PushQueue."Entry No.");
            if L_PushQueue.FindFirst() then begin
                L_PushQueue.Status := L_PushQueue.Status::Processing;
                L_PushQueue.Modify();

                if not ChannelLastSyncTime.Get(L_PushQueue."Channel Code", LastSyncTime) then
                    Clear(LastSyncTime);

                if TryStageItemInventory(L_PushQueue."Item No.", L_PushQueue."Channel Code", LastSyncTime) then begin
                    L_PushQueue.Status := L_PushQueue.Status::Done;
                    L_PushQueue."Error Message" := '';
                    if not ProcessedChannels.Contains(L_PushQueue."Channel Code") then
                        ProcessedChannels.Add(L_PushQueue."Channel Code");
                end else begin
                    L_PushQueue.Status := L_PushQueue.Status::Failed;
                    L_PushQueue."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
                end;
                L_PushQueue.Modify();
            end;
        until PushQueue.Next() = 0;

        // ── Step 2: Push all staged Delta records to LifeRay per channel ─────
        foreach ChannelCode in ProcessedChannels do begin
            if ChannelCode = 'LIFERAY' then
                if not TryPushDelta(SyncAPI, ChannelCode) then
                    Commit();
        end;
    end;

    // ─────────────────────────────────────────────────────────────────────────
    // Calculates NET CHANGE in free inventory for _ItemNo since _LastSyncTime
    // across all Liferay locations + variants, then stages LifeRay Stock
    // records (Sync Type = Delta, Sync = false) for COD 90043 to push.
    // Only records where the net change <> 0 are inserted.
    // ─────────────────────────────────────────────────────────────────────────
    [TryFunction]
    local procedure TryStageItemInventory(_ItemNo: Code[20]; _ChannelCode: Code[20]; _LastSyncTime: DateTime)
    var
        ChannelItemListing: Record "Channel Item Listing";
        Location: Record Location;
        ItemVariant: Record "Item Variant";
        InterimSalesLine: Record "Interim Sales Line";
        LastEntry: Record "LifeRay Stock";
        NextEntryNo: Integer;
        WebOrderQty: Decimal;
        TotalInventory: Decimal;
        AllocOnSO: Decimal;
        AllocOnPick: Decimal;
        KNAPPQty: Decimal;
        TotalFree: Decimal;
        AssignToWebOrder: Decimal;
        L_LifeRayStock: Record "LifeRay Stock";
        L_IsSaleable: Boolean;
    begin
        // Verify item is marked for sync on this channel — if not, skip processing (but still mark queue entry as Done so it doesn't block the queue)
        ChannelItemListing.SetRange("Item No.", _ItemNo);
        ChannelItemListing.SetRange("Channel Code", _ChannelCode);
        ChannelItemListing.SetRange("Item Sync", true);
        if not ChannelItemListing.FindFirst() then
            exit;

        //If any full sync record exists for this item/channel and is not yet synced, skip delta processing (wait for full sync to run)
        L_LifeRayStock.Reset();
        L_LifeRayStock.SetRange("Created On", WorkDate());
        L_LifeRayStock.SetRange("Channel Code", _ChannelCode);
        L_LifeRayStock.SetRange("Item No.", _ItemNo);
        L_LifeRayStock.SetRange("Sync Type", L_LifeRayStock."Sync Type"::Full);
        L_LifeRayStock.SetRange(Sync, false);
        if L_LifeRayStock.FindFirst() then
            exit;

        //Get Last Entry No.++
        LastEntry.Reset();
        if LastEntry.FindLast() then
            NextEntryNo := LastEntry."Entry No." + 1
        else
            NextEntryNo := 1;

        // ── For each location (with positive ranking) ─────────────────────────────
        Location.SetFilter("Liferay Location Ranking", '>%1', 0);
        Location.SetCurrentKey("Liferay Location Ranking");
        Location.Ascending(true);
        if not Location.FindSet() then
            exit;

        repeat
            //Check if the location is saleable+++
            Clear(L_IsSaleable);
            L_IsSaleable := Location."Saleable Location";


            // ── Web Order qty for DEPOT1 — time-filtered (same as COD 90041 Delta) ──
            Clear(WebOrderQty);
            if Location.Code = 'DEPOT1' then begin
                InterimSalesLine.Reset();
                InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
                InterimSalesLine.SetRange(Type, InterimSalesLine.Type::Item);
                InterimSalesLine.SetRange("No.", _ItemNo);
                InterimSalesLine.SetRange("Sales Order Created", false);
                InterimSalesLine.SetRange("Consolidated Order", false);
                InterimSalesLine.SetFilter("Trade Partner Code", '<>%1', 'LIFERAY');
                InterimSalesLine.SetFilter("Reason Code", '%1|%2', UpperCase('Order line created'), UpperCase('Partial Quantity Delivered'));
                InterimSalesLine.SetFilter(SystemCreatedAt, '>%1', _LastSyncTime);
                InterimSalesLine.CalcSums("Qty. to Deliver");
                WebOrderQty := InterimSalesLine."Qty. to Deliver";
            end;

            //Check the new Transaction & new entry after last synctime and get the TotalInventory, AllocOnSO, AllocOnPick++
            CalcDeltaInventory(_ItemNo, '', Location.Code, _LastSyncTime, TotalInventory, AllocOnSO, AllocOnPick);

            //Check KNAPP allocated qty if location is DEPOT1 after last synctime++
            KNAPPQty := 0;
            if Location.Code = 'DEPOT1' then
                KNAPPQty := GetKNAPPDelta(_ItemNo, ItemVariant.Code, _LastSyncTime);

            // Calculate free inventory delta since last sync (can be negative if net transactions reduce free inventory)
            TotalFree := TotalInventory - AllocOnSO - AllocOnPick - KNAPPQty - WebOrderQty;

            //Insert Delta Record In the table++
            InsertDeltaRecord(NextEntryNo, _ChannelCode, ChannelItemListing, '', '', 0, Location.Code, TotalInventory, AllocOnSO, AllocOnPick, KNAPPQty, WebOrderQty, WebOrderQty, TotalFree);
        until Location.Next() = 0;

        //++
        Commit();
    end;

    // ─────────────────────────────────────────────────────────────────────────
    // Calculates three delta components for one item/variant/location,
    // considering only records created AFTER _LastSyncTime.
    // Values can be negative (net issue > net receipt since last sync).
    // ─────────────────────────────────────────────────────────────────────────
    local procedure CalcDeltaInventory(_ItemNo: Code[20]; _VariantCode: Code[20]; _LocationCode: Code[20]; _LastSyncTime: DateTime; var TotalInventory: Decimal; var AllocOnSO: Decimal; var AllocOnPick: Decimal)
    var
        ILE: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        WHActivityLine: Record "Warehouse Activity Line";
    begin
        // ── Net ILE movement since last sync ──────────────────────────────────
        ILE.SetRange("Item No.", _ItemNo);
        ILE.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            ILE.SetRange("Variant Code", _VariantCode);
        ILE.SetFilter(SystemCreatedAt, '>%1', _LastSyncTime);
        ILE.CalcSums(Quantity);
        TotalInventory := ILE.Quantity;

        // ── New Sales Order allocations since last sync ───────────────────────
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", _ItemNo);
        SalesLine.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            SalesLine.SetRange("Variant Code", _VariantCode);
        SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        SalesLine.SetFilter("SystemCreatedAt", '>%1', _LastSyncTime);
        SalesLine.CalcSums("Outstanding Qty. (Base)");
        AllocOnSO := SalesLine."Outstanding Qty. (Base)";
        if AllocOnSO < 0 then
            AllocOnSO := 0;

        // ── New Pick allocations since last sync ──────────────────────────────
        WHActivityLine.SetRange("Item No.", _ItemNo);
        WHActivityLine.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            WHActivityLine.SetRange("Variant Code", _VariantCode);
        WHActivityLine.SetRange("Source Document", WHActivityLine."Source Document"::"Sales Order");
        WHActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
        WHActivityLine.SetFilter("SystemCreatedAt", '>%1', _LastSyncTime);
        WHActivityLine.CalcSums("Qty. Outstanding (Base)");
        AllocOnPick := WHActivityLine."Qty. Outstanding (Base)";
        if AllocOnPick < 0 then
            AllocOnPick := 0;
    end;

    // ─────────────────────────────────────────────────────────────────────────
    // Returns KNAPP-allocated qty delta since _LastSyncTime
    // (mirrors COD 90041 Delta_GetKNAPPQTY).
    // ─────────────────────────────────────────────────────────────────────────
    local procedure GetKNAPPDelta(_ItemNo: Code[20]; _VariantCode: Code[20]; _LastSyncTime: DateTime): Decimal
    var
        Location: Record Location;
        ILE: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        KNAPPFilter: Text;
        TotalInventory: Decimal;
        AllocOnSO: Decimal;
    begin
        Location.SetRange("Knapp Location", true);
        if not Location.FindSet() then
            exit(0);
        repeat
            if KNAPPFilter <> '' then
                KNAPPFilter += '|' + Location.Code
            else
                KNAPPFilter := Location.Code;
        until Location.Next() = 0;
        if KNAPPFilter = '' then
            exit(0);

        ILE.SetRange("Item No.", _ItemNo);
        if _VariantCode <> '' then
            ILE.SetRange("Variant Code", _VariantCode);
        ILE.SetFilter("Location Code", KNAPPFilter);
        ILE.SetFilter(SystemCreatedAt, '>%1', _LastSyncTime);
        ILE.CalcSums(Quantity);
        TotalInventory := ILE.Quantity;
        if TotalInventory < 0 then TotalInventory := 0;

        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", _ItemNo);
        if _VariantCode <> '' then
            SalesLine.SetRange("Variant Code", _VariantCode);
        SalesLine.SetFilter("Location Code", KNAPPFilter);
        SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        SalesLine.SetFilter("SystemCreatedAt", '>%1', _LastSyncTime);
        SalesLine.CalcSums("Outstanding Qty. (Base)");
        AllocOnSO := SalesLine."Outstanding Qty. (Base)";
        if AllocOnSO < 0 then AllocOnSO := 0;

        exit(Abs(TotalInventory) + AllocOnSO);
    end;

    local procedure AllocateWebOrder(_LocationCode: Code[20]; _CurrentFreeQty: Decimal;
        var TotalFree: Decimal; var RemainingWebOrderQty: Decimal; var AssignToWebOrder: Decimal)
    begin
        // _CurrentFreeQty = current available stock for this variant (the cap).
        // TotalFree       = delta value — reduced by however much is assigned.
        Clear(AssignToWebOrder);
        if (_LocationCode <> 'DEPOT1') or (RemainingWebOrderQty <= 0) or (_CurrentFreeQty <= 0) then
            exit;
        if _CurrentFreeQty >= RemainingWebOrderQty then begin
            AssignToWebOrder := RemainingWebOrderQty;
            RemainingWebOrderQty := 0;
        end else begin
            AssignToWebOrder := _CurrentFreeQty;
            RemainingWebOrderQty -= AssignToWebOrder;
        end;
        TotalFree -= AssignToWebOrder;
    end;

    // ─────────────────────────────────────────────────────────────────────────
    // Returns CURRENT available free inventory for one variant/location
    // (no time filter — mirrors COD 90041 Full calculation).
    // Used exclusively to correctly cap web order distribution across variants.
    // ─────────────────────────────────────────────────────────────────────────
    local procedure GetCurrentFreeQty(_ItemNo: Code[20]; _VariantCode: Code[20]; _LocationCode: Code[20]; _LastSyncTime: DateTime): Decimal
    var
        ILE: Record "Item Ledger Entry";
        L_Location: Record Location;
        L_SaleableLocation: Boolean;
        SalesLine: Record "Sales Line";
        WHActivityLine: Record "Warehouse Activity Line";
        BinContent: Record "Bin Content";
        TotalInventory: Decimal;
        AllocOnSO: Decimal;
        AllocOnPick: Decimal;
        ExcludedQty: Decimal;
        TotalFree: Decimal;
        InterimSalesLine: Record "Interim Sales Line";
        WebOrderQty: Decimal;
    begin
        //Check if location is saleable
        Clear(L_SaleableLocation);
        L_Location.Reset();
        L_Location.SetRange(Code, _LocationCode);
        if L_Location.FindFirst() then
            if L_Location."Saleable Location" = true then
                L_SaleableLocation := true;

        // ── Net ILE movement before  last sync ──────────────────────────────────
        TotalInventory := 0;
        ILE.Reset();
        ILE.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation then
            ILE.SetRange("Saleable Location", true)
        else
            ILE.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            ILE.SetRange("Variant Code", _VariantCode);
        ILE.SetFilter(SystemCreatedAt, '<%1', _LastSyncTime);
        ILE.CalcSums(Quantity);
        TotalInventory := ILE.Quantity;
        if TotalInventory < 0 then TotalInventory := 0;

        // ── New Sales Order allocations before last sync ───────────────────────
        AllocOnSO := 0;
        SalesLine.Reset();
        SalesLine.ReservEntryExist();
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", _ItemNo);
        if L_SaleableLocation then
            SalesLine.SetRange("Saleable Location", true)
        else
            SalesLine.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            SalesLine.SetRange("Variant Code", _VariantCode);
        SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        SalesLine.SetFilter("SystemCreatedAt", '<%1', _LastSyncTime);
        SalesLine.CalcSums("Outstanding Qty. (Base)");
        AllocOnSO := SalesLine."Outstanding Qty. (Base)";
        if AllocOnSO < 0 then AllocOnSO := 0;

        // ── New Pick allocations since last sync ──────────────────────────────
        AllocOnPick := 0;
        WHActivityLine.Reset();
        WHActivityLine.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation then
            WHActivityLine.SetRange("Saleable Location", true)
        else
            WHActivityLine.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            WHActivityLine.SetRange("Variant Code", _VariantCode);
        WHActivityLine.SetRange("Source Document", WHActivityLine."Source Document"::"Sales Order");
        WHActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
        WHActivityLine.SetFilter("SystemCreatedAt", '<%1', _LastSyncTime);
        WHActivityLine.CalcSums("Qty. Outstanding (Base)");
        AllocOnPick := WHActivityLine."Qty. Outstanding (Base)";
        if AllocOnPick < 0 then AllocOnPick := 0;

        // Excluded bin qty
        ExcludedQty := 0;
        BinContent.Reset();
        BinContent.SetRange("Item No.", _ItemNo);
        BinContent.SetRange("Location Code", _LocationCode);
        if _VariantCode <> '' then
            BinContent.SetRange("Variant Code", _VariantCode);
        BinContent.SetRange("Exclude from free Qty.", true);
        BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        if BinContent.FindSet() then
            repeat
                BinContent.CalcFields("Quantity (Base)");
                ExcludedQty += BinContent."Quantity (Base)";
            until BinContent.Next() = 0;
        if ExcludedQty < 0 then ExcludedQty := 0;

        //Web Order Qty++
        WebOrderQty := 0;
        InterimSalesLine.Reset();
        InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
        InterimSalesLine.SetRange(Type, InterimSalesLine.Type::Item);
        InterimSalesLine.SetRange("No.", _ItemNo);
        InterimSalesLine.SetRange("Sales Order Created", false);
        InterimSalesLine.SetRange("Consolidated Order", false);
        InterimSalesLine.SetFilter("Trade Partner Code", '<>%1', 'LIFERAY');
        InterimSalesLine.SetFilter("Reason Code", '%1|%2', UpperCase('Order line created'), UpperCase('Partial Quantity Delivered'));
        InterimSalesLine.SetFilter(SystemCreatedAt, '<%1', _LastSyncTime);
        InterimSalesLine.CalcSums("Qty. to Deliver");
        WebOrderQty := InterimSalesLine."Qty. to Deliver";
        if WebOrderQty < 0 then WebOrderQty := 0;

        TotalFree := TotalInventory - AllocOnSO - AllocOnPick - ExcludedQty - WebOrderQty;
        if TotalFree < 0 then TotalFree := 0;
        exit(TotalFree);
    end;

    // ─────────────────────────────────────────────────────────────────────────
    // Returns current KNAPP-allocated qty for DEPOT1
    // (mirrors COD 90041 Full_GetKNAPPQTY — no time filter).
    // ─────────────────────────────────────────────────────────────────────────
    local procedure InsertDeltaRecord(
        var _EntryNo: Integer; _ChannelCode: Code[20];
        var _CIL: Record "Channel Item Listing";
        _VariantCode: Code[20]; _VariantDesc: Text[100]; _VariantPriority: Integer;
        _LocationCode: Code[20]; _TotalQty: Decimal; _AllocSO: Decimal;
        _AllocPick: Decimal; _KNAPP: Decimal;
        _WebOrderQty: Decimal; _AllocWebOrder: Decimal; _FreeQty: Decimal)
    var
        LifeRayStock: Record "LifeRay Stock";
    begin
        // Zero delta means no change since last sync — nothing to push
        if _FreeQty = 0 then
            exit;

        LifeRayStock.Init();
        LifeRayStock."Entry No." := _EntryNo;
        LifeRayStock."Channel Code" := _ChannelCode;
        LifeRayStock."Item No." := _CIL."Item No.";
        LifeRayStock."Item Description" := _CIL.Description;
        LifeRayStock."Variant Code" := _VariantCode;
        LifeRayStock."Variant Description" := _VariantDesc;
        LifeRayStock."Variant Priority" := _VariantPriority;
        LifeRayStock."Location Code" := _LocationCode;
        LifeRayStock."Total Quantity" := _TotalQty;
        LifeRayStock."Allocated On SO" := _AllocSO;
        LifeRayStock."Allocated On Pick" := _AllocPick;
        LifeRayStock."Allocated for KNAPP" := _KNAPP;
        LifeRayStock."Total Web Order Qty" := _WebOrderQty;
        LifeRayStock."Allocated On WebOrder" := _AllocWebOrder;
        LifeRayStock.Inventory := _FreeQty;
        LifeRayStock."Created On" := WorkDate();
        LifeRayStock."Sync Type" := LifeRayStock."Sync Type"::Delta;
        LifeRayStock.Sync := false;
        LifeRayStock.Insert();
        _EntryNo += 1;
    end;

    [TryFunction]
    local procedure TryPushDelta(var SyncAPI: Codeunit "Sync Product/Inv./Cust./Price"; _ChannelCode: Code[20])
    begin
        SyncAPI.SyncDeltaInventoryToLiferay(0, _ChannelCode);
    end;
}
