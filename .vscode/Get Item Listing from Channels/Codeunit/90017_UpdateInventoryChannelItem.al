codeunit 90017 "Update Inventory Channel Item"
{
    trigger OnRun()
    var
        ChannelItemListing: Record "Channel Item Listing";
        L_Item: Record Item;
    begin
        ChannelItemListing.Reset();
        if ChannelItemListing.FindSet() then begin
            L_Item.Reset();
            L_Item.SetRange("No.", ChannelItemListing."Item No.");
            if ChannelItemListing."NAV Variant" <> '' then
                L_Item.SetRange("Variant Filter", ChannelItemListing."NAV Variant");
            if L_Item.FindFirst() then begin
                L_Item.CalcFields(Inventory);
                ChannelItemListing.Validate("Channel Inventory", L_Item.Inventory);
                ChannelItemListing.Modify();
            end;
        end;
    end;

    var
        myInt: Integer;
}