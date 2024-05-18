codeunit 90021 "Update Channel Item Inventory"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        UpdateChannelItemInventory();
    end;

    local procedure UpdateChannelItemInventory()
    var
        L_ChannelItemListing: Record "Channel Item Listing";
        L_Item: Record Item;
        AvailableInventory: Decimal;
        PhysicalInventory: Decimal;
        QtyOnSO: Decimal;
        QtyonWebOrder: Decimal;
    begin
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetFilter("Item No.", '<>%1', '');
        L_ChannelItemListing.SetRange("Listing Status", L_ChannelItemListing."Listing Status"::Listed);
        L_ChannelItemListing.SetRange(Status, L_ChannelItemListing.Status::Active);
        L_ChannelItemListing.SetFilter("Date Filter", '>=%1', WorkDate());
        if L_ChannelItemListing.FindSet() then begin
            repeat
                Clear(L_Item);
                if L_Item.Get(L_ChannelItemListing."Item No.") then begin
                    L_ChannelItemListing.CalcFields("Physical Inventory", "Allcoated on SO", "Web Orders Qty");
                    Clear(PhysicalInventory);
                    PhysicalInventory := L_ChannelItemListing."Physical Inventory";

                    Clear(QtyOnSO);
                    QtyOnSO := L_ChannelItemListing."Allcoated on SO";

                    Clear(QtyonWebOrder);
                    QtyonWebOrder := L_ChannelItemListing."Web Orders Qty";

                    Clear(AvailableInventory);
                    AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder);

                    if AvailableInventory <> L_ChannelItemListing."Channel Inventory" then begin
                        if AvailableInventory > 0 then begin
                            L_ChannelItemListing.Validate("Channel Inventory", AvailableInventory);
                        end
                        else begin
                            L_ChannelItemListing.Validate("Channel Inventory", 0);
                        end;
                        L_ChannelItemListing."Inventory Synced" := false;
                        L_ChannelItemListing."Modified On" := CurrentDateTime;
                    end;
                end
                else begin
                    L_ChannelItemListing.Remarks := 'Item Not Found ' + L_ChannelItemListing."Item No.";
                    L_ChannelItemListing."Modified On" := CurrentDateTime;
                end;

                L_ChannelItemListing.Modify(true);
                Commit();
            Until L_ChannelItemListing.Next = 0;
        end;
    end;
}