codeunit 90005 "Process Web Order"
{
    TableNo = "Interim Sales Header";
    Permissions = tabledata "Sales Shipment Header" = RIMD, tabledata "Bank Account" = R;

    trigger OnRun()
    begin
        case CalllType of
            CalllType::"Internal Pick":
                begin
                    CreateInternalPick(Rec);
                end;

            CalllType::"Single Order":
                begin
                    CreateSingleOrder(Rec);
                    GenSetupChannels.Get();
                    if GenSetupChannels."Despatch Scan Enabled" = false then
                        MovedToHandled(Rec, true);
                end;

            CalllType::"Consolidate Order":
                begin
                    CreateConsolidateOrder(Rec);
                    GenSetupChannels.Get();
                    if GenSetupChannels."Despatch Scan Enabled" = false then
                        MovedToHandled(Rec, true);
                end;
        end;

    end;

    var
        InvDiscountAmount: Decimal;
        NoSeriesManagement: Codeunit 396;
        HeaderNo: Code[20];
        LineNo: Integer;
        FirstOrder: Boolean;
        WarehouseSetup: Record "Warehouse Setup";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        TempSalesHeader: Record "Sales Header" temporary;
        CustRec: Record Customer;
        ResCen: Record "Responsibility Center";
        CalllType: Option "Internal Pick","Single Order","Consolidate Order";
        GenSetupChannels: Record "General Setup - Channels";
        TempOrderNoPick: Record 27 temporary;
        G_BayNo: Code[20];
        G_TotalQty: Decimal;
        Window: Dialog;
        CurrRec: Integer;
        NoOfRecs: Integer;
        ApplyDiscount: Boolean;
        TempExcelBuffer: Record "Excel Buffer" temporary;

    local procedure CreatePickHeader(var InterimSalesLine: Record "Interim Sales Line"; i: Integer): Code[20]
    var
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        Location: Record Location;
        Bin: Record Bin;
    begin
        WarehouseSetup.GET;
        WhseInternalPickHeader.INIT;
        WhseInternalPickHeader."No." := NoSeriesManagement.GetNextNo(WarehouseSetup."Whse. Internal Pick Nos.", WORKDATE, TRUE);
        InterimSalesLine.CALCFIELDS("Location Code");
        IF Location.GET(InterimSalesLine."Location Code") THEN;
        WhseInternalPickHeader.VALIDATE("Assignment Date", TODAY);
        Bin.RESET;
        Bin.SETRANGE("Location Code", Location.Code);
        //Bin.SETRANGE(Code, Location."Default DD Bin");
        IF Bin.FINDFIRST THEN;

        WhseInternalPickHeader.VALIDATE("Location Code", Location.Code);
        WhseInternalPickHeader.VALIDATE("To Zone Code", Bin."Zone Code");
        WhseInternalPickHeader.VALIDATE("To Bin Code", Bin.Code);
        WhseInternalPickHeader.VALIDATE("Due Date", TODAY);
        WhseInternalPickHeader.INSERT;
        EXIT(WhseInternalPickHeader."No.");

    end;

    local procedure CreatePickLines(HeaderNo: Code[20]; var InterimSalesLine: Record "Interim Sales Line"): Integer
    var
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
        line: Integer;
        Item: Record Item;
        totalWeight: Decimal;
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        RecWhseIPL: Record "Whse. Internal Pick Line";
        LineNo: Integer;
        OchannelSetup: Record "General Setup - Channels";//Sofyan
    begin
        if InterimSalesLine.Type = InterimSalesLine.Type::Item then begin
            CLEAR(line);
            CLEAR(WhseInternalPickLine);
            CLEAR(totalWeight);

            RecWhseIPL.RESET;
            RecWhseIPL.SETRANGE("No.", HeaderNo);
            IF RecWhseIPL.FINDLAST THEN
                LineNo := RecWhseIPL."Line No." + 10000
            ELSE
                LineNo := 10000;

            WhseInternalPickLine.INIT;
            WhseInternalPickLine.VALIDATE("No.", HeaderNo);
            WhseInternalPickLine.VALIDATE("Line No.", LineNo);
            // WhseInternalPickLine.VALIDATE("Line No.",GetLastLineNo(HeaderNo));
            WhseInternalPickLine.VALIDATE("Item No.", InterimSalesLine."No.");
            WhseInternalPickLine.Validate("Variant Code", InterimSalesLine."NAV Variant code");

            Item.RESET;  //Ranjit 04-04-2018
            IF (InterimSalesLine.Type = InterimSalesLine.Type::Item) AND (Item.GET(InterimSalesLine."No.")) THEN BEGIN
                totalWeight := Item."Net Weight" * InterimSalesLine.Quantity;
            END;  //Ranjit 04-04-2018


            ItemUnitofMeasure.RESET;
            ItemUnitofMeasure.SETRANGE("Item No.", InterimSalesLine."No.");
            ItemUnitofMeasure.SETRANGE(Code, InterimSalesLine."Unit of Measure Code");
            IF ItemUnitofMeasure.FINDFIRST THEN
                WhseInternalPickLine.VALIDATE(Quantity, InterimSalesLine.Quantity * ItemUnitofMeasure."Qty. per Unit of Measure")
            ELSE
                WhseInternalPickLine.VALIDATE(Quantity, InterimSalesLine.Quantity);

            WhseInternalPickLine.VALIDATE(Weight, totalWeight);


            WhseInternalPickLine.INSERT(TRUE);

            EXIT(WhseInternalPickLine."Line No.");
        end;
    end;

    local procedure UpdatePickLines(L_SalesLine: Record "Whse. Internal Pick Line"; var L_InterimSalesLine: Record "Interim Sales Line"; var L_InterimSalesHeader: Record "Interim Sales Header")//NG_Variable_Check
    var
        RecSalesLine: Record "Whse. Internal Pick Line";//NG_Variable_Check
        OldQty: Decimal;
        CurrQty: Decimal;
    begin
        //Start_NIKHIL_29/01/2019
        CLEAR(CurrQty);
        RecSalesLine.RESET;
        RecSalesLine.SETRANGE("No.", L_SalesLine."No.");
        RecSalesLine.SETRANGE("Item No.", L_InterimSalesLine."No.");
        RecSalesLine.SetRange("Variant Code", L_InterimSalesLine."NAV Variant code");
        //Chandan++170519
        //Chandan--170519
        IF RecSalesLine.FINDFIRST THEN BEGIN
            CLEAR(OldQty);
            OldQty := RecSalesLine.Quantity;

            ItemUnitofMeasure.RESET;
            ItemUnitofMeasure.SETRANGE("Item No.", L_InterimSalesLine."No.");
            ItemUnitofMeasure.SETRANGE(Code, L_InterimSalesLine."Unit of Measure Code");
            IF ItemUnitofMeasure.FINDFIRST THEN
                CurrQty := L_InterimSalesLine.Quantity * ItemUnitofMeasure."Qty. per Unit of Measure"
            ELSE
                CurrQty := L_InterimSalesLine.Quantity;

            RecSalesLine.VALIDATE(Quantity, OldQty + CurrQty);

            //RecSalesLine.VALIDATE(Quantity,OldQty+L_InterimSalesLine.Quantity);
            RecSalesLine.MODIFY;
            HeaderNo := RecSalesLine."No.";
            LineNo := RecSalesLine."Line No.";
        END;
        //END_NIKHIL_29/01/2019
    end;

    local procedure UpdateOrderNo(var L_InterimSalesLine: Record "Interim Sales Line"; var RecInterimSalesHeader: Record "Interim Sales Header")
    begin
        //Update Interim Line
        L_InterimSalesLine."Destination Doc Type" := L_InterimSalesLine."Destination Doc Type"::"Internal Pick";
        L_InterimSalesLine."Destination Doc No." := HeaderNo;
        L_InterimSalesLine."Destination Doc. Line No" := LineNo;
        L_InterimSalesLine.MODIFY;

        //Update Interim Header
        RecInterimSalesHeader.VALIDATE(Status, RecInterimSalesHeader.Status::Processing);
        RecInterimSalesHeader."Destination Doc Type" := RecInterimSalesHeader."Destination Doc Type"::"Internal Pick";
        RecInterimSalesHeader."Destination Doc No." := HeaderNo;
        RecInterimSalesHeader.MODIFY;

        //Insert Temp Header
        //InsertIntoTempHeader(HeaderNo);

        //Update Shipment Tracking
        //AmazonIntegration.UpdateSalesOrderNoInShippmentTrackingLine(L_InterimSalesLine);//NIKHIL_28/01/19
    end;

    local procedure ItemLineExists(L_InterimSalesLine: Record "Interim Sales Line"; OrderNo: Text): Boolean
    var
        L_SalesLine: Record "Whse. Internal Pick Line";//NG_Variable_Check
    begin
        L_SalesLine.RESET;
        L_SalesLine.SETRANGE("No.", OrderNo);
        L_SalesLine.SETRANGE("Item No.", L_InterimSalesLine."No.");
        L_SalesLine.SetRange("Variant Code", L_InterimSalesLine."NAV Variant code");//ak to manage varient
        IF L_SalesLine.FINDSET THEN
            EXIT(TRUE);
    end;



    local procedure CheckSOExists(var L_InterimSalesLine: Record "Interim Sales Line"; var L_InterimSalesHeader: Record "Interim Sales Header")
    var
        RecInterimSalesLine: Record "Interim Sales Line";
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        WhseValidateSourceLine: Codeunit "Whse. Validate Source Line";
        SalesLine: Record "Sales Line";
        TradePartner: Record "Trade Partner";
        L_Sales_H: Record "Sales Header";
    begin
        IF L_InterimSalesLine.Type = L_InterimSalesLine.Type::Item THEN BEGIN
            SalesLine.RESET;
            SalesLine.CALCFIELDS("Whse. Outstanding Qty.");
            SalesLine.SetRange("Document No.", HeaderNo);
            SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SETRANGE(Type, L_InterimSalesLine.Type);
            SalesLine.SETRANGE("Sell-to Customer No.", L_InterimSalesLine."Sell-to Customer No.");
            IF L_InterimSalesLine."Trade Partner Code" = 'B2B' THEN
                SalesLine.SETRANGE("Shortcut Dimension 1 Code", GetDim(L_InterimSalesLine."Sell-to Customer No."));
            /* ELSE
               BEGIN
                  IF L_Sales_H.GET(L_InterimSalesLine."Document Type",L_InterimSalesHeader."No.") THEN
                   BEGIN
                       SalesLine.SETRANGE("Shortcut Dimension 1 Code",L_Sales_H."Shortcut Dimension 1 Code");
                   END;

               //SalesLine.SETRANGE("Shortcut Dimension 1 Code",SalesHeader."Shortcut Dimension 1 Code");// L_InterimSalesLine."Trade Partner Code");
               END;*/
            SalesLine.SETFILTER("Whse. Outstanding Qty.", '%1', 0);
            SalesLine.SETFILTER("Outstanding Quantity", '<>%1', 0);
            //SalesLine.SETFILTER(Status,'%1',SalesLine.Status::);
            /*IF L_InterimSalesHeader."Deal ID" <> '' THEN
              SalesLine.SETFILTER("Campaign No.",L_InterimSalesHeader."Deal ID");*/
            //SalesLine.SETRANGE("Order Created On",CREATEDATETIME(WORKDATE,000000T),CREATEDATETIME(WORKDATE,235900T));
            IF SalesLine.FINDFIRST THEN BEGIN
                IF WhseValidateSourceLine.WhseLinesExist(
                   DATABASE::"Sales Line", SalesLine."Document Type".AsInteger(), SalesLine."Document No.",
                   SalesLine."Line No.", 0, SalesLine.Quantity) THEN BEGIN
                    HeaderNo := NewCreateSalesHeader(L_InterimSalesLine);
                    LineNo := NewCreateSalesLine(HeaderNo, L_InterimSalesLine);
                    UpdateSONo(L_InterimSalesLine, L_InterimSalesHeader);
                END
                ELSE BEGIN
                    IF ItemLineExists(L_InterimSalesLine, SalesLine."Document No.", L_InterimSalesHeader) THEN
                        UpdateSalesLine(SalesLine, L_InterimSalesLine, L_InterimSalesHeader)
                    ELSE BEGIN
                        HeaderNo := SalesLine."Document No.";
                        LineNo := NewCreateSalesLine(SalesLine."Document No.", L_InterimSalesLine);
                    END;
                    UpdateSONo(L_InterimSalesLine, L_InterimSalesHeader);
                END;
            END
            ELSE BEGIN
                HeaderNo := NewCreateSalesHeader(L_InterimSalesLine);
                LineNo := NewCreateSalesLine(HeaderNo, L_InterimSalesLine);
                UpdateSONo(L_InterimSalesLine, L_InterimSalesHeader);
            END;
        END
        ELSE BEGIN
            IF L_InterimSalesLine.Type = L_InterimSalesLine.Type::"G/L Account" THEN BEGIN
                IF HeaderNo <> '' THEN BEGIN
                    SalesLine.RESET;
                    SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SETRANGE("Document No.", HeaderNo);
                    SalesLine.SETRANGE(Type, SalesLine.Type::"G/L Account");
                    SalesLine.SETRANGE("No.", L_InterimSalesLine."No.");
                    SalesLine.SETRANGE("Unit Price", L_InterimSalesLine."Unit Price");
                    IF SalesLine.FINDFIRST THEN BEGIN
                        UpdateSalesLine(SalesLine, L_InterimSalesLine, L_InterimSalesHeader);
                        UpdateSONo(L_InterimSalesLine, L_InterimSalesHeader);
                    END
                    ELSE BEGIN
                        LineNo := NewCreateSalesLine(HeaderNo, L_InterimSalesLine);
                        UpdateSONo(L_InterimSalesLine, L_InterimSalesHeader);
                    END;
                END;
            END;
        END;
    end;

    local procedure UpdateSalesLine(L_SalesLine: Record "Sales Line"; var L_InterimSalesLine: Record "Interim Sales Line"; var L_InterimSalesHeader: Record "Interim Sales Header")
    var
        RecSalesLine: Record "Sales Line";
        OldQty: Decimal;
    begin
        //Start_NIKHIL_29/01/2019
        RecSalesLine.RESET;
        RecSalesLine.SETRANGE("Document Type", L_SalesLine."Document Type");
        RecSalesLine.SETRANGE("Document No.", L_SalesLine."Document No.");
        RecSalesLine.SETRANGE("No.", L_InterimSalesLine."No.");
        RecSalesLine.SetRange("Variant Code", L_InterimSalesLine."NAV Variant code");
        RecSalesLine.SETRANGE("Unit Price", L_InterimSalesLine."Unit Price");//Chandan++140519
        IF RecSalesLine.FINDFIRST THEN BEGIN
            CLEAR(OldQty);
            OldQty := RecSalesLine.Quantity;
            RecSalesLine.VALIDATE(Quantity, OldQty + L_InterimSalesLine.Quantity);
            RecSalesLine.MODIFY;
            HeaderNo := RecSalesLine."Document No.";
            LineNo := RecSalesLine."Line No.";
        END;
        //END_NIKHIL_29/01/2019
    end;

    local procedure UpdateSONo(var L_InterimSalesLine: Record "Interim Sales Line"; var RecInterimSalesHeader: Record "Interim Sales Header")
    begin
        //Update Interim Line
        L_InterimSalesLine."Destination Doc Type" := L_InterimSalesLine."Destination Doc Type"::"Sales Order";
        L_InterimSalesLine."Destination Doc No." := HeaderNo;
        L_InterimSalesLine."Destination Doc. Line No" := LineNo;
        L_InterimSalesLine.MODIFY;

        //Update Interim Header
        RecInterimSalesHeader.VALIDATE(Status, RecInterimSalesHeader.Status::Processing);
        RecInterimSalesHeader."Destination Doc Type" := RecInterimSalesHeader."Destination Doc Type"::"Sales Order";
        RecInterimSalesHeader."Destination Doc No." := HeaderNo;
        RecInterimSalesHeader.VALIDATE("Destination Doc No.", HeaderNo);
        RecInterimSalesHeader.MODIFY;

        //Insert Temp Header
        InsertIntoTempHeader(HeaderNo);

        //Update Shipment Tracking
        //AmazonIntegration.UpdateSalesOrderNoInShippmentTrackingLine(L_InterimSalesLine);//NIKHIL_28/01/19Commented By pavan No need Amazon
    end;

    local procedure NewCreateSalesHeader(L_InterimSalesLine: Record "Interim Sales Line") SNo: Code[20]
    var
        L_SalesH: Record "Sales Header";
        "S&R": Record "Sales & Receivables Setup";
        Countryregion: Record "Country/Region";
        Campaigns: Record Campaign;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Customer: Record Customer;
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        InterimSalesHeader: Record "Interim Sales Header";
        TradePartner: Record "Trade Partner";
        ssad: Page "Warehouse Shipment";
        WebPayment: Record "Web Payment";
    begin
        "S&R".GET;
        CLEAR(L_SalesH);
        IF InterimSalesHeader.GET(L_InterimSalesLine."Document Type", L_InterimSalesLine."Document No") THEN;
        L_SalesH.INIT;
        L_SalesH.VALIDATE("Document Type", L_SalesH."Document Type"::Order);
        // L_SalesH."No." := NoSeriesManagement.GetNextNo("S&R"."Order Nos.", WORKDATE, TRUE);
        L_SalesH."No." := InterimSalesHeader."No.";//khan++
        L_SalesH.VALIDATE("No.");
        L_SalesH.VALIDATE("Posting Date", WORKDATE);
        L_SalesH.VALIDATE("Order Date", InterimSalesHeader."Document Date");
        L_SalesH.VALIDATE("Document Date", InterimSalesHeader."Document Date");
        L_SalesH.Validate("Web Shipment Method", InterimSalesHeader."Web Shipment Method");
        L_SalesH."Channel Code" := InterimSalesHeader."Trade Partner Code";
        L_SalesH.INSERT(TRUE);

        //L_SalesH.VALIDATE("Order placed At",InterimSalesHeader."Order Placed At"); //commented by shailesh 040719
        L_SalesH.VALIDATE("Sell-to Customer No.", InterimSalesHeader."Sell-to Customer No.");
        L_SalesH.VALIDATE("External Document No.", InterimSalesHeader."Channel Order ID");//Block_Nikhil_30/01/19
        IF InterimSalesHeader."Earliest Delivery date" <> 0D THEN BEGIN
            IF InterimSalesHeader."Earliest Delivery date" < WORKDATE THEN
                L_SalesH.VALIDATE("Shipment Date", WORKDATE)
            ELSE
                L_SalesH.VALIDATE("Promised Delivery Date", InterimSalesHeader."Earliest Delivery date");
        END;
        IF InterimSalesHeader."Earliest Ship Date" <> 0D THEN BEGIN
            IF InterimSalesHeader."Earliest Ship Date" < WORKDATE THEN BEGIN
                L_SalesH.VALIDATE("Shipment Date", WORKDATE);
                //L_SalesH.VALIDATE("Pickup Date",WORKDATE);  //commented by shailesh 040719
            END
            ELSE BEGIN
                L_SalesH.VALIDATE("Shipment Date", InterimSalesHeader."Earliest Ship Date");
                //L_SalesH.VALIDATE("Pickup Date",InterimSalesHeader."Earliest Ship Date");  //commented by shailesh 040719
            END;
        END;


        //Added By Shubham 25052021
        L_SalesH."Ship-to Name" := InterimSalesHeader."Ship-to Name";
        L_SalesH."Ship-to Address" := InterimSalesHeader."Ship-to Address";
        L_SalesH."Ship-to Address 2" := InterimSalesHeader."Ship-to Address 2";
        L_SalesH."Ship-to City" := InterimSalesHeader."Ship-to City";
        L_SalesH."Ship-to Post Code" := InterimSalesHeader."Ship-to Post Code";
        L_SalesH."Ship-to County" := InterimSalesHeader."Ship-to County";
        L_SalesH."Ship-to Country/Region Code" := InterimSalesHeader."Ship-to Country";
        //Added By Shubham 25052021



        IF Customer.GET(InterimSalesHeader."Sell-to Customer No.") THEN;
        L_SalesH.VALIDATE("Payment Method Code", GetPaymentMethodCode(InterimSalesHeader."Trade Partner Code", InterimSalesHeader."Channel Order ID", L_SalesH."No."));


        IF InterimSalesHeader."Deal ID" <> '' THEN BEGIN
            Campaigns.RESET;
            Campaigns.SETRANGE("No.", InterimSalesHeader."Deal ID");
            IF Campaigns.FINDFIRST THEN
                L_SalesH.VALIDATE("Campaign No.", InterimSalesHeader."Deal ID")
            ELSE
                InsertErrorlog('Deal Id not found.', InterimSalesHeader);
        END;
        //L_SalesH."Shipment Day"  := FORMAT(L_SalesH."Shipment Date",0,'<Weekday Text>'); //commented by shailesh 040719
        IF InterimSalesHeader."Trade Partner Code" = 'B2B' THEN
            L_SalesH.VALIDATE("Shortcut Dimension 1 Code", GetDim(InterimSalesHeader."Sell-to Customer No."));


        L_SalesH.VALIDATE("Ship-to Country/Region Code", InterimSalesHeader."Ship-to Country/Region Code");
        L_SalesH."Shipping Agent Code" := InterimSalesHeader."Shipping Agent Code";
        L_SalesH."Shipping Agent Service Code" := InterimSalesHeader."Shipping Agent Service Code";
        L_SalesH."Shipment Method Code" := interimSalesHeader."Shipment Method Code";
        WebPayment.Reset();
        WebPayment.SetRange("Channel Code", InterimSalesHeader."Trade Partner Code");
        WebPayment.SetRange("Web Payment Method", InterimSalesHeader."Payment Method");
        WebPayment.SetRange("Currency Code", InterimSalesHeader."Currency Code");
        if WebPayment.FindFirst() then
            L_SalesH.Validate("Payment Method Code", WebPayment."NAV Payment Method 2");
        // L_SalesH."Payment Method Code" := WebPayment."NAV Payment Method 2";
        //L_SalesH.INSERT(TRUE); //Ranjit 12082019 commented
        L_SalesH.Validate("Currency Code", InterimSalesHeader."Currency Code");
        L_SalesH.Validate("Customer Posting Group", InterimSalesHeader."Customer Posting Group");

        if InterimSalesHeader."Customer Posting Group" = 'FOREIGN' then begin// Unique to ILW 
            L_SalesH.Validate("VAT Bus. Posting Group", 'EXPORT');
            L_SalesH.Validate("Gen. Bus. Posting Group", 'EXPORT');
        end
        else begin
            L_SalesH.Validate("VAT Bus. Posting Group", InterimSalesHeader."Customer Posting Group");
            L_SalesH.Validate("Gen. Bus. Posting Group", InterimSalesHeader."Customer Posting Group");

        end;
        L_SalesH."Order Date" := InterimSalesHeader."Document Date";
        L_SalesH."Document Date" := InterimSalesHeader."Document Date";
        L_SalesH."Posting Date" := InterimSalesHeader."Document Date";
        L_SalesH."VAT Reporting Date" := InterimSalesHeader."Document Date";
        L_SalesH.MODIFY;
        EXIT(L_SalesH."No.");

    end;

    local procedure NewCreateSalesLine(HeaderNo: Code[20]; L_IntrimSalesLine: Record "Interim Sales Line"): Integer
    var
        L_SalesL: Record "Sales Line";
        totalWeight: Decimal;
        line: Integer;
        ISL: Record "Interim Sales Line";
        Qty: Decimal;
        Amt: Decimal;
        item: Record Item;
        desc: Text;
        desc2: Text;
        ItemLineNo: Integer;
        L_SalesH: Record "Sales Header";
        InterimSalesHeader: Record "Interim Sales Header";
        DiscountExVat: Decimal;
        L_GeneralSetup: Record "General Setup - Channels";
        LineCount: Integer;
    begin
        CLEAR(line);
        CLEAR(totalWeight);
        CLEAR(Qty);
        CLEAR(Amt);
        CLEAR(ItemLineNo);
        Qty := L_IntrimSalesLine.Quantity;
        Amt := L_IntrimSalesLine.Amount;

        CLEAR(L_SalesL);
        L_SalesL.INIT;
        L_SalesL.VALIDATE("Document Type", L_SalesL."Document Type"::Order);
        L_SalesL.VALIDATE("Document No.", HeaderNo);
        L_SalesL.VALIDATE("Line No.", GetLastLineNo(HeaderNo));
        L_SalesL.VALIDATE(Type, L_IntrimSalesLine.Type);
        L_SalesL.VALIDATE("No.", L_IntrimSalesLine."No.");
        L_SalesL.VALIDATE("Unit of Measure Code", L_IntrimSalesLine."Unit of Measure Code");
        L_SalesL.Validate("Variant Code", L_IntrimSalesLine."NAV Variant code");
        item.RESET;
        IF (L_IntrimSalesLine.Type = L_IntrimSalesLine.Type::Item) AND (item.GET(L_IntrimSalesLine."No.")) THEN BEGIN
            totalWeight := item."Net Weight" * Qty;
        END;

        L_SalesL.Validate("Currency Code", L_IntrimSalesLine."Currency Code");

        IF L_SalesL.Type <> L_SalesL.Type::" " THEN BEGIN
            ItemLineNo := L_SalesL."Line No.";
            L_SalesL.VALIDATE(Quantity, Qty);
            L_SalesL.VALIDATE("Unit Price", L_IntrimSalesLine."Unit Price");
            //L_SalesL.VALIDATE("Shortcut Dimension 1 Code",L_IntrimSalesLine."Trade Partner Code"); //Commented by Ranjit 16082019


            // L_SalesL.VALIDATE(Amount,Amt);
            //  L_SalesL.VALIDATE("Amount Including VAT",L_IntrimSalesLine."Amount Including VAT");
        END;

        IF ((L_IntrimSalesLine.Discount > 0) and (L_IntrimSalesLine.Quantity > 0) and (L_IntrimSalesLine."Unit Price" > 0)) THEN begin
            L_SalesL.Validate("Line Discount %", Round(
               L_IntrimSalesLine.Discount / Round((L_IntrimSalesLine.Quantity * L_IntrimSalesLine."Unit Price") + L_IntrimSalesLine."VAT amount", 0.01) * 100,
               0.01));
        end;
        //L_SalesL.VALIDATE("Line Discount Amount", L_IntrimSalesLine.Discount);//khan++

        L_SalesL.Validate("Channel Order ID", L_IntrimSalesLine."Channel Order ID");
        L_SalesL.Validate("Channel Code", L_IntrimSalesLine."Trade Partner Code");
        if L_IntrimSalesLine.Weight > 0 then
            L_SalesL.Validate("Net Weight", L_IntrimSalesLine.Weight);
        L_SalesL.Validate("VAT Bus. Posting Group", L_IntrimSalesLine."VAT Bus. Posting Group");

        L_SalesL.Validate("VAT Prod. Posting Group", L_IntrimSalesLine."VAT Prod. Posting Group");
        L_SalesL.INSERT(TRUE);


        IF L_SalesH.GET(L_SalesL."Document Type", L_SalesL."Document No.") THEN BEGIN
            L_SalesL.VALIDATE("Location Code", L_SalesH."Location Code");
            L_SalesL.VALIDATE("Shortcut Dimension 1 Code", L_SalesH."Shortcut Dimension 1 Code"); //Ranjit 16082019
            L_SalesL.MODIFY(TRUE);
        END;

        //Bug 12386
        Clear(LineCount);
        ISL.reset();
        ISL.SetFilter(Type, '%1', ISL.Type::Item);
        ISL.SetFilter("Document No", L_IntrimSalesLine."Document No");
        if ISL.FindSet() then begin
            isl.CalcSums(Discount);
            LineCount := ISL.Count;
        end;

        if ApplyDiscount then begin // Check if line requires discount of order using global boolean, get discount on lines and reduce total discount then remianing add to line as invoice discount
            InterimSalesHeader.reset();
            if InterimSalesHeader.get(L_IntrimSalesLine."Document Type", L_IntrimSalesLine."Document No") then begin
                //if (L_SalesL.Amount - isl.Discount) >= (InterimSalesHeader."Order Discount Amount" - isl.Discount) then begin
                if (InterimSalesHeader."Order Discount Amount" - isl.Discount) > 0 then begin
                    DiscountExVat := (InterimSalesHeader."Order Discount Amount" - isl.Discount) / ((L_SalesL."VAT %" / 100) + 1);
                    if (DiscountExVat > 0) and (LineCount > 0) then
                        InvDiscountAmount := DiscountExVat / LineCount;
                    if L_SalesL.Type = L_SalesL.Type::Item then begin
                        if L_SalesL."Unit Price" > InvDiscountAmount then begin
                            L_SalesL."Inv. Discount Amount" := Round(InvDiscountAmount, 0.01, '>');
                        end
                        else begin
                            L_SalesL.Validate("Inv. Discount Amount", 0);
                            ApplyDiscount := false;
                        end;
                    end;
                end;
            end;
            L_SalesL.MODIFY(TRUE);
        end
        else begin
            L_SalesL.Validate("Inv. Discount Amount", 0);
            L_SalesL.Modify(true);
            InterimSalesHeader.reset();
            if InterimSalesHeader.get(L_IntrimSalesLine."Document Type", L_IntrimSalesLine."Document No") then begin
                if (InterimSalesHeader."Order Discount Amount" - isl.Discount) > 0 then begin
                    DiscountExVat := (InterimSalesHeader."Order Discount Amount" - isl.Discount) / ((L_SalesL."VAT %" / 100) + 1);
                    if L_SalesL.Type = L_SalesL.Type::"G/L Account" then begin
                        L_SalesL."Inv. Discount Amount" := Round(DiscountExVat, 0.01, '>');
                    end;
                end;
            end;
            L_SalesL.MODIFY(TRUE);
        end;
        //Bug 12386


        EXIT(L_SalesL."Line No.");

    end;

    local procedure InsertIntoTempHeader(DocNo: Code[20])
    begin
        TempSalesHeader.RESET;
        TempSalesHeader.SETRANGE("Document Type", TempSalesHeader."Document Type"::Order);
        TempSalesHeader.SETRANGE("No.", DocNo);
        IF NOT TempSalesHeader.FINDFIRST THEN BEGIN
            TempSalesHeader.INIT;
            TempSalesHeader."Document Type" := TempSalesHeader."Document Type"::Order;
            TempSalesHeader."No." := DocNo;
            TempSalesHeader.INSERT;
        END;
    end;

    local procedure ItemLineExists(L_InterimSalesLine: Record "Interim Sales Line"; OrderNo: Text; L_InterimSalesHeader: Record "Interim Sales Header"): Boolean
    var
        L_SalesLine: Record "Sales Line";
    begin
        L_SalesLine.RESET;
        L_SalesLine.SETRANGE("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SETRANGE("Document No.", OrderNo);
        L_SalesLine.SETRANGE(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", L_InterimSalesLine."No.");
        L_SalesLine.SetRange("Variant Code", L_InterimSalesLine."NAV Variant code");
        L_SalesLine.SETRANGE("Unit Price", L_InterimSalesLine."Unit Price");//Chandan++120519
        /*IF L_InterimSalesHeader."Deal ID" <> '' THEN
              SalesLine.SETFILTER("Campaign No.",L_InterimSalesHeader."Deal ID");*/

        IF L_SalesLine.FINDSET THEN
            EXIT(TRUE);

    end;

    local procedure GetPaymentMethodCode(ChannelCode: Code[20]; ChannelOrderId: Code[50]; SalesOrderID: Code[20]): Code[20]
    var
        ChannelMedia: Record "Channel Media";
    begin

    end;

    procedure InsertErrorlog(P_Text: Text[250]; var InterimSalesHeader: Record "Interim Sales Header")
    var
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_LineNo: Integer;
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
    begin
        L_PartnerErrorLog.RESET;
        IF L_PartnerErrorLog.FINDLAST THEN
            L_LineNo := L_PartnerErrorLog."Line No." + 10000
        ELSE
            L_LineNo := 10000;

        PartnerErrorLog.INIT;
        PartnerErrorLog."Document No." := InterimSalesHeader."No.";
        PartnerErrorLog.Date := WORKDATE;
        PartnerErrorLog."Line No." := L_LineNo;

        PartnerErrorLog."Error Text" := P_Text;
        PartnerErrorLog.INSERT;
        InterimSalesHeader.MODIFY;
    end;

    local procedure GetLastLineNo(HeaderNo: Code[20]): Integer
    var
        L_SalesLine: Record "Sales Line";
    begin
        L_SalesLine.RESET;
        L_SalesLine.SETRANGE("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SETRANGE("Document No.", HeaderNo);
        IF L_SalesLine.FINDLAST THEN
            EXIT(L_SalesLine."Line No." + 10000)
        ELSE
            EXIT(10000);
    end;

    local procedure GetDim(P_Cust: Code[20]): Code[20]
    var
        DefaultDim: Record "Default Dimension";
    begin
        IF CustRec.GET(P_Cust) THEN BEGIN
            IF ResCen.GET(CustRec."Responsibility Center") THEN BEGIN
                DefaultDim.RESET;
                DefaultDim.SETRANGE("Dimension Code", 'SALES CHANNEL');
                DefaultDim.SETRANGE("No.", ResCen.Code);
                DefaultDim.SETRANGE("Table ID", 5714);
                IF DefaultDim.FINDFIRST THEN
                    EXIT(DefaultDim."Dimension Value Code");
            END;
        END;
    end;

    local procedure CreateSingleOrder(var Rec: Record "Interim Sales Header")
    var
        ChanCode: Code[20];
        ItemNo: Code[20];
        CustomerNo: Code[20];
        ISL: Record "Interim Sales Line";
        InterimSalesHeader: Record "Interim Sales Header";
        InterimSalesHeader1: Record "Interim Sales Header";
        Customer: Record "Customer";
        ShipmentTracking: Record "Shipment Tracking";
        GeneralSetup: Record "General Setup - Channels";
        L_SalesLine: Record "Sales Line";
    begin
        GeneralSetup.Get();
        CLEAR(HeaderNo);
        ISL.RESET;
        ISL.SETRANGE("Document Type", Rec."Document Type"::Order);
        ISL.SETRANGE("Document No", Rec."No.");
        ApplyDiscount := true;
        IF ISL.FINDSET THEN BEGIN
            HeaderNo := NewCreateSalesHeader(ISL);
            Clear(InvDiscountAmount);
            REPEAT
                CLEAR(LineNo);
                LineNo := NewCreateSalesLine(HeaderNo, ISL);
                UpdateSONo(ISL, Rec);

            UNTIL ISL.NEXT = 0;

            //Bug 12386
            if ApplyDiscount = false then begin
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document No.", HeaderNo);
                L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                if L_SalesLine.FindSet() then begin
                    repeat
                        if L_SalesLine.Type = L_SalesLine.Type::Item then begin
                            L_SalesLine.Validate("Inv. Discount Amount", 0);
                            L_SalesLine.Modify();
                        end;
                    until L_SalesLine.Next() = 0;
                end;
            end;
            //Bug 12386

            if GeneralSetup."Auto Release Sales Orders" = true then
                UpdateStatusOnSalesOrder(HeaderNo);//Sofyan
            //Message('Web Order Processed Successfully'); //Sofyan//NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
            FirstOrder := FALSE;
        END;
    end;

    local procedure CreateConsolidateOrder(var Rec: Record "Interim Sales Header")
    var
        ChanCode: Code[20];
        ItemNo: Code[20];
        CustomerNo: Code[20];
        ISL: Record "Interim Sales Line";
        InterimSalesHeader: Record "Interim Sales Header";
        InterimSalesHeader1: Record "Interim Sales Header";
        Customer: Record "Customer";
        ShipmentTracking: Record "Shipment Tracking";
    begin
        IF FirstOrder = FALSE THEN BEGIN
            //CLEAR(HeaderNo);
            ISL.RESET;
            ISL.SETRANGE("Document Type", Rec."Document Type"::Order);
            ISL.SETRANGE("Document No", Rec."No.");
            IF ISL.FINDSET THEN
                REPEAT
                    CLEAR(LineNo);
                    CheckSOExists(ISL, Rec);
                UNTIL ISL.NEXT = 0;
        END
        ELSE BEGIN
            CLEAR(HeaderNo);
            ISL.RESET;
            ISL.SETRANGE("Document Type", Rec."Document Type"::Order);
            ISL.SETRANGE("Document No", Rec."No.");
            IF ISL.FINDSET THEN BEGIN
                HeaderNo := NewCreateSalesHeader(ISL);
                REPEAT
                    CLEAR(LineNo);
                    LineNo := NewCreateSalesLine(HeaderNo, ISL);
                    UpdateSONo(ISL, Rec);
                UNTIL ISL.NEXT = 0;
                //Message('Web Order Processed Successfully'); //Sofyan //NIKHIL_30/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
                FirstOrder := FALSE;
            END;
        END;
    end;

    local procedure CreateInternalPick(var Rec: Record "Interim Sales Header")
    var
        IsHandled: Boolean;

    begin
        OnBeforeCreateInternalPick(Rec, IsHandled);
        if IsHandled then
            exit;


        OnAfterCreateInternalPick(Rec);
    end;

    local procedure MovedToHandled(P_Rec: Record "Interim Sales Header"; skipfilter: boolean)
    var
        R80020: Report "Move Scanned Order to Handled";
        ISH: Record "Interim Sales Header";
    begin
        ISH.Reset;
        ISH.SetRange("Document Type", P_Rec."Document Type");
        ISH.SetRange("No.", P_Rec."No.");
        If ISH.FindFirst() then begin
            CLEAR(R80020);
            R80020.SETTABLEVIEW(ISH);
            R80020.USEREQUESTPAGE(FALSE);
            R80020.SetWebOrder(ISH, ISH."Trade Partner Code");
            //R80020.Setskipfilter(skipfilter);
            R80020.RunModal();
        end;
    end;

    procedure SetParamters(FirstOrderFlag: Boolean; VarCalllType: Option "Internal Pick","Single Order","Consolidate Order")
    begin
        FirstOrder := FirstOrderFlag;
        CalllType := VarCalllType;

    end;

    procedure UnAllocateWebOrderOnDeleteNew(var RecInterimSalesLine: Record "Interim Sales Line"; NeedWIPValidation: Boolean)
    var
        RecSalesLine: Record 37;
        ReleaseSalesDocument: Codeunit 414;
        RecSalesHeader: Record 36;
        L_SalesLine: Record 37;
        RecInterimSalesHeader: Record "Interim Sales Header";
        WSHList: Page 7339;
        filterText: Text;
        L_WIPL: Record 7334;
        RecInterimSalesL: Record "Interim Sales Line";
    begin
        IF RecInterimSalesLine.FINDSET THEN
            REPEAT
                IF NeedWIPValidation THEN BEGIN
                    L_WIPL.RESET;
                    L_WIPL.SETRANGE("No.", RecInterimSalesLine."Destination Doc No.");
                    L_WIPL.SETRANGE("Item No.", RecInterimSalesLine."No.");
                    IF L_WIPL.FINDFIRST THEN
                        ERROR(STRSUBSTNO('You can not remove internal pick %1 from web order %2 because internal pick is exist in system.', L_WIPL."No.", RecInterimSalesLine."Document No"));

                    IF RecInterimSalesLine."Trolley No." <> '' THEN
                        CheckTrolleyIsClosed(RecInterimSalesLine);
                END;
                CLEAR(RecInterimSalesLine."Destination Doc. Line No");
                CLEAR(RecInterimSalesLine."Destination Doc No.");
                CLEAR(RecInterimSalesLine."Destination Doc Type");
                CLEAR(RecInterimSalesLine."Trolley No.");
                RecInterimSalesLine."Destination Doc Type" := RecInterimSalesLine."Destination Doc Type"::" ";
                RecInterimSalesLine."Destination Doc No." := '';
                RecInterimSalesLine.Reserved := FALSE;
                RecInterimSalesLine.MODIFY;
                if RecInterimSalesHeader.Get(RecInterimSalesLine."Document Type", RecInterimSalesLine."Document No") then
                    RecInterimSalesHeader.Mark(true);
            UNTIL RecInterimSalesLine.NEXT = 0;



        RecInterimSalesHeader.MarkedOnly(true);
        IF RecInterimSalesHeader.FINDSET THEN
            REPEAT
                IF NOT CheckIfLineExistsWithDocNo(RecInterimSalesHeader) THEN BEGIN
                    CLEAR(RecInterimSalesHeader."Destination Doc No.");
                    CLEAR(RecInterimSalesHeader."Destination Doc Type");
                    IF NOT (RecInterimSalesHeader.Status IN [RecInterimSalesHeader.Status::"No Stock", RecInterimSalesHeader.Status::Cancelled]) THEN
                        RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::"In Progress";
                    RecInterimSalesLine."Destination Doc Type" := RecInterimSalesLine."Destination Doc Type"::" ";
                    RecInterimSalesLine."Destination Doc No." := '';
                    RecInterimSalesHeader.ReservedFlag := FALSE;
                    RecInterimSalesHeader."Order Ack. Exported" := false;
                    RecInterimSalesHeader.MODIFY;
                END;
            UNTIL RecInterimSalesHeader.NEXT = 0;
    end;

    local procedure CheckIfLineExistsWithDocNo(P_InterimSalesHeader: Record "Interim Sales Header"): Boolean
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
        L_InterimSalesLine.SETFILTER("Destination Doc No.", '%1', P_InterimSalesHeader."Destination Doc No.");
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);//ak 081220
        L_InterimSalesLine.SETRANGE("Scanned Date", 0DT);//'ak 081220
        IF L_InterimSalesLine.FINDSET THEN
            EXIT(TRUE);
    end;

    local procedure CheckTrolleyIsClosed(P_InterimSalesLine: Record "Interim Sales Line")
    var
        RegisteredWhseActivityHdr: Record 5772;
        RegisteredWhseActivityLine: Record 5773;
    begin
        RegisteredWhseActivityLine.RESET;
        RegisteredWhseActivityLine.SETRANGE("Activity Type", RegisteredWhseActivityLine."Activity Type"::Pick);
        RegisteredWhseActivityLine.SETRANGE("Source Type", 7334);
        RegisteredWhseActivityLine.SETRANGE("Source No.", P_InterimSalesLine."Destination Doc No.");
        RegisteredWhseActivityLine.SETRANGE("Item No.", P_InterimSalesLine."No.");
        RegisteredWhseActivityLine.SETRANGE("Trolley No.", P_InterimSalesLine."Trolley No.");
        IF RegisteredWhseActivityLine.FINDFIRST THEN BEGIN
            RegisteredWhseActivityHdr.RESET;
            RegisteredWhseActivityHdr.SETRANGE(Type, RegisteredWhseActivityHdr.Type::Pick);
            RegisteredWhseActivityHdr.SETRANGE("No.", RegisteredWhseActivityLine."No.");
            IF RegisteredWhseActivityHdr.FINDFIRST THEN
                IF NOT RegisteredWhseActivityHdr."Trolley Closed" THEN
                    ERROR(STRSUBSTNO('You can not remove internal pick %1 from web order %2 because open trolley exists in system for Registered Pick %3.', P_InterimSalesLine."Destination Doc No.", P_InterimSalesLine."Document No", RegisteredWhseActivityHdr."No."))


        END;
    end;

    procedure ShowWebOrderLines(WhseInternalPickHeader: Record "Whse. Internal Pick Header"; WhseInternalPickLine: Record "Whse. Internal Pick Line"; CalledFromLine: Boolean)
    var
        InterimSalesLine: record "Interim Sales Line";
    begin
        InterimSalesLine.RESET;
        InterimSalesLine.SETRANGE("Destination Doc Type", InterimSalesLine."Destination Doc Type"::"Internal Pick");
        InterimSalesLine.SETRANGE("Destination Doc No.", WhseInternalPickHeader."No.");
        IF CalledFromLine THEN
            InterimSalesLine.SETRANGE(InterimSalesLine."Destination Doc. Line No", WhseInternalPickLine."Line No.");
        IF InterimSalesLine.FINDSET THEN BEGIN
            PAGE.RUN(90018, InterimSalesLine);
        END;
    end;



    procedure TrolleyNoValidations(P_TrolleyNo: Text; InternalPickNo: Code[20])
    var
        L_ISL: Record "Interim Sales Line";
    begin
        //Chandan++190720
        L_ISL.RESET;
        L_ISL.SETRANGE("Destination Doc Type", L_ISL."Destination Doc Type"::"Sales Order");
        L_ISL.SETRANGE("Destination Doc No.", InternalPickNo);
        L_ISL.SETRANGE("Dispatch Scan", FALSE);
        L_ISL.SETRANGE("Scanned Date", 0DT);
        L_ISL.SETFILTER(Status, '<>%1', L_ISL.Status::Cancelled);
        L_ISL.SETFILTER("Trolley No.", '<>%1', '');
        IF L_ISL.FINDSET THEN
            ERROR('You can not create Pick.\There is an open Trolley %1 assoiciated with this Whse. Internal Pick %2 ', L_ISL."Trolley No.", L_ISL."Destination Doc No.");
        //Chandan--190720

        L_ISL.RESET;
        L_ISL.SETRANGE("Trolley No.", P_TrolleyNo);
        L_ISL.SETRANGE("Dispatch Scan", FALSE);
        L_ISL.SETRANGE("Scanned Date", 0DT);
        L_ISL.CALCFIELDS(Status);
        L_ISL.SETFILTER(Status, '<>%1', L_ISL.Status::Cancelled);
        IF L_ISL.FINDSET THEN
            ERROR('This Trolley no is assoiciated with open web order from Whse. Internal Pick %1 ', L_ISL."Destination Doc No.");

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnAfterCreateWhseDocLine', '', true, true)]
    local procedure OnAfterCreateWhseDocLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        WAL: Record "Warehouse Activity Line";
        WIPH: Record "Whse. Internal Pick Header";
        WAH: Record "Warehouse Activity Header";
        ISH: Record "Interim Sales Header";
        ISL: Record "Interim Sales Line";
        L_InitValue: Code[20];
        WIPL: Record "Whse. Internal Pick Line";
        OrderNo: Code[20];
        OrderCount: Integer;
        L_Integer: Record Integer;
        WAL2: Record "Warehouse Activity Line";
        WIPL2: Record "Whse. Internal Pick Line";
        WSL: Record "Warehouse Shipment Line";

        WarShipmentHeader: Record "Warehouse Shipment Header";
    begin


        WAL.Reset();
        WAL.SetRange("Activity Type", WarehouseActivityLine."Activity Type");
        WAL.SetRange("No.", WarehouseActivityLine."No.");
        if WAL.FindSet() then begin
            CASE WAL."Whse. Document Type" OF
                WAL."Whse. Document Type"::Shipment:
                    begin
                        repeat
                            WSL.Reset();
                            WSL.SetRange("No.", WAL."Whse. Document No.");
                            WSL.SetRange("Line No.", WAL."Whse. Document Line No.");
                            if WSL.FindFirst() then begin
                                // WSL.CalcFields("Trolley No."); //khan++
                                WAL.Validate("Trolley No.", WSL."Trolley No.");
                                WAL.Validate("Bay No.", WSL."Bay No.");  // Ik++
                                WAL.Validate("Channel Order ID", WSL."Channel Order ID");
                                WAL.Validate("Channel Code", WSL."Channel Code");
                                WAL.Modify();
                            end;
                        until WAL.Next() = 0;

                        WarShipmentHeader.Reset();
                        WarShipmentHeader.SetRange("No.", WarehouseActivityLine."Whse. Document No.");
                        if WarShipmentHeader.FindFirst() then;
                        WAH.Reset();
                        WAH.SetRange("No.", WAL."No.");
                        WAH.SetRange(Type, WAH.Type::Pick);
                        if WAH.FindFirst() then begin
                            WAH.Validate("Trolley No.", WSL."Trolley No.");
                            //WAH.Validate(Comments, WarShipmentHeader.Comments);
                            WAH.Validate("Shipping Agent Code", WarShipmentHeader."Shipping Agent Code");
                            WAH.Validate("Shipping Agent Service Code", WarShipmentHeader."Shipping Agent Service Code");
                            WAH.Modify();
                        end;
                    end;

            END;

            ISH.Reset();
            ISH.SetRange("Document Type", ISH."Document Type"::Order);
            ISH.SetRange("Destination Doc Type", ISH."Destination Doc Type"::"Sales Order");
            ISH.SetRange("Destination Doc No.", WAL."Source No.");
            if ISH.FindSet() then begin
                repeat
                    ISH.Validate("Trolley No.", WAL."Trolley No.");
                    ISH.Modify();
                    ISL.Reset();
                    ISL.SetRange("Document Type", ISH."Document Type");
                    ISL.SetRange("Document No", ISH."No.");
                    if ISL.FindSet() then begin
                        repeat
                            ISL.Validate("Trolley No.", ISH."Trolley No.");
                            ISL.Modify();
                        until ISL.Next() = 0;
                    end;
                until ISH.Next() = 0;
            end;
        end;
    end;



    //ReturnOrder++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Put-away", 'OnAfterWhseActivLineInsert', '', false, false)]
    local procedure OnAfterWhseActivLineInsert(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        L_WAL: Record "Warehouse Activity Line";
        SL: Record "Sales Line";
    begin
        if WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::"Put-away" then
            //if WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Place then begin
                SL.Reset();
        SL.SetRange("Document Type", SL."Document Type"::"Return Order");
        SL.SetRange("Document No.", WarehouseActivityLine."Source No.");
        SL.SetRange("Line No.", WarehouseActivityLine."Source Line No.");
        if SL.FindFirst() then begin
            SetBins(SL."Item Reference Type No.", WarehouseActivityLine, sl."Shipping Agent Service Code", WarehouseActivityLine."Action Type");
        end;
        //end   


    end;
    //ReturnOrder--
    local procedure SetBins(P_ReasonCode: Code[20]; P_WAL: Record "Warehouse Activity Line"; P_bayno: Code[20]; activitytype: Enum "Warehouse Action Type")
    var
        L_Zone: Record Zone;
        L_Bin: Record Bin;
        L_ReasonCode: Record "Reason Code";
    begin
        if activitytype = activitytype::Place then begin
            L_ReasonCode.Reset();
            L_ReasonCode.SetRange(Code, P_ReasonCode);
            if L_ReasonCode.FindFirst() then begin
                L_Zone.Reset();
                L_Zone.SetRange("Location Code", P_WAL."Location Code");
                L_Zone.SetRange(Code, L_ReasonCode."Zone Code");
                if L_Zone.FindFirst() then begin
                    P_WAL.Validate("Zone Code", L_Zone.Code);
                    L_Bin.Reset();
                    L_Bin.SetRange("Location Code", P_WAL."Location Code");
                    L_Bin.SetRange("Zone Code", L_Zone.Code);
                    if L_Bin.FindFirst() then begin
                        P_WAL.Validate("Bin Code", L_Bin.Code);
                        P_WAL.Modify();
                    end;
                end;
            end;
            P_WAL."Bay No." := P_bayno;
            P_WAL.Modify();
        end else begin
            P_WAL."Bay No." := P_bayno;
            P_WAL.Modify();
        end;

    end;


    procedure SetTotalQty(P_Qty: Decimal)
    begin
        Clear(G_TotalQty);
        G_TotalQty := P_Qty;
    end;




    //AllocateWebOrder++
    procedure AllocateWebOrderWithAvailableQty2(VAR CS_ISH: Record "Interim Sales Header"; MaxOrder: Integer)
    var
        CS_InterimSalesLine: Record "Interim Sales Line";
        filterText: Text;
        CS_ISH2: Record "Interim Sales Header";
        LineModified: Boolean;
        OrderFilter: Text;
        OrderFilter2: Text;
        OrderFilter3: Text;
        OrderFilter4: Text;
        OrderFilter5: Text;
    begin
        Window.OPEN('Checking web orders...');
        // GetOrderNoFilter(CS_ISH, filterText, MaxOrder);
        Clear(OrderFilter);
        Clear(OrderFilter2);
        Clear(OrderFilter3);
        Clear(OrderFilter4);
        Clear(OrderFilter5);
        if CS_ISH.FindFirst() then
            repeat

                CS_ISH.Mark(true);
                //CS_InterimSalesLine.RESET;
                CS_InterimSalesLine.SETFILTER("Document No", CS_ISH."No.");
                CS_InterimSalesLine.SETRANGE("Document Type", CS_ISH."Document Type");
                CS_InterimSalesLine.SETRANGE(Type, CS_InterimSalesLine.Type::Item);
                if CS_InterimSalesLine.FindSet() then
                    repeat
                        CS_InterimSalesLine.Mark(true);
                    until CS_InterimSalesLine.Next() = 0;

            until CS_ISH.Next() = 0;

        Window.CLOSE;


        CS_InterimSalesLine.SetRange("Document No");
        CS_InterimSalesLine.MarkedOnly(true);
        IF CS_InterimSalesLine.FindFirst() THEN
            AllocateWebOrdersNew(CS_InterimSalesLine, LineModified, CS_InterimSalesLine.COUNT);

        CLEAR(CurrRec);
        IF GUIALLOWED THEN
            Window.OPEN('Updating web headers... @1@@@@@@@@@@');

        CS_ISH.MarkedOnly(true);
        Clear(NoOfRecs);
        NoOfRecs := CS_ISH.COUNT;
        IF CS_ISH.FINDFIRST THEN
            REPEAT
                UpdateResFlagOnISH(CS_ISH);
                IF GUIALLOWED THEN BEGIN
                    CurrRec += 1;
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL CS_ISH.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;

        //Un-Allocate Partially Reserved Order
        UnAllocatePartiallyReservedOrder(CS_ISH);
        //OrderFilter + OrderFilter2 + OrderFilter3 + OrderFilter4 + OrderFilter5);
        COMMIT;
    end;



    LOCAL procedure AllocateWebOrdersNew(VAR InterimSalesLine: Record "Interim Sales Line"; VAR LineModified: Boolean; OrderCount: Decimal)
    var
        AvailableQuantity: Decimal;
        ItemCode: Code[20];
        ReservedQty: Decimal;
        LastQty: Decimal;
        QuantityForReservedKit: Decimal;
        ItemQuery1: Query ItemQuery;
    begin
        IF GUIALLOWED THEN
            Window.OPEN('Allocating web orders... @1@@@@@@@@@@');
        NoOfRecs := OrderCount;
        IF InterimSalesLine.FINDSET THEN
            REPEAT

                IF ItemCode <> InterimSalesLine."No." THEN BEGIN
                    CLEAR(AvailableQuantity);
                    InterimSalesLine.CALCFIELDS("Location Code");
                    CLEAR(ItemQuery1);
                    ItemQuery1.SETRANGE(ItemQuery1.No, InterimSalesLine."No.");
                    ItemQuery1.SETRANGE(ItemQuery1.Location_Filter, InterimSalesLine."Location Code");
                    ItemQuery1.SETRANGE(ItemQuery1.Variant_Filter, InterimSalesLine."NAV Variant code");
                    //ItemQuery1.SETFILTER(ItemQuery1.Bin_Filter, '<>DDSHIP&<>SHIP');//Block_User Story 6088
                    ItemQuery1.SetFilter(ItemQuery1.Bin_Type_Filter, 'PUTPICK|PICK');

                    ItemQuery1.OPEN;
                    IF ItemQuery1.READ THEN BEGIN
                        CLEAR(QuantityForReservedKit);

                        AvailableQuantity := (ItemQuery1.W_H_Inventory) - (ItemQuery1.Qty_on_Sales_Order + ItemQuery1.Qty_on_Web_Resv_Order);
                    END;
                    ItemQuery1.CLOSE;

                    ItemCode := InterimSalesLine."No.";
                END;


                ReservedQty := AvailableQuantity;
                IF AvailableQuantity > 0 THEN BEGIN
                    LastQty := AvailableQuantity;
                    ReservedQty := ReservedQty - InterimSalesLine.Quantity;
                    IF ReservedQty >= 0 THEN BEGIN
                        InterimSalesLine.Reserved := TRUE;
                        InterimSalesLine."Reserved Qty" := InterimSalesLine.Quantity;
                        InterimSalesLine.MODIFY(true);
                        LineModified := TRUE;
                        AvailableQuantity := ReservedQty;
                    END;
                END;

                IF GUIALLOWED THEN BEGIN
                    CurrRec += 1;
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);
                END;
            UNTIL InterimSalesLine.NEXT = 0;
        IF GUIALLOWED THEN
            Window.CLOSE;
    end;

    procedure UpdateResFlagOnISH(VAR InterimSalesHeader: Record "Interim Sales Header")
    var
        Res_InterimSalesLine: Record "Interim Sales Line";
        ReservedLines: Integer;
        TotalLines: Integer;
        Count_InterimSalesLine: Record "Interim Sales Line";
    begin
        CLEAR(TotalLines);
        CLEAR(ReservedLines);

        Res_InterimSalesLine.RESET;
        Res_InterimSalesLine.SETRANGE("Document Type", Res_InterimSalesLine."Document Type"::Order);
        Res_InterimSalesLine.SETRANGE("Document No", InterimSalesHeader."No.");
        Res_InterimSalesLine.SETRANGE(Type, Res_InterimSalesLine.Type::Item);
        Res_InterimSalesLine.SETRANGE(Reserved, TRUE);
        ReservedLines := Res_InterimSalesLine.COUNT;

        Count_InterimSalesLine.RESET;
        Count_InterimSalesLine.SETRANGE("Document Type", Count_InterimSalesLine."Document Type"::Order);
        Count_InterimSalesLine.SETRANGE("Document No", InterimSalesHeader."No.");
        Count_InterimSalesLine.SETRANGE(Type, Count_InterimSalesLine.Type::Item);
        TotalLines := Count_InterimSalesLine.COUNT;

        IF TotalLines = ReservedLines THEN
            InterimSalesHeader.ReservedFlag := TRUE
        ELSE
            InterimSalesHeader.ReservedFlag := FALSE;


        InterimSalesHeader.MODIFY;
    end;

    procedure UnAllocatePartiallyReservedOrder(var Rec_ISH: Record "Interim Sales Header")
    var
        //Rec_ISH: Record "Interim Sales Header";
        Rec_ISL: Record "Interim Sales Line";
        WHList: Page "Warehouse Shipment List";
        OrderFilterText: Text;
    begin
        Window.OPEN('Removing Allocation for Partially Reserved orders...');
        //Rec_ISH.RESET;
        //Rec_ISH.SETFILTER("No.", OrderNoFilter);
        Rec_ISH.MarkedOnly(true);
        Rec_ISH.SETRANGE(ReservedFlag, FALSE);
        IF Rec_ISH.FINDSET THEN
            REPEAT
                //WHList.AddToFilterText2(OrderFilterText, '|', '', Rec_ISH."No.");
                Rec_ISL.RESET;
                Rec_ISL.SETRANGE("Document Type", Rec_ISH."Document Type");
                Rec_ISL.SETFILTER("Document No", Rec_ISH."No.");
                //OrderFilterText);
                Rec_ISL.SETRANGE(Type, Rec_ISL.Type::Item);
                Rec_ISL.SETRANGE(Reserved, TRUE);
                IF Rec_ISL.FINDSET THEN
                    REPEAT
                        CLEAR(Rec_ISL."Reserved Qty");
                        Rec_ISL.Reserved := FALSE;
                        Rec_ISL.MODIFY;
                    UNTIL Rec_ISL.NEXT = 0;

            UNTIL Rec_ISH.NEXT = 0;
        Window.CLOSE;
    end;

    procedure UnAllocatePartiallyReservedOrder1(OrderNoFilter: Text)
    var
        Rec_ISH: Record "Interim Sales Header";
        Rec_ISL: Record "Interim Sales Line";
        WHList: Page "Warehouse Shipment List";
        OrderFilterText: Text;
    begin
        Window.OPEN('Removing Allocation for Partially Reserved orders...');
        Rec_ISH.RESET;
        Rec_ISH.SETFILTER("No.", OrderNoFilter);
        Rec_ISH.SETRANGE(ReservedFlag, FALSE);
        IF Rec_ISH.FINDSET THEN
            REPEAT
                WHList.AddToFilterText2(OrderFilterText, '|', '', Rec_ISH."No.");
            UNTIL Rec_ISH.NEXT = 0;


        Rec_ISL.RESET;
        Rec_ISL.SETRANGE("Document Type", Rec_ISH."Document Type");
        Rec_ISL.SETFILTER("Document No", OrderFilterText);
        Rec_ISL.SETRANGE(Type, Rec_ISL.Type::Item);
        Rec_ISL.SETRANGE(Reserved, TRUE);
        IF Rec_ISL.FINDSET THEN
            REPEAT
                CLEAR(Rec_ISL."Reserved Qty");
                Rec_ISL.Reserved := FALSE;
                Rec_ISL.MODIFY;
            UNTIL Rec_ISL.NEXT = 0;
        Window.CLOSE;
    end;


    //AllocateWebOrder--
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnAfterCreateShptLineFromSalesLine', '', false, false)]
    local procedure OnAfterCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        WSH: Record "Warehouse Shipment Header";
        L_SalesLine: Record "Sales Line";
    begin
        if WarehouseShipmentLine.FindSet() then begin
            repeat
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                L_SalesLine.SetRange("Document No.", WarehouseShipmentLine."Source No.");
                L_SalesLine.SetRange("Line No.", WarehouseShipmentLine."Source Line No.");
                if L_SalesLine.FindFirst() then begin
                    WarehouseShipmentLine."Channel Code" := L_SalesLine."Channel Code";
                    WarehouseShipmentLine."Channel Order ID" := L_SalesLine."Channel Order ID";
                    WarehouseShipmentLine.Modify();
                end;
            until WarehouseShipmentLine.Next() = 0;
        end;
    end;

    local procedure UpdateStatusOnSalesOrder(P_HeaderNo: Code[20])
    var
        SH: Record "Sales Header";
        RealeaseSalesDoc: Codeunit "Release Sales Document";
    begin
        SH.Reset();
        SH.SetRange("Document Type", SH."Document Type"::Order);
        SH.SetRange("No.", P_HeaderNo);
        if SH.FindFirst() then begin
            if SH.Status = SH.Status::Open then
                RealeaseSalesDoc.PerformManualRelease(SH);
        end;
    end;

    //Bug 12946++
    procedure UpdatePostedSalesShipment()
    var
        InStrm: InStream;
        FromFile: Text;
        Sheetname: Text;
        RowNo: Integer;
        RecCount: Integer;
        SalesShipmentNo: Code[20];
        OrderNo: Code[20];
        ExternalDocNo: Code[35];
        L_SalesShipmentHeader: Record "Sales Shipment Header";
        TempNameValueBufferOut: Record "Name/Value Buffer" temporary;
    begin
        Clear(FromFile);
        Clear(Sheetname);
        Clear(RecCount);

        UploadIntoStream('Please Choose Excel File', '', '', FromFile, InStrm);
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.GetSheetsNameListFromStream(InStrm, TempNameValueBufferOut);
        Sheetname := TempNameValueBufferOut.GetValue();
        TempExcelBuffer.OpenBookStream(InStrm, Sheetname);
        TempExcelBuffer.ReadSheet();
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then
            RecCount := TempExcelBuffer."Row No.";

        for RowNo := 2 to RecCount do begin
            Clear(SalesShipmentNo);
            Clear(OrderNo);
            Clear(ExternalDocNo);

            SalesShipmentNo := GetValueAtCell(RowNo, 1);
            OrderNo := GetValueAtCell(RowNo, 2);
            ExternalDocNo := GetValueAtCell(RowNo, 4);

            L_SalesShipmentHeader.Reset();
            L_SalesShipmentHeader.SetRange("No.", SalesShipmentNo);
            L_SalesShipmentHeader.SetRange("Order No.", OrderNo);
            if L_SalesShipmentHeader.FindFirst() then begin
                L_SalesShipmentHeader."External Document No." := ExternalDocNo;
                L_SalesShipmentHeader.Modify();
                Commit();
            end;
        end;
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;
    //Bug 12946--

    [EventSubscriber(ObjectType::Report, Report::"Combine Shipments", 'OnBeforeSalesInvHeaderModify', '', false, false)]
    local procedure OnBeforeSalesInvHeaderModify(var SalesHeader: Record "Sales Header"; SalesOrderHeader: Record "Sales Header")
    begin
        SalesHeader.Validate("Payment Method Code", SalesOrderHeader."Payment Method Code");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateInternalPick(var Rec: Record "Interim Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateInternalPick(var Rec: Record "Interim Sales Header")
    begin
    end;

}


