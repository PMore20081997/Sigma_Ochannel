codeunit 90018 "GOY File Integration"
{
    TableNo = "Job Queue Entry";

    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SendReplyLabel: Label 'SendReply';

        TempCSVBuffer: Record "CSV Buffer" temporary;
        TradePartner: Record "Trade Partner";

    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF
            SyncOrderLabel:
                BEGIN
                    GetFileNameFromAzure(StartParameter);
                    //ImportOrders(StartParameter);
                    TradePartner.Get(StartParameter);
                    TradePartner."Last Order Sync" := CurrentDateTime;
                    TradePartner.Modify();
                    Message('Order Sync Completed');
                End;
        end;
    end;

    local procedure GetFileNameFromAzure(P_ChannelCode: Code[20])
    var
        apiEndPoint: Text;
        containerName: Text;
        apiattribute: Text;
        sasToken: Text;
        apiUrl: Text;
        httpClient: HttpClient;
        httpResponse: HttpResponseMessage;
        ResponseText: Text;
        xmlDoc: XmlDocument;
        L_Root: XmlElement;
        L_Orders: XmlNodeList;
        L_Node: XmlNode;
        e: XmlElement;
        L_Orders2: XmlNodeList;
        L_Node2: XmlNode;
        L_Orders3: XmlNodeList;
        L_Node3: XmlNode;
        TradePartner: Record "Trade Partner";
    begin
        ClearLastError();
        TradePartner.Reset();
        TradePartner.SetRange(Code, P_ChannelCode);
        if TradePartner.FindFirst() then begin
            apiEndPoint := TradePartner."API Endpoint";
            apiattribute := TradePartner."API Attribute";
            containerName := TradePartner."Incoming Orders Conatiner Name";
            sasToken := TradePartner."Incoming Orders Token";
        end;
        //apiEndPoint := 'https://sigmaplc.blob.core.windows.net';
        //containerName := 'order';
        // apiattribute := '?restype=container&comp=list';
        // sasToken := 'sp=racwdli&st=2023-12-14T11:04:51Z&se=2023-12-14T19:04:51Z&spr=https&sv=2022-11-02&sr=c&sig=slXm4FAuDyf5nsd%2Fg%2FFwG5q1qwP5t5Qowy%2FydM%2B8SJQ%3D';
        apiUrl := apiEndPoint + '/' + containerName + apiattribute + '&' + sasToken;

        httpClient.Get(apiUrl, httpResponse);
        if (httpResponse.HttpStatusCode = 200) then begin
            if (httpResponse.IsSuccessStatusCode = true) then begin
                httpResponse.Content().ReadAs(ResponseText);
                if XmlDocument.ReadFrom(ResponseText, xmlDoc) then begin
                    xmlDoc.GetRoot(L_Root);
                    L_Orders := L_Root.GetChildElements('Blobs');
                    foreach L_Node in L_Orders do begin
                        Clear(e);
                        e := L_Node.AsXmlElement();
                        Clear(L_Orders2);
                        Clear(L_Node2);
                        L_Orders2 := L_Node.AsXmlElement().GetChildElements();
                        foreach L_Node2 in L_Orders2 do begin
                            Clear(e);
                            e := L_Node2.AsXmlElement();
                            Clear(L_Orders3);
                            Clear(L_Node3);
                            L_Orders3 := L_Node2.AsXmlElement().GetChildElements();
                            foreach L_Node3 in L_Orders3 do begin
                                Clear(e);
                                e := L_Node3.AsXmlElement();
                                if e.Name = 'Name' then begin
                                    ReadSpecificFileFromAzure(StartParameter, e.InnerText);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            Message('Order Sync Completed...');
        end;
    end;

    local procedure ReadSpecificFileFromAzure(ChannelCode: Code[20]; FileName: Text)
    var
        L_ApiUrl: Text;
        L_HttpClient: HttpClient;
        L_HttpResponse: HttpResponseMessage;
        L_ApiEndpoint: Text;
        L_ContainerName: Text;
        L_ResponseText: Text;
        CSVOutstream: OutStream;
        CUTempoBlob: Codeunit "Temp Blob";
        CSVInstream: InStream;
        csvBuffer: Record "CSV Buffer";
        xmlDoc: XmlDocument;
        L_Root: XmlElement;
        L_Orders: XmlNodeList;
        L_Node: XmlNode;
        e: XmlElement;
        L_InterimHeader: Record "Interim Sales Header" temporary;
        L_InterimLine: Record "Interim Sales Line" temporary;
        L_Orders2: XmlNodeList;
        L_Node2: XmlNode;
        L_Orders3: XmlNodeList;
        L_Node3: XmlNode;
        L_Orders4: XmlNodeList;
        L_Node4: XmlNode;
        L_Orders5: XmlNodeList;
        L_Node5: XmlNode;
        L_Orders6: XmlNodeList;
        L_Node6: XmlNode;
        L_Count: Integer;
        L_ShipmnetTracking: Record "Shipment Tracking" temporary;
        L_PaymentDetails: Record "Channel Media" temporary;
        e2: XmlElement;
        L_No: Code[20];
        Flag: Boolean;
        L_TradePartner: Record "Trade Partner";
        ShippingRule: Record "Shipping Rule";
        BlobInstream: InStream;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";

    begin
        Clear(L_ApiUrl);
        Clear(L_HttpClient);
        Clear(L_HttpResponse);
        Clear(L_ApiEndpoint);
        Clear(L_ContainerName);
        Clear(L_ResponseText);
        Clear(L_TradePartner);
        //headers.Remove('Content-Type');
        //headers.Add('Content-Type', 'application/json');
        L_TradePartner.Get(ChannelCode);
        L_ApiEndpoint := L_TradePartner."API Endpoint";
        L_ContainerName := L_TradePartner."Incoming Orders Conatiner Name";
        L_ApiUrl := L_ApiEndpoint + '/' + L_ContainerName + '/' + FileName;
        L_HttpClient.Get(L_ApiUrl, L_HttpResponse);
        if L_HttpResponse.HttpStatusCode = 200 then begin
            if (L_HttpResponse.IsSuccessStatusCode = true) then begin
                L_HttpResponse.Content().ReadAs(L_ResponseText);
                CUTempoBlob.CreateOutStream(CSVOutstream);
                CSVOutstream.WriteText(L_ResponseText);

                CUTempoBlob.CreateInStream(CSVInstream, TextEncoding::UTF8);

                CSVInstream.ReadText(L_ResponseText);

                CreateOrder(CSVInstream, StartParameter, FileName);
            end;
        end;
    end;


    procedure ExportFile(Header: Record "Interim Sales Header"; P_ChannelCode: Code[20])
    var
        FileOutStream: OutStream;
        FileInStream: InStream;
        outputFileName: Text[250];
        TempBlob: Codeunit "Temp Blob";
        L_Line: Record "Interim Sales Line";
    begin
        L_Line.Reset();
        L_Line.SetRange("Document Type", L_Line."Document Type"::Order);
        L_Line.SetRange("Document No", Header."No.");
        L_Line.SetRange(Type, L_Line.Type::Item);
        if L_Line.FindSet() then begin
            Clear(FileOutStream);
            Clear(FileInStream);
            Clear(outputFileName);
            TempBlob.CREATEOUTSTREAM(FileOutStream);
            Xmlport.Export(Xmlport::"Export File", FileOutStream, L_Line);
            TempBlob.CREATEINSTREAM(FileInStream);
            //outputFileName := Format(CurrentDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2><Minutes,2><Seconds,2>') + 'GOYNORreply' + '.CSV';
            outputFileName := Format(DT2Date(CurrentDateTime), 0, '<Day,2><Month,2>20<Year>') + L_Line."ET Access Code" + 'reply.csv';
            //DownloadFromStream(FileInStream, '', '', '', outputFileName);
            UploadFileTOAzureBlob(FileInStream, outputFileName, P_ChannelCode);
        end;
    end;

    local procedure UploadFileTOAzureBlob(P_FileInstream: InStream; P_FileName: Text; P__ChannelCode: Code[20])
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
        L_Partner: Record "Trade Partner";
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
        L_httpHeader.Add('Content-Type', 'text/csv');

        L_Partner.Reset();
        L_Partner.SetRange(Code, P__ChannelCode);
        if L_Partner.FindFirst() then begin
            apiEndPoint := 'https://sigmaplc.blob.core.windows.net';
            containerName := L_Partner."Outgoing Container 2 Name";
            sasToken := L_Partner."Outgoing Container 2 Token";
        end;

        // apiEndPoint := 'https://shopdirect.blob.core.windows.net';
        // containerName := 'teststupdin';
        // sasToken := 'sp=racwl&st=2021-06-18T09:59:46Z&se=2021-07-30T17:59:46Z&spr=https&sv=2020-02-10&sr=c&sig=GMoLncjHNc0eY2KCSDN%2BnVw819%2FmQJdKmp5ZamBst5k%3D';

        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + '?' + sasToken;
        L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
        if L_httpResponse.HttpStatusCode = 201 then;
        // Message('file uploaded successfully.');
        //Upload--
    end;

    local procedure ImportOrders(StartParameter: Text)
    var
        ChannelPartnerSetup: Record "Trade Partner";
        ABSBlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Interface "Storage Service Authorization";
        StorageServiceAuthorizationCodeunit: Codeunit "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerContent: Record "ABS Container Content";
        SharedKey: Text;
        EndPoint: Text;
        StoratgeAccount: Text;
        ContainerName: Text;
        BlobInstream: InStream;
    begin
        ChannelPartnerSetup.Get(StartParameter);
        SharedKey := ChannelPartnerSetup."Incoming Orders Token";
        StoratgeAccount := ChannelPartnerSetup."API Endpoint";
        ContainerName := ChannelPartnerSetup."Incoming Orders Conatiner Name";
        StorageServiceAuthorization := StorageServiceAuthorizationCodeunit.CreateSharedKey(SharedKey);
        ABSBlobClient.Initialize(StoratgeAccount, ContainerName, StorageServiceAuthorization);

        Response := ABSBlobClient.ListBlobs(ABSContainerContent);
        if Response.IsSuccessful() then begin
            ABSContainerContent.Reset();
            if ABSContainerContent.FindSet() then
                repeat
                    Response := ABSBlobClient.GetBlobAsStream(ABSContainerContent."Full Name", BlobInstream);
                    if Response.IsSuccessful() then begin
                        CreateOrder(BlobInstream, StartParameter, ABSContainerContent."Full Name");
                    end else
                        Error(GetLastErrorText());
                until ABSContainerContent.Next() = 0;
        end else
            Error(GetLastErrorText());
    end;

    local procedure CreateOrder(BlobInstream: InStream; StartParameter: Text; FileName: Text[2048])
    var
        RowNo: Integer;
        ColNo: Integer;
        MaxRow: Integer;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        LineNo: Integer;
        Qty: Decimal;
        L_Header: Record "Interim Sales Header";
        L_Line: Record "Interim Sales Line";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_OrderLevelResponse: Record "Order Level Response";
        L_ProductLevelResponse: Record "Product Level Response";
    begin
        TempCSVBuffer.Reset();
        TempCSVBuffer.DeleteAll();
        TempCSVBuffer.LoadDataFromStream(BlobInstream, ',');
        InterimSalesHeader.DeleteAll();
        InterimSalesLine.DeleteAll();
        ShipmnetTracking.DeleteAll();
        PaymentDetails.DeleteAll();
        TempCSVBuffer.Reset();
        if TempCSVBuffer.FindLast() then
            MaxRow := TempCSVBuffer."Line No.";
        for RowNo := 1 to MaxRow do begin
            //if GetCellValue(RowNo, 3) = 'Pending' then begin
            Clear(LineNo);
            Evaluate(LineNo, GetCellValue(RowNo, 7));
            InterimSalesHeader.Reset();
            InterimSalesHeader.SetRange("Document Type", InterimSalesHeader."Document Type"::Order);
            //InterimSalesHeader.SetRange("Trade Partner Code", GetCellValue(RowNo, 1));
            InterimSalesHeader.SetRange("File Name", FileName);
            if NOT InterimSalesHeader.FindFirst() then begin
                InterimSalesHeader.Init();
                InterimSalesHeader.Validate("Document Type", InterimSalesHeader."Document Type"::Order);
                InterimSalesHeader.Validate("No.", CopyStr(GetCellValue(RowNo, 12), 1, 20));
                InterimSalesHeader.Validate("Trade Partner Code", StartParameter);
                InterimSalesHeader.Validate("ET Access Code", GetCellValue(RowNo, 1));
                InterimSalesHeader.Validate("Channel Order ID", FileName);
                InterimSalesHeader.Validate("Sell-to Customer No.", GetCellValue(RowNo, 2));
                InterimSalesHeader.Validate("File Name", FileName);
                InterimSalesHeader.Insert();
            end;
            InterimSalesLine.Reset();
            InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
            //InterimSalesLine.SetRange("Trade Partner Code", GetCellValue(RowNo, 1));
            InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
            InterimSalesLine.SetRange("Line No.", LineNo);
            if NOT InterimSalesLine.FindFirst() then begin
                InterimSalesLine.Init();
                InterimSalesLine.Validate("Document Type", InterimSalesLine."Document Type"::Order);
                InterimSalesLine.Validate("Document No", InterimSalesHeader."No.");
                InterimSalesLine.Validate("Line No.", LineNo);
                InterimSalesLine.Validate(Type, InterimSalesLine.Type::Item);
                InterimSalesLine.Validate("Trade Partner Code", InterimSalesHeader."Trade Partner Code");
                InterimSalesLine.Validate("ET Access Code", GetCellValue(RowNo, 1));
                InterimSalesLine.Validate("Channel Order ID", InterimSalesHeader."Channel Order ID");
                InterimSalesLine.Validate("Channel SKU", GetCellValue(RowNo, 8));
                Clear(Qty);
                Evaluate(Qty, GetCellValue(RowNo, 9));
                InterimSalesLine.Quantity := Qty;
                InterimSalesLine.Insert();
            end;
            //end;
        end;

        if RowNo = MaxRow then begin
            InterimSalesLine.Reset();
            if InterimSalesLine.FindSet() then begin
                repeat
                until InterimSalesLine.Next() = 0;
                CUWebOrderMgt.Sigma_CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

                //Update Interim header and Interim Line Response Code and Message++
                L_Header.Reset();
                L_Header.SetRange("Document Type", L_Header."Document Type"::Order);
                L_Header.SetRange("Channel Order ID", InterimSalesHeader."Channel Order ID");
                if L_Header.FindFirst() then begin
                    //Header++
                    PartnerErrorLog.RESET;
                    PartnerErrorLog.SETRANGE("Document No.", L_Header."No.");
                    PartnerErrorLog.SetFilter("Item No.", '%1', '');
                    PartnerErrorLog.SetCurrentKey("Sequence No.");
                    PartnerErrorLog.Ascending(true);
                    IF PartnerErrorLog.FindFirst() THEN begin
                        L_OrderLevelResponse.Reset();
                        L_OrderLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                        if L_OrderLevelResponse.FindFirst() then begin
                            L_Header."Reason Code" := L_OrderLevelResponse.Reason;
                            L_Header."Reason Message" := L_OrderLevelResponse.Message;
                            L_Header.Modify();
                        end;
                    end else begin
                        L_Header."Reason Code" := 'Order Created';
                        L_Header."Reason Message" := 'Accepted';
                        L_Header.Modify();

                    end;

                    //Line++
                    L_Line.Reset();
                    L_Line.SetRange("Document Type", L_Header."Document Type");
                    L_Line.SetRange("Document No", L_Header."No.");
                    if L_Line.FindSet() then begin
                        repeat
                            PartnerErrorLog.RESET;
                            PartnerErrorLog.SETRANGE("Document No.", L_Header."No.");
                            PartnerErrorLog.SetFilter("Item No.", L_Line."No.");
                            PartnerErrorLog.SetCurrentKey("Sequence No.");
                            PartnerErrorLog.Ascending(true);
                            IF PartnerErrorLog.FindFirst() THEN begin
                                L_ProductLevelResponse.Reset();
                                L_ProductLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                                if L_ProductLevelResponse.FindFirst() then begin
                                    if L_ProductLevelResponse."Error Code" = 'SEQ13' then begin
                                        L_Line."Reason Code" := L_ProductLevelResponse.Reason;
                                        L_Line."Reason Message" := PartnerErrorLog.Attribute + ' ' + L_ProductLevelResponse.Message;
                                        L_Line.Modify();
                                    end else begin
                                        L_Line."Reason Code" := L_ProductLevelResponse.Reason;
                                        L_Line."Reason Message" := L_ProductLevelResponse.Message;
                                        L_Line.Modify();
                                    end;
                                end;
                            end else begin
                                L_Line."Reason Code" := 'Order Line Created';
                                L_Line."Reason Message" := 'Successful';
                                L_Line.Modify();
                            end;
                        until L_Line.Next() = 0;
                    end;
                end;

                //Update Status in Interim Sales Header++
                L_Header.Reset();
                L_Header.SetRange("Document Type", L_Header."Document Type"::Order);
                L_Header.SetRange("Channel Order ID", InterimSalesHeader."Channel Order ID");
                L_Header.SetRange("Reason Message", 'Accepted');
                if L_Header.FindFirst() then begin
                    L_Line.Reset();
                    L_Line.SetRange("Document Type", L_Header."Document Type");
                    L_Line.SetRange("Document No", L_Header."No.");
                    L_Line.SetFilter("Reason Message", '<>%1', 'Successful');
                    if L_Line.FindFirst() then begin
                        L_Header.status := L_Header.status::Confirmed;
                        L_Header.Modify();
                    end else begin
                        L_Header.status := L_Header.status::"In Progress";
                        L_Header."Ready to process" := true;
                        L_Header.Modify();
                    end;
                end else begin
                    L_Header.status := L_Header.status::Confirmed;
                    L_Header.Modify();
                end;

                ExportFile(L_Header, StartParameter);

            end;
        end;
    end;

    local procedure GetCellValue(RowNo: Integer; ColNo: Integer): Text
    begin
        TempCSVBuffer.Reset();
        if TempCSVBuffer.Get(RowNo, ColNo) then
            exit(TempCSVBuffer.Value)
        else
            exit('')
    end;


}