// codeunit 90024 "Sales Quota Qty Validation"
// {
//     procedure CheckExceededQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"): Decimal
//     var
//         Recitem: Record Item;
//         CurrentMonthStartDate: Date;
//         CurrentYear: Integer;
//         CurrentMonth: Integer;
//         CurrentMonth_Text: Text;
//         EndDate: Date;
//         RemainingQuantity: Decimal;
//     begin
//         Clear(CurrentMonthStartDate);
//         Clear(EndDate);

//         Recitem.Reset();
//         Recitem.SetRange("No.", _InterimSalesLine."No.");
//         if Recitem.FindFirst() then;

//         currentMonth := Date2DMY(_InterimSalesHeader."Order Date", 2);
//         CurrentYear := Date2DMY(_InterimSalesHeader."Order Date", 3);
//         if currentMonth > 9 then
//             CurrentMonth_Text := Format(currentMonth)
//         else
//             CurrentMonth_Text := '0' + Format(currentMonth);
//         Evaluate(CurrentMonthStartDate, '01' + CurrentMonth_Text + Format(CurrentYear));

//         //EndDate++
//         EndDate := CalcDate('+1M', CurrentMonthStartDate);
//         EndDate := CalcDate('-1D', EndDate);
//         //EndDate--

//         Clear(RemainingQuantity);

//         #Region Exception Per Day all 12 Validation++
//         //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPOQ)-------------
//         RemainingQuantity := ExceptionPerDaySelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//         if (RemainingQuantity > 0) then
//             exit(RemainingQuantity)
//         else begin
//             //-------------2: Selected Customer, All Item, ErrorCode(SCAPDQ)-------------
//             RemainingQuantity := ExceptionPerDaySelCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//             if (RemainingQuantity > 0) then
//                 exit(RemainingQuantity)
//             else begin
//                 //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPDQ)-------
//                 RemainingQuantity := ExceptionPerDaySelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                 if (RemainingQuantity > 0) then
//                     exit(RemainingQuantity)
//                 else begin
//                     //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
//                     RemainingQuantity := ExceptionPerDaySelDimensionSelItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                     if (RemainingQuantity > 0) then
//                         exit(RemainingQuantity)
//                     else begin
//                         //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
//                         RemainingQuantity := ExceptionPerDaySelDimensionAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                         if (RemainingQuantity > 0) then
//                             exit(RemainingQuantity)
//                         else begin
//                             //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
//                             RemainingQuantity := ExceptionPerDaySelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                             if (RemainingQuantity > 0) then
//                                 exit(RemainingQuantity)
//                             else begin
//                                 //-------------7: All Customer, Selected Item, ErrorCode(ASIPDQ)-------------
//                                 RemainingQuantity := ExceptionPerDayAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                 if (RemainingQuantity > 0) then
//                                     exit(RemainingQuantity)
//                                 else begin
//                                     //-------------8: All Customer, All Item, ErrorCode(AAPDQ)-------------
//                                     RemainingQuantity := ExceptionPerDayAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                     if (RemainingQuantity > 0) then
//                                         exit(RemainingQuantity)
//                                     else begin
//                                         //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPDQ)-------------
//                                         RemainingQuantity := ExceptionPerDayAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                         if (RemainingQuantity > 0) then
//                                             exit(RemainingQuantity)
//                                         else begin
//                                             //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPDQ)-------
//                                             RemainingQuantity := ExceptionPerDaySelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                             if (RemainingQuantity > 0) then
//                                                 exit(RemainingQuantity)
//                                             else begin
//                                                 //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPDQ)-------------
//                                                 RemainingQuantity := ExceptionPerDaySelCustomerGroupAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                                 if (RemainingQuantity > 0) then
//                                                     exit(RemainingQuantity)
//                                                 else begin
//                                                     //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
//                                                     RemainingQuantity := ExceptionPerDaySelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                                     if (RemainingQuantity > 0) then
//                                                         exit(RemainingQuantity);
//                                                 end;
//                                             end;
//                                         end;
//                                     end;
//                                 end;
//                             end;
//                         end;
//                     end;
//                 end;
//             end;
//         end;
//         #endregion

//         #Region Per Order all 12 Validation++
//         //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPOQ)-------------
//         RemainingQuantity := PerOrderSelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//         if (RemainingQuantity > 0) then
//             exit(RemainingQuantity)
//         else begin
//             //-------------2: Selected Customer, All Item, ErrorCode(SCAPOQ)-------------
//             RemainingQuantity := PerOrderSelCustomerAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//             if (RemainingQuantity > 0) then
//                 exit(RemainingQuantity)
//             else begin
//                 //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPOQ)-------------
//                 RemainingQuantity := PerOrderSelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                 if (RemainingQuantity > 0) then
//                     exit(RemainingQuantity)
//                 else begin
//                     //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
//                     RemainingQuantity := PerOrderSelDimensionSelItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                     if (RemainingQuantity > 0) then
//                         exit(RemainingQuantity)
//                     else begin
//                         //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
//                         RemainingQuantity := PerOrderSelDimensionAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                         if (RemainingQuantity > 0) then
//                             exit(RemainingQuantity)
//                         else begin
//                             //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
//                             RemainingQuantity := PerOrderSelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                             if (RemainingQuantity > 0) then
//                                 exit(RemainingQuantity)
//                             else begin
//                                 //-------------7: All Customer, Selected Item, ErrorCode(ASIPOQ)-------------
//                                 RemainingQuantity := PerOrderAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                 if (RemainingQuantity > 0) then
//                                     exit(RemainingQuantity)
//                                 else begin
//                                     //-------------8: All Customer, All Item, ErrorCode(AAPOQ)-------------
//                                     RemainingQuantity := PerOrderAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                     if (RemainingQuantity > 0) then
//                                         exit(RemainingQuantity)
//                                     else begin
//                                         //------------9: All Customer, Selected Item Category, ErrorCode(ASICPOQ)-------------
//                                         RemainingQuantity := PerOrderAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                         if (RemainingQuantity > 0) then
//                                             exit(RemainingQuantity)
//                                         else begin
//                                             //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPOQ)-------------
//                                             RemainingQuantity := PerOrderSelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                             if (RemainingQuantity > 0) then
//                                                 exit(RemainingQuantity)
//                                             else begin
//                                                 //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPOQ)-------------
//                                                 RemainingQuantity := PerOrderSelCustomerGroupAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                                 if (RemainingQuantity > 0) then
//                                                     exit(RemainingQuantity)
//                                                 else begin
//                                                     //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
//                                                     RemainingQuantity := PerOrderSelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                                     if (RemainingQuantity > 0) then
//                                                         exit(RemainingQuantity);
//                                                 end;
//                                             end;
//                                         end;
//                                     end;
//                                 end;
//                             end;
//                         end;
//                     end;
//                 end;
//             end;
//         end;
//         #endregion

//         #Region Per Day all 12 validation
//         //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPDQ)-------------
//         RemainingQuantity := PerDaySelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//         if (RemainingQuantity > 0) then
//             exit(RemainingQuantity)
//         else begin
//             //-------------2: Selected Customer, All Item, ErrorCode(SCAPDQ)-------------
//             RemainingQuantity := PerDaySelCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//             if (RemainingQuantity > 0) then
//                 exit(RemainingQuantity)
//             else begin
//                 //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPDQ)-------
//                 RemainingQuantity := PerDaySelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                 if (RemainingQuantity > 0) then
//                     exit(RemainingQuantity)
//                 else begin
//                     //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
//                     RemainingQuantity := PerDaySelDimensionSelItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                     if (RemainingQuantity > 0) then
//                         exit(RemainingQuantity)
//                     else begin
//                         //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
//                         RemainingQuantity := PerDaySelDimensionAllItem(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                         if (RemainingQuantity > 0) then
//                             exit(RemainingQuantity)
//                         else begin
//                             //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
//                             RemainingQuantity := PerDaySelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                             if (RemainingQuantity > 0) then
//                                 exit(RemainingQuantity)
//                             else begin
//                                 //-------------7: All Customer, Selected Item, ErrorCode(ASIPDQ)-------------
//                                 RemainingQuantity := PerDayAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                 if (RemainingQuantity > 0) then
//                                     exit(RemainingQuantity)
//                                 else begin
//                                     //-------------8: All Customer, All Item, ErrorCode(AAPDQ)-------------
//                                     RemainingQuantity := PerDayAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                     if (RemainingQuantity > 0) then
//                                         exit(RemainingQuantity)
//                                     else begin
//                                         //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPDQ)-------------
//                                         RemainingQuantity := PerDayAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                         if (RemainingQuantity > 0) then
//                                             exit(RemainingQuantity)
//                                         else begin
//                                             //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPDQ)-------
//                                             RemainingQuantity := PerDaySelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                             if (RemainingQuantity > 0) then
//                                                 exit(RemainingQuantity)
//                                             else begin
//                                                 //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPDQ)-------------
//                                                 RemainingQuantity := PerDaySelCustomerGroupAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                                 if (RemainingQuantity > 0) then
//                                                     exit(RemainingQuantity)
//                                                 else begin
//                                                     //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
//                                                     RemainingQuantity := PerDaySelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code");
//                                                     if (RemainingQuantity > 0) then
//                                                         exit(RemainingQuantity);
//                                                 end;
//                                             end;
//                                         end;
//                                     end;
//                                 end;
//                             end;
//                         end;
//                     end;
//                 end;
//             end;
//         end;
//         #endregion

//         #Region Per Month all 12 validation
//         //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPMQ)-------------
//         RemainingQuantity := PerMonthSelCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//         if (RemainingQuantity > 0) then
//             exit(RemainingQuantity)
//         else begin
//             //-------------2: Selected Customer, All Item, ErrorCode(SCAPMQ)-------------
//             RemainingQuantity := PerMonthSelCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//             if (RemainingQuantity > 0) then
//                 exit(RemainingQuantity)
//             else begin
//                 //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPMQ)-------
//                 RemainingQuantity := PerMonthSelCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                 if (RemainingQuantity > 0) then
//                     exit(RemainingQuantity)
//                 else begin
//                     //-------------4: Selected Dimension, Selected Item, ErrorCode(SCSIPMQ)-------------
//                     RemainingQuantity := PerMonthSelDimensionSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                     if (RemainingQuantity > 0) then
//                         exit(RemainingQuantity)
//                     else begin
//                         //-------------5: Selected Dimension, All Item, ErrorCode(SCAPMQ)-------------
//                         RemainingQuantity := PerMonthSelDimensionAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                         if (RemainingQuantity > 0) then
//                             exit(RemainingQuantity)
//                         else begin
//                             //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPMQ)-------
//                             RemainingQuantity := PerMonthSelDimensionSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                             if (RemainingQuantity > 0) then
//                                 exit(RemainingQuantity)
//                             else begin
//                                 //-------------7: All Customer, Selected Item, ErrorCode(ASIPMQ)-------------
//                                 RemainingQuantity := PerMonthAllCustomerSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                                 if (RemainingQuantity > 0) then
//                                     exit(RemainingQuantity)
//                                 else begin
//                                     //-------------8: All Customer, All Item, ErrorCode(AAPMQ)-------------
//                                     RemainingQuantity := PerMonthAllCustomerAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                                     if (RemainingQuantity > 0) then
//                                         exit(RemainingQuantity)
//                                     else begin
//                                         //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPMQ)-------------
//                                         RemainingQuantity := PerMonthAllCustomerSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                                         if (RemainingQuantity > 0) then
//                                             exit(RemainingQuantity)
//                                         else begin
//                                             //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPMQ)-------
//                                             RemainingQuantity := PerMonthSelCustomerGroupSelItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                                             if (RemainingQuantity > 0) then
//                                                 exit(RemainingQuantity)
//                                             else begin
//                                                 //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPMQ)-------------
//                                                 RemainingQuantity := PerMonthSelCustomerGroupAllItemQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                                                 if (RemainingQuantity > 0) then
//                                                     exit(RemainingQuantity)
//                                                 else begin
//                                                     //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPMQ)-------------
//                                                     RemainingQuantity := PerMonthSelCustomerGroupSelItemCatQty(_InterimSalesLine, _InterimSalesHeader, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
//                                                     if (RemainingQuantity > 0) then
//                                                         exit(RemainingQuantity);
//                                                 end;
//                                             end;
//                                         end;
//                                     end;
//                                 end;
//                             end;
//                         end;
//                     end;
//                 end;
//             end;
//         end;
//         #endregion
//     end;

//     local procedure ExceptionPerDaySelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //Calculate Existing Order Quantity++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesLine."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesLine."Document No");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesLine."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //Calculate Shipped Quantity++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesLine."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 //Calculate Remaining Quantity++
//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             end;
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure ExceptionPerDaySelCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesLine."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             end;
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure ExceptionPerDaySelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             end;
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure ExceptionPerDaySelDimensionSelItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//                 L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                         //PerDay Web orders Qty++++++
//                         L_InterimSalesLinePerdayQuantity.Reset();
//                         L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                         L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                         L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                         L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
//                         L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                         if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                             repeat
//                                 DefaultDimension_2.Reset();
//                                 DefaultDimension_2.SetRange("Table ID", 18);
//                                 DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                                 DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                                 DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if DefaultDimension_2.FindFirst() then begin
//                                     L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                                 end;
//                             until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                         end;

//                         //PerDay SHipped Qty+++++
//                         L_SalesShipmentLine.Reset();
//                         L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
//                         L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                         L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
//                         if L_SalesShipmentLine.FindSet() then begin
//                             repeat
//                                 L_DimensionSetEntry.Reset();
//                                 L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                                 L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if L_DimensionSetEntry.FindFirst() then begin
//                                     L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                                 end;
//                             until L_SalesShipmentLine.Next() = 0;
//                         end;

//                         L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                         if L_RemainingQuantity > 0 then
//                             exit(L_RemainingQuantity);
//                     end;
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure ExceptionPerDaySelDimensionAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                         //PerDay Web orders Qty++++++
//                         L_InterimSalesLinePerdayQuantity.Reset();
//                         L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                         L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                         L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                         L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
//                         L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                         if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                             repeat
//                                 DefaultDimension_2.Reset();
//                                 DefaultDimension_2.SetRange("Table ID", 18);
//                                 DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                                 DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                                 DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if DefaultDimension_2.FindFirst() then begin
//                                     L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                                 end;
//                             until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                         end;

//                         //PerDay SHipped Qty+++++
//                         L_SalesShipmentLine.Reset();
//                         L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
//                         L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                         L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
//                         if L_SalesShipmentLine.FindSet() then begin
//                             repeat
//                                 L_DimensionSetEntry.Reset();
//                                 L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                                 L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if L_DimensionSetEntry.FindFirst() then begin
//                                     L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                                 end;
//                             until L_SalesShipmentLine.Next() = 0;
//                         end;

//                         L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                         if L_RemainingQuantity > 0 then
//                             exit(L_RemainingQuantity);
//                     end;
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure ExceptionPerDaySelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//                 L_MaxOrderQty.SetRange("Item Code", ItemCat);
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                         //PerDay Web orders Qty++++++
//                         L_InterimSalesLinePerdayQuantity.Reset();
//                         L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                         L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                         L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                         L_InterimSalesLinePerdayQuantity.SetRange("Item Category Code", ItemCat);
//                         L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                         if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                             repeat
//                                 DefaultDimension_2.Reset();
//                                 DefaultDimension_2.SetRange("Table ID", 18);
//                                 DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                                 DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                                 DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if DefaultDimension_2.FindFirst() then begin
//                                     L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                                 end;
//                             until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                         end;

//                         //PerDay SHipped Qty+++++
//                         L_SalesShipmentLine.Reset();
//                         L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
//                         L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                         L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
//                         if L_SalesShipmentLine.FindSet() then begin
//                             repeat
//                                 L_DimensionSetEntry.Reset();
//                                 L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                                 L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if L_DimensionSetEntry.FindFirst() then begin
//                                     L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                                 end;
//                             until L_SalesShipmentLine.Next() = 0;
//                         end;

//                         L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                         if L_RemainingQuantity > 0 then
//                             exit(L_RemainingQuantity);
//                     end;
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure ExceptionPerDayAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             end;
//         End;
//     end;

//     local procedure ExceptionPerDayAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             end;
//         end;
//     end;

//     local procedure ExceptionPerDayAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             end;
//         end;
//     end;

//     local procedure ExceptionPerDaySelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             end;
//         end;
//     end;

//     local procedure ExceptionPerDaySelCustomerGroupAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             end;
//         end;
//     end;

//     local procedure ExceptionPerDaySelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Exception Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") and (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin
//                 //Perday Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //Perday SHipped Qty++
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             end;
//         end;
//     end;

//     local procedure PerMonthSelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_SaleasHeader: Record "Sales Header";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//                 L_MaxOrderQty.SetRange("Item Code", ItemCat);
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                         //Permonth Web orders Qty++++++
//                         L_InterimSalesLinePerdayQuantity.Reset();
//                         L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                         L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                         L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                         L_InterimSalesLinePerdayQuantity.SetRange("Item Category Code", ItemCat);
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Order Date", '%1..%2', Sdate, Edate);
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                         if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                             repeat
//                                 DefaultDimension_2.Reset();
//                                 DefaultDimension_2.SetRange("Table ID", 18);
//                                 DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                                 DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                                 DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if DefaultDimension_2.FindFirst() then begin
//                                     L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                                 end;
//                             until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                         end;

//                         //Permonth SHipped Qty+++++
//                         L_SalesShipmentLine.Reset();
//                         L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
//                         L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                         L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
//                         if L_SalesShipmentLine.FindSet() then begin
//                             repeat
//                                 L_DimensionSetEntry.Reset();
//                                 L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                                 L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if L_DimensionSetEntry.FindFirst() then begin
//                                     L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                                 end;
//                             until L_SalesShipmentLine.Next() = 0;
//                         end;

//                         L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                         if L_RemainingQuantity > 0 then
//                             exit(L_RemainingQuantity);
//                     end;
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerMonthSelDimensionAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_SaleasHeader: Record "Sales Header";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                         //PerMonth Web orders Qty++++++
//                         L_InterimSalesLinePerdayQuantity.Reset();
//                         L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                         L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                         L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                         L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Order Date", '%1..%2', Sdate, Edate);
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                         if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                             repeat
//                                 DefaultDimension_2.Reset();
//                                 DefaultDimension_2.SetRange("Table ID", 18);
//                                 DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                                 DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                                 DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if DefaultDimension_2.FindFirst() then begin
//                                     L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                                 end;
//                             until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                         end;

//                         //PerMonth SHipped Qty+++++
//                         L_SalesShipmentLine.Reset();
//                         L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
//                         L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                         L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
//                         if L_SalesShipmentLine.FindSet() then begin
//                             repeat
//                                 L_DimensionSetEntry.Reset();
//                                 L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                                 L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if L_DimensionSetEntry.FindFirst() then begin
//                                     L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                                 end;
//                             until L_SalesShipmentLine.Next() = 0;
//                         end;

//                         L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                         if L_RemainingQuantity > 0 then
//                             exit(L_RemainingQuantity);
//                     end;
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerMonthSelDimensionSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//                 L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                         //Permonth Web orders Qty++++++
//                         L_InterimSalesLinePerdayQuantity.Reset();
//                         L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                         L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                         L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                         L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Order Date", '%1..%2', Sdate, Edate);
//                         L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                         if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                             repeat
//                                 DefaultDimension_2.Reset();
//                                 DefaultDimension_2.SetRange("Table ID", 18);
//                                 DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                                 DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                                 DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if DefaultDimension_2.FindFirst() then begin
//                                     L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                                 end;
//                             until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                         end;

//                         //Permonth SHipped Qty+++++
//                         L_SalesShipmentLine.Reset();
//                         L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
//                         L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                         L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
//                         if L_SalesShipmentLine.FindSet() then begin
//                             repeat
//                                 L_DimensionSetEntry.Reset();
//                                 L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                                 L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                                 L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                                 if L_DimensionSetEntry.FindFirst() then begin
//                                     L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                                 end;
//                             until L_SalesShipmentLine.Next() = 0;
//                         end;

//                         L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                         if L_RemainingQuantity > 0 then
//                             exit(L_RemainingQuantity);
//                     end;
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerMonthSelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SetFilter(L_DayWiseWebOrderQty.Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.Close();

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthSelCustomerGroupAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SetFilter(L_DayWiseWebOrderQty.Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.Close();

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthSelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0); 
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SetFilter(L_DayWiseWebOrderQty.Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.Close();

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //PerDay Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //PerDay SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthSelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //Permonth Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //Permonth SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthSelCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //Permonth Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //Permonth SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerMonthSelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]; Sdate: date; Edate: Date): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             if (L_MaxOrderQty."Start Date" <= _InterimSalesHeader."Order Date") AND (L_MaxOrderQty."End Date" >= _InterimSalesHeader."Order Date") then begin

//                 //Permonth Web orders Qty++++++
//                 L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//                 L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseWebOrderQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseWebOrderQty.OPEN;
//                 WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//                 END;
//                 L_DayWiseWebOrderQty.CLOSE;

//                 //Permonth SHipped Qty++
//                 L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//                 L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//                 L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
//                 L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//                 L_DayWiseShippedQty.OPEN;
//                 WHILE L_DayWiseShippedQty.READ DO BEGIN
//                     L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//                 END;
//                 L_DayWiseShippedQty.CLOSE;

//                 L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                 if L_RemainingQuantity > 0 then
//                     exit(L_RemainingQuantity);
//             End else
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerDaySelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //Perday Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //Perday SHipped Qty++
//             L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             if L_RemainingQuantity > 0 then
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerDaySelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             if L_RemainingQuantity > 0 then
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerDaySelCustomerGroupAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesLine."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.No, _InterimSalesLine."No.");
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _InterimSalesLine."Customer Price Group");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             if L_RemainingQuantity > 0 then
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerDaySelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//                 L_MaxOrderQty.SetRange("Item Code", ItemCat);
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     //PerDay Web orders Qty++++++
//                     L_InterimSalesLinePerdayQuantity.Reset();
//                     L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                     L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                     L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                     L_InterimSalesLinePerdayQuantity.SetRange("Item Category Code", ItemCat);
//                     L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
//                     L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                     if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                         repeat
//                             DefaultDimension_2.Reset();
//                             DefaultDimension_2.SetRange("Table ID", 18);
//                             DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                             DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                             DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                             DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                             if DefaultDimension_2.FindFirst() then begin
//                                 L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                             end;
//                         until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                     end;

//                     //PerDay SHipped Qty+++++
//                     L_SalesShipmentLine.Reset();
//                     L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
//                     L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                     L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
//                     if L_SalesShipmentLine.FindSet() then begin
//                         repeat
//                             L_DimensionSetEntry.Reset();
//                             L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                             L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                             L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                             if L_DimensionSetEntry.FindFirst() then begin
//                                 L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                             end;
//                         until L_SalesShipmentLine.Next() = 0;
//                     end;

//                     L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                     if L_RemainingQuantity > 0 then
//                         exit(L_RemainingQuantity);
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerDaySelDimensionAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0) ;
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     //PerDay Web orders Qty++++++
//                     L_InterimSalesLinePerdayQuantity.Reset();
//                     L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                     L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                     L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                     L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
//                     L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
//                     L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                     if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                         repeat
//                             DefaultDimension_2.Reset();
//                             DefaultDimension_2.SetRange("Table ID", 18);
//                             DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                             DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                             DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                             DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                             if DefaultDimension_2.FindFirst() then begin
//                                 L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                             end;
//                         until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                     end;

//                     //PerDay SHipped Qty+++++
//                     L_SalesShipmentLine.Reset();
//                     L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
//                     L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                     L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
//                     if L_SalesShipmentLine.FindSet() then begin
//                         repeat
//                             L_DimensionSetEntry.Reset();
//                             L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                             L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                             L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                             if L_DimensionSetEntry.FindFirst() then begin
//                                 L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                             end;
//                         until L_SalesShipmentLine.Next() = 0;
//                     end;

//                     L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                     if L_RemainingQuantity > 0 then
//                         exit(L_RemainingQuantity);
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerDaySelDimensionSelItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record 60600;
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";

//         //New
//         DefaultDimension_2: Record "Default Dimension";
//         L_DimensionSetEntry: Record "Dimension Set Entry";
//         L_SalesShipmentLine: Record "Sales Shipment Line";
//         L_InterimSalesLinePerdayQuantity: Record "Interim Sales Line";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_DayOrderQty);
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//                 L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     //PerDay Web orders Qty++++++
//                     L_InterimSalesLinePerdayQuantity.Reset();
//                     L_InterimSalesLinePerdayQuantity.SetRange("Document Type", _InterimSalesHeader."Document Type");
//                     L_InterimSalesLinePerdayQuantity.SETFILTER("Document No", '<>%1', _InterimSalesHeader."No.");
//                     L_InterimSalesLinePerdayQuantity.SetRange(Type, L_InterimSalesLinePerdayQuantity.Type::Item);
//                     L_InterimSalesLinePerdayQuantity.SetRange("No.", _InterimSalesLine."No.");
//                     L_InterimSalesLinePerdayQuantity.SETRANGE("Order Date", _InterimSalesHeader."Order Date");
//                     L_InterimSalesLinePerdayQuantity.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
//                     if L_InterimSalesLinePerdayQuantity.FindSet() then begin
//                         repeat
//                             DefaultDimension_2.Reset();
//                             DefaultDimension_2.SetRange("Table ID", 18);
//                             DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
//                             DefaultDimension_2.SetRange("No.", L_InterimSalesLinePerdayQuantity."Sell-to Customer No.");
//                             DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                             DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                             if DefaultDimension_2.FindFirst() then begin
//                                 L_DayOrderQty += L_InterimSalesLinePerdayQuantity."Qty. to Deliver";
//                             end;
//                         until L_InterimSalesLinePerdayQuantity.Next() = 0;
//                     end;

//                     //PerDay SHipped Qty+++++
//                     L_SalesShipmentLine.Reset();
//                     L_SalesShipmentLine.SetRange("No.", _InterimSalesLine."No.");
//                     L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
//                     L_SalesShipmentLine.SetRange("Order Date", _InterimSalesHeader."Order Date");
//                     if L_SalesShipmentLine.FindSet() then begin
//                         repeat
//                             L_DimensionSetEntry.Reset();
//                             L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
//                             L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
//                             L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
//                             if L_DimensionSetEntry.FindFirst() then begin
//                                 L_DayOrderQty += L_SalesShipmentLine.Quantity;
//                             end;
//                         until L_SalesShipmentLine.Next() = 0;
//                     end;

//                     L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//                     if L_RemainingQuantity > 0 then
//                         exit(L_RemainingQuantity);
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerDaySelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//             L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerDaySelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//             L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerDaySelCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesLine."Sell-to Customer No.");
//             L_DayWiseWebOrderQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//             L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _InterimSalesHeader."Ship-to Code");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerDayAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(L_DayWiseWebOrderQty.Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(L_DayWiseWebOrderQty.Item_Category_Code, ItemCat);
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             if L_RemainingQuantity > 0 then
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerDayAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             if L_RemainingQuantity > 0 then
//                 exit(L_RemainingQuantity);
//         End;
//     end;

//     local procedure PerDayAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_DayOrderQty: Decimal;
//         L_RemainingQuantity: Decimal;
//         L_DayWiseShippedQty: Query "DayShippe Qty Copy";
//         L_DayWiseWebOrderQty: Query "Daywise Web order quantity";
//     begin
//         Clear(L_DayOrderQty);
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             //PerDay Web orders Qty++++++
//             L_DayWiseWebOrderQty.SetRange(Document_Type, _InterimSalesHeader."Document Type");
//             L_DayWiseWebOrderQty.SETFILTER(L_DayWiseWebOrderQty.Doc_No, '<>%1', _InterimSalesHeader."No.");
//             L_DayWiseWebOrderQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseWebOrderQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseWebOrderQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseWebOrderQty.OPEN;
//             WHILE L_DayWiseWebOrderQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseWebOrderQty.Sum_Quantity;
//             END;
//             L_DayWiseWebOrderQty.CLOSE;

//             //PerDay SHipped Qty++
//             L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _InterimSalesHeader."Sell-to Customer No.");
//             L_DayWiseShippedQty.SETRANGE(Order_Date, _InterimSalesHeader."Order Date");
//             L_DayWiseShippedQty.SETRANGE(No, _InterimSalesLine."No.");
//             L_DayWiseShippedQty.OPEN;
//             WHILE L_DayWiseShippedQty.READ DO BEGIN
//                 L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
//             END;
//             L_DayWiseShippedQty.CLOSE;

//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
//             if L_RemainingQuantity > 0 then
//                 exit(L_RemainingQuantity);
//         end;
//     end;

//     local procedure PerOrderSelCustomerGroupSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;

//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderSelCustomerGroupSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;

//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderSelCustomerGroupAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Customer Price Group");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;

//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderSelCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderSelCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderSelDimensionSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//     begin
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//                 L_MaxOrderQty.SetRange("Item Code", ItemCat);
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//                     exit(L_RemainingQuantity);
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerOrderSelDimensionAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//     begin
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//                     exit(L_RemainingQuantity);
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerOrderSelDimensionSelItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//         L_DefaultDimension: Record "Default Dimension";
//     begin
//         Clear(L_RemainingQuantity);

//         L_DefaultDimension.Reset();
//         L_DefaultDimension.SetRange("Table ID", 18);
//         L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
//         L_DefaultDimension.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
//         if L_DefaultDimension.FindSet() then begin
//             repeat
//                 Clear(L_RemainingQuantity);

//                 L_MaxOrderQty.RESET;
//                 L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
//                 L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
//                 L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
//                 L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//                 L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//                 L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//                 L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//                 //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//                 IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//                     L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//                     exit(L_RemainingQuantity);
//                 end;
//             until L_DefaultDimension.Next() = 0;
//         end;
//     end;

//     local procedure PerOrderSelCustomerAllItem(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
//         L_MaxOrderQty.SetRange("Sales Code", _InterimSalesHeader."Sell-to Customer No.");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Ship-to Code", _InterimSalesHeader."Ship-to Code");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;
//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderAllCustomerSelItemCatQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
//         L_MaxOrderQty.SetRange("Item Code", ItemCat);
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;

//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderAllCustomerAllItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;

//         exit(L_RemainingQuantity);
//     end;

//     local procedure PerOrderAllCustomerSelItemQty(_InterimSalesLine: Record "Interim Sales Line"; _InterimSalesHeader: Record "Interim Sales Header"; ItemCat: code[20]): Decimal
//     var
//         L_MaxOrderQty: Record "Sales Quota";
//         L_RemainingQuantity: Decimal;
//     begin
//         Clear(L_RemainingQuantity);

//         L_MaxOrderQty.RESET;
//         L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
//         L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
//         L_MaxOrderQty.SetRange("Item Code", _InterimSalesLine."No.");
//         L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
//         L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
//         //L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
//         IF L_MaxOrderQty.FINDFIRST THEN BEGIN
//             L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";
//         end;

//         exit(L_RemainingQuantity);
//     end;
// }