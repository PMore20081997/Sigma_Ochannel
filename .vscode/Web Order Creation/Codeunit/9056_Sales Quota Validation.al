codeunit 90056 "Web Order Sales Quota"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure CheckExceededQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header") ReturnPram: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        Recitem: Record Item;
        CurrentMonthStartDate: Date;
        CurrentYear: Integer;
        currentMonth: Integer;
        CurrentMonth_Text: Text;
        EndDate: Date;
        ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry";
    begin
        Clear(CurrentMonthStartDate);
        Clear(EndDate);

        Recitem.Reset();
        Recitem.SetRange("No.", _InterimSalesLine."No.");
        if Recitem.FindFirst() then;

        //StartDateEndDateCalculation
        currentMonth := Date2DMY(_InterimSalesHeader."Order Date", 2);
        CurrentYear := Date2DMY(_InterimSalesHeader."Order Date", 3);
        if currentMonth > 9 then
            CurrentMonth_Text := Format(currentMonth)
        else
            CurrentMonth_Text := '0' + Format(currentMonth);
        Evaluate(CurrentMonthStartDate, '01' + CurrentMonth_Text + Format(CurrentYear));
        //CurrentMonthStartDate--

        //EndDate++
        EndDate := CalcDate('+1M', CurrentMonthStartDate);
        EndDate := CalcDate('-1D', EndDate);
        //EndDate--

        Clear(ReturnValue);
        //Per Order all 12 Validation++
        //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPOQ)-------------
        ReturnValue := PerOrderSelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
        if (ReturnValue <> ReturnValue::"No Entry") then
            exit(ReturnValue)
        else begin
            //-------------2: Selected Customer, All Item, ErrorCode(SCAPOQ)-------------
            ReturnValue := PerOrderSelCustomerAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
            if (ReturnValue <> ReturnValue::"No Entry") then
                exit(ReturnValue)
            else begin
                //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPOQ)-------------
                ReturnValue := PerOrderSelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                if (ReturnValue <> ReturnValue::"No Entry") then
                    exit(ReturnValue)
                else begin
                    //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
                    ReturnValue := PerOrderSelDimensionSelItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                    if (ReturnValue <> ReturnValue::"No Entry") then
                        exit(ReturnValue)
                    else begin
                        //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
                        ReturnValue := PerOrderSelDimensionAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                        if (ReturnValue <> ReturnValue::"No Entry") then
                            exit(ReturnValue)
                        else begin
                            //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
                            ReturnValue := PerOrderSelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                            if (ReturnValue <> ReturnValue::"No Entry") then
                                exit(ReturnValue)
                            else begin
                                //-------------7: All Customer, Selected Item, ErrorCode(ASIPOQ)-------------
                                ReturnValue := PerOrderAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                if (ReturnValue <> ReturnValue::"No Entry") then
                                    exit(ReturnValue)
                                else begin
                                    //-------------8: All Customer, All Item, ErrorCode(AAPOQ)-------------
                                    ReturnValue := PerOrderAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                    if (ReturnValue <> ReturnValue::"No Entry") then
                                        exit(ReturnValue)
                                    else begin
                                        //------------9: All Customer, Selected Item Category, ErrorCode(ASICPOQ)-------------
                                        ReturnValue := PerOrderAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                        if (ReturnValue <> ReturnValue::"No Entry") then
                                            exit(ReturnValue)
                                        else begin
                                            //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPOQ)-------------
                                            ReturnValue := PerOrderSelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                            if (ReturnValue <> ReturnValue::"No Entry") then
                                                exit(ReturnValue)
                                            else begin
                                                //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPOQ)-------------
                                                ReturnValue := PerOrderSelCustomerGroupAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                                if (ReturnValue <> ReturnValue::"No Entry") then
                                                    exit(ReturnValue)
                                                else begin
                                                    //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
                                                    ReturnValue := PerOrderSelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                                    if (ReturnValue <> ReturnValue::"No Entry") then
                                                        exit(ReturnValue);
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        //Per Order all 12 Validation--


        //Per Day all 12 validation+++++++
        //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPDQ)-------------
        ReturnValue := PerDaySelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
        if (ReturnValue <> ReturnValue::"No Entry") then
            exit(ReturnValue)
        else begin
            //-------------2: Selected Customer, All Item, ErrorCode(SCAPDQ)-------------
            ReturnValue := PerDaySelCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
            if (ReturnValue <> ReturnValue::"No Entry") then
                exit(ReturnValue)
            else begin
                //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPDQ)-------
                ReturnValue := PerDaySelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                if (ReturnValue <> ReturnValue::"No Entry") then
                    exit(ReturnValue)
                else begin
                    //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
                    ReturnValue := PerDaySelDimensionSelItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                    if (ReturnValue <> ReturnValue::"No Entry") then
                        exit(ReturnValue)
                    else begin
                        //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
                        ReturnValue := PerDaySelDimensionAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                        if (ReturnValue <> ReturnValue::"No Entry") then
                            exit(ReturnValue)
                        else begin
                            //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
                            ReturnValue := PerDaySelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                            if (ReturnValue <> ReturnValue::"No Entry") then
                                exit(ReturnValue)
                            else begin
                                //-------------7: All Customer, Selected Item, ErrorCode(ASIPDQ)-------------
                                ReturnValue := PerDayAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                if (ReturnValue <> ReturnValue::"No Entry") then
                                    exit(ReturnValue)
                                else begin
                                    //-------------8: All Customer, All Item, ErrorCode(AAPDQ)-------------
                                    ReturnValue := PerDayAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                    if (ReturnValue <> ReturnValue::"No Entry") then
                                        exit(ReturnValue)
                                    else begin
                                        //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPDQ)-------------
                                        ReturnValue := PerDayAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                        if (ReturnValue <> ReturnValue::"No Entry") then
                                            exit(ReturnValue)
                                        else begin
                                            //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPDQ)-------
                                            ReturnValue := PerDaySelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                            if (ReturnValue <> ReturnValue::"No Entry") then
                                                exit(ReturnValue)
                                            else begin
                                                //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPDQ)-------------
                                                ReturnValue := PerDaySelCustomerGroupAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                                if (ReturnValue <> ReturnValue::"No Entry") then
                                                    exit(ReturnValue)
                                                else begin
                                                    //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
                                                    ReturnValue := PerDaySelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
                                                    if (ReturnValue <> ReturnValue::"No Entry") then
                                                        exit(ReturnValue);
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        //Per Day all 12 validation------

        //Per Month all 12 validation++
        //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPMQ)-------------
        ReturnValue := PerMonthSelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        if (ReturnValue <> ReturnValue::"No Entry") then
            exit(ReturnValue)
        else begin
            //-------------2: Selected Customer, All Item, ErrorCode(SCAPMQ)-------------
            ReturnValue := PerMonthSelCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
            if (ReturnValue <> ReturnValue::"No Entry") then
                exit(ReturnValue)
            else begin
                //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPMQ)-------
                ReturnValue := PerMonthSelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                if (ReturnValue <> ReturnValue::"No Entry") then
                    exit(ReturnValue)
                else begin
                    //-------------4: Selected Dimension, Selected Item, ErrorCode(SCSIPMQ)-------------
                    ReturnValue := PerMonthSelDimensionSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                    if (ReturnValue <> ReturnValue::"No Entry") then
                        exit(ReturnValue)
                    else begin
                        //-------------5: Selected Dimension, All Item, ErrorCode(SCAPMQ)-------------
                        ReturnValue := PerMonthSelDimensionAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                        if (ReturnValue <> ReturnValue::"No Entry") then
                            exit(ReturnValue)
                        else begin
                            //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPMQ)-------
                            ReturnValue := PerMonthSelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                            if (ReturnValue <> ReturnValue::"No Entry") then
                                exit(ReturnValue)
                            else begin
                                //-------------7: All Customer, Selected Item, ErrorCode(ASIPMQ)-------------
                                ReturnValue := PerMonthAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                                if (ReturnValue <> ReturnValue::"No Entry") then
                                    exit(ReturnValue)
                                else begin
                                    //-------------8: All Customer, All Item, ErrorCode(AAPMQ)-------------
                                    ReturnValue := PerMonthAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                                    if (ReturnValue <> ReturnValue::"No Entry") then
                                        exit(ReturnValue)
                                    else begin
                                        //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPMQ)-------------
                                        ReturnValue := PerMonthAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                                        if (ReturnValue <> ReturnValue::"No Entry") then
                                            exit(ReturnValue)
                                        else begin
                                            //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPMQ)-------
                                            ReturnValue := PerMonthSelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                                            if (ReturnValue <> ReturnValue::"No Entry") then
                                                exit(ReturnValue)
                                            else begin
                                                //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPMQ)-------------
                                                ReturnValue := PerMonthSelCustomerGroupAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                                                if (ReturnValue <> ReturnValue::"No Entry") then
                                                    exit(ReturnValue)
                                                else begin
                                                    //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPMQ)-------------
                                                    ReturnValue := PerMonthSelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
                                                    if (ReturnValue <> ReturnValue::"No Entry") then
                                                        exit(ReturnValue);
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        // //Per Month all 12 validation--
    end;

    procedure PerMonthSelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record 60600;
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query 60602;
        L_DayWiseShippedQty: Query 60603;
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_EntryFound: Boolean;

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
        L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
                L_MaxOrderQty.SetRange("Item Code", ItemCat);
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                        //Permonth Web orders Qty++++++
                        L_InterimSalesLinePerdayQuantity.Reset();
                        L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
                        L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
                        L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
                        L_InterimSalesLinePerdayQuantity.SetRange("Item Category Code", ItemCat);
                        L_InterimSalesLinePerdayQuantity.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        L_InterimSalesLinePerdayQuantity.SetRange("Reason Message", 'Successful');
                        if L_InterimSalesLinePerdayQuantity.FindSet() then begin
                            repeat
                                DefaultDimension_2.Reset();
                                DefaultDimension_2.SetRange("Table ID", 18);
                                DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                                DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
                                DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if DefaultDimension_2.FindFirst() then begin
                                    L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
                                end;
                            until L_InterimSalesLinePerdayQuantity.Next() = 0;
                        end;


                        //Permonth Current Web orders Qty++++++
                        L_InterimSalesLine.RESET;
                        L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                        L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                        L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
                        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                        IF L_InterimSalesLine.FINDSET THEN BEGIN
                            L_InterimSalesLine.CalcSums("Qty. to Deliver");
                            L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                        END;

                        //Permonth SHipped Qty+++++
                        L_SalesShipmentLine.Reset();
                        L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
                        L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                        L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        if L_SalesShipmentLine.FindSet() then begin
                            repeat
                                L_DimensionSetEntry.Reset();
                                L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                                L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if L_DimensionSetEntry.FindFirst() then begin
                                    L_DayOrderQty += L_SalesShipmentLine.Quantity;
                                end;
                            until L_SalesShipmentLine.Next() = 0;
                        end;

                        L_EntryFound := true;
                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                        if L_RemainingQuantity < L_OrderQty then
                            exit(ReturnValue::"Exceeded Qty");
                    end;
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");
    end;


    procedure PerMonthSelDimensionAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record 60600;
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query 60602;
        L_DayWiseShippedQty: Query 60603;
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_EntryFound: Boolean;

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
        L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                        //PerMonth Web orders Qty++++++
                        L_InterimSalesLinePerdayQuantity.Reset();
                        L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
                        L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
                        L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
                        L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
                        L_InterimSalesLinePerdayQuantity.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        L_InterimSalesLinePerdayQuantity.SetRange("Reason Message", 'Successful');
                        if L_InterimSalesLinePerdayQuantity.FindSet() then begin
                            repeat
                                DefaultDimension_2.Reset();
                                DefaultDimension_2.SetRange("Table ID", 18);
                                DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                                DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
                                DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if DefaultDimension_2.FindFirst() then begin
                                    L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
                                end;
                            until L_InterimSalesLinePerdayQuantity.Next() = 0;
                        end;

                        //PerMonth Current Web orders Qty++++++
                        L_InterimSalesLine.RESET;
                        L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                        L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                        L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                        IF L_InterimSalesLine.FINDSET THEN BEGIN
                            L_InterimSalesLine.CalcSums("Qty. to Deliver");
                            L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                        END;

                        //PerMonth SHipped Qty+++++
                        L_SalesShipmentLine.Reset();
                        L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
                        L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                        L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        if L_SalesShipmentLine.FindSet() then begin
                            repeat
                                L_DimensionSetEntry.Reset();
                                L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                                L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if L_DimensionSetEntry.FindFirst() then begin
                                    L_DayOrderQty += L_SalesShipmentLine.Quantity;
                                end;
                            until L_SalesShipmentLine.Next() = 0;
                        end;

                        L_EntryFound := true;
                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                        if L_RemainingQuantity < L_OrderQty then
                            exit(ReturnValue::"Exceeded Qty");
                    end;
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");

    end;


    procedure PerMonthSelDimensionSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record 60600;
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query 60602;
        L_DayWiseShippedQty: Query 60603;
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_EntryFound: Boolean;

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
        L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
                L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                        //Permonth Web orders Qty++++++
                        L_InterimSalesLinePerdayQuantity.Reset();
                        L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
                        L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
                        L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
                        L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
                        L_InterimSalesLinePerdayQuantity.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        L_InterimSalesLinePerdayQuantity.SetRange("Reason Message", 'Successful');
                        if L_InterimSalesLinePerdayQuantity.FindSet() then begin
                            repeat
                                DefaultDimension_2.Reset();
                                DefaultDimension_2.SetRange("Table ID", 18);
                                DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                                DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
                                DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if DefaultDimension_2.FindFirst() then begin
                                    L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
                                end;
                            until L_InterimSalesLinePerdayQuantity.Next() = 0;
                        end;

                        //Permonth Current Web orders Qty++++++
                        L_InterimSalesLine.RESET;
                        L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                        L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                        L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                        IF L_InterimSalesLine.FINDSET THEN BEGIN
                            L_InterimSalesLine.CalcSums("Qty. to Deliver");
                            L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                        END;

                        //Permonth SHipped Qty+++++
                        L_SalesShipmentLine.Reset();
                        L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
                        L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                        L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        if L_SalesShipmentLine.FindSet() then begin
                            repeat
                                L_DimensionSetEntry.Reset();
                                L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                                L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if L_DimensionSetEntry.FindFirst() then begin
                                    L_DayOrderQty += L_SalesShipmentLine.Quantity;
                                end;
                            until L_SalesShipmentLine.Next() = 0;
                        end;

                        L_EntryFound := true;
                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                        if L_RemainingQuantity < L_OrderQty then
                            exit(ReturnValue::"Exceeded Qty");
                    end;
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");
    end;

    procedure PerMonthSelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //PerDay Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SetFilter(L_DayWiseWebOrderQty.Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;

                //PerDay Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //PerDay SHipped Qty++
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerMonthSelCustomerGroupAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //PerDay Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SetFilter(L_DayWiseWebOrderQty.Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;

                //PerDay Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //PerDay SHipped Qty++
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerMonthSelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //PerDay Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SetFilter(L_DayWiseWebOrderQty.Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;

                //PerDay Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //PerDay SHipped Qty++
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;



    procedure PerMonthAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //PerDay Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;
                L_DayWiseWebOrderQty.CLOSE;


                //Permonth Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //PerDay SHipped Qty++
                L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerMonthAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //PerDay Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;
                L_DayWiseWebOrderQty.CLOSE;


                //Permonth Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //PerDay SHipped Qty++
                L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerMonthAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //PerDay Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;
                L_DayWiseWebOrderQty.CLOSE;


                //Permonth Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //PerDay SHipped Qty++
                L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerMonthSelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //Permonth Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                //L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
                L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;
                L_DayWiseWebOrderQty.CLOSE;

                //Permonth Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //Permonth SHipped Qty++
                L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                //L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerMonthSelCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //Permonth Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                //L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
                L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;
                L_DayWiseWebOrderQty.CLOSE;

                //Permonth Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //Permonth SHipped Qty++
                L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                //L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerMonthSelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

                //Permonth Web orders Qty++++++
                L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
                L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
                L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                //L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
                L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseWebOrderQty.OPEN;
                WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
                END;
                L_DayWiseWebOrderQty.CLOSE;

                //Permonth Current Web orders Qty++++++
                L_InterimSalesLine.RESET;
                L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                IF L_InterimSalesLine.FINDSET THEN BEGIN
                    L_InterimSalesLine.CalcSums("Qty. to Deliver");
                    L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                END;

                //Permonth SHipped Qty++
                L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
                //L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                if L_RemainingQuantity < L_OrderQty then
                    exit(ReturnValue::"Exceeded Qty")
                else
                    exit(ReturnValue::"Allowed Qty");
            End else
                exit(ReturnValue::"No Entry");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerDaySelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //Perday Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //Perday Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange("Item Category Code", ItemCat);
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //Perday SHipped Qty++
            L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerDaySelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerDaySelCustomerGroupAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerDaySelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record 60600;
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query 60602;
        L_DayWiseShippedQty: Query 60603;
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_EntryFound: Boolean;

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
        L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
                L_MaxOrderQty.SetRange("Item Code", ItemCat);
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    //PerDay Web orders Qty++++++
                    L_InterimSalesLinePerdayQuantity.Reset();
                    L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
                    L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
                    L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
                    L_InterimSalesLinePerdayQuantity.SetRange("Item Category Code", ItemCat);
                    L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
                    L_InterimSalesLinePerdayQuantity.SetRange("Reason Message", 'Successful');
                    if L_InterimSalesLinePerdayQuantity.FindSet() then begin
                        repeat
                            DefaultDimension_2.Reset();
                            DefaultDimension_2.SetRange("Table ID", 18);
                            DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                            DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
                            DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if DefaultDimension_2.FindFirst() then begin
                                L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
                            end;
                        until L_InterimSalesLinePerdayQuantity.Next() = 0;
                    end;

                    //PerDay Current Web orders Qty++++++
                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                    L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
                    L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                    IF L_InterimSalesLine.FINDSET THEN BEGIN
                        L_InterimSalesLine.CalcSums("Qty. to Deliver");
                        L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                    END;


                    //PerDay SHipped Qty+++++
                    L_SalesShipmentLine.Reset();
                    L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
                    L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                    L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
                    if L_SalesShipmentLine.FindSet() then begin
                        repeat
                            L_DimensionSetEntry.Reset();
                            L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                            L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if L_DimensionSetEntry.FindFirst() then begin
                                L_DayOrderQty += L_SalesShipmentLine.Quantity;
                            end;
                        until L_SalesShipmentLine.Next() = 0;
                    end;

                    L_EntryFound := true;
                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    if L_RemainingQuantity < L_OrderQty then
                        exit(ReturnValue::"Exceeded Qty");
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");

    end;

    procedure PerDaySelDimensionAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record 60600;
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query 60602;
        L_DayWiseShippedQty: Query 60603;
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_EntryFound: Boolean;

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
        L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    //PerDay Web orders Qty++++++
                    L_InterimSalesLinePerdayQuantity.Reset();
                    L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
                    L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
                    L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
                    L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
                    L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
                    L_InterimSalesLinePerdayQuantity.SetRange("Reason Message", 'Successful');
                    if L_InterimSalesLinePerdayQuantity.FindSet() then begin
                        repeat
                            DefaultDimension_2.Reset();
                            DefaultDimension_2.SetRange("Table ID", 18);
                            DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                            DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
                            DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if DefaultDimension_2.FindFirst() then begin
                                L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
                            end;
                        until L_InterimSalesLinePerdayQuantity.Next() = 0;
                    end;

                    //PerDay Current Web orders Qty++++++
                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                    L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                    L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                    IF L_InterimSalesLine.FINDSET THEN BEGIN
                        L_InterimSalesLine.CalcSums("Qty. to Deliver");
                        L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                    END;

                    //PerDay SHipped Qty+++++
                    L_SalesShipmentLine.Reset();
                    L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
                    L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                    L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
                    if L_SalesShipmentLine.FindSet() then begin
                        repeat
                            L_DimensionSetEntry.Reset();
                            L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                            L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if L_DimensionSetEntry.FindFirst() then begin
                                L_DayOrderQty += L_SalesShipmentLine.Quantity;
                            end;
                        until L_SalesShipmentLine.Next() = 0;
                    end;

                    L_EntryFound := true;
                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    if L_RemainingQuantity < L_OrderQty then
                        exit(ReturnValue::"Exceeded Qty");
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");

    end;



    procedure PerDaySelDimensionSelItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record 60600;
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query 60602;
        L_DayWiseShippedQty: Query 60603;
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_EntryFound: Boolean;

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
        L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
                L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    //PerDay Web orders Qty++++++
                    L_InterimSalesLinePerdayQuantity.Reset();
                    L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
                    L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
                    L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
                    L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
                    L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
                    L_InterimSalesLinePerdayQuantity.SetRange("Reason Message", 'Successful');
                    if L_InterimSalesLinePerdayQuantity.FindSet() then begin
                        repeat
                            DefaultDimension_2.Reset();
                            DefaultDimension_2.SetRange("Table ID", 18);
                            DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                            DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
                            DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if DefaultDimension_2.FindFirst() then begin
                                L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
                            end;
                        until L_InterimSalesLinePerdayQuantity.Next() = 0;
                    end;

                    //PerDay Current Web orders Qty++++++
                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
                    L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                    L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                    IF L_InterimSalesLine.FINDSET THEN BEGIN
                        L_InterimSalesLine.CalcSums("Qty. to Deliver");
                        L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
                    END;

                    //PerDay SHipped Qty+++++
                    L_SalesShipmentLine.Reset();
                    L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
                    L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                    L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
                    if L_SalesShipmentLine.FindSet() then begin
                        repeat
                            L_DimensionSetEntry.Reset();
                            L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                            L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if L_DimensionSetEntry.FindFirst() then begin
                                L_DayOrderQty += L_SalesShipmentLine.Quantity;
                            end;
                        until L_SalesShipmentLine.Next() = 0;
                    end;

                    L_EntryFound := true;
                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    if L_RemainingQuantity < L_OrderQty then
                        exit(ReturnValue::"Exceeded Qty");
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");
    end;



    procedure PerDaySelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            //L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
            L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            //L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerDaySelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            //L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
            L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            //L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");

        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerDaySelCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";


        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesLine."Sell-to Customer No.");
            //L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
            L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            //L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");

        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerDayAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;

    procedure PerDayAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");

        End;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerDayAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        RecSalesLineNew: Record "Sales Line";
        L_OrderQty: Decimal;
        L_DayWiseQty: Query "Daywise order quantity Copy";
        L_DayWiseShippedQty: Query "DayShippe Qty Copy";
        L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
        L_InterimSalesLine: Record "Interim Sales Line";

        //New+
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            //PerDay Web orders Qty++++++
            L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");//azhar
            L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
            L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseWebOrderQty.OPEN;
            WHILE L_DayWiseWebOrderQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
            END;
            L_DayWiseWebOrderQty.CLOSE;

            //PerDay Current Web orders Qty++++++
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_OrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            //PerDay SHipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            if L_RemainingQuantity < L_OrderQty then
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderSelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
        RecItem: Record Item;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;

        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderSelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;

        exit(ReturnValue::"No Entry");
    end;

    procedure PerOrderSelCustomerGroupAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;

        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderSelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
        RecItem: Record Item;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesLine."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesLine."Document No");
            L_InterimSalesLine.SetRange("Item Category Code", ItemCat);
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderSelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesLine."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesLine."Document No");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderSelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
        L_DefaultDimension: Record "Default Dimension";
        L_EntryFound: Boolean;
        RecItem: Record Item;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
                L_MaxOrderQty.SetRange("Item Code", ItemCat);
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN

                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesLine."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", _InterimSalesLine."Document No");
                    L_InterimSalesLine.SetRange("Item Category Code", ItemCat);
                    IF L_InterimSalesLine.FINDSET THEN BEGIN
                        L_InterimSalesLine.CalcSums("Qty. to Deliver");
                        L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
                    END;

                    L_EntryFound := true;
                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    IF L_RemainingQuantity < 0 THEN
                        exit(ReturnValue::"Exceeded Qty");
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");
    end;

    procedure PerOrderSelDimensionAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
        L_DefaultDimension: Record "Default Dimension";
        L_EntryFound: Boolean;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesLine."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", _InterimSalesLine."Document No");
                    L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                    L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                    IF L_InterimSalesLine.FINDSET THEN BEGIN
                        L_InterimSalesLine.CalcSums("Qty. to Deliver");
                        L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
                    END;

                    L_EntryFound := true;
                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    IF L_RemainingQuantity < 0 THEN
                        exit(ReturnValue::"Exceeded Qty");
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");
    end;

    procedure PerOrderSelDimensionSelItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
        L_DefaultDimension: Record "Default Dimension";
        L_EntryFound: Boolean;
    begin
        Clear(L_EntryFound);
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
                L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN

                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesLine."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", _InterimSalesLine."Document No");
                    L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
                    L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                    IF L_InterimSalesLine.FINDSET THEN BEGIN
                        L_InterimSalesLine.CalcSums("Qty. to Deliver");
                        L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
                    END;

                    L_EntryFound := true;
                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    IF L_RemainingQuantity < 0 THEN
                        exit(ReturnValue::"Exceeded Qty");
                end;
            until L_DefaultDimension.Next() = 0;
        end;

        if L_EntryFound = false then
            exit(ReturnValue::"No Entry")
        else
            exit(ReturnValue::"Allowed Qty");
    end;

    procedure PerOrderSelCustomerAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        //L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesLine."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesLine."Document No");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;
        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
        RecItem: Record Item;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            L_InterimSalesLine.SETRANGE("Item Category Code", ItemCat);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;

        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;

        exit(ReturnValue::"No Entry");
    end;


    procedure PerOrderAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]) ReturnValue: Option "Allowed Qty","Exceeded Qty","No Entry"
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_OrderQty: Decimal;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", _InterimSalesHeader."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", _InterimSalesHeader."No.");
            L_InterimSalesLine.SETRANGE("No.", _InterimSalesLine."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            IF L_InterimSalesLine.FINDSET THEN BEGIN
                L_InterimSalesLine.CalcSums("Qty. to Deliver");
                L_DayOrderQty := L_InterimSalesLine."Qty. to Deliver";
            END;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                exit(ReturnValue::"Exceeded Qty")
            else
                exit(ReturnValue::"Allowed Qty");
        end;

        exit(ReturnValue::"No Entry");
    end;

    // procedure CheckingRemainingQty(RemQty: Decimal; Errcode: code[20])
    // var
    // begin
    //     IF (RemQty < 0) THEN
    //         ERROR('Maximum quantity allowed has been exceeded. Error Code:' + Errcode);
    // end;
}