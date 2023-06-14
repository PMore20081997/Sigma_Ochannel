page 90075 "Return Order Screen"
{
    Caption = 'B2C Return Order Scan';
    DelayedInsert = true;
    DeleteAllowed = true;
    PageType = Worksheet;
    SourceTable = "Interim Sales Return";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = Administration;
    ApplicationArea = All;
    Permissions = tabledata "Bank Account" = R;

    layout
    {
        area(content)
        {
            group("Option")
            {

                field(G_ReasonCode; G_ReasonCode)
                {
                    Caption = 'Condition';
                    ApplicationArea = All;
                    TableRelation = "Reason Code".Code;
                    QuickEntry = false;
                    Visible = false;
                }

                field(G_ReturnReasonCode; G_ReturnReasonCode)
                {
                    Caption = 'Return Reason';
                    ApplicationArea = All;
                    TableRelation = "Return Reason".Code;

                }
                field(G_OrderNo; G_OrderNo)
                {
                    Caption = 'Order No.';
                    ApplicationArea = All;
                    QuickEntry = true;
                }
                field(G_BulkScan; G_BulkScan)
                {
                    Caption = 'Quantity to return';
                    ApplicationArea = All;
                }
                field(G_Barcode; G_Barcode)
                {
                    Caption = 'Barcode';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if G_OrderNo = '' then
                            Error('Please enter an order no.');
                        // US 12005 ++
                        // if G_ReasonCode = '' then
                        //     Error('Please select a condition');
                        if G_ReturnReasonCode = '' then
                            Error('Please select return reason');

                        IF G_BulkScan = 0 then
                            Error('Please enter return quantity');
                        // if ((G_OrderNo <> '') AND (G_Barcode <> '') AND (G_ReasonCode <> '') AND (G_ReturnReasonCode <> '')) then begin
                        if ((G_OrderNo <> '') AND (G_Barcode <> '') AND (G_ReturnReasonCode <> '') AND (G_BulkScan <> 0)) then begin
                            Clear(G_ItemNo);
                            Clear(G_OrderNo2);
                            Clear(G_Barcode2);
                            G_OrderNo2 := LookupOrderNo(G_OrderNo);
                            G_Barcode2 := G_Barcode;
                            G_ItemNo := G_DespatchScanPage.FindItem(G_Barcode, 1);
                            FillReturnOrdersForScan(G_OrderNo2, G_ItemNo, G_Barcode);
                            FindHandledOrder(G_OrderNo2, G_Barcode);
                            Clear(G_BulkScan);
                            // ValidateScannedQty(G_OrderNo2, G_ItemNo, G_Barcode2); IK++Already checking while inserting into retrurn line
                        end;
                    end;
                }

            }
            repeater("Group")
            {
                Editable = false;
                Enabled = false;
                field("Channel Code"; rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Web Order No.")
                {
                    ApplicationArea = All;
                }
                field("Channel Order id"; Rec."Channel Order id")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Order Quantity"; rec."Order Quantity")
                {
                    ApplicationArea = All;
                }
                field("Quantity to Return"; rec."Quantity to Return")
                {
                    ApplicationArea = All;
                }

                field("Scanned Qty"; Rec."Scanned Qty")
                {
                    ApplicationArea = All;
                }
                field("Item Unit of Measure"; rec."Item Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; rec."Discount %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Condition; Rec.Condition)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Return Reason"; Rec."Return Reason")
                {
                    ApplicationArea = All;
                }
                field("Bay No."; Rec."Bay No.")
                {
                    ApplicationArea = All;
                }
                //Azhar++
                field("Scanned Date"; Rec."Scanned Date")
                {
                    ApplicationArea = all;
                }
                //Azhar--
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Return Order")
            {
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = CreateDocument;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_Return: Record "Interim Sales Return";
                    L_ChannelCode: Code[20];
                    SL: Record "Sales Line";
                    HISL: Record "Handled Interim Sales Line";
                    SH: Record "Sales Header";
                    HISH: Record "Handled Interim Sales Header";
                    L_OrderNo: Code[20];
                    L_ReturnOrderNo: Code[20];
                    L_LineNo: Integer;
                    Return_HISH: Record "Handled Interim Sales Header";
                    Return_HISL: Record "Handled Interim Sales Line";
                    NoSeriesManagement: Codeunit NoSeriesManagement;
                    GeneralSetup: Record "General Setup - Channels";
                    DiagProgress: Dialog;
                    L_Flag: Boolean;
                    HandledLineNo: Integer;
                    TempSH: Record "Sales Header" temporary;
                    salesreturnlist: Page "Sales Return Order List";
                    salesreturncard: Page "Sales Return Order";
                    ReleaseSalesDoc: Codeunit "Release Sales Document";
                    WebPayment: Record "Web Payment";
                    whseRecpt: Record "Warehouse Receipt Header";
                    whserecptpage: Page "Warehouse Receipt";
                    Createsourcedoc: Codeunit "Whse.-Create Source Document";
                    L_OrignalOrderid: Code[50];
                    L_OrignalOrderidLineWise: Code[50];
                    SH2: Record "Sales Header";
                    LineInvoiceDiscountAmount: Decimal;
                begin
                    Clear(L_ChannelCode);
                    Clear(L_Flag);
                    Clear(L_OrderNo);
                    Clear(L_ReturnOrderNo);
                    Clear(L_LineNo);
                    Clear(HandledLineNo);
                    Clear(DiagProgress);
                    GeneralSetup.Get();
                    L_Return.Reset();
                    L_Return.SetRange("User ID", UserId);
                    L_Return.SetCurrentKey("Channel Code", "Web Order No.", "Entry No.");
                    L_Return.SetAscending("Channel Code", true);
                    if L_Return.FindSet() then begin
                        DiagProgress.OPEN('@1@@@@@@@@@@@@@@@@@@');
                        repeat
                            //if L_ChannelCode <> L_Return."Channel Code" then begin
                            HISH.Reset();
                            HISH.SetRange("Document Type", HISH."Document Type"::Order);
                            HISH.SetRange("No.", L_Return."Web Order No.");
                            if HISH.FindFirst() then begin
                                if L_ChannelCode <> L_Return."Channel Code" then begin
                                    //code to create sales return header per channel
                                    SH.Reset();
                                    SH.Init();
                                    SH."No." := '';
                                    SH.Validate("Document Type", SH."Document Type"::"Return Order");
                                    SH.Validate("Sell-to Customer No.", HISH."Sell-to Customer No.");
                                    SH.Validate("Posting Date", Today);
                                    SH.Validate("Location Code", HISH."Location Code");
                                    // SH.Validate("External Document No.", HISH."Trade Partner Code" + '-' + format(WorkDate()));
                                    SH.Validate("External Document No.", HISH."Channel Order ID");
                                    SH.Validate("Customer Posting Group", HISH."Customer Posting Group");


                                    if HISH."Customer Posting Group" = 'FOREIGN' then begin
                                        SH.Validate("VAT Bus. Posting Group", 'EXPORT');
                                        SH.Validate("Gen. Bus. Posting Group", 'EXPORT');
                                    end else begin
                                        SH.Validate("VAT Bus. Posting Group", HISH."Customer Posting Group");
                                        SH.Validate("Gen. Bus. Posting Group", HISH."Customer Posting Group");
                                    end;

                                    WebPayment.Reset();
                                    WebPayment.SetRange("Channel Code", L_Return."Channel Code");
                                    WebPayment.SetRange("Web Payment Method", HISH."Payment Method");
                                    WebPayment.SetRange("Currency Code", HISH."Currency Code");
                                    if WebPayment.FindSet() then
                                        SH.Validate("Payment Method Code", WebPayment."NAV Payment Method 2");

                                    SH.Validate("Ship-to Name", HISH."Ship-to Name");
                                    SH.Validate("Ship-to Address", HISH."Ship-to Address");
                                    SH.Validate("Ship-to Address 2", HISH."Ship-to Address 2");
                                    SH.Validate("Ship-to County", HISH."Ship-to County");
                                    SH.Validate("Ship-to City", HISH."Ship-to City");
                                    SH.Validate("Ship-to Post Code", HISH."Ship-to Post Code");
                                    SH.Validate("Ship-to Country/Region Code", HISH."Ship-to Country/Region Code");
                                    SH.Validate("Shipping Agent Code", HISH."Shipping Agent Code");
                                    SH.Validate("Shipping Agent Service Code", HISH."Shipping Agent Service Code");

                                    if HISH."Currency Code" <> '' then
                                        SH.Validate("Currency Code", HISH."Currency Code");
                                    SH.Insert(true);
                                    TempSH.Init();
                                    TempSH."Document Type" := SH."Document Type";
                                    TempSH."No." := SH."No.";
                                    TempSH."Location Code" := SH."Location Code";
                                    TempSH.Insert();
                                END;





                                L_OrderNo := SH."No.";
                                SH2.Reset();
                                SH2.SetRange("No.", HISH."Destination Doc No.");
                                SH2.SetRange("Document Type", SH2."Document Type"::Order);
                                if SH2.FindFirst() then begin
                                    SH2.Validate(SalesOrderReturnNo, L_OrderNo);
                                    SH2.Modify(true);
                                    OnAfterCreateSalesReturn(HISH, L_OrderNo);
                                end;

                                L_ChannelCode := L_Return."Channel Code";
                                // code to create web return order per channel order id
                                IF L_OrignalOrderid <> L_Return."Web Order No." then begin
                                    Return_HISH.Init();
                                    Return_HISH.Validate("Document Type", Return_HISH."Document Type"::"Return Order");
                                    Return_HISH.Validate("Sell-to Customer No.", HISH."Sell-to Customer No.");
                                    Return_HISH.Validate("Channel Order ID", HISH."Channel Order ID");
                                    Return_HISH.Validate("Fullfillment Channel", HISH."Fullfillment Channel");
                                    Return_HISH.Validate(status, Return_HISH.status::Confirmed);
                                    Return_HISH.Validate("Trade Partner Code", HISH."Trade Partner Code");
                                    Return_HISH.Validate("Location Code", HISH."Location Code");
                                    Return_HISH."Document Date" := Today;
                                    Return_HISH.Validate("Scanned Date", L_Return."Scanned Date");
                                    Return_HISH.Validate("Package Tracking No.", HISH."Package Tracking No.");
                                    Return_HISH.Validate("Scanned By", HISH."Scanned By");
                                    Return_HISH.Validate("Web Customer No.", HISH."Web Customer No.");

                                    //shipping details
                                    Return_HISH.Validate("Web Shipment Method", HISH."Web Shipment Method");
                                    Return_HISH.Validate("Shipment Method Code", HISH."Shipment Method Code");
                                    Return_HISH.Validate("Shipping Agent Code", HISH."Shipping Agent Code");
                                    Return_HISH.Validate("Shipping Agent Service Code", HISH."Shipping Agent Service Code");
                                    Return_HISH.Validate("Shipment Date", HISH."Shipment Date");

                                    Return_HISH."Payment Method" := WebPayment."Web Payment Method";
                                    //    Return_HISH.Validate("Tracking No.", HISH."Tracking No.");
                                    Return_HISH.Validate("Ship-to Name", HISH."Ship-to Name");
                                    Return_HISH.Validate("Buyer Name", HISH."Buyer Name");
                                    Return_HISH.Validate("Ship-to Address", HISH."Ship-to Address");
                                    Return_HISH.Validate("Ship-to Address 2", HISH."Ship-to Address 2");
                                    Return_HISH.Validate("Ship-to City", HISH."Ship-to City");
                                    Return_HISH.Validate("Ship-to Post Code", HISH."Ship-to Post Code");
                                    Return_HISH.Validate("Ship-to Country", HISH."Ship-to Country");
                                    Return_HISH.Validate("Ship-to Country/Region Code", HISH."Ship-to Country/Region Code");
                                    Return_HISH.Validate("Ship-to Email", HISH."Ship-to Email");
                                    Return_HISH.Validate("Buyer Email", HISH."Buyer Email");
                                    Return_HISH.Validate("Earliest Delivery date", HISH."Earliest Delivery date");
                                    Return_HISH.Validate("Earliest Ship Date", HISH."Earliest Ship Date");
                                    Return_HISH.Validate("Customer Posting Group", HISH."Customer Posting Group");

                                    if HISH."Currency Code" <> '' then
                                        Return_HISH.Validate("Currency Code", HISH."Currency Code");

                                    Return_HISH.Validate("External Document No.", HISH."No.");
                                    Return_HISH.Validate("Scanned By", UserId);
                                    Return_HISH."No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
                                    Return_HISH.Validate("Destination Doc Type", Return_HISH."Destination Doc Type"::"Return Order");
                                    Return_HISH.Validate("Destination Doc No.", SH."No.");
                                    Return_HISH.Insert(true);
                                    L_ReturnOrderNo := Return_HISH."No.";
                                end;
                                L_OrignalOrderid := L_Return."Web Order No."
                            end;
                            /*HISH.Reset();
                            HISH.SetRange("Document Type", HISH."Document Type"::Order);
                            HISH.SetRange("No.", L_Return."Web Order No.");
                            if HISH.FindFirst() then begin

                                //CreateReturnHISH++
                                Return_HISH.Reset();
                                Return_HISH.Init();
                                
                                //   
                                //  Return_HISH.Validate("Order Amount", HISH."Order Amount");
                                Return_HISH.Validate(status, Return_HISH.status::Confirmed);
                               
                                L_ReturnOrderNo := Return_HISH."No.";
                                //CreateReturnHISH--

                            end;*/

                            //LINE++

                            //CreateReturnHISL++
                            HISL.Reset();
                            HISL.SetRange("Document Type", HISL."Document Type"::Order);
                            HISL.SetRange("Document No", L_Return."Web Order No.");
                            HISL.SetRange("Line No.", L_Return."Source Line No.");
                            if HISL.FindFirst() then begin
                                if HandledLineNo <> 0 then
                                    HandledLineNo := HandledLineNo + 10000
                                else
                                    HandledLineNo := 10000;


                                //end;

                                //CreateReturnHISL--

                                /*HISL.Reset();
                                HISL.SetRange("Document Type", HISL."Document Type"::Order);
                                HISL.SetRange("Document No", L_Return."Web Order No.");
                                // HISL.SetRange("Line No.");
                                HISL.SetRange("Line No.", L_Return."Source Line No.");
                                if HISL.FindFirst() then begin

                                    //Notes++
                                    if HISL.Type = HISL.Type::" " then begin
                                        SL.Init();
                                        SL.Validate("Document Type", SL."Document Type"::"Return Order");
                                        SL.Validate("Document No.", L_OrderNo);
                                        SL.Type := SL.Type::" ";
                                        SL.Description := L_Return.Description;
                                        SL."Line No." := GetLineno(L_OrderNo);
                                        SL.Insert(true);
                                        L_Return.Delete();
                                    end;

                                    //Notes--

                                    if HISL.Type = HISL.Type::Item then begin*/
                                IF L_OrignalOrderidLineWise <> L_Return."Web Order No." then begin
                                    SL.Init();
                                    SL.Validate("Document Type", SL."Document Type"::"Return Order");
                                    SL.Validate("Document No.", L_OrderNo);
                                    SL.Type := SL.Type::" ";
                                    SL.Description := 'Web Order No ' + HISL."Document No" + ',' + 'Channel Order Id' + HISL."Channel Order ID";
                                    SL."Line No." := GetLineno(L_OrderNo);
                                    SL.Insert(true);
                                end;
                                L_OrignalOrderidLineWise := L_Return."Web Order No.";
                                SL.Init();
                                SL.Validate("Document Type", SL."Document Type"::"Return Order");
                                SL.Validate("Document No.", L_OrderNo);
                                SL.Validate("Line No.", GetLineno(L_OrderNo));
                                SL.Validate(Type, L_Return.Type);
                                SL.Validate("No.", L_Return."Item No.");
                                SL.Validate("Variant Code", L_Return."Variant Code");
                                if L_Return.Type = L_Return.Type::" " then
                                    SL.Description := L_Return.Description;
                                SL.Validate(Quantity, L_Return."Quantity to Return");
                                if HISL."Unit of Measure Code" = 'ROLL' then
                                    SL.Validate("Unit of Measure Code", 'PCS')
                                else
                                    SL.Validate("Unit of Measure Code", HISL."Unit of Measure Code");
                                SL.Validate("Unit Price", L_Return."Unit Price");
                                //HISL."Unit Price");bloked by ak
                                //SL.Validate("Line Discount %", L_Return."Discount %");
                                SL.Validate("Return Reason Code", L_Return."Return Reason");
                                SL.Validate("Item Reference Type No.", L_Return.Condition);
                                SL."Shipping Agent Service Code" := L_Return."Bay No.";
                                SL."Scanned Date" := L_Return."Scanned Date";
                                SL."Channel Order ID" := HISL."Channel Order ID";
                                IF ((HISL.Discount > 0) and (HISL.Quantity > 0) and (HISL."Unit Price" > 0)) THEN begin
                                    SL.Validate("Line Discount %", Round(
                                       HISL.Discount / Round((HISL.Quantity * HISL."Unit Price") + HISL."VAT amount", 0.01) * 100,
                                       0.01));
                                end;

                                // LineInvoiceDiscountAmount := CalculateLineInvoiceDiscountAmount(HISL, SL, HISH, L_Return);
                                // if SL.Type = SL.Type::Item then begin
                                //     SL.Validate("Inv. Discount Amount", LineInvoiceDiscountAmount);
                                // end;

                                SL.Insert(true);
                                CreateHandledReturnOrder(Return_HISH, HISL, L_ReturnOrderNo, L_Return, HandledLineNo, SL);
                                L_Return.Delete();
                            end;
                            //end;
                            //LINE--
                            SLEEP(1000);

                            DiagProgress.UPDATE(1, L_Return."Web Order No.");

                        until L_Return.Next() = 0;


                        if TempSH.FindFirst() then
                            repeat
                                if SH.get(TempSh."Document Type", TempSh."No.") then begin
                                    if SH.Status = SH.Status::Open then
                                        ReleaseSalesDoc.PerformManualRelease(SH);
                                    SH.Mark(true);
                                end;
                            until TempSH.Next() = 0;
                        whseRecpt.Init();
                        whseRecpt.Validate("Posting Date", WorkDate());
                        whseRecpt.Insert(true);
                        whseRecpt.Validate("Location Code", sh."Location Code");
                        whseRecpt.Modify(true);
                        SH.MarkedOnly(true);
                        if SH.FindFirst() then
                            repeat
                                SL.Reset();
                                sl.SetRange("Document Type", SH."Document Type");
                                SL.SetRange("Document No.", SH."No.");
                                SL.SetRange(Type, SL.Type::Item);
                                if SL.FindFirst() then
                                    repeat
                                        Createsourcedoc.SalesLine2ReceiptLine(whseRecpt, SL)
                                    until SL.Next() = 0;
                            until SH.Next() = 0;
                        Clear(salesreturnlist);
                        Clear(salesreturncard);
                        DiagProgress.CLOSE;
                        Commit();
                        whseRecpt.SetRange("No.", whseRecpt."No.");
                        whserecptpage.SetTableView(whseRecpt);
                        whserecptpage.RunModal();
                        /*if SH.Count = 1 then begin
                            salesreturncard.SetTableView(SH);
                            salesreturncard.RunModal();
                        end else begin
                            salesreturnlist.SetTableView(SH);
                            salesreturnlist.RunModal();
                        end;*/


                    end;
                end;
            }
        }
    }



    trigger OnOpenPage()
    var
        L_Return: Record "Interim Sales Return";
    begin
        // G_BulkScan := true;
        Clear(G_BulkScan);
        CLEAR(G_Barcode);
        Clear(scancount);
        BayNo := '000';
        L_Return.RESET;
        L_Return.SETRANGE("User ID", USERID);
        IF L_Return.FINDFIRST THEN BEGIN
            Rec.RESET;
            Rec.SETRANGE("User ID", USERID);
            // Rec.SETRANGE("Order No.", L_Return."Order No.");
            //Rec.SETRANGE(Barcode, L_Return.Barcode);
            Clear(G_ItemNo);
            //G_ItemNo := G_DespatchScanPage.FindItem(G_Barcode, 1);
            FillReturnOrdersForScan(G_OrderNo, G_ItemNo, G_Barcode);
            L_Return.SetCurrentKey("Trolley No.", "Bay No.");
            L_Return.CalcSums("Quantity to Return");
            scancount := L_Return."Quantity to Return";
            if L_Return.FindLast() then
                BayNo := L_Return."Bay No.";
            if scancount > 16 then
                repeat
                    scancount := scancount - 16
                until scancount <= 16;


        END
        ELSE BEGIN
            Rec.RESET;
            Rec.SETRANGE("User ID", USERID);
            Rec.SETRANGE("Web Order No.", '');
        END;
        CurrPage.UPDATE(FALSE);

    end;

    var

        G_Barcode: Code[250];
        G_OrderNo: Code[20];
        G_ReasonCode: Code[10];
        G_ReturnReasonCode: code[10];
        G_BulkScan: Integer;
        Q_ValidateReturnOrder: Query "Validate Return Order Screen";
        TempReturnedStock: Record "Lot Bin Buffer" temporary;
        G_ItemNo: Code[20];
        G_DespatchScanPage: Page "New Despatch Scan";
        G_OrderNo2: Code[50];
        G_Barcode2: Code[250];
        G_Trolley: Code[20];
        scancount: Integer;
        BayNo: Code[20];

    local procedure LookupOrderNo(OrderRef: Code[20]): Code[50]
    var
        HandledWebOrder: Record "Handled Interim Sales Header";
    begin
        HandledWebOrder.Reset();
        HandledWebOrder.SetFilter("No.", OrderRef);
        if HandledWebOrder.FindFirst() then begin
            exit(HandledWebOrder."Channel Order ID");
        end
        else begin
            exit(OrderRef);
        end;


    end;

    local procedure GetLineno(P_DocumentNo: Code[20]): Integer
    var
        L_SL: Record "Sales Line";
        L_LineNo: Integer;
    begin
        L_SL.Reset();
        L_SL.SetRange("Document Type", L_SL."Document Type"::"Return Order");
        L_SL.SetRange("Document No.", P_DocumentNo);
        if L_SL.FindLast() then
            L_LineNo := L_SL."Line No." + 10000
        else
            L_LineNo := 10000;

        exit(L_LineNo);
    end;

    local procedure FindHandledOrder(P_OrderNo: Code[20]; P_Barcode: Code[250])
    var
        L_HandledInterimSalesLine: Record "Handled Interim Sales Line";
        L_Return: Record "Interim Sales Return";
        L_DespatchScanPage: Page "New Despatch Scan";
    begin
        L_HandledInterimSalesLine.RESET;
        L_HandledInterimSalesLine.SETRANGE("Document Type", L_HandledInterimSalesLine."Document Type"::Order);
        L_HandledInterimSalesLine.SETRANGE(Type, L_HandledInterimSalesLine.Type::Item);
        L_HandledInterimSalesLine.SETRANGE("No.", L_DespatchScanPage.FindItem(G_Barcode, 1));
        if L_HandledInterimSalesLine."NAV Variant code" <> '' then
            L_HandledInterimSalesLine.SETRANGE(L_HandledInterimSalesLine."NAV Variant code", L_DespatchScanPage.FindItem(G_Barcode, 2));
        L_HandledInterimSalesLine.SETFILTER("Item Type", '<>%1', L_HandledInterimSalesLine."Item Type"::Assembly);
        L_HandledInterimSalesLine.SetRange("Channel Order id", P_OrderNo);
        IF L_HandledInterimSalesLine.FINDFIRST THEN BEGIN
            /*L_Return.RESET;
            L_Return.SETRANGE("Web Order No.", L_HandledInterimSalesLine."Document No");
            IF NOT L_Return.FINDFIRST THEN BEGIN*/
            CheckHandledReturnOrderExist(L_HandledInterimSalesLine);//khan++
            InsertLineIntoDespatchTable(L_HandledInterimSalesLine);
            // END;
            Clear(G_Barcode);//khan++
            Clear(G_OrderNo);//khan++
            //Clear(G_ReasonCode);
            //Clear(G_ReturnReasonCode);
        END;
    end;

    local procedure CheckHandledReturnOrderExist(P_HandledInterimSalesLine: Record "Handled Interim Sales Line")
    var
    begin
    end;

    local procedure InsertLineIntoDespatchTable(P_HandledInterimSalesLine: Record "Handled Interim Sales Line")
    var
        L_Return: Record "Interim Sales Return";
        L_ReturnHandledQty: Decimal;
        L_QtyOnReturnLine: Decimal;
        i: Integer;
        GeneralSetgup: record "General Setup - Channels";
        P_HandledInterimSalesHeader: Record "Handled Interim Sales Header";//Azhar
    begin
        CLEAR(i);
        /*L_HandledInterimSalesLine.RESET;
        L_HandledInterimSalesLine.SETRANGE("Document No", L_WebDocNo);
        L_HandledInterimSalesLine.SETRANGE(Type, L_HandledInterimSalesLine.Type::Item);
        L_HandledInterimSalesLine.SETFILTER("Item Type", '<>%1', L_HandledInterimSalesLine."Item Type"::Assembly);
        IF L_HandledInterimSalesLine.FINDSET THEN
          REPEAT*/

        scancount += 1;
        if scancount = 16 then
            scancount := 1;

        if scancount = 1 then
            BayNo := IncStr(BayNo);
        GeneralSetgup.Get();
        L_Return.RESET;
        L_Return.SETRANGE("Web Order No.", P_HandledInterimSalesLine."Document No");
        L_Return.SetRange("Item No.", P_HandledInterimSalesLine."No.");
        L_Return.SetRange("Return Reason", G_ReturnReasonCode);
        if P_HandledInterimSalesLine."NAV Variant code" <> '' then
            L_Return.SetRange("Variant Code", P_HandledInterimSalesLine."NAV Variant code");
        if NOT L_Return.FindFirst() then begin

            L_Return.INIT;
            L_Return."Entry No." := FindLastEntryNo;
            L_Return."Web Order No." := P_HandledInterimSalesLine."Document No";
            L_Return.Type := P_HandledInterimSalesLine.Type;
            L_Return."Item No." := P_HandledInterimSalesLine."No.";
            L_Return."Variant Code" := P_HandledInterimSalesLine."NAV Variant code";
            L_Return.Description := P_HandledInterimSalesLine.Description;
            L_Return.Barcode := G_Barcode;
            L_Return."Variant Code" := P_HandledInterimSalesLine."NAV Variant code";
            L_Return."User ID" := UserId;
            L_Return."Channel Code" := P_HandledInterimSalesLine."Trade Partner Code";
            L_Return."Channel Order id" := P_HandledInterimSalesLine."Channel Order ID";
            L_Return."Order Quantity" := P_HandledInterimSalesLine.Quantity;
            L_Return."Item Unit of Measure" := P_HandledInterimSalesLine."Unit of Measure Code";
            // L_Return."Quantity to Return" := P_HandledInterimSalesLine.Quantity - L_ReturnQty;
            L_Return."Quantity to Return" := G_BulkScan;

            CheckAndValidateQuantity(L_ReturnHandledQty, L_QtyOnReturnLine, L_Return);
            L_Return."Scanned Qty" := L_ReturnHandledQty;
            if (L_Return."Quantity to Return" + L_ReturnHandledQty + L_QtyOnReturnLine) > L_Return."Order Quantity" then
                Error('Return quantity should not be more than order quantity.');

            L_Return.Condition := G_ReasonCode;
            L_Return."Return Reason" := G_ReturnReasonCode;
            L_Return."Source Line No." := P_HandledInterimSalesLine."Line No.";
            L_Return."Unit Price" := P_HandledInterimSalesLine."Unit Price";
            L_Return."Bay No." := BayNo;
            //L_Return."Discount %" := P_HandledInterimSalesLine."Discount %";
            L_Return."Scanned Date" := CurrentDateTime();
            //Azhar++
            // P_HandledInterimSalesHeader.Reset();
            // P_HandledInterimSalesHeader.SetRange("No.", P_HandledInterimSalesLine."Document No");
            // if P_HandledInterimSalesHeader.FindFirst() then begin
            //     L_Return."Scanned Date" := P_HandledInterimSalesHeader."Scanned Date";
            // end;
            //Azhar--
            L_Return.Insert();
        end else begin
            L_Return."Quantity to Return" += G_BulkScan;
            CheckAndValidateQuantity(L_ReturnHandledQty, L_QtyOnReturnLine, L_Return);
            if (L_Return."Quantity to Return" + L_ReturnHandledQty + L_QtyOnReturnLine) > L_Return."Order Quantity" then begin
                Message('Return quantity should not be more than order quantity.');
            end else
                L_Return.Modify();

            //IK ++ Aplly above logic for the validation
            // if L_Return."Quantity to Return" > L_Return."Order Quantity" then begin
            //     Clear(G_OrderNo);
            //     Clear(G_Barcode);
            //     Message('Return quantity should not be more than order quantity.');
            // end else
            //     L_Return.Modify();
            // IK--

        end;
        if GeneralSetgup."Enable Carriage credit" then
            if checkifallorderitemlinesreturned(P_HandledInterimSalesLine) then
                CreateShippingChargeLine(P_HandledInterimSalesLine, L_Return."Entry No.");// code to pull shipping GL line
        FindNotesInHandledOrder(P_HandledInterimSalesLine."Channel Order ID", L_Return."Entry No.");//code to show notes on return screen
        rec.RESET;
        rec.SETCURRENTKEY("Entry No.");
        rec.ASCENDING(FALSE);
        rec.SETRANGE("User ID", USERID);
        rec.SETRANGE("Web Order No.", P_HandledInterimSalesLine."Document No");
        rec.FINDLAST;
        CurrPage.UPDATE(FALSE);
        rec.SETRANGE("Web Order No.");
        CurrPage.UPDATE(FALSE);
    end;

    local procedure checkifallorderitemlinesreturned(P_HandledInterimSalesLine: Record "Handled Interim Sales Line"): Boolean
    var
        L_OrderHandledInterimSalesLine: record "Handled Interim Sales Line";
        Query_ValidateReturnOrder: Query "Validate Return Order Screen";
        Query_ValidateInterimreturn: Query "Validate Interim Sales Return";
        TotalItemReturnQty: Decimal;
    begin
        L_OrderHandledInterimSalesLine.Reset();
        L_OrderHandledInterimSalesLine.SetRange("Document Type", P_HandledInterimSalesLine."Document Type");
        L_OrderHandledInterimSalesLine.SetRange("Document No", P_HandledInterimSalesLine."Document No");
        L_OrderHandledInterimSalesLine.SetRange(Type, L_OrderHandledInterimSalesLine.Type::Item);
        IF L_OrderHandledInterimSalesLine.FindSet() then
            repeat
                Clear(TotalItemReturnQty);
                Query_ValidateInterimreturn.SetRange(web_order_no, L_OrderHandledInterimSalesLine."Document No");
                Query_ValidateInterimreturn.SetRange(Item_No, L_OrderHandledInterimSalesLine."No.");
                Query_ValidateInterimreturn.SetRange(Variant_Code, L_OrderHandledInterimSalesLine."NAV Variant code");
                Query_ValidateInterimreturn.Open();
                while Query_ValidateInterimreturn.Read() do begin
                    TotalItemReturnQty := Query_ValidateInterimreturn.Quantity_to_Return;
                end;
                Query_ValidateReturnOrder.SetRange(Channel_Order_ID, L_OrderHandledInterimSalesLine."Channel Order ID");
                Query_ValidateReturnOrder.SetRange(No_, L_OrderHandledInterimSalesLine."No.");
                Query_ValidateReturnOrder.SetRange(NAV_Variant_code, L_OrderHandledInterimSalesLine."NAV Variant code");
                Query_ValidateReturnOrder.Open();
                while Query_ValidateReturnOrder.Read() do begin
                    TotalItemReturnQty += Query_ValidateReturnOrder.Quantity;
                end;
                if L_OrderHandledInterimSalesLine.Quantity <> TotalItemReturnQty then
                    exit(false)
until L_OrderHandledInterimSalesLine.Next() = 0;
        exit(true);
    end;

    local procedure CreateShippingChargeLine(P_HandledInterimSalesLine: Record "Handled Interim Sales Line"; P_EntryNo: Integer)
    var
        L_HandledInterimSalesLine: Record "Handled Interim Sales Line";
        L_Return: Record "Interim Sales Return";
        L_GeneralSetupOchannel: record "General Setup - Channels";
        L_Return1: Record "Interim Sales Return";
        L_HandledInterimSaleshdr: Record "Handled Interim Sales Header";//Azhar
    begin
        L_HandledInterimSalesLine.Reset();
        L_HandledInterimSalesLine.SetRange("Document Type", P_HandledInterimSalesLine."Document Type");
        L_HandledInterimSalesLine.SetRange("Document No", P_HandledInterimSalesLine."Document No");
        L_HandledInterimSalesLine.SetRange(Type, L_HandledInterimSalesLine.Type::"G/L Account");
        if L_HandledInterimSalesLine.FindFirst() then begin
            L_GeneralSetupOchannel.Get();
            L_Return.Reset();
            L_Return.SetRange("Channel Order id", L_HandledInterimSalesLine."Channel Order ID");
            L_Return.SetRange(Type, L_Return.Type::"G/L Account");
            L_Return.SetRange("Item No.", L_GeneralSetupOchannel."Shipping G/L No.");
            if NOT L_Return.FindFirst() then begin
                L_Return.INIT;
                L_Return1.ASCENDING(FALSE);
                L_Return1.SetCurrentKey("Web Order No.");
                L_Return1.SetRange("Web Order No.", L_HandledInterimSalesLine."Document No");
                if L_Return1.FindLast() then;
                L_Return."Entry No." := L_Return1."Entry No." - 1;
                L_Return."Web Order No." := L_HandledInterimSalesLine."Document No";
                L_Return.Type := L_HandledInterimSalesLine.Type;
                L_Return."Item No." := L_HandledInterimSalesLine."No.";
                L_Return.Description := L_HandledInterimSalesLine.Description;
                L_Return."User ID" := UserId;
                L_Return."Channel Code" := L_HandledInterimSalesLine."Trade Partner Code";
                L_Return."Channel Order id" := L_HandledInterimSalesLine."Channel Order ID";
                L_Return."Order Quantity" := L_HandledInterimSalesLine.Quantity;
                L_Return."Quantity to Return" := 1;
                L_Return.Condition := G_ReasonCode;
                L_Return."Return Reason" := G_ReturnReasonCode;
                L_Return."Source Line No." := L_HandledInterimSalesLine."Line No.";
                L_Return."Unit Price" := L_HandledInterimSalesLine."Unit Price";
                //L_Return."Discount %" := L_HandledInterimSalesLine."Discount %";
                //Azhar++
                L_HandledInterimSaleshdr.Reset();
                L_HandledInterimSaleshdr.SetRange("No.", L_HandledInterimSalesLine."Document No");
                if L_HandledInterimSaleshdr.FindFirst() then begin
                    L_Return."Scanned Date" := L_HandledInterimSaleshdr."Scanned Date";
                end;
                //Azhar--
                L_Return.Insert();
            end;
        end;
    end;

    local procedure FindLastEntryNo(): Integer
    var
        L_Return: Record "Interim Sales Return";
    begin
        L_Return.RESET;
        IF L_Return.FINDLAST THEN
            EXIT(L_Return."Entry No." + 1000)
        ELSE
            EXIT(1000);
    end;

    local procedure FindItem(P_CrossRef: Code[20]): Code[20]
    var
        L_ItemBarcode: Record "Item Reference";
        L_ItemNo: Record Item;
    begin
        L_ItemBarcode.RESET;
        L_ItemBarcode.SETRANGE("Reference Type", L_ItemBarcode."Reference Type"::"Bar Code");
        L_ItemBarcode.SETRANGE("Reference No.", P_CrossRef);
        IF L_ItemBarcode.FINDFIRST THEN
            EXIT(L_ItemBarcode."Item No.");

        ERROR('Item not find');
    end;

    local procedure CreateHandledReturnOrder(Return_HISH: Record "Handled Interim Sales Header"; P_HISL: Record "Handled Interim Sales Line"; P_DocNo: Code[20]; P_Return: Record "Interim Sales Return"; P_LineNo: Integer; P_SL: Record "Sales Line")
    var
        L_HandledInterSalesLine: Record "Handled Interim Sales Line";
    begin
        L_HandledInterSalesLine.Reset();
        L_HandledInterSalesLine.Init();
        L_HandledInterSalesLine.Validate("Document Type", L_HandledInterSalesLine."Document Type"::"Return Order");
        L_HandledInterSalesLine.Validate("Document No", P_DocNo);
        L_HandledInterSalesLine.Validate("Line No.", P_LineNo);
        L_HandledInterSalesLine.Validate(Type, P_SL.Type);
        L_HandledInterSalesLine.Validate("No.", P_SL."No.");
        L_HandledInterSalesLine.Validate(Description, P_SL.Description);
        L_HandledInterSalesLine.Validate("Channel Price", P_HISL."Channel Price");
        L_HandledInterSalesLine.Validate("Unit Price", P_SL."Unit Price");
        //L_HandledInterSalesLine.Validate("Discount %", P_SL."Line Discount %");
        L_HandledInterSalesLine.Validate(Discount, P_SL."Line Discount Amount");
        L_HandledInterSalesLine.Validate(Amount, P_SL.Amount + P_SL."Line Discount Amount");
        L_HandledInterSalesLine.Validate("Amount Including VAT", P_SL."Amount Including VAT" + P_SL."Line Discount Amount");
        L_HandledInterSalesLine.Validate("VAT amount", (P_SL."Amount Including VAT" - P_Sl.Amount));
        L_HandledInterSalesLine.Validate("VAT Bus. Posting Group", P_HISL."VAT Bus. Posting Group");
        L_HandledInterSalesLine.Validate("VAT Prod. Posting Group", P_HISL."VAT Prod. Posting Group");
        L_HandledInterSalesLine.Validate("Scanned Date", P_Return."Scanned Date");
        L_HandledInterSalesLine.Validate("Channel SKU", P_HISL."Channel SKU");
        L_HandledInterSalesLine.Validate(Quantity, P_Return."Quantity to Return");
        L_HandledInterSalesLine.Validate("Channel Item Id", P_HISL."Channel Item Id");
        L_HandledInterSalesLine.Validate("Channel Order ID", P_HISL."Channel Order ID");
        L_HandledInterSalesLine.Validate(Weight, P_HISL.Weight);
        L_HandledInterSalesLine.Validate("Item Type", P_HISL."Item Type");
        L_HandledInterSalesLine.Validate("NAV Variant code", P_HISL."NAV Variant code");
        L_HandledInterSalesLine.Validate("Trade Partner Code", P_HISL."Trade Partner Code");
        L_HandledInterSalesLine.Validate("Unit of Measure Code", P_SL."Unit of Measure Code");
        L_HandledInterSalesLine.Insert(true);
    end;

    local procedure FillReturnOrdersForScan(P_ChannelOrderID: Code[50]; P_ItemNo: Code[20]; P_Barcode: Code[250])
    var
        L_CrossReference: Record "Item Reference";
    begin
        CLEAR(Q_ValidateReturnOrder);
        Q_ValidateReturnOrder.SETRANGE(Q_ValidateReturnOrder.Channel_Order_ID, P_ChannelOrderID);
        Q_ValidateReturnOrder.SETRANGE(Q_ValidateReturnOrder.No_, P_ItemNo);
        L_CrossReference.Reset();
        L_CrossReference.SetRange("Item No.", P_ItemNo);
        L_CrossReference.SetRange("Reference Type", L_CrossReference."Reference Type"::"Bar Code");
        L_CrossReference.SetRange("Reference No.", P_Barcode);
        if L_CrossReference.FindFirst() then
            Q_ValidateReturnOrder.SETRANGE(Q_ValidateReturnOrder.NAV_Variant_code, L_CrossReference."Variant Code");
        Q_ValidateReturnOrder.OPEN;
        WHILE Q_ValidateReturnOrder.READ DO BEGIN
            TempReturnedStock.RESET;
            TempReturnedStock.SETRANGE("Item No.", Q_ValidateReturnOrder.No_);
            TempReturnedStock.SetRange("Variant Code", Q_ValidateReturnOrder.NAV_Variant_code);
            TempReturnedStock.SETRANGE("Bin Code", Q_ValidateReturnOrder.Channel_Order_ID);
            IF NOT TempReturnedStock.FINDFIRST THEN BEGIN
                TempReturnedStock.INIT;
                TempReturnedStock."Item No." := Q_ValidateReturnOrder.No_;
                TempReturnedStock."Variant Code" := Q_ValidateReturnOrder.NAV_Variant_code;
                TempReturnedStock."Bin Code" := Q_ValidateReturnOrder.Channel_Order_ID;
                TempReturnedStock."Qty. (Base)" := Q_ValidateReturnOrder.Quantity;
                TempReturnedStock.INSERT;
            END ELSE BEGIN
                TempReturnedStock."Qty. (Base)" += Q_ValidateReturnOrder.Quantity;
                TempReturnedStock.MODIFY;
            END;
        END;
        Q_ValidateReturnOrder.CLOSE;

    end;

    local procedure ValidateScannedQty(P_ChannelOrderID: Code[50]; P_ItemNo: Code[20]; P_Barcode: Code[250])
    var
        L_ReturnedCount: Record "Interim Sales Return";
        L_CrossReference: Record "Item Reference";
        L_VariantCode: Code[20];
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
    begin
        TempReturnedStock.RESET;
        TempReturnedStock.SETRANGE("Item No.", P_ItemNo);
        L_CrossReference.Reset();
        L_CrossReference.SetRange("Item No.", P_ItemNo);
        L_CrossReference.SetRange("Reference Type", L_CrossReference."Reference Type"::"Bar Code");
        L_CrossReference.SetRange("Reference No.", P_Barcode);
        if L_CrossReference.FindFirst() then
            L_VariantCode := L_CrossReference."Variant Code";
        TempReturnedStock.SetRange("Variant Code", L_VariantCode);

        TempReturnedStock.CALCSUMS("Qty. (Base)");

        L_ReturnedCount.RESET;
        L_ReturnedCount.SETRANGE("Channel Order id", P_ChannelOrderID);
        L_ReturnedCount.SETRANGE("Item No.", P_ItemNo);
        L_ReturnedCount.SetRange("Variant Code", L_VariantCode);

        L_ReturnedCount.CALCSUMS("Order Quantity");

        if (L_ReturnedCount."Order Quantity" = 0) and (TempReturnedStock."Qty. (Base)" = 0) THEN
            exit;

        IF L_ReturnedCount."Order Quantity" <= TempReturnedStock."Qty. (Base)" THEN
            ERROR('Order is already scanned');

    end;


    local procedure FindNotesInHandledOrder(P_OrderNo: Code[20]; P_EntryNo: Integer)
    var
        L_HandledInterimSalesLine: Record "Handled Interim Sales Line";
        L_Return: Record "Interim Sales Return";

    begin
        L_HandledInterimSalesLine.RESET;
        L_HandledInterimSalesLine.SETRANGE("Document Type", L_HandledInterimSalesLine."Document Type"::Order);
        L_HandledInterimSalesLine.SetRange(Type, L_HandledInterimSalesLine.Type::" ");
        L_HandledInterimSalesLine.SETFILTER("Item Type", '<>%1', L_HandledInterimSalesLine."Item Type"::Assembly);
        L_HandledInterimSalesLine.SetRange("Channel Order id", P_OrderNo);
        IF L_HandledInterimSalesLine.FINDFIRST THEN BEGIN
            InsertNotesLineIntoDespatchTable(L_HandledInterimSalesLine, P_EntryNo);
            Clear(G_Barcode);
            Clear(G_OrderNo);
        END;
    end;

    local procedure InsertNotesLineIntoDespatchTable(P_HandledInterimSalesLine: Record "Handled Interim Sales Line"; P_EntryNo: Integer)
    var
        L_Return: Record "Interim Sales Return";
        P_HandledInterimSalesHdr: Record "Handled Interim Sales Header";//Azhar+
    begin


        L_Return.RESET;
        L_Return.SETRANGE("Web Order No.", P_HandledInterimSalesLine."Document No");
        L_Return.SetRange(Description, P_HandledInterimSalesLine.Description);
        if NOT L_Return.FindFirst() then begin

            L_Return.INIT;
            L_Return."Entry No." := P_EntryNo - 2;
            L_Return."Channel Code" := P_HandledInterimSalesLine."Trade Partner Code";
            L_Return."Web Order No." := P_HandledInterimSalesLine."Document No";
            L_Return."Source Line No." := P_HandledInterimSalesLine."Line No.";
            L_Return.Description := P_HandledInterimSalesLine.Description;
            L_Return."Channel Order id" := P_HandledInterimSalesLine."Channel Order ID";
            L_Return."User ID" := UserId;
            //Azhar++
            P_HandledInterimSalesHdr.Reset();
            P_HandledInterimSalesHdr.SetRange("No.", P_HandledInterimSalesLine."Document No");
            if P_HandledInterimSalesHdr.FindFirst() then begin
                L_Return."Scanned Date" := P_HandledInterimSalesHdr."Scanned Date";
            end;
            //Azhar--
            L_Return.Insert();
        end;
    end;

    local procedure CalculateLineInvoiceDiscountAmount(P_HISL: Record "Handled Interim Sales Line"; P_SL: Record "Sales Line"; P_HISH: Record "Handled Interim Sales Header"; P_Return: Record "Interim Sales Return"): Decimal
    var
        L_DiscountExVat: Decimal;
        L_Return: Record "Interim Sales Return";
        LineCount: Integer;
        InvDiscountAmount: Decimal;
        L_HandledInterimSalesLine: Record "Handled Interim Sales Line";
    begin
        Clear(LineCount);

        L_Return.Reset();
        L_Return.SetRange("Web Order No.", P_Return."Web Order No.");
        L_Return.SetFilter(Type, '%1', L_Return.Type::Item);
        LineCount := L_Return.Count();
        if P_HISH."Order Discount Amount" - P_HISL.Discount > 0 then begin
            L_DiscountExVat := (P_HISH."Order Discount Amount" - P_HISL.Discount) / (P_SL."VAT %" / 100 + 1);
            if (L_DiscountExVat > 0) and (LineCount > 0) then
                InvDiscountAmount := L_DiscountExVat / LineCount;
        end;
        exit(InvDiscountAmount);
    end;

    local procedure CheckAndValidateQuantity(var P_ReturnHandledQty: Decimal; Var P_QtyOnReturnLine: Decimal; var P_InterimSalesReturn: Record "Interim Sales Return")
    var
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        InterimSalesReturn: Record "Interim Sales Return";
    begin
        Clear(P_ReturnHandledQty);
        Clear(P_QtyOnReturnLine);
        HandledInterimSalesLine.Reset();
        HandledInterimSalesLine.SetRange("Document Type", HandledInterimSalesLine."Document Type"::"Return Order");
        HandledInterimSalesLine.SetRange("Channel Order ID", P_InterimSalesReturn."Channel Order id");
        HandledInterimSalesLine.SetRange("No.", P_InterimSalesReturn."Item No.");
        HandledInterimSalesLine.SetRange("NAV Variant code", P_InterimSalesReturn."Variant Code");
        if HandledInterimSalesLine.FindSet() then
            repeat
                P_ReturnHandledQty += HandledInterimSalesLine.Quantity;
            until HandledInterimSalesLine.Next() = 0;

        InterimSalesReturn.Reset();
        InterimSalesReturn.SetRange("Channel Order id", P_InterimSalesReturn."Channel Order id");
        InterimSalesReturn.SetRange("Item No.", P_InterimSalesReturn."Item No.");
        InterimSalesReturn.SetRange("Variant Code", P_InterimSalesReturn."Variant Code");
        InterimSalesReturn.SetFilter("Return Reason", '<>%1', P_InterimSalesReturn."Return Reason");
        if InterimSalesReturn.FindSet() then
            repeat
                P_QtyOnReturnLine += InterimSalesReturn."Quantity to Return";
            until InterimSalesReturn.Next() = 0;

    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCreateSalesReturn(P_HISH: Record "Handled Interim Sales Header"; P_OrderNo: Code[20])
    begin
    end;



}

