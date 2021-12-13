codeunit 90070 "Shopdirect Integration"
{
    TableNo = 472;
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
        //apiEndPoint := 'https://shopdirect.blob.core.windows.net';
        //containerName := 'testin';
        // apiattribute := '?restype=container&comp=list';
        // sasToken := 'sp=racwdl&st=2021-07-31T09:50:32Z&se=2026-07-31T17:50:32Z&spr=https&sv=2020-08-04&sr=c&sig=5eq5v3dlDu5urK%2BC1egbie0OHjERYgidYQftlEqOT4U%3D';
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
    begin
        Clear(L_ApiUrl);
        Clear(L_HttpClient);
        Clear(L_HttpResponse);
        Clear(L_ApiEndpoint);
        Clear(L_ContainerName);
        Clear(L_ResponseText);
        Clear(L_TradePartner);
        L_TradePartner.Get(ChannelCode);
        L_ApiEndpoint := L_TradePartner."API Endpoint";
        L_ContainerName := L_TradePartner."Incoming Orders Conatiner Name";
        L_ApiUrl := L_ApiEndpoint + '/' + L_ContainerName + '/' + FileName;
        L_HttpClient.Get(L_ApiUrl, L_HttpResponse);
        if L_HttpResponse.HttpStatusCode = 200 then begin
            if (L_HttpResponse.IsSuccessStatusCode = true) then begin
                L_HttpResponse.Content().ReadAs(L_ResponseText);

                //++
                L_TradePartner."Last Order Sync" := CreateDateTime(WorkDate, Time);
                L_TradePartner.Modify;
                //--
                L_InterimHeader.DeleteAll();
                L_InterimLine.DeleteAll();
                L_ShipmnetTracking.DeleteAll();
                L_PaymentDetails.DeleteAll();

                Clear(xmlDoc);
                if XmlDocument.ReadFrom(L_ResponseText, xmlDoc) then begin
                    Clear(L_Root);
                    Clear(L_Orders);
                    Clear(L_Node);
                    xmlDoc.GetRoot(L_Root);
                    L_Orders := L_Root.GetChildElements('ORDERS');
                    foreach L_Node in L_Orders do begin
                        Clear(L_Count);
                        L_Count := L_Root.GetChildElements().Count;
                        Clear(e);
                        e := L_Node.AsXmlElement();
                        Clear(L_Orders2);
                        Clear(L_Node2);
                        L_Orders2 := L_Node.AsXmlElement().GetChildElements();
                        foreach L_Node2 in L_Orders2 do begin
                            Clear(e);
                            e := L_Node2.AsXmlElement();
                            if GetText(e, 'NUMBER') <> '' then begin
                                Clear(L_No);
                                L_InterimHeader.Reset();
                                L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
                                if L_InterimHeader.FindLast() then
                                    L_No := IncStr(L_InterimHeader."No.")
                                else
                                    L_No := '10000';
                                L_InterimHeader.Init();
                                L_InterimHeader."Document Type" := L_InterimHeader."Document Type"::Order;
                                L_InterimHeader."No." := L_No;
                                L_InterimHeader.Validate("Trade Partner Code", ChannelCode);
                                L_InterimHeader.Validate("Sell-to Customer No.", L_TradePartner."Customer No.");
                                //  L_InterimHeader."Location Code" := L_TradePartner.Location;//Sofyan
                                L_InterimHeader.Validate("File Name", FileName);
                                if GetDate(e, 'PROCESSDATE') <> 0D then
                                    L_InterimHeader.Validate("Document Date", GetDate(e, 'PROCESSDATE'));
                                if GetText(e, 'SUPPLIERORDERNUMBER') <> '' then
                                    L_InterimHeader.Validate("MultiLine Order No.", GetText(e, 'SUPPLIERORDERNUMBER'));
                                L_InterimHeader.Insert(true);
                                Flag := false;
                            end;
                            if GetText(e, 'NUMBER') <> '' then
                                L_InterimHeader.Validate("Channel Order ID", GetText(e, 'NUMBER'));
                            if GetDateTime(e, 'DATE') <> 0DT then
                                L_InterimHeader.Validate("Order Placed At", GetDateTime(e, 'DATE'));
                            if GetText(e, 'EWS') <> '' then
                                L_InterimHeader.Validate("External Document No.", GetText(e, 'EWS'));
                            if GetText(e, 'NUMBER') <> '' then
                                L_InterimHeader.Modify(true);
                            Clear(L_Orders3);
                            Clear(L_Node3);
                            L_Orders3 := L_Node2.AsXmlElement().GetChildElements();
                            foreach L_Node3 in L_Orders3 do begin
                                Clear(L_Orders4);
                                Clear(L_Node4);
                                L_Orders4 := L_Node3.AsXmlElement().GetChildElements();
                                foreach L_Node4 in L_Orders4 do begin
                                    Clear(e2);
                                    L_Node4.GetParent(e2);
                                    Clear(e);
                                    e := L_Node3.AsXmlElement();
                                    if e2.Name = 'CARRIER' then
                                        if GetText(e, 'BUYERREFERENCE') <> '' then begin
                                            ShippingRule.Reset();
                                            ShippingRule.SetRange("Channel Code", ChannelCode);
                                            ShippingRule.SetRange("Web Shipping Agent", GetText(e, 'BUYERREFERENCE'));
                                            if ShippingRule.FindFirst() then begin
                                                L_InterimHeader.Validate("Shipping Agent Code", ShippingRule."Shipping Agent");
                                            end;

                                            // L_InterimHeader.Validate("Web Shipping Agent", GetText(e, 'BUYERREFERENCE'));
                                        end;
                                    if GetText(e, 'NAME') <> '' then
                                        L_InterimHeader.Validate("Ship-to Name", GetText(e, 'NAME'));
                                    if GetText(e, 'TELEPHONENUMBER1') <> '' then
                                        L_InterimHeader.Validate("Ship-to Phone", GetText(e, 'TELEPHONENUMBER1'));
                                    if GetText(e, 'EMAILADDRESS') <> '' then
                                        L_InterimHeader.Validate("Ship-to Email", GetText(e, 'EMAILADDRESS'));
                                    if e2.Name = 'SHIPDATE' then
                                        if GetDate(e, 'ONDATE') <> 0D then
                                            L_InterimHeader."Shipment Date" := GetDate(e, 'ONDATE');
                                    if e2.Name = 'DELIVERYDATE' then
                                        if GetDate(e, 'ONDATE') <> 0D then
                                            L_InterimHeader.Validate("Earliest Delivery date", GetDate(e, 'ONDATE'));
                                    if GetInteger(e, 'QUANTITY') <> 0 then begin
                                        if Flag = false then begin
                                            L_InterimLine.Reset();
                                            L_InterimLine.SetRange("Document Type", L_InterimHeader."Document Type");
                                            L_InterimLine.SetRange("Document No", L_InterimHeader."No.");
                                            if not L_InterimLine.FindFirst() then begin
                                                L_InterimLine.Init();
                                                L_InterimLine."Document Type" := L_InterimLine."Document Type"::Order;
                                                L_InterimLine."Document No" := L_InterimHeader."No.";
                                                L_InterimLine."Line No." := 10000;
                                                L_InterimLine.Validate("Trade Partner Code", ChannelCode);
                                                //  L_InterimLine."Location Code" := L_InterimHeader."Location Code";//Sofyan
                                                L_InterimLine."Channel Order ID" := L_InterimHeader."Channel Order ID";
                                                L_InterimLine.Insert(true);
                                                Flag := true;
                                            end;
                                        end;
                                    end;

                                    if GetInteger(e, 'QUANTITY') <> 0 then
                                        L_InterimLine.Quantity := GetInteger(e, 'QUANTITY');
                                    if Getdecimal(e, 'RETAILPRICE') <> 0 then
                                        L_InterimLine."Unit Price" := Getdecimal(e, 'RETAILPRICE');
                                    //GetInteger(e, 'RETAILPRICE');

                                    if GetText(e, 'NAME') <> '' then
                                        L_InterimHeader.Validate("Ship-to Name", GetText(e, 'NAME'));
                                    L_InterimHeader.Modify(true);
                                    if GetInteger(e, 'QUANTITY') <> 0 then
                                        L_InterimLine.Modify(true);
                                    Clear(L_Orders5);
                                    Clear(L_Node5);
                                    L_Orders5 := L_Node4.AsXmlElement().GetChildElements();
                                    foreach L_Node5 in L_Orders5 do begin
                                        Clear(e);
                                        e := L_Node4.AsXmlElement();
                                        if GetText(e, 'ADDRESSLINE') <> '' then
                                            L_InterimHeader.Validate("Ship-to Address", GetText(e, 'ADDRESSLINE'));
                                        if GetText(e, 'ADDRESSLINE') <> '' then
                                            L_InterimHeader.Validate("Ship-to Address 2", GetText(e, 'ADDRESSLINE'));
                                        if GetText(e, 'ADDRESSLINE') <> '' then
                                            L_InterimHeader.Validate("Ship to Address 3", GetText(e, 'ADDRESSLINE'));
                                        if GetText(e, 'POSTALCODE') <> '' then
                                            L_InterimHeader.Validate("Ship-to Post Code", GetText(e, 'POSTALCODE'));
                                        if GetText(e, 'COUNTRYCODE') <> '' then
                                            L_InterimHeader.Validate("Ship-to Country/Region Code", GetText(e, 'COUNTRYCODE'));
                                        if GetText(e, 'PRODUCTSTYLEDESCRIPTION') <> '' then
                                            L_InterimLine.Validate(Description, GetText(e, 'PRODUCTSTYLEDESCRIPTION'));
                                        if GetText(e, 'CARRIERBARCODE') <> '' then begin
                                            L_InterimHeader."Package Tracking No." := GetText(e, 'CARRIERBARCODE');
                                            L_InterimHeader.Modify(true);
                                        end;
                                        if GetText(e, 'UNIQUEIDENTIFIER') <> '' then begin
                                            L_InterimLine.Validate("Channel SKU", GetText(e, 'UNIQUEIDENTIFIER'));
                                            L_InterimLine.Validate("No.", GetText(e, 'UNIQUEIDENTIFIER'));
                                            L_InterimHeader.Modify(true);
                                        end;

                                        if GetText(e, 'UNIQUEIDENTIFIER') <> '' then
                                            L_InterimLine.Modify(true);
                                        /* if GetText(e, 'OWNPRODUCTCODE') <> '' then
                                             L_InterimLine.Validate("No.", GetText(e, 'OWNPRODUCTCODE'));
                                         L_InterimHeader.Modify(true);
                                         if GetText(e, 'OWNPRODUCTCODE') <> '' then
                                             L_InterimLine.Modify(true);*/
                                        Clear(L_Orders6);
                                        Clear(L_Node6);
                                        L_Orders6 := L_Node5.AsXmlElement().GetChildElements();
                                        foreach L_Node6 in L_Orders6 do begin
                                            Clear(e);
                                            e := L_Node5.AsXmlElement();
                                            if GetInteger(e, 'WEIGHT') <> 0 then
                                                L_InterimLine.Validate(Weight, GetInteger(e, 'WEIGHT'));
                                            if GetText(e, 'BUYERREFERENCE') <> '' then
                                                L_InterimLine.Validate("Channel SKU", GetText(e, 'BUYERREFERENCE'));
                                            L_InterimHeader.Modify(true);
                                            L_InterimLine.Modify(true);
                                        end;
                                    end;
                                end;
                            end;
                            if L_InterimHeader."No." <> '' then
                                CUWebOrderMgt.CreateWebOrder(L_InterimHeader, L_InterimLine, L_ShipmnetTracking, L_PaymentDetails);
                        end;
                    end;
                end;
            end;
        end;
    end;

    local procedure GetText(e: XmlElement; Name: Text): Text
    var
        FindNode: XmlNode;
    begin
        foreach FindNode in e.GetChildElements(Name) do begin
            exit(FindNode.AsXmlElement().InnerText);
        end;
    end;

    local procedure GetInteger(e: XmlElement; Name: Text): Integer
    var
        FindNode: XmlNode;
        Value: Integer;
    begin
        foreach FindNode in e.GetChildElements(Name) do begin
            Evaluate(Value, FindNode.AsXmlElement().InnerText, 9);
            exit(Value);
        end;
    end;

    local procedure Getdecimal(e: XmlElement; Name: Text): Decimal
    var
        FindNode: XmlNode;
        Value: Decimal;
    begin
        foreach FindNode in e.GetChildElements(Name) do begin
            Evaluate(Value, FindNode.AsXmlElement().InnerText, 9);
            exit(Value);
        end;
    end;

    local procedure GetDateTime(e: XmlElement; Name: Text): DateTime
    var
        FindNode: XmlNode;
        Value: DateTime;
    begin
        foreach FindNode in e.GetChildElements(Name) do begin
            Evaluate(Value, FindNode.AsXmlElement().InnerText, 9);
            exit(Value);
        end;
    end;

    local procedure GetDate(e: XmlElement; Name: Text): Date
    var
        FindNode: XmlNode;
        Value: Date;
    begin
        foreach FindNode in e.GetChildElements(Name) do begin
            Evaluate(Value, format(FindNode.AsXmlElement().InnerText, 10));
            exit(Value);
        end;
    end;

    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        CUWebOrderMgt: Codeunit "Web Order Mgt";
}