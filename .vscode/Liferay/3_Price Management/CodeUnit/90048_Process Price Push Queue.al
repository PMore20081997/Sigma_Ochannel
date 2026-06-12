codeunit 90048 "Process Price Push Queue"
{
    // Job Queue processor — runs every 1–2 minutes.
    // For each pending queue entry it reads the current Price List Line state
    // and updates (or marks inactive) the matching Channel Price record,
    // then sets Sync Price = false so the API push process picks it up.
    //
    // Action::Update  — syncs current Price List Line data into Channel Price
    //                   (inserts if missing, updates if exists).
    // Action::Delete  — marks Channel Price as Inactive + Sync Price = false
    //                   because the source Price List Line was deleted.

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        PushQueue: Record "Price Push Queue";
        SyncAPI: Codeunit "Sync Product/Inv./Cust./Price";
        ProcessedChannels: List of [Code[20]];
        ChannelCode: Code[20];
        L_PushQueue: Record "Price Push Queue";
    begin
        // ── Step 1: Update Channel Price records for each pending entry ───────
        PushQueue.SetRange(Status, PushQueue.Status::Pending);
        PushQueue.SetCurrentKey(Status, "Created At");
        if not PushQueue.FindSet(true) then begin
            //This is in the case where there are no pending entries, but we still want to push any existing records with Sync Price = false to LifeRay.
            if TryPushPrice(SyncAPI, 'LIFERAY') then
                Commit();
            exit;
        end;

        repeat
            L_PushQueue.Reset();
            L_PushQueue.SetRange("Entry No.", PushQueue."Entry No.");
            if L_PushQueue.FindFirst() then begin
                L_PushQueue.Status := L_PushQueue.Status::Processing;
                L_PushQueue.Modify();

                if TryProcessPriceEntry(L_PushQueue) then begin
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

        // ── Step 2: Push all staged price records to LifeRay per channel ─────
        foreach ChannelCode in ProcessedChannels do begin
            if ChannelCode = 'LIFERAY' then begin
                if TryPushPrice(SyncAPI, ChannelCode) then
                    Commit();
            end;
        end;
    end;

    [TryFunction]
    local procedure TryProcessPriceEntry(var _Queue: Record "Price Push Queue")
    var
        ChannelPrice: Record "Channel Price";
        PriceListLine: Record "Price List Line";
        Item: Record Item;
    begin
        case _Queue.Action of
            _Queue.Action::Delete:
                begin
                    // Price List Line was deleted — deactivate the Channel Price entry
                    if ChannelPrice.Get(_Queue."Channel Code", _Queue."Price List Code", _Queue."Line No.") then begin
                        ChannelPrice."Listing Status Setting" := ChannelPrice."Listing Status Setting"::Inactive;
                        ChannelPrice."Sync Price" := false;
                        ChannelPrice.Modify();
                    end;
                end;
            _Queue.Action::Update:
                begin
                    // Read the current live price data
                    PriceListLine.SetRange("Price List Code", _Queue."Price List Code");
                    PriceListLine.SetRange("Line No.", _Queue."Line No.");
                    if not PriceListLine.FindFirst() then
                        exit; // Line was deleted between enqueue and processing — skip

                    if ChannelPrice.Get(_Queue."Channel Code", _Queue."Price List Code", _Queue."Line No.") then begin
                        ChannelPrice.TransferFields(PriceListLine);
                        ChannelPrice."Channel Code" := _Queue."Channel Code";
                        ChannelPrice."Listing Status" := PriceListLine."Listing Status";
                        ChannelPrice."Listing Status Setting" := PriceListLine."Listing Status Setting";
                        ChannelPrice."Base Volume" := PriceListLine."Base Volume";
                        ChannelPrice."Cost Unit Thereafter" := PriceListLine."Cost Unit Thereafter";
                        //ChannelPrice."PIP Code" := PriceListLine."PIP Code";
                        if Item.Get(PriceListLine."Product No.") then
                            ChannelPrice."Item Category Code" := Item."Item Category Code";
                        ChannelPrice."Sync Price" := false;
                        ChannelPrice.Modify();
                    end else begin
                        // New price line not yet in Channel Price — insert it
                        ChannelPrice.Init();
                        ChannelPrice.TransferFields(PriceListLine);
                        ChannelPrice."Channel Code" := _Queue."Channel Code";
                        ChannelPrice."Listing Status" := PriceListLine."Listing Status";
                        ChannelPrice."Listing Status Setting" := PriceListLine."Listing Status Setting";
                        ChannelPrice."Base Volume" := PriceListLine."Base Volume";
                        ChannelPrice."Cost Unit Thereafter" := PriceListLine."Cost Unit Thereafter";
                        //ChannelPrice."PIP Code" := PriceListLine."PIP Code";
                        if Item.Get(PriceListLine."Product No.") then
                            ChannelPrice."Item Category Code" := Item."Item Category Code";
                        ChannelPrice."Sync Price" := false;
                        ChannelPrice.Insert();
                    end;
                end;
        end;
    end;

    [TryFunction]
    local procedure TryPushPrice(var SyncAPI: Codeunit "Sync Product/Inv./Cust./Price"; _ChannelCode: Code[20])
    begin
        // Passing '' and 0 pushes all Sync Price = false records for this channel
        SyncAPI.SyncPriceToLiferay('', 0, _ChannelCode);
    end;
}
