codeunit 90082 "EDI Invoice"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "Sales Invoice Header" = M;
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF



            EDICustomerLabel:
                begin

                    GetEDIRecords();

                end;
            EDISupplierLabel:
                begin
                    GetEDIRecords1();

                end;
            EDICrMemoLabel:
                begin
                    GetEDIRecords2();

                end;
            EDISalesOrderLabel:
                begin
                    GetEDIRecords3();

                end;

            EDILabel:
                begin
                    GetEDIRecords(); //SalesInvoice
                    GetEDIRecords1(); //PO
                    GetEDIRecords2(); //SalesCreditMemo

                end;
        end;
    end;
    //Customer EDI
    procedure GetEDIRecords() //salesinvoice
    var
        NoSeriesMgmt: Codeunit "No. Series";
        NextNo: Code[20];
        Salesinvoicehead: Record "Sales Invoice Header";

        //salesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin

        Customer.Reset();
        Customer.SetRange("EDI Invoice/Credit", true);
        if Customer.FindSet() then begin
            repeat
                Salesinvoicehead.Reset();
                Salesinvoicehead.SetRange("Sell-to Customer No.", Customer."No.");
                // Salesinvoicehead.SetRange("Document Type", salesHeader."Document Type"::Invoice);
                if Salesinvoicehead.FindSet() then begin
                    repeat
                        ProcessEDIFile(Salesinvoicehead, Customer);
                    until Salesinvoicehead.Next() = 0;

                end;
            until Customer.Next() = 0;

        end;
    end;


    procedure ProcessEDIFile(var Salesinvoicehead: Record "Sales Invoice Header"; var P_customer: Record Customer)
    var
        // SalesHeader: Record "Sales Header";

        CompanyInfo: Record "Company Information";
        salesinvoiceline: Record "Sales Invoice Line";
        item: Record Item;
        Customer1: Record Customer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        Clear(InvNo);
        Clear(DMYPostingFormat);
        Clear(YearText);
        Clear(MonthText);
        Clear(Dateformat);
        Clear(TimeFormat);
        Clear(TimeStr);
        Clear(TimeText);
        Clear(HeaderInfoAll);
        Clear(HeaderInfo1);
        Clear(HeaderInfo2);
        Clear(HeaderInfo3);
        Clear(HeaderInfo4);
        Clear(HeaderInfo5);
        Clear(HeaderInfo6);
        Clear(HeaderInfo7);
        Clear(HeaderInfo8);
        Clear(HeaderInfo9);
        Clear(HeaderInfo10);
        Clear(HeaderInfo11);
        Clear(CompGLN);
        Clear(PartnerGLN);
        Clear(PaymentTermDays);
        CompanyInfo.get();
        //posting date
        Dateformat := Date2DMY(Salesinvoicehead."Order Date", 1);
        if Dateformat < 10 then
            DateText := '0' + Format(Dateformat)
        else
            DateText := format(Dateformat);
        Monthformat := Date2DMY(Salesinvoicehead."Order Date", 2);
        if Monthformat < 10 then
            MonthText := '0' + Format(Monthformat)
        else
            MonthText := format(Monthformat);
        Yearformat := Date2DMY(Salesinvoicehead."Order Date", 3);
        YearText := Format(Yearformat);
        DMYPostingFormat := YearText + MonthText + DateText;
        //Due Date
        DueDateformat := Date2DMY(Salesinvoicehead."Due Date", 1);
        if DueDateformat < 10 then
            DueDateText := '0' + Format(DueDateformat)
        else
            DueDateText := format(DueDateformat);
        DueMonthformat := Date2DMY(Salesinvoicehead."Due Date", 2);
        if DueMonthformat < 10 then
            DueMonthText := '0' + Format(DueMonthformat)
        else
            DueMonthText := format(DueMonthformat);
        DueYearformat := Date2DMY(Salesinvoicehead."Due Date", 3);
        DueYearText := Format(DueYearformat);
        DMYDueDateFormat := DueYearText + DueMonthText + DueDateText;

        Time1 := DT2Time(Salesinvoicehead.SystemCreatedAt);
        TimeText := Format(Time1, 0, '<Hours24,2><Minutes,2><Seconds,2>');
        InvNo := Salesinvoicehead."No.";
        Customer1.Reset();
        Customer1.SetFilter("No.", P_customer."Bill-to Customer No.");
        if Customer1.FindFirst() THEN begin
            PartnerGLN := Customer1.GLN;
        end;
        CompGLN := P_customer.GLN;
        Curr := Salesinvoicehead."Currency Code";
        RefCurr := P_customer."Currency Code";
        taxDate := Salesinvoicehead."VAT Reporting Date";
        PaymentTermDays := Salesinvoicehead."Due Date" - Salesinvoicehead."Order Date";
        //TotalAmt := SalesHeader."Amount Including VAT";
        Salesinvoicehead.CalcFields("Amount Including VAT", Amount);
        TaxAmount := Salesinvoicehead."Amount Including VAT" - Salesinvoicehead.Amount;
        BuyerRef := Salesinvoicehead."External Document No.";
        Clear(LineInfoAll);
        Clear(count);
        Clear(TotalAmtIncVat);
        Clear(LineInfo1);
        Clear(LineInfo2);
        Clear(LineInfo3);
        Clear(item);
        Clear(gtin);
        Clear(PackSize);
        Clear(Desc);
        Clear(Subtotalgoodsval);
        salesinvoiceline.Reset();
        salesinvoiceline.SetRange("Document No.", Salesinvoicehead."No.");
        //salesinvoiceline.SetRange("Document Type", Salesinvoicehead."Document Type");
        salesinvoiceline.SetRange(Type, salesinvoiceline.Type::Item);
        if salesinvoiceline.findset() then begin
            repeat

                item.Reset();
                if item.Get(salesinvoiceline."No.") then begin
                    gtin := item.GTIN;
                    PackSize := item."EDI Pack size";
                    Desc := item."EDI Description";
                    Subtotalgoodsval += ((salesinvoiceline."Unit Price" * salesinvoiceline.Quantity));
                end;
                count += 1;
                TotalAmtIncVat += salesinvoiceline."Amount Including VAT";
                TotalAmtExcVat += salesinvoiceline.Amount;
                DiscountAmt += salesinvoiceline."Line Discount Amount";
                totalVatBaseAmt += salesinvoiceline."VAT Base Amount";
                LineInfo1 := '*IL' + '^' + InvNo + '^' + format(count) + '^' + BuyerRef + '^' + DMYPostingFormat + '^^' + format(salesinvoiceline.Quantity) + '^' + '2' + '^^' + format(salesinvoiceline."Unit Price") + '^' + Format(salesinvoiceline.Amount) + '^' + 'VAT' + '^' + 'E' + '^' + 'N' + '^' + format(salesinvoiceline."VAT %") + '^' + format(salesinvoiceline."Amount Including VAT" - salesinvoiceline.Amount) + '^^^' + CRLF[1];
                LineInfo2 := '**P' + '^' + 'O' + '^' + salesinvoiceline."No." + '^' + gtin + '^^^^^^' + Desc + '^^' + Format(PackSize) + '^^^^^^^^^^^^^^^^^^^^^^^^^^^^' + CRLF[1];
                LineInfo3 := '**G^O^' + format(salesinvoiceline.Amount) + '^' + Format(salesinvoiceline."Unit Price") + '^^^^^^^^^^^^' + CRLF[1];
                LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
            until salesinvoiceline.Next() = 0;

        end;
        HeaderInfoAll := '';
        HeaderInfo1 := '**!' + '1.02.30' + 'G' + 'INV' + InvNo + DMYPostingFormat + TimeText + 'D' + '^' + CRLF[1];
        HeaderInfo2 := '**D' + '^' + CompanyInfo."Registration No." + '^' + '^' + '^' + 'INV' + '^' + '^' + 'N' + '^' + InvNo + '^' + DMYPostingFormat + '^' + '1' + '^' + '^' + '^' + RefCurr + '^' + RefCurr + '^^^^' + CRLF[1];
        HeaderInfo3 := '*IH' + '^' + InvNo + '^' + DMYPostingFormat + '^' + DMYPostingFormat + '^' + '^' + '^' + DMYDueDateFormat + '^' + Format(PaymentTermDays) + '^' + format(TotalAmtIncVat) + '^' + format(TaxAmount) + '^' + Format(Salesinvoicehead."Payment Discount %") + '^' + '^' + '^' + '^' + '^' + '^' + '^^' + CRLF[1];
        HeaderInfo12 := '*DH' + '^' + Salesinvoicehead."Order No." + '^' + DMYPostingFormat + '^^^^^^^^^^^^^^^^^^^^^^^^^^^^' + CRLF[1];
        HeaderInfo4 := '*OH' + '^' + BuyerRef + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^^^^^^^^^' + CRLF[1];
        HeaderInfo5 := '**A' + '^' + '0' + '^' + '0' + '^' + 'COMPANY' + '^' + CompanyInfo.GLN + '^^^^^' + CompanyInfo.GLN + '^' + CompanyInfo.Name + '^' + CompanyInfo.Address + '^' + CompanyInfo."Address 2" + '^' + CompanyInfo.City + '^' + CompanyInfo.County + '^' + CompanyInfo."Post Code" + '^' + CompanyInfo."Country/Region Code" + '^' + CRLF[1];
        HeaderInfo6 := '**A' + '^' + '0' + '^' + '0' + '^' + 'PARTNER' + '^' + PartnerGLN + '^^^^^^' + Salesinvoicehead."Bill-to Name" + '^' + Salesinvoicehead."Bill-to Address" + '^' + Salesinvoicehead."Bill-to Address 2" + '^' + Salesinvoicehead."Bill-to City" + '^' + Salesinvoicehead."Bill-to County" + '^' + Salesinvoicehead."Bill-to Post Code" + '^' + Salesinvoicehead."Bill-to Country/Region Code" + '^' + CRLF[1];
        HeaderInfo7 := '**A' + '^' + '0' + '^' + '0' + '^' + 'INVOICE TO' + '^' + PartnerGLN + '^^^^^^' + Salesinvoicehead."Bill-to Name" + '^' + Salesinvoicehead."Bill-to Address" + '^' + Salesinvoicehead."Bill-to Address 2" + '^' + Salesinvoicehead."Bill-to City" + '^' + Salesinvoicehead."Bill-to County" + '^' + Salesinvoicehead."Bill-to Post Code" + '^' + Salesinvoicehead."Bill-to Country/Region Code" + '^' + CRLF[1];
        HeaderInfo8 := '**A' + '^' + '0' + '^' + '0' + '^' + 'SHIP TO' + '^' + P_customer.GLN + '^^^^^' + P_customer.GLN + '^' + Salesinvoicehead."Ship-to Name" + '^' + Salesinvoicehead."Ship-to Address" + '^' + Salesinvoicehead."Ship-to Address 2" + '^' + Salesinvoicehead."Ship-to City" + '^' + Salesinvoicehead."Ship-to County" + '^' + Salesinvoicehead."Ship-to Post Code" + '^' + Salesinvoicehead."Ship-to Country/Region Code" + '^' + CRLF[1];
        HeaderInfo9 := '*IS^' + InvNo + '^VAT^E^' + Format(salesinvoiceline."VAT %") + '^' + format(count) + '^' + format(Subtotalgoodsval) + '^' + format(DiscountAmt) + '^' + '0' + '^' + format(Subtotalgoodsval - DiscountAmt) + '^' + Format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(Subtotalgoodsval - DiscountAmt + TotalAmtIncVat - TotalAmtExcVat) + '^^^^' + CRLF[1];
        HeaderInfo10 := '*IT^' + InvNo + '^1^' + Format(count) + '^' + format(Subtotalgoodsval) + '^' + format(DiscountAmt) + '^' + 'N' + '^' + '0' + '^' + format(Subtotalgoodsval - DiscountAmt) + '^' + '0' + '^' + format(Subtotalgoodsval - DiscountAmt) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(Subtotalgoodsval - DiscountAmt + TotalAmtIncVat - TotalAmtExcVat) + '^^^^^^^^' + CRLF[1];
        HeaderInfo11 := '**@' + InvNo + '1     1     ' + Format(count);
        HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo12 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;


        EDIMessage := HeaderInfoAll + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + Salesinvoicehead."No." + '.fif';  //$5000112073.fif
            Clear(tempblob);
            Clear(TextInstream);
            Clear(TextOutstream);
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            //UploadFileToEDIAzureContainer(TextInstream, FileName, StartParameter);
        end;
    end;


    ///////////////////////////////////////Supplier EDI

    procedure GetEDIRecords1() //PO
    var
        NoSeriesMgmt1: Codeunit "No. Series";
        NextNo1: Code[20];
        //Salesinvoicehead: Record "Sales Invoice Header";
        purchHeader: Record "Purchase Header";
        vendor: Record Vendor;
    begin

        vendor.Reset();
        vendor.SetRange("EDI Invoice/Credit", true);
        if vendor.FindSet() then begin
            repeat
                purchHeader.Reset();
                purchHeader.SetRange("Buy-from Vendor No.", vendor."No.");
                purchHeader.SetRange("Document Type", purchHeader."Document Type"::Order);
                if purchHeader.FindSet() then begin
                    repeat
                        ProcessEDIFile1(purchHeader, vendor);
                    until purchHeader.Next() = 0;
                end;
            until vendor.Next() = 0;

        end;
    end;

    procedure ProcessEDIFile1(var purchHeader: Record "Purchase Header"; var P_vendor: Record Vendor)
    var
        //PurchHeader: Record "Purchase Header";
        CompanyInfo: Record "Company Information";
        Purchline: Record "Purchase Line";
        item: Record Item;
        quantityInt: Integer;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        Clear(InvNo);
        Clear(DMYPostingFormat);
        Clear(YearText);
        Clear(MonthText);
        Clear(Dateformat);
        Clear(TimeFormat);
        Clear(TimeStr);
        Clear(TimeText);
        Clear(HeaderInfoAll);
        Clear(HeaderInfo1);
        Clear(HeaderInfo2);
        Clear(HeaderInfo3);
        Clear(HeaderInfo4);
        Clear(HeaderInfo5);
        Clear(HeaderInfo6);
        Clear(HeaderInfo7);
        Clear(HeaderInfo8);
        Clear(HeaderInfo9);
        Clear(HeaderInfo10);
        Clear(HeaderInfo11);
        Clear(quantityInt);

        CompanyInfo.get();

        Dateformat := Date2DMY(PurchHeader."Order Date", 1);
        if Dateformat < 10 then
            DateText := '0' + Format(Dateformat)
        else
            DateText := format(Dateformat);
        Monthformat := Date2DMY(PurchHeader."Order Date", 2);
        if Monthformat < 10 then
            MonthText := '0' + Format(Monthformat)
        else
            MonthText := format(Monthformat);
        Yearformat := Date2DMY(PurchHeader."Order Date", 3);
        YearText := Format(Yearformat);
        DMYPostingFormat := YearText + MonthText + DateText;
        Time1 := DT2Time(PurchHeader.SystemCreatedAt);
        TimeText := Format(Time1, 0, '<Hours24,2><Minutes,2><Seconds,2>');
        InvNo := PurchHeader."No.";
        CompGLN := P_vendor.GLN;
        Curr := PurchHeader."Currency Code";
        RefCurr := P_vendor."Currency Code";
        taxDate := PurchHeader."VAT Reporting Date";
        //TotalAmt := SalesHeader."Amount Including VAT";
        purchHeader.CalcFields("Amount Including VAT", Amount);
        TaxAmount := PurchHeader."Amount Including VAT" - PurchHeader.Amount;
        BuyerRef := PurchHeader."Your Reference";
        Clear(LineInfoAll);
        Clear(count);
        Clear(TotalAmtIncVat);
        Clear(totalqty);
        Purchline.Reset();
        Purchline.SetRange("Document No.", PurchHeader."No.");
        Purchline.SetRange("Document Type", PurchHeader."Document Type");
        Purchline.SetRange(Type, Purchline.Type::Item);
        if Purchline.findset() then begin
            repeat
                Clear(LineInfo1);
                Clear(LineInfo2);
                Clear(LineInfo3);
                Clear(item);
                Clear(gtin);
                Clear(PackSize);
                Clear(Desc);
                item.Reset();
                if item.Get(Purchline."No.") then begin
                    gtin := item.GTIN;
                    PackSize := item."EDI Pack size";
                    Desc := item."EDI Description";
                end;

                count += 1;
                TotalAmtIncVat += Purchline."Amount Including VAT";
                TotalAmtExcVat += Purchline.Amount;
                DiscountAmt += Purchline."Line Discount Amount";
                totalqty += Purchline.Quantity;
                Evaluate(quantityInt, DelChr(Format(Purchline.Quantity), '<=>', ','));
                Evaluate(totalqty1, DelChr(Format(totalqty), '<=>', ','));
                LineInfo1 := '*OL,' + PurchHeader."Your Reference" + ',' + format(count) + ',' + format(Purchline."Line No.") + ',' + Format(quantityInt) + ',,,,' + Format(Purchline.Amount) + ',,,,,,,,,,,,,,,,,' + CRLF[1];
                LineInfo2 := '**P,O,,' + gtin + ',,,,' + Purchline."No." + ',,' + Desc + ',,' + Format(PackSize) + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,' + CRLF[1];
                LineInfo3 := '**V,O,,,,,,,,,,' + CRLF[1];
                LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
            until Purchline.Next() = 0;


            HeaderInfoAll := '';
            HeaderInfo1 := '**!1.02.30GORD' + InvNo + DMYPostingFormat + TimeText + 'C ' + CRLF[1];
            HeaderInfo2 := '**D,' + CompanyInfo."Registration No." + ',' + PurchHeader."Purchaser Code" + ',' + P_vendor."No." + ',ORD,FINAL,N,' + PurchHeader."Your Reference" + ',' + DMYPostingFormat + ',1,,,,,,,,' + CRLF[1];
            HeaderInfo3 := '*OH,' + PurchHeader."Your Reference" + ',' + DMYPostingFormat + ',,,,,,,,' + DMYPostingFormat + ',,,,,,,,,,,,' + CRLF[1];
            HeaderInfo4 := '**A,0,0,COMPANY,' + CompanyInfo.GLN + ',,,,' + PurchHeader."Purchaser Code" + ',,' + CompanyInfo.Name + ',' + CompanyInfo.Address + ',' + CompanyInfo."Address 2" + ',' + CompanyInfo.City + ',' + CompanyInfo.County + ',' + CompanyInfo."Post Code" + ',' + CompanyInfo."Country/Region Code" + ',' + CRLF[1];
            HeaderInfo5 := '**A,0,0,SHIP TO,' + CompanyInfo.GLN + ',,,,' + purchHeader."Purchaser Code" + ',,' + PurchHeader."Ship-to Name" + ',' + PurchHeader."Ship-to Address" + ',' + PurchHeader."Ship-to Address 2" + ',' + PurchHeader."Ship-to City" + ',' + PurchHeader."Ship-to County" + ',' + PurchHeader."Ship-to Post Code" + ',' + PurchHeader."Ship-to Country/Region Code" + ',' + CRLF[1];
            HeaderInfo6 := '**A,0,0,PARTNER,' + P_vendor.GLN + ',,,,,' + PurchHeader."Buy-from Vendor No." + ',' + purchHeader."Buy-from Vendor Name" + ',' + P_vendor.Address + ',' + P_vendor."Address 2" + ',' + P_vendor.City + ',' + P_vendor.County + ',' + P_vendor."Post Code" + ',' + P_vendor."Country/Region Code" + ',' + CRLF[1];
            HeaderInfo10 := '*OT,' + PurchHeader."Your Reference" + ',' + Format(count) + ',' + DelChr(Format(totalqty), '<=>', ',') + CRLF[1];
            HeaderInfo11 := '**@' + InvNo + '1     1     ' + Format(count);
            HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;

        end;
        EDIMessage := HeaderInfoAll + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + purchHeader."No." + '.ord';
            Clear(tempblob);
            Clear(TextInstream);
            Clear(TextOutstream);
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            //UploadFileToEDIAzureContainer(TextInstream, FileName, StartParameter);
        end;
        //end;
    end;

    ////////////////////////////////////////////////////////////////////////////////////////////////

    procedure GetEDIRecords2()
    var
        NoSeriesMgmt: Codeunit "No. Series";
        NextNo: Code[20];
        SalesCrHeader: Record "Sales Cr.Memo Header";
        //salesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin

        Customer.Reset();
        Customer.SetRange("EDI Invoice/Credit", true);
        if Customer.FindSet() then begin
            repeat
                SalesCrHeader.Reset();
                SalesCrHeader.SetRange("Sell-to Customer No.", Customer."No.");
                //SalesCrHeader.SetRange("Document Type", SalesCrHeader."Document Type"::"Credit Memo");
                if SalesCrHeader.FindSet() then begin
                    repeat
                        ProcessEDIFile2(SalesCrHeader, Customer);
                    until SalesCrHeader.Next() = 0;
                end;
            until Customer.Next() = 0;

        end;
        Message('Process Completed Successfully');
    end;

    procedure ProcessEDIFile2(SalesCrHeader: Record "Sales Cr.Memo Header"; var P_customer: Record Customer)
    var
        //SalesHeader: Record "Sales Header";

        CompanyInfo: Record "Company Information";
        salesCRLine: Record "Sales Cr.Memo Line";
        item: Record Item;
        quantityInt: Integer;
        VATPostingSetup: Record "VAT Posting Setup";
        ReturnReason: Record "Return Reason";
        Reason: Record "Reason Code";
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        Clear(InvNo);
        Clear(DMYPostingFormat);
        Clear(YearText);
        Clear(MonthText);
        Clear(Dateformat);
        Clear(TimeFormat);
        Clear(TimeStr);
        Clear(TimeText);
        Clear(HeaderInfoAll);
        Clear(HeaderInfo1);
        Clear(HeaderInfo2);
        Clear(HeaderInfo3);
        Clear(HeaderInfo4);
        Clear(HeaderInfo5);
        Clear(HeaderInfo6);
        Clear(HeaderInfo7);
        Clear(HeaderInfo8);
        Clear(HeaderInfo9);
        Clear(HeaderInfo10);
        Clear(HeaderInfo11);
        clear(TaxCode);
        Clear(ReasonDesc);
        VATPostingSetup.Reset();
        VATPostingSetup.SetRange("VAT Bus. Posting Group", SalesCrHeader."VAT Bus. Posting Group");
        if VATPostingSetup.FindFirst() then begin
            TaxCode := VATPostingSetup."Tax Category";
        end;

        CompanyInfo.get();
        Dateformat := Date2DMY(SalesCrHeader."Posting Date", 1);
        if Dateformat < 10 then
            DateText := '0' + Format(Dateformat)
        else
            DateText := format(Dateformat);
        Monthformat := Date2DMY(SalesCrHeader."Posting Date", 2);
        if Monthformat < 10 then
            MonthText := '0' + Format(Monthformat)
        else
            MonthText := format(Monthformat);
        Yearformat := Date2DMY(SalesCrHeader."Posting Date", 3);
        YearText := Format(Yearformat);
        DMYPostingFormat := YearText + MonthText + DateText;

        //Due Date
        DueDateformat := Date2DMY(SalesCrHeader."Due Date", 1);
        if DueDateformat < 10 then
            DueDateText := '0' + Format(DueDateformat)
        else
            DueDateText := format(DueDateformat);
        DueMonthformat := Date2DMY(SalesCrHeader."Due Date", 2);
        if DueMonthformat < 10 then
            DueMonthText := '0' + Format(DueMonthformat)
        else
            DueMonthText := format(DueMonthformat);
        DueYearformat := Date2DMY(SalesCrHeader."Due Date", 3);
        DueYearText := Format(DueYearformat);
        DMYDueDateFormat := DueYearText + DueMonthText + DueDateText;

        Reason.Reset();
        Reason.SetRange(Code, SalesCrHeader."Reason Code");
        if Reason.FindFirst() then begin
            ReasonDesc := Reason.Description;
        end;
        Time1 := DT2Time(SalesCrHeader.SystemCreatedAt);
        TimeText := Format(Time1, 0, '<Hours24,2><Minutes,2><Seconds,2>');
        InvNo := SalesCrHeader."No.";
        CompGLN := P_customer.GLN;
        Curr := SalesCrHeader."Currency Code";
        RefCurr := P_customer."Currency Code";
        taxDate := SalesCrHeader."VAT Reporting Date";
        //TotalAmt := SalesHeader."Amount Including VAT";
        SalesCrHeader.CalcFields("Amount Including VAT", Amount);
        TaxAmount := SalesCrHeader."Amount Including VAT" - SalesCrHeader.Amount;
        BuyerRef := SalesCrHeader."Your Reference";

        Clear(LineInfoAll);
        Clear(count);
        Clear(TotalAmtIncVat);

        salesCRLine.Reset();
        salesCRLine.SetRange("Document No.", SalesCrHeader."No.");
        //salesline.SetRange("Document Type", SalesCrHeader."Document Type");
        salesCRLine.SetRange(Type, salesCRLine.Type::Item);
        if salesCRLine.findset() then begin
            repeat
                clear(TaxCodeLine);
                VATPostingSetup.Reset();
                VATPostingSetup.SetRange("VAT Bus. Posting Group", SalesCrHeader."VAT Bus. Posting Group");
                VATPostingSetup.SetRange("VAT Prod. Posting Group", salesCRLine."VAT Prod. Posting Group");
                if VATPostingSetup.FindFirst() then begin
                    TaxCodeLine := VATPostingSetup."Tax Category";
                end;

                Clear(ReturnReasonDesc);
                ReturnReason.Reset();
                ReturnReason.SetRange(Code, salesCRLine."Return Reason Code");
                if ReturnReason.FindFirst() then begin
                    ReturnReasonDesc := ReturnReason.Description;
                end;
                Clear(LineInfo1);
                Clear(LineInfo2);
                Clear(LineInfo3);
                Clear(item);
                Clear(gtin);
                Clear(PackSize);
                Clear(Desc);

                item.Reset();
                if item.Get(salesCRLine."No.") then begin
                    gtin := item.GTIN;
                    PackSize := item."EDI Pack size";
                    Desc := item."EDI Description";
                end;

                count += 1;
                TotalAmtIncVat += salesCRLine."Amount Including VAT";
                TotalAmtExcVat += salesCRLine.Amount;
                TaxAmount := SalesCrHeader."Amount Including VAT" - SalesCrHeader.Amount;
                DiscountAmt += salesCRLine."Line Discount Amount";
                totalqty += salesCRLine.Quantity;
                Evaluate(quantityInt, DelChr(Format(salesCRLine.Quantity), '<=>', ','));
                LineInfo1 := '*CL,' + SalesCrHeader."Your Reference" + ',' + format(count) + ',,,,,,,,,,' + salesCRLine."Return Reason Code" + ',,' + ReturnReasonDesc + ',' + Format(quantityInt) + ',,,' + format(salesCRLine."Unit Price") + ',' + Format(quantityInt * salesCRLine."Unit Price") + ',VAT,' + 'E' + ',N,' + format(salesCRLine."Line Discount %") + ',,' + CRLF[1];
                LineInfo2 := '**P,O,,' + gtin + ',,,,,,' + Desc + ',,' + Format(PackSize) + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,' + CRLF[1];
                LineInfo3 := '**G,O,' + Format(salesCRLine.Amount) + ',,,,,,,,,,,,,' + CRLF[1];
                LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
            until salesCRLine.Next() = 0;

            HeaderInfoAll := '';
            HeaderInfo1 := '**!1.02.30GCRN0000' + InvNo + DMYPostingFormat + TimeText + 'C ' + CRLF[1];
            HeaderInfo2 := '**D,' + CompanyInfo."Registration No." + ',,' + ',CRN,,O,' + SalesCrHeader."No." + ',' + DMYPostingFormat + ',1,,,,,,,,' + CRLF[1];
            HeaderInfo3 := '*CH,' + SalesCrHeader."Your Reference" + ',' + DMYPostingFormat + ',,,,,,,,,,' + SalesCrHeader."Reason Code" + ',,' + ReasonDesc + ',' + format(TotalAmtExcVat) + ',' + format(TaxAmount) + ',,,B,,INVOICE,' + CRLF[1];
            HeaderInfo4 := '*IH,' + SalesCrHeader."Applies-to Doc. No." + ',' + DMYPostingFormat + ',' + DMYPostingFormat + ',,,' + DMYDueDateFormat + ',,,,,,,,,,,,' + CRLF[1];
            HeaderInfo5 := '*DH,' + SalesCrHeader."External Document No." + ',' + DMYPostingFormat + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,' + CRLF[1];
            HeaderInfo6 := '*OH,' + SalesCrHeader."Your Reference" + ',' + DMYPostingFormat + ',,,,,,,,,,,,,,,,,,,,' + CRLF[1];
            HeaderInfo7 := '**A,0,0,PARTNER,' + CompGLN + ',,,,,,' + SalesCrHeader."Sell-to Customer Name" + ',' + SalesCrHeader."Sell-to Address" + ',' + SalesCrHeader."Sell-to Address 2" + ',' + SalesCrHeader."Sell-to City" + ',' + SalesCrHeader."Sell-to County" + ',' + SalesCrHeader."Sell-to Post Code" + ',' + SalesCrHeader."Sell-to Country/Region Code" + ',' + CRLF[1];
            HeaderInfo8 := '**A,0,0,SHIP TO,' + CompanyInfo.GLN + ',,,,' + SalesCrHeader."Salesperson Code" + ',,' + SalesCrHeader."Ship-to Name" + ',' + SalesCrHeader."Ship-to Address" + ',' + SalesCrHeader."Ship-to Address 2" + ',' + SalesCrHeader."Ship-to City" + ',' + SalesCrHeader."Ship-to County" + ',' + SalesCrHeader."Ship-to Post Code" + ',' + SalesCrHeader."Ship-to Country/Region Code" + ',' + CRLF[1];
            HeaderInfo9 := '*CS,' + SalesCrHeader."Your Reference" + ',VAT,' + 'E' + ',' + format(SalesCrHeader."VAT Base Discount %") + ',' + format(count) + ',' + format(TotalAmtExcVat) + ',0.00,0.00,' + format(TotalAmtExcVat) + ',' + Format(TaxAmount) + ',' + Format(TotalAmtIncVat) + ',' + CRLF[1];
            HeaderInfo10 := '*CT,' + SalesCrHeader."Your Reference" + ',1,' + Format(count) + ',' + format(TotalAmtExcVat) + ',0.00,N,0.00,' + format(TotalAmtExcVat) + ',0.00,' + format(TotalAmtExcVat) + ',' + Format(TaxAmount) + ',' + Format(TotalAmtIncVat) + ',' + Format(TaxAmount) + ',,,,' + CRLF[1];
            HeaderInfo11 := '**@0000' + InvNo + '1     1     ' + Format(count);
            HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;


            EDIMessage := HeaderInfoAll + EDIMessage;
            if EDIMessage <> '' then begin
                FileName := '$' + SalesCrHeader."No." + '.crn';
                Clear(tempblob);
                Clear(TextInstream);
                Clear(TextOutstream);
                tempblob.CreateOutStream(TextOutstream);
                TextOutstream.WriteText(EDIMessage);
                tempblob.CreateInStream(TextInstream);
                DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
                // UploadFileToEDIAzureContainer(TextInstream, FileName, StartParameter);
            end;
        end;
    end;

    procedure GetEDIRecords3()
    var
        NoSeriesMgmt1: Codeunit "No. Series";
        NextNo1: Code[20];
        //Salesinvoicehead: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        customer: Record Customer;
    begin


        Customer.Reset();
        Customer.SetRange("EDI Invoice/Credit", true);
        if customer.FindSet() then begin
            repeat
                salesHeader.Reset();
                salesHeader.SetRange("Sell-to Customer No.", customer."No.");
                salesHeader.SetRange("Document Type", salesHeader."Document Type"::Order);
                if salesHeader.FindSet() then begin
                    repeat
                        ProcessEDIFile3(salesHeader, customer);
                    until salesHeader.Next() = 0;
                end;
            until customer.Next() = 0;

        end;
    end;

    procedure ProcessEDIFile3(var salesHeader: Record "Sales Header"; var P_customer: Record Customer)
    var
        //PurchHeader: Record "Purchase Header";
        CompanyInfo: Record "Company Information";
        salesline: Record "Sales Line";
        item: Record Item;
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        Clear(InvNo);
        Clear(DMYPostingFormat);
        Clear(YearText);
        Clear(MonthText);
        Clear(Dateformat);
        Clear(TimeFormat);
        Clear(TimeStr);
        Clear(TimeText);
        Clear(HeaderInfoAll);
        Clear(HeaderInfo1);
        Clear(HeaderInfo2);
        Clear(HeaderInfo3);
        Clear(HeaderInfo4);
        Clear(HeaderInfo5);
        Clear(HeaderInfo6);
        Clear(HeaderInfo7);
        Clear(HeaderInfo8);
        Clear(HeaderInfo9);
        Clear(HeaderInfo10);
        Clear(HeaderInfo11);

        CompanyInfo.get();

        Dateformat := Date2DMY(salesHeader."Order Date", 1);
        if Dateformat < 10 then
            DateText := '0' + Format(Dateformat)
        else
            DateText := format(Dateformat);
        Monthformat := Date2DMY(salesHeader."Order Date", 2);
        if Monthformat < 10 then
            MonthText := '0' + Format(Monthformat)
        else
            MonthText := format(Monthformat);
        Yearformat := Date2DMY(salesHeader."Order Date", 3);
        YearText := Format(Yearformat);
        DMYPostingFormat := YearText + MonthText + DateText;
        Time1 := DT2Time(salesHeader.SystemCreatedAt);
        TimeText := Format(Time1, 0, '<Hours24,2><Minutes,2><Seconds,2>');
        InvNo := salesHeader."No.";
        CompGLN := P_customer.GLN;
        Curr := salesHeader."Currency Code";
        RefCurr := P_customer."Currency Code";
        taxDate := salesHeader."VAT Reporting Date";
        //TotalAmt := SalesHeader."Amount Including VAT";
        salesHeader.CalcFields("Amount Including VAT", Amount);
        TaxAmount := salesHeader."Amount Including VAT" - salesHeader.Amount;
        BuyerRef := salesHeader."Your Reference";
        Clear(LineInfoAll);
        Clear(count);
        Clear(TotalAmtIncVat);
        salesline.Reset();
        salesline.SetRange("Document No.", salesHeader."No.");
        salesline.SetRange("Document Type", salesHeader."Document Type");
        salesline.SetRange(Type, salesline.Type::Item);
        if salesline.findset() then begin
            repeat
                Clear(LineInfo1);
                Clear(LineInfo2);
                Clear(LineInfo3);
                Clear(item);
                Clear(gtin);
                Clear(PackSize);
                Clear(Desc);
                item.Reset();
                if item.Get(salesline."No.") then begin
                    gtin := item.GTIN;
                    PackSize := item."EDI Pack size";
                    Desc := item."EDI Description";

                end;
                Clear(totalqty);
                count += 1;
                TotalAmtIncVat += salesline."Amount Including VAT";
                TotalAmtExcVat += salesline.Amount;
                totalqty += salesline.Quantity;
                DiscountAmt += salesline."Line Discount Amount";
                LineInfo1 := '*OL,' + salesHeader."Your Reference" + ',' + format(count) + ',' + format(salesline."Line No.") + ',' + format(salesline.Quantity) + ',,,,,,,,,,,,' + CRLF[1];
                LineInfo2 := '**P,O,,,' + gtin + ',,,' + salesline."No." + ',' + Desc + ',,' + Format(PackSize) + ',,,,,,,,,,,,,,,,,,,,,' + CRLF[1];
                LineInfo3 := '**V,O,,,,,,,,,,' + CRLF[1];
                LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
            until salesline.Next() = 0;


            HeaderInfoAll := '';
            HeaderInfo1 := '**!1.01.01GORD    ' + InvNo + DMYPostingFormat + TimeText + 'C ' + CRLF[1];
            HeaderInfo2 := '**D,' + CompanyInfo."Registration No." + ',' + salesHeader."Salesperson Code" + ',' + P_customer."No." + ',ORD,FINAL,N,' + salesHeader."Your Reference" + ',' + DMYPostingFormat + ',1,,,,' + CRLF[1];
            //HeaderInfo3 := '**IH' + '^' + InvNo + '^' + DMYPostingFormat + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + format(TotalAmtIncVat) + '^' + format(TaxAmount) + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + CRLF[1];
            HeaderInfo3 := '*OH,' + salesHeader."Your Reference" + ',' + DMYPostingFormat + ',,,,,,,,' + DMYPostingFormat + ',,,,' + CRLF[1];

            HeaderInfo4 := '**A,0,0,COMPANY,' + CompanyInfo.GLN + ',,,,' + salesHeader."Salesperson Code" + ',' + CompanyInfo.Name + ',' + CompanyInfo.Address + ',' + CompanyInfo."Address 2" + ',' + CompanyInfo.City + ',' + CompanyInfo.County + ',' + CompanyInfo."Post Code" + ',' + CompanyInfo."Country/Region Code" + ',' + CRLF[1];
            HeaderInfo5 := '**A,0,0,SHIP TO,' + P_customer.GLN + ',,,,' + salesHeader."Ship-to Name" + ',' + salesHeader."Ship-to Address" + ',' + salesHeader."Ship-to Address 2" + ',' + salesHeader."Ship-to City" + ',' + salesHeader."Ship-to County" + ',' + salesHeader."Ship-to Post Code" + ',' + salesHeader."Ship-to Country/Region Code" + ',' + CRLF[1];
            HeaderInfo6 := '**A,0,0,PARTNER,' + P_customer.GLN + ',,,,,' + salesHeader."Salesperson Code" + ',' + P_customer.Name + ',' + P_customer.Address + ',' + P_customer."Address 2" + ',' + P_customer.City + ',' + P_customer.County + ',' + P_customer."Post Code" + ',' + P_customer."Country/Region Code" + ',' + CRLF[1];
            //HeaderInfo7 := '**A' + '^' + '0' + '^' + '0' + '^' + 'INVOICE' + '^' + CompGLN + '^^^^^^' + PurchHeader.buy + '^' + PurchHeader."Bill-to Address" + '^' + PurchHeader."Bill-to Address 2" + '^' + PurchHeader."Bill-to City" + '^' + PurchHeader."Bill-to County" + '^' + PurchHeader."Bill-to Post Code" + '^' + PurchHeader."Bill-to Country/Region Code" + '^' + CRLF[1];
            //HeaderInfo9 := '*IS^' + InvNo + '^VAT^E^0^' + format(count) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + format(DiscountAmt) + '^' + format(TotalAmtIncVat) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(TotalAmtIncVat) + CRLF[1];
            HeaderInfo10 := '*OT,' + salesHeader."Your Reference" + ',' + Format(count) + ',' + format(totalqty) + CRLF[1];
            HeaderInfo11 := '**@     ' + InvNo + '     1    ';
            HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;

        end;
        EDIMessage := HeaderInfoAll + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + salesHeader."No." + '.fif';
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            // DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            UploadFileToEDIAzureContainer(TextInstream, FileName, TradepartnerRecord.Code);

        end;
        //end;
    end;

    local procedure UploadFileToEDIAzureContainer(var P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
    var
        Authorization: Interface "Storage Service Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSBlobClient: Codeunit "ABS Blob Client";
        Response: Codeunit "ABS Operation Response";

    begin
        GetCredentials(P_ChannelCode);
        Clear(Authorization);
        Clear(StorageServiceAuthorization);
        Authorization := StorageServiceAuthorization.CreateSharedKey(SharedAccessKey);

        Clear(ABSBlobClient);
        ABSBlobClient.Initialize(StorageAccountName, OutgoingContainerName, Authorization);

        Clear(Response);
        Response := ABSBlobClient.PutBlobBlockBlobStream(P_FileName, P_FileInstream);
    end;

    local procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            OutgoingContainerName := TradePartner."Order Acknow. Container Name";
            StorageAccountName := TradePartner."Storage Account Name";
            SharedAccessKey := TradePartner."Shared Access Key";

        End;
    end;
    ///old
    // procedure UploadFileTOAzureBlob(P_FileInstream: InStream; P_FileName: Text; P__ChannelCode: Code[20])
    // var
    //     fileMgt: Codeunit "File Management";
    //     L_httpResponse: HttpResponseMessage;
    //     L_httpHeader: HttpHeaders;
    //     apiEndPoint: Text;
    //     containerName: Text;
    //     filename: Text;
    //     sasToken: text;
    //     apiUrl: Text;
    //     L_httpClient: HttpClient;
    //     L_httpContent: HttpContent;
    //     apiattribute: Text;
    //     TradePartner: Record "Trade Partner";
    // begin
    //     //Upload++
    //     ClearLastError();
    //     Clear(L_httpContent);
    //     Clear(L_httpHeader);
    //     Clear(apiEndPoint);
    //     Clear(containerName);
    //     Clear(filename);
    //     Clear(sasToken);
    //     Clear(L_httpClient);
    //     Clear(L_httpResponse);
    //     L_httpContent.WriteFrom(P_FileInstream);
    //     L_httpContent.GetHeaders(L_httpHeader);

    //     L_httpHeader.Remove('Content-Type');
    //     L_httpHeader.Add('x-ms-version', '2015-02-21');
    //     L_httpHeader.Add('x-ms-date', '2015-02-21');
    //     L_httpHeader.Add('x-ms-blob-type', 'BlockBlob');
    //     L_httpHeader.Add('Content-Type', 'application/octet-stream');

    //     TradePartner.Reset();
    //     TradePartner.SetRange(Code, P__ChannelCode);
    //     if TradePartner.FindFirst() then begin
    //         apiEndPoint := TradePartner."API Endpoint";
    //         containerName := TradePartner."Order Acknow. Container Name";
    //         sasToken := TradePartner."Order Acknow. Container Token";
    //     end;

    //     // apiEndPoint := 'https://shopdirect.blob.core.windows.net';
    //     // containerName := 'teststupdin';
    //     // sasToken := 'sp=racwl&st=2021-06-18T09:59:46Z&se=2021-07-30T17:59:46Z&spr=https&sv=2020-02-10&sr=c&sig=GMoLncjHNc0eY2KCSDN%2BnVw819%2FmQJdKmp5ZamBst5k%3D';

    //     apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
    //     L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
    //     if L_httpResponse.HttpStatusCode = 201 then
    //         Message('file uploaded successfully.');
    //     //Upload--
    // end;

    var
        CRLF: Text[2];
        SalesInvoiceLine: Record "Sales Invoice Line";
        myInt: Integer;
        ExportTextHeader: Text;
        ExportTextLine: Text;
        HeaderInfoAll: Text;
        HeaderInfo1: Text;
        HeaderInfo2: Text;
        HeaderInfo3: Text;
        HeaderInfo4: Text;
        HeaderInfo5: Text;
        HeaderInfo6: Text;
        HeaderInfo7: Text;
        HeaderInfo8: Text;
        HeaderInfo9: Text;
        HeaderInfo10: Text;
        HeaderInfo11: Text;
        HeaderInfo12: Text;
        LineInfoAll: Text;
        LineInfo1: Text;
        LineInfo2: Text;
        LineInfo3: Text;
        TextInstream: InStream;
        TextOutstream: OutStream;
        EDIMessage: Text;
        tempblob: Codeunit "Temp Blob";
        SalesInvoiceHeader: Record "Sales Invoice Header";

        FileName: Text;
        Dateformat: Integer;
        DueDateformat: Integer;
        Monthformat: Integer;
        DueMonthformat: Integer;
        Yearformat: Integer;
        DueYearformat: Integer;
        DMYPostingFormat: Text;
        DMYDueDateFormat: Text;
        DMYShipmentFormat: Text;
        YearText: Text;
        DueYearText: Text;
        MonthText: Text;
        DueMonthText: Text;
        DateText: Text;
        DueDateText: Text;
        TimeFormat: Text;
        TimeText: Text;
        TimeStr: Text;
        InvNo: Code[20];
        Datetime1: DateTime;
        Time1: Time;
        CompGLN: Code[20];
        PartnerGLN: Code[20];
        Curr: Code[20];
        RefCurr: Code[20];
        taxDate: Date;
        TotalAmtIncVat: Decimal;
        TotalAmtExcVat: Decimal;
        DiscountAmt: Decimal;
        TaxAmount: Decimal;
        BuyerRef: Text;
        count: Integer;
        gtin: Code[20];
        EDICustomerLabel: Label 'EDICustomer';
        EDISupplierLabel: Label 'EDISupplier';
        EDICrMemoLabel: Label 'EDICrMemo';
        EDISalesOrderLabel: Label 'EDISalesOrder';
        EDILabel: Label 'EDI';
        StartParameter: Text;
        RunType: Text;
        TradepartnerRecord: Record "Trade Partner";
        PackSize: Decimal;
        Desc: text[40];
        Subtotalgoodsval: Decimal;
        totalqty: Decimal;
        totalqty1: Decimal;
        TaxCode: Code[10];
        TaxCodeLine: Code[10];
        OutgoingContainerName: Text;
        OutgoingSasToken: Text;
        StorageAccountName: Text;
        SharedAccessKey: SecretText;
        ArchiveContainerName: Text;
        PaymentTermDays: Integer;
        totalVatBaseAmt: Decimal;
        ReturnReasonDesc: Text[100];
        ReasonDesc: Text[100];
}