codeunit 90071 "Order Acknowledgement"
{
    Description = 'this code unit we can use for all channels where any data need to be send via file';
    TableNo = 472;
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE StartParameter OF
            'SHOPDIRECT':
                BEGIN
                    case RunType of
                        'OrderAcknowledgement':
                            ShopdirectOrderAckText(StartParameter);
                        'SyncShipment':
                            ShopdirectOrderdispatchText(StartParameter);
                        'StockPosition':
                            ShopdirectStockPosition(StartParameter);
                        'StockStatus':
                            ShopDirectStockStatus(StartParameter);
                    end;
                End;
        end;
    end;



    procedure UploadFileTOAzureBlob(P_FileInstream: InStream; P_FileName: Text; P__ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
        CU_90000: Codeunit 90000;
    begin
        //Upload++
        /*below code is blocked because it is moved inot cu 90000 Web order Mgt which we can call from any where
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
        L_httpHeader.Add('Content-Type', 'text/xml');
        */
        TradePartner.Reset();
        TradePartner.SetRange(Code, P__ChannelCode);
        if TradePartner.FindFirst() then begin
            /*below code is blocked because it is moved inot cu 90000 Web order Mgt which we can call from any where  
              apiEndPoint := TradePartner."API Endpoint";
              containerName := TradePartner."Order Acknow. Conatiner Name";
              sasToken := TradePartner."Order Acknow. Token";
            */
            CU_90000.UploadFilefromBCTOAzureBlob(P_FileInstream, P_FileName, TradePartner."API Endpoint", TradePartner."Order Acknow. Conatiner Name", TradePartner."Order Acknow. Token", true);
        end;

        /*below code is blocked because it is moved inot cu 90000 Web order Mgt which we can call from any where
        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
        L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
        if ((L_httpResponse.HttpStatusCode = 200) OR (L_httpResponse.HttpStatusCode = 201)) then
            Message('file uploaded successfully.');
        //Upload--
        */
    end;

    procedure ShopdirectOrderAckText(PartnerCode: Code[10])
    var
        InterimSalesHeader: Record "Interim Sales Header";
        TodayDate: Text;
        MultilineorderNoref: Code[250];
        InterimSalesHeader2: Record "Interim Sales Header";
        InterimSalesHeader3: Record "Interim Sales Header";
        P_ChannelPartner: Record "Trade Partner";
        CRLF: Text[2];
        inStr: InStream;
        TextOutstream: OutStream;
        ExportText: Text;
        HeaderInfo: Text;
        HeaderInfo1: Text;
        FileName: Text;
        ExportTextFile: Text;
        DateStr: Text;
        DeleteStr1: Text;
        DeleteStr2: Text;
        DeleteStr3: Text;
        Dateformat: Text;
        TimeStr: Text;
        TimeStr1: Text;
        L_cust: Record Customer;
        L_TradePartner: Record "Trade Partner";
        FileCount: Text;
        OrderAck: Codeunit "Order Acknowledgement";
    begin
        Clear(TodayDate);
        Clear(Dateformat);
        Clear(DeleteStr1);
        Clear(DeleteStr2);
        Clear(DeleteStr3);
        Clear(DateStr);
        Clear(TimeStr);
        Clear(TimeStr1);

        InterimSalesHeader.RESET;
        InterimSalesHeader.SETRANGE("Trade Partner Code", PartnerCode);
        InterimSalesHeader.SETRANGE(Status, InterimSalesHeader.Status::"SO Created");
        InterimSalesHeader.SETRANGE("Order Ack. Exported", FALSE);
        TodayDate := FORMAT(TODAY, 0, '20<Year>-<Month,2>-<Day,2>');
        TimeStr := Format(Time, 0, '<Hours24,2>:<Minutes,2>:<Second,2>');
        IF InterimSalesHeader.FindSet() THEN begin
            Clear(CRLF);
            CRLF[1] := 13;
            CRLF[2] := 10;
            HeaderInfo := '';
            HeaderInfo := '<STATUSES>' + CRLF[1] + '<SENDERADDRESS>' + 'R0200' + '</SENDERADDRESS>' + CRLF[1] + '<DATATYPE>' + '30' + '</DATATYPE>' + CRLF[1];
            ExportText := '';
            repeat
                L_cust.Get(InterimSalesHeader."Sell-to Customer No.");
                ExportText += '<STATUS>' + CRLF[1] + '<DATE>' + Format(TodayDate) + 'T00:00:00' + '</DATE>' + CRLF[1] + '<TIME>' + TimeStr + '</TIME>' + CRLF[1] + '<STATUSCODE>' + '11' + '</STATUSCODE>' + CRLF[1] + '<ORDER>' + CRLF[1] + '<ORDERNUMBER>' + InterimSalesHeader."Channel Order ID"
            + '</ORDERNUMBER>' + CRLF[1] + '<ORDERDATE>' + FORMAT(InterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>') + '</ORDERDATE>' + CRLF[1] + '<SUPPLIER>' + CRLF[1] + '<BUYERREFERENCE>' + L_cust."Our Account No." + '</BUYERREFERENCE>' + CRLF[1] + '</SUPPLIER>' + CRLF[1] + '</ORDER>' + CRLF[1] + '</STATUS>' + CRLF[1];
            until InterimSalesHeader.Next() = 0;
            HeaderInfo1 := '';
            HeaderInfo1 := '</STATUSES>';
        end;
        Clear(FileName);
        Clear(inStr);
        Clear(TextOutstream);
        Clear(FileName);
        Clear(FileName);
        Clear(ExportTextFile);
        ExportTextFile := HeaderInfo + ExportText + HeaderInfo1;
        L_TradePartner.Reset();
        L_TradePartner.SetRange(Code, PartnerCode);
        if L_TradePartner.FindFirst() then begin
            IF (L_TradePartner."Last Date to Export Order Ack" = 0D) OR (L_TradePartner."Last Date to Export Order Ack" <> TODAY) THEN
                FileCount := '00'
            ELSE
                FileCount := INCSTR(L_TradePartner.TariffCode);

            L_TradePartner."Last Date to Export Order Ack" := TODAY;
            L_TradePartner.TariffCode := FileCount;
            L_TradePartner.MODIFY;

            // Save the data of the InStream as a file
            fileName := L_TradePartner.Code + '.' + 'stupd.' + TodayDate + '.' + FileCount;// + '.XML';
        end;

        tempblob.CreateOutStream(TextOutstream);
        TextOutstream.WriteText(ExportTextFile);
        tempblob.CreateInStream(inStr);
        UploadFileTOAzureBlob(inStr, fileName, L_TradePartner.Code);
    end;

    procedure ShopdirectOrderdispatchText(PartnerCode: Code[10])
    var
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        TodayDate: Text;
        MultilineorderNoref: Code[250];
        InterimSalesHeader2: Record "Interim Sales Header";
        InterimSalesHeader3: Record "Interim Sales Header";
        P_ChannelPartner: Record "Trade Partner";
        CRLF: Text[2];
        inStr: InStream;
        TextOutstream: OutStream;
        ExportText: Text;
        HeaderInfo: Text;
        HeaderInfo1: Text;
        FileName: Text;
        ExportTextFile: Text;
        DateStr: Text;
        DeleteStr1: Text;
        DeleteStr2: Text;
        DeleteStr3: Text;
        Dateformat: Text;
        TimeStr: Text;
        TimeStr1: Text;
        L_cust: Record Customer;
        L_TradePartner: Record "Trade Partner";
        FileCount: Text;
        OrderAck: Codeunit "Order Acknowledgement";
    begin
        Clear(TodayDate);
        Clear(Dateformat);
        Clear(DeleteStr1);
        Clear(DeleteStr2);
        Clear(DeleteStr3);
        Clear(DateStr);
        Clear(TimeStr);
        Clear(TimeStr1);

        HandledInterimSalesHeader.RESET;
        //HandledInterimSalesHeader.SetFilter("No.",'%1..%2','WEB0000006','WEB0000007');      
        HandledInterimSalesHeader.SETRANGE("Trade Partner Code", PartnerCode);
        HandledInterimSalesHeader.SetRange("Document Type", HandledInterimSalesHeader."Document Type"::Order);
        //HandledInterimSalesHeader.SetFilter(Status, '%1|%2', HandledInterimSalesHeader.Status::Dispatched, HandledInterimSalesHeader.status::Cancelled);
        HandledInterimSalesHeader.SETRANGE("Order Fullfilled", FALSE);
        TodayDate := FORMAT(TODAY, 0, '20<Year>-<Month,2>-<Day,2>');
        TimeStr := Format(Time, 0, '<Hours24,2>:<Minutes,2>:<Second,2>');
        IF HandledInterimSalesHeader.FindSet() THEN begin
            Clear(CRLF);
            CRLF[1] := 13;
            CRLF[2] := 10;
            HeaderInfo := '';
            HeaderInfo := '<STATUSES>' + CRLF[1] + '<SENDERADDRESS>' + 'R0200' + '</SENDERADDRESS>' + CRLF[1] + '<DATATYPE>' + '30' + '</DATATYPE>' + CRLF[1];
            ExportText := '';
            repeat
                L_cust.Get(HandledInterimSalesHeader."Sell-to Customer No.");
                ExportText += '<STATUS>' + CRLF[1] + '<DATE>' + Format(TodayDate) + 'T00:00:00' + '</DATE>' + CRLF[1] + '<TIME>' + TimeStr + '</TIME>' + CRLF[1];
                // if HandledInterimSalesHeader.status = HandledInterimSalesHeader.status::Dispatched then
                //     ExportText += '<STATUSCODE>' + '40' + '</STATUSCODE>' + CRLF[1]
                // else
                //     if HandledInterimSalesHeader.status = HandledInterimSalesHeader.status::Cancelled then
                //         ExportText += '<STATUSCODE>' + '17' + '</STATUSCODE>' + CRLF[1];

                ExportText += '<ORDER>' + CRLF[1] + '<ORDERNUMBER>' + HandledInterimSalesHeader."Channel Order ID"
               + '</ORDERNUMBER>' + CRLF[1] + '<ORDERDATE>' + FORMAT(HandledInterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>') + '</ORDERDATE>' + CRLF[1] + '<SUPPLIER>' + CRLF[1] + '<BUYERREFERENCE>' + L_cust."Our Account No." + '</BUYERREFERENCE>' + CRLF[1] + '</SUPPLIER>' + CRLF[1] + '</ORDER>' + CRLF[1] + '</STATUS>' + CRLF[1];
            until HandledInterimSalesHeader.Next() = 0;
            HeaderInfo1 := '';
            HeaderInfo1 := '</STATUSES>';
        end;
        Clear(FileName);
        Clear(inStr);
        Clear(TextOutstream);
        Clear(FileName);
        Clear(FileName);
        Clear(ExportTextFile);
        ExportTextFile := HeaderInfo + ExportText + HeaderInfo1;
        L_TradePartner.Reset();
        L_TradePartner.SetRange(Code, PartnerCode);
        if L_TradePartner.FindFirst() then begin
            IF (L_TradePartner."Last Date to Export Order Ack" = 0D) OR (L_TradePartner."Last Date to Export Order Ack" <> TODAY) THEN
                FileCount := '00'
            ELSE
                FileCount := INCSTR(L_TradePartner.TariffCode);

            L_TradePartner."Last Date to Export Order Ack" := TODAY;
            L_TradePartner.TariffCode := FileCount;
            L_TradePartner.MODIFY;

            // Save the data of the InStream as a file
            fileName := L_TradePartner.Code + '.' + 'stupd.' + TodayDate + '.' + FileCount;// + '.XML';
        end;

        tempblob.CreateOutStream(TextOutstream);
        TextOutstream.WriteText(ExportTextFile);
        tempblob.CreateInStream(inStr);
        UploadFileTOAzureBlob(inStr, fileName, L_TradePartner.Code);
    end;

    local procedure ShopdirectStockPosition(PartnerCode: Code[10])
    var
        CRLF: Text[2];
        HeaderInfo: Text;
        ExportText: Text;
        ItemVariant: record "Item Variant";
        L_TradePartner: Record "Trade Partner";
        FileName: Text;
        inStr: InStream;
        TextOutstream: OutStream;
        TodayDate: Text;
        L_cust: Record Customer;
        ItemReferance: Record "Item Reference";
        UniqueIdentifier: Text;
        Noofstocklines: Integer;
        AvailableQty: Decimal;
    begin
        Clear(CRLF);
        Clear(AvailableQty);
        L_TradePartner.Reset();
        L_TradePartner.SetRange(Code, PartnerCode);
        L_TradePartner.FindFirst();
        L_cust.Get(L_TradePartner."Customer No.");
        CRLF[1] := 13;
        CRLF[2] := 10;
        HeaderInfo := '';
        HeaderInfo := '<STOCK_POSITIONS>' + CRLF[1] + '<BUYER>' + CRLF[1] + '<BUYERREFERENCE>' + 'R0200' + '</BUYERREFERENCE>' + CRLF[1] + '</BUYER>' + CRLF[1] + '<SUPPLIER>' + CRLF[1] + '<BUYERREFERENCE>' + L_cust."Our Account No." + '</BUYERREFERENCE>' + CRLF[1] + '</SUPPLIER>' + CRLF[1];
        ExportText := '';

        Clear(UniqueIdentifier);
        ItemReferance.Reset();
        //ItemReferance.SetRange("Item No.",'2778_7');
        ItemReferance.SetRange("Reference Type", ItemReferance."Reference Type"::Customer);
        ItemReferance.SetRange("Reference Type No.", L_cust."No.");
        if ItemReferance.FindFirst() then
            repeat
                UniqueIdentifier := ItemReferance."Reference No.";
                Noofstocklines += 1;
                AvailableQty := CalculateAvailableQuantity(ItemReferance."Item No.", ItemReferance."Variant Code", L_cust."Location Code");
                ExportText += '<STOCK_POSITION>' + CRLF[1] + '<UNIQUEIDENTIFIER>' + UniqueIdentifier + '</UNIQUEIDENTIFIER>' + CRLF[1] + '<OWN_CODE>' + ItemReferance."Item No." + '</OWN_CODE>' + CRLF[1] + '<AVAILABLE_QUANTITY>' + format(AvailableQty) + '</AVAILABLE_QUANTITY>' + CRLF[1] + '</STOCK_POSITION>' + CRLF[1];
                if Noofstocklines > 2500 then begin
                    CreateStockPositionandStatusfile(HeaderInfo, ExportText, L_TradePartner, 'StockPosition');
                    Clear(Noofstocklines);
                    Clear(ExportText);
                end;
            until ItemReferance.Next() = 0;
        if Noofstocklines > 0 then
            CreateStockPositionandStatusfile(HeaderInfo, ExportText, L_TradePartner, 'StockPosition');


    end;

    local procedure CreateStockPositionandStatusfile(P_HeaderInfo: Text; P_ExportText: Text; var P_TradePartner: record "Trade Partner"; Source: Text)
    var
        FileName: Text;
        inStr: InStream;
        TextOutstream: OutStream;
        FileCount: Text;
        TodayDate: Text;
        HeaderInfo1: Text;
        ExportTextFile: Text;
        CU_90000: Codeunit 90000;
        TimeStr: Text;
    begin
        Clear(TodayDate);
        TodayDate := FORMAT(TODAY, 0, '20<Year>-<Month,2>-<Day,2>');
        TodayDate := DELCHR(TodayDate, '=', '/');
        TodayDate := DELCHR(TodayDate, '=', '-');
        TimeStr := Format(Time, 0, '<Hours24,2>:<Minutes,2>:<Second,2>');
        TimeStr := DelChr(TimeStr, '=', ':');
        TodayDate := TodayDate + TimeStr;
        Clear(FileName);
        HeaderInfo1 := '';
        if Source = 'StockPosition' then begin
            HeaderInfo1 := '</STOCK_POSITIONS>';
            fileName := P_TradePartner.Code + '.' + 'StockPosition.' + TodayDate;
        end else
            if Source = 'StockStatus' then begin
                HeaderInfo1 := '</STOCK_STATUSES>';
                fileName := P_TradePartner.Code + '.' + 'StockStatus.' + TodayDate;
            end;


        Clear(inStr);
        Clear(TextOutstream);
        Clear(ExportTextFile);
        ExportTextFile := P_HeaderInfo + P_ExportText + HeaderInfo1;

        // Save the data of the InStream as a file   


        tempblob.CreateOutStream(TextOutstream);
        TextOutstream.WriteText(ExportTextFile);
        tempblob.CreateInStream(inStr);
        if Source = 'StockPosition' then
            CU_90000.UploadFilefromBCTOAzureBlob(inStr, FileName, P_TradePartner."API Endpoint", P_TradePartner."Outgoing Container 2 Name", P_TradePartner."Outgoing Container 2 Token", false)
        else
            if Source = 'StockStatus' then
                CU_90000.UploadFilefromBCTOAzureBlob(inStr, FileName, P_TradePartner."API Endpoint", P_TradePartner."Outgoing Container 3 Name", P_TradePartner."Outgoing Container 3 Token", false);
    end;


    local procedure CalculateAvailableQuantity(P_ItemNo: Code[20]; P_VariantCode: Code[20]; P_Location: Code[20]) AvailableQty: Decimal
    var
        IsHandled: Boolean;
    begin
        OnBeforeCalculateAvailableQuantity(P_ItemNo, P_VariantCode, P_Location, AvailableQty, IsHandled);
        if IsHandled then
            exit;

        OnAfterCalculateAvailableQuantity(P_ItemNo, P_VariantCode, P_Location, AvailableQty);
    end;

    local procedure ShopDirectStockStatus(PartnerCode: Code[10])
    var
        CRLF: Text[2];
        HeaderInfo: Text;
        ExportText: Text;
        ItemVariant: record "Item Variant";
        L_TradePartner: Record "Trade Partner";
        FileName: Text;
        inStr: InStream;
        TextOutstream: OutStream;
        TodayDate: Text;
        L_cust: Record Customer;
        ItemReferance: Record "Item Reference";
        UniqueIdentifier: Text;
        Noofstocklines: Integer;
        AvailableQty: Decimal;
    begin
        Clear(CRLF);
        L_TradePartner.Reset();
        L_TradePartner.SetRange(Code, PartnerCode);
        L_TradePartner.FindFirst();
        L_cust.Get(L_TradePartner."Customer No.");
        CRLF[1] := 13;
        CRLF[2] := 10;
        HeaderInfo := '';
        HeaderInfo := '<STOCK_STATUSES>' + CRLF[1] + '<BUYER>' + CRLF[1] + '<BUYERREFERENCE>' + 'R0200' + '</BUYERREFERENCE>' + CRLF[1] + '</BUYER>' + CRLF[1] + '<SUPPLIER>' + CRLF[1] + '<BUYERREFERENCE>' + L_cust."Our Account No." + '</BUYERREFERENCE>' + CRLF[1] + '</SUPPLIER>' + CRLF[1];
        ExportText := '';

        Clear(UniqueIdentifier);
        ItemReferance.Reset();
        //ItemReferance.SetRange("Item No.",'2778_7');
        ItemReferance.SetRange("Reference Type", ItemReferance."Reference Type"::Customer);
        ItemReferance.SetRange("Reference Type No.", L_cust."No.");
        if ItemReferance.FindFirst() then
            repeat
                UniqueIdentifier := ItemReferance."Reference No.";
                Clear(TodayDate);
                TodayDate := FORMAT(TODAY, 0, '20<Year>-<Month,2>-<Day,2>');
                Noofstocklines += 1;
                AvailableQty := CalculateAvailableQuantity(ItemReferance."Item No.", ItemReferance."Variant Code", L_cust."Location Code");
                ExportText += '<STOCK_STATUS>' + CRLF[1] + '<UNIQUEIDENTIFIER>' + UniqueIdentifier + '</UNIQUEIDENTIFIER>' + CRLF[1] + '<OWN_CODE>' + ItemReferance."Item No." + '</OWN_CODE>' + CRLF[1] + '<CURRENT_EFFECTIVE_DATE>' + Format(TodayDate) + 'T00:00:00' + '</CURRENT_EFFECTIVE_DATE>' + CRLF[1];
                IF AvailableQty > 0 then
                    ExportText += '<CURRENT_STOCK_STATUS>' + 'IS' + '</CURRENT_STOCK_STATUS>'
                else
                    ExportText += '<CURRENT_STOCK_STATUS>' + 'OOS' + '</CURRENT_STOCK_STATUS>';

                ExportText += CRLF[1] + '<CURRENT_LEAD_TIME>' + '2' + '</CURRENT_LEAD_TIME>' + CRLF[1] + '<CURRENT_DUE_DATE />' + CRLF[1];
                ExportText += '<NEXT_EFFECTIVE_DATE />' + CRLF[1] + '<NEXT_STOCK_STATUS />' + CRLF[1] + '<NEXT_LEAD_TIME />' + CRLF[1] + '<NEXT_DUE_DATE />' + CRLF[1];
                ExportText += '<FUTURE_EFFECTIVE_DATE />' + CRLF[1] + '<FUTURE_STOCK_STATUS />' + CRLF[1] + '<FUTURE_LEAD_TIME />' + CRLF[1] + '<FUTURE_DUE_DATE />' + CRLF[1];
                ExportText += '</STOCK_STATUS>' + CRLF[1];
                //'</STOCK_POSITION>' + CRLF[1]; 
                if Noofstocklines > 2500 then begin
                    CreateStockPositionandStatusfile(HeaderInfo, ExportText, L_TradePartner, 'StockStatus');
                    Clear(Noofstocklines);
                    Clear(ExportText);
                end;
            until ItemReferance.Next() = 0;
        if Noofstocklines > 0 then
            CreateStockPositionandStatusfile(HeaderInfo, ExportText, L_TradePartner, 'StockStatus');

    end;

    local procedure CreateStockstatusfile()
    var
    begin

    end;

    //this function is not in use
    local procedure ShopdirectOrderdispatch(PartnerCode: Code[10])
    var
        FileCount: Text;
        Customer: Record Customer;
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        TodayDate: Text;
        MultilineorderNoref: Code[250];
        HandledInterimSalesHeader2: Record "Handled Interim Sales Header";
        HandledInterimSalesHeader3: Record "Handled Interim Sales Header";
        xmlElem: XmlElement;
        xmlElem2: XmlElement;
        Tempblob: Codeunit "Temp Blob";
        xmlElem3: XmlElement;
        xmlElem4: XmlElement;
        xmlElem5: XmlElement;
        xmlElem6: XmlElement;
        xmlElem7: XmlElement;
        xmlElem8: XmlElement;
        xmlElem9: XmlElement;
        xmlElem10: XmlElement;
        xmlElem11: XmlElement;
        xmlElem12: XmlElement;
        xmlDoc: XmlDocument;
        xmlDec: XmlDeclaration;
        OutStr: OutStream;
        inStr: InStream;
        fileName: Text;
        L_TradePartner: Record "Trade Partner";
        OrderAck: Codeunit "Order Acknowledgement";
        L_cust: Record Customer;
    begin
        Clear(xmlElem);
        Clear(xmlElem2);
        Clear(xmlElem3);
        Clear(xmlElem4);
        Clear(xmlElem5);
        Clear(xmlElem6);
        Clear(xmlElem7);
        Clear(xmlElem8);
        Clear(xmlElem9);
        Clear(xmlElem10);
        Clear(xmlElem11);
        Clear(xmlElem12);
        Clear(xmlDoc);
        Clear(xmlDec);
        Clear(outStr);
        TodayDate := FORMAT(TODAY, 0, '<Month,2>_<Day,2>_<Year4>');
        TodayDate := DELCHR(TodayDate, '=', '/');

        xmlDoc := xmlDocument.Create();
        /*
        xmlDec := xmlDeclaration.Create('1.0', 'UTF-8', '');
        xmlDoc.SetDeclaration(xmlDec);
        */
        xmlElem := xmlElement.Create('STATUSES');

        xmlElem2 := XmlElement.Create('SENDERADDRESS');
        xmlElem2.Add(xmlText.Create('R0200'));

        xmlElem3 := XmlElement.Create('DATATYPE');
        xmlElem3.Add(xmlText.Create('30'));

        xmlElem.Add(xmlElem2);
        xmlElem.Add(xmlElem3);




        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETFILTER("Trade Partner Code", PartnerCode);
        //HandledInterimSalesHeader.SETRANGE(Status, HandledInterimSalesHeader.Status::Dispatched);
        //InterimSalesHeader.SETRANGE("Order Ack. Exported", FALSE);
        IF HandledInterimSalesHeader.FindSet() THEN begin
            REPEAT
                L_cust.Get(HandledInterimSalesHeader."Sell-to Customer No.");
                xmlElem4 := XmlElement.Create('STATUS');

                xmlElem5 := XmlElement.Create('DATE');
                xmlElem5.Add(xmlText.Create(Format(Today, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>')));

                xmlElem6 := XmlElement.Create('TIME');
                xmlElem6.Add(xmlText.Create(Format(Time)));

                xmlElem12 := XmlElement.Create('STATUSCODE');
                // if HandledInterimSalesHeader.status = HandledInterimSalesHeader.status::Dispatched then
                //     xmlElem12.Add(xmlText.Create('40'))
                // else
                //     xmlElem12.Add(xmlText.Create('17'));
                xmlElem4.Add(xmlElem5);
                xmlElem4.Add(xmlElem6);
                xmlElem4.Add(xmlElem12);

                xmlElem7 := XmlElement.Create('ORDER');

                xmlElem8 := XmlElement.Create('ORDERNUMBER');
                xmlElem8.Add(xmlText.Create(HandledInterimSalesHeader."Channel Order ID"));

                xmlElem9 := XmlElement.Create('ORDERDATE');
                xmlElem9.Add(xmlText.Create(FORMAT(HandledInterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>')));

                xmlElem7.Add(xmlElem8);
                xmlElem7.Add(xmlElem9);

                xmlElem10 := XmlElement.Create('SUPPLIER');
                xmlElem7.Add(xmlElem10);

                xmlElem11 := XmlElement.Create('BUYERREFERENCE');
                xmlElem11.Add(xmlText.Create(L_cust."Our Account No."));
                //HandledInterimSalesHeader."Web Shipping Agent"));

                xmlElem10.Add(xmlElem11);

                xmlElem4.Add(xmlElem7);
                xmlElem.Add(xmlElem4);

                IF HandledInterimSalesHeader3.GET(HandledInterimSalesHeader."Document Type", HandledInterimSalesHeader."No.") THEN BEGIN
                    HandledInterimSalesHeader3."Order Fullfilled" := TRUE;
                    HandledInterimSalesHeader3."Order Fullfillment Date" := WorkDate();
                    HandledInterimSalesHeader3.MODIFY;
                END;

            UNTIL HandledInterimSalesHeader.NEXT = 0;


            xmlDoc.Add(xmlElem);


            // Create an outStream from the Blob, notice the encoding.
            TempBlob.CreateOutStream(outStr, TextEncoding::UTF8);

            // Write the contents of the doc to the stream
            xmlDoc.WriteTo(outStr);

            // From the same Blob, that now contains the XML document, create an inStr
            TempBlob.CreateInStream(inStr, TextEncoding::UTF8);
            L_TradePartner.Reset();
            L_TradePartner.SetRange(Code, PartnerCode);
            if L_TradePartner.FindFirst() then begin
                IF (L_TradePartner."Last Date to Ex. Odr. fullfill" = 0D) OR (L_TradePartner."Last Date to Ex. Odr. fullfill" <> TODAY) THEN
                    FileCount := '00'
                ELSE
                    FileCount := INCSTR(L_TradePartner."Channel Sub Name");

                L_TradePartner."Last Date to Ex. Odr. fullfill" := TODAY;
                L_TradePartner."Channel Sub Name" := FileCount;
                L_TradePartner.MODIFY;

                // Save the data of the InStream as a file.
                fileName := L_TradePartner.Code + '.' + 'des.' + TodayDate + '.' + FileCount + '.XML';
                OrderAck.UploadFileTOAzureBlob(inStr, fileName, L_TradePartner.Code);
            end;

        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateAvailableQuantity(P_ItemNo: Code[20]; P_VariantCode: Code[20]; P_Location: Code[20]; var AvailableQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateAvailableQuantity(P_ItemNo: Code[20]; P_VariantCode: Code[20]; P_Location: Code[20]; var AvailableQty: Decimal)
    begin
    end;

    var
        StartParameter: Text;
        tempblob: Codeunit "Temp Blob";
        RunType: Text;
        Windows: Dialog;
        Text001: TextConst ENG = 'Channel Partner....';
        Text005: TextConst ENG = 'Exporting....';
}