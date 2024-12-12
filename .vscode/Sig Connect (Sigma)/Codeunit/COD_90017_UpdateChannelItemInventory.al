codeunit 90017 "Update Channel Item Inventory"
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
        L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        Clear(QtyOnSO);
        Clear(QtyonWebOrder);
        Clear(AvailableInventory);
        Clear(PhysicalInventory);


        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetFilter("Item No.", '<>%1', '');
        L_ChannelItemListing.SetRange("Listing Status", L_ChannelItemListing."Listing Status"::Listed);
        L_ChannelItemListing.SetRange(Status, L_ChannelItemListing.Status::Active);
        //L_ChannelItemListing.SetFilter("Date Filter", '>=%1', WorkDate());
        if L_ChannelItemListing.FindSet() then begin
            repeat
                Clear(L_Item);
                if L_Item.Get(L_ChannelItemListing."Item No.") then begin
                    L_ChannelItemListing.CalcFields("Web Orders Qty", "Variant Code Mandatory");

                    //Calculate Physical+++
                    Clear(PhysicalInventory);
                    //PhysicalInventory := ChannelItemListing."Physical Inventory";
                    L_ItemLedgerEntry.Reset();
                    L_ItemLedgerEntry.SetRange("Item No.", L_ChannelItemListing."Item No.");
                    L_ItemLedgerEntry.SetRange("Saleable Location", true);
                    if L_ChannelItemListing."Variant Code Mandatory" = true then
                        L_ItemLedgerEntry.SetRange("Daily Priority Exist", true)
                    else
                        L_ItemLedgerEntry.SetRange("Daily Priority Exist", false);
                    L_ItemLedgerEntry.CalcSums(Quantity);
                    PhysicalInventory := L_ItemLedgerEntry.Quantity;
                    if PhysicalInventory < 0 then
                        PhysicalInventory := 0;


                    //Calculate "Qty On SO"++++
                    Clear(QtyOnSO);
                    //QtyOnSO := ChannelItemListing."Allcoated on SO";
                    L_SalesLine.Reset();
                    L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                    L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                    L_SalesLine.SetRange("No.", L_ChannelItemListing."Item No.");
                    L_SalesLine.SetRange("Saleable Location", true);
                    L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                    L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                    QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
                    if QtyOnSO < 0 then
                        QtyOnSO := 0;


                    //Get Web Order Qty+++
                    Clear(QtyonWebOrder);
                    QtyonWebOrder := L_ChannelItemListing."Web Orders Qty";
                    if QtyonWebOrder < 0 then
                        QtyonWebOrder := 0;

                    //Calculate Available Qty +++
                    Clear(AvailableInventory);
                    AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder);
                    if AvailableInventory < 0 then
                        AvailableInventory := 0;

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
                    L_ChannelItemListing."Sales Blocked" := L_Item."Sales Blocked";
                    L_ChannelItemListing."Ops Sales Blocked" := L_Item."Ops Sales Blocked";
                end
                else begin
                    L_ChannelItemListing.Remarks := 'Item Not Found ' + L_ChannelItemListing."Item No.";
                    L_ChannelItemListing."Modified On" := CurrentDateTime;
                end;

                L_ChannelItemListing.Modify(true);
                Commit();
            Until L_ChannelItemListing.Next() = 0;
        end;
    end;
}