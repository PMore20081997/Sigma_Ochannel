codeunit 90076 "JohnlewisEDI"
{
    TableNo = "Sales Invoice Header";
    Permissions = tabledata "Sales Invoice Header" = M;
    trigger OnRun()
    var
        FileName: Text;


    begin


    end;

    procedure GetEDIRecords()
    var
        NoSeriesMgmt: Codeunit "No. Series";
        NextNo: Code[20];
        Salesinvoicehead: Record "Sales Invoice Header";
    begin

        TradepartnerRecord.Reset();
        TradepartnerRecord.SetRange("Export Invoice", true);
        if TradepartnerRecord.FindSet() then begin
            repeat
                Salesinvoicehead.Reset();
                Salesinvoicehead.SetRange("Bill-to Customer No.", TradepartnerRecord."Customer No.");
                Salesinvoicehead.SetRange(Export, false);
                if Salesinvoicehead.FindFirst() then begin
                    NextNo := NoSeriesMgmt.GetNextNo(TradepartnerRecord."EDI No.Series", WorkDate(), true);
                    ProcessEDIHeader(NextNo, TradepartnerRecord."Customer No.");
                    TradepartnerRecord."Last EDI Invoice No." := '$' + NextNo;
                    TradepartnerRecord.Modify();
                end;
            until TradepartnerRecord.Next() = 0;

        end;
    end;

    local procedure ProcessEDIHeader(NextNo: Code[20]; CustomerNo: code[20])
    var

    begin

        CRLF[1] := 13;
        CRLF[2] := 10;
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("Bill-to Customer No.", "CustomerNo");
        SalesInvoiceHeader.SetRange(Export, false);
        if SalesInvoiceHeader.FindSet() then begin
            Dateformat := Date2DMY(SalesInvoiceHeader."Posting Date", 1);
            Monthformat := Date2DMY(SalesInvoiceHeader."Posting Date", 2);
            if Monthformat < 10 then
                MonthText := '0' + Format(Monthformat) else
                MonthText := format(Monthformat);
            Yearformat := Date2DMY(SalesInvoiceHeader."Posting Date", 3);
            if Yearformat < 10 then
                YearText := '0' + CopyStr(format(Yearformat), 3, 2)
            else
                YearText := CopyStr(format(Yearformat), 3, 2);
            DMYPostingFormat := YearText + MonthText + Format(Dateformat);
            TimeFormat := format(Time, 9);
            TimeText := copystr(TimeFormat, 1, 5);
            TimeStr := DelStr(TimeText, 3, 1);
            HeaderInfo := '';
            HeaderInfo := 'UNB' + '+' + 'UNOA:3' + '+' + '5016237033020' + ':14' + '+' + '5023949000004' + ':14:' + '+' + DMYPostingFormat + ':' + TimeStr + '+' + SalesInvoiceHeader."External Document No." + '++' + 'INVOIC''' + CRLF[1];
            repeat
                Dateformat := Date2DMY(SalesInvoiceHeader."Shipment Date", 1);
                if Dateformat < 10 then
                    DateText := '0' + Format(Dateformat)
                else
                    DateText := Format(Dateformat);
                Monthformat := Date2DMY(SalesInvoiceHeader."Shipment Date", 2);
                if Monthformat < 10 then
                    MonthText := '0' + Format(Monthformat) else
                    MonthText := format(Monthformat);
                Yearformat := Date2DMY(SalesInvoiceHeader."Shipment Date", 3);
                DMYShipmentFormat := Format(Yearformat) + MonthText + Format(DateText);
                ExportTextHeader := '';
                ExportTextHeader := 'UNH' + '+' + SalesInvoiceHeader."No." + '+' + 'INVOIC:D:96A:UN:EAN008''' + CRLF[1] + 'BGM' + '+' + '380' + '+' + SalesInvoiceHeader."Order No." + '+' + '9''' + CRLF[1] + 'DTM' + '+' + '137:' + DMYShipmentFormat + ':102''' + CRLF[1] + 'RFF' + '+' + 'ON:176938''' + CRLF[1] + 'RFF' + '+' + 'ALL:510''' + CRLF[1] + 'NAD' + '+' + 'BY' + '+' + '5023949000004::9' + '++' + SalesInvoiceHeader."Sell-to Customer Name" + '''' + CRLF[1] +
'NAD' + '+' + 'SU' + '+' + '5016237033020::9' + '++' + SalesInvoiceHeader."Ship-to Name" + '''' + CRLF[1] + 'RFF' + '+' + 'VA:GB105958557''';

                EDIMessage += ExportTextHeader + CRLF[1] + ExportEDILines(SalesInvoiceHeader."No.");
                SalesInvoiceHeader.Export := true;
                SalesInvoiceHeader.Modify();
            until SalesInvoiceHeader.Next() = 0;
        end;
        EDIMessage := HeaderInfo + EDIMessage;
        if EDIMessage <> '' then begin
            FileName := '$' + NextNo + '.INV';
            tempblob.CreateOutStream(TextOutstream);
            TextOutstream.WriteText(EDIMessage);
            tempblob.CreateInStream(TextInstream);
            // DownloadFromStream(TextInstream, 'EDI', '', '', FileName);
            UploadFileTOAzureBlob(TextInstream, FileName, TradepartnerRecord.Code);
        end;
    end;

    local procedure ExportEDILines(SalesInvoiceNo: Code[20]): Text
    var
        myInt: Integer;
        SalesInvoiceLine: Record "Sales Invoice Line";
        LineIncrement: Integer;
        Totalcount: Integer;
        ItemCrossreference: Record "Item Reference";
        Taxvariable: Text;

    begin
        CRLF[1] := 13;
        CRLF[2] := 10;

        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceNo);
        If SalesInvoiceLine.FindFirst() then begin
            Totalcount := 0;
            Totalcount := SalesInvoiceLine.Count;
            repeat
                ItemCrossreference.Reset();
                // ItemCrossreference.SetRange("Cross-Reference Type", ItemCrossreference."Cross-Reference Type"::"Bar Code");
                ItemCrossreference.SetRange("Item No.", SalesInvoiceLine."No.");
                ItemCrossreference.SetRange("Variant Code", SalesInvoiceLine."Variant Code");
                if ItemCrossreference.FindFirst() then;
                LineIncrement += 1;

                if SalesInvoiceLine."VAT %" > 0 then
                    Taxvariable := 'S' else
                    Taxvariable := 'Z';

                ExportTextLine += 'LIN' + '+' + Format(LineIncrement) + '++' + ItemCrossreference."Reference No." + ':EN''' + CRLF[1] + 'IMD' + '+' + 'F' + '++:::' + SalesInvoiceLine.Description + '''' + CRLF[1] + 'QTY' + '+' + '47:' + format(SalesInvoiceLine.Quantity) + '''' + CRLF[1] + 'MOA' + '+' + '66:438.61''' + CRLF[1] + 'PRI' + '+' + 'AAB:' + format(SalesInvoiceLine."Unit Price") + '''' + CRLF[1] + 'RFF' + '+' + 'ON:176938:0''' + CRLF[1] + 'TAX' + '+' + '7' + '+' + 'VAT' + '+++:::' + format(SalesInvoiceLine."VAT %") + '%' + Taxvariable + '''' + CRLF[1] + 'ALC' + '+' + 'A' + '+++' + SalesInvoiceLine."No." + '+' + 'QD''' + CRLF[1] + 'MOA' + '+' + '204:2.00''' + CRLF[1] + 'UNS' + '+' + 'S''' + CRLF[1] + 'CNT' + '+' + format(Totalcount) + ':' + Format(LineIncrement) + '''' + CRLF[1] +
                'MOA' + '+' + '86:344.23''' + CRLF[1] + 'MOA' + '+' + '124:.00''' + CRLF[1] + 'MOA' + '+' + '129:353.06''' + CRLF[1] + 'MOA' + '+' + '125:344.23''' + CRLF[1] + 'TAX' + '+' + '7' + '+' + 'VAT:::+++:::' + format(SalesInvoiceLine."VAT %") + '%' + Taxvariable + '''' + CRLF[1] + 'MOA' + '+' + '124:0.00''' + CRLF[1] + 'MOA' + '+' + '125:353.06''' + CRLF[1] + 'UNT' + '+' + '27' + '+' + SalesInvoiceHeader."No." + '''' + CRLF[1];
            until SalesInvoiceLine.Next() = 0;
            exit(ExportTextLine);
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
            containerName := TradePartner."Order Acknow. Container Name";
            sasToken := TradePartner."Order Acknow. Container Token";
        end;

        // apiEndPoint := 'https://shopdirect.blob.core.windows.net';
        // containerName := 'teststupdin';
        // sasToken := 'sp=racwl&st=2021-06-18T09:59:46Z&se=2021-07-30T17:59:46Z&spr=https&sv=2020-02-10&sr=c&sig=GMoLncjHNc0eY2KCSDN%2BnVw819%2FmQJdKmp5ZamBst5k%3D';

        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
        L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
        if L_httpResponse.HttpStatusCode = 201 then
            Message('file uploaded successfully.');
        //Upload--
    end;

    var
        CRLF: Text[2];
        SalesInvoiceLine: Record "Sales Invoice Line";
        myInt: Integer;
        ExportTextHeader: Text;
        ExportTextLine: Text;
        HeaderInfo: Text;


        TextInstream: InStream;

        TextOutstream: OutStream;
        EDIMessage: Text;
        tempblob: Codeunit "Temp Blob";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TradepartnerRecord: Record "Trade Partner";
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


}