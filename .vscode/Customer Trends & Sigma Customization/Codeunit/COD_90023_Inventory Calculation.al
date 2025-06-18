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
    begin
        Clear(_CurrentLineQty);
        L_CstomerTrend.Reset();
        L_CstomerTrend.SetRange("Entry Number", _Rec."Entry Number");
        L_CstomerTrend.SetRange("Line No.", _Rec."Line No.");
        if L_CstomerTrend.FindFirst() then
            _CurrentLineQty := L_CstomerTrend."Qty. to be added to SO";

        // _Rec.SetFilter("Date Filter", '>=%1', WorkDate());
        // _Rec.CalcFields(Physical, "Allocated on SO", "Web Orders Qty", "Qty On Customer Trends");
        // _Free := (_Rec.Physical + _CurrentLineQty) - (_Rec."Allocated on SO" + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");
        // if _Free > 0 then
        //     Exit(_Free)
        // else
        //     exit(0);


        //New Code+++
        //Pysical+++
        Clear(_Physical);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _Rec."Item No.");
        //L_ItemLedgerEntry.SetRange("Unit of Measure Code", _Rec."Units of Measure");
        L_ItemLedgerEntry.SetRange("Saleable Location", true);
        L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."Item No."));
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
        L_SalesLine.SetRange("No.", _Rec."Item No.");
        L_SalesLine.SetRange("Saleable Location", true);
        //L_SalesLine.SetRange("Unit of Measure Code", _Rec."Units of Measure");
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            _AllocatedOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if _AllocatedOnSO < 0 then
            _AllocatedOnSO := 0;

        //Web Order Qty++
        _Rec.CalcFields("Web Orders Qty", "Qty On Customer Trends");

        //Free++
        Clear(_Free);
        _Free := (_Physical + _CurrentLineQty) - (_AllocatedOnSO + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");


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

        if L_ExcludeQty > 0 then
            _Free := _Free - L_ExcludeQty;
        //Prathamesh-- SBB-291

        if _Free > 0 then
            Exit(_Free)
        else
            exit(0);

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
        L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        _Physical: Decimal;
        _AllocatedOnSO: Decimal;
        _AllocatedOnSO_SameOrderDifferentLine: Decimal;
        L_Location: Record Location;
        L_ExcludeQty: Decimal;
        L_BinContent: Record "Bin Content";
    begin
        _Rec.CalcFields("Saleable Location");

        //Physical Qty++
        Clear(_Physical);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _Rec."No.");
        //L_ItemLedgerEntry.SetRange("Unit of Measure Code", _Rec."Unit of Measure Code");
        if _Rec."Saleable Location" = false then
            L_ItemLedgerEntry.SetRange("Location Code", _Rec."Location Code")
        else begin
            //L_ItemLedgerEntry.SetRange("Saleable Location", true);
            L_ItemLedgerEntry.SetRange("Location Code", _Rec."Location Code");
            L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."No."));
        end;
        L_ItemLedgerEntry.SetRange("Variant Code", _Rec."Variant Code");
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            _Physical := L_ItemLedgerEntry.Quantity;
        end;
        if _Physical < 0 then
            _Physical := 0;


        //Allocated On SO Existing Order+++
        Clear(_AllocatedOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetFilter("Document No.", '<>%1', _Rec."Document No.");
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("No.", _Rec."No.");
        //L_SalesLine.SetRange("Unit of Measure Code", _Rec."Unit of Measure Code");
        // if _Rec."Saleable Location" = false then
        //     L_SalesLine.SetRange("Location Code", _Rec."Location Code")
        // else
        //     L_SalesLine.SetRange("Saleable Location", true);
        L_SalesLine.SetRange("Location Code", _Rec."Location Code");
        L_SalesLine.SetRange("Variant Code", _Rec."Variant Code");
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            _AllocatedOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if _AllocatedOnSO < 0 then
            _AllocatedOnSO := 0;


        //Allocated On SO Order+++
        Clear(_AllocatedOnSO_SameOrderDifferentLine);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange("Document No.", _Rec."Document No.");
        L_SalesLine.SetFilter("Line No.", '<>%1', _Rec."Line No.");
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("No.", _Rec."No.");
        //L_SalesLine.SetRange("Unit of Measure Code", _Rec."Unit of Measure Code");
        // if _Rec."Saleable Location" = false then
        //     L_SalesLine.SetRange("Location Code", _Rec."Location Code")
        // else
        //     L_SalesLine.SetRange("Saleable Location", true);
        L_SalesLine.SetRange("Location Code", _Rec."Location Code");
        L_SalesLine.SetRange("Variant Code", _Rec."Variant Code");
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            _AllocatedOnSO_SameOrderDifferentLine := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if _AllocatedOnSO_SameOrderDifferentLine < 0 then
            _AllocatedOnSO_SameOrderDifferentLine := 0;

        //Web Qty++
        _Rec.CalcFields("Web Orders Qty");

        //Free Qty++
        Clear(_Free);
        if _Rec."Saleable Location" = true then
            _Free := _Physical - (_AllocatedOnSO + _AllocatedOnSO_SameOrderDifferentLine + _Rec."Web Orders Qty")
        else
            _Free := _Physical - (_AllocatedOnSO + _AllocatedOnSO_SameOrderDifferentLine);

        //Rec Bin Qty++
        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."No.");
        if _Rec."Saleable Location" = true then begin
            //L_BinContent.SetRange("Saleable Location", true);
            L_BinContent.SetRange("Location Code", _Rec."Location Code");
            L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."No."));
        end else
            L_BinContent.SetRange("Location Code", _Rec."Location Code");
        L_BinContent.SetRange("Variant Code", _Rec."Variant Code");
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;

        if L_ExcludeQty > 0 then
            _Free := _Free - L_ExcludeQty;
        //Prathamesh-- SBB-291

        if _Free > 0 then
            exit(_Free)
        else
            exit(0);
    end;

    procedure SalesQuote_CheckFreeQuantity_OnValidate(_Rec: Record "Sales Line") _Free: Decimal
    var
        L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        _Physical: Decimal;
        _AllocatedOnSO: Decimal;
        L_ExcludeQty: Decimal;
        L_BinContent: Record "Bin Content";
    begin
        _Rec.CalcFields("Saleable Location");

        //Physical Qty++
        Clear(_Physical);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _Rec."No.");
        //L_ItemLedgerEntry.SetRange("Unit of Measure Code", _Rec."Unit of Measure Code");
        if _Rec."Saleable Location" = false then
            L_ItemLedgerEntry.SetRange("Location Code", _Rec."Location Code")
        else begin
            //L_ItemLedgerEntry.SetRange("Saleable Location", true);
            L_ItemLedgerEntry.SetRange("Location Code", _Rec."Location Code");
            L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."No."));
        end;
        L_ItemLedgerEntry.SetRange("Variant Code", _Rec."Variant Code");
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            _Physical := L_ItemLedgerEntry.Quantity;
        end;
        if _Physical < 0 then
            _Physical := 0;



        Clear(_AllocatedOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("No.", _Rec."No.");
        //L_SalesLine.SetRange("Unit of Measure Code", _Rec."Unit of Measure Code");
        // if _Rec."Saleable Location" = false then
        //     L_SalesLine.SetRange("Location Code", _Rec."Location Code")
        // else
        //     L_SalesLine.SetRange("Saleable Location", true);
        L_SalesLine.SetRange("Location Code", _Rec."Location Code");
        L_SalesLine.SetRange("Variant Code", _Rec."Variant Code");
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            _AllocatedOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if _AllocatedOnSO < 0 then
            _AllocatedOnSO := 0;


        //Web Order Qty++
        _Rec.CalcFields("Web Orders Qty");


        //Free Qty++
        Clear(_Free);
        if _Rec."Saleable Location" = true then
            _Free := _Physical - (_AllocatedOnSO + _Rec."Web Orders Qty")
        else
            _Free := _Physical - _AllocatedOnSO;



        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."No.");
        if _Rec."Saleable Location" = true then begin
            //L_BinContent.SetRange("Saleable Location", true);
            L_BinContent.SetRange("Location Code", _Rec."Location Code");
            L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(_Rec."No."));
        end else
            L_BinContent.SetRange("Location Code", _Rec."Location Code");
        L_BinContent.SetRange("Variant Code", _Rec."Variant Code");
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty > 0 then
            _Free := _Free - L_ExcludeQty;
        //Prathamesh-- SBB-291

        if _Free > 0 then
            exit(_Free)
        else
            exit(0);
    end;

    procedure Upload_CheckFreeQuantity_OnValidate(_ItemNo: Code[20]; _VariantCode: Code[20]; _LocationCode: Code[20]) _Free: Decimal
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
    begin
        Clear(L_SaleableLocation);
        L_Location.Reset();
        L_Location.SetRange(Code, _LocationCode);
        if L_Location.FindFirst() then
            if L_Location."Saleable Location" = true then
                L_SaleableLocation := true
            else
                L_SaleableLocation := false;


        //Physical ++
        Clear(_Physical);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation = false then
            L_ItemLedgerEntry.SetRange("Location Code", _LocationCode)
        else begin
            //L_ItemLedgerEntry.SetRange("Saleable Location", true);
            L_ItemLedgerEntry.SetRange("Location Code", _LocationCode);
            L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(_ItemNo));
        end;
        L_ItemLedgerEntry.SetRange("Variant Code", _VariantCode);
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            _Physical := L_ItemLedgerEntry.Quantity;
        end;
        if _Physical < 0 then
            _Physical := 0;


        //Allocated On SO++
        Clear(_AllocatedOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("No.", _ItemNo);
        // if L_SaleableLocation = false then
        //     L_SalesLine.SetRange("Location Code", _LocationCode)
        // else
        //     L_SalesLine.SetRange("Saleable Location", true);
        L_SalesLine.SetRange("Location Code", _LocationCode);
        L_SalesLine.SetRange("Variant Code", _VariantCode);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Quantity");
            _AllocatedOnSO := L_SalesLine."Outstanding Quantity";
        end;
        if _AllocatedOnSO < 0 then
            _AllocatedOnSO := 0;

        //Web Order Qty++
        Clear(L_WebOrderQty);
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            L_Item.CalcFields("Qty. on Web Order");
            L_WebOrderQty := L_Item."Qty. on Web Order";
        end;

        //Free Qty++
        Clear(_Free);
        if L_SaleableLocation = true then
            _Free := _Physical - (_AllocatedOnSO + L_WebOrderQty)
        else
            _Free := _Physical - _AllocatedOnSO;

        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _ItemNo);
        if L_SaleableLocation = true then begin
            //L_BinContent.SetRange("Saleable Location", true);
            L_BinContent.SetRange("Location Code", _LocationCode);
            L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(_ItemNo));
        end else
            L_BinContent.SetRange("Location Code", _LocationCode);
        L_BinContent.SetRange("Variant Code", _VariantCode);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;

        if L_ExcludeQty > 0 then
            _Free := _Free - L_ExcludeQty;
        //Prathamesh-- SBB-291

        if _Free > 0 then
            exit(_Free)
        else
            exit(0);

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