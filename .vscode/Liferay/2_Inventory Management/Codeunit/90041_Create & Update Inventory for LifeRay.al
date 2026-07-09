codeunit 90041 "Create/Update Inv. for LifeRay"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        case RunType of
            'FullInventory':
                begin
                    //NOTE:- This is not free Inventory+++
                    Full_CreateUpdateInventoryforLifeRay('', StartParameter);
                end;
            'DeltaInventory':
                begin
                    //This code move to Process Inventory Push Queue Codeunit. (will remove after confirm the new code is working fine)
                    //Delta_CreateUpdateInventoryforLifeRay('', StartParameter)
                end;
        end;
    end;

    var
        myInt: Integer;
        StartParameter: Text;
        RunType: Text;

    #Region Full-Inventory++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //As discussed with Dipesh and VML on 2nd June, we agreed that inventory updates will be sent at an Item/Location level rather than an Item/Variant/Location level. (SBB-700)
    procedure Full_CreateUpdateInventoryforLifeRay(_ItemNo: Code[20]; _ChannelCode: Code[20])
    var
        L_ChannelItemListing: Record "Channel Item Listing";
        L_LiferayStock: Record "LifeRay Stock";
        Last_LiferayStock: Record "LifeRay Stock";
        L_Item: Record Item;
        L_Location: Record Location;
        L_TradePartner: Record "Trade Partner";
        L_TotalInventory: Decimal;
        L_AllocatedOnSo: Decimal;
        L_AllocatedOnPick: Decimal;
        L_ExculdedQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_TotalFree: Decimal;
        NextEntryNo: Integer;
        L_KNAPPQTY: Decimal;
        L_TotalWebOrderQty: Decimal;
        L_HasVariantSetup: Boolean;
        L_IsSaleable: Boolean;

        //
        Query_SalesLineQty: Query "Sales Line Qty Liferay";
        Query_PickQty: Query "Pick Qty LifeRay";
        Query_InventoryFromILE: Query "Inventory From ILE";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        L_SalesLine: Record "Sales Line";
        L_WarehouseActivityLine: Record "Warehouse Activity Line";
    begin
        //Update Sync Date Time to trade partner++
        if GuiAllowed = false then begin
            L_TradePartner.Reset();
            if L_TradePartner.Get(_ChannelCode) then begin
                L_TradePartner."Last Inventory Sync" := CurrentDateTime;
                L_TradePartner.Modify();
            end;
        end;

        //Get the Last Entry No. for Liferay Stock++
        Last_LiferayStock.Reset();
        if Last_LiferayStock.FindLast() then
            NextEntryNo := Last_LiferayStock."Entry No."
        else
            NextEntryNo := 0;

        //Check Mandatory fields++
        L_Location.Reset();
        L_Location.SetFilter("Liferay Location Ranking", '>%1', 0);
        if not L_Location.FindFirst() then
            Error('Please setup Location with Liferay Location Ranking greater than 0 for Inventory Sync.');

        #Region Process to insert record in table++
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Channel Code", _ChannelCode);
        L_ChannelItemListing.SetRange("Item Sync", true);
        if _ItemNo <> '' then
            L_ChannelItemListing.SetRange("Item No.", _ItemNo);
        if L_ChannelItemListing.FindSet() then begin
            repeat
                //Check variant setup result
                Clear(L_HasVariantSetup);
                L_HasVariantSetup := GetVariantSetup(L_ChannelItemListing."Item No.");


                //Location Loop — one LifeRay Stock entry per Item + Location (no variant split)++
                L_Location.Reset();
                L_Location.SetFilter("Liferay Location Ranking", '>%1', 0);
                L_Location.SetCurrentKey("Liferay Location Ranking");
                L_Location.Ascending(true);
                if L_Location.FindSet() then begin
                    repeat
                        //Check if the location is saleable+++
                        Clear(L_IsSaleable);
                        L_IsSaleable := L_Location."Saleable Location";


                        L_LiferayStock.Reset();
                        L_LiferayStock.SetRange("Item No.", L_ChannelItemListing."Item No.");
                        L_LiferayStock.SetRange("Location Code", L_Location.Code);
                        L_LiferayStock.SetRange("Created On", WorkDate());
                        L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
                        if not L_LiferayStock.FindFirst() then begin
                            L_LiferayStock.Init();
                            NextEntryNo := NextEntryNo + 1;
                            L_LiferayStock."Entry No." := NextEntryNo;
                            L_LiferayStock."Channel Code" := _ChannelCode;
                            L_LiferayStock."Item No." := L_ChannelItemListing."Item No.";
                            L_LiferayStock."Item Description" := L_ChannelItemListing.Description;
                            L_LiferayStock."Variant Code" := '';
                            L_LiferayStock."Variant Description" := '';
                            L_LiferayStock."Variant Priority" := 0;
                            L_LiferayStock."Location Code" := L_Location.Code;

                            //Web Order Qty (DEPOT1 only — other channels + LifeRay(Consider Liferay WebOrder at the full-Inventory))++
                            L_TotalWebOrderQty := 0;
                            if L_Location.Code = 'DEPOT1' then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", L_ChannelItemListing."Item No.");
                                if L_Item.FindFirst() then begin
                                    L_Item.CalcFields("Qty. on Web Order");
                                    L_TotalWebOrderQty := L_Item."Qty. on Web Order";
                                end;
                            end;
                            L_LiferayStock."Total Web Order Qty" := L_TotalWebOrderQty;

                            #Region Inventory Calculation++
                            //Total Inventory from ILE (all variants summed only for priority > 0)++
                            Clear(L_TotalInventory);
                            L_ItemLedgerEntry.Reset();
                            L_ItemLedgerEntry.SetRange("Item No.", L_ChannelItemListing."Item No.");
                            IF L_IsSaleable = false then
                                L_ItemLedgerEntry.SetRange("Location Code", L_Location.Code)
                            else begin
                                L_ItemLedgerEntry.SetRange("Daily Priority Exist", L_HasVariantSetup);
                                L_ItemLedgerEntry.SetRange("Saleable Location", true);
                            end;
                            // L_ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
                            // L_ItemLedgerEntry.CalcSums("Remaining Quantity");
                            // L_TotalInventory := L_ItemLedgerEntry."Remaining Quantity";
                            L_ItemLedgerEntry.CalcSums(Quantity);
                            L_TotalInventory := L_ItemLedgerEntry.Quantity;
                            if L_TotalInventory < 0 then
                                L_TotalInventory := 0;

                            //Total Allocated On SO (all variants summed)++
                            Clear(L_AllocatedOnSo);
                            L_SalesLine.Reset();
                            L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                            L_SalesLine.SetRange("No.", L_ChannelItemListing."Item No.");
                            if L_IsSaleable = false then
                                L_SalesLine.SetRange("Location Code", L_Location.Code)
                            else
                                L_SalesLine.SetRange("Saleable Location", true);
                            L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                            L_AllocatedOnSo := L_SalesLine."Outstanding Qty. (Base)";
                            if L_AllocatedOnSo < 0 then
                                L_AllocatedOnSo := 0;


                            //Total Allocated on Pick (all variants summed)++
                            Clear(L_AllocatedOnPick);
                            L_WarehouseActivityLine.Reset();
                            L_WarehouseActivityLine.SetRange("Source Document", L_WarehouseActivityLine."Source Document"::"Sales Order");
                            L_WarehouseActivityLine.SetRange("Item No.", L_ChannelItemListing."Item No.");
                            if L_IsSaleable = false then
                                L_WarehouseActivityLine.SetRange("Location Code", L_Location.Code)
                            else
                                L_WarehouseActivityLine.SetRange("Saleable Location", true);
                            L_WarehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
                            L_WarehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
                            L_AllocatedOnPick := L_WarehouseActivityLine."Qty. Outstanding (Base)";
                            if L_AllocatedOnPick < 0 then
                                L_AllocatedOnPick := 0;

                            //Total Excluded Qty from Bin Content (all variants summed)++
                            Clear(L_ExculdedQty);
                            L_BinContent.Reset();
                            L_BinContent.SetRange("Item No.", L_ChannelItemListing."Item No.");
                            L_BinContent.SetRange("Location Code", L_Location.Code);
                            L_BinContent.SetRange("Exclude from free Qty.", true);
                            L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
                            if L_BinContent.FindSet() then begin
                                repeat
                                    L_BinContent.CalcFields("Quantity (Base)");
                                    L_ExculdedQty += L_BinContent."Quantity (Base)";
                                until L_BinContent.Next() = 0;
                            end;
                            if L_ExculdedQty < 0 then
                                L_ExculdedQty := 0;


                            //Calculate Total Free quantity++
                            Clear(L_TotalFree);
                            L_TotalFree := L_TotalInventory - (L_AllocatedOnSo + L_AllocatedOnPick + L_ExculdedQty + L_TotalWebOrderQty + L_KNAPPQTY);
                            if L_TotalFree < 0 then
                                L_TotalFree := 0;

                            L_LiferayStock."Allocated On WebOrder" := L_TotalWebOrderQty;
                            L_LiferayStock.Inventory := L_TotalFree;
                            #Endregion Inventory Calculation++

                            L_LiferayStock."Total Quantity" := L_TotalInventory;
                            L_LiferayStock."Allocated On SO" := L_AllocatedOnSo; //This allocated SO include KNAPP orders Qty as well+++
                            L_LiferayStock."Allocated On Pick" := L_AllocatedOnPick;
                            L_LiferayStock."Restricted Quantity" := L_ExculdedQty;
                            L_LiferayStock."Created On" := WorkDate();
                            L_LiferayStock."Sync Type" := L_LiferayStock."Sync Type"::Full;
                            L_LiferayStock.Sync := false;
                            L_LiferayStock.Insert();
                        end;
                    until L_Location.Next() = 0;
                end;
            until L_ChannelItemListing.Next() = 0;

            //Commit
            Commit();
        end;
        #EndRegion Process to insert record in table++
    end;

    /* 
    procedure Full_CreateUpdateInventoryforLifeRay(_ItemNo: Code[20]; _ChannelCode: Code[20])
    var
        L_ChannelItemListing: Record "Channel Item Listing";
        L_LiferayStock: Record "LifeRay Stock";
        Last_LiferayStock: Record "LifeRay Stock";
        L_ItemVariant: Record "Item Variant";
        L_Item: Record Item;
        L_Location: Record Location;
        L_TradePartner: Record "Trade Partner";
        L_TotalInventory: Decimal;
        L_AllocatedOnSo: Decimal;
        L_AllocatedOnPick: Decimal;
        L_RemainingWebOrderQty: Decimal;
        L_ExculdedQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_TotalFree: Decimal;
        NextEntryNo: Integer;
        L_ItemNoLoop: Code[20];
        L_KNAPPQTY: Decimal;
        AssigntoWbOrderQty: Decimal;
        L_TotalWebOrderQty: Decimal;

        //++
        Query_SalesLineQty: Query "Sales Line Qty Liferay";
        Query_PickQty: Query "Pick Qty LifeRay";
        Query_InventoryFromILE: Query "Inventory From ILE";
        L_ItemLadgerEntry: Record "Item Ledger Entry";
        L_SalesLine: Record "Sales Line";
        L_WarehouseActivityLine: Record "Warehouse Activity Line";
        L_SalesInterimLine: Record "Interim Sales Line";
    begin
        //Update Sync Date Time to trade partner++
        if GuiAllowed = false then begin
            L_TradePartner.Reset();
            if L_TradePartner.Get(_ChannelCode) then begin
                L_TradePartner."Last Inventory Sync" := CurrentDateTime;
                L_TradePartner.Modify();
            end;
        end;

        //Get the Last Entry No. for Liferay Stock++
        Last_LiferayStock.Reset();
        if Last_LiferayStock.FindLast() then
            NextEntryNo := Last_LiferayStock."Entry No."
        else
            NextEntryNo := 0;

        //Check Mandatory fields++
        L_Location.Reset();
        L_Location.SetFilter("Liferay Location Ranking", '>%1', 0);
        if not L_Location.FindFirst() then
            Error('Please setup Location with Liferay Location Ranking greater than 0 for Inventory Sync.');

        #Region Process to insert record in table++
        Clear(L_ItemNoLoop);
        L_ChannelItemListing.Reset();
        L_ChannelItemListing.SetRange("Channel Code", _ChannelCode);
        L_ChannelItemListing.SetRange("Item Sync", true);
        if _ItemNo <> '' then
            L_ChannelItemListing.SetRange("Item No.", _ItemNo);
        if L_ChannelItemListing.FindSet() then begin
            repeat
                //++
                L_ChannelItemListing.CalcFields("Variant Mandatory if Exists");

                //Location Loop++
                L_Location.Reset();
                L_Location.SetFilter("Liferay Location Ranking", '>%1', 0);
                L_Location.SetCurrentKey("Liferay Location Ranking");
                L_Location.Ascending(true);
                if L_Location.FindSet() then begin
                    repeat
                        //Get Web Order Qty++
                        Clear(L_RemainingWebOrderQty);
                        Clear(L_TotalWebOrderQty);
                        if L_Location.Code = 'DEPOT1' then begin
                            //This web order for other channel++
                            L_Item.Reset();
                            L_Item.SetRange("No.", L_ChannelItemListing."Item No.");
                            if L_Item.FindFirst() then begin
                                L_Item.CalcFields("Qty. on Web Order");
                                L_RemainingWebOrderQty := L_Item."Qty. on Web Order";
                                L_TotalWebOrderQty := L_Item."Qty. on Web Order";
                            end;
                        end;

                        //If Variant Product++
                        if L_ChannelItemListing."Variant Mandatory if Exists" = L_ChannelItemListing."Variant Mandatory if Exists"::Yes then begin
                            #Region With Priority++
                            L_ItemVariant.Reset();
                            L_ItemVariant.SetRange("Item No.", L_ChannelItemListing."Item No.");
                            L_ItemVariant.SetFilter(Priority, '>%1', 0);
                            L_ItemVariant.SetCurrentKey(Priority);
                            L_ItemVariant.Ascending(true);
                            if L_ItemVariant.FindSet() then begin
                                repeat
                                    L_LiferayStock.Reset();
                                    L_LiferayStock.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                    L_LiferayStock.SetRange("Variant Code", L_ItemVariant.Code);
                                    L_LiferayStock.SetRange("Location Code", L_Location.Code);
                                    L_LiferayStock.SetRange("Created On", WorkDate());
                                    L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
                                    if not L_LiferayStock.FindFirst() then begin
                                        L_LiferayStock.Init();
                                        NextEntryNo := NextEntryNo + 1;
                                        L_LiferayStock."Entry No." := NextEntryNo;
                                        L_LiferayStock."Channel Code" := _ChannelCode;
                                        L_LiferayStock."Item No." := L_ChannelItemListing."Item No.";
                                        L_LiferayStock."Item Description" := L_ChannelItemListing.Description;
                                        L_LiferayStock."Variant Code" := L_ItemVariant.Code;
                                        L_LiferayStock."Variant Description" := L_ItemVariant.Description;
                                        L_LiferayStock."Variant Priority" := L_ItemVariant.Priority;
                                        L_LiferayStock."Location Code" := L_Location.Code;
                                        L_LiferayStock."Total Web Order Qty" := L_TotalWebOrderQty;
                                        #Region Inventory Calculation++
                                        //Total Inventory from ILE
                                        Clear(L_TotalInventory);
                                        Clear(Query_InventoryFromILE);
                                        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Item_No_, L_ChannelItemListing."Item No.");
                                        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Location_Code, L_Location.Code);
                                        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Variant_Code, L_ItemVariant.Code);
                                        Query_InventoryFromILE.Open();
                                        while Query_InventoryFromILE.Read() do begin
                                            L_TotalInventory += Query_InventoryFromILE.Quantity;
                                        end;
                                        if L_TotalInventory < 0 then
                                            L_TotalInventory := 0;


                                        //Total Allocated On SO++
                                        Clear(L_AllocatedOnSo);
                                        Clear(Query_SalesLineQty);
                                        Query_SalesLineQty.SetRange(Query_SalesLineQty.No_, L_ChannelItemListing."Item No.");
                                        Query_SalesLineQty.SetRange(Query_SalesLineQty.Variant_Code, L_ItemVariant.Code);
                                        Query_SalesLineQty.SetRange(Query_SalesLineQty.Location_Code, L_Location.Code);
                                        Query_SalesLineQty.SetFilter(Query_SalesLineQty.Shipment_Date, '>=%1', WorkDate());
                                        Query_SalesLineQty.Open();
                                        while Query_SalesLineQty.Read() do begin
                                            L_AllocatedOnSo += Query_SalesLineQty.Outstanding_Qty___Base_;
                                        end;
                                        if L_AllocatedOnSo < 0 then
                                            L_AllocatedOnSo := 0;


                                        //Total Allocated on Pick++
                                        Clear(L_AllocatedOnPick);
                                        Clear(Query_PickQty);
                                        Query_PickQty.SetRange(Query_PickQty.Item_No_, L_ChannelItemListing."Item No.");
                                        Query_PickQty.SetRange(Query_PickQty.Variant_Code, L_ItemVariant.Code);
                                        Query_PickQty.SetRange(Query_PickQty.Location_Code, L_Location.Code);
                                        Query_PickQty.SetFilter(Query_PickQty.Shipment_Date, '<%1', WorkDate());
                                        Query_PickQty.Open();
                                        while Query_PickQty.Read() do begin
                                            L_AllocatedOnPick += Query_PickQty.Qty__Outstanding__Base_;
                                        end;
                                        if L_AllocatedOnPick < 0 then
                                            L_AllocatedOnPick := 0;


                                        //Total Exculded Qty++
                                        Clear(L_ExculdedQty);
                                        L_BinContent.Reset();
                                        L_BinContent.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                        L_BinContent.SetRange("Variant Code", L_ItemVariant.Code);
                                        L_BinContent.SetRange("Location Code", L_Location.Code);
                                        L_BinContent.SetRange("Exclude from free Qty.", true);
                                        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
                                        if L_BinContent.FindSet() then begin
                                            repeat
                                                L_BinContent.CalcFields("Quantity (Base)");
                                                L_ExculdedQty += L_BinContent."Quantity (Base)";
                                            until L_BinContent.Next() = 0;
                                        end;
                                        if L_ExculdedQty < 0 then
                                            L_ExculdedQty := 0;

                                        //If the location is DEPOT1 need to consider KNAPP orders++++
                                        Clear(L_KNAPPQTY);
                                        if L_Location.Code = 'DEPOT1' then
                                            L_KNAPPQTY := Full_GetKNAPPQTY(L_ChannelItemListing."Item No.", L_ItemVariant.Code)
                                        else
                                            L_KNAPPQTY := 0;
                                        if L_KNAPPQTY < 0 then
                                            L_KNAPPQTY := 0;

                                        //Calculate Total Free quantity++ 
                                        Clear(L_TotalFree);
                                        L_TotalFree := L_TotalInventory - (L_AllocatedOnSo + L_AllocatedOnPick + L_ExculdedQty + L_KNAPPQTY);
                                        if L_TotalFree < 0 then
                                            L_TotalFree := 0;


                                        #Region Remaining Web Order Qty+++
                                        Clear(AssigntoWbOrderQty);
                                        if (L_Location.Code = 'DEPOT1') AND (L_RemainingWebOrderQty > 0) then begin
                                            if L_TotalFree >= L_RemainingWebOrderQty then begin
                                                AssigntoWbOrderQty := L_RemainingWebOrderQty;
                                                L_RemainingWebOrderQty := 0;
                                            end else begin
                                                AssigntoWbOrderQty := L_TotalFree;
                                                L_RemainingWebOrderQty := L_RemainingWebOrderQty - AssigntoWbOrderQty;
                                            end;

                                            //++
                                            L_TotalFree := L_TotalFree - AssigntoWbOrderQty;
                                            if L_TotalFree < 0 then
                                                L_TotalFree := 0;
                                        end;
                                        #EndRegion Remaining Web Order Qty++

                                        L_LiferayStock."Allocated On WebOrder" := AssigntoWbOrderQty;
                                        L_LiferayStock.Inventory := L_TotalFree;
                                        #Endregion Inventory Calculation++

                                        L_LiferayStock."Total Quantity" := L_TotalInventory;
                                        L_LiferayStock."Allocated On SO" := L_AllocatedOnSo;
                                        L_LiferayStock."Allocated On Pick" := L_AllocatedOnPick;
                                        L_LiferayStock."Restricted Quantity" := L_ExculdedQty;
                                        L_LiferayStock."Allocated for KNAPP" := L_KNAPPQTY;
                                        L_LiferayStock."Created On" := WorkDate();
                                        L_LiferayStock."Sync Type" := L_LiferayStock."Sync Type"::Full;
                                        L_LiferayStock.Sync := false;
                                        L_LiferayStock.Insert();
                                    end;
                                until L_ItemVariant.Next() = 0;
                            end;
                            #EndRegion With Priority++

                            #Region Without Priority++
                            L_ItemVariant.Reset();
                            L_ItemVariant.SetRange("Item No.", L_ChannelItemListing."Item No.");
                            L_ItemVariant.SetRange(Priority, 0);
                            if L_ItemVariant.FindSet() then begin
                                repeat
                                    L_LiferayStock.Reset();
                                    L_LiferayStock.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                    L_LiferayStock.SetRange("Variant Code", L_ItemVariant.Code);
                                    L_LiferayStock.SetRange("Location Code", L_Location.Code);
                                    L_LiferayStock.SetRange("Created On", WorkDate());
                                    L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
                                    if not L_LiferayStock.FindFirst() then begin
                                        L_LiferayStock.Init();
                                        NextEntryNo := NextEntryNo + 1;
                                        L_LiferayStock."Entry No." := NextEntryNo;
                                        L_LiferayStock."Channel Code" := _ChannelCode;
                                        L_LiferayStock."Item No." := L_ChannelItemListing."Item No.";
                                        L_LiferayStock."Item Description" := L_ChannelItemListing.Description;
                                        L_LiferayStock."Variant Code" := L_ItemVariant.Code;
                                        L_LiferayStock."Variant Description" := L_ItemVariant.Description;
                                        L_LiferayStock."Variant Priority" := L_ItemVariant.Priority;
                                        L_LiferayStock."Location Code" := L_Location.Code;
                                        L_LiferayStock."Total Web Order Qty" := L_TotalWebOrderQty;
                                        #Region Inventory Calculation++
                                        //Total Inventory from ILE
                                        Clear(L_TotalInventory);
                                        Clear(Query_InventoryFromILE);
                                        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Item_No_, L_ChannelItemListing."Item No.");
                                        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Location_Code, L_Location.Code);
                                        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Variant_Code, L_ItemVariant.Code);
                                        Query_InventoryFromILE.Open();
                                        while Query_InventoryFromILE.Read() do begin
                                            L_TotalInventory += Query_InventoryFromILE.Quantity;
                                        end;
                                        if L_TotalInventory < 0 then
                                            L_TotalInventory := 0;
                                        // Clear(L_TotalInventory);
                                        // L_ItemLadgerEntry.Reset();
                                        // L_ItemLadgerEntry.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                        // L_ItemLadgerEntry.SetRange("Location Code", L_Location.Code);
                                        // L_ItemLadgerEntry.SetRange("Variant Code", L_ItemVariant.Code);
                                        // L_ItemLadgerEntry.SetFilter("WebOrder No.", '%1', '');
                                        // L_ItemLadgerEntry.CalcSums(Quantity);
                                        // L_TotalInventory := L_ItemLadgerEntry.Quantity;
                                        // if L_TotalInventory < 0 then
                                        //     L_TotalInventory := 0;


                                        //Total Allocated On SO++
                                        Clear(L_AllocatedOnSo);
                                        Clear(Query_SalesLineQty);
                                        Query_SalesLineQty.SetRange(Query_SalesLineQty.No_, L_ChannelItemListing."Item No.");
                                        Query_SalesLineQty.SetRange(Query_SalesLineQty.Variant_Code, L_ItemVariant.Code);
                                        Query_SalesLineQty.SetRange(Query_SalesLineQty.Location_Code, L_Location.Code);
                                        Query_SalesLineQty.SetFilter(Query_SalesLineQty.Shipment_Date, '>=%1', WorkDate());
                                        Query_SalesLineQty.Open();
                                        while Query_SalesLineQty.Read() do begin
                                            L_AllocatedOnSo += Query_SalesLineQty.Outstanding_Qty___Base_;
                                        end;
                                        if L_AllocatedOnSo < 0 then
                                            L_AllocatedOnSo := 0;
                                        // Clear(L_AllocatedOnSo);
                                        // L_SalesLine.Reset();
                                        // L_SalesLine.SetRange("No.", L_ChannelItemListing."Item No.");
                                        // L_SalesLine.SetRange("Variant Code", L_ItemVariant.Code);
                                        // L_SalesLine.SetRange("Location Code", L_Location.Code);
                                        // L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                                        // L_SalesLine.SetFilter("WebOrder No.", '%1', '');
                                        // L_SalesLine.SetRange("Type", L_SalesLine.Type::Item);
                                        // L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                                        // L_AllocatedOnSo := L_SalesLine."Outstanding Qty. (Base)";
                                        // if L_AllocatedOnSo < 0 then
                                        //     L_AllocatedOnSo := 0;


                                        //Total Allocated on Pick++
                                        Clear(L_AllocatedOnPick);
                                        Clear(Query_PickQty);
                                        Query_PickQty.SetRange(Query_PickQty.Item_No_, L_ChannelItemListing."Item No.");
                                        Query_PickQty.SetRange(Query_PickQty.Variant_Code, L_ItemVariant.Code);
                                        Query_PickQty.SetRange(Query_PickQty.Location_Code, L_Location.Code);
                                        Query_PickQty.SetFilter(Query_PickQty.Shipment_Date, '<%1', WorkDate());
                                        Query_PickQty.Open();
                                        while Query_PickQty.Read() do begin
                                            L_AllocatedOnPick += Query_PickQty.Qty__Outstanding__Base_;
                                        end;
                                        if L_AllocatedOnPick < 0 then
                                            L_AllocatedOnPick := 0;
                                        // Clear(L_AllocatedOnPick);
                                        // L_WarehouseActivityLine.Reset();
                                        // L_WarehouseActivityLine.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                        // L_WarehouseActivityLine.SetRange("Variant Code", L_ItemVariant.Code);
                                        // L_WarehouseActivityLine.SetRange("Location Code", L_Location.Code);
                                        // L_WarehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
                                        // L_WarehouseActivityLine.SetRange("Activity Type", L_WarehouseActivityLine."Activity Type"::Pick);
                                        // L_WarehouseActivityLine.SetFilter("WebOrder No.",'%1','');
                                        // L_WarehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
                                        // L_AllocatedOnPick := L_WarehouseActivityLine."Qty. Outstanding (Base)";
                                        // if L_AllocatedOnPick < 0 then
                                        //     L_AllocatedOnPick := 0;



                                        //Total Exculded Qty++
                                        Clear(L_ExculdedQty);
                                        L_BinContent.Reset();
                                        L_BinContent.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                        L_BinContent.SetRange("Variant Code", L_ItemVariant.Code);
                                        L_BinContent.SetRange("Location Code", L_Location.Code);
                                        L_BinContent.SetRange("Exclude from free Qty.", true);
                                        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
                                        if L_BinContent.FindSet() then begin
                                            repeat
                                                L_BinContent.CalcFields("Quantity (Base)");
                                                L_ExculdedQty += L_BinContent."Quantity (Base)";
                                            until L_BinContent.Next() = 0;
                                        end;
                                        if L_ExculdedQty < 0 then
                                            L_ExculdedQty := 0;

                                        //If the location is DEPOT1 need to consider KNAPP orders++++
                                        Clear(L_KNAPPQTY);
                                        if L_Location.Code = 'DEPOT1' then
                                            L_KNAPPQTY := Full_GetKNAPPQTY(L_ChannelItemListing."Item No.", L_ItemVariant.Code)
                                        else
                                            L_KNAPPQTY := 0;
                                        if L_KNAPPQTY < 0 then
                                            L_KNAPPQTY := 0;

                                        //Calculate Total Free quantity++ 
                                        Clear(L_TotalFree);
                                        L_TotalFree := L_TotalInventory - (L_AllocatedOnSo + L_AllocatedOnPick + L_ExculdedQty + L_KNAPPQTY);
                                        if L_TotalFree < 0 then
                                            L_TotalFree := 0;

                                        #Region Remaining Web Order Qty+++
                                        Clear(AssigntoWbOrderQty);
                                        if (L_Location.Code = 'DEPOT1') AND (L_RemainingWebOrderQty > 0) then begin
                                            if L_TotalFree >= L_RemainingWebOrderQty then begin
                                                AssigntoWbOrderQty := L_RemainingWebOrderQty;
                                                L_RemainingWebOrderQty := 0;
                                            end else begin
                                                AssigntoWbOrderQty := L_TotalFree;
                                                L_RemainingWebOrderQty := L_RemainingWebOrderQty - AssigntoWbOrderQty;
                                            end;
                                            L_TotalFree := L_TotalFree - AssigntoWbOrderQty;
                                            if L_TotalFree < 0 then
                                                L_TotalFree := 0;
                                        end;
                                        #EndRegion Remaining Web Order Qty++

                                        L_LiferayStock."Allocated On WebOrder" := AssigntoWbOrderQty;
                                        L_LiferayStock.Inventory := L_TotalFree;
                                        #Endregion Inventory Calculation++

                                        L_LiferayStock."Total Quantity" := L_TotalInventory;
                                        L_LiferayStock."Allocated On SO" := L_AllocatedOnSo;
                                        L_LiferayStock."Allocated On Pick" := L_AllocatedOnPick;
                                        L_LiferayStock."Restricted Quantity" := L_ExculdedQty;
                                        L_LiferayStock."Allocated for KNAPP" := L_KNAPPQTY;
                                        L_LiferayStock."Created On" := WorkDate();
                                        L_LiferayStock."Sync Type" := L_LiferayStock."Sync Type"::Full;
                                        L_LiferayStock.Sync := false;
                                        L_LiferayStock.Insert();
                                    end;
                                until L_ItemVariant.Next() = 0;
                            end;
                            #EndRegion Without Priority++
                        end else begin
                            //Without Variant++
                            L_LiferayStock.Reset();
                            L_LiferayStock.SetRange("Item No.", L_ChannelItemListing."Item No.");
                            L_LiferayStock.SetRange("Location Code", L_Location.Code);
                            L_LiferayStock.SetRange("Created On", WorkDate());
                            L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
                            if not L_LiferayStock.FindFirst() then begin
                                L_LiferayStock.Init();
                                NextEntryNo := NextEntryNo + 1;
                                L_LiferayStock."Entry No." := NextEntryNo;
                                L_LiferayStock."Channel Code" := _ChannelCode;
                                L_LiferayStock."Item No." := L_ChannelItemListing."Item No.";
                                L_LiferayStock."Item Description" := L_ChannelItemListing.Description;
                                L_LiferayStock."Variant Code" := '';
                                L_LiferayStock."Variant Description" := '';
                                L_LiferayStock."Location Code" := L_Location.Code;
                                L_LiferayStock."Total Web Order Qty" := L_TotalWebOrderQty;
                                #Region Inventory Calculation++
                                //Total Inventory from ILE
                                Clear(L_TotalInventory);
                                Clear(Query_InventoryFromILE);
                                Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Item_No_, L_ChannelItemListing."Item No.");
                                Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Location_Code, L_Location.Code);
                                Query_InventoryFromILE.Open();
                                while Query_InventoryFromILE.Read() do begin
                                    L_TotalInventory += Query_InventoryFromILE.Quantity;
                                end;
                                if L_TotalInventory < 0 then
                                    L_TotalInventory := 0;


                                //Total Allocated On SO++
                                Clear(L_AllocatedOnSo);
                                Clear(Query_SalesLineQty);
                                Query_SalesLineQty.SetRange(Query_SalesLineQty.No_, L_ChannelItemListing."Item No.");
                                Query_SalesLineQty.SetRange(Query_SalesLineQty.Location_Code, L_Location.Code);
                                Query_SalesLineQty.SetFilter(Query_SalesLineQty.Shipment_Date, '>=%1', WorkDate());
                                Query_SalesLineQty.Open();
                                while Query_SalesLineQty.Read() do begin
                                    L_AllocatedOnSo += Query_SalesLineQty.Outstanding_Qty___Base_;
                                end;
                                if L_AllocatedOnSo < 0 then
                                    L_AllocatedOnSo := 0;


                                //Total Allocated on Pick++
                                Clear(L_AllocatedOnPick);
                                Clear(Query_PickQty);
                                Query_PickQty.SetRange(Query_PickQty.Item_No_, L_ChannelItemListing."Item No.");
                                Query_PickQty.SetRange(Query_PickQty.Location_Code, L_Location.Code);
                                Query_PickQty.SetFilter(Query_PickQty.Shipment_Date, '<%1', WorkDate());
                                Query_PickQty.Open();
                                while Query_PickQty.Read() do begin
                                    L_AllocatedOnPick += Query_PickQty.Qty__Outstanding__Base_;
                                end;
                                if L_AllocatedOnPick < 0 then
                                    L_AllocatedOnPick := 0;

                                //Total Exculded Qty++
                                Clear(L_ExculdedQty);
                                L_BinContent.Reset();
                                L_BinContent.SetRange("Item No.", L_ChannelItemListing."Item No.");
                                L_BinContent.SetRange("Location Code", L_Location.Code);
                                L_BinContent.SetRange("Exclude from free Qty.", true);
                                L_BinContent.SetFilter("Quantity (Base)", '>%1', 1);
                                if L_BinContent.FindSet() then begin
                                    repeat
                                        L_BinContent.CalcFields("Quantity (Base)");
                                        L_ExculdedQty += L_BinContent."Quantity (Base)";
                                    until L_BinContent.Next() = 0;
                                end;
                                if L_ExculdedQty < 0 then
                                    L_ExculdedQty := 0;

                                //If the location is DEPOT1 need to consider KNAPP orders++++
                                Clear(L_KNAPPQTY);
                                if L_Location.Code = 'DEPOT1' then
                                    L_KNAPPQTY := Full_GetKNAPPQTY(L_ChannelItemListing."Item No.", '')
                                else
                                    L_KNAPPQTY := 0;
                                if L_KNAPPQTY < 0 then
                                    L_KNAPPQTY := 0;

                                //Calculate Total Free quantity++ 
                                Clear(L_TotalFree);
                                L_TotalFree := L_TotalInventory - (L_AllocatedOnSo + L_AllocatedOnPick + L_ExculdedQty + L_RemainingWebOrderQty + L_KNAPPQTY);
                                if L_TotalFree < 0 then
                                    L_TotalFree := 0;

                                L_LiferayStock."Allocated On WebOrder" := L_RemainingWebOrderQty;
                                L_LiferayStock.Inventory := L_TotalFree;
                                #Endregion Inventory Calculation++

                                L_LiferayStock."Total Quantity" := L_TotalInventory;
                                L_LiferayStock."Allocated On SO" := L_AllocatedOnSo;
                                L_LiferayStock."Allocated On Pick" := L_AllocatedOnPick;
                                L_LiferayStock."Restricted Quantity" := L_ExculdedQty;
                                L_LiferayStock."Allocated for KNAPP" := L_KNAPPQTY;
                                L_LiferayStock."Created On" := WorkDate();
                                L_LiferayStock."Sync Type" := L_LiferayStock."Sync Type"::Full;
                                L_LiferayStock.Sync := false;
                                L_LiferayStock.Insert();
                            end;
                        end;
                    until L_Location.Next() = 0;
                end;
                L_ItemNoLoop := L_ChannelItemListing."Item No.";
            until L_ChannelItemListing.Next() = 0;

            //Commit
            Commit();
        end;
        #EndRegion Process to insert record in table++
    end;
    */
    #EndRegion Full-Inventory++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



    #Region Delta-Inventory++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //This code move to Process Inventory Push Queue Codeunit. (will remove after confirm the new code is working fine)
    /*
    procedure Delta_CreateUpdateInventoryforLifeRay(_ItemNo: Code[20]; _ChannelCode: Code[20])
    var
        L_LiferayStock: Record "LifeRay Stock";
        L_LastInvemtorySyncDatetime: DateTime;
        L_TardePartner: Record "Trade Partner";
        Last_LiferayStock: Record "LifeRay Stock";
        L_HasVariantSetup: Boolean;
        L_TotalInventory: Decimal;
        L_AllocatedOnSo: Decimal;
        L_AllocatedOnPick: Decimal;
        L_TotalFree: Decimal;
        L_TotalWeborderQty: Decimal;
        Remaining_WeborderQty: Decimal;
        L_ItemNoLoop: Code[20];
        Temp_LiferayStock: Record "LifeRay Stock" temporary; //Dont remove temp property++
        Temp_LiferayStockLoop: Record "LifeRay Stock" temporary; //Dont remove temp property++
        DeltaInsert_LiferayStock: Record "LifeRay Stock";
        L_Count: Integer;
        L_LocationCodeLoop: Code[20];
        AssigntoWbOrderQty: Decimal;
        EntryNo: Integer;

    begin
         //Get Last Inventory Sync Date Time++
       if GuiAllowed = false then begin
           Clear(L_LastInvemtorySyncDatetime);
           if L_TardePartner.Get(_ChannelCode) then begin
               L_LastInvemtorySyncDatetime := L_TardePartner."Last Inventory Sync";
               L_TardePartner."Last Inventory Sync" := CurrentDateTime;
               L_TardePartner.Modify();
           end;
       end else begin
           Clear(L_LastInvemtorySyncDatetime);
           if L_TardePartner.Get(_ChannelCode) then begin
               L_LastInvemtorySyncDatetime := L_TardePartner."Last Inventory Sync";
           end;
       end;

   /*
   procedure Delta_CreateUpdateInventoryforLifeRay(_ItemNo: Code[20]; _ChannelCode: Code[20])
   var
       L_LiferayStock: Record "LifeRay Stock";
       L_LastInvemtorySyncDatetime: DateTime;
       L_TardePartner: Record "Trade Partner";
       Last_LiferayStock: Record "LifeRay Stock";
       L_HasVariantSetup: Boolean;
       L_TotalInventory: Decimal;
       L_AllocatedOnSo: Decimal;
       L_AllocatedOnPick: Decimal;
       L_TotalFree: Decimal;
       L_TotalWeborderQty: Decimal;
       Remaining_WeborderQty: Decimal;
       L_ItemNoLoop: Code[20];
       Temp_LiferayStock: Record "LifeRay Stock" temporary; //Dont remove temp property++
       Temp_LiferayStockLoop: Record "LifeRay Stock" temporary; //Dont remove temp property++
       DeltaInsert_LiferayStock: Record "LifeRay Stock";
       L_Count: Integer;
       L_LocationCodeLoop: Code[20];
       AssigntoWbOrderQty: Decimal;
       EntryNo: Integer;

       //++
       L_ItemLadgerEntry: Record "Item Ledger Entry";
       L_SalesLine: Record "Sales Line";
       L_WarehouseActivityLine: Record "Warehouse Activity Line";
       L_InterimSalesLine: Record "Interim Sales Line";
       L_KNAPPQTY: Decimal;
   begin
       //Get Last Inventory Sync Date Time++
       if GuiAllowed = false then begin
           Clear(L_LastInvemtorySyncDatetime);
           if L_TardePartner.Get(_ChannelCode) then begin
               L_LastInvemtorySyncDatetime := L_TardePartner."Last Inventory Sync";
               L_TardePartner."Last Inventory Sync" := CurrentDateTime;
               L_TardePartner.Modify();
           end;
       end else begin
           Clear(L_LastInvemtorySyncDatetime);
           if L_TardePartner.Get(_ChannelCode) then begin
               L_LastInvemtorySyncDatetime := L_TardePartner."Last Inventory Sync";
           end;
       end;


       //Insert Delta Invemtory record++
       Clear(L_ItemNoLoop);
       Clear(L_Count);
       L_LiferayStock.Reset();
       L_LiferayStock.SetFilter("Created On", '>=%1', WorkDate());
       L_LiferayStock.SetRange(Sync, true);
       L_LiferayStock.SetRange("Sync Type", L_LiferayStock."Sync Type"::Full);
       if _ItemNo <> '' then
           L_LiferayStock.SetRange("Item No.", _ItemNo);
       L_LiferayStock.SetRange("Channel Code", _ChannelCode);
       L_LiferayStock.SetCurrentKey("Item No.");
       L_LiferayStock.Ascending(true);
       if L_LiferayStock.FindSet() then begin
           //++
           L_Count := L_LiferayStock.Count;

           //Get Last Entry No. in LifeRay Stock table++
           Clear(EntryNo);
           Last_LiferayStock.Reset();
           if Last_LiferayStock.FindLast() then
               EntryNo := Last_LiferayStock."Entry No." + 1
           else
               EntryNo := 1;
           repeat
               //Check Variant Mandatory++
               Clear(L_HasVariantSetup);
               L_HasVariantSetup := GetVariantSetup(L_LiferayStock."Item No.");

               #Region Only For Non-Variant products++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
               if L_HasVariantSetup = false then begin
                   DeltaInsert_LiferayStock.Init();
                   DeltaInsert_LiferayStock."Entry No." := EntryNo;
                   DeltaInsert_LiferayStock."Channel Code" := _ChannelCode;
                   DeltaInsert_LiferayStock."Item No." := L_LiferayStock."Item No.";
                   DeltaInsert_LiferayStock."Item Description" := L_LiferayStock."Item Description";
                   DeltaInsert_LiferayStock."Variant Code" := L_LiferayStock."Variant Code";
                   DeltaInsert_LiferayStock."Variant Description" := L_LiferayStock."Variant Description";
                   DeltaInsert_LiferayStock."Variant Priority" := L_LiferayStock."Variant Priority";
                   DeltaInsert_LiferayStock."Location Code" := L_LiferayStock."Location Code";
                   #Region Inventory Calculation++
                   //Total Inventory from ILE
                   Clear(L_TotalInventory);
                   L_ItemLadgerEntry.Reset();
                   L_ItemLadgerEntry.SetRange("Item No.", L_LiferayStock."Item No.");
                   L_ItemLadgerEntry.SetRange("Location Code", L_LiferayStock."Location Code");
                   L_ItemLadgerEntry.SetFilter(SystemCreatedAt, '>%1', L_LastInvemtorySyncDatetime);
                   L_ItemLadgerEntry.CalcSums("Quantity");
                   L_TotalInventory := L_ItemLadgerEntry."Quantity";


                   //Total Allocated On SO++
                   Clear(L_AllocatedOnSo);
                   L_SalesLine.Reset();
                   L_SalesLine.SetRange("No.", L_LiferayStock."Item No.");
                   L_SalesLine.SetRange("Location Code", L_LiferayStock."Location Code");
                   L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                   L_SalesLine.SetFilter("SystemCreatedAt", '>%1', L_LastInvemtorySyncDatetime);
                   L_SalesLine.SetRange("Type", L_SalesLine.Type::Item);
                   L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                   L_AllocatedOnSo := L_SalesLine."Outstanding Qty. (Base)";


                   //Total Allocated on Pick++
                   Clear(L_AllocatedOnPick);
                   L_WarehouseActivityLine.Reset();
                   L_WarehouseActivityLine.SetRange("Item No.", L_LiferayStock."Item No.");
                   L_WarehouseActivityLine.SetRange("Location Code", L_LiferayStock."Location Code");
                   L_WarehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
                   L_WarehouseActivityLine.SetFilter("SystemCreatedAt", '>%1', L_LastInvemtorySyncDatetime);
                   L_WarehouseActivityLine.SetRange("Source Document", L_WarehouseActivityLine."Source Document"::"Sales Order");
                   L_WarehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
                   L_AllocatedOnPick := L_WarehouseActivityLine."Qty. Outstanding (Base)";


                   //If the location is DEPOT1 need to consider KNAPP orders++++
                   Clear(L_KNAPPQTY);
                   if L_LiferayStock."Location Code" = 'DEPOT1' then begin
                       L_KNAPPQTY := Delta_GetKNAPPQTY(L_LiferayStock."Item No.", '', L_LastInvemtorySyncDatetime);
                   end else
                       L_KNAPPQTY := 0;


                   //Weborder Qty++
                   if L_LiferayStock."Location Code" = 'DEPOT1' then begin
                       Clear(L_TotalWeborderQty);
                       Clear(L_TotalWeborderQty);
                       L_InterimSalesLine.Reset();
                       L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                       L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                       L_InterimSalesLine.SetRange("No.", L_LiferayStock."Item No.");
                       L_InterimSalesLine.SetRange("Sales Order Created", false);
                       L_InterimSalesLine.SetRange("Consolidated Order", false);
                       //L_InterimSalesLine.SetRange("Order Status", L_InterimSalesLine."Order Status"::Accepted);
                       L_InterimSalesLine.SetFilter("Trade Partner Code", '<>%1', 'LIFERAY');
                       L_InterimSalesLine.SetFilter("Reason Code", '%1|%2', UpperCase('Order line created'), UpperCase('Partial Quantity Delivered'));
                       L_InterimSalesLine.SetFilter(SystemCreatedAt, '>%1', L_LastInvemtorySyncDatetime);
                       L_InterimSalesLine.CalcSums("Qty. to Deliver");
                       L_TotalWeborderQty := L_InterimSalesLine."Qty. to Deliver";
                   end else
                       L_TotalWeborderQty := 0;


                   //Calculate Free qty++
                   Clear(L_TotalFree);
                   L_TotalFree := L_TotalInventory - L_AllocatedOnSo - L_AllocatedOnPick - L_KNAPPQTY - L_TotalWeborderQty;
                   DeltaInsert_LiferayStock.Inventory := L_TotalFree;
                   #Endregion Inventory Calculation++

                   DeltaInsert_LiferayStock."Total Quantity" := L_TotalInventory;
                   DeltaInsert_LiferayStock."Allocated On SO" := L_AllocatedOnSo;
                   DeltaInsert_LiferayStock."Allocated On Pick" := L_AllocatedOnPick;
                   DeltaInsert_LiferayStock."Allocated for KNAPP" := L_KNAPPQTY;
                   DeltaInsert_LiferayStock."Total Web Order Qty" := L_TotalWeborderQty;
                   DeltaInsert_LiferayStock."Allocated On WebOrder" := L_TotalWeborderQty;
                   DeltaInsert_LiferayStock."Created On" := WorkDate();
                   DeltaInsert_LiferayStock."Sync Type" := DeltaInsert_LiferayStock."Sync Type"::Delta;
                   DeltaInsert_LiferayStock.Sync := false;
                   if DeltaInsert_LiferayStock.Inventory <> 0 then begin
                       DeltaInsert_LiferayStock.Insert();
                       EntryNo := EntryNo + 1;
                   end;
               end;
               #EndRegion Only For Non-Variant products++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



               #Region Only For Variant products++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
               if L_HasVariantSetup = true then begin
                   #Region Insert record in actual table++
                   if (L_ItemNoLoop <> L_LiferayStock."Item No.") AND (not Temp_LiferayStock.IsEmpty) then begin
                       #Region Insert In TempLoop Table++
                       Temp_LiferayStockLoop.Reset();
                       Temp_LiferayStockLoop.DeleteAll();
                       Temp_LiferayStock.Reset();
                       if Temp_LiferayStock.FindSet() then begin
                           repeat
                               Temp_LiferayStockLoop.Init();
                               Temp_LiferayStockLoop.TransferFields(Temp_LiferayStock);
                               Temp_LiferayStockLoop.Insert();
                           until Temp_LiferayStock.Next() = 0;
                       end;
                       #EndRegion Insert In TempLoop Table++


                       //++
                       Clear(L_LocationCodeLoop); //[FIX: reset per item so first location of new item is not skipped if it equals previous item's last location]
                       Temp_LiferayStockLoop.Reset();
                       Temp_LiferayStockLoop.SetCurrentKey("Location Code");
                       Temp_LiferayStockLoop.Ascending(true);
                       if Temp_LiferayStockLoop.FindSet() then begin
                           repeat
                               if L_LocationCodeLoop <> Temp_LiferayStockLoop."Location Code" then begin
                                   //Calculate WebOrder Qty++  [FIX: use Temp_LiferayStockLoop fields — at flush time L_LiferayStock points to the NEXT item, not the one being flushed]
                                   Clear(L_TotalWeborderQty);
                                   Clear(Remaining_WeborderQty);
                                   if Temp_LiferayStockLoop."Location Code" = 'DEPOT1' then begin
                                       L_InterimSalesLine.Reset();
                                       L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                       L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                                       L_InterimSalesLine.SetRange("No.", Temp_LiferayStockLoop."Item No.");
                                       L_InterimSalesLine.SetRange("Sales Order Created", false);
                                       //L_InterimSalesLine.SetRange("Order Status", L_InterimSalesLine."Order Status"::Accepted);
                                       L_InterimSalesLine.SetFilter("Trade Partner Code", '<>%1', 'LIFERAY');
                                       L_InterimSalesLine.SetRange("Consolidated Order", false);
                                       L_InterimSalesLine.SetFilter("Reason Code", '%1|%2', UpperCase('Order line created'), UpperCase('Partial Quantity Delivered'));
                                       L_InterimSalesLine.SetFilter(SystemCreatedAt, '>%1', L_LastInvemtorySyncDatetime);
                                       L_InterimSalesLine.CalcSums("Qty. to Deliver");
                                       L_TotalWeborderQty := L_InterimSalesLine."Qty. to Deliver";
                                       Remaining_WeborderQty := L_InterimSalesLine."Qty. to Deliver";
                                   end;

                                   //++
                                   Temp_LiferayStock.Reset();
                                   Temp_LiferayStock.SetRange("Location Code", Temp_LiferayStockLoop."Location Code");
                                   Temp_LiferayStock.SetFilter("Variant Priority", '>%1', 0);
                                   Temp_LiferayStock.SetCurrentKey("Variant Priority");
                                   Temp_LiferayStock.Ascending(true);
                                   if Temp_LiferayStock.FindSet() then begin
                                       repeat
                                           DeltaInsert_LiferayStock.Init();
                                           DeltaInsert_LiferayStock.TransferFields(Temp_LiferayStock);

                                           #Region Remaining Web Order Qty+++
                                           Clear(AssigntoWbOrderQty);
                                           if DeltaInsert_LiferayStock.Inventory > Remaining_WeborderQty then begin
                                               AssigntoWbOrderQty := Remaining_WeborderQty;
                                               Remaining_WeborderQty := 0;
                                           end else begin
                                               AssigntoWbOrderQty := DeltaInsert_LiferayStock.Inventory;
                                               Remaining_WeborderQty := Remaining_WeborderQty - AssigntoWbOrderQty;
                                           end;

                                           //++
                                           DeltaInsert_LiferayStock.Inventory := DeltaInsert_LiferayStock.Inventory - AssigntoWbOrderQty;
                                           #EndRegion Remaining Web Order Qty++

                                           DeltaInsert_LiferayStock."Total Web Order Qty" := L_TotalWeborderQty;
                                           DeltaInsert_LiferayStock."Allocated On WebOrder" := AssigntoWbOrderQty;
                                           if DeltaInsert_LiferayStock.Inventory <> 0 then
                                               DeltaInsert_LiferayStock.Insert();
                                       until Temp_LiferayStock.Next() = 0;
                                   end;

                                   #Region Without Priority Variants++ [FIX: previously dropped — now flushed with remaining web-order qty]
                                   Temp_LiferayStock.Reset();
                                   Temp_LiferayStock.SetRange("Location Code", Temp_LiferayStockLoop."Location Code");
                                   Temp_LiferayStock.SetRange("Variant Priority", 0);
                                   if Temp_LiferayStock.FindSet() then begin
                                       repeat
                                           DeltaInsert_LiferayStock.Init();
                                           DeltaInsert_LiferayStock.TransferFields(Temp_LiferayStock);

                                           Clear(AssigntoWbOrderQty);
                                           if DeltaInsert_LiferayStock.Inventory > Remaining_WeborderQty then begin
                                               AssigntoWbOrderQty := Remaining_WeborderQty;
                                               Remaining_WeborderQty := 0;
                                           end else begin
                                               AssigntoWbOrderQty := DeltaInsert_LiferayStock.Inventory;
                                               Remaining_WeborderQty := Remaining_WeborderQty - AssigntoWbOrderQty;
                                           end;

                                           DeltaInsert_LiferayStock.Inventory := DeltaInsert_LiferayStock.Inventory - AssigntoWbOrderQty;

                                           DeltaInsert_LiferayStock."Total Web Order Qty" := L_TotalWeborderQty;
                                           DeltaInsert_LiferayStock."Allocated On WebOrder" := AssigntoWbOrderQty;
                                           if DeltaInsert_LiferayStock.Inventory <> 0 then
                                               DeltaInsert_LiferayStock.Insert();
                                       until Temp_LiferayStock.Next() = 0;
                                   end;
                                   #EndRegion Without Priority Variants++
                               end;

                               //++
                               L_LocationCodeLoop := Temp_LiferayStockLoop."Location Code";
                           until Temp_LiferayStockLoop.Next() = 0;
                       end;

                       //Clear & Delete the Temp Record for the another Items++
                       Temp_LiferayStock.Reset();
                       Temp_LiferayStock.DeleteAll();
                   end;
                   #Endregion Insert record in actual table++

                   #Region Insert Data into Temp Table++++
                   Temp_LiferayStock.Init();
                   Temp_LiferayStock."Entry No." := EntryNo;
                   Temp_LiferayStock."Channel Code" := _ChannelCode;
                   Temp_LiferayStock."Item No." := L_LiferayStock."Item No.";
                   Temp_LiferayStock."Item Description" := L_LiferayStock."Item Description";
                   Temp_LiferayStock."Variant Code" := L_LiferayStock."Variant Code";
                   Temp_LiferayStock."Variant Description" := L_LiferayStock."Variant Description";
                   Temp_LiferayStock."Variant Priority" := L_LiferayStock."Variant Priority";
                   Temp_LiferayStock."Location Code" := L_LiferayStock."Location Code";
                   #Region Inventory Calculation++
                   //Total Inventory from ILE
                   Clear(L_TotalInventory);
                   L_ItemLadgerEntry.Reset();
                   L_ItemLadgerEntry.SetRange("Item No.", L_LiferayStock."Item No.");
                   L_ItemLadgerEntry.SetRange("Location Code", L_LiferayStock."Location Code");
                   L_ItemLadgerEntry.SetRange("Variant Code", L_LiferayStock."Variant Code");
                   L_ItemLadgerEntry.SetFilter(SystemCreatedAt, '>%1', L_LastInvemtorySyncDatetime);
                   L_ItemLadgerEntry.CalcSums("Quantity");
                   L_TotalInventory := L_ItemLadgerEntry."Quantity";


                   //Total Allocated On SO++
                   Clear(L_AllocatedOnSo);
                   L_SalesLine.Reset();
                   L_SalesLine.SetRange("No.", L_LiferayStock."Item No.");
                   L_SalesLine.SetRange("Variant Code", L_LiferayStock."Variant Code");
                   L_SalesLine.SetRange("Location Code", L_LiferayStock."Location Code");
                   L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                   L_SalesLine.SetFilter("SystemCreatedAt", '>%1', L_LastInvemtorySyncDatetime);
                   L_SalesLine.SetRange("Type", L_SalesLine.Type::Item);
                   L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                   L_AllocatedOnSo := L_SalesLine."Outstanding Qty. (Base)";


                   //Total Allocated on Pick++
                   Clear(L_AllocatedOnPick);
                   L_WarehouseActivityLine.Reset();
                   L_WarehouseActivityLine.SetRange("Item No.", L_LiferayStock."Item No.");
                   L_WarehouseActivityLine.SetRange("Variant Code", L_LiferayStock."Variant Code");
                   L_WarehouseActivityLine.SetRange("Location Code", L_LiferayStock."Location Code");
                   L_WarehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
                   L_WarehouseActivityLine.SetFilter("SystemCreatedAt", '>%1', L_LastInvemtorySyncDatetime);
                   L_WarehouseActivityLine.SetRange("Source Document", L_WarehouseActivityLine."Source Document"::"Sales Order");
                   L_WarehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
                   L_AllocatedOnPick := L_WarehouseActivityLine."Qty. Outstanding (Base)";


                   //If the location is DEPOT1 need to consider KNAPP orders++++
                   Clear(L_KNAPPQTY);
                   if L_LiferayStock."Location Code" = 'DEPOT1' then begin
                       L_KNAPPQTY := Delta_GetKNAPPQTY(L_LiferayStock."Item No.", L_LiferayStock."Variant Code", L_LastInvemtorySyncDatetime)
                   end else
                       L_KNAPPQTY := 0;


                   //Calculate Free qty++
                   Clear(L_TotalFree);
                   L_TotalFree := L_TotalInventory - L_AllocatedOnSo - L_AllocatedOnPick - L_KNAPPQTY;
                   Temp_LiferayStock.Inventory := L_TotalFree;
                   #Endregion Inventory Calculation++

                   Temp_LiferayStock."Total Quantity" := L_TotalInventory;
                   Temp_LiferayStock."Allocated On SO" := L_AllocatedOnSo;
                   Temp_LiferayStock."Allocated On Pick" := L_AllocatedOnPick;
                   Temp_LiferayStock."Allocated for KNAPP" := L_KNAPPQTY;
                   Temp_LiferayStock."Created On" := WorkDate();
                   Temp_LiferayStock."Sync Type" := Temp_LiferayStock."Sync Type"::Delta;
                   Temp_LiferayStock.Sync := false;
                   Temp_LiferayStock.Insert();
                   EntryNo := EntryNo + 1;
                   #EndRegion Insert Data into Temp Table++++

                   #Region Insert record in actual table if the count = 1 Next = 0 +++++
                   if (L_Count = 1) AND (not Temp_LiferayStock.IsEmpty) then begin
                       DeltaInsert_LiferayStock.Init();
                       DeltaInsert_LiferayStock.TransferFields(Temp_LiferayStock);

                       //Calculate WebOrder Qty++
                       if L_LiferayStock."Location Code" = 'DEPOT1' then begin
                           Clear(L_TotalWeborderQty);
                           Clear(L_TotalWeborderQty);
                           L_InterimSalesLine.Reset();
                           L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                           L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                           L_InterimSalesLine.SetRange("No.", L_LiferayStock."Item No.");
                           L_InterimSalesLine.SetRange("Sales Order Created", false);
                           //L_InterimSalesLine.SetRange("Order Status", L_InterimSalesLine."Order Status"::Accepted);
                           L_InterimSalesLine.SetFilter("Trade Partner Code", '<>%1', 'LIFERAY');
                           L_InterimSalesLine.SetRange("Consolidated Order", false);
                           L_InterimSalesLine.SetFilter("Reason Code", '%1|%2', UpperCase('Order line created'), UpperCase('Partial Quantity Delivered'));
                           L_InterimSalesLine.SetFilter(SystemCreatedAt, '>%1', L_LastInvemtorySyncDatetime);
                           L_InterimSalesLine.CalcSums("Qty. to Deliver");
                           L_TotalWeborderQty := L_InterimSalesLine."Qty. to Deliver";
                       end else
                           L_TotalWeborderQty := 0;

                       //Update Free qty++
                       DeltaInsert_LiferayStock.Inventory := DeltaInsert_LiferayStock.Inventory - L_TotalWeborderQty;

                       DeltaInsert_LiferayStock."Total Web Order Qty" := L_TotalWeborderQty;
                       DeltaInsert_LiferayStock."Allocated On WebOrder" := L_TotalWeborderQty;
                       if DeltaInsert_LiferayStock.Inventory <> 0 then
                           DeltaInsert_LiferayStock.Insert();

                       //Clear & Delete the Temp Record for the another Items++
                       Temp_LiferayStock.Reset();
                       Temp_LiferayStock.DeleteAll();
                   end;
                   #EndRegion Insert record in actual table if the count = 1 & Next = 0+++++
               end;
               #EndRegion Only For Variant products++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

               //++
               L_ItemNoLoop := L_LiferayStock."Item No.";
           until L_LiferayStock.Next() = 0;

           #Region Final Flush For Last Item's Variant Records++ [FIX: previously the last item never got flushed from Temp to actual table]
           if not Temp_LiferayStock.IsEmpty then begin
               Temp_LiferayStockLoop.Reset();
               Temp_LiferayStockLoop.DeleteAll();
               Temp_LiferayStock.Reset();
               if Temp_LiferayStock.FindSet() then begin
                   repeat
                       Temp_LiferayStockLoop.Init();
                       Temp_LiferayStockLoop.TransferFields(Temp_LiferayStock);
                       Temp_LiferayStockLoop.Insert();
                   until Temp_LiferayStock.Next() = 0;
               end;

               Clear(L_LocationCodeLoop);
               Temp_LiferayStockLoop.Reset();
               Temp_LiferayStockLoop.SetCurrentKey("Location Code");
               Temp_LiferayStockLoop.Ascending(true);
               if Temp_LiferayStockLoop.FindSet() then begin
                   repeat
                       if L_LocationCodeLoop <> Temp_LiferayStockLoop."Location Code" then begin
                           //Calculate WebOrder Qty for the item being flushed++
                           Clear(L_TotalWeborderQty);
                           Clear(Remaining_WeborderQty);
                           if Temp_LiferayStockLoop."Location Code" = 'DEPOT1' then begin
                               L_InterimSalesLine.Reset();
                               L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                               L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                               L_InterimSalesLine.SetRange("No.", Temp_LiferayStockLoop."Item No.");
                               L_InterimSalesLine.SetRange("Sales Order Created", false);
                               L_InterimSalesLine.SetRange("Consolidated Order", false);
                               //L_InterimSalesLine.SetRange("Order Status", L_InterimSalesLine."Order Status"::Accepted);
                               L_InterimSalesLine.SetFilter("Trade Partner Code", '<>%1', 'LIFERAY');
                               L_InterimSalesLine.SetFilter("Reason Code", '%1|%2', UpperCase('Order line created'), UpperCase('Partial Quantity Delivered'));
                               L_InterimSalesLine.SetFilter(SystemCreatedAt, '>%1', L_LastInvemtorySyncDatetime);
                               L_InterimSalesLine.CalcSums("Qty. to Deliver");
                               L_TotalWeborderQty := L_InterimSalesLine."Qty. to Deliver";
                               Remaining_WeborderQty := L_InterimSalesLine."Qty. to Deliver";
                           end;

                           //Priority > 0 variants++
                           Temp_LiferayStock.Reset();
                           Temp_LiferayStock.SetRange("Location Code", Temp_LiferayStockLoop."Location Code");
                           Temp_LiferayStock.SetFilter("Variant Priority", '>%1', 0);
                           Temp_LiferayStock.SetCurrentKey("Variant Priority");
                           Temp_LiferayStock.Ascending(true);
                           if Temp_LiferayStock.FindSet() then begin
                               repeat
                                   DeltaInsert_LiferayStock.Init();
                                   DeltaInsert_LiferayStock.TransferFields(Temp_LiferayStock);

                                   Clear(AssigntoWbOrderQty);
                                   if DeltaInsert_LiferayStock.Inventory > Remaining_WeborderQty then begin
                                       AssigntoWbOrderQty := Remaining_WeborderQty;
                                       Remaining_WeborderQty := 0;
                                   end else begin
                                       AssigntoWbOrderQty := DeltaInsert_LiferayStock.Inventory;
                                       Remaining_WeborderQty := Remaining_WeborderQty - AssigntoWbOrderQty;
                                   end;

                                   DeltaInsert_LiferayStock.Inventory := DeltaInsert_LiferayStock.Inventory - AssigntoWbOrderQty;

                                   DeltaInsert_LiferayStock."Total Web Order Qty" := L_TotalWeborderQty;
                                   DeltaInsert_LiferayStock."Allocated On WebOrder" := AssigntoWbOrderQty;
                                   if DeltaInsert_LiferayStock.Inventory <> 0 then
                                       DeltaInsert_LiferayStock.Insert();
                               until Temp_LiferayStock.Next() = 0;
                           end;

                           //Priority = 0 variants++
                           Temp_LiferayStock.Reset();
                           Temp_LiferayStock.SetRange("Location Code", Temp_LiferayStockLoop."Location Code");
                           Temp_LiferayStock.SetRange("Variant Priority", 0);
                           if Temp_LiferayStock.FindSet() then begin
                               repeat
                                   DeltaInsert_LiferayStock.Init();
                                   DeltaInsert_LiferayStock.TransferFields(Temp_LiferayStock);

                                   Clear(AssigntoWbOrderQty);
                                   if DeltaInsert_LiferayStock.Inventory > Remaining_WeborderQty then begin
                                       AssigntoWbOrderQty := Remaining_WeborderQty;
                                       Remaining_WeborderQty := 0;
                                   end else begin
                                       AssigntoWbOrderQty := DeltaInsert_LiferayStock.Inventory;
                                       Remaining_WeborderQty := Remaining_WeborderQty - AssigntoWbOrderQty;
                                   end;

                                   DeltaInsert_LiferayStock.Inventory := DeltaInsert_LiferayStock.Inventory - AssigntoWbOrderQty;

                                   DeltaInsert_LiferayStock."Total Web Order Qty" := L_TotalWeborderQty;
                                   DeltaInsert_LiferayStock."Allocated On WebOrder" := AssigntoWbOrderQty;
                                   if DeltaInsert_LiferayStock.Inventory <> 0 then
                                       DeltaInsert_LiferayStock.Insert();
                               until Temp_LiferayStock.Next() = 0;
                           end;
                       end;

                       L_LocationCodeLoop := Temp_LiferayStockLoop."Location Code";
                   until Temp_LiferayStockLoop.Next() = 0;
               end;

               Temp_LiferayStock.Reset();
               Temp_LiferayStock.DeleteAll();
           end;
           #EndRegion Final Flush For Last Item's Variant Records++

           //Commit
           Commit();
       end;
   end;
   */
    #EndRegion Delta-Inventory++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure GetVariantSetup(_ItemNo: Code[20]): Boolean
    var
        L_ItemVariant: Record "Item Variant";
        L_Item: Record Item;
    begin
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            if L_Item."Variant Mandatory if Exists" <> L_Item."Variant Mandatory if Exists"::No then begin
                if L_Item."Variant Mandatory if Exists" = L_Item."Variant Mandatory if Exists"::Yes then
                    exit(true)
                else begin
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", _ItemNo);
                    if L_ItemVariant.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            end else
                exit(false);
        end;
    end;

    local procedure Full_GetKNAPPQTY(_ItemNo: Code[20]; _VariantCode: Code[20]): Decimal
    var
        L_Location: Record Location;
        L_KNAPPLocationcode: Code[250];
        Query_SalesLineQty: Query "Sales Line Qty Liferay";
        Query_PickQty: Query "Pick Qty LifeRay";
        Query_InventoryFromILE: Query "Inventory From ILE";
        L_ItemLadgerEntry: Record "Item Ledger Entry";
        L_SalesLine: Record "Sales Line";
        L_WarehouseActivityLine: Record "Warehouse Activity Line";
        L_TotalInventory: Decimal;
        L_AllocatedOnSo: Decimal;
        L_AllocatedOnPick: Decimal;
        L_ExculdedQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_TotalQty: Decimal;
    begin
        Clear(L_TotalQty);
        //Get KNAPP Location++
        L_Location.Reset();
        L_Location.SetRange("Knapp Location", true);
        if L_Location.FindSet() then begin
            repeat
                if L_KNAPPLocationcode <> '' then begin
                    L_KNAPPLocationcode := L_KNAPPLocationcode + '|' + L_Location.Code;
                end else
                    L_KNAPPLocationcode := L_Location.Code;
            until L_Location.Next() = 0;
        end else
            exit(0);

        #Region Calculate Qty++++
        //Total Inventory from ILE
        Clear(L_TotalInventory);
        Clear(Query_InventoryFromILE);
        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Item_No_, _ItemNo);
        Query_InventoryFromILE.SetRange(Query_InventoryFromILE.Location_Code, L_KNAPPLocationcode);
        if _VariantCode <> '' then
            Query_InventoryFromILE.SetFilter(Query_InventoryFromILE.Variant_Code, _VariantCode);
        Query_InventoryFromILE.Open();
        while Query_InventoryFromILE.Read() do begin
            L_TotalInventory += Query_InventoryFromILE.Quantity;
        end;
        if L_TotalInventory < 0 then
            L_TotalInventory := 0;


        //Total Allocated On SO++
        Clear(L_AllocatedOnSo);
        Clear(Query_SalesLineQty);
        Query_SalesLineQty.SetRange(Query_SalesLineQty.No_, _ItemNo);
        Query_SalesLineQty.SetRange(Query_SalesLineQty.Location_Code, L_KNAPPLocationcode);
        if _VariantCode <> '' then
            Query_SalesLineQty.SetFilter(Query_SalesLineQty.Variant_Code, _VariantCode);
        Query_SalesLineQty.SetFilter(Query_SalesLineQty.Shipment_Date, '>=%1', WorkDate());
        Query_SalesLineQty.Open();
        while Query_SalesLineQty.Read() do begin
            L_AllocatedOnSo += Query_SalesLineQty.Outstanding_Qty___Base_;
        end;
        if L_AllocatedOnSo < 0 then
            L_AllocatedOnSo := 0;


        //Total Allocated on Pick++
        //Not required for sigma as we are not creating pick for KNAPP location.To ignore performance issue have commented the code ++++
        // Clear(L_AllocatedOnPick);
        // Clear(Query_PickQty);
        // Query_PickQty.SetRange(Query_PickQty.Item_No_, _ItemNo);
        // Query_PickQty.SetRange(Query_PickQty.Location_Code, L_KNAPPLocationcode);
        // if _VariantCode <> '' then
        //     Query_PickQty.SetFilter(Query_PickQty.Variant_Code, _VariantCode);
        // Query_PickQty.SetFilter(Query_PickQty.Shipment_Date, '<%1', WorkDate());
        // Query_PickQty.Open();
        // while Query_PickQty.Read() do begin
        //     L_AllocatedOnPick += Query_PickQty.Qty__Outstanding__Base_;
        // end;
        // if L_AllocatedOnPick < 0 then
        //     L_AllocatedOnPick := 0;


        // //Total Exculded Qty++
        //Not required for sigma process for kanpp location. To ignore performance issue have commented the code ++++
        // Clear(L_ExculdedQty);
        // L_BinContent.Reset();
        // L_BinContent.SetRange("Item No.", _ItemNo);
        // L_BinContent.SetRange("Location Code", L_KNAPPLocationcode);
        // if _VariantCode <> '' then
        //     L_BinContent.SetFilter("Variant Code", _VariantCode);
        // L_BinContent.SetRange("Exclude from free Qty.", true);
        // if L_BinContent.FindSet() then begin
        //     repeat
        //         L_BinContent.CalcFields("Quantity (Base)");
        //         L_ExculdedQty += L_BinContent."Quantity (Base)";
        //     until L_BinContent.Next() = 0;
        // end;
        // if L_ExculdedQty < 0 then
        //     L_ExculdedQty := 0;

        L_TotalQty := Abs(L_TotalInventory) + L_AllocatedOnSo;
        if L_TotalQty < 0 then
            L_TotalQty := 0;
        exit(L_TotalQty);
        #EndRegion Calculate Qty++++
    end;

    local procedure Delta_GetKNAPPQTY(_ItemNo: Code[20]; _VariantCode: Code[20]; _LastInvemtorySyncDatetime: DateTime): Decimal
    var
        L_Location: Record Location;
        L_KNAPPLocationcode: Code[250];
        Query_SalesLineQty: Query "Sales Line Qty Liferay";
        Query_PickQty: Query "Pick Qty LifeRay";
        Query_InventoryFromILE: Query "Inventory From ILE";
        L_ItemLadgerEntry: Record "Item Ledger Entry";
        L_SalesLine: Record "Sales Line";
        L_WarehouseActivityLine: Record "Warehouse Activity Line";
        L_TotalInventory: Decimal;
        L_AllocatedOnSo: Decimal;
        L_AllocatedOnPick: Decimal;
        L_ExculdedQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_TotalQty: Decimal;
    begin
        Clear(L_TotalQty);

        //Get KNAPP Location++
        L_Location.Reset();
        L_Location.SetRange("Knapp Location", true);
        if L_Location.FindSet() then begin
            repeat
                if L_KNAPPLocationcode <> '' then begin
                    L_KNAPPLocationcode := L_KNAPPLocationcode + '|' + L_Location.Code;
                end else
                    L_KNAPPLocationcode := L_Location.Code;
            until L_Location.Next() = 0;
        end else
            exit(0);

        #Region Calculate Qty++++
        //Total Inventory from ILE
        Clear(L_TotalInventory);
        L_ItemLadgerEntry.Reset();
        L_ItemLadgerEntry.SetRange("Item No.", _ItemNo);
        if _VariantCode <> '' then
            L_ItemLadgerEntry.SetRange("Variant Code", _VariantCode);
        L_ItemLadgerEntry.SetRange("Location Code", L_KNAPPLocationcode);
        L_ItemLadgerEntry.SetFilter(SystemCreatedAt, '>%1', _LastInvemtorySyncDatetime);
        L_ItemLadgerEntry.CalcSums("Quantity");
        L_TotalInventory := L_ItemLadgerEntry."Quantity";
        if L_TotalInventory < 0 then
            L_TotalInventory := 0;



        //Total Allocated On SO++
        Clear(L_AllocatedOnSo);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("No.", _ItemNo);
        if _VariantCode <> '' then
            L_SalesLine.SetRange("Variant Code", _VariantCode);
        L_SalesLine.SetRange("Location Code", L_KNAPPLocationcode);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        L_SalesLine.SetFilter("SystemCreatedAt", '>%1', _LastInvemtorySyncDatetime);
        L_SalesLine.SetRange("Type", L_SalesLine.Type::Item);
        L_SalesLine.CalcSums("Outstanding Qty. (Base)");
        L_AllocatedOnSo := L_SalesLine."Outstanding Qty. (Base)";
        if L_AllocatedOnSo < 0 then
            L_AllocatedOnSo := 0;


        //Not required for sigma as we are not creating pick for KNAPP location.To ignore performance issue have commented the code ++++
        //Total Allocated on Pick++
        // Clear(L_AllocatedOnPick);
        // L_WarehouseActivityLine.Reset();
        // L_WarehouseActivityLine.SetRange("Item No.", _ItemNo);
        // if _VariantCode <> '' then
        //     L_WarehouseActivityLine.SetRange("Variant Code", _VariantCode);
        // L_WarehouseActivityLine.SetRange("Location Code", L_KNAPPLocationcode);
        // L_WarehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
        // L_WarehouseActivityLine.SetFilter("SystemCreatedAt", '>%1', _LastInvemtorySyncDatetime);
        // L_WarehouseActivityLine.SetRange("Activity Type", L_WarehouseActivityLine."Activity Type"::Pick);
        // L_WarehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
        // L_AllocatedOnPick := L_WarehouseActivityLine."Qty. Outstanding (Base)";
        // if L_AllocatedOnPick < 0 then
        //     L_AllocatedOnPick := 0;




        L_TotalQty := Abs(L_TotalInventory) + L_AllocatedOnSo;
        if L_TotalQty < 0 then
            L_TotalQty := 0;
        exit(L_TotalQty);
        #EndRegion Calculate Qty++++
    end;
}