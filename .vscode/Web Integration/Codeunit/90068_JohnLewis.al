codeunit 90068 "John Lewis Integration"
{
    TableNo = 472;
    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE StartParameter OF
            'JOHNLEWIS':
                BEGIN
                    GetFileNameFromAzure(StartParameter);
                    // ImportWebOrders('JOHNLEWIS', '$E000513.ORD');
                End;
        end;
    end;

    local procedure GetFileNameFromAzure(P_ChannelCode: Code[10])
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
        //apiEndPoint := 'https://johnlewis1.blob.core.windows.net';
        //containerName := 'jlptest';
        //apiattribute := '?restype=container&comp=list';
        // sasToken := 'sp=racwdl&st=2021-07-12T07:44:03Z&se=2026-07-12T15:44:03Z&spr=https&sv=2020-08-04&sr=c&sig=L6CUgLsxE3aMa7chb1g%2BKQPhFKPmS5pT4RZ%2FWAA8z3Q%3D';
        apiUrl := apiEndPoint + '/' + containerName + apiattribute + '&' + sasToken;

        httpClient.Get(apiUrl, httpResponse);
        if (httpResponse.HttpStatusCode = 200) then begin
            if (httpResponse.IsSuccessStatusCode = true) then begin

                //++
                TradePartner."Last Order Sync" := CreateDateTime(WorkDate, Time);
                TradePartner.Modify;
                //--

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
                                    ImportWebOrders(StartParameter, e.InnerText, apiEndPoint, containerName);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            Message('Order Sync Completed...');
        end;
    end;

    procedure ImportWebOrders(P_ChannelCode: Code[20]; FileName: Text; P_Endpoint: Text; P_ContainerName: Text)
    var
        httpClient: HttpClient;
        httpResponse: HttpResponseMessage;
        apiUrl: Text;
        apiEndPoint: Text;
        containerName: Text;
        CSVOutstream: OutStream;
        CUTempoBlob: Codeunit "Temp Blob";
        CSVInstream: InStream;
        csvBuffer: Record "CSV Buffer";
        ResponseText: Text;
        L_List: List of [text];
        DoubleQuote: Code[2];
        SingleQuote: Code[1];
        L_InterimHeader: Record "Interim Sales Header" temporary;
        L_No: Code[20];
        L_TradePartner: Record "Trade Partner";
        ResponseText2: Text;
        FileLineNo: Integer;
        FileData: List of [text];
        L_InterimLine: Record "Interim Sales Line" temporary;
        L_CrossRef: Record "Item Reference";
        L_Pos: Integer;
        L_ShipmnetTracking: Record "Shipment Tracking" temporary;
        L_PaymentDetails: Record "Channel Media" temporary;
        ShippingRule: Record "Shipping Rule";
        L_DateText: Text;
        L_ExternalDocument: Code[20];
    begin
        ClearLastError();
        Clear(ResponseText);
        Clear(DoubleQuote);
        Clear(SingleQuote);
        DoubleQuote := '''';
        SingleQuote := CopyStr(DoubleQuote, 1, 1);
        Clear(FileLineNo);
        apiEndPoint := P_Endpoint;
        containerName := P_ContainerName;
        apiUrl := apiEndPoint + '/' + containerName + '/' + FileName;

        httpClient.Get(apiUrl, httpResponse);
        if (httpResponse.HttpStatusCode = 200) then begin
            if (httpResponse.IsSuccessStatusCode = true) then begin

                httpResponse.Content().ReadAs(ResponseText);

                L_InterimHeader.DeleteAll();
                L_InterimLine.DeleteAll();
                L_ShipmnetTracking.DeleteAll();
                L_PaymentDetails.DeleteAll();

                CUTempoBlob.CreateOutStream(CSVOutstream);
                CSVOutstream.WriteText(ResponseText);

                CUTempoBlob.CreateInStream(CSVInstream, TextEncoding::UTF8);

                CSVInstream.ReadText(ResponseText);
                csvBuffer.DeleteAll();
                csvBuffer.LoadDataFromStream(CSVInstream, SingleQuote);

                IF csvBuffer.GetNumberOfLines() > 0 then begin
                    IF csvBuffer.FindSet() then
                        repeat
                            Clear(L_List);
                            Clear(ResponseText2);
                            L_List := csvBuffer.Value.Split('/');
                            if L_List.Count > 0 then begin
                                ResponseText2 := L_List.Get(1);
                                if ResponseText2 <> '' then begin
                                    FileLineNo += 1;
                                    Clear(FileData);
                                    FileData := ResponseText2.Split('+');
                                    if CopyStr(ResponseText2, 1, 3) = 'UNH' then begin
                                        if FileData.Get(2) <> '' then begin
                                            Clear(L_ExternalDocument);
                                            L_ExternalDocument := FileData.Get(2);
                                        end;
                                    end;

                                    if CopyStr(ResponseText2, 1, 3) = 'BGM' then begin
                                        if FileData.Get(3) <> '' then begin
                                            Clear(L_No);
                                            L_InterimHeader.Reset();
                                            L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
                                            if L_InterimHeader.FindLast() then
                                                L_No := IncStr(L_InterimHeader."No.")
                                            else
                                                L_No := '10000';
                                            L_InterimHeader.Init();
                                            L_InterimHeader.Validate("Document Type", L_InterimHeader."Document Type"::Order);
                                            L_InterimHeader."No." := L_No;
                                            L_TradePartner.Reset();
                                            L_TradePartner.SetRange(Code, StartParameter);
                                            if L_TradePartner.FindFirst() then begin
                                                L_InterimHeader.Validate("Trade Partner Code", L_TradePartner.Code);
                                                L_InterimHeader.Validate("Sell-to Customer No.", L_TradePartner."Customer No.");
                                                L_InterimHeader.Validate("Location Code", L_TradePartner.Location);
                                                ShippingRule.Reset();
                                                ShippingRule.SetRange("Channel Code", StartParameter);
                                                ShippingRule.SetRange("Web Shipping Agent", '10');
                                                if ShippingRule.FindFirst() then begin
                                                    L_InterimHeader.Validate("Shipping Agent Code", ShippingRule."Shipping Agent");
                                                end;
                                                L_InterimHeader.Validate("File Name", FileName);
                                                L_InterimHeader.Validate("Channel Order ID", FileData.Get(3));
                                                L_InterimHeader.Validate("External Document No.", L_ExternalDocument);
                                                L_InterimHeader.Insert(true);
                                            end;
                                        end;
                                    end;


                                    if CopyStr(ResponseText2, 1, 5) = 'DTM+2' then begin
                                        Clear(L_Pos);
                                        Clear(L_DateText);
                                        if FileData.Get(2) <> '' then begin
                                            L_Pos := StrPos(FileData.Get(2), ':');
                                            L_DateText := CopyStr(FileData.Get(2), L_Pos + 1, 8);
                                            Evaluate(L_InterimHeader."Shipment Date", CopyStr(L_DateText, 5) + CopyStr(L_DateText, 1, 4));
                                            L_InterimHeader.Modify(true);
                                        end;
                                    end;

                                    if CopyStr(ResponseText2, 1, 6) = 'DTM+137' then begin
                                        Clear(L_Pos);
                                        Clear(L_DateText);
                                        if FileData.Get(2) <> '' then begin
                                            L_Pos := StrPos(FileData.Get(2), ':');
                                            L_DateText := CopyStr(FileData.Get(2), L_Pos + 1, 8);
                                            Evaluate(L_InterimHeader."Document Date", CopyStr(L_DateText, 5) + CopyStr(L_DateText, 1, 4));
                                            L_InterimHeader.Modify(true);
                                        end;
                                    end;
                                    //if CopyStr(FileName, StrPos(FileName, '.'), 4) = '.txt' then begin
                                    if CopyStr(ResponseText2, 1, 6) = 'NAD+DP' then begin
                                        if FileData.Get(5) <> '' then
                                            L_InterimHeader.Validate("Ship-to Name", FileData.Get(5));
                                        if FileData.Get(6) <> '' then
                                            L_InterimHeader.Validate("Ship-to Address", FileData.Get(6));
                                        if FileData.Get(7) <> '' then
                                            L_InterimHeader.Validate("Ship-to City", FileData.Get(7));
                                        if FileData.Get(9) <> '' then
                                            L_InterimHeader.Validate("Ship-to Post Code", FileData.Get(9));
                                        L_InterimHeader.Modify(true);
                                    end;
                                    /*end else
                                        if CopyStr(FileName, StrPos(FileName, '.'), 4) = '.ORC' then begin
                                            if FileLineNo = 10 then begin
                                                if FileData.Get(5) <> '' then
                                                    L_InterimHeader.Validate("Ship-to Name", FileData.Get(5));
                                                if FileData.Get(6) <> '' then
                                                    L_InterimHeader.Validate("Ship-to Address", FileData.Get(6));
                                                if FileData.Get(7) <> '' then
                                                    L_InterimHeader.Validate("Ship-to City", FileData.Get(7));
                                                if FileData.Get(9) <> '' then
                                                    L_InterimHeader.Validate("Ship-to Post Code", FileData.Get(9));
                                                L_InterimHeader.Modify(true);
                                            end;
                                        end;*/
                                    if CopyStr(ResponseText2, 1, 3) = 'CUX' then begin
                                        if FileData.Get(2) <> '' then begin
                                            L_InterimHeader.Validate("Currency Code", CopyStr(FileData.Get(2), 3, 3));
                                            L_InterimHeader.Modify(true);
                                        end;
                                    end;
                                    if CopyStr(ResponseText2, 1, 3) = 'LIN' then begin
                                        L_InterimLine.Init();
                                        L_InterimLine."Document Type" := L_InterimLine."Document Type"::Order;
                                        L_InterimLine."Document No" := L_InterimHeader."No.";
                                        L_InterimLine."Line No." += 10000;
                                        L_InterimLine.Validate("Trade Partner Code", StartParameter);
                                        L_InterimLine."Channel Order ID" := L_InterimHeader."Channel Order ID";
                                        Clear(L_Pos);
                                        if FileData.Get(4) <> '' then begin
                                            L_Pos := StrPos(FileData.Get(4), ':');
                                            L_InterimLine.Validate("Channel SKU", CopyStr(FileData.Get(4), 1, L_Pos - 1));
                                        end;
                                        L_InterimLine.Insert(true);
                                    end;
                                    if CopyStr(ResponseText2, 1, 3) = 'IMD' then begin
                                        Clear(L_Pos);
                                        if FileData.Get(4) <> '' then begin
                                            L_Pos := StrPos(FileData.Get(4), ':');
                                            L_InterimLine.Validate(Description, CopyStr(FileData.Get(4), L_Pos + 1));
                                            L_InterimLine.Modify(true);
                                        end;
                                    end;
                                    if CopyStr(ResponseText2, 1, 3) = 'QTY' then begin
                                        Clear(L_Pos);
                                        if FileData.Get(2) <> '' then begin
                                            L_Pos := StrPos(FileData.Get(2), ':');
                                            Evaluate(L_InterimLine.Quantity, CopyStr(FileData.Get(2), L_Pos + 1));
                                            L_InterimLine.Modify(true);
                                        end;
                                    end;
                                    if CopyStr(ResponseText2, 1, 3) = 'PRI' then begin
                                        if FileData.Get(2) <> '' then begin
                                            if CopyStr(FileData.Get(2), 1, 3) = 'AAA' then begin
                                                Clear(L_Pos);
                                                L_Pos := StrPos(FileData.Get(2), ':');
                                                Evaluate(L_InterimLine."Unit Price", CopyStr(FileData.Get(2), L_Pos + 1));
                                                L_InterimLine.Modify(true);
                                            end;
                                        end;
                                    end;
                                end;
                                if CopyStr(ResponseText2, 1, 3) = 'UNT' then begin
                                    CUWebOrderMgt.CreateWebOrder(L_InterimHeader, L_InterimLine, L_ShipmnetTracking, L_PaymentDetails);
                                    L_InterimHeader.DeleteAll();
                                    L_InterimLine.DeleteAll();
                                end;

                            end;

                        until csvBuffer.Next() = 0;

                end;
            end;
        end;
    end;

    var
        StartParameter: Text;
        RunType: Text;
        Windows: Dialog;
        Text001: TextConst ENG = 'Channel Partner....';
        Text005: TextConst ENG = 'Exporting....';
        CUWebOrderMgt: Codeunit "Web Order Mgt";
}