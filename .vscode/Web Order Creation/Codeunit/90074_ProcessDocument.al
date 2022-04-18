codeunit 90074 MyCodeunit2
{
    trigger OnRun()
    begin

    end;


    /*procedure CreateItemTrackingLines(WhIntPickHeader: Record "Whse. Internal Pick Header"; P_ZoneFilter: Code[20])
       var
           L_WhseIntPickL: Record "Whse. Internal Pick Line";
           AppliedQty: Decimal;
           RemQty: Decimal;
           TradePartner: Record 90005;//NG_Variable_check
       begin
           L_WhseIntPickL.RESET;
           L_WhseIntPickL.SETRANGE("No.", WhIntPickHeader."No.");
           IF L_WhseIntPickL.FINDSET THEN
               REPEAT

                   AppliedQty := CheckAllocatedQty(L_WhseIntPickL."Item No.", "Whse. Internal Pick Line", 0, L_WhseIntPickL."Line No.", L_WhseIntPickL."Location Code", L_WhseIntPickL."No.");
                   TempGlobalEntrySummary.DELETEALL;
                   TempGlobalReservEntry.DELETEALL;
                   CLEAR(TempGlobalEntrySummary);
                   CLEAR(TempGlobalReservEntry);
                   CLEAR(RemQty);
                   IF ABS(AppliedQty) <= L_WhseIntPickL."Qty. (Base)" THEN BEGIN//"Qty. Outstanding (Base)"

                       RemQty := L_WhseIntPickL."Qty. (Base)" - ABS(AppliedQty);//"Qty. Outstanding (Base)"


                       IF TradePartner.GET(WhIntPickHeader."Channel Code") THEN;
                       CalculateQtyandBatchFromILE(L_WhseIntPickL."Item No.", L_WhseIntPickL."Location Code", L_WhseIntPickL."Variant Code", L_WhseIntPickL."No.", "Whse. Internal Pick Line", TradePartner."Customer No.");
                       ///////////////////////////////////////////////////////
                       IF TempGlobalEntrySummary.FINDFIRST THEN;
                       //REPEAT
                       /////////////////////////////////////////////////////////
                       CLEAR(QtyToApply);

                       WHILE ((RemQty > 0) AND (TempGlobalEntrySummary."Total Available Quantity" > 0)) DO BEGIN
                           IF USERID = 'PS-NAV1\Robosol' THEN
                               MESSAGE(FORMAT(TempGlobalEntrySummary."Total Available Quantity"));
                           CLEAR(QtyonInternalPick);
                           //   MESSAGE(FORMAT(TempGlobalEntrySummary."Lot No."));
                           QtyonInternalPick := AutoBatchAllocation.QtyReservedonInternalPick(L_WhseIntPickL."No.", TempGlobalEntrySummary."Lot No.", L_WhseIntPickL."Location Code", "Whse. Internal Pick Line");
                           //MESSAGE(FORMAT(QtyonInternalPick));
                           TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - CreatePick.CalcQtyOnOutboundBins_AutoAllocation(L_WhseIntPickL."Location Code", L_WhseIntPickL."No.", L_WhseIntPickL."Variant Code",
                                                                                TempGlobalEntrySummary."Lot No.", TempGlobalEntrySummary."Serial No.", TRUE, TempGlobalEntrySummary."Total Available Quantity")//ak 270920
                                                                                - AutoBatchAllocation.QtyinPutawayBin(L_WhseIntPickL."Location Code", L_WhseIntPickL."No.", TempGlobalEntrySummary."Lot No.");//-QtyonInternalPick;
                           QtyToApply := TempGlobalEntrySummary."Total Available Quantity";
                           IF USERID = 'PS-NAV1\Robosol' THEN
                               MESSAGE(FORMAT(QtyToApply));
                           // MESSAGE(FORMAT(QtyToApply));
                           IF CheckDDBin(TempGlobalEntrySummary, L_WhseIntPickL, P_ZoneFilter, QtyToApply) THEN//ak 2106 passed zone filter
                           BEGIN
                               IF QtyToApply > RemQty THEN
                                   QtyToApply := RemQty ELSE
                                   QtyToApply := QtyToApply;

                               IF QtyToApply > 0 THEN BEGIN
                                   WhseItemTrackingLines.InsertItemTrackingLineCustom(L_WhseIntPickL, '', TempGlobalEntrySummary."Lot No.", 0D, QtyToApply, DATABASE::"Whse. Internal Pick Line");
                                   TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - QtyToApply;
                                   TempGlobalEntrySummary.MODIFY;
                                   RemQty := RemQty - QtyToApply;
                               END;
                               TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - QtyToApply;
                           END ELSE BEGIN
                               TempGlobalEntrySummary."Total Available Quantity" := 0;
                               TempGlobalEntrySummary.MODIFY;
                           END;
                           TempGlobalEntrySummary.NEXT;
                       END;
                       //UNTIL TempGlobalEntrySummary.NEXT;
                   END;
               //UpdateLotOnWebOrder(L_WhseIntPickL); //Commented by chandna 220620++ Not Required to updated on weorder
               UNTIL L_WhseIntPickL.NEXT = 0;

       end;*///NG_No_Need

    /*  local procedure CalculateQtyandBatchFromILE(P_ItemNo: Code[20]; P_LocationCode: Code[20]; P_VariantCode: Code[20]; SourceID: Code[20]; CallFrom: Integer; CustomerNo: Code[20])
      var
          L_ILE: Record 32;
          ReservEntry: Record 337;
          LastReservEntryNo: Integer;
          RecWhseItemTracking: Record 6550;
      begin
          ReservEntry.RESET;

          IF ReservEntry.FINDLAST THEN
              LastReservEntryNo := ReservEntry."Entry No.";
          ReservEntry.SETCURRENTKEY(
            "Item No.", "Variant Code", "Location Code", "Item Tracking", "Reservation Status", "Lot No.", "Serial No.");
          ReservEntry.SETRANGE("Item No.", P_ItemNo);
          ReservEntry.SETRANGE("Variant Code", P_VariantCode);
          ReservEntry.SETRANGE("Location Code", P_LocationCode);
          ReservEntry.SETFILTER("Item Tracking", '<>%1', ReservEntry."Item Tracking"::None);


          //RecWhseItemTracking.SETCURRENTKEY(
          //  "Item No.","Variant Code","Location Code","Lot No.","Serial No.");
          //RecWhseItemTracking.SETRANGE("Item No.",P_ItemNo);
          //RecWhseItemTracking.SETRANGE("Variant Code",P_VariantCode);
          //RecWhseItemTracking.SETRANGE("Location Code",P_LocationCode);
          //RecWhseItemTracking.SETFILTER("Source Type",'%1|%2|%3',DATABASE::"Whse. Internal Pick Line",DATABASE::"Internal Movement Line",DATABASE::"Whse. Worksheet Line");
          // IF NOT (CallFrom=DATABASE::"Whse. Worksheet Line") THEN
          //RecWhseItemTracking.SETFILTER("Source ID",'<>%1',SourceID);

          L_ILE.RESET;
          L_ILE.SETCURRENTKEY("Item No.", Open, "Variant Code", "Location Code", "Item Tracking",
            "Lot No.", "Serial No.");
          L_ILE.ASCENDING(TRUE);
          L_ILE.SETRANGE("Item No.", P_ItemNo);
          L_ILE.SETRANGE("Variant Code", P_VariantCode);
          L_ILE.SETRANGE(Open, TRUE);
          L_ILE.SETRANGE("Location Code", P_LocationCode);


          TransferItemLedgToTempRec(L_ILE, CallFrom, P_LocationCode, P_ItemNo, SourceID, CustomerNo);
          TransferReservEntryToTempRec(ReservEntry);
          //TransferWarehouseEntryToTempRec(RecWhseItemTracking);

          TempGlobalEntrySummary.SETRANGE("Lot No.");//code blocked by alok

          TempGlobalEntrySummary.SETFILTER("Total Available Quantity", '>%1', 0);//code blocked by alok

          TempGlobalEntrySummary.SETRANGE(Blocked, FALSE);//Chandan++++220620

          IF TempGlobalEntrySummary.FINDFIRST THEN
              REPEAT

                  //UNTIL L_ForecastAllocation.NEXT = 0;
                  //New code End--------------------------------------------------------------------------------
                  TempItem.RESET;
                  TempItem.SETRANGE("No.", TempGlobalEntrySummary."Lot No. Status");
                  IF NOT TempItem.FINDFIRST THEN BEGIN
                      TempItem.INIT;
                      TempItem."No." := TempGlobalEntrySummary."Lot No. Status";
                      TempItem."Unit Price" := TempGlobalEntrySummary."Total Available Quantity";
                      TempItem.INSERT;
                  END ELSE BEGIN
                      TempItem."Unit Price" += TempGlobalEntrySummary."Total Available Quantity";
                      TempItem.MODIFY;
                  END;
              UNTIL TempGlobalEntrySummary.NEXT = 0;

      end;*/

    /*local procedure TransferItemLedgToTempRec(var ItemLedgEntry: Record 32; CallingFrom: Integer; P_LocationCode: Code[20]; P_ItemNo: Code[20]; P_SourceID: Code[20]; P_CustNo: Code[20])
    var
        CU6500: Codeunit 6500;
    begin
        IF ItemLedgEntry.FINDSET THEN
            REPEAT
                IF ItemLedgEntry.TrackingExists THEN BEGIN
                    TempTrackingSpecification.DELETEALL;
                    AutoBatchAllocation.CreateTrackingSpecification(TempTrackingSpecification, P_SourceID, P_LocationCode, ItemLedgEntry."Lot No.", CallingFrom
                                                 , P_ItemNo, FALSE);//FORMAT(5741)
                                                                    //Chandan++230620
                    TempTrackingSpecification."Customer No" := P_CustNo;
                    TempTrackingSpecification.MODIFY;
                    //Chandan++230620
                    IF NOT CU6500.LotCheckValidity(TempTrackingSpecification) THEN BEGIN
                        TempGlobalReservEntry.INIT;
                        TempGlobalReservEntry."Entry No." := -ItemLedgEntry."Entry No.";
                        TempGlobalReservEntry."Reservation Status" := TempGlobalReservEntry."Reservation Status"::Surplus;
                        TempGlobalReservEntry.Positive := ItemLedgEntry.Positive;
                        TempGlobalReservEntry."Item No." := ItemLedgEntry."Item No.";
                        TempGlobalReservEntry."Location Code" := ItemLedgEntry."Location Code";
                        TempGlobalReservEntry."Quantity (Base)" := ItemLedgEntry."Remaining Quantity";
                        TempGlobalReservEntry."Source Type" := DATABASE::"Item Ledger Entry";
                        TempGlobalReservEntry."Source Ref. No." := ItemLedgEntry."Entry No.";
                        TempGlobalReservEntry."Serial No." := ItemLedgEntry."Serial No.";
                        TempGlobalReservEntry."Lot No." := ItemLedgEntry."Lot No.";
                        TempGlobalReservEntry."Variant Code" := ItemLedgEntry."Variant Code";

                        IF TempGlobalReservEntry.Positive THEN BEGIN
                            TempGlobalReservEntry."Warranty Date" := ItemLedgEntry."Warranty Date";
                            TempGlobalReservEntry."Expiration Date" := ItemLedgEntry."Expiration Date";
                            TempGlobalReservEntry."Expected Receipt Date" := 0D
                        END ELSE
                            TempGlobalReservEntry."Shipment Date" := 31129999D;

                        IF TempGlobalReservEntry.INSERT THEN;
                        CreateEntrySummary2(1, TempGlobalReservEntry);
                    END;
                END;
            UNTIL ItemLedgEntry.NEXT = 0;
    end;*/

    /*local procedure TransferReservEntryToTempRec(var ReservEntry: Record 337)
    begin
        IF ReservEntry.FINDSET THEN
            REPEAT
                TempGlobalReservEntry := ReservEntry;
                TempGlobalReservEntry."Transferred from Entry No." := 0;
                IF TempGlobalReservEntry.INSERT THEN
                    CreateEntrySummary2(1, TempGlobalReservEntry);
            UNTIL ReservEntry.NEXT = 0;
    end;*/

    /*local procedure CreateEntrySummary2(LookupMode: Option "Serial No.","Lot No."; TempReservEntry: Record 337 temporary)
    var
        DoInsert: Boolean;
        L_LotInfo: Record 6505;
        L_ForecastAllocation: Record 50097;
    begin
        TempGlobalEntrySummary.RESET;
        TempGlobalEntrySummary.SETCURRENTKEY("Lot No.", "Serial No.");

        // Set filters
        CASE LookupMode OF
            LookupMode::"Serial No.":
                BEGIN
                    IF TempReservEntry."Serial No." = '' THEN
                        EXIT;
                    TempGlobalEntrySummary.SETRANGE("Serial No.", TempReservEntry."Serial No.");
                    TempGlobalEntrySummary.SETRANGE("Lot No.", TempReservEntry."Lot No.");
                END;
            LookupMode::"Lot No.":
                BEGIN
                    TempGlobalEntrySummary.SETRANGE("Serial No.", '');
                    TempGlobalEntrySummary.SETRANGE("Lot No.", TempReservEntry."Lot No.");
                    IF TempReservEntry."Serial No." <> '' THEN
                        TempGlobalEntrySummary.SETRANGE("Table ID", 0)
                    ELSE
                        TempGlobalEntrySummary.SETFILTER("Table ID", '<>%1', 0);
                END;
        END;

        // If no summary exists, create new record
        IF NOT TempGlobalEntrySummary.FINDFIRST THEN BEGIN
            TempGlobalEntrySummary.INIT;
            TempGlobalEntrySummary."Entry No." := LastSummaryEntryNo + 1;
            LastSummaryEntryNo := TempGlobalEntrySummary."Entry No.";

            IF (LookupMode = LookupMode::"Lot No.") AND (TempReservEntry."Serial No." <> '') THEN
                TempGlobalEntrySummary."Table ID" := 0 // Mark as summation
            ELSE
                TempGlobalEntrySummary."Table ID" := TempReservEntry."Source Type";
            IF LookupMode = LookupMode::"Serial No." THEN
                TempGlobalEntrySummary."Serial No." := TempReservEntry."Serial No."
            ELSE
                TempGlobalEntrySummary."Serial No." := '';
            TempGlobalEntrySummary."Lot No." := TempReservEntry."Lot No.";
            //CAS-06164-M8T0Y1 Start
            IF L_LotInfo.GET(TempReservEntry."Item No.", TempGlobalReservEntry."Variant Code", TempReservEntry."Lot No.") THEN BEGIN
                TempGlobalEntrySummary.Blocked := L_LotInfo."Sales Blocked";
                TempGlobalEntrySummary."Lot No. Status" := L_LotInfo."Certificate Number";
            END;
            //CAS-06164-M8T0Y1 End
            //TempGlobalEntrySummary."Bin Active" := CurrBinCode <> '';
            AutoBatchAllocation.UpdateBinContent(TempGlobalEntrySummary);

            // If consumption/output fill in double entry value here:
            //TempGlobalEntrySummary."Double-entry Adjustment" :=
            // MaxDoubleEntryAdjustQty(TrackingSpecification,TempGlobalEntrySummary);

            DoInsert := TRUE;
        END;

        // Sum up values
        IF TempReservEntry.Positive THEN BEGIN
            TempGlobalEntrySummary."Warranty Date" := TempReservEntry."Warranty Date";
            TempGlobalEntrySummary."Expiration Date" := TempReservEntry."Expiration Date";
            IF TempReservEntry."Entry No." < 0 THEN // The record represents an Item ledger entry
                TempGlobalEntrySummary."Total Quantity" += TempReservEntry."Quantity (Base)";
            IF TempReservEntry."Reservation Status" = TempReservEntry."Reservation Status"::Reservation THEN
                TempGlobalEntrySummary."Total Reserved Quantity" += TempReservEntry."Quantity (Base)";
        END ELSE BEGIN
            TempGlobalEntrySummary."Total Requested Quantity" -= TempReservEntry."Quantity (Base)";
            //IF HasSamePointer(TrackingSpecification,TempReservEntry) THEN BEGIN
            IF TempReservEntry."Reservation Status" = TempReservEntry."Reservation Status"::Reservation THEN
                TempGlobalEntrySummary."Current Reserved Quantity" -= TempReservEntry."Quantity (Base)";
            IF TempReservEntry."Entry No." > 0 THEN // The record represents a reservation entry
                TempGlobalEntrySummary."Current Requested Quantity" -= TempReservEntry."Quantity (Base)";
            //END;
        END;

        // Update available quantity on the record
        TempGlobalEntrySummary.UpdateAvailable;
        IF DoInsert THEN
            TempGlobalEntrySummary.INSERT
        ELSE
            TempGlobalEntrySummary.MODIFY;
    end;*///NG_No_Need

    /*local procedure TransferWarehouseEntryToTempRec(var ReservEntry: Record 6550)
    begin
        IF ReservEntry.FINDSET THEN
            REPEAT
                TempGlobalwhseItemtracking := ReservEntry;
                IF TempGlobalwhseItemtracking.INSERT THEN;
                CreateEntrySummarywhseTracking(1, TempGlobalwhseItemtracking);
            UNTIL ReservEntry.NEXT = 0;
    end;*///NG_No_Need

    /*local procedure CreateEntrySummarywhseTracking(LookupMode: Option "Serial No.","Lot No."; TempReservEntry: Record 6550 temporary)
    var
        DoInsert: Boolean;
        L_LotInfo: Record 6505;
        L_ForecastAllocation: Record 50097;
    begin
        TempGlobalEntrySummary.RESET;
        TempGlobalEntrySummary.SETCURRENTKEY("Lot No.", "Serial No.");

        // Set filters
        CASE LookupMode OF
            LookupMode::"Serial No.":
                BEGIN
                    IF TempReservEntry."Serial No." = '' THEN
                        EXIT;
                    TempGlobalEntrySummary.SETRANGE("Serial No.", TempReservEntry."Serial No.");
                    TempGlobalEntrySummary.SETRANGE("Lot No.", TempReservEntry."Lot No.");
                END;
            LookupMode::"Lot No.":
                BEGIN
                    TempGlobalEntrySummary.SETRANGE("Serial No.", '');
                    TempGlobalEntrySummary.SETRANGE("Lot No.", TempReservEntry."Lot No.");
                    IF TempReservEntry."Serial No." <> '' THEN
                        TempGlobalEntrySummary.SETRANGE("Table ID", 0)
                    ELSE
                        TempGlobalEntrySummary.SETFILTER("Table ID", '<>%1', 0);
                END;
        END;

        // If no summary exists, create new record
        IF NOT TempGlobalEntrySummary.FINDFIRST THEN BEGIN
            TempGlobalEntrySummary.INIT;
            TempGlobalEntrySummary."Entry No." := LastSummaryEntryNo + 1;
            LastSummaryEntryNo := TempGlobalEntrySummary."Entry No.";

            IF (LookupMode = LookupMode::"Lot No.") AND (TempReservEntry."Serial No." <> '') THEN
                TempGlobalEntrySummary."Table ID" := 0 // Mark as summation
            ELSE
                TempGlobalEntrySummary."Table ID" := TempReservEntry."Source Type";
            IF LookupMode = LookupMode::"Serial No." THEN
                TempGlobalEntrySummary."Serial No." := TempReservEntry."Serial No."
            ELSE
                TempGlobalEntrySummary."Serial No." := '';
            TempGlobalEntrySummary."Lot No." := TempReservEntry."Lot No.";
            //CAS-06164-M8T0Y1 Start
            IF L_LotInfo.GET(TempReservEntry."Item No.", TempGlobalReservEntry."Variant Code", TempReservEntry."Lot No.") THEN BEGIN
                TempGlobalEntrySummary.Blocked := L_LotInfo."Sales Blocked";
                TempGlobalEntrySummary."Lot No. Status" := L_LotInfo."Certificate Number";
            END;
            //CAS-06164-M8T0Y1 End
            //TempGlobalEntrySummary."Bin Active" := CurrBinCode <> '';
            AutoBatchAllocation.UpdateBinContent(TempGlobalEntrySummary);

            // If consumption/output fill in double entry value here:
            //TempGlobalEntrySummary."Double-entry Adjustment" :=
            // MaxDoubleEntryAdjustQty(TrackingSpecification,TempGlobalEntrySummary);

            DoInsert := TRUE;
        END;

        // Sum up values
        TempGlobalEntrySummary."Total Requested Quantity" += TempReservEntry."Quantity (Base)";
        //IF HasSamePointer(TrackingSpecification,TempReservEntry) THEN BEGIN
        TempGlobalEntrySummary."Current Reserved Quantity" += TempReservEntry."Quantity (Base)";
        IF TempReservEntry."Entry No." > 0 THEN // The record represents a reservation entry
            TempGlobalEntrySummary."Current Requested Quantity" += TempReservEntry."Quantity (Base)";
        //END;
        //END;

        // Update available quantity on the record
        TempGlobalEntrySummary.UpdateAvailable;
        IF DoInsert THEN
            TempGlobalEntrySummary.INSERT
        ELSE
            TempGlobalEntrySummary.MODIFY;

    end;*///NG_No_Need

    /*local procedure CheckDDBin(var TempEntrySummary: Record 338 temporary; WhseInternalPickLine: Record "Whse. Internal Pick Line"; P_ZoneFilter: Code[20]; var QtyToApply: Decimal): Boolean
    var
        WarehouseEntry: Record 7312;
        Qty: Decimal;
        PriorityZones: Record 50012;
        CreatePick: Codeunit 7312;
        L_BinContent: Record 7302;
    begin

        IF P_ZoneFilter = '' THEN
            EXIT(TRUE);

        CreatePick.CheckZonePriority(WhseInternalPickLine."Location Code", P_ZoneFilter);//Check if zone priority is added for Pick Zone filter.
        PriorityZones.RESET;
        PriorityZones.SETRANGE("Location Code", WhseInternalPickLine."Location Code");
        PriorityZones.SETRANGE("Zone Code", P_ZoneFilter);
        PriorityZones.SETCURRENTKEY("Priority Sequence");
        PriorityZones.ASCENDING(TRUE);
        IF PriorityZones.FINDSET THEN
            REPEAT
                WarehouseEntry.RESET;
                WarehouseEntry.SETCURRENTKEY(
                  "Item No.", "Bin Code", "Location Code", "Variant Code",
                  "Unit of Measure Code", "Lot No.", "Serial No.");
                //WarehouseEntry.SETRANGE("Item No.",WhseInternalPickLine."Item No.");
                //IF P_ZoneFilter <> '' THEN
                //alok 220720 ++
                L_BinContent.RESET;
                L_BinContent.SETRANGE("Item No.", WhseInternalPickLine."Item No.");
                L_BinContent.SETRANGE("Location Code", PriorityZones."Location Code");
                L_BinContent.SETRANGE("Zone Code", PriorityZones."Priority Zone Code");
                L_BinContent.SETRANGE("Lot No. Filter", TempEntrySummary."Lot No.");
                L_BinContent.SETFILTER(Quantity, '>%1', 0);
                IF L_BinContent.FINDFIRST THEN
                    REPEAT
                        Qty += L_BinContent.CalcQtyAvailToTakeUOM;
                    UNTIL L_BinContent.NEXT = 0;
            //alok 220720 --
            //Qty += WarehouseEntry."Qty. (Base)";
            UNTIL PriorityZones.NEXT = 0;
        IF Qty > QtyToApply THEN
            QtyToApply := QtyToApply ELSE
            QtyToApply := Qty;


        //QtyToApply:=Qty;
        IF Qty > 0 THEN
            EXIT(TRUE);

    end;*///NG_No_Need

    /* local procedure TransferwhseItemTrackingToTemp(var RecWhseInternalPickLine: Record "Whse. Internal Pick Line")
     var
         RecWhseItemTrackingLine: Record "Whse. Item Tracking Line";
         RecInterimSalesLine: Record "Interim Sales Line";
     begin
         RecWhseItemTrackingLine.RESET;
         RecWhseItemTrackingLine.SETCURRENTKEY("Item No.", "Source Type", "Source Subtype", "Source Ref. No.", "Location Code");
         RecWhseItemTrackingLine.SETRANGE("Source ID", RecWhseInternalPickLine."No.");
         RecWhseItemTrackingLine.SETRANGE("Item No.", RecWhseInternalPickLine."Item No.");
         RecWhseItemTrackingLine.SETRANGE("Source Type", 7334);
         RecWhseItemTrackingLine.SETRANGE("Source Subtype", 0);
         RecWhseItemTrackingLine.SETRANGE("Source Ref. No.", RecWhseInternalPickLine."Line No.");
         RecWhseItemTrackingLine.SETRANGE("Location Code", RecWhseInternalPickLine."Location Code");
         IF RecWhseItemTrackingLine.FINDSET THEN
             REPEAT
                 TempWhseItemTracking.RESET;
                 TempWhseItemTracking.SETRANGE("Item No.", RecWhseItemTrackingLine."Item No.");
                 TempWhseItemTracking.SETRANGE("Lot No.", RecWhseItemTrackingLine."Lot No.");
                 IF NOT TempWhseItemTracking.FINDFIRST THEN BEGIN
                     TempWhseItemTracking.INIT;
                     TempWhseItemTracking."Item No." := RecWhseItemTrackingLine."Item No.";
                     TempWhseItemTracking."Lot No." := RecWhseItemTrackingLine."Lot No.";
                     TempWhseItemTracking."Qty. (Base)" := RecWhseItemTrackingLine."Qty. to Handle (Base)";
                     TempWhseItemTracking."Location Code" := RecWhseItemTrackingLine."Location Code";
                     TempWhseItemTracking.INSERT;
                 END ELSE BEGIN
                     TempWhseItemTracking."Qty. (Base)" += RecWhseItemTrackingLine."Qty. to Handle (Base)";
                     TempWhseItemTracking.MODIFY;
                 END;
             UNTIL RecWhseItemTrackingLine.NEXT = 0;
     end;*/



    /*procedure CreateItemTrackingLinesMovWS(var L_WhseWorksheetLine: Record 7326)
    var
        AppliedQty: Decimal;
        RemQty: Decimal;
    begin
        IF L_WhseWorksheetLine.FINDSET THEN
            REPEAT
                AppliedQty := CheckAllocatedQty(L_WhseWorksheetLine."Item No.", 7326, 0, L_WhseWorksheetLine."Line No.", L_WhseWorksheetLine."Location Code", L_WhseWorksheetLine.Name);
                TempGlobalEntrySummary.DELETEALL;
                TempGlobalReservEntry.DELETEALL;
                CLEAR(TempGlobalEntrySummary);
                CLEAR(TempGlobalReservEntry);
                CLEAR(RemQty);
                IF ABS(AppliedQty) < L_WhseWorksheetLine."Qty. Outstanding (Base)" THEN BEGIN
                    RemQty := L_WhseWorksheetLine."Qty. Outstanding (Base)" - ABS(AppliedQty);


                    CalculateQtyandBatchFromILE(L_WhseWorksheetLine."Item No.", L_WhseWorksheetLine."Location Code", L_WhseWorksheetLine."Variant Code", L_WhseWorksheetLine.Name, 7326, '');
                    ///////////////////////////////////////////////////////
                    IF TempGlobalEntrySummary.FINDFIRST THEN;
                    /////////////////////////////////////////////////////////
                    CLEAR(QtyToApply);
                    WHILE ((RemQty > 0) AND (TempGlobalEntrySummary."Total Available Quantity" > 0)) DO BEGIN
                        IF CheckCurrentBin(TempGlobalEntrySummary, L_WhseWorksheetLine) THEN BEGIN
                            CLEAR(QtyonInternalPick);
                            QtyonInternalPick := AutoBatchAllocation.QtyReservedonInternalPick(L_WhseWorksheetLine."Item No.", TempGlobalEntrySummary."Lot No.", L_WhseWorksheetLine."Location Code", "Whse. Internal Pick Line");

                            TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - CreatePick.CalcQtyOnOutboundBins_AutoAllocation(L_WhseWorksheetLine."Location Code", L_WhseWorksheetLine."Item No.",
                                                 L_WhseWorksheetLine."Variant Code", TempGlobalEntrySummary."Lot No.", TempGlobalEntrySummary."Serial No.", TRUE, TempGlobalEntrySummary."Total Available Quantity")//ak 270920
                                                 - AutoBatchAllocation.QtyinPutawayBin(L_WhseWorksheetLine."Location Code", L_WhseWorksheetLine."Item No.", TempGlobalEntrySummary."Lot No.") - QtyonInternalPick;


                            QtyToApply := TempGlobalEntrySummary."Total Available Quantity";

                            IF QtyToApply > RemQty THEN
                                QtyToApply := RemQty ELSE
                                QtyToApply := QtyToApply;

                            IF QtyToApply > 0 THEN BEGIN
                                L_WhseWorksheetLine.SetItemTrackingLines('', TempGlobalEntrySummary."Lot No.", 0D, QtyToApply);
                                // WhseItemTrackingLines.InsertItemTrackingLine(L_WhseWorksheetLine,'',TempGlobalEntrySummary."Lot No.",0D,QtyToApply);
                            END;
                            TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - RemQty;
                            //UpdateRangePlanallocationForfreeStock("Sales Line",QtyToApply);//code to consume allocation qty if free stock is reserved on sales order

                            RemQty := RemQty - QtyToApply;
                        END ELSE
                            TempGlobalEntrySummary."Total Available Quantity" := 0;
                        TempGlobalEntrySummary.NEXT;
                    END;
                END;
            UNTIL L_WhseWorksheetLine.NEXT = 0;
    end;*///NG_No_Need

    local procedure CheckCurrentBin(var TempEntrySummary: Record "Entry Summary" temporary; WorksheetLine: Record "Whse. Worksheet Line"): Boolean
    var
        WarehouseEntry: Record "Warehouse Entry";
        Qty: Decimal;
    begin
        WarehouseEntry.RESET;
        WarehouseEntry.SETCURRENTKEY(
          "Item No.", "Bin Code", "Location Code", "Variant Code",
          "Unit of Measure Code", "Lot No.", "Serial No.");
        WarehouseEntry.SETRANGE("Item No.", WorksheetLine."Item No.");
        WarehouseEntry.SETRANGE("Zone Code", WorksheetLine."From Zone Code");
        WarehouseEntry.SETRANGE("Bin Code", WorksheetLine."From Bin Code");
        WarehouseEntry.SETRANGE("Location Code", WorksheetLine."Location Code");
        WarehouseEntry.SETRANGE("Lot No.", TempEntrySummary."Lot No.");
        WarehouseEntry.CALCSUMS("Qty. (Base)");
        Qty := WarehouseEntry."Qty. (Base)";

        IF Qty > 0 THEN
            EXIT(TRUE);
    end;


    /*local procedure CheckDDBin2(var P_TempILEInventory: Record 7350 temporary; WhseInternalPickLine: Record "Whse. Internal Pick Line"; P_ZoneFilter: Code[20]; var QtyToApply: Decimal): Boolean
   var
       WarehouseEntry: Record 7312;
       Qty: Decimal;
       PriorityZones: Record 50012;
       CreatePick: Codeunit 7312;
       L_BinContent: Record 7302;
   begin

       IF P_ZoneFilter = '' THEN
           EXIT(TRUE);

       CreatePick.CheckZonePriority(WhseInternalPickLine."Location Code", P_ZoneFilter);//Check if zone priority is added for Pick Zone filter.
       PriorityZones.RESET;
       PriorityZones.SETRANGE("Location Code", WhseInternalPickLine."Location Code");
       PriorityZones.SETRANGE("Zone Code", P_ZoneFilter);
       PriorityZones.SETCURRENTKEY("Priority Sequence");
       PriorityZones.ASCENDING(TRUE);
       IF PriorityZones.FINDSET THEN
           REPEAT
               L_BinContent.RESET;
               L_BinContent.SETRANGE("Item No.", WhseInternalPickLine."Item No.");
               L_BinContent.SETRANGE("Location Code", PriorityZones."Location Code");
               L_BinContent.SETRANGE("Zone Code", PriorityZones."Priority Zone Code");
               L_BinContent.SETRANGE("Lot No. Filter", P_TempILEInventory."Lot No.");
               L_BinContent.SETFILTER(Quantity, '>%1', 0);
               IF L_BinContent.FINDFIRST THEN
                   REPEAT
                       Qty += L_BinContent.CalcQtyAvailToTakeUOM;
                   UNTIL L_BinContent.NEXT = 0;
           UNTIL PriorityZones.NEXT = 0;

       IF Qty > QtyToApply THEN
           QtyToApply := QtyToApply ELSE
           QtyToApply := Qty;

       //QtyToApply:=Qty;
       IF Qty > 0 THEN
           EXIT(TRUE);

   end;*///NG_No_need

    /*local procedure CalculateQtyFromILE(P_ItemNo: Code[20]; P_LocationCode: Code[10]; P_VariantCode: Code[20]; P_ChannelCode: Code[20]; CustomerNo: Code[20])
    var
        RecWarehouseEntry: Record 7312;
        RecLocation: Record 14;
        AllocatedQty: Decimal;
        RemainingQty: Decimal;
        L_ILE: Record 32;
    begin
        IF RecLocation.GET(P_LocationCode) THEN BEGIN
            L_ILE.RESET;
            L_ILE.SETCURRENTKEY("Item No.", Open, "Variant Code", "Location Code", "Item Tracking",
              "Lot No.", "Serial No.");
            L_ILE.ASCENDING(TRUE);
            L_ILE.SETRANGE("Item No.", P_ItemNo);
            L_ILE.SETRANGE("Variant Code", P_VariantCode);
            L_ILE.SETRANGE(Open, TRUE);
            L_ILE.SETRANGE("Location Code", P_LocationCode);
            IF L_ILE.FINDSET THEN
                REPEAT
                    IF NOT LotCheckValidity(L_ILE, CustomerNo) THEN BEGIN
                        RemainingQty := L_ILE."Remaining Quantity";
                        IF RemainingQty > 0 THEN BEGIN
                            IF USERID = 'PS-NAV1\ROBOSOL' THEN
                                MESSAGE('Lot %1, qty %2', L_ILE."Lot No.", L_ILE."Remaining Quantity");
                            TempILEInventory.RESET;
                            TempILEInventory.SETRANGE("Item No.", L_ILE."Item No.");
                            TempILEInventory.SETRANGE("Lot No.", L_ILE."Lot No.");
                            // TempILEInventory.SETRANGE("Variant Code",P_ChannelCode);
                            IF NOT TempILEInventory.FINDSET THEN BEGIN
                                IF USERID = 'PS-NAV1\ROBOSOL' THEN
                                    MESSAGE('Insert');
                                TempILEInventory.INIT;
                                TempILEInventory."Item No." := L_ILE."Item No.";
                                TempILEInventory."Location Code" := L_ILE."Location Code";
                                TempILEInventory."Lot No." := L_ILE."Lot No.";
                                TempILEInventory."Qty. (Base)" := RemainingQty;
                                //TempILEInventory."Variant Code":=P_ChannelCode;
                                TempILEInventory."Source No" := CustomerNo;
                                TempILEInventory.INSERT;
                            END ELSE BEGIN
                                // IF USERID='PS-NAV1\ROBOSOL' THEN
                                // MESSAGE('Modify');
                                TempILEInventory."Qty. (Base)" += RemainingQty;
                                TempILEInventory.MODIFY;
                            END;
                        END;
                    END;
                UNTIL L_ILE.NEXT = 0;
        END;
    end;*///NG_No_Need

    /*procedure LotCheckValidity(Rec: Record 32; CustomerNo: Code[20]): Boolean
    var
        recRuleSet: Record 70002;
        Lot: Text;
        I: Integer;
        RecRuleLine: Record 70001;
        recSO: Record 36;
        J: Integer;
        recRuleHeader: Record 70000;
        Loc: Record 14;
        LotInfo: Record 6505;
        UserSetup: Record 91;
        ItemBudgetName: Record 7132;
        recSO1: Record 36;
    begin
        IF Rec."Item No." = '5741' THEN
            EXIT(FALSE);
        Rec.CALCFIELDS("Stock Status");
        LotInfo.RESET;
        //code to skip customer rule for certain user Start
        UserSetup.GET(USERID);
        IF UserSetup."Allow to Skip Customer Rule" THEN
            EXIT(FALSE);

        IF NOT Rec.Correction THEN BEGIN
            IF NOT LotInfo.GET(Rec."Item No.", Rec."Variant Code", Rec."Lot No.") THEN
                EXIT(TRUE);
            IF LotInfo."Certificate Number" = '' THEN
                EXIT(TRUE);

            IF LotInfo."Sales Blocked" THEN
                EXIT(TRUE);
            Lot := LotInfo."Certificate Number";
        END ELSE BEGIN
            Lot := Rec."Stock Status";
            IF Lot = '' THEN
                EXIT(TRUE);
        END;

        recRuleHeader.RESET;
        recRuleHeader.SETRANGE("Company Type", 1);
        recRuleHeader.SETRANGE("Company No", CustomerNo);//recSO."Sell-to Customer No.");
        recRuleHeader.SETRANGE(Status, recRuleHeader.Status::Released);
        recRuleHeader.SETRANGE("License No", CheckSupplyType(COPYSTR(Lot, 1, STRPOS(Lot, '.') - 1), CustomerNo));
        IF recRuleHeader.FINDLAST THEN BEGIN
            IF LotInfo.Bonded THEN BEGIN
                RecRuleLine.RESET;
                RecRuleLine.SETRANGE("Company Type", recRuleHeader."Company Type");
                RecRuleLine.SETRANGE("License No", recRuleHeader."License No");
                RecRuleLine.SETRANGE("Company No", recRuleHeader."Company No");
                RecRuleLine.SETRANGE(Type, RecRuleLine.Type::Bonded);
                IF NOT RecRuleLine.FINDFIRST THEN
                    EXIT(TRUE)
                ELSE BEGIN
                    IF RecRuleLine."Class Type" = 'N' THEN
                        EXIT(TRUE);
                END;
                // END;
            END;
            //to check Supply type
            RecRuleLine.RESET;
            RecRuleLine.SETRANGE("Company Type", recRuleHeader."Company Type");
            RecRuleLine.SETRANGE("License No", recRuleHeader."License No");
            RecRuleLine.SETRANGE("Company No", recRuleHeader."Company No");
            RecRuleLine.SETRANGE(Type, RecRuleLine.Type::"Supply Type");
            RecRuleLine.SETRANGE("Class Type", COPYSTR(Lot, 1, STRPOS(Lot, '.') - 1));
            IF RecRuleLine.ISEMPTY THEN
                EXIT(TRUE);

            //to check Brand Marking
            Lot := DELSTR(Lot, 1, STRPOS(Lot, '.'));
            RecRuleLine.SETRANGE(Type, RecRuleLine.Type::"Brand Marking");
            RecRuleLine.SETRANGE("Class Type", COPYSTR(Lot, 1, STRPOS(Lot, '.') - 1));
            IF RecRuleLine.ISEMPTY THEN
                EXIT(TRUE);

            //to check Origin
            Lot := DELSTR(Lot, 1, STRPOS(Lot, '.'));
            RecRuleLine.SETRANGE(Type, RecRuleLine.Type::Origin);
            RecRuleLine.SETRANGE("Class Type", COPYSTR(Lot, 1, STRPOS(Lot, '.') - 1));
            IF RecRuleLine.ISEMPTY THEN
                EXIT(TRUE);


            IF STRLEN(Lot) > 1 THEN BEGIN
                //to check Condition
                Lot := DELSTR(Lot, 1, STRPOS(Lot, '.'));
                RecRuleLine.SETRANGE(Type, RecRuleLine.Type::Condition);
                RecRuleLine.SETRANGE("Class Type", COPYSTR(Lot, 1, 2));
                IF RecRuleLine.ISEMPTY THEN
                    EXIT(TRUE);
                ////////////////////////////////////////////////////Code for Brand Restriction
                BrandRestriction.RESET;
                BrandRestriction.SETRANGE("Sales Type", BrandRestriction."Sales Type"::Customer);
                BrandRestriction.SETRANGE("Sales Code", recSO."Sell-to Customer No.");
                BrandRestriction.SETRANGE("Supply Type", BrandRestriction."Supply Type"::All);
                IF NOT BrandRestriction.ISEMPTY THEN BEGIN
                    IF GetBrandRestrction(Rec."Item No.") THEN
                        EXIT(TRUE)
                END ELSE BEGIN
                    BrandRestriction.SETRANGE("Supply Type", BrandRestriction."Supply Type"::Specific);
                    BrandRestriction.SETRANGE("Supply Type Code", recRuleHeader.Type);
                    IF NOT BrandRestriction.ISEMPTY THEN BEGIN
                        IF GetBrandRestrction(Rec."Item No.") THEN
                            EXIT(TRUE)
                    END;
                END;
                ////////////////////////////////////////////////////////////////Code End for Brand Restriction
            END;
        END ELSE
            EXIT(TRUE);
    end;

    procedure CheckStockStatus(var Rec: Record 336; var xRec: Record 336)
    var
        recPL: Record 39;
    begin
        //CAS-06371-C8R2B7
        recPL.RESET;
        recPL.SETRANGE("Document Type", recPL."Document Type"::Order);
        recPL.SETRANGE("Document No.", Rec."Source ID");
        recPL.SETRANGE("Line No.", Rec."Source Ref. No.");
        IF recPL.FINDFIRST THEN;
        IF (Rec."Source Type" = 39) AND (Rec."Source Subtype" = 1) THEN BEGIN
            IF (xRec."Lot No. Status" <> Rec."Lot No. Status") AND (Rec."Lot No. Status" <> recPL."Lot No. Status") THEN BEGIN
                IF NOT CONFIRM('Stock status on purchase order is different then on Goods-in.\\Do you want to continue?', TRUE) THEN BEGIN
                    Rec."Lot No. Status" := '';
                    Rec.MODIFY(TRUE);
                    //MESSAGE('Please select the correct ECMA No.');
                    ERROR('');
                END;
            END;
        END;
    end;

    local procedure CheckSupplyType(P_StockStatus: Code[20]; P_Cust: Code[20]): Code[10]
    var
        L_RecRuleLine: Record 70001;
    begin
        L_RecRuleLine.RESET;
        L_RecRuleLine.SETRANGE("Company Type", L_RecRuleLine."Company Type"::Customer);
        L_RecRuleLine.SETRANGE("Company No", P_Cust);
        L_RecRuleLine.SETRANGE(Type, L_RecRuleLine.Type::"Supply Type");
        L_RecRuleLine.SETRANGE("Class Type", P_StockStatus);
        L_RecRuleLine.SETRANGE(Status, L_RecRuleLine.Status::Released);
        IF L_RecRuleLine.FINDFIRST THEN
            EXIT(L_RecRuleLine."License No");
    end;*///NG_no_Need

    /*local procedure GetBrandRestrction(P_Item: Code[20]): Boolean
    var
        L_Item: Record 27;
    begin
        L_Item.GET(P_Item);
        BrandRestriction.SETRANGE(Restrict, BrandRestriction.Restrict::House);
        BrandRestriction.SETRANGE(Code, L_Item.House);
        IF NOT BrandRestriction.ISEMPTY THEN
            EXIT(TRUE);

        BrandRestriction.SETRANGE(Restrict, BrandRestriction.Restrict::Brand);
        BrandRestriction.SETRANGE(Code, L_Item.Brand);
        IF NOT BrandRestriction.ISEMPTY THEN
            EXIT(TRUE);

        BrandRestriction.SETRANGE(Restrict, BrandRestriction.Restrict::"Item Category");
        BrandRestriction.SETRANGE(Code, L_Item."Item Category Code");
        IF NOT BrandRestriction.ISEMPTY THEN
            EXIT(TRUE);

        BrandRestriction.SETRANGE(Restrict, BrandRestriction.Restrict::Item);
        BrandRestriction.SETRANGE(Code, L_Item."No.");
        IF NOT BrandRestriction.ISEMPTY THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;*///NG_No_Need

    /*local procedure CalculateReservedQty(P_ItemNo: Code[20]; P_LocationCode: Code[10]; P_VariantCode: Code[20]; P_Lot: Text): Decimal
    var
        ReservEntry: Record 337;
    begin
        ReservEntry.RESET;
        ReservEntry.SETCURRENTKEY(
          "Item No.", "Variant Code", "Location Code", "Item Tracking", "Reservation Status", "Lot No.", "Serial No.");
        ReservEntry.SETRANGE("Item No.", P_ItemNo);
        ReservEntry.SETRANGE("Variant Code", P_VariantCode);
        ReservEntry.SETRANGE("Location Code", P_LocationCode);
        ReservEntry.SETRANGE("Lot No.", P_Lot);
        ReservEntry.SETFILTER("Item Tracking", '<>%1', ReservEntry."Item Tracking"::None);
        ReservEntry.CALCSUMS("Quantity (Base)");

        EXIT(ReservEntry."Quantity (Base)");

    end;*///NG_No_Need

    /*  procedure CreateItemTrackingLines_IP(WhIntPickHeader: Record "Whse. Internal Pick Header"; P_ZoneFilter: Code[20])
      var
          L_WhseIntPickL: Record "Whse. Internal Pick Line";
          AppliedQty: Decimal;
          RemQty: Decimal;
          TradePartner: Record 90005;//NG_variable_check
          R50094: Report 50094;
      begin
          L_WhseIntPickL.RESET;
          L_WhseIntPickL.SETRANGE("No.", WhIntPickHeader."No.");
          IF L_WhseIntPickL.FINDSET THEN
              REPEAT

                  AppliedQty := CheckAllocatedQty(L_WhseIntPickL."Item No.", "Whse. Internal Pick Line", 0, L_WhseIntPickL."Line No.", L_WhseIntPickL."Location Code", L_WhseIntPickL."No.");
                  TempGlobalEntrySummary.DELETEALL;
                  TempGlobalReservEntry.DELETEALL;
                  CLEAR(TempGlobalEntrySummary);
                  CLEAR(TempGlobalReservEntry);
                  CLEAR(RemQty);
                  CLEAR(QtyToApply);
                  IF ABS(AppliedQty) <= L_WhseIntPickL."Qty. (Base)" THEN BEGIN//"Qty. Outstanding (Base)"
                      RemQty := L_WhseIntPickL."Qty. (Base)" - ABS(AppliedQty);//"Qty. Outstanding (Base)"
                      IF TradePartner.GET(WhIntPickHeader."Channel Code") THEN;
                      CalculateQtyandBatchFromILE(L_WhseIntPickL."Item No.", L_WhseIntPickL."Location Code", L_WhseIntPickL."Variant Code", L_WhseIntPickL."No.", "Whse. Internal Pick Line", TradePartner."Customer No.");
                      TempItem.SETRANGE("No.");
                      TempItem.SETCURRENTKEY("Unit Price");
                      TempItem.ASCENDING(FALSE);
                      IF TempItem.FINDFIRST THEN
                          REPEAT
                              TempGlobalEntrySummary.SETRANGE("Lot No. Status", TempItem."No.");
                              IF TempGlobalEntrySummary.FINDFIRST THEN
                                  REPEAT
                                      CLEAR(QtyonInternalPick);
                                      IF USERID = 'PS-NAV1\ROBOSOL' THEN BEGIN
                                          //MESSAGE(FORMAT(L_WhseIntPickL."Item No."));
                                          MESSAGE(FORMAT(TempGlobalEntrySummary."Lot No."));
                                      END;
                                      IF USERID = 'PS-NAV1\ROBOSOL' THEN
                                          MESSAGE(FORMAT(TempGlobalEntrySummary."Total Available Quantity") + '--1');
                                      QtyonInternalPick := R50094.QtyReservedonInternalPick(L_WhseIntPickL."Item No.", TempGlobalEntrySummary."Lot No.", L_WhseIntPickL."Location Code", "Whse. Internal Pick Line");
                                      IF USERID = 'PS-NAV1\ROBOSOL' THEN BEGIN
                                          MESSAGE(FORMAT(QtyonInternalPick) + '--2')
                                      END;
                                      TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - R50094.QtyinPutawayBin(L_WhseIntPickL."Location Code", L_WhseIntPickL."Item No.", TempGlobalEntrySummary."Lot No.") - QtyonInternalPick;
                                      IF USERID = 'PS-NAV1\ROBOSOL' THEN
                                          MESSAGE(FORMAT(TempGlobalEntrySummary."Total Available Quantity") + '--3');
                                      TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - CreatePick.CalcQtyOnOutboundBins_AutoAllocation(L_WhseIntPickL."Location Code", L_WhseIntPickL."Item No.",
                                                                                                                                               L_WhseIntPickL."Variant Code", TempGlobalEntrySummary."Lot No.", TempGlobalEntrySummary."Serial No."
                                                                                                                                                 , TRUE, TempGlobalEntrySummary."Total Available Quantity");



                                      IF USERID = 'PS-NAV1\ROBOSOL' THEN
                                          MESSAGE(FORMAT(TempGlobalEntrySummary."Total Available Quantity") + '--4');

                                      IF ((RemQty > 0) AND (TempGlobalEntrySummary."Total Available Quantity" > 0)) THEN BEGIN

                                          CLEAR(QtyToApply);
                                          QtyToApply := TempGlobalEntrySummary."Total Available Quantity";

                                          IF R50094.CheckZone(L_WhseIntPickL."Location Code", L_WhseIntPickL."Item No.", TempGlobalEntrySummary."Lot No.", P_ZoneFilter, QtyToApply) THEN BEGIN
                                              IF QtyToApply > RemQty THEN
                                                  QtyToApply := RemQty ELSE
                                                  QtyToApply := QtyToApply;

                                              IF QtyToApply > 0 THEN BEGIN
                                                  WhseItemTrackingLines.InsertItemTrackingLineCustom(L_WhseIntPickL, '', TempGlobalEntrySummary."Lot No.", 0D, QtyToApply, DATABASE::"Whse. Internal Pick Line");
                                                  TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - QtyToApply;
                                                  TempGlobalEntrySummary.MODIFY;
                                                  RemQty := RemQty - QtyToApply;
                                              END;
                                          END;
                                          IF QtyToApply > 0 THEN
                                              TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - QtyToApply
                                          ELSE
                                              TempGlobalEntrySummary."Total Available Quantity" := TempGlobalEntrySummary."Total Available Quantity" - RemQty;
                                      END;
                                  UNTIL (TempGlobalEntrySummary.NEXT = 0) OR (RemQty <= 0);
                          UNTIL (TempItem.NEXT = 0) OR (RemQty <= 0);
                  END;
              UNTIL L_WhseIntPickL.NEXT = 0;

      end;*/

    /*procedure CreateItemTrackingLines_ReplanishMent(var L_WhseWorksheetLine: Record 7326)
    var
        L_BinContent: Record 7302;
        L_WarehouseEntry: Record 7312;
        QtyToEmptyBase: Decimal;
        ItemTrackingMgt: Codeunit 6500;
        RemQty: Decimal;
        L_LotInfo: Record 6505;
        R50094: Report 50094;
    begin
        Window.OPEN('Processing........');
        IF L_WhseWorksheetLine.FINDSET THEN
            REPEAT
                CLEAR(RemQty);
                RemQty := L_WhseWorksheetLine."Qty. Outstanding (Base)" - CalculateAllocatedqty(L_WhseWorksheetLine);
                L_BinContent.RESET;
                L_BinContent.SETRANGE("Item No.", L_WhseWorksheetLine."Item No.");
                L_BinContent.SETRANGE("Location Code", L_WhseWorksheetLine."Location Code");
                L_BinContent.SETRANGE("Zone Code", L_WhseWorksheetLine."From Zone Code");
                L_BinContent.SETRANGE("Bin Code", L_WhseWorksheetLine."From Bin Code");
                L_BinContent.SETRANGE("Unit of Measure Code", L_WhseWorksheetLine."Unit of Measure Code");
                IF L_BinContent.FINDFIRST THEN BEGIN
                    WITH L_WarehouseEntry DO BEGIN
                        RESET;
                        SETCURRENTKEY(
                          "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.");
                        SETRANGE("Item No.", L_BinContent."Item No.");
                        SETRANGE("Bin Code", L_BinContent."Bin Code");
                        SETRANGE("Location Code", L_BinContent."Location Code");
                        SETRANGE("Variant Code", L_BinContent."Variant Code");
                        SETRANGE("Unit of Measure Code", L_BinContent."Unit of Measure Code");
                        IF FINDSET THEN
                            REPEAT
                                //MESSAGE("Lot No.");
                                CLEAR(QtyToEmptyBase);
                                IF TrackingExists THEN BEGIN
                                    IF "Lot No." <> '' THEN
                                        SETRANGE("Lot No.", "Lot No.");
                                    IF "Serial No." <> '' THEN
                                        SETRANGE("Serial No.", "Serial No.");

                                    QtyToEmptyBase := GetQtyToEmptyBase("Lot No.", "Serial No.", L_BinContent);//- R50094.QtyReservedonInternalPick(L_WarehouseEntry."Item No.",
                                                                                                               //L_WarehouseEntry."Lot No.",L_WarehouseEntry."Location Code",7326);

                                    L_LotInfo.GET(L_WarehouseEntry."Item No.", L_WarehouseEntry."Variant Code", L_WarehouseEntry."Lot No.");
                                    L_LotInfo.SETRANGE("Location Filter", L_WarehouseEntry."Location Code");
                                    L_LotInfo.CALCFIELDS("Reserved Qty. on Inventory");
                                    QtyToEmptyBase := QtyToEmptyBase - L_LotInfo."Reserved Qty. on Inventory";

                                    IF RemQty < QtyToEmptyBase THEN
                                        QtyToEmptyBase := RemQty;

                                    IF QtyToEmptyBase > 0 THEN BEGIN
                                        L_WhseWorksheetLine.SetItemTrackingLines("Serial No.", "Lot No.", "Expiration Date", QtyToEmptyBase);
                                        RemQty := RemQty - QtyToEmptyBase;
                                    END;
                                END;
                                FIND('+');
                                SETRANGE("Lot No.");
                                SETRANGE("Serial No.");
                            UNTIL (NEXT = 0) OR (RemQty <= 0);
                        ;
                    END;
                END;
            UNTIL L_WhseWorksheetLine.NEXT = 0;
        Window.CLOSE;
    end;*///NG_No_Need

    /*local procedure GetQtyToEmptyBase(LotNo: Code[20]; SerialNo: Code[20]; var "P_Bin Content": Record 7302): Decimal
    var
        BinContent: Record 7302;
    begin
        WITH BinContent DO BEGIN
            INIT;
            COPY("P_Bin Content");
            FILTERGROUP(8);
            IF LotNo <> '' THEN
                SETRANGE("Lot No. Filter", LotNo);
            IF SerialNo <> '' THEN
                SETRANGE("Serial No. Filter", SerialNo);
            EXIT(CalcQtyAvailToTake(0));
        END;
    end;*///NG_No_Need

    /*local procedure CalculateAllocatedqty(var P_WhseWorksheetLine: Record 7326) TotalallocatedQty: Decimal
    var
        L_WhseItemTracking: Record 6550;
    begin
        L_WhseItemTracking.RESET;
        L_WhseItemTracking.SETRANGE("Item No.", P_WhseWorksheetLine."Item No.");
        L_WhseItemTracking.SETRANGE("Source ID", P_WhseWorksheetLine.Name);
        L_WhseItemTracking.SETRANGE("Source Batch Name", P_WhseWorksheetLine."Worksheet Template Name");
        L_WhseItemTracking.SETRANGE("Source Type", 7326);
        L_WhseItemTracking.SETRANGE("Source Subtype", 0);
        L_WhseItemTracking.SETRANGE("Source Ref. No.", P_WhseWorksheetLine."Line No.");
        IF L_WhseItemTracking.FINDSET THEN
            REPEAT
                TotalallocatedQty += L_WhseItemTracking."Quantity (Base)";
            UNTIL L_WhseItemTracking.NEXT = 0;
    end;*///NG_No_Need

    var
        TempItem: Record Item;
}