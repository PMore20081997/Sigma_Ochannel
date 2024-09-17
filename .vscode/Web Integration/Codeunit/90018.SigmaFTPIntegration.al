codeunit 90018 "GOY File Integration"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF
            SyncOrderLabel:
                BEGIN
                    //GetFileNameFromAzure(StartParameter);
                    ImportOrders(StartParameter);

                    G_TradePartner.Reset();
                    if G_TradePartner.Get(StartParameter) then begin
                        G_TradePartner."Last Order Sync" := CurrentDateTime;
                        G_TradePartner.Modify();
                    end;
                    Message('Order Sync Completed');
                End;
            ExportDataFilesLabel:
                begin
                    PushDataFilesToContainer();
                end;
        end;
    end;

    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        ExportDataFilesLabel: Label 'ExportDataFiles';
        TempCSVBuffer: Record "CSV Buffer" temporary;
        G_TradePartner: Record "Trade Partner";
        ApiEndPoint: Text;
        IncomingContainerName: Text;
        ApiAttribute: Text;
        IncomingSasToken: Text;
        OutgoingContainerName: Text;
        OutgoingSasToken: Text;
        StorageAccountName: Text;
        SharedAccessKey: SecretText;
        ArchiveContainerName: Text;
        MasterDataContainerName: Text;

    local procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            ApiEndPoint := TradePartner."API Endpoint";
            ApiAttribute := TradePartner."API Attribute";
            IncomingContainerName := TradePartner."Incoming Order Container Name";
            IncomingSasToken := TradePartner."Incoming Order Container Token";
            OutgoingContainerName := TradePartner."Order Acknow. Container Name";
            OutgoingSasToken := TradePartner."Order Acknow. Container Token";
            StorageAccountName := TradePartner."Storage Account Name";
            SharedAccessKey := TradePartner."Shared Access Key";
            ArchiveContainerName := TradePartner."Outgoing Container 2 Name";
            MasterDataContainerName := TradePartner."Outgoing Container 3 Name";
        End;
    end;

    local procedure ImportOrders(P_ChannelCode: Code[20])
    var
        ABSBlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Interface "Storage Service Authorization";
        StorageServiceAuthorizationCodeunit: Codeunit "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerContent: Record "ABS Container Content";
        BlobInstream: InStream;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
    begin
        GetCredentials(P_ChannelCode);

        //SharedAccessKey := 'ZJiEt/NKlLT1jvt1O38DQdJ0cnEjIEdEmCpTQHUc9W2W8C77XeL26zWUbyRrEt7b2+rh7sCpNZOW+AStHx0KLw==';
        StorageServiceAuthorization := StorageServiceAuthorizationCodeunit.CreateSharedKey(SharedAccessKey);
        ABSBlobClient.Initialize(StorageAccountName, IncomingContainerName, StorageServiceAuthorization);

        Clear(Response);
        Clear(ABSContainerContent);
        Response := ABSBlobClient.ListBlobs(ABSContainerContent);
        if Response.IsSuccessful() then begin
            ABSContainerContent.Reset();
            if ABSContainerContent.FindSet() then begin
                repeat
                    Clear(BlobInstream);
                    Response := ABSBlobClient.GetBlobAsStream(ABSContainerContent."Full Name", BlobInstream);
                    if Response.IsSuccessful() then begin
                        if CU_WebOrderMgmt.CheckOrderNotExist(P_ChannelCode, ABSContainerContent."Full Name") then begin
                            if not CreateOrder(BlobInstream, P_ChannelCode, ABSContainerContent."Full Name") then
                                Error(GetLastErrorText() + '\For File - ' + ABSContainerContent."Full Name");
                        end
                        else begin
                            UploadFileToArchiveAzureContainer(BlobInstream, ABSContainerContent."Full Name", P_ChannelCode);
                        end;
                    end;
                until ABSContainerContent.Next() = 0;
            end;
        end else
            Error(GetLastErrorText());
    end;

    local procedure GetFileNameFromAzure(P_ChannelCode: Code[20])
    var
        ApiUrl: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        xmlDoc: XmlDocument;
        L_Root: XmlElement;
        L_Orders: XmlNodeList;
        L_Node: XmlNode;
        FileNameElement: XmlElement;
        L_Orders2: XmlNodeList;
        L_Node2: XmlNode;
        L_Orders3: XmlNodeList;
        L_Node3: XmlNode;
    begin
        ClearLastError();
        GetCredentials(P_ChannelCode);

        Clear(ApiUrl);
        ApiUrl := ApiEndPoint + '/' + IncomingContainerName + ApiAttribute + '&' + IncomingSasToken;

        Clear(ResponseMessage);
        Clear(ResponseText);
        Clear(Client);
        if Client.Get(ApiUrl, ResponseMessage) then begin
            if (ResponseMessage.HttpStatusCode = 200) and (ResponseMessage.IsSuccessStatusCode = true) then begin
                ResponseMessage.Content().ReadAs(ResponseText);
                if XmlDocument.ReadFrom(ResponseText, xmlDoc) then begin
                    xmlDoc.GetRoot(L_Root);
                    L_Orders := L_Root.GetChildElements('Blobs');
                    foreach L_Node in L_Orders do begin
                        Clear(L_Orders2);
                        Clear(L_Node2);
                        L_Orders2 := L_Node.AsXmlElement().GetChildElements();
                        foreach L_Node2 in L_Orders2 do begin
                            Clear(L_Orders3);
                            Clear(L_Node3);
                            L_Orders3 := L_Node2.AsXmlElement().GetChildElements();
                            foreach L_Node3 in L_Orders3 do begin
                                Clear(FileNameElement);
                                FileNameElement := L_Node3.AsXmlElement();
                                if FileNameElement.Name = 'Name' then begin
                                    ReadSpecificFileFromAzure(StartParameter, FileNameElement.InnerText);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure ReadSpecificFileFromAzure(ChannelCode: Code[20]; FileName: Text)
    var
        L_ApiUrl: Text;
        L_HttpClient: HttpClient;
        L_HttpResponseMessage: HttpResponseMessage;
        L_ResponseText: Text;
        CSVOutstream: OutStream;
        CUTempoBlob: Codeunit "Temp Blob";
        CSVInstream: InStream;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
    begin
        if CU_WebOrderMgmt.CheckOrderNotExist(ChannelCode, FileName) then begin
            Clear(L_ApiUrl);
            Clear(L_HttpClient);
            Clear(L_HttpResponseMessage);
            Clear(L_ResponseText);
            Clear(CSVOutstream);
            Clear(CSVInstream);

            L_ApiUrl := ApiEndpoint + '/' + IncomingContainerName + '/' + FileName;
            if L_HttpClient.Get(L_ApiUrl, L_HttpResponseMessage) then begin
                if (L_HttpResponseMessage.HttpStatusCode = 200) and (L_HttpResponseMessage.IsSuccessStatusCode = true) then begin
                    L_HttpResponseMessage.Content().ReadAs(L_ResponseText);
                    CUTempoBlob.CreateOutStream(CSVOutstream);
                    CSVOutstream.WriteText(L_ResponseText);
                    CUTempoBlob.CreateInStream(CSVInstream, TextEncoding::UTF8);
                    CreateOrder(CSVInstream, ChannelCode, FileName);
                end;
            end;
        end;
    end;

    [TryFunction]
    local procedure CreateOrder(var BlobInstream: InStream; P_ChannelCode: Text; FileName: Text)
    var
        RowNo: Integer;
        ColNo: Integer;
        MaxRow: Integer;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmentTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        LineNo: Integer;
        Qty: Decimal;
        L_InterimHeader: Record "Interim Sales Header";
        CustomerRef: Record "Customer Reference";
        K: Integer;
        ErrorText: Text;
    begin
        InterimSalesHeader.DeleteAll();
        InterimSalesLine.DeleteAll();
        ShipmentTracking.DeleteAll();
        PaymentDetails.DeleteAll();

        Clear(MaxRow);
        TempCSVBuffer.Reset();
        TempCSVBuffer.DeleteAll();
        TempCSVBuffer.LoadDataFromStream(BlobInstream, ',');
        if TempCSVBuffer.FindLast() then
            MaxRow := TempCSVBuffer."Line No.";

        Clear(K);
        if MaxRow > 0 then begin
            for RowNo := 1 to MaxRow do begin
                if K = 0 then
                    K := 1
                else
                    K += 1;

                Clear(LineNo);
                LineNo := K;

                #Region Insert data in temp table++++
                InterimSalesHeader.Reset();
                InterimSalesHeader.SetRange("Document Type", InterimSalesHeader."Document Type"::Order);
                InterimSalesHeader.SetRange("File Name", FileName);
                if NOT InterimSalesHeader.FindFirst() then begin
                    InterimSalesHeader.Init();
                    InterimSalesHeader.Validate("Document Type", InterimSalesHeader."Document Type"::Order);
                    InterimSalesHeader.Validate("No.", CopyStr(GetCellValue(RowNo, 12), 1, 20));
                    InterimSalesHeader.Validate("Trade Partner Code", P_ChannelCode);
                    InterimSalesHeader.Validate("ET Access Code", GetCellValue(RowNo, 1));
                    InterimSalesHeader.Validate("Channel Order ID", GetCellValue(RowNo, 2));
                    CustomerRef.Reset();
                    CustomerRef.SetRange("ET Access Code", GetCellValue(RowNo, 1));
                    if CustomerRef.FindFirst() then
                        InterimSalesHeader.Validate("Sell-to Customer No.", CustomerRef."Customer No.");
                    InterimSalesHeader.Validate("File Name", FileName);
                    InterimSalesHeader.Insert();
                end;

                //Lines++
                InterimSalesLine.Reset();
                InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
                InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                InterimSalesLine.SetRange("Line No.", LineNo);
                if NOT InterimSalesLine.FindFirst() then begin
                    InterimSalesLine.Init();
                    InterimSalesLine.Validate("Document Type", InterimSalesLine."Document Type"::Order);
                    InterimSalesLine.Validate("Document No", InterimSalesHeader."No.");
                    InterimSalesLine.Validate("Line No.", LineNo);
                    InterimSalesLine.Validate(Type, InterimSalesLine.Type::Item);
                    InterimSalesLine.Validate("Trade Partner Code", P_ChannelCode);
                    InterimSalesLine.Validate("ET Access Code", GetCellValue(RowNo, 1));
                    InterimSalesLine.Validate("Channel Order ID", InterimSalesHeader."Channel Order ID");
                    InterimSalesLine.Validate("Channel SKU", GetCellValue(RowNo, 8));
                    Clear(Qty);
                    if GetCellValue(RowNo, 9) <> '' then
                        Evaluate(Qty, GetCellValue(RowNo, 9));
                    InterimSalesLine.Quantity := Qty;
                    InterimSalesLine.Insert();
                end;
                #endregion
            end;

            #Region Insert Order in actual table++++
            if RowNo = MaxRow then begin
                Clear(InterimSalesLine);
                InterimSalesLine.Reset();
                if InterimSalesLine.FindSet() then begin
                    CUWebOrderMgt.Sigma_CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmentTracking, PaymentDetails);

                    //Send Response (Store Response File in Container)
                    L_InterimHeader.Reset();
                    L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
                    L_InterimHeader.SetRange("Channel Order ID", InterimSalesHeader."Channel Order ID");
                    if L_InterimHeader.FindFirst() then begin
                        ExportFile(L_InterimHeader, P_ChannelCode);

                        //Procedure to move file from Order to Archive Container
                        UploadFileToArchiveAzureContainer(BlobInstream, FileName, P_ChannelCode);
                    end;
                    Commit();
                end;
            end;
            #endregion
        end
        else begin
            //Procedure to move file from Order to Archive Container
            UploadFileToArchiveAzureContainer(BlobInstream, FileName, P_ChannelCode);
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

            //outputFileName := Format(DT2Date(CurrentDateTime), 0, '<Day,2><Month,2>20<Year>') + '_' + L_Line."ET Access Code" + '_' + Header."Channel Order ID";
            outputFileName := Header."File Name";

            //Procedure to Upload Reply (Order Acknowledgement) File to Reply Container
            UploadFileToReplyAzureContainer(FileInStream, outputFileName, P_ChannelCode);
        end;
    end;

    local procedure UploadFileToReplyAzureContainer(P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
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
        if not Response.IsSuccessful() then
            Error(Response.GetError());
    end;

    local procedure UploadFileToArchiveAzureContainer(var P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
    var
        ArchiveAuthorization: Interface "Storage Service Authorization";
        ArchiveStorageServiceAuthorization: Codeunit "Storage Service Authorization";
        GetFileABSBlobClient: Codeunit "ABS Blob Client";
        GetFileResponse: Codeunit "ABS Operation Response";
        FileInstream: InStream;
        ArchiveABSBlobClient: Codeunit "ABS Blob Client";
        DeleteABSBlobClient: Codeunit "ABS Blob Client";
        ArchiveResponse: Codeunit "ABS Operation Response";
        DeleteResponse: Codeunit "ABS Operation Response";
    begin
        GetCredentials(P_ChannelCode);

        Clear(ArchiveAuthorization);
        Clear(ArchiveStorageServiceAuthorization);
        ArchiveAuthorization := ArchiveStorageServiceAuthorization.CreateSharedKey(SharedAccessKey);

        #Region Getting File in Instream from Order Container
        Clear(GetFileABSBlobClient);
        GetFileABSBlobClient.Initialize(StorageAccountName, IncomingContainerName, ArchiveAuthorization);

        Clear(GetFileResponse);
        Clear(FileInstream);
        GetFileResponse := GetFileABSBlobClient.GetBlobAsStream(P_FileName, FileInstream);
        #endregion

        #Region Upload File in Archive Container and Delete from Order Container
        Clear(ArchiveABSBlobClient);
        ArchiveABSBlobClient.Initialize(StorageAccountName, ArchiveContainerName, ArchiveAuthorization);

        Clear(ArchiveResponse);
        ArchiveResponse := ArchiveABSBlobClient.PutBlobBlockBlobStream(P_FileName, FileInstream);
        if ArchiveResponse.IsSuccessful() then begin
            //Code to Delete File From Order Container
            Clear(DeleteABSBlobClient);
            DeleteABSBlobClient.Initialize(StorageAccountName, IncomingContainerName, ArchiveAuthorization);

            Clear(DeleteResponse);
            DeleteResponse := DeleteABSBlobClient.DeleteBlob(P_FileName);
            if not DeleteResponse.IsSuccessful() then
                Error(DeleteResponse.GetError());
        end;
        #endregion
    end;

    local procedure UploadFileToAzureBlob(P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
    var
        L_httpResponse: HttpResponseMessage;
        L_httpHeader: HttpHeaders;
        ApiURL: Text;
        L_httpClient: HttpClient;
        L_httpContent: HttpContent;
    begin
        ClearLastError();
        GetCredentials(P_ChannelCode);

        Clear(L_httpContent);
        Clear(L_httpHeader);
        Clear(L_httpClient);
        Clear(L_httpResponse);
        Clear(ApiURL);

        L_httpContent.WriteFrom(P_FileInstream);
        L_httpContent.GetHeaders(L_httpHeader);
        L_httpHeader.Remove('Content-Type');
        L_httpHeader.Add('x-ms-version', '2015-02-21');
        L_httpHeader.Add('x-ms-date', '2015-02-21');
        L_httpHeader.Add('x-ms-blob-type', 'BlockBlob');
        L_httpHeader.Add('Content-Type', 'text/csv');

        ApiURL := ApiEndPoint + '/' + OutgoingContainerName + '/' + P_FileName + '?' + OutgoingSasToken;
        L_httpClient.Put(ApiURL, L_httpContent, L_httpResponse);
        if L_httpResponse.HttpStatusCode = 201 then;
    end;

    local procedure GetCellValue(RowNo: Integer; ColNo: Integer): Text
    begin
        TempCSVBuffer.Reset();
        if TempCSVBuffer.Get(RowNo, ColNo) then
            exit(TempCSVBuffer.Value)
        else
            exit('')
    end;


    local procedure PushDataFilesToContainer()
    var
        TempBlob: Codeunit "Temp Blob";
        StockXmlPort: XmlPort "Stock File FTP";
        ProductXmlPort: XmlPort "Product File FTP";
        ProductScXmlPort: XmlPort "ProductSC File FTP";
        FTPOutStrm: OutStream;
        FTPInStrm: InStream;
    begin
        #Region Stock File
        Clear(TempBlob);
        Clear(FTPOutStrm);
        Clear(FTPInStrm);
        TempBlob.CreateOutStream(FTPOutStrm);
        StockXmlPort.SetDestination(FTPOutStrm);
        StockXmlPort.Export();
        TempBlob.CreateInStream(FTPInStrm, TextEncoding::UTF8);

        UploadDataFileToAzureContainer(FTPInStrm, 'stock.csv', StartParameter);
        #endregion

        #Region Product File
        Clear(TempBlob);
        Clear(FTPOutStrm);
        Clear(FTPInStrm);
        TempBlob.CreateOutStream(FTPOutStrm);
        ProductXmlPort.SetDestination(FTPOutStrm);
        ProductXmlPort.Export();
        TempBlob.CreateInStream(FTPInStrm, TextEncoding::UTF8);

        UploadDataFileToAzureContainer(FTPInStrm, 'product.csv', StartParameter);
        #endregion

        #Region Product SC File
        Clear(TempBlob);
        Clear(FTPOutStrm);
        Clear(FTPInStrm);
        TempBlob.CreateOutStream(FTPOutStrm);
        ProductScXmlPort.SetDestination(FTPOutStrm);
        ProductScXmlPort.Export();
        TempBlob.CreateInStream(FTPInStrm, TextEncoding::UTF8);

        UploadDataFileToAzureContainer(FTPInStrm, 'productsc.csv', StartParameter);
        #endregion
    end;

    local procedure UploadDataFileToAzureContainer(P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
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
        ABSBlobClient.Initialize(StorageAccountName, MasterDataContainerName, Authorization);

        Clear(Response);
        Response := ABSBlobClient.PutBlobBlockBlobStream(P_FileName, P_FileInstream);
    end;
}