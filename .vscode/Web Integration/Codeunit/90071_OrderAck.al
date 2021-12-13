codeunit 90071 "Order Acknowledgement"
{
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
                    //  ExportShopDirectAck(StartParameter);
                    ShopdirectOrderAck(StartParameter);
                End;
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
        L_httpHeader.Add('Content-Type', 'text/xml');

        TradePartner.Reset();
        TradePartner.SetRange(Code, P__ChannelCode);
        if TradePartner.FindFirst() then begin
            apiEndPoint := TradePartner."API Endpoint";
            containerName := TradePartner."Order Acknow. Conatiner Name";
            sasToken := TradePartner."Order Acknow. Token";
        end;

        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
        L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
        if ((L_httpResponse.HttpStatusCode = 200) OR (L_httpResponse.HttpStatusCode = 201)) then
            Message('file uploaded successfully.');
        //Upload--
    end;

    local procedure ExportShopDirectAck(P_ChannelCode: Code[20])
    var
        TodayDate: Text;
        ISH: Record "Interim Sales Header";
        xmlDoc: XmlDocument;
        xmlDec: XmlDeclaration;
        xmlElem: XmlElement;
        xmlElem2: XmlElement;
        Tempblob: Codeunit "Temp Blob";
        outStr: OutStream;
        inStr: InStream;
        TempFile: File;
        fileName: Text;
        FileCount: Text;
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
        ChannelPartner: Record "Trade Partner";
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
        IF GUIALLOWED THEN
            Windows.OPEN(Text001 + ' #########2#\' + Text005 + ' @1@@@@@@@@@@@@@');
        TodayDate := FORMAT(TODAY, 0, '<Month,2>_<Day,2>_<Year4>');
        TodayDate := DELCHR(TodayDate, '=', '/');
        IF GUIALLOWED THEN
            Windows.UPDATE(2, P_ChannelCode);
        ChannelPartner.Reset();
        ChannelPartner.SetRange(Code, P_ChannelCode);
        if ChannelPartner.FindFirst() then begin
            ISH.RESET;
            ISH.SETFILTER("Trade Partner Code", ChannelPartner.Code);
            ISH.SETRANGE(Status, ISH.Status::Processing);
            ISH.SETRANGE("Order Ack. Exported", FALSE);
            IF NOT ISH.ISEMPTY THEN BEGIN
                IF ChannelPartner.Code = 'SHOPDIRECT' THEN BEGIN
                    ExportOrderAckJDW2(ChannelPartner);
                END;
                /* ISH.RESET;
                 ISH.SETFILTER("Trade Partner Code", ChannelPartner.Code);
                 ISH.SETRANGE(Status, ISH.Status::Processing);
                 ISH.SETRANGE("Order Ack. Exported", FALSE);
                 IF ISH.FINDFIRST THEN
                     REPEAT
                         ISH."Order Ack. Exported" := TRUE;
                         ISH.MODIFY;
                     UNTIL ISH.NEXT = 0;*/
            END;
            IF GUIALLOWED THEN
                Windows.CLOSE;
        end;

    end;

    local procedure ExportOrderAckJDW2(P_ChannelPartner: Record "Trade Partner")
    var
        FileCount: Text;
        Customer: Record Customer;
        InterimSalesHeader: Record "Interim Sales Header";
        TodayDate: Text;
        MultilineorderNoref: Code[250];
        InterimSalesHeader2: Record "Interim Sales Header";
        InterimSalesHeader3: Record "Interim Sales Header";
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
        IF P_ChannelPartner.Code = 'SHOPDIRECT' THEN BEGIN
            xmlDoc := xmlDocument.Create();
            xmlDec := xmlDeclaration.Create('1.0', 'UTF-8', '');
            xmlDoc.SetDeclaration(xmlDec);

            xmlElem := xmlElement.Create('STATUSES');

            xmlElem2 := XmlElement.Create('SENDERADDRESS');
            xmlElem2.Add(xmlText.Create('R0200'));

            xmlElem3 := XmlElement.Create('DATATYPE');
            xmlElem3.Add(xmlText.Create('30'));

            xmlElem.Add(xmlElem2);
            xmlElem.Add(xmlElem3);
        END;

        InterimSalesHeader.RESET;
        InterimSalesHeader.SETCURRENTKEY("MultiLine Order No.");
        InterimSalesHeader.SETFILTER("Trade Partner Code", P_ChannelPartner.Code);
        InterimSalesHeader.SETRANGE(Status, InterimSalesHeader.Status::Processing);
        InterimSalesHeader.SETRANGE("Order Ack. Exported", FALSE);
        InterimSalesHeader.SETFILTER("MultiLine Order No.", '<>%1', '');
        IF InterimSalesHeader.FINDFIRST THEN
            REPEAT

                IF (MultilineorderNoref <> InterimSalesHeader."MultiLine Order No.") THEN BEGIN
                    MultilineorderNoref := InterimSalesHeader."MultiLine Order No.";

                    InterimSalesHeader2.COPYFILTERS(InterimSalesHeader);
                    InterimSalesHeader2.SETRANGE("MultiLine Order No.", MultilineorderNoref);
                    IF InterimSalesHeader2.FINDSET THEN
                        REPEAT
                            IF P_ChannelPartner.Code = 'SHOPDIRECT' THEN BEGIN
                                xmlElem4 := XmlElement.Create('STATUS');

                                xmlElem5 := XmlElement.Create('DATE');
                                xmlElem5.Add(xmlText.Create(Format(Today)));

                                xmlElem6 := XmlElement.Create('TIME');
                                xmlElem6.Add(xmlText.Create(Format(Time)));

                                xmlElem12 := XmlElement.Create('STATUSCODE');
                                xmlElem12.Add(xmlText.Create('11'));

                                xmlElem4.Add(xmlElem5);
                                xmlElem4.Add(xmlElem6);
                                xmlElem4.Add(xmlElem12);

                                xmlElem7 := XmlElement.Create('ORDER');

                                xmlElem8 := XmlElement.Create('ORDERNUMBER');
                                xmlElem8.Add(xmlText.Create(InterimSalesHeader."Channel Order ID"));

                                xmlElem9 := XmlElement.Create('ORDERDATE');
                                xmlElem9.Add(xmlText.Create(FORMAT(InterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>')));

                                xmlElem7.Add(xmlElem8);
                                xmlElem7.Add(xmlElem9);

                                xmlElem10 := XmlElement.Create('SUPPLIER');
                                xmlElem7.Add(xmlElem10);

                                xmlElem11 := XmlElement.Create('BUYERREFERENCE');
                                xmlElem11.Add(xmlText.Create(InterimSalesHeader."Web Shipping Agent"));

                                xmlElem10.Add(xmlElem11);

                                xmlElem4.Add(xmlElem7);
                                xmlElem.Add(xmlElem4);
                            END;
                            IF InterimSalesHeader3.GET(InterimSalesHeader2."Document Type", InterimSalesHeader2."No.") THEN BEGIN
                                InterimSalesHeader3."Order Ack. Exported" := TRUE;
                                InterimSalesHeader3.MODIFY;
                            END;
                        UNTIL InterimSalesHeader2.NEXT = 0;
                END;
            UNTIL InterimSalesHeader.NEXT = 0;

        InterimSalesHeader.RESET;
        InterimSalesHeader.SETCURRENTKEY("MultiLine Order No.");
        InterimSalesHeader.SETFILTER("Trade Partner Code", P_ChannelPartner.Code);
        InterimSalesHeader.SETRANGE(Status, InterimSalesHeader.Status::Processing);
        InterimSalesHeader.SETRANGE("Order Ack. Exported", FALSE);
        InterimSalesHeader.SETFILTER("MultiLine Order No.", '%1', '');
        IF InterimSalesHeader.FINDFIRST THEN
            REPEAT
                IF P_ChannelPartner.Code = 'SHOPDIRECT' THEN BEGIN

                    xmlElem4 := XmlElement.Create('STATUS');

                    xmlElem5 := XmlElement.Create('DATE');
                    xmlElem5.Add(xmlText.Create(Format(Today)));

                    xmlElem6 := XmlElement.Create('TIME');
                    xmlElem6.Add(xmlText.Create(Format(Time)));

                    xmlElem12 := XmlElement.Create('STATUSCODE');
                    xmlElem12.Add(xmlText.Create('11'));

                    xmlElem4.Add(xmlElem5);
                    xmlElem4.Add(xmlElem6);
                    xmlElem4.Add(xmlElem12);

                    xmlElem7 := XmlElement.Create('ORDER');

                    xmlElem8 := XmlElement.Create('ORDERNUMBER');
                    xmlElem8.Add(xmlText.Create(InterimSalesHeader."Channel Order ID"));

                    xmlElem9 := XmlElement.Create('ORDERDATE');
                    xmlElem9.Add(xmlText.Create(FORMAT(InterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>')));

                    xmlElem7.Add(xmlElem8);
                    xmlElem7.Add(xmlElem9);

                    xmlElem10 := XmlElement.Create('SUPPLIER');
                    xmlElem7.Add(xmlElem10);

                    xmlElem11 := XmlElement.Create('BUYERREFERENCE');
                    xmlElem11.Add(xmlText.Create(InterimSalesHeader."Web Shipping Agent"));

                    xmlElem10.Add(xmlElem11);

                    xmlElem4.Add(xmlElem7);
                    xmlElem.Add(xmlElem4);

                    IF InterimSalesHeader3.GET(InterimSalesHeader."Document Type", InterimSalesHeader."No.") THEN BEGIN
                        InterimSalesHeader3."Order Ack. Exported" := TRUE;
                        InterimSalesHeader3.MODIFY;
                    END;
                END;
            UNTIL InterimSalesHeader.NEXT = 0;
        xmlDoc.Add(xmlElem);


        // Create an outStream from the Blob, notice the encoding.
        TempBlob.CreateOutStream(outStr, TextEncoding::UTF8);

        // Write the contents of the doc to the stream
        xmlDoc.WriteTo(outStr);

        // From the same Blob, that now contains the XML document, create an inStr
        TempBlob.CreateInStream(inStr, TextEncoding::UTF8);

        IF (P_ChannelPartner."Last Date to Export Order Ack" = 0D) OR (P_ChannelPartner."Last Date to Export Order Ack" <> TODAY) THEN
            FileCount := '00'
        ELSE
            FileCount := INCSTR(P_ChannelPartner.TariffCode);

        P_ChannelPartner."Last Date to Export Order Ack" := TODAY;
        P_ChannelPartner.TariffCode := FileCount;
        P_ChannelPartner.MODIFY;

        // Save the data of the InStream as a file.
        fileName := P_ChannelPartner.Code + '.' + 'ASN.' + TodayDate + '.' + FileCount + '.XML';
        UploadFileTOAzureBlob(inStr, fileName, P_ChannelPartner.Code);
    END;

    local procedure ShopdirectOrderAck(PartnerCode: Code[10])
    var
        FileCount: Text;
        Customer: Record Customer;
        InterimSalesHeader: Record "Interim Sales Header";
        TodayDate: Text;
        MultilineorderNoref: Code[250];
        InterimSalesHeader2: Record "Interim Sales Header";
        InterimSalesHeader3: Record "Interim Sales Header";
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
        xmlDec := xmlDeclaration.Create('1.0', 'UTF-8', '');
        xmlDoc.SetDeclaration(xmlDec);

        xmlElem := xmlElement.Create('STATUSES');

        xmlElem2 := XmlElement.Create('SENDERADDRESS');
        xmlElem2.Add(xmlText.Create('R0200'));

        xmlElem3 := XmlElement.Create('DATATYPE');
        xmlElem3.Add(xmlText.Create('30'));

        xmlElem.Add(xmlElem2);
        xmlElem.Add(xmlElem3);




        InterimSalesHeader.RESET;
        InterimSalesHeader.SETFILTER("Trade Partner Code", PartnerCode);
        InterimSalesHeader.SETRANGE(Status, InterimSalesHeader.Status::Processing);
        InterimSalesHeader.SETRANGE("Order Ack. Exported", FALSE);
        IF InterimSalesHeader.FindSet() THEN begin
            REPEAT

                xmlElem4 := XmlElement.Create('STATUS');

                xmlElem5 := XmlElement.Create('DATE');
                xmlElem5.Add(xmlText.Create(Format(Today)));

                xmlElem6 := XmlElement.Create('TIME');
                xmlElem6.Add(xmlText.Create(Format(Time)));

                xmlElem12 := XmlElement.Create('STATUSCODE');
                xmlElem12.Add(xmlText.Create('11'));

                xmlElem4.Add(xmlElem5);
                xmlElem4.Add(xmlElem6);
                xmlElem4.Add(xmlElem12);

                xmlElem7 := XmlElement.Create('ORDER');

                xmlElem8 := XmlElement.Create('ORDERNUMBER');
                xmlElem8.Add(xmlText.Create(InterimSalesHeader."Channel Order ID"));

                xmlElem9 := XmlElement.Create('ORDERDATE');
                xmlElem9.Add(xmlText.Create(FORMAT(InterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>')));

                xmlElem7.Add(xmlElem8);
                xmlElem7.Add(xmlElem9);

                xmlElem10 := XmlElement.Create('SUPPLIER');
                xmlElem7.Add(xmlElem10);

                xmlElem11 := XmlElement.Create('BUYERREFERENCE');
                xmlElem11.Add(xmlText.Create(InterimSalesHeader."Web Shipping Agent"));

                xmlElem10.Add(xmlElem11);

                xmlElem4.Add(xmlElem7);
                xmlElem.Add(xmlElem4);

                IF InterimSalesHeader3.GET(InterimSalesHeader."Document Type", InterimSalesHeader."No.") THEN BEGIN
                    InterimSalesHeader3."Order Ack. Exported" := TRUE;
                    InterimSalesHeader3.MODIFY;
                END;

            UNTIL InterimSalesHeader.NEXT = 0;


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
                IF (L_TradePartner."Last Date to Export Order Ack" = 0D) OR (L_TradePartner."Last Date to Export Order Ack" <> TODAY) THEN
                    FileCount := '00'
                ELSE
                    FileCount := INCSTR(L_TradePartner.TariffCode);

                L_TradePartner."Last Date to Export Order Ack" := TODAY;
                L_TradePartner.TariffCode := FileCount;
                L_TradePartner.MODIFY;

                // Save the data of the InStream as a file.
                fileName := L_TradePartner.Code + '.' + 'ASN.' + TodayDate + '.' + FileCount + '.XML';
                OrderAck.UploadFileTOAzureBlob(inStr, fileName, L_TradePartner.Code);
            end;

        end;
    end;


    var
        StartParameter: Text;
        RunType: Text;
        Windows: Dialog;
        Text001: TextConst ENG = 'Channel Partner....';
        Text005: TextConst ENG = 'Exporting....';
}