codeunit 90046 "Inventory Change Subscriber"
{
    Permissions = TableData "Channel Item Listing" = RMDI, TableData "Inventory Push Queue" = RMDI;
    // Subscribes to inventory-affecting events and inserts one queue entry per
    // Item+Channel combination. The actual recalculation and API push happens
    // in COD 90048 (Job Queue), safely outside the posting transaction.

    // ─── Item Ledger Entry ───────────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Item Ledger Entry", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterILEInsert(var Rec: Record "Item Ledger Entry"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        EnqueueItemChannels(Rec."Item No.", 'ILE');
    end;

    // ─── Sales Order Lines ───────────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterSalesLineInsert(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        EnqueueItemChannels(Rec."No.", 'Sales Order');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterSalesLineModify(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        // Only re-queue if something inventory-relevant actually changed
        if (Rec."Outstanding Qty. (Base)" <> xRec."Outstanding Qty. (Base)") or
           (Rec."Location Code" <> xRec."Location Code") then
            EnqueueItemChannels(Rec."No.", 'Sales Order');
    end;

    //Not Required for Now - 22/05/2026++++
    // // ─── Warehouse Activity Lines (Inventory Picks) ──────────────────────────
    // [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", OnAfterInsertEvent, '', false, false)]
    // local procedure OnAfterWHActivityLineInsert(var Rec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    // begin
    //     if Rec.IsTemporary then
    //         exit;
    //     if Rec."Item No." = '' then
    //         exit;
    //     EnqueueItemChannels(Rec."Item No.", 'Inventory Pick');
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", OnAfterModifyEvent, '', false, false)]
    // local procedure OnAfterWHActivityLineModify(var Rec: Record "Warehouse Activity Line"; var xRec: Record "Warehouse Activity Line"; RunTrigger: Boolean)
    // begin
    //     if Rec.IsTemporary then
    //         exit;
    //     if Rec."Item No." = '' then
    //         exit;
    //     if Rec."Qty. Outstanding (Base)" <> xRec."Qty. Outstanding (Base)" then
    //         EnqueueItemChannels(Rec."Item No.", 'Inventory Pick');
    // end;
    //Not Required for Now - 22/05/2026++++

    // ─── Web Orders (Interim Sales Lines) ───────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Interim Sales Line", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInterimSalesLineInsert(var Rec: Record "Interim Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        if Rec."No." = '' then
            exit;
        EnqueueItemChannels(Rec."No.", 'Web Order');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Interim Sales Line", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterInterimSalesLineModify(var Rec: Record "Interim Sales Line"; var xRec: Record "Interim Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        if Rec."Qty. to Deliver" <> xRec."Qty. to Deliver" then
            EnqueueItemChannels(Rec."No.", 'Web Order');
    end;

    // ─── Queue insertion (shared logic) ─────────────────────────────────────
    local procedure EnqueueItemChannels(_ItemNo: Code[20]; _Source: Text[50])
    var
        ChannelItemListing: Record "Channel Item Listing";
        TradePartner: Record "Trade Partner";
        PushQueue: Record "Inventory Push Queue";
    begin
        // Only queue for channels where this item is actively listed
        ChannelItemListing.SetRange("Item No.", _ItemNo);
        ChannelItemListing.SetRange("Item Sync", true);
        ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
        if not ChannelItemListing.FindSet() then
            exit;

        repeat
            if TradePartner.Get(ChannelItemListing."Channel Code") then
                if TradePartner.SyncInventory then begin
                    // Deduplication: one Pending entry per Item+Channel is enough.
                    // If one already exists, the processor will pick it up and recalculate
                    // at that point — multiple events in quick succession collapse into one push.
                    PushQueue.SetRange("Channel Code", ChannelItemListing."Channel Code");
                    PushQueue.SetRange("Item No.", _ItemNo);
                    PushQueue.SetRange(Status, PushQueue.Status::Pending);
                    if PushQueue.IsEmpty() then begin
                        PushQueue.Init();
                        PushQueue."Channel Code" := ChannelItemListing."Channel Code";
                        PushQueue."Item No." := _ItemNo;
                        PushQueue."Created At" := CurrentDateTime;
                        PushQueue.Status := PushQueue.Status::Pending;
                        PushQueue."Trigger Source" := _Source;
                        PushQueue."Created On" := WorkDate();
                        PushQueue.Insert();
                    end;
                end;
        until ChannelItemListing.Next() = 0;
    end;
}