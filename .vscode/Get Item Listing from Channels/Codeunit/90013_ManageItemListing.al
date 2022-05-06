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
    begin
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
                        P_Item.SETRANGE(Blocked, false);
                        IF P_Item.FINDFIRST THEN
                            REPEAT
                                P_Item.CalcFields(Inventory);
                                ChannelItemListing.RESET;
                                ChannelItemListing.SETRANGE("Channel Code", TradePartner2.Code);
                                ChannelItemListing.SETRANGE("Channel SKU", P_Item."No.");
                                IF ChannelItemListing.FINDFIRST THEN BEGIN
                                    ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                    ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                    ChannelItemListing.MODIFY(TRUE);
                                END
                                ELSE BEGIN
                                    ChannelItemListing.INIT;
                                    ChannelItemListing.VALIDATE("Channel Code", TradePartner2.Code);
                                    ChannelItemListing.VALIDATE("Item No.", P_Item."No.");
                                    ChannelItemListing.VALIDATE("Channel Title", P_Item.Description);
                                    ChannelItemListing.Validate("Channel Inventory", P_Item.Inventory);
                                    ChannelItemListing.Validate("Unit of Measure code", P_Item."Base Unit of Measure");
                                    ChannelItemListing.Validate("Unit Price", P_Item."Unit Price");
                                    ChannelItemListing.Validate("Item Category Code", P_Item."Item Category Code");
                                    ChannelItemListing.Validate(Manufacturer, P_Item."Manufacturer Code");
                                    ChannelItemListing.Validate("Channel SKU", P_Item."No.");
                                    ChannelItemListing.Validate("Item No.", P_Item."No.");
                                    ChannelItemListing.Validate("ASIN No", P_Item."No.");
                                    ChannelItemListing.Validate("Created On", CREATEDATETIME(WORKDATE, TIME));
                                    ChannelItemListing.Validate("Channel brand ID", P_Item."VAT Prod. Posting Group");
                                    ChannelItemListing.Validate("Price Synced", false);
                                    ChannelItemListing.Validate("Inventory Synced", false);
                                    ChannelItemListing.Validate(Status, ChannelItemListing.Status::Active);
                                    ChannelItemListing.Validate(Action, ChannelItemListing.Action::Update);
                                    ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::"Not Listed");
                                    ChannelItemListing.INSERT;
                                END;
                            UNTIL P_Item.NEXT = 0;
                    UNTIL TradePartner2.NEXT = 0;
                MESSAGE('Items added in channel item listing successfully.');
            END;
        end;
    end;
}