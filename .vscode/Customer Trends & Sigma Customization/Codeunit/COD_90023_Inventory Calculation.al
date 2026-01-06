codeunit 90023 "Inventory Calculation"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;
    //++++++++++++++++++++++++++++++++++++++++++++Customer Trends+++++++++++++++++++++++++++++++++++++++++++++++++++
    // procedure CT_TotalFree(_Rec: Record CustomerTrends) _TotalFree: Decimal
    // begin
    //     _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    //     _Rec.CalcFields("Total Physical", "Total Allocated on SO", "Web Orders Qty", "Qty On Customer Trends");
    //     _TotalFree := _Rec."Total Physical" - (_Rec."Total Allocated on SO" + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");
    //     if _TotalFree > 0 then
    //         exit(_TotalFree)
    //     else
    //         exit(0);
    // end;

    // procedure CT_Free(_Rec: Record CustomerTrends) _Free: Decimal
    // begin
    //     _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    //     _Rec.CalcFields(Physical, "Allocated on SO", "Web Orders Qty", "Qty On Customer Trends");
    //     _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");
    //     if _Free > 0 then
    //         Exit(_Free)
    //     else
    //         exit(0);
    // end;


    procedure CT_Onvalidate_Free(_Rec: Record CustomerTrends) _Free: Decimal
    var
        L_CstomerTrend: Record CustomerTrends;
        _CurrentLineQty: Decimal;
        L_ExcludeQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        _Physical: Decimal;
        L_SalesLine: Record "Sales Line";
        _AllocatedOnSO: Decimal;
        L_HasVariantSetup: Boolean;
        _QtyonPick: Decimal;
        L_warehouseActivityLine: Record "Warehouse Activity Line";


        Query_ILEQuantity: Query "ILE Quantity Query";
        Query_SalesLineQuantity: Query "SalesLine Quantity Query";
        Query_PickQuantity: Query "Pick Quantity Query";
    begin
        // Cache current line qty
        Clear(_CurrentLineQty);
        L_CstomerTrend.Reset();
        L_CstomerTrend.SetRange("Entry Number", _Rec."Entry Number");
        L_CstomerTrend.SetRange("Line No.", _Rec."Line No.");
        if L_CstomerTrend.FindFirst() then
            _CurrentLineQty := L_CstomerTrend."Qty. to be added to SO";
        if _CurrentLineQty < 0 then
            _CurrentLineQty := 0;

        // Cache variant setup result
        Clear(L_HasVariantSetup);
        L_HasVariantSetup := GetVariantSetup(_Rec."Item No.");

        //Physical+++
        Clear(_Physical);
        Clear(Query_ILEQuantity);
        Query_ILEQuantity.SetRange(Query_ILEQuantity.Item_No_, _Rec."Item No.");
        Query_ILEQuantity.SetRange(Query_ILEQuantity.Saleable_Location, true);
        Query_ILEQuantity.SetRange(Query_ILEQuantity.Daily_Priority_Exist, L_HasVariantSetup);
        Query_ILEQuantity.Open();
        while Query_ILEQuantity.Read() do begin
            _Physical += Query_ILEQuantity.Remaining_Quantity;
        end;
        if _Physical < 0 then
            _Physical := 0;


        //ALlocated On SO++
        Clear(_AllocatedOnSO);
        Clear(Query_SalesLineQuantity);
        Query_SalesLineQuantity.SetRange(Query_SalesLineQuantity.Document_Type, Query_SalesLineQuantity.Document_Type::Order);
        Query_SalesLineQuantity.SetRange(Query_SalesLineQuantity.Type, Query_SalesLineQuantity.Type::Item);
        Query_SalesLineQuantity.SetRange(Query_SalesLineQuantity.No_, _Rec."Item No.");
        Query_SalesLineQuantity.SetRange(Query_SalesLineQuantity.Saleable_Location, true);
        Query_SalesLineQuantity.SetFilter(Query_SalesLineQuantity.Shipment_Date, '>=%1', WorkDate());
        Query_SalesLineQuantity.Open();
        while Query_SalesLineQuantity.Read() do begin
            _AllocatedOnSO += Query_SalesLineQuantity.Outstanding_Qty___Base_;
        end;
        if _AllocatedOnSO < 0 then
            _AllocatedOnSO := 0;

        //Qty on Pick++ SBB-579
        Clear(_QtyonPick);
        Clear(Query_PickQuantity);
        Query_PickQuantity.SetRange(Query_PickQuantity.Source_Document, Query_PickQuantity.Source_Document::"Sales Order");
        Query_PickQuantity.SetRange(Query_PickQuantity.Saleable_Location, true);
        Query_PickQuantity.SetRange(Query_PickQuantity.Item_No_, _Rec."Item No.");
        Query_PickQuantity.SetFilter(Query_PickQuantity.Shipment_Date, '<%1', WorkDate());
        Query_PickQuantity.Open();
        while Query_PickQuantity.Read() do begin
            _QtyonPick += Query_PickQuantity.Qty__Outstanding__Base_;
        end;
        if _QtyonPick < 0 then
            _QtyonPick := 0;

        //Web Order Qty++
        _Rec.CalcFields("Web Orders Qty", "Qty On Customer Trends");

        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."Item No.");
        L_BinContent.SetRange("Saleable Location", true);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."Item No."));
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty < 0 then
            L_ExcludeQty := 0;

        //Free++
        Clear(_Free);
        _Free := (_Physical + _CurrentLineQty) - (_AllocatedOnSO + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends" + L_ExcludeQty + _QtyonPick);
        if _Free < 0 then
            _Free := 0;
        Exit(_Free);

    end;
    //--------------------------------------------Customer Trends---------------------------------------------------



    //++++++++++++++++++++++++++++++++++++++++Sales Order++++++++++++++++++++++++++++++++++++++++
    // procedure Sales_TotalFree(_Rec: Record "Sales Line") _TotalFree: Decimal
    // begin
    //     _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    //     _Rec.CalcFields("Total Physical", "Total Allocated on SO", "Web Orders Qty");
    //     _TotalFree := _Rec."Total Physical" - (_Rec."Total Allocated on SO" + _Rec."Web Orders Qty");
    //     if _TotalFree > 0 then
    //         exit(_TotalFree)
    //     else
    //         exit(0);
    // end;

    // procedure Sales_Free(_Rec: Record "Sales Line") _Free: Decimal
    // begin
    //     _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    //     _Rec.CalcFields("Allocated on SO", Physical, "Web Orders Qty");
    //     _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty");
    //     if _Free > 0 then
    //         exit(_Free)
    //     else
    //         exit(0);
    // end;

    procedure Sales_CheckFreeQuantity_OnValidate(_Rec: Record "Sales Line") _Free: Decimal
    var
        // L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        //L_Location: Record Location;
        //L_ExcludeQty: Decimal;
        //L_warehouseActivityLine: Record "Warehouse Activity Line";
        L_BinContent: Record "Bin Content";
        L_HasVariantSetup: Boolean;


        //Total Item wise++
        _TotalPhysical_Item_VariantWise: Decimal;
        _AllocatedOnSO_Item_VariantWise: Decimal;
        _AllocatedOnSO_SameOrderDifferentLine_Item_VariantWise: Decimal;
        _TotalFreeQty_Item_VariantWise: Decimal;
        L_ExcludeQty_Item_VariantWise: Decimal;
        _QtyonPick_Item_VariantWise: Decimal;


        //Total Item wise+++
        _TotalPhysical_ItemWise: Decimal;
        _AllocatedOnSO_ItemWise: Decimal;
        _AllocatedOnSO_SameOrderDifferentLine_ItemWise: Decimal;
        _TotalFreeQty_ItemWise: Decimal;
        L_ExcludeQty_ItemWise: Decimal;
        _QtyonPick_ItemWise: Decimal;


        Query_ILEQuantity: Query "ILE Quantity Query";
        Query_SalesLineQuantity: Query "SalesLine Quantity Query";
        Query_PickQuantity: Query "Pick Quantity Query";
    begin
        _Rec.CalcFields("Saleable Location");

        // Cache variant setup result
        Clear(L_HasVariantSetup);
        L_HasVariantSetup := GetVariantSetup(_Rec."No.");

        //Total Physical only Item Wise Qty++
        Clear(_TotalPhysical_ItemWise);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _Rec."No.");
        IF _Rec."Saleable Location" = false then
            L_ItemLedgerEntry.SetRange("Location Code", _Rec."Location Code")
        else begin
            L_ItemLedgerEntry.SetRange("Daily Priority Exist", L_HasVariantSetup);
            L_ItemLedgerEntry.SetRange("Saleable Location", true);
        end;
        L_ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
        L_ItemLedgerEntry.CalcSums("Remaining Quantity");
        _TotalPhysical_ItemWise := L_ItemLedgerEntry."Remaining Quantity";
        if _TotalPhysical_ItemWise < 0 then
            _TotalPhysical_ItemWise := 0;
        // Clear(Query_ILEQuantity);
        // Query_ILEQuantity.SetRange(Item_No_, _Rec."No.");
        // if _Rec."Saleable Location" = false then begin
        //     Query_ILEQuantity.SetRange(Location_Code, _Rec."Location Code")
        // end else begin
        //     Query_ILEQuantity.SetFilter(Daily_Priority_Exist, '%1', L_HasVariantSetup);
        //     Query_ILEQuantity.SetRange(Saleable_Location, true);
        // end;
        // Query_ILEQuantity.Open();
        // if Query_ILEQuantity.Read() then
        //     _TotalPhysical_ItemWise := Query_ILEQuantity.Remaining_Quantity;
        // if _TotalPhysical_ItemWise < 0 then
        //     _TotalPhysical_ItemWise := 0;

        //Allocated On SO existing Orders Item wise+++
        Clear(_AllocatedOnSO_ItemWise);
        Clear(Query_SalesLineQuantity);
        Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
        Query_SalesLineQuantity.SetFilter(Query_SalesLineQuantity.Document_No_, '<>%1', _Rec."Document No.");
        Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
        Query_SalesLineQuantity.SetRange(No_, _Rec."No.");
        if _Rec."Saleable Location" = false then
            Query_SalesLineQuantity.SetRange(Location_Code, _Rec."Location Code")
        else
            Query_SalesLineQuantity.SetRange(Saleable_Location, true);
        Query_SalesLineQuantity.SetFilter(Shipment_Date, '>=%1', WorkDate());
        Query_SalesLineQuantity.Open();
        while Query_SalesLineQuantity.Read() do begin
            _AllocatedOnSO_ItemWise += Query_SalesLineQuantity.Outstanding_Qty___Base_;
        end;
        if _AllocatedOnSO_ItemWise < 0 then
            _AllocatedOnSO_ItemWise := 0;

        //Allocated On Current SO Order but different lines Item wise+++
        Clear(_AllocatedOnSO_SameOrderDifferentLine_ItemWise);
        Clear(Query_SalesLineQuantity);
        Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
        Query_SalesLineQuantity.SetRange(Query_SalesLineQuantity.Document_No_, _Rec."Document No.");
        Query_SalesLineQuantity.SetFilter(Query_SalesLineQuantity.Line_No_, '<>%1', _Rec."Line No.");
        Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
        Query_SalesLineQuantity.SetRange(No_, _Rec."No.");
        if _Rec."Saleable Location" = false then
            Query_SalesLineQuantity.SetRange(Location_Code, _Rec."Location Code")
        else
            Query_SalesLineQuantity.SetRange(Saleable_Location, true);
        Query_SalesLineQuantity.SetFilter(Shipment_Date, '>=%1', WorkDate());
        Query_SalesLineQuantity.Open();
        while Query_SalesLineQuantity.Read() do begin
            _AllocatedOnSO_SameOrderDifferentLine_ItemWise += Query_SalesLineQuantity.Outstanding_Qty___Base_;
        end;
        if _AllocatedOnSO_SameOrderDifferentLine_ItemWise < 0 then
            _AllocatedOnSO_SameOrderDifferentLine_ItemWise := 0;


        //Qty on Pick item wise++ SBB-579
        Clear(_QtyonPick_ItemWise);
        Clear(Query_PickQuantity);
        Query_PickQuantity.SetRange(Query_PickQuantity.Source_Document, Query_PickQuantity.Source_Document::"Sales Order");
        Query_PickQuantity.SetRange(Query_PickQuantity.Item_No_, _Rec."No.");
        if _Rec."Saleable Location" = true then
            Query_PickQuantity.SetRange(Query_PickQuantity.Saleable_Location, true)
        else
            Query_PickQuantity.SetRange(Query_PickQuantity.Location_Code, _Rec."Location Code");
        Query_PickQuantity.SetFilter(Query_PickQuantity.Shipment_Date, '<%1', WorkDate());
        Query_PickQuantity.Open();
        while Query_PickQuantity.Read() do begin
            _QtyonPick_ItemWise += Query_PickQuantity.Qty__Outstanding__Base_;
        end;
        if _QtyonPick_ItemWise < 0 then
            _QtyonPick_ItemWise := 0;

        //Calculate excluding Bin Qty item wise++
        Clear(L_ExcludeQty_ItemWise);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."No.");
        if _Rec."Saleable Location" = true then begin
            L_BinContent.SetRange("Location Code", _Rec."Location Code");
            L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."No."));
        end else
            L_BinContent.SetRange("Location Code", _Rec."Location Code");
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty_ItemWise += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty_ItemWise < 0 then
            L_ExcludeQty_ItemWise := 0;

        //Web Qty Item wise++
        _Rec.CalcFields("Web Orders Qty");

        //Calculate Final Free Qty++
        if _Rec."Saleable Location" = true then begin
            //Total Free qty item wise++
            Clear(_TotalFreeQty_ItemWise);
            _TotalFreeQty_ItemWise := _TotalPhysical_ItemWise - (_AllocatedOnSO_ItemWise + _AllocatedOnSO_SameOrderDifferentLine_ItemWise + _Rec."Web Orders Qty" + L_ExcludeQty_ItemWise + _QtyonPick_ItemWise);
            if _Rec.Quantity > _TotalFreeQty_ItemWise then begin
                _Free := _TotalFreeQty_ItemWise;
                exit(_Free);
            end;

            //Total Physical Qty Item & Variant Wise
            Clear(_TotalPhysical_Item_VariantWise);
            L_ItemLedgerEntry.Reset();
            L_ItemLedgerEntry.SetRange("Item No.", _Rec."No.");
            IF _Rec."Saleable Location" = false then
                L_ItemLedgerEntry.SetRange("Location Code", _Rec."Location Code")
            else begin
                L_ItemLedgerEntry.SetRange("Daily Priority Exist", L_HasVariantSetup);
                L_ItemLedgerEntry.SetRange("Saleable Location", true);
            end;
            L_ItemLedgerEntry.SetRange("Variant Code", _Rec."Variant Code");
            L_ItemLedgerEntry.SetFilter("Remaining Quantity", '>%1', 0);
            L_ItemLedgerEntry.CalcSums("Remaining Quantity");
            _TotalPhysical_Item_VariantWise := L_ItemLedgerEntry."Remaining Quantity";
            if _TotalPhysical_Item_VariantWise < 0 then
                _TotalPhysical_Item_VariantWise := 0;
            // Clear(Query_ILEQuantity);
            // Query_ILEQuantity.SetRange(Item_No_, _Rec."No.");
            // if _Rec."Saleable Location" = false then begin
            //     Query_ILEQuantity.SetRange(Location_Code, _Rec."Location Code")
            // end else begin
            //     Query_ILEQuantity.SetRange(Saleable_Location, true);
            //     Query_ILEQuantity.SetRange(Daily_Priority_Exist, L_HasVariantSetup);
            // end;
            // Query_ILEQuantity.SetRange(Variant_Code, _Rec."Variant Code");
            // Query_ILEQuantity.Open();
            // if Query_ILEQuantity.Read() then
            //     _TotalPhysical_Item_VariantWise := Query_ILEQuantity.Remaining_Quantity;
            // if _TotalPhysical_Item_VariantWise < 0 then
            //     _TotalPhysical_Item_VariantWise := 0;


            //Allocated On SO Existing Order item & Variant Wise
            Clear(_AllocatedOnSO_Item_VariantWise);
            Clear(Query_SalesLineQuantity);
            Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
            Query_SalesLineQuantity.SetFilter(Query_SalesLineQuantity.Document_No_, '<>%1', _Rec."Document No.");
            Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
            Query_SalesLineQuantity.SetRange(No_, _Rec."No.");
            if _Rec."Saleable Location" = false then
                Query_SalesLineQuantity.SetRange(Location_Code, _Rec."Location Code")
            else
                Query_SalesLineQuantity.SetRange(Saleable_Location, true);
            Query_SalesLineQuantity.SetFilter(Shipment_Date, '>=%1', WorkDate());
            Query_SalesLineQuantity.SetRange(Variant_Code, _Rec."Variant Code");
            Query_SalesLineQuantity.Open();
            while Query_SalesLineQuantity.Read() do begin
                _AllocatedOnSO_Item_VariantWise += Query_SalesLineQuantity.Outstanding_Qty___Base_;
            end;
            if _AllocatedOnSO_Item_VariantWise < 0 then
                _AllocatedOnSO_Item_VariantWise := 0;

            //Allocated On SO Order Item & Variant Wise
            Clear(_AllocatedOnSO_SameOrderDifferentLine_Item_VariantWise);
            Clear(Query_SalesLineQuantity);
            Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
            Query_SalesLineQuantity.SetRange(Query_SalesLineQuantity.Document_No_, _Rec."Document No.");
            Query_SalesLineQuantity.SetFilter(Query_SalesLineQuantity.Line_No_, '<>%1', _Rec."Line No.");
            Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
            Query_SalesLineQuantity.SetRange(No_, _Rec."No.");
            if _Rec."Saleable Location" = false then
                Query_SalesLineQuantity.SetRange(Location_Code, _Rec."Location Code")
            else
                Query_SalesLineQuantity.SetRange(Saleable_Location, true);
            Query_SalesLineQuantity.SetFilter(Shipment_Date, '>=%1', WorkDate());
            Query_SalesLineQuantity.SetRange(Variant_Code, _Rec."Variant Code");
            Query_SalesLineQuantity.Open();
            while Query_SalesLineQuantity.Read() do begin
                _AllocatedOnSO_SameOrderDifferentLine_Item_VariantWise += Query_SalesLineQuantity.Outstanding_Qty___Base_;
            end;
            if _AllocatedOnSO_SameOrderDifferentLine_Item_VariantWise < 0 then
                _AllocatedOnSO_SameOrderDifferentLine_Item_VariantWise := 0;

            //Qty on Pick item wise & Variant Wise++ SBB-579
            Clear(_QtyonPick_Item_VariantWise);
            Clear(Query_PickQuantity);
            Query_PickQuantity.SetRange(Query_PickQuantity.Source_Document, Query_PickQuantity.Source_Document::"Sales Order");
            Query_PickQuantity.SetRange(Query_PickQuantity.Item_No_, _Rec."No.");
            if _Rec."Saleable Location" = true then
                Query_PickQuantity.SetRange(Query_PickQuantity.Saleable_Location, true)
            else
                Query_PickQuantity.SetRange(Query_PickQuantity.Location_Code, _Rec."Location Code");
            Query_PickQuantity.SetFilter(Query_PickQuantity.Shipment_Date, '<%1', WorkDate());
            Query_PickQuantity.SetRange(Variant_Code, _Rec."Variant Code");
            Query_PickQuantity.Open();
            while Query_PickQuantity.Read() do begin
                _QtyonPick_Item_VariantWise += Query_PickQuantity.Qty__Outstanding__Base_;
            end;
            if _QtyonPick_Item_VariantWise < 0 then
                _QtyonPick_Item_VariantWise := 0;

            //Calculate excluding Bin Qty item  & variant wise++
            Clear(L_ExcludeQty_Item_VariantWise);
            L_BinContent.Reset();
            L_BinContent.SetRange("Item No.", _Rec."No.");
            if _Rec."Saleable Location" = true then begin
                L_BinContent.SetRange("Location Code", _Rec."Location Code");
                L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."No."));
            end else
                L_BinContent.SetRange("Location Code", _Rec."Location Code");
            L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
            L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
            L_BinContent.SetRange("Variant Code", _Rec."Variant Code");
            if L_BinContent.FindSet() then begin
                repeat
                    L_BinContent.CalcFields("Quantity (Base)");
                    L_ExcludeQty_Item_VariantWise += L_BinContent."Quantity (Base)";
                until L_BinContent.Next() = 0;
            end;
            if L_ExcludeQty_Item_VariantWise < 0 then
                L_ExcludeQty_Item_VariantWise := 0;

            Clear(_TotalFreeQty_Item_VariantWise);
            _TotalFreeQty_Item_VariantWise := _TotalPhysical_Item_VariantWise - (_AllocatedOnSO_Item_VariantWise + _AllocatedOnSO_SameOrderDifferentLine_Item_VariantWise + L_ExcludeQty_Item_VariantWise + _QtyonPick_Item_VariantWise);
            if _TotalFreeQty_Item_VariantWise < 0 then
                _TotalFreeQty_Item_VariantWise := 0;

            //Final Free Qty++
            Clear(_Free);
            _Free := _TotalFreeQty_Item_VariantWise;
            exit(_Free);
        end else begin
            //Total Free qty item wise++
            Clear(_TotalFreeQty_ItemWise);
            _TotalFreeQty_ItemWise := _TotalPhysical_ItemWise - (_AllocatedOnSO_ItemWise + _AllocatedOnSO_SameOrderDifferentLine_ItemWise + L_ExcludeQty_ItemWise + _QtyonPick_ItemWise);
            _Free := _TotalFreeQty_ItemWise;
            exit(_Free);
        end;
    end;

    procedure Upload_CheckFreeQuantity_OnValidate(_ItemNo: Code[20]; _VariantCode: Code[20]; _LocationCode: Code[20]; _RequestedQuantity: Decimal) _Free: Decimal
    var
        L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        _Physical: Decimal;
        _AllocatedOnSO: Decimal;
        L_Location: Record Location;
        L_SaleableLocation: Boolean;
        L_WebOrderQty: Decimal;
        L_Item: Record Item;
        L_ExcludeQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_HasVariantSetup: Boolean;
        L_warehouseActivityLine: Record "Warehouse Activity Line";


        //Total Item wise++
        _TotalPhysical_Item_VariantWise: Decimal;
        _AllocatedOnSO_Item_VariantWise: Decimal;
        _TotalFreeQty_Item_VariantWise: Decimal;
        L_ExcludeQty_Item_VariantWise: Decimal;
        _QtyonPick_Item_VariantWise: Decimal;

        //Total Item wise+++
        _TotalPhysical_ItemWise: Decimal;
        _AllocatedOnSO_ItemWise: Decimal;
        _TotalFreeQty_ItemWise: Decimal;
        L_ExcludeQty_ItemWise: Decimal;
        _QtyonPick_ItemWise: Decimal;
    begin
        //Check if Location is Saleable Location or not++
        Clear(L_SaleableLocation);
        L_Location.Reset();
        L_Location.SetRange(Code, _LocationCode);
        if L_Location.FindFirst() then
            if L_Location."Saleable Location" = true then
                L_SaleableLocation := true
            else
                L_SaleableLocation := false;

        // Cache variant setup result
        Clear(L_HasVariantSetup);
        L_HasVariantSetup := GetVariantSetup(_ItemNo);

        //Total Physical only Item Wise Qty++
        Clear(_TotalPhysical_ItemWise);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation = false then
            L_ItemLedgerEntry.SetRange("Location Code", _LocationCode)
        else begin
            L_ItemLedgerEntry.SetRange("Saleable Location", true);
            L_ItemLedgerEntry.SetRange("Daily Priority Exist", L_HasVariantSetup);
        end;
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            _TotalPhysical_ItemWise := L_ItemLedgerEntry.Quantity;
        end;
        if _TotalPhysical_ItemWise < 0 then
            _TotalPhysical_ItemWise := 0;

        //Allocated On SO existing Orders Item wise+++
        Clear(_AllocatedOnSO_ItemWise);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("No.", _ItemNo);
        if L_SaleableLocation = false then
            L_SalesLine.SetRange("Location Code", _LocationCode)
        else
            L_SalesLine.SetRange("Saleable Location", true);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            _AllocatedOnSO_ItemWise := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if _AllocatedOnSO_ItemWise < 0 then
            _AllocatedOnSO_ItemWise := 0;

        //Qty on Pick item wise++ SBB-579
        Clear(_QtyonPick_ItemWise);
        L_warehouseActivityLine.Reset();
        L_warehouseActivityLine.SetRange("Source Document", L_warehouseActivityLine."Source Document"::"Sales Order");
        L_warehouseActivityLine.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation = false then
            L_warehouseActivityLine.SetRange("Location Code", _LocationCode)
        else
            L_warehouseActivityLine.SetRange("Saleable Location", true);
        L_warehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
        if L_warehouseActivityLine.FindSet() then begin
            L_warehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
            _QtyonPick_ItemWise := L_warehouseActivityLine."Qty. Outstanding (Base)";
        end;
        if _QtyonPick_ItemWise < 0 then
            _QtyonPick_ItemWise := 0;

        //Calculate excluding Bin Qty item wise++
        Clear(L_ExcludeQty_ItemWise);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation = true then begin
            L_BinContent.SetRange("Location Code", _LocationCode);
            L_BinContent.SetRange("Daily Priority Exist", L_HasVariantSetup);
        end else
            L_BinContent.SetRange("Location Code", _LocationCode);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty_ItemWise += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty_ItemWise < 0 then
            L_ExcludeQty_ItemWise := 0;

        //Web Order Qty++
        Clear(L_WebOrderQty);
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            L_Item.CalcFields("Qty. on Web Order");
            L_WebOrderQty := L_Item."Qty. on Web Order";
        end;


        //Calculate Final Free Qty++
        if L_SaleableLocation = true then begin
            //Total Free qty item wise++
            Clear(_TotalFreeQty_ItemWise);
            _TotalFreeQty_ItemWise := _TotalPhysical_ItemWise - (_AllocatedOnSO_ItemWise + L_WebOrderQty + L_ExcludeQty_ItemWise + _QtyonPick_ItemWise);
            if _RequestedQuantity > _TotalFreeQty_ItemWise then begin
                _Free := _TotalFreeQty_ItemWise;
                exit(_Free);
            end;

            //Total Physical Qty Item & Variant Wise
            Clear(_TotalPhysical_Item_VariantWise);
            L_ItemLedgerEntry.Reset();
            L_ItemLedgerEntry.SetRange("Item No.", _ItemNo);
            if L_SaleableLocation = false then
                L_ItemLedgerEntry.SetRange("Location Code", _LocationCode)
            else begin
                L_ItemLedgerEntry.SetRange("Saleable Location", true);
                L_ItemLedgerEntry.SetRange("Daily Priority Exist", L_HasVariantSetup);
            end;
            L_ItemLedgerEntry.SetRange("Variant Code", _VariantCode);
            if L_ItemLedgerEntry.FindSet() then begin
                L_ItemLedgerEntry.CalcSums(Quantity);
                _TotalPhysical_Item_VariantWise := L_ItemLedgerEntry.Quantity;
            end;
            if _TotalPhysical_Item_VariantWise < 0 then
                _TotalPhysical_Item_VariantWise := 0;

            //Allocated On SO Existing Order item & Variant Wise
            Clear(_AllocatedOnSO_Item_VariantWise);
            L_SalesLine.Reset();
            L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
            L_SalesLine.SetRange("No.", _ItemNo);
            if L_SaleableLocation = false then
                L_SalesLine.SetRange("Location Code", _LocationCode)
            else
                L_SalesLine.SetRange("Saleable Location", true);
            L_SalesLine.SetRange("Variant Code", _VariantCode);
            L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
            if L_SalesLine.FindSet() then begin
                L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                _AllocatedOnSO_Item_VariantWise := L_SalesLine."Outstanding Qty. (Base)";
            end;
            if _AllocatedOnSO_Item_VariantWise < 0 then
                _AllocatedOnSO_Item_VariantWise := 0;

            //Qty on Pick item wise & Variant Wise++ SBB-579
            Clear(_QtyonPick_Item_VariantWise);
            L_warehouseActivityLine.Reset();
            L_warehouseActivityLine.SetRange("Source Document", L_warehouseActivityLine."Source Document"::"Sales Order");
            L_warehouseActivityLine.SetRange("Item No.", _ItemNo);
            if L_SaleableLocation = false then
                L_warehouseActivityLine.SetRange("Location Code", _LocationCode)
            else
                L_warehouseActivityLine.SetRange("Saleable Location", true);
            L_warehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
            L_warehouseActivityLine.SetRange("Variant Code", _VariantCode);
            if L_warehouseActivityLine.FindSet() then begin
                L_warehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
                _QtyonPick_Item_VariantWise := L_warehouseActivityLine."Qty. Outstanding (Base)";
            end;
            if _QtyonPick_Item_VariantWise < 0 then
                _QtyonPick_Item_VariantWise := 0;


            //Calculate excluding Bin Qty item  & variant wise++
            Clear(L_ExcludeQty_Item_VariantWise);
            L_BinContent.Reset();
            L_BinContent.SetRange("Item No.", _ItemNo);
            if L_SaleableLocation = true then begin
                L_BinContent.SetRange("Location Code", _LocationCode);
                L_BinContent.SetRange("Daily Priority Exist", L_HasVariantSetup);
            end else
                L_BinContent.SetRange("Location Code", _LocationCode);
            L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
            L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
            L_BinContent.SetRange("Variant Code", _VariantCode);
            if L_BinContent.FindSet() then begin
                repeat
                    L_BinContent.CalcFields("Quantity (Base)");
                    L_ExcludeQty_Item_VariantWise += L_BinContent."Quantity (Base)";
                until L_BinContent.Next() = 0;
            end;
            if L_ExcludeQty_Item_VariantWise < 0 then
                L_ExcludeQty_Item_VariantWise := 0;

            Clear(_TotalFreeQty_Item_VariantWise);
            _TotalFreeQty_Item_VariantWise := _TotalPhysical_Item_VariantWise - (_AllocatedOnSO_Item_VariantWise + L_ExcludeQty_Item_VariantWise + _QtyonPick_Item_VariantWise);
            if _TotalFreeQty_Item_VariantWise < 0 then
                _TotalFreeQty_Item_VariantWise := 0;

            //Final Free Qty++
            Clear(_Free);
            _Free := _TotalFreeQty_Item_VariantWise;
            exit(_Free);
        end else begin
            //Total Free qty item wise++
            Clear(_TotalFreeQty_ItemWise);
            _TotalFreeQty_ItemWise := _TotalPhysical_ItemWise - (_AllocatedOnSO_ItemWise + L_ExcludeQty_ItemWise + _QtyonPick_ItemWise);
            _Free := _TotalFreeQty_ItemWise;
            exit(_Free);
        end;
    end;


    procedure UploadIRP_CheckFreeQuantity_OnValidate(_ItemNo: Code[20]; _VariantCode: Code[20]; _LocationCode: Code[20]) _Free: Decimal
    var
        L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        _Physical: Decimal;
        _AllocatedOnSO: Decimal;
        L_Location: Record Location;
        L_SaleableLocation: Boolean;
        L_WebOrderQty: Decimal;
        L_Item: Record Item;
        L_ExcludeQty: Decimal;
        L_BinContent: Record "Bin Content";
        L_HasVariantSetup: Boolean;
        _QtyonPick: Decimal;
        L_warehouseActivityLine: Record "Warehouse Activity Line";
    begin
        // Cache variant setup result
        Clear(L_HasVariantSetup);
        L_HasVariantSetup := GetVariantSetup(_ItemNo);

        //Pysical+++
        Clear(_Physical);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _ItemNo);
        L_ItemLedgerEntry.SetRange("Saleable Location", true);
        L_ItemLedgerEntry.SetRange("Daily Priority Exist", L_HasVariantSetup);
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            _Physical := L_ItemLedgerEntry.Quantity;
        end;
        if _Physical < 0 then
            _Physical := 0;


        //ALlocated On SO++
        Clear(_AllocatedOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("No.", _ItemNo);
        L_SalesLine.SetRange("Saleable Location", true);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            _AllocatedOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if _AllocatedOnSO < 0 then
            _AllocatedOnSO := 0;

        //Qty on Pick ++ SBB-579
        Clear(_QtyonPick);
        L_warehouseActivityLine.Reset();
        L_warehouseActivityLine.SetRange("Source Document", L_warehouseActivityLine."Source Document"::"Sales Order");
        L_warehouseActivityLine.SetRange("Item No.", _ItemNo);
        L_warehouseActivityLine.SetRange("Saleable Location", true);
        L_warehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
        if L_warehouseActivityLine.FindSet() then begin
            L_warehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
            _QtyonPick := L_warehouseActivityLine."Qty. Outstanding (Base)";
        end;
        if _QtyonPick < 0 then
            _QtyonPick := 0;

        //Web Order Qty++
        Clear(L_WebOrderQty);
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            L_Item.CalcFields("Qty. on Web Order");
            L_WebOrderQty := L_Item."Qty. on Web Order";
        end;
        if L_WebOrderQty < 0 then
            L_WebOrderQty := 0;

        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _ItemNo);
        L_BinContent.SetRange("Location Code", _LocationCode);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        L_BinContent.SetRange("Daily Priority Exist", L_HasVariantSetup);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty < 0 then
            L_ExcludeQty := 0;

        //Free Qty++
        Clear(_Free);
        if L_SaleableLocation = true then
            _Free := _Physical - (_AllocatedOnSO + L_WebOrderQty + _QtyonPick + L_ExcludeQty)
        else
            _Free := _Physical - _AllocatedOnSO - _QtyonPick + L_WebOrderQty;
        if _Free < 0 then
            _Free := 0;
        Exit(_Free);
    end;
    //----------------------------------------Sales Order----------------------------------------


    //++++++++++++++++++++++++++++++++++++++++Purcahse Order+++++++++++++++++++++++++++++++++++++
    // procedure Purchase_TotalFree(_Rec: Record "Purchase Line") _TotalFree: Decimal
    // begin
    //     _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    //     _Rec.CalcFields("Total Physical", "Total Allocated on SO", "Web Orders Qty");
    //     _TotalFree := _Rec."Total Physical" - (_Rec."Total Allocated on SO" + _Rec."Web Orders Qty");
    //     if _TotalFree > 0 then
    //         exit(_TotalFree)
    //     else
    //         exit(0);
    // end;


    // procedure Purchase_Free(_Rec: Record "Purchase Line") _Free: Decimal
    // begin
    //     _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    //     _Rec.CalcFields("Allocated on SO", Physical, "Web Orders Qty");
    //     _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty");
    //     if _Free > 0 then
    //         exit(_Free)
    //     else
    //         exit(0);
    // end;
    //----------------------------------------Purcahse Order-------------------------------------


    local procedure GetVariantSetup(_ItemNo: Code[20]): Boolean
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
}