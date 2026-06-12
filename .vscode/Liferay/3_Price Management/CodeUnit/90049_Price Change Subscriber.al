codeunit 90049 "Price Change Subscriber"
{
    Permissions = TableData "Price Push Queue" = RMDI;
    // Subscribes to Price List Line changes and inserts one queue entry per
    // Line+Channel combination. The actual Channel Price update happens in
    // COD 90045 (Job Queue), safely outside the modification transaction.

    // ─── Price List Line Insert ──────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterPriceLineInsert(var Rec: Record "Price List Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Source Group" <> Rec."Source Group"::Customer then
            exit;
        if Rec."Price Type" <> Rec."Price Type"::Sale then
            exit;
        EnqueuePriceChannels(Rec, 0, 'Insert', false); // Action::Update, always enqueue
    end;

    // ─── Price List Line Modify ──────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterPriceLineModify(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Source Group" <> Rec."Source Group"::Customer then
            exit;
        if Rec."Price Type" <> Rec."Price Type"::Sale then
            exit;
        // xRec is unreliable in table event subscribers — compare against
        // Channel Price (the last-synced snapshot) instead of xRec
        EnqueuePriceChannels(Rec, 0, 'Modify', true); // Action::Update, check for changes
    end;

    // ─── Price List Line Delete ──────────────────────────────────────────────
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterDeleteEvent, '', false, false)]
    local procedure OnAfterPriceLineDelete(var Rec: Record "Price List Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Source Group" <> Rec."Source Group"::Customer then
            exit;
        if Rec."Price Type" <> Rec."Price Type"::Sale then
            exit;
        EnqueuePriceChannels(Rec, 1, 'Delete', false); // Action::Delete, always enqueue
    end;

    // ─── Queue insertion (shared logic) ─────────────────────────────────────
    local procedure EnqueuePriceChannels(_PriceLine: Record "Price List Line"; _Action: Integer; _Source: Text[50]; _OnlyIfChanged: Boolean)
    var
        TradePartner: Record "Trade Partner";
        PushQueue: Record "Price Push Queue";
    begin
        TradePartner.SetRange(SyncPrice, true);
        if not TradePartner.FindSet() then
            exit;

        repeat
            if IsPriceLineForChannel(_PriceLine, TradePartner.Code) then
                if (not _OnlyIfChanged) or HasPriceChanged(_PriceLine, TradePartner.Code) then begin
                    // Deduplication: one Pending entry per Line+Channel is enough.
                    // If a Delete action arrives while an Update is pending, upgrade it.
                    PushQueue.SetRange("Channel Code", TradePartner.Code);
                    PushQueue.SetRange("Price List Code", _PriceLine."Price List Code");
                    PushQueue.SetRange("Line No.", _PriceLine."Line No.");
                    PushQueue.SetRange(Status, PushQueue.Status::Pending);
                    if PushQueue.FindFirst() then begin
                        // Upgrade pending Update to Delete — deletion wins
                        if (_Action = 1) and (PushQueue.Action <> 1) then begin
                            PushQueue.Action := 1;
                            PushQueue."Trigger Source" := _Source;
                            PushQueue.Modify();
                        end;
                    end else begin
                        PushQueue.Init();
                        PushQueue."Channel Code" := TradePartner.Code;
                        PushQueue."Price List Code" := _PriceLine."Price List Code";
                        PushQueue."Line No." := _PriceLine."Line No.";
                        PushQueue."Created At" := CurrentDateTime;
                        PushQueue.Status := PushQueue.Status::Pending;
                        PushQueue."Trigger Source" := _Source;
                        PushQueue."Created On" := WorkDate();
                        PushQueue.Action := _Action;
                        PushQueue.Insert();
                    end;
                end;
        until TradePartner.Next() = 0;
    end;

    // Returns true if Price List Line differs from the stored Channel Price snapshot.
    // If no Channel Price exists yet, treat it as changed so it gets enqueued.
    local procedure HasPriceChanged(_PriceLine: Record "Price List Line"; _ChannelCode: Code[20]): Boolean
    var
        ChannelPrice: Record "Channel Price";
    begin
        if not ChannelPrice.Get(_ChannelCode, _PriceLine."Price List Code", _PriceLine."Line No.") then
            exit(true); // No snapshot yet — always enqueue

        exit(
            (_PriceLine."Unit Price" <> ChannelPrice."Unit Price") or
            (_PriceLine."Variant Code" <> ChannelPrice."Variant Code") or
            (_PriceLine."Unit of Measure Code" <> ChannelPrice."Unit of Measure Code") or
            (_PriceLine."Starting Date" <> ChannelPrice."Starting Date") or
            (_PriceLine."Ending Date" <> ChannelPrice."Ending Date") or
            (_PriceLine."Minimum Quantity" <> ChannelPrice."Minimum Quantity") or
            (_PriceLine."Listing Status Setting" <> ChannelPrice."Listing Status Setting") or
            (_PriceLine."Base Volume" <> ChannelPrice."Base Volume") or
            (_PriceLine."Cost Unit Thereafter" <> ChannelPrice."Cost Unit Thereafter")
        );
    end;

    local procedure IsPriceLineForChannel(_PriceLine: Record "Price List Line"; _ChannelCode: Code[20]): Boolean
    begin
        //Note - for now we have only two cahnnel.
        _PriceLine.CalcFields("Master LifeRay", "Master DC");
        case _ChannelCode of
            'LIFERAY':
                exit(_PriceLine."Master LifeRay");
            'DC':
                exit(_PriceLine."Master DC");
        end;
        exit(false);
    end;
}
