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
        end;
    end;
    //Customer EDI
    procedure GetEDIRecords()
    var
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        NextNo: Code[20];
        Salesinvoicehead: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin

        Customer.Reset();
        Customer.SetRange("EDI Invoice/Credit", true);
        if Customer.FindSet() then begin
            repeat
                salesHeader.Reset();
                salesHeader.SetRange("Sell-to Customer No.", Customer."No.");
                salesHeader.SetRange("Document Type", salesHeader."Document Type"::Invoice);
                if salesHeader.FindFirst() then begin
                    NextNo := NoSeriesMgmt.GetNextNo(salesHeader."No. Series", WorkDate(), true);
                    ProcessEDIFile(NextNo, Customer);

                end;
            until Customer.Next() = 0;

        end;
    end;

    local procedure ProcessEDIFile(NextNo: Code[20]; var P_customer: Record Customer)
    var
        SalesHeader: Record "Sales Header";

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
        SalesHeader.Reset();
        SalesHeader.SetRange("sell-to Customer No.", P_customer."No.");
        salesHeader.SetRange("Document Type", salesHeader."Document Type"::Invoice);
        if SalesHeader.FindSet() then begin
            Dateformat := Date2DMY(SalesHeader."Order Date", 1);
            if Dateformat < 10 then
                DateText := '0' + Format(Dateformat)
            else
                DateText := format(Dateformat);
            Monthformat := Date2DMY(SalesHeader."Order Date", 2);
            if Monthformat < 10 then
                MonthText := '0' + Format(Monthformat)
            else
                MonthText := format(Monthformat);
            Yearformat := Date2DMY(SalesHeader."Order Date", 3);
            YearText := Format(Yearformat);
            DMYPostingFormat := YearText + MonthText + DateText;
            Time1 := DT2Time(SalesHeader.SystemCreatedAt);
            TimeText := Format(Time1, 0, '<Hours24,2><Minutes,2><Seconds,2>');
            InvNo := SalesHeader."No.";
            CompGLN := P_customer.GLN;
            Curr := SalesHeader."Currency Code";
            RefCurr := P_customer."Currency Code";
            taxDate := SalesHeader."VAT Reporting Date";
            //TotalAmt := SalesHeader."Amount Including VAT";
            TaxAmount := SalesHeader."Amount Including VAT" - SalesHeader.Amount;
            BuyerRef := SalesHeader."Your Reference";
            Clear(LineInfoAll);
            Clear(count);
            Clear(TotalAmtIncVat);
            salesline.Reset();
            salesline.SetRange("Document No.", SalesHeader."No.");
            salesline.SetRange("Document Type", SalesHeader."Document Type");
            salesline.SetRange(Type, salesline.Type::Item);
            if salesline.findset() then begin
                repeat
                    Clear(LineInfo1);
                    Clear(LineInfo2);
                    Clear(LineInfo3);
                    Clear(item);
                    Clear(gtin);
                    item.Reset();
                    if item.Get(salesline."No.") then begin
                        gtin := item.GTIN;
                    end;
                    count += 1;
                    TotalAmtIncVat += salesline."Amount Including VAT";
                    TotalAmtExcVat += salesline.Amount;
                    DiscountAmt += salesline."Line Discount Amount";
                    LineInfo1 := '**IL' + '^' + InvNo + '^' + format(count) + '^' + BuyerRef + '^' + DMYPostingFormat + '^' + format(salesline.Quantity) + '^' + '2' + '^' + format(salesline."Amount Including VAT") + '^' + Format(salesline.Amount) + '^' + 'VAT' + '^' + 'E' + '^' + 'N' + '^' + format(salesline."VAT %") + '^' + format(salesline."Amount Including VAT" - salesline.Amount) + '^^^' + CRLF[1];
                    LineInfo2 := '**P' + '^' + 'O' + '^' + salesline."No." + '^' + gtin + '^^^^^^' + salesline.Description + '^' + '1' + '^^^^^^^^^^^^^^^^^^^^^^^^^' + CRLF[1];
                    LineInfo3 := '**G^O^' + format(salesline."Amount Including VAT") + '^' + Format(salesline.Amount) + '^^^^^^^' + CRLF[1];
                    LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
                until salesline.Next() = 0;

            end;
            HeaderInfoAll := '';
            HeaderInfo1 := '**!' + '1.01.01' + 'G' + 'INV' + '0000' + InvNo + DMYPostingFormat + TimeText + 'D' + '^' + CRLF[1];
            HeaderInfo2 := '**D' + '^' + CompanyInfo."Registration No." + '^' + '^' + CompanyInfo.GLN + '^' + 'INV' + '^' + '^' + 'N' + '^' + InvNo + DMYPostingFormat + '^' + '1' + '^' + '^' + '^' + RefCurr + '^' + RefCurr + CRLF[1];
            HeaderInfo3 := '**IH' + '^' + InvNo + '^' + DMYPostingFormat + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + format(TotalAmtIncVat) + '^' + format(TaxAmount) + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + CRLF[1];
            HeaderInfo4 := '**OH' + '^' + BuyerRef + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + CRLF[1];
            HeaderInfo5 := '**A' + '^' + '0' + '^' + '0' + '^' + 'COMPANY' + '^' + CompanyInfo.GLN + '^^^^^' + CompanyInfo.GLN + '^' + CompanyInfo.Name + '^' + CompanyInfo.Address + '^' + CompanyInfo."Address 2" + '^' + CompanyInfo.City + '^' + CompanyInfo.County + '^' + CompanyInfo."Post Code" + '^' + CompanyInfo."Country/Region Code" + '^' + CRLF[1];
            HeaderInfo6 := '**A' + '^' + '0' + '^' + '0' + '^' + 'PARTNER' + '^^^^^' + P_customer.Name + '^' + P_customer.Address + '^' + P_customer."Address 2" + '^' + P_customer.City + '^' + P_customer.County + '^' + P_customer."Post Code" + '^' + P_customer."Country/Region Code" + '^' + CRLF[1];
            HeaderInfo7 := '**A' + '^' + '0' + '^' + '0' + '^' + 'INVOICE' + '^' + CompGLN + '^^^^^^' + SalesHeader."Bill-to Name" + '^' + SalesHeader."Bill-to Address" + '^' + SalesHeader."Bill-to Address 2" + '^' + SalesHeader."Bill-to City" + '^' + SalesHeader."Bill-to County" + '^' + SalesHeader."Bill-to Post Code" + '^' + SalesHeader."Bill-to Country/Region Code" + '^' + CRLF[1];
            HeaderInfo8 := '**A' + '^' + '0' + '^' + '0' + '^' + 'SHIP TO' + '^' + P_customer.GLN + '^^^^^' + P_customer.GLN + '^' + SalesHeader."Ship-to Name" + '^' + SalesHeader."Ship-to Address" + '^' + SalesHeader."Ship-to Address 2" + '^' + SalesHeader."Ship-to City" + '^' + SalesHeader."Ship-to County" + '^' + SalesHeader."Ship-to Post Code" + '^' + SalesHeader."Ship-to Country/Region Code" + '^' + CRLF[1];
            HeaderInfo9 := '*IS^' + InvNo + '^VAT^E^0^' + format(count) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + format(DiscountAmt) + '^' + format(TotalAmtIncVat) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(TotalAmtIncVat) + CRLF[1];
            HeaderInfo10 := '*IT^' + InvNo + '^1^' + Format(count) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + 'N' + '^' + format(DiscountAmt) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + format(TotalAmtIncVat) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(TotalAmtIncVat) + CRLF[1];
            HeaderInfo11 := '**@0000' + InvNo + '1' + '     1';
            HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;

        end;
        EDIMessage := HeaderInfoAll + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + NextNo + '.fif';
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            UploadFileTOAzureBlob(TextInstream, FileName, TradepartnerRecord.Code);
        end;
    end;


    ///////////////////////////////////////Supplier EDI

    procedure GetEDIRecords1()
    var
        NoSeriesMgmt1: Codeunit NoSeriesManagement;
        NextNo1: Code[20];
        //Salesinvoicehead: Record "Sales Invoice Header";
        purchHeader: Record "Purchase Header";
        vendor: Record Vendor;
    begin

        vendor.Reset();
        if vendor.FindSet() then begin
            repeat
                purchHeader.Reset();
                purchHeader.SetRange("Buy-from Vendor No.", vendor."No.");
                purchHeader.SetRange("Document Type", purchHeader."Document Type"::Invoice);
                if purchHeader.FindFirst() then begin
                    NextNo1 := NoSeriesMgmt1.GetNextNo(purchHeader."No. Series", WorkDate(), true);
                    ProcessEDIFile1(NextNo1, vendor);

                end;
            until vendor.Next() = 0;

        end;
    end;

    local procedure ProcessEDIFile1(NextNo: Code[20]; var P_vendor: Record Vendor)
    var
        PurchHeader: Record "Purchase Header";
        CompanyInfo: Record "Company Information";
        Purchline: Record "Purchase Line";
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
        PurchHeader.Reset();
        PurchHeader.SetRange("Buy-from Vendor No.", P_vendor."No.");
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        //if P_vendor."EDI Invoice/Credit" = true then begin
        if PurchHeader.FindSet() then begin
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
            TaxAmount := PurchHeader."Amount Including VAT" - PurchHeader.Amount;
            BuyerRef := PurchHeader."Your Reference";
            Clear(LineInfoAll);
            Clear(count);
            Clear(TotalAmtIncVat);
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
                    item.Reset();
                    if item.Get(Purchline."No.") then begin
                        gtin := item.GTIN;
                    end;
                    count += 1;
                    TotalAmtIncVat += Purchline."Amount Including VAT";
                    TotalAmtExcVat += Purchline.Amount;
                    DiscountAmt += Purchline."Line Discount Amount";
                    LineInfo1 := '**OL,' + PurchHeader."Your Reference" + ',' + format(count) + ',' + format(Purchline."Line No.") + ',' + format(Purchline.Quantity) + ',,,,,,,,,,,,' + CRLF[1];
                    LineInfo2 := '**P,O,,,' + gtin + ',,,' + Purchline."No." + ',' + Purchline.Description + ',,' + format(Purchline.Quantity) + ',,,,,,,,,,,,,,,,,,,,,' + CRLF[1];
                    LineInfo3 := '**V,O,,,,,,,,,,' + CRLF[1];
                    LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
                until Purchline.Next() = 0;

            end;
            HeaderInfoAll := '';
            HeaderInfo1 := '**!1.01.01GORD    ' + InvNo + DMYPostingFormat + TimeText + 'C ' + CRLF[1];
            HeaderInfo2 := '**D,' + CompanyInfo."Registration No." + ',' + PurchHeader."Purchaser Code" + ',' + P_vendor."No." + 'ORD,FINAL,N,' + PurchHeader."Your Reference" + ',' + DMYPostingFormat + ',1,,,,' + CRLF[1];
            //HeaderInfo3 := '**IH' + '^' + InvNo + '^' + DMYPostingFormat + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + format(TotalAmtIncVat) + '^' + format(TaxAmount) + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + CRLF[1];
            HeaderInfo3 := '**OH,' + PurchHeader."Your Reference" + ',' + DMYPostingFormat + ',,,,,,,,' + DMYPostingFormat + ',,,,' + CRLF[1];

            HeaderInfo4 := '**A,0,0,COMPANY,' + CompanyInfo.GLN + ',,,,' + PurchHeader."Purchaser Code" + ',' + CompanyInfo.Name + ',' + CompanyInfo.Address + ',' + CompanyInfo."Address 2" + ',' + CompanyInfo.City + ',' + CompanyInfo.County + ',' + CompanyInfo."Post Code" + ',' + CompanyInfo."Country/Region Code" + ',' + CRLF[1];
            HeaderInfo5 := '**A,0,0,SHIP TO,' + P_vendor.GLN + ',,,,' + PurchHeader."Ship-to Name" + ',' + PurchHeader."Ship-to Address" + ',' + PurchHeader."Ship-to Address 2" + ',' + PurchHeader."Ship-to City" + ',' + PurchHeader."Ship-to County" + ',' + PurchHeader."Ship-to Post Code" + ',' + PurchHeader."Ship-to Country/Region Code" + ',' + CRLF[1];
            HeaderInfo6 := '**A,0,0,PARTNER,' + P_vendor.GLN + ',,,,,' + PurchHeader."Purchaser Code" + ',' + P_vendor.Name + ',' + P_vendor.Address + ',' + P_vendor."Address 2" + ',' + P_vendor.City + ',' + P_vendor.County + ',' + P_vendor."Post Code" + ',' + P_vendor."Country/Region Code" + ',' + CRLF[1];
            //HeaderInfo7 := '**A' + '^' + '0' + '^' + '0' + '^' + 'INVOICE' + '^' + CompGLN + '^^^^^^' + PurchHeader.buy + '^' + PurchHeader."Bill-to Address" + '^' + PurchHeader."Bill-to Address 2" + '^' + PurchHeader."Bill-to City" + '^' + PurchHeader."Bill-to County" + '^' + PurchHeader."Bill-to Post Code" + '^' + PurchHeader."Bill-to Country/Region Code" + '^' + CRLF[1];
            //HeaderInfo9 := '*IS^' + InvNo + '^VAT^E^0^' + format(count) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + format(DiscountAmt) + '^' + format(TotalAmtIncVat) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(TotalAmtIncVat) + CRLF[1];
            HeaderInfo10 := '*OT,' + PurchHeader."Your Reference" + ',' + Format(count) + ',' + format(Purchline.Quantity) + CRLF[1];
            HeaderInfo11 := '**@      ' + InvNo + '     1    ';
            HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;

        end;
        EDIMessage := HeaderInfoAll + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + NextNo + '.fif';
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            UploadFileTOAzureBlob(TextInstream, FileName, TradepartnerRecord.Code);
        end;
        //end;
    end;

    ////////////////////////////////////////////////////////////////////////////////////////////////

    procedure GetEDIRecords2()
    var
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        NextNo: Code[20];
        Salesinvoicehead: Record "Sales Invoice Header";
        salesHeader: Record "Sales Header";
        Customer: Record Customer;
    begin

        Customer.Reset();
        Customer.SetRange("EDI Invoice/Credit", true);
        if Customer.FindSet() then begin
            repeat
                salesHeader.Reset();
                salesHeader.SetRange("Sell-to Customer No.", Customer."No.");
                salesHeader.SetRange("Document Type", salesHeader."Document Type"::"Credit Memo");
                if salesHeader.FindSet() then begin
                    repeat
                        ProcessEDIFile2(salesHeader, Customer);
                    until salesHeader.Next() = 0;
                end;
            until Customer.Next() = 0;

        end;
        Message('Process Completed Successfully');
    end;

    local procedure ProcessEDIFile2(var salesHeader: Record "Sales Header"; var P_customer: Record Customer)
    var
        //SalesHeader: Record "Sales Header";

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
        Dateformat := Date2DMY(SalesHeader."Order Date", 1);
        if Dateformat < 10 then
            DateText := '0' + Format(Dateformat)
        else
            DateText := format(Dateformat);
        Monthformat := Date2DMY(SalesHeader."Order Date", 2);
        if Monthformat < 10 then
            MonthText := '0' + Format(Monthformat)
        else
            MonthText := format(Monthformat);
        Yearformat := Date2DMY(SalesHeader."Order Date", 3);
        YearText := Format(Yearformat);
        DMYPostingFormat := YearText + MonthText + DateText;
        Time1 := DT2Time(SalesHeader.SystemCreatedAt);
        TimeText := Format(Time1, 0, '<Hours24,2><Minutes,2><Seconds,2>');
        InvNo := SalesHeader."No.";
        CompGLN := P_customer.GLN;
        Curr := SalesHeader."Currency Code";
        RefCurr := P_customer."Currency Code";
        taxDate := SalesHeader."VAT Reporting Date";
        //TotalAmt := SalesHeader."Amount Including VAT";
        TaxAmount := SalesHeader."Amount Including VAT" - SalesHeader.Amount;
        BuyerRef := SalesHeader."Your Reference";
        Clear(LineInfoAll);
        Clear(count);
        Clear(TotalAmtIncVat);
        salesline.Reset();
        salesline.SetRange("Document No.", SalesHeader."No.");
        salesline.SetRange("Document Type", SalesHeader."Document Type");
        salesline.SetRange(Type, salesline.Type::Item);
        if salesline.findset() then begin
            repeat
                Clear(LineInfo1);
                Clear(LineInfo2);
                Clear(LineInfo3);
                Clear(item);
                Clear(gtin);
                item.Reset();
                if item.Get(salesline."No.") then begin
                    gtin := item.GTIN;
                end;
                count += 1;
                TotalAmtIncVat += salesline."Amount Including VAT";
                TotalAmtExcVat += salesline.Amount;
                DiscountAmt += salesline."Line Discount Amount";
                LineInfo1 := '**IL' + '^' + InvNo + '^' + format(count) + '^' + BuyerRef + '^' + DMYPostingFormat + '^' + format(salesline.Quantity) + '^' + '2' + '^' + format(salesline."Amount Including VAT") + '^' + Format(salesline.Amount) + '^' + 'VAT' + '^' + 'E' + '^' + 'N' + '^' + format(salesline."VAT %") + '^' + format(salesline."Amount Including VAT" - salesline.Amount) + '^^^' + CRLF[1];
                LineInfo2 := '**P' + '^' + 'O' + '^' + salesline."No." + '^' + gtin + '^^^^^^' + salesline.Description + '^' + '1' + '^^^^^^^^^^^^^^^^^^^^^^^^^' + CRLF[1];
                LineInfo3 := '**G^O^' + format(salesline."Amount Including VAT") + '^' + Format(salesline.Amount) + '^^^^^^^' + CRLF[1];
                LineInfoAll += LineInfo1 + LineInfo2 + LineInfo3;
            until salesline.Next() = 0;

        end;
        HeaderInfoAll := '';
        HeaderInfo1 := '**!' + '1.01.01' + 'G' + 'CRN' + '0000' + InvNo + DMYPostingFormat + TimeText + 'D' + '^' + CRLF[1];
        HeaderInfo2 := '**D' + '^' + CompanyInfo."Registration No." + '^' + '^' + CompanyInfo.GLN + '^' + 'CRN' + '^' + '^' + 'N' + '^' + InvNo + DMYPostingFormat + '^' + '1' + '^' + '^' + '^' + RefCurr + '^' + RefCurr + CRLF[1];
        HeaderInfo3 := '**IH' + '^' + InvNo + '^' + DMYPostingFormat + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + format(TotalAmtIncVat) + '^' + format(TaxAmount) + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + CRLF[1];
        HeaderInfo4 := '**OH' + '^' + BuyerRef + '^' + DMYPostingFormat + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + '^' + CRLF[1];
        HeaderInfo5 := '**A' + '^' + '0' + '^' + '0' + '^' + 'COMPANY' + '^' + CompanyInfo.GLN + '^^^^^' + CompanyInfo.GLN + '^' + CompanyInfo.Name + '^' + CompanyInfo.Address + '^' + CompanyInfo."Address 2" + '^' + CompanyInfo.City + '^' + CompanyInfo.County + '^' + CompanyInfo."Post Code" + '^' + CompanyInfo."Country/Region Code" + '^' + CRLF[1];
        HeaderInfo6 := '**A' + '^' + '0' + '^' + '0' + '^' + 'PARTNER' + '^^^^^' + P_customer.Name + '^' + P_customer.Address + '^' + P_customer."Address 2" + '^' + P_customer.City + '^' + P_customer.County + '^' + P_customer."Post Code" + '^' + P_customer."Country/Region Code" + '^' + CRLF[1];
        HeaderInfo7 := '**A' + '^' + '0' + '^' + '0' + '^' + 'INVOICE' + '^' + CompGLN + '^^^^^^' + SalesHeader."Bill-to Name" + '^' + SalesHeader."Bill-to Address" + '^' + SalesHeader."Bill-to Address 2" + '^' + SalesHeader."Bill-to City" + '^' + SalesHeader."Bill-to County" + '^' + SalesHeader."Bill-to Post Code" + '^' + SalesHeader."Bill-to Country/Region Code" + '^' + CRLF[1];
        HeaderInfo8 := '**A' + '^' + '0' + '^' + '0' + '^' + 'SHIP TO' + '^' + P_customer.GLN + '^^^^^' + P_customer.GLN + '^' + SalesHeader."Ship-to Name" + '^' + SalesHeader."Ship-to Address" + '^' + SalesHeader."Ship-to Address 2" + '^' + SalesHeader."Ship-to City" + '^' + SalesHeader."Ship-to County" + '^' + SalesHeader."Ship-to Post Code" + '^' + SalesHeader."Ship-to Country/Region Code" + '^' + CRLF[1];
        HeaderInfo9 := '*IS^' + InvNo + '^VAT^E^0^' + format(count) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + format(DiscountAmt) + '^' + format(TotalAmtIncVat) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(TotalAmtIncVat) + CRLF[1];
        HeaderInfo10 := '*IT^' + InvNo + '^1^' + Format(count) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + 'N' + '^' + format(DiscountAmt) + '^' + format(TotalAmtExcVat) + '^' + format(DiscountAmt) + '^' + format(TotalAmtIncVat) + '^' + format(TotalAmtIncVat - TotalAmtExcVat) + '^' + format(TotalAmtIncVat) + CRLF[1];
        HeaderInfo11 := '**@0000' + InvNo + '1' + '     1';
        HeaderInfoAll := HeaderInfo1 + HeaderInfo2 + HeaderInfo3 + HeaderInfo4 + HeaderInfo5 + HeaderInfo6 + HeaderInfo7 + HeaderInfo8 + LineInfoAll + HeaderInfo9 + HeaderInfo10 + HeaderInfo11;


        EDIMessage := HeaderInfoAll + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + salesHeader."No." + '.fif';
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            UploadFileTOAzureBlob(TextInstream, FileName, StartParameter);
        end;
    end;





    procedure UploadFileTOAzureBlob(P_FileInstream: InStream; P_FileName: Text; P__ChannelCode: Code[20])
    var
        fileMgt: Codeunit "File Management";
        L_httpResponse: HttpResponseMessage;
        L_httpHeader: HttpHeaders;
        apiEndPoint: Text;
        containerName: Text;
        filename: Text;
        sasToken: text;
        apiUrl: Text;
        L_httpClient: HttpClient;
        L_httpContent: HttpContent;
        apiattribute: Text;
        TradePartner: Record "Trade Partner";
    begin
        //Upload++
        ClearLastError();
        Clear(L_httpContent);
        Clear(L_httpHeader);
        Clear(apiEndPoint);
        Clear(containerName);
        Clear(filename);
        Clear(sasToken);
        Clear(L_httpClient);
        Clear(L_httpResponse);
        L_httpContent.WriteFrom(P_FileInstream);
        L_httpContent.GetHeaders(L_httpHeader);

        L_httpHeader.Remove('Content-Type');
        L_httpHeader.Add('x-ms-version', '2015-02-21');
        L_httpHeader.Add('x-ms-date', '2015-02-21');
        L_httpHeader.Add('x-ms-blob-type', 'BlockBlob');
        L_httpHeader.Add('Content-Type', 'application/octet-stream');

        TradePartner.Reset();
        TradePartner.SetRange(Code, P__ChannelCode);
        if TradePartner.FindFirst() then begin
            apiEndPoint := TradePartner."API Endpoint";
            containerName := TradePartner."Order Acknow. Conatiner Name";
            sasToken := TradePartner."Order Acknow. Token";
        end;

        // apiEndPoint := 'https://shopdirect.blob.core.windows.net';
        // containerName := 'teststupdin';
        // sasToken := 'sp=racwl&st=2021-06-18T09:59:46Z&se=2021-07-30T17:59:46Z&spr=https&sv=2020-02-10&sr=c&sig=GMoLncjHNc0eY2KCSDN%2BnVw819%2FmQJdKmp5ZamBst5k%3D';

        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
        L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
        // if L_httpResponse.HttpStatusCode = 201 then
        //     Message('file uploaded successfully.');
        //Upload--
    end;

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
        Monthformat: Integer;
        Yearformat: Integer;
        DMYPostingFormat: Text;
        DMYShipmentFormat: Text;
        YearText: Text;
        MonthText: Text;
        DateText: Text;
        TimeFormat: Text;
        TimeText: Text;
        TimeStr: Text;
        InvNo: Code[20];
        Datetime1: DateTime;
        Time1: Time;
        CompGLN: Code[20];
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
        StartParameter: Text;
        RunType: Text;
        TradepartnerRecord: Record "Trade Partner";
}