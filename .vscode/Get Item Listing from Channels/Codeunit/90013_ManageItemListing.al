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
                                ChannelItemListing.INSERT;
                            END;
                        UNTIL P_Item.NEXT = 0;
                UNTIL TradePartner2.NEXT = 0;
            MESSAGE('Items added in channel item listing successfully.');
        END;
    end;
}