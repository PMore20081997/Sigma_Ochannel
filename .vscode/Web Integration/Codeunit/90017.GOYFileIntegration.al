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
                    ImportOrders(StartParameter);
                    TradePartner.Get(StartParameter);
                    TradePartner."Last Order Sync" := CurrentDateTime;
                    TradePartner.Modify();
                    Message('Order Sync Completed');
                End;
            SendReplyLabel:
                begin
                    //  SyncReply(StartParameter);
                    //  Message('Reply Sent');
                end;
        end;
    end;

    /* procedure SyncReply(P_ChannelCode: Code[20])
     var
         WarePartner: Record "Warehouse Partner Setup";
         PurchHeader: Record "Purchase Header";
         PurchLine: Record "Purchase Line";
     begin
         WarePartner.Get(P_ChannelCode);
         PurchHeader.Reset();
         PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
         PurchHeader.SetRange("Location Code", WarePartner.Location);
         PurchHeader.SetRange(Status, PurchHeader.Status::Released);
         // PurchHeader.SetFilter("Expected Receipt Date", '<>%1', 0D);
         PurchHeader.SetRange("Order Created", false);
         //PurchHeader.SetFilter("Posting Date", '<>%1', 0D);
         if PurchHeader.FindSet() then begin
             repeat
                 PurchHeader.InsertInPurchaseHeader(PurchHeader);
                 PurchLine.Reset();
                 PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                 PurchLine.SetRange("Document No.", PurchHeader."No.");
                 PurchLine.SetRange(Type, PurchLine.Type::Item);
                 if PurchLine.FindSet() then begin
                     repeat
                         PurchHeader.InsertInPurchaseLine(PurchLine);
                     until PurchLine.Next() = 0;
                     ExportOrder(PurchHeader, PurchLine, P_ChannelCode);
                     PurchHeader."Order Created" := true;
                     PurchHeader.Modify(true);
                 end;
             until PurchHeader.Next() = 0;
         end;
     end;

     local procedure ExportOrder(Header: Record "Purchase Header"; Lines: Record "Purchase Line"; P_ChannelCode: Code[20])
     var
         WareRequestHeader: Record "Warehouse Request Header";
         FileOutStream: OutStream;
         FileInStream: InStream;
         outputFileName: Text[250];
         TempBlob: Codeunit "Temp Blob";
         WarePartner: Record "Warehouse Partner Setup";
     begin

         WareRequestHeader.Reset();
         WareRequestHeader.SetRange("Document Type", Header."Document Type");
         WareRequestHeader.SetRange("No.", Header."No.");
         WareRequestHeader.SetRange("Entry Type", WareRequestHeader."Entry Type"::Purchase);
         if WareRequestHeader.FindFirst() then begin
             Clear(FileOutStream);
             Clear(FileInStream);
             Clear(outputFileName);
             TempBlob.CREATEOUTSTREAM(FileOutStream);
             Xmlport.Export(Xmlport::"Export PO", FileOutStream, WareRequestHeader);
             TempBlob.CREATEINSTREAM(FileInStream);
             outputFileName := 'po_order_' + Format(CurrentDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2><Minutes,2><Seconds,2>Z') + '_' + Header."No." + '.CSV';
             WareRequestHeader."File Name" := outputFileName;
             WareRequestHeader.Modify();
             // outputFileName := 'po_order_' + Header."No." + '.csv';
             // DownloadFromStream(FileInStream, '', '', '', outputFileName);
             UploadFileTOAzureBlob(FileInStream, outputFileName, P_ChannelCode);

         end;
     end;*/

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
        L_httpHeader.Add('Content-Type', 'application/octet-stream');

        L_Partner.Reset();
        L_Partner.SetRange(Code, P__ChannelCode);
        if L_Partner.FindFirst() then begin
            apiEndPoint := L_Partner."API Endpoint";
            containerName := L_Partner."Outgoing Container 2 Name";
            sasToken := L_Partner."Outgoing Container 2 Token";
        end;

        // apiEndPoint := 'https://shopdirect.blob.core.windows.net';
        // containerName := 'teststupdin';
        // sasToken := 'sp=racwl&st=2021-06-18T09:59:46Z&se=2021-07-30T17:59:46Z&spr=https&sv=2020-02-10&sr=c&sig=GMoLncjHNc0eY2KCSDN%2BnVw819%2FmQJdKmp5ZamBst5k%3D';

        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
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
            if GetCellValue(RowNo, 3) = 'Pend' then begin
                Clear(LineNo);
                Evaluate(LineNo, GetCellValue(RowNo, 7));
                InterimSalesHeader.Reset();
                InterimSalesHeader.SetRange("Document Type", InterimSalesHeader."Document Type"::Order);
                InterimSalesHeader.SetRange("Trade Partner Code", GetCellValue(RowNo, 1));
                InterimSalesHeader.SetRange("File Name", GetCellValue(RowNo, 12));
                if NOT InterimSalesHeader.FindFirst() then begin
                    InterimSalesHeader.Init();
                    InterimSalesHeader.Validate("Document Type", InterimSalesHeader."Document Type"::Order);
                    InterimSalesHeader.Validate("No.", CopyStr(GetCellValue(RowNo, 12), 1, 20));
                    InterimSalesHeader.Validate("Trade Partner Code", GetCellValue(RowNo, 1));
                    InterimSalesHeader.Validate("Channel Order ID", GetCellValue(RowNo, 12));
                    InterimSalesHeader.Validate("Sell-to Customer No.", GetCellValue(RowNo, 2));
                    InterimSalesHeader.Validate("File Name", GetCellValue(RowNo, 12));
                    InterimSalesHeader.Insert();
                end;
                InterimSalesLine.Reset();
                InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
                InterimSalesLine.SetRange("Trade Partner Code", GetCellValue(RowNo, 1));
                InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                InterimSalesLine.SetRange("Line No.", LineNo);
                if NOT InterimSalesLine.FindFirst() then begin
                    InterimSalesLine.Init();
                    InterimSalesLine.Validate("Document Type", InterimSalesLine."Document Type"::Order);
                    InterimSalesLine.Validate("Document No", InterimSalesHeader."No.");
                    InterimSalesLine.Validate("Line No.", LineNo);
                    InterimSalesLine.Validate(Type, InterimSalesLine.Type::Item);
                    InterimSalesLine.Validate("Trade Partner Code", GetCellValue(RowNo, 1));
                    InterimSalesLine.Validate("Channel Order ID", InterimSalesHeader."Channel Order ID");
                    InterimSalesLine.Validate("Channel SKU", GetCellValue(RowNo, 8));
                    Clear(Qty);
                    Evaluate(Qty, GetCellValue(RowNo, 9));
                    InterimSalesLine.Quantity := Qty;
                    InterimSalesLine.Insert();
                end;
            end;
        end;

        if RowNo = MaxRow then begin
            InterimSalesLine.Reset();
            if InterimSalesLine.FindSet() then begin
                repeat
                until InterimSalesLine.Next() = 0;
                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
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