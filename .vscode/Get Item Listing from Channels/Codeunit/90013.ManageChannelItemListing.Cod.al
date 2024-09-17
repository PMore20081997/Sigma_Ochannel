codeunit 90013 "Manage Channel Item Listing"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    Procedure CreateChannelItemListingForMultipleSelection(VAR P_Item: Record Item)
    var
        SelectTradePartner: FilterPageBuilder;
        TradePartner: Record "Trade Partner";
        VarDefaultVeiw: Text;
        TradePartner2: Record "Trade Partner";
        ChannelItemListing: Record "Channel Item Listing";
        L_Variant: Record "Item Variant";
        L_Item: Record Item;
    begin
        TradePartner.RESET;
        TradePartner.SETRANGE("Partner Type", TradePartner."Partner Type"::Channel);
        IF TradePartner.FINDSET THEN BEGIN
            VarDefaultVeiw := TradePartner.GETVIEW;
            SelectTradePartner.ADDTABLE('Trade Partner', DATABASE::"Trade Partner");
            SelectTradePartner.SETVIEW('Trade Partner', VarDefaultVeiw);
            SelectTradePartner.ADDFIELD('Trade Partner', TradePartner.Code, '');
            IF SelectTradePartner.RUNMODAL = TRUE THEN BEGIN
            END;
            TradePartner2.SETVIEW(SelectTradePartner.GETVIEW('Trade Partner'));
            IF TradePartner2.GETFILTER(Code) = '' THEN
                EXIT;
            IF TradePartner2.FINDFIRST THEN
                REPEAT
                    IF P_Item.FINDFIRST THEN
                        REPEAT
                            L_Variant.Reset();
                            L_Variant.SetRange("Item No.", P_Item."No.");
                            if L_Variant.FindSet() then begin
                                repeat
                                    ChannelItemListing.RESET;
                                    ChannelItemListing.SETRANGE("Channel Code", TradePartner2.Code);
                                    if TradePartner2.Code = 'SIGCONNECT' then
                                        ChannelItemListing.SETRANGE("Channel SKU", L_Variant."Item No.")
                                    else
                                        ChannelItemListing.SETRANGE("Channel SKU", L_Variant."Item No." + L_Variant.Code);
                                    ChannelItemListing.SetRange("NAV Variant", L_Variant.Code);
                                    IF ChannelItemListing.FINDFIRST THEN BEGIN
                                        ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                        ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                        ChannelItemListing.Validate("NAV Variant", L_Variant.Code);
                                        if TradePartner2.Code = 'SIGCONNECT' then
                                            ChannelItemListing.Validate("Channel SKU", L_Variant."Item No.")
                                        else
                                            ChannelItemListing.Validate("Channel SKU", L_Variant."Item No." + L_Variant.Code);
                                        ChannelItemListing.Validate("Channel Variant", L_Variant.Code);
                                        ChannelItemListing.Validate("Pack Size", P_Item."Pack Size");

                                        //Update Invetory++
                                        //For Sigma Channel Inventory := BC Inventory++
                                        L_Item.Reset();
                                        L_Item.SetRange("No.", P_Item."No.");
                                        L_Item.SetRange("Variant Filter", L_Variant.Code);
                                        if L_Item.FindFirst() then begin
                                            L_Item.CalcFields(Inventory);
                                            ChannelItemListing.Validate("Channel Inventory", L_Item.Inventory);
                                        end;

                                        ChannelItemListing.MODIFY(TRUE);
                                    END
                                    ELSE BEGIN
                                        ChannelItemListing.INIT;
                                        ChannelItemListing.VALIDATE("Channel Code", TradePartner2.Code);
                                        ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                        ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                        ChannelItemListing.Validate("NAV Variant", L_Variant.Code);
                                        if TradePartner2.Code = 'SIGCONNECT' then
                                            ChannelItemListing.Validate("Channel SKU", L_Variant."Item No.")
                                        else
                                            ChannelItemListing.Validate("Channel SKU", L_Variant."Item No." + L_Variant.Code);
                                        ChannelItemListing.Validate("Channel Variant", L_Variant.Code);
                                        ChannelItemListing.Validate("Pack Size", P_Item."Pack Size");
                                        //Update Invetory++
                                        //For Sigma Channel Inventory := BC Inventory++
                                        L_Item.Reset();
                                        L_Item.SetRange("No.", P_Item."No.");
                                        L_Item.SetRange("Variant Filter", L_Variant.Code);
                                        if L_Item.FindFirst() then begin
                                            L_Item.CalcFields(Inventory);
                                            ChannelItemListing.Validate("Channel Inventory", L_Item.Inventory);
                                        end;
                                        ChannelItemListing.Status := ChannelItemListing.Status::Active;
                                        ChannelItemListing.INSERT;
                                    END;
                                until L_Variant.Next() = 0;
                            end else begin
                                ChannelItemListing.RESET;
                                ChannelItemListing.SETRANGE("Channel Code", TradePartner2.Code);
                                ChannelItemListing.SETRANGE("Channel SKU", P_Item."No.");
                                IF ChannelItemListing.FINDFIRST THEN BEGIN
                                    ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                    ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                    ChannelItemListing.Validate("Pack Size", P_Item."Pack Size");

                                    P_Item.CalcFields(Inventory);
                                    ChannelItemListing.Validate("Channel Inventory", P_Item.Inventory);
                                    ChannelItemListing.MODIFY(TRUE);
                                END
                                ELSE BEGIN
                                    ChannelItemListing.INIT;
                                    ChannelItemListing.VALIDATE("Channel Code", TradePartner2.Code);
                                    ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                    ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                    ChannelItemListing.Validate("Channel SKU", P_Item."No.");
                                    ChannelItemListing.Validate("Pack Size", P_Item."Pack Size");
                                    P_Item.CalcFields(Inventory);
                                    ChannelItemListing.Validate("Channel Inventory", P_Item.Inventory);
                                    ChannelItemListing.Status := ChannelItemListing.Status::Active;
                                    ChannelItemListing.INSERT;
                                END;
                            end;

                        UNTIL P_Item.NEXT = 0;
                UNTIL TradePartner2.NEXT = 0;
            MESSAGE('Items added in channel item listing successfully.');
        END;
    end;

    Procedure SigmaCreateChannelItemListingForMultipleSelection(VAR P_Item: Record Item)
    var
        SelectTradePartner: FilterPageBuilder;
        TradePartner: Record "Trade Partner";
        VarDefaultVeiw: Text;
        TradePartner2: Record "Trade Partner";
        ChannelItemListing: Record "Channel Item Listing";
        L_Variant: Record "Item Variant";
        L_Item: Record Item;
        PhysicalInventory: Decimal;
        QtyOnSO: Decimal;
        QtyonWebOrder: Decimal;
        AvailableInventory: Decimal;
    begin
        TradePartner.Reset();
        TradePartner.SetRange("Partner Type", TradePartner."Partner Type"::Channel);
        IF TradePartner.FindSet() THEN BEGIN
            VarDefaultVeiw := TradePartner.GetView();
            SelectTradePartner.AddTable('Trade Partner', DATABASE::"Trade Partner");
            SelectTradePartner.SetView('Trade Partner', VarDefaultVeiw);
            SelectTradePartner.AddField('Trade Partner', TradePartner.Code, '');
            IF SelectTradePartner.RunModal = true then begin
            end;
            TradePartner2.SetView(SelectTradePartner.GetView('Trade Partner'));
            IF TradePartner2.GetFilter(Code) = '' then
                exit;
            IF TradePartner2.FindFirst() then
                repeat
                    IF P_Item.FindFirst() then
                        repeat
                            ChannelItemListing.Reset();
                            ChannelItemListing.SetRange("Channel Code", TradePartner2.Code);
                            ChannelItemListing.SetRange("Channel SKU", P_Item."No.");
                            IF ChannelItemListing.FindFirst THEN BEGIN
                                ChannelItemListing.Validate("Item No.", P_Item."No.");
                                ChannelItemListing.Validate("Channel Title", P_Item.Description);
                                ChannelItemListing.Validate("Pack Size", P_Item."Pack Size");

                                Clear(PhysicalInventory);
                                Clear(QtyOnSO);
                                Clear(QtyonWebOrder);
                                L_Variant.Reset();
                                L_Variant.SetRange("Item No.", P_Item."No.");
                                L_Variant.SetRange(Blocked, false);
                                L_Variant.SetRange("Sales Blocked", false);
                                L_Variant.SetFilter(Priority, '<>%1', 0);
                                L_Variant.SetCurrentKey(Priority);
                                L_Variant.Ascending(true);
                                if L_Variant.FindSet() then begin
                                    repeat
                                        L_Variant.CalcFields("Saleable Inventory", "Qty on SO(Saleable)");
                                        PhysicalInventory += L_Variant."Saleable Inventory";
                                        QtyOnSO += L_Variant."Qty on SO(Saleable)";
                                    until L_Variant.Next() = 0;
                                end;

                                P_Item.CalcFields("Qty. on Web Order");
                                QtyonWebOrder := P_Item."Qty. on Web Order";

                                Clear(AvailableInventory);
                                AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder);
                                if AvailableInventory < 0 then
                                    AvailableInventory := 0;
                                ChannelItemListing.Validate("Channel Inventory", AvailableInventory);
                                ChannelItemListing.Modify(true);
                            end
                            else begin
                                ChannelItemListing.Init();
                                ChannelItemListing.VALIDATE("Channel Code", TradePartner2.Code);
                                ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                ChannelItemListing.Validate("Channel SKU", P_Item."No.");
                                ChannelItemListing.Validate("Pack Size", P_Item."Pack Size");

                                Clear(PhysicalInventory);
                                Clear(QtyOnSO);
                                Clear(QtyonWebOrder);
                                L_Variant.Reset();
                                L_Variant.SetRange("Item No.", P_Item."No.");
                                L_Variant.SetRange(Blocked, false);
                                L_Variant.SetRange("Sales Blocked", false);
                                L_Variant.SetFilter(Priority, '<>%1', 0);
                                L_Variant.SetCurrentKey(Priority);
                                L_Variant.Ascending(true);
                                if L_Variant.FindSet() then begin
                                    repeat
                                        L_Variant.CalcFields("Saleable Inventory", "Qty on SO(Saleable)");
                                        PhysicalInventory += L_Variant."Saleable Inventory";
                                        QtyOnSO += L_Variant."Qty on SO(Saleable)";
                                    until L_Variant.Next() = 0;
                                end;

                                P_Item.CalcFields("Qty. on Web Order");
                                QtyonWebOrder := P_Item."Qty. on Web Order";

                                Clear(AvailableInventory);
                                AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder);
                                if AvailableInventory < 0 then
                                    AvailableInventory := 0;
                                ChannelItemListing.Validate("Channel Inventory", AvailableInventory);
                                ChannelItemListing.Status := ChannelItemListing.Status::Active;
                                ChannelItemListing.Insert();
                            end;
                        until P_Item.Next() = 0;
                until TradePartner2.Next() = 0;
            Message('Items added in channel item listing successfully.');
        END;
    end;
}