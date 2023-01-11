codeunit 90015 VisualSoft
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
                    GetOrdersCredentials(StartParameter);
                    //GetOrders(StartParameter);

                    if IsError = true then begin
                        Message('Some error has found while syncing process.\Please contact system administrator.');
                    end
                    else begin
                        TradePartner.Reset();
                        TradePartner.SetRange(Code, StartParameter);
                        if TradePartner.FindFirst() then begin
                            TradePartner."Last Order Sync" := CurrentDateTime;
                            TradePartner.Modify();
                        end;

                        MESSAGE('Order Sync Completed.');
                    end;
                End;
            SyncItemLabel:
                Begin
                    ProductLoop := true;
                    productOffset := 0;
                    Getitems(StartParameter);

                    if IsError = true then begin
                        Message('Some error has found while syncing process.\Please contact system administrator.');
                    end
                    else begin
                        //Code to Update Last Product Sync Date on trade Partner
                        TradePartner.Reset();
                        TradePartner.SetRange(Code, StartParameter);
                        if TradePartner.FindFirst() then begin
                            TradePartner."Last Product Sync" := CurrentDateTime;
                            TradePartner.Modify();
                        end;
                        MESSAGE('Items Sync Completed.');
                    end;
                End;
            UpdateInventoryLabel:
                begin
                    //setInventory(ChannelCode);
                    UpdateChannelItemListing(StartParameter);
                    UpdateProductStok(StartParameter);  //Need to UnComment Before Going Live
                    MESSAGE('Inventory Updated Successfully.');
                end;
            SyncShipmentLabel:
                begin
                    UpdateOrderStatus(StartParameter); //Need to UnComment Before Going Live
                    Message('Order Status Updated Successfully.');
                end;
        end;
    End;

    procedure GetCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            MarketplaceId := TradePartner.MarketplaceId;
            AccessKeyId := TradePartner.AccessKeyId;
            SecretAccessKey := TradePartner.SecretAccessKey;
            ServiceURL := TradePartner."Sevice/API URL";
            //EndDate := Format(Today, 0, '20<Year>-<Month,2>-<Day,2>');

            EndDate := Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');
            StartDate := Format(TradePartner."Last Order Sync", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');

            // StartDate := Format(TradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2>');
            ProductCount := TradePartner."API Attribute";
            ProductPageCount := TradePartner."API Endpoint";
            BasicAuthPassword := TradePartner.MerchantId;
        end;
    end;


    procedure GetOrdersCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            MarketplaceId := TradePartner.MarketplaceId;
            AccessKeyId := TradePartner.AccessKeyId;
            SecretAccessKey := TradePartner.SecretAccessKey;
            ServiceURL := TradePartner."Sevice/API URL";

            StartDateTime := CreateDateTime(CalcDate('-1D', DT2Date(TradePartner."Last Order Sync")), DT2Time(TradePartner."Last Order Sync"));
            if TradePartner."Last Customer Sync" = 0DT then begin
                EndDateTime := CurrentDateTime;
            end
            else begin
                EndDateTime := TradePartner."Last Customer Sync";
            end;
            //EndDateTime := TradePartner."Last Customer Sync";

            ProductCount := TradePartner."API Attribute";
            ProductPageCount := TradePartner."API Endpoint";
            BasicAuthPassword := TradePartner.MerchantId;

            GenerateStartDateEndDate(ChannelCode);
        end;
    end;


    local procedure GenerateStartDateEndDate(ChannelCode: Code[10])
    var
        i: Integer;
        Timer: Integer;
    begin
        Clear(NoOfDays);
        Clear(NoOfHours);
        if EndDateTime = 0DT then begin
            EndDateTime := CurrentDateTime;
        end;
        DateDuration := EndDateTime - StartDateTime;
        NoOfDays := Round(DateDuration / 86400000, 2, '=');
        NoOfHours := Round(DateDuration / 3600000, 3, '=');

        if NoOfDays > 0 then begin
            i := 0;
            repeat
                if i > 0 then begin
                    StartDateTime := NewDateTime;
                end;

                for Timer := 0 to 7 do begin
                    if Timer = 0 then begin
                        if StartDateTime < EndDateTime then begin
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 0T);
                            StartDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T00:00:00');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 030000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 1 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 060000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 2 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 090000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 3 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 120000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 4 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 150000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 5 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 180000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 6 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 210000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if Timer = 7 then begin
                        if NewDateTime < EndDateTime then begin
                            NewDate := CalcDate('+1D', DT2Date(NewDateTime));
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(NewDate, 0T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T00:00:00');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;
                end;

                i := i + 1;
            until i > NoOfDays;
        end
        else begin
            if NoOfHours > 0 then begin
                repeat
                    if i = 0 then begin
                        if NewDateTime < EndDateTime then begin
                            StartDateTime := CreateDateTime(DT2Date(StartDateTime), 0T);
                            //StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>');
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T00:00:00');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 060000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if i = 1 then begin
                        if NewDateTime < EndDateTime then begin
                            Clear(StartDateTime);
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 120000T);
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if i = 2 then begin
                        if NewDateTime < EndDateTime then begin
                            Clear(StartDateTime);
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 180000T);
                            // EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>');
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T18:00:00');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;

                    if i = 3 then begin
                        if NewDateTime < EndDateTime then begin
                            Clear(StartDateTime);
                            StartDateTime := NewDateTime;
                            StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>');
                            Clear(NewDateTime);
                            NewDateTime := CreateDateTime(DT2Date(StartDateTime), 235959T);
                            // EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>');
                            EndDate := Format(NewDateTime, 0, '20<Year>-<Month,2>-<Day,2>T23:59:59');
                            GetOrders(ChannelCode);
                            Sleep(1000);
                        end;
                    end;
                    i := i + 1;
                until i > 3;
            end;
        end;
    end;


    local procedure GetOrders(ChannelCode: Code[10])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        j: Integer;
        TradePartner: Record "Trade Partner";
    begin
        //GetCredentials(ChannelCode);
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="' + ServiceURL + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetOrdersByDateRange><from_date xsi:type="xsd:date">' + StartDate + '</from_date><to_date xsi:type="xsd:date">' + EndDate + '</to_date><successful_only xsi:nil="true"/></ns1:GetOrdersByDateRange></soapenv:Body></soapenv:Envelope>';

        URL := ServiceURL;
        //SoapAction := SoapActionUrl + '/6#GetOrdersByDateRange';
        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Headers := Client.DefaultRequestHeaders;
        Headers.Add('Authorization', CreateBasicAuth(AccessKeyId, BasicAuthPassword, MarketplaceId));
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        // Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service/5#GetOrdersByDateRange');
        //Headers.Add('soapAction', SoapAction);
        RequestMessage.Content := Content;

        IsError := false;
        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content().ReadAs(Response);
            if ResponseMessage.HttpStatusCode = 200 then begin
                InsertXMLResponse(Response, ChannelCode);
            end
            else begin
                Error(StrSubstNo('Status Code - "%1" and Error Message - %2', ResponseMessage.HttpStatusCode, Response));
            end;
        end
        else begin
            IsError := true;
        end;
    end;

    local procedure InsertXMLResponse(P_Response: Text; ChannelCode: Code[10])
    var
        EnvInformation: Codeunit "Environment Information";
        L_XmlDocument: XmlDocument;
        CU_XMLDOMMgmt: Codeunit "XML DOM Management";
        L_NavOrderResultList: XmlNodeList;
        L_StatusNodeList: XmlNodeList;
        L_OrderDataNodeList: XmlNodeList;
        L_OrderNodeList: XmlNodeList;
        L_NavOrderResultNode: XmlNode;
        L_StatusNode: XmlNode;
        L_MessageNode: XmlNode;
        L_OrderDataNode: XmlNode;
        L_OrderResponseNode: XmlNode;
        L_NavOrderResultElement: XmlElement;
        L_StatusElement: XmlElement;
        L_MessageElement: XmlElement;
        L_OrderDataElement: XmlElement;
        L_OrderResponseElement: XmlElement;
        i: Integer;
        OrderSource: Text;
        TradePartner: Record "Trade Partner";
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        j: Integer;
        WebOrderXLMNode: XmlNode;
        WebOrderXLMElement: XmlElement;
        WebOrderXLMList: XmlNodeList;
        WebOrderXLMNode1: XmlNode;
        WebOrderXLMElement1: XmlElement;
        WebOrderXLMList1: XmlNodeList;
        WebOrderXLMNode2: XmlNode;
        WebOrderXLMElement2: XmlElement;
        WebOrderXLMList2: XmlNodeList;
        WebOrderXLMNode3: XmlNode;
        WebOrderXLMElement3: XmlElement;
        WebOrderXLMList3: XmlNodeList;
        WebOrderXLMNode4: XmlNode;
        WebOrderXLMElement4: XmlElement;
        WebOrderXLMList4: XmlNodeList;
        CountXMlWebOrder: Integer;
        GenericNode: XmlNode;
        GenericElement: XmlElement;
        Generictext: text;
        SkipNodeList: XmlNodeList;
        OrderStatus: Text;
    begin
        P_Response := CU_XMLDOMMgmt.RemoveNamespaces(P_Response);
        XmlDocument.ReadFrom(P_Response, L_XmlDocument);

        L_NavOrderResultList := L_XmlDocument.GetDescendantElements('GetOrdersByDateRangeResponse');

        if L_NavOrderResultList.Get(1, L_StatusNode) then
            L_StatusElement := L_StatusNode.AsXmlElement();
        if not L_StatusElement.IsEmpty() and L_StatusElement.HasElements() then
            L_StatusNodeList := L_StatusElement.GetChildNodes();

        if L_StatusNodeList.Get(1, L_MessageNode) then
            L_MessageElement := L_MessageNode.AsXmlElement();
        if not L_MessageElement.IsEmpty() and L_MessageElement.HasElements() then
            L_OrderDataNodeList := L_MessageElement.GetChildNodes();
        if L_OrderDataNodeList.get(6, L_OrderDataNode) then
            L_OrderDataElement := L_OrderDataNode.AsXmlElement();

        if not L_OrderDataElement.IsEmpty() and L_OrderDataElement.HasElements() then
            WebOrderXLMList := L_OrderDataElement.GetChildNodes();
        if WebOrderXLMList.get(1, WebOrderXLMNode1) then
            WebOrderXLMElement1 := WebOrderXLMNode1.AsXmlElement();
        if not WebOrderXLMElement1.IsEmpty() and WebOrderXLMElement1.HasElements() then
            WebOrderXLMList2 := WebOrderXLMElement1.GetChildNodes();
        CountXMlWebOrder := WebOrderXLMList2.Count;

        if WebOrderXLMList2.Count > 0 then begin
            for j := 1 to WebOrderXLMList2.Count do begin
                //  Clear(WebOrderXLMElement1);
                InterimSalesHeader.DeleteAll();
                InterimSalesLine.DeleteAll();
                PaymentDetails.DeleteAll();

                if WebOrderXLMList.get(j, WebOrderXLMNode2) then
                    WebOrderXLMElement1 := WebOrderXLMNode2.AsXmlElement();
                L_OrderNodeList := WebOrderXLMElement1.GetChildNodes();
                if L_OrderNodeList.Get(j, WebOrderXLMNode3) then
                    WebOrderXLMElement3 := WebOrderXLMNode3.AsXmlElement();
                if not WebOrderXLMElement3.IsEmpty() and WebOrderXLMElement3.HasElements() then
                    WebOrderXLMList3 := WebOrderXLMElement3.GetChildNodes();

                Clear(SkipNodeList);
                Clear(GenericNode);
                Clear(GenericElement);
                if WebOrderXLMList3.Get(1, GenericNode) then
                    GenericElement := GenericNode.AsXmlElement();
                if not GenericElement.IsEmpty() and GenericElement.HasElements() then
                    SkipNodeList := GenericElement.GetChildNodes();

                Clear(GenericNode);
                Clear(GenericElement);
                if SkipNodeList.Get(5, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    OrderStatus := GenericElement.InnerText;
                end;

                if (OrderStatus = 'Payment Received') or (OrderStatus = 'Processing Order') or (OrderStatus = 'Pre Order') or (OrderStatus = 'Payment Received from Paypal') or (OrderStatus = 'Order Partially Refunded') then begin

                    InsertIntrimSalesHeader(WebOrderXLMList3, ChannelCode, InterimSalesHeader, PaymentDetails);
                    InsertInInterimSalesLine(WebOrderXLMList3, ChannelCode, InterimSalesHeader, InterimSalesLine);
                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

                    Sleep(1000);
                    //Code to Mark Order as Downloaded
                    if EnvInformation.IsProduction() then begin
                        OrderMarkAsDownloaded(InterimSalesHeader, ChannelCode);
                    end;
                    Commit();
                    Sleep(1000);

                    if WebOrderXLMList3.Get(2, WebOrderXLMNode4) then
                        WebOrderXLMElement4 := WebOrderXLMNode4.AsXmlElement();
                    WebOrderXLMList4 := WebOrderXLMElement4.GetChildNodes();
                    Clear(GenericElement);
                    Clear(GenericNode);
                    if WebOrderXLMList4.get(1, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        Generictext := GenericElement.InnerText;
                    end;
                end;
            end;
        end;
    end;

    procedure InsertIntrimSalesHeader(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary; var PaymentDetails: Record "Channel Media" temporary)
    var
        TradePartner1: Record "Trade Partner";
        CustomerNodeList: XmlNodeList;
        BillingAddressNodeList: XmlNodeList;
        ShippingAddressNodeList: XmlNodeList;
        OrderNodeList: XmlNodeList;
        TransactionNodeList: XmlNodeList;
        PaymentNodeList: XmlNodeList;
        PaymentAmt: Decimal;
        TransactionDate: Date;
        TradePartner: Record "Trade Partner";
        DeliveryDate: Date;
        OrderDate: DateTime;
        OrderStatus: Text;
        OrderAmount: Decimal;
        DiscountAmount: Decimal;
        OrderId: Text;
        FirstName: Text;
        LastName: Text;
        FullName: Text;
        BillingAddress1: Text[50];
        ShippingAddress1: Text[50];
        ShippingRule: Record "Shipping Rule";
        Rec_CountryRegion: Record "Country/Region";
        CountryCode: Text[50];
        L_ShippingPrice: Decimal;
        FullShipToAddress: Text;
        LeghtString: Text;
        TotalDiscountIn: Decimal;
        OrderTotalIncVat: Decimal;
        ShipToCountryRegionCode: Code[10];
        PaymentAmtText: Text;
        i: Integer;
        CurrencyCode: Text;
    begin
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;

        //for HeaderNodeLsit 
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(OrderNodeList);
        if P_OrderDataNodeList.Get(1, GenericNode) then
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            OrderNodeList := GenericElement.GetChildNodes();

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Channel Order ID" := GenericElement.InnerText;
            InterimSalesHeader."No." := GenericElement.InnerText
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(5, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Order Status" := GenericElement.InnerText;
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(3, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."External Document No." := GenericElement.InnerText;
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(9, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            OrderDate := GenerateDateTime(GenericElement.InnerText());
            InterimSalesHeader."Order Placed At" := OrderDate;
            InterimSalesHeader."Document Date" := DT2Date(OrderDate);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(11, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            OrderDate := GenerateDateTime(GenericElement.InnerText());
            //InterimSalesHeader."Requested Delivery Date" := OrderDate;
            InterimSalesHeader."Requested Delivery Date" := DT2Date(OrderDate);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(23, GenericNode) then begin //GRAND_TOTAL_INC
            GenericElement := GenericNode.AsXmlElement();
            Evaluate(OrderTotalIncVat, GenericElement.InnerText());
            InterimSalesHeader."Order Amount" := OrderTotalIncVat;
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        Clear(LeghtString);
        if OrderNodeList.Get(33, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            LeghtString := Copystr(GenericElement.InnerText(), 1, 50);
            InterimSalesHeader."Web Shipment Method" := LeghtString;
        end;

        //for HeaderNodeLsit 
        //Customer Node List
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(CustomerNodeList);


        if P_OrderDataNodeList.Get(2, GenericNode) then
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            CustomerNodeList := GenericElement.GetChildNodes();

        Clear(GenericNode);
        Clear(GenericElement);
        Clear(FirstName);
        if CustomerNodeList.Get(4, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            FirstName := Copystr(GenericElement.InnerText(), 1, 50);
        end;
        Clear(LastName);
        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(5, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            LastName := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(FullName);
        FullName := FirstName + ' ' + LastName;
        InterimSalesHeader."Bill- to Name" := CopyStr(FullName, 1, 50);

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(6, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader.Address := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(7, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Address 2" := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(8, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader.City := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(13, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Post Code" := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(15, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Email" := CopyStr(GenericElement.InnerText(), 1, 80);
            InterimSalesHeader."Buyer Email" := CopyStr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        Clear(G_ShippingPrice);
        if OrderNodeList.Get(17, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            Evaluate(G_ShippingPrice, GenericElement.InnerText());
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if OrderNodeList.Get(20, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            Evaluate(TotalDiscountIn, GenericElement.InnerText());
            InterimSalesHeader."Order Discount Amount" := TotalDiscountIn;
        end;
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(FirstName);
        if CustomerNodeList.Get(18, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            FirstName := Copystr(GenericElement.InnerText(), 1, 30);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        Clear(LastName);
        if CustomerNodeList.Get(19, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            LastName := Copystr(GenericElement.InnerText(), 1, 30);
        end;

        Clear(FullName);
        FullName := FirstName + ' ' + LastName;
        InterimSalesHeader."Ship-to Name" := CopyStr(FullName, 1, 50);

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(20, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Address" := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(21, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Address 2" := Copystr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(22, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to City" := Copystr(GenericElement.InnerText(), 1, 30);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        Clear(ShipToCountryRegionCode);
        if CustomerNodeList.Get(26, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ShipToCountryRegionCode := Copystr(GenericElement.InnerText(), 1, 10);
            if ShipToCountryRegionCode = 'UNITED KIN' then begin
                InterimSalesHeader."Ship-to Country/Region Code" := 'GB';
            end;
            if ShipToCountryRegionCode = 'NORTHERN I' then begin
                InterimSalesHeader."Ship-to Country/Region Code" := 'NI';
            end;
            if ((ShipToCountryRegionCode <> 'NORTHERN I') and (ShipToCountryRegionCode <> 'UNITED KIN')) then begin
                InterimSalesHeader."Ship-to Country/Region Code" := ShipToCountryRegionCode;
            end;
        end;

        if CustomerNodeList.Get(23, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to County" := Copystr(GenericElement.InnerText(), 1, 30);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(27, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Post Code" := Copystr(GenericElement.InnerText(), 1, 20);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(28, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Phone" := Copystr(GenericElement.InnerText(), 1, 20);
        end;


        TradePartner1.Reset();
        if TradePartner1.Get(ChannelCode) then begin
            if TradePartner1."Customer Mapping" = TradePartner1."Customer Mapping"::"Default Customer" then
                InterimSalesHeader."Sell-to Customer No." := TradePartner1."Customer No.";
        end;

        //Customer Node List

        //Payment Node List++
        Clear(PaymentMethod);
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(TransactionNodeList);
        if P_OrderDataNodeList.Get(5, GenericNode) then
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            TransactionNodeList := GenericElement.GetChildNodes();

        if TransactionNodeList.Count > 0 then begin

            for i := 1 to TransactionNodeList.Count do begin

                PaymentDetails.Init();
                if PaymentDetails.FindLast() then
                    PaymentDetails."Entry No" += 1
                else
                    PaymentDetails."Entry No" := 1;
                PaymentDetails."Channel Code" := ChannelCode;
                PaymentDetails."Channel Order ID" := InterimSalesHeader."Channel Order ID";

                Clear(GenericNode);
                Clear(GenericElement);
                Clear(PaymentNodeList);

                if TransactionNodeList.get(i, GenericNode) then
                    GenericElement := GenericNode.AsXmlElement();
                if not GenericElement.IsEmpty() and GenericElement.HasElements() then
                    PaymentNodeList := GenericElement.GetChildNodes();

                Clear(GenericNode);
                Clear(GenericElement);
                Clear(PaymentAmtText);
                Clear(PaymentAmt);

                if PaymentNodeList.Get(1, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    PaymentAmtText := GenericElement.InnerText();
                    if PaymentAmtText <> '' then
                        Evaluate(PaymentAmt, GenericElement.InnerText());
                    PaymentDetails.Amount := PaymentAmt;
                end;

                Clear(GenericNode);
                Clear(GenericElement);
                Clear(TransactionDate);

                if PaymentNodeList.Get(2, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    TransactionDate := GenerateNewDate(GenericElement.InnerText());
                    PaymentDetails."Transaction Date" := TransactionDate;
                end;

                Clear(GenericNode);
                Clear(GenericElement);

                if PaymentNodeList.Get(3, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    PaymentDetails."Payment Method" := CopyStr(GenericElement.InnerText(), 1, 50);
                    InterimSalesHeader."Payment Method" := CopyStr(GenericElement.InnerText(), 1, 10);
                    PaymentMethod[i] := GenericElement.InnerText();
                end;

                Clear(GenericNode);
                Clear(GenericElement);
                if PaymentNodeList.Get(7, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    PaymentDetails."Transaction ID" := CopyStr(GenericElement.InnerText(), 1, 50);
                end;

                if PaymentDetails.Amount = 0 then begin
                    PaymentDetails.Amount := InterimSalesHeader."Order Amount";
                end;
                PaymentDetails.Insert();

            end;

        end;
        //Payment Node List--

        //If Payment method is Paypal Express and Currency Code is not GBP then must map Currency Code in Web Order
        Clear(InterimSalesHeader."Currency Code");
        for i := 1 to 5 do begin
            if PaymentMethod[i] = 'PayPal Express' then begin
                Clear(GenericNode);
                Clear(GenericElement);
                Clear(CurrencyCode);
                if OrderNodeList.Get(28, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    CurrencyCode := GenericElement.InnerText();
                    if CurrencyCode <> 'GBP' then
                        InterimSalesHeader."Currency Code" := CurrencyCode;
                end;
            end;
        end;

        InterimSalesHeader.Insert();
    end;

    local procedure InsertInInterimSalesLine(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        OrderItemNodeList: XmlNodeList;
        OrderItemList: XmlNodeList;
        itemlistNode: XmlNode;
        ItemlistXLMlist: XmlNodeList;
        itemlistelement: XmlElement;
        i: Integer;
        j: Integer;
        UnitPriceTxt: Text;
        UnitPrice: Decimal;
        Amount: Decimal;
        ShippingPrice: Decimal;
        LineCount: Integer;
        QtyText: Text;
        Qty: Decimal;
        GLAccount: Code[20];
        TradePartner1: Record "Trade Partner";
        DiscountExtext: Text;
        DiscountEx: Decimal;
        InterimSalesLine1: Record "Interim Sales Line";
        CountLine: Integer;
        G_CountLine: Integer;
        ItemWeightTxt: Text;
        ItemWeight: Decimal;
        ProductStatus: Text;
    begin
        //OrderItem
        Clear(GenericNode);
        Clear(GenericElement);

        if P_OrderDataNodeList.Get(3, GenericNode) then
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then begin
            OrderItemNodeList := GenericElement.GetChildNodes();

            CountLine := OrderItemNodeList.Count;
            if CountLine > 0 then begin
                for j := 1 to CountLine do begin
                    Clear(G_CountLine);
                    if CountLine > 1 then
                        G_CountLine := j;
                    if OrderItemNodeList.get(j, itemlistNode) then
                        itemlistelement := itemlistNode.AsXmlElement();
                    if not itemlistelement.IsEmpty() and itemlistelement.HasElements() then
                        ItemlistXLMlist := itemlistelement.GetChildNodes();

                    Clear(GenericNode);
                    Clear(GenericElement);
                    Clear(ProductStatus);

                    //Getting status of product if it is 'Y' then only it should insert the line in order
                    if ItemlistXLMlist.Get(22, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        ProductStatus := GenericElement.InnerText;
                    end;

                    if ProductStatus = 'Y' then begin
                        InterimSalesLine.Init;
                        InterimSalesLine."Line No." := j;
                        InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                        InterimSalesLine.Type := InterimSalesLine.type::Item;
                        InterimSalesLine."Document No" := InterimSalesHeader."No.";
                        InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";

                        Clear(GenericNode);
                        Clear(GenericElement);
                        if ItemlistXLMlist.Get(5, GenericNode) then begin
                            GenericElement := GenericNode.AsXmlElement();
                            InterimSalesLine."No." := GenericElement.InnerText;
                            InterimSalesLine."Channel SKU" := GenericElement.InnerText;
                        end;

                        if InterimSalesLine."Channel SKU" = '' then begin
                            Clear(GenericNode);
                            Clear(GenericElement);
                            if ItemlistXLMlist.Get(3, GenericNode) then begin
                                GenericElement := GenericNode.AsXmlElement();
                                InterimSalesLine."No." := GenericElement.InnerText;
                                InterimSalesLine."Channel SKU" := GenericElement.InnerText;
                            end;
                        end;

                        // Clear(GenericNode);
                        // Clear(GenericElement);
                        // if ItemlistXLMlist.Get(2, GenericNode) then begin
                        //     GenericElement := GenericNode.AsXmlElement();
                        //     InterimSalesLine."No." := GenericElement.InnerText;
                        // end;

                        Clear(GenericNode);
                        Clear(GenericElement);
                        Clear(QtyText);
                        Clear(Qty);
                        if ItemlistXLMlist.Get(14, GenericNode) then begin
                            GenericElement := GenericNode.AsXmlElement();
                            QtyText := GenericElement.InnerText;
                            if QtyText <> '' then
                                Evaluate(Qty, QtyText);
                            InterimSalesLine.Quantity := Qty;
                        end;

                        Clear(GenericNode);
                        Clear(GenericElement);
                        Clear(ItemWeightTxt);
                        Clear(ItemWeight);
                        if ItemlistXLMlist.Get(23, GenericNode) then begin
                            GenericElement := GenericNode.AsXmlElement();
                            ItemWeightTxt := GenericElement.InnerText;
                            if ItemWeightTxt <> '' then
                                Evaluate(ItemWeight, ItemWeightTxt);
                            InterimSalesLine.Weight := ItemWeight;
                        end;

                        Clear(GenericNode);
                        Clear(GenericElement);
                        if ItemlistXLMlist.Get(11, GenericNode) then begin
                            GenericElement := GenericNode.AsXmlElement();
                            InterimSalesLine.Description := GenericElement.InnerText();
                        end;

                        Clear(GenericNode);
                        Clear(GenericElement);
                        Clear(DiscountExtext);
                        Clear(DiscountEx);
                        InterimSalesLine.Discount := 0;
                        //if ItemlistXLMlist.Get(19, GenericNode) then begin
                        if ItemlistXLMlist.Get(18, GenericNode) then begin //Inclusive VAT Discount
                            GenericElement := GenericNode.AsXmlElement();
                            DiscountExtext := GenericElement.InnerText;
                            if (DiscountExtext <> '') and (DiscountExtext <> '0') then begin
                                if DiscountExtext.Contains('-') then
                                    DiscountExtext := DiscountExtext.Remove(1, 1);

                                Evaluate(DiscountEx, DiscountExtext);
                                InterimSalesLine.Discount := DiscountEx * Qty;
                            end else begin
                                InterimSalesLine.Discount := 0;
                            end;
                        end;

                        Clear(GenericNode);
                        Clear(GenericElement);
                        Clear(UnitPriceTxt);
                        Clear(UnitPrice);
                        if ItemlistXLMlist.Get(15, GenericNode) then begin
                            GenericElement := GenericNode.AsXmlElement();
                            UnitPriceTxt := GenericElement.InnerText;
                            if UnitPriceTxt <> '' then
                                Evaluate(UnitPrice, UnitPriceTxt);
                            /* if DiscountEx > 0 then
                                 InterimSalesLine."Unit Price" := UnitPrice - DiscountEx
                             else*/
                            InterimSalesLine."Unit Price" := UnitPrice;
                        end;

                        if j = 1 then begin
                            if G_ShippingPrice > 0 then
                                InterimSalesLine."Shipping Price" := G_ShippingPrice;
                        end;
                        //Shipping Price

                        //Adding Currency Code on Line Level
                        Clear(InterimSalesLine."Currency Code");
                        for i := 1 to 5 do begin
                            if PaymentMethod[i] = 'PayPal Express' then begin
                                if (InterimSalesHeader."Currency Code" <> '') and (InterimSalesHeader."Currency Code" <> 'GBP') then
                                    InterimSalesLine."Currency Code" := InterimSalesHeader."Currency Code";
                            end;
                        end;

                        InterimSalesLine.Insert();
                    end;
                end;
            end;
        End;
    end;

    local procedure OrderMarkAsDownloaded(var P_InterimSalesHeader: Record "Interim Sales Header" temporary; P_ChannelCode: Code[10])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        GetCredentials(P_ChannelCode);
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="' + ServiceURL + '">' +
                    '<soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username>' +
                    '<Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns:MarkOrdersAsDownloaded>' +
                    '<order_ids><order_id>' + P_InterimSalesHeader."Channel Order ID" + '</order_id></order_ids></ns:MarkOrdersAsDownloaded></soapenv:Body></soapenv:Envelope>';

        RequestMessage.SetRequestUri(ServiceURL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Headers := Client.DefaultRequestHeaders;
        Headers.Add('Authorization', CreateBasicAuth(AccessKeyId, BasicAuthPassword, MarketplaceId));
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);

        if ResponseMessage.HttpStatusCode = 200 then begin
            L_InterimSalesHeader.Reset();
            L_InterimSalesHeader.SetRange("No.", P_InterimSalesHeader."No.");
            L_InterimSalesHeader.SetRange("Document Type", P_InterimSalesHeader."Document Type");
            L_InterimSalesHeader.SetRange("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
            if L_InterimSalesHeader.FindFirst() then begin
                L_InterimSalesHeader.Validate("FullFillment Status", L_InterimSalesHeader."FullFillment Status"::Acknowledged);
                L_InterimSalesHeader.Modify(true);
            end;
        end;
    end;

    local procedure Getitems(ChannelCode: Code[10])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        j: Integer;
        SoapAction: text;
        CU_XMLDOMMgmt: Codeunit "XML DOM Management";
        L_XmlDocument: XmlDocument;
        L_ProductsResponseList: XmlNodeList;
        L_ReturnNode: XmlNode;
        L_ReturnElement: XmlElement;
        L_ReturnNodeList: XmlNodeList;
        L_ReturnListNode: XmlNode;
        L_ReturnListElement: XmlElement;
        L_ReturnListNodeList: XmlNodeList;
        ErrorNode: XmlNode;
        ErrorElement: XmlElement;
        ErrorNodeList: XmlNodeList;
        ErrorsNode: XmlNode;
        ErrorsElement: XmlElement;
    begin
        GetCredentials(ChannelCode);
        //Live Request Body++
        //RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + SoapActionUrl + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetProducts><product_references SOAP-ENC:arrayType="xsd:string[2]" xsi:type="SOAP-ENC:Array"><item xsi:type="xsd:string">REF1</item></product_references><get_data xsi:nil="true"/><limit xsi:type="xsd:int">' + ProductCount + '</limit><offset xsi:type="xsd:int">' + ProductPageCount + '</offset><file_type xsi:type="xsd:string">xml</file_type></ns1:GetProducts></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--
        //RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + ServiceURL + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetProducts><product_references xsi:nil="true"/><get_data xsi:nil="true"/><file_type xsi:type="xsd:string">xml</file_type><limit xsi:type="xsd:int">' + ProductCount + '</limit><offset xsi:type="xsd:int">' + ProductPageCount + '</offset></ns1:GetProducts></soapenv:Body></soapenv:Envelope>';

        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + ServiceURL + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetProducts><product_references xsi:nil="true"/><get_data xsi:nil="true"/><file_type xsi:type="xsd:string">xml</file_type><limit xsi:type="xsd:int">500</limit><offset xsi:type="xsd:int">' + Format(productOffset) + '</offset></ns1:GetProducts></soapenv:Body></soapenv:Envelope>';

        // URL := 'https://demo.visualsoft.co.uk/api/soap/service/5';
        URL := ServiceURL;

        //SoapAction := SoapActionUrl + '#GetProducts';
        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Headers := Client.DefaultRequestHeaders;
        Headers.Add('Authorization', CreateBasicAuth(AccessKeyId, BasicAuthPassword, MarketplaceId));
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        //Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service#GetProducts');
        //Headers.Add('soapAction', SoapAction);
        RequestMessage.Content := Content;

        IsError := false;
        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content().ReadAs(Response);
            if ResponseMessage.HttpStatusCode = 200 then begin

                //Checking Error Message if any++
                Response := CU_XMLDOMMgmt.RemoveNamespaces(Response);
                XmlDocument.ReadFrom(Response, L_XmlDocument);

                L_ProductsResponseList := L_XmlDocument.GetDescendantElements('GetProductsResponse');
                if L_ProductsResponseList.Get(1, L_ReturnNode) then
                    L_ReturnElement := L_ReturnNode.AsXmlElement();
                if not L_ReturnElement.IsEmpty() and L_ReturnElement.HasElements() then
                    L_ReturnNodeList := L_ReturnElement.GetChildNodes();

                if L_ReturnNodeList.Get(1, L_ReturnListNode) then
                    L_ReturnListElement := L_ReturnListNode.AsXmlElement();
                if not L_ReturnListElement.IsEmpty() and L_ReturnListElement.HasElements() then
                    L_ReturnListNodeList := L_ReturnListElement.GetChildNodes();

                if L_ReturnListNodeList.get(4, ErrorsNode) then
                    ErrorsElement := ErrorsNode.AsXmlElement();
                if not ErrorsElement.IsEmpty() and ErrorsElement.HasElements() then begin
                    //If Error Comes up Loop of Product Sync Stops
                    ProductLoop := false;
                    ErrorNodeList := ErrorsElement.GetChildNodes();

                    if ErrorNodeList.get(1, ErrorNode) then
                        ErrorElement := ErrorNode.AsXmlElement();
                end
                else begin
                    ProductLoop := true;
                    productOffset := productOffset + 500;
                end;
                //Checking Error Message if any--

                InsertProductXMLResponse(Response, ChannelCode);

                //Condition to Check if there isn't any Error then Continue With Syncing Items
                if ProductLoop = true then begin
                    Getitems(ChannelCode);
                end;
            end
            else begin
                Error(StrSubstNo('Status Code - "%1" and Error Message - %2', ResponseMessage.HttpStatusCode, Response));
            end;
        end
        else begin
            IsError := true;
        end;
    end;

    local procedure InsertProductXMLResponse(P_Response: Text; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
        L_XmlDocument: XmlDocument;
        ASINNOXMLlist: XmlNodeList;
        ASINNOXMLlistNode: Xmlnode;
        ASINNOXMLlistNodeElement: XmlElement;
        ASINNOXMLlist1: XmlNodeList;
        ASINNOXMLlistNode1: Xmlnode;
        ASINNOXMLlistNodeElement1: XmlElement;
        CU_XMLDOMMgmt: Codeunit "XML DOM Management";
        L_NavOrderResultList: XmlNodeList;
        L_StatusNodeList: XmlNodeList;
        L_OrderDataNodeList: XmlNodeList;
        L_OrderNodeList: XmlNodeList;
        L_NavOrderResultNode: XmlNode;
        L_StatusNode: XmlNode;
        L_MessageNode: XmlNode;
        L_OrderDataNode: XmlNode;
        L_OrderResponseNode: XmlNode;
        L_NavOrderResultElement: XmlElement;
        L_StatusElement: XmlElement;
        L_MessageElement: XmlElement;
        L_OrderDataElement: XmlElement;
        L_OrderResponseElement: XmlElement;
        i: Integer;
        OrderSource: Text;
        TradePartner: Record "Trade Partner";
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        j: Integer;
        WebOrderXLMNode: XmlNode;
        WebOrderXLMElement: XmlElement;
        WebOrderXLMList: XmlNodeList;
        WebOrderXLMNode1: XmlNode;
        WebOrderXLMElement1: XmlElement;
        WebOrderXLMList1: XmlNodeList;
        WebOrderXLMNode2: XmlNode;
        WebOrderXLMElement2: XmlElement;
        WebOrderXLMList2: XmlNodeList;
        WebOrderXLMNode3: XmlNode;
        WebOrderXLMElement3: XmlElement;
        WebOrderXLMList3: XmlNodeList;
        WebOrderXLMNode4: XmlNode;
        WebOrderXLMElement4: XmlElement;
        WebOrderXLMList4: XmlNodeList;
        CountXMlWebOrder: Integer;
        GenericNode: XmlNode;
        GenericElement: XmlElement;
        Generictext: text;
        NmberAsin: Text;
    begin
        P_Response := CU_XMLDOMMgmt.RemoveNamespaces(P_Response);
        XmlDocument.ReadFrom(P_Response, L_XmlDocument);

        L_NavOrderResultList := L_XmlDocument.GetDescendantElements('GetProductsResponse');

        if L_NavOrderResultList.Get(1, L_StatusNode) then
            L_StatusElement := L_StatusNode.AsXmlElement();
        if not L_StatusElement.IsEmpty() and L_StatusElement.HasElements() then
            L_StatusNodeList := L_StatusElement.GetChildNodes();

        if L_StatusNodeList.Get(1, L_MessageNode) then
            L_MessageElement := L_MessageNode.AsXmlElement();
        if not L_MessageElement.IsEmpty() and L_MessageElement.HasElements() then
            L_OrderDataNodeList := L_MessageElement.GetChildNodes();
        if L_OrderDataNodeList.get(6, L_OrderDataNode) then
            L_OrderDataElement := L_OrderDataNode.AsXmlElement();

        if not L_OrderDataElement.IsEmpty() and L_OrderDataElement.HasElements() then
            WebOrderXLMList := L_OrderDataElement.GetChildNodes();
        if WebOrderXLMList.get(1, WebOrderXLMNode1) then
            WebOrderXLMElement1 := WebOrderXLMNode1.AsXmlElement();
        if not WebOrderXLMElement1.IsEmpty() and WebOrderXLMElement1.HasElements() then
            WebOrderXLMList2 := WebOrderXLMElement1.GetChildNodes();
        CountXMlWebOrder := WebOrderXLMList2.Count;

        if WebOrderXLMList2.Count > 0 then begin
            for j := 1 to WebOrderXLMList2.Count do begin
                //  Clear(WebOrderXLMElement1);
                if WebOrderXLMList.get(j, WebOrderXLMNode2) then
                    WebOrderXLMElement1 := WebOrderXLMNode2.AsXmlElement();
                L_OrderNodeList := WebOrderXLMElement1.GetChildNodes();
                if L_OrderNodeList.Get(j, WebOrderXLMNode3) then
                    WebOrderXLMElement3 := WebOrderXLMNode3.AsXmlElement();
                if not WebOrderXLMElement3.IsEmpty() and WebOrderXLMElement3.HasElements() then
                    WebOrderXLMList3 := WebOrderXLMElement3.GetChildNodes();

                Clear(Generictext);
                if WebOrderXLMList3.Get(1, WebOrderXLMNode4) then begin
                    WebOrderXLMElement4 := WebOrderXLMNode4.AsXmlElement();
                    Generictext := WebOrderXLMElement4.InnerText;
                end;

                if WebOrderXLMList3.Get(18, ASINNOXMLlistNode) then
                    ASINNOXMLlistNodeElement := ASINNOXMLlistNode.AsXmlElement();
                if not ASINNOXMLlistNodeElement.IsEmpty() and ASINNOXMLlistNodeElement.HasElements() then
                    ASINNOXMLlist := ASINNOXMLlistNodeElement.GetChildNodes();

                Clear(ASINNOXMLlistNodeElement1);
                if ASINNOXMLlist.get(1, ASINNOXMLlistNode1) then
                    ASINNOXMLlistNodeElement1 := ASINNOXMLlistNode1.AsXmlElement();
                ASINNOXMLlist1 := ASINNOXMLlistNodeElement1.GetChildNodes();

                Clear(NmberAsin);
                if ASINNOXMLlist1.Get(8, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    NmberAsin := GenericElement.InnerText;
                end;
                //ItemsInsertCode

                ChannelItemListing.RESET;
                // if Generictext = 'Voucher' then begin
                //     Message('Voucher');
                // end;
                if NmberAsin <> '' then
                    ChannelItemListing.SetRange("ASIN No", NmberAsin);
                ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                ChannelItemListing.SETRANGE("Channel SKU", Generictext);

                IF ChannelItemListing.FINDFIRST THEN BEGIN
                    UpdateProduct(WebOrderXLMList3, FALSE, ChannelItemListing, ChannelCode);
                END
                ELSE BEGIN
                    CreateProduct(WebOrderXLMList3, true, ChannelCode);
                END;
            end;
        end;
    end;

    local procedure UpdateProduct(P_ItemDataNodeList: XmlNodeList; bool: Boolean; ChannelItemListing: Record "Channel Item Listing"; ChannelCode: Code[10])
    var
        ItemName: Text;
        ItemDescription: Text;
        //ChannelItemListing: Record "Channel Item Listing";
        unitPrice: Decimal;
        UnitPriceText: text;
        ChannelInvquantity: Decimal;
        ChannelInvOldquantity: Decimal;
        InvItemId: BigInteger;
        ITEM: Record 27;
        NetWeight: Decimal;
        ItemSKU: Text;
        SubProductCount: Integer;
        K: Integer;
        ChannelSKUCheck: Text;
        ChannelSKU: Code[20];
        InventoryVisualsoft: Decimal;
    begin
        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelSKUCheck := GenericElement.InnerText;
        end;

        if ChannelSKUCheck <> '' then begin
            ChannelItemListing.Validate("Channel SKU", ChannelItemListing."Channel SKU");
            ChannelItemListing.Validate("ASIN No", ChannelItemListing."ASIN No");
            ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
            ChannelItemListing.VALIDATE("Price Synced", TRUE);
            ChannelItemListing.VALIDATE("Inventory Synced", TRUE);
            ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);

            Clear(GenericNode);
            Clear(GenericElement);

            Clear(GenericNode);
            Clear(GenericElement);
            if P_ItemDataNodeList.Get(2, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing."Channel Title" := GenericElement.InnerText;
            end;

            // Clear(GenericNode);
            // Clear(GenericElement);
            // if P_ItemDataNodeList.Get(5, GenericNode) then begin
            //     GenericElement := GenericNode.AsXmlElement();
            //     ChannelItemListing."ASIN No" := GenericElement.InnerText;
            // end;

            // if P_ItemDataNodeList.Get(1, GenericNode) then begin
            //     GenericElement := GenericNode.AsXmlElement();
            //     ChannelItemListing."Channel SKU" := GenericElement.InnerText;

            // end;

            if P_ItemDataNodeList.Get(18, SubProductXMLNode) then
                SubProductXMLElement := SubProductXMLNode.AsXmlElement();
            if not SubProductXMLElement.IsEmpty() and SubProductXMLElement.HasElements() then
                SubProductXMLNodeList := SubProductXMLElement.GetChildNodes();

            SubProductCount := SubProductXMLNodeList.Count;

            if SubProductXMLNodeList.Count > 0 then begin
                for k := 1 to SubProductXMLNodeList.Count do begin

                    if SubProductXMLNodeList.get(K, SubProductXMLNode1) then
                        SubProductXMLElement1 := SubProductXMLNode1.AsXmlElement();
                    SubProductXMLNodeList1 := SubProductXMLElement1.GetChildNodes();
                    if SubProductXMLNodeList1.Get(K, SubProductXMLNode2) then
                        SubProductXMLElement2 := SubProductXMLNode2.AsXmlElement();
                    // if not SubProductXMLElement2.IsEmpty() and SubProductXMLElement2.HasElements() then
                    //  WebOrderXLMList3 := WebOrderXLMElement3.GetChildNodes();
                    // UpdateSubproduct(SubProductXMLNodeList1, ChannelItemListing, ChannelCode, AsinNo);

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if SubProductXMLNodeList1.Get(1, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        ChannelSKU := GenericElement.InnerText;
                    end;
                    //  if ChannelSKU = ASINNO then begin

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if SubProductXMLNodeList1.Get(14, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        UnitPriceText := GenericElement.InnerText;
                        if UnitPriceText <> '' then
                            Evaluate(UnitPrice, GenericElement.InnerText);
                        ChannelItemListing."Unit Price" := UnitPrice;
                    end;

                    // if SubProductXMLNodeList1.Get(8, GenericNode) then begin
                    //     GenericElement := GenericNode.AsXmlElement();
                    //     ChannelItemListing."ASIN No" := GenericElement.InnerText;
                    // end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    Clear(InventoryVisualsoft);
                    if SubProductXMLNodeList1.Get(5, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        Evaluate(InventoryVisualsoft, GenericElement.InnerText);
                        ChannelItemListing."Channel Inventory" := InventoryVisualsoft;
                    end;
                    //  end;
                end;
            end;
        end;
        ChannelItemListing.MODIFY();
    end;

    local procedure CreateProduct(P_ItemDataNodeList: XmlNodeList; bool: Boolean; ChannelCode: Code[20])
    var
        ItemName: Text;
        ItemDescription: Text;
        ChannelItemListing: Record "Channel Item Listing";
        unitPrice: Decimal;
        ChannelInvquantity: Decimal;
        ChannelInvOldquantity: Decimal;
        InvItemId: BigInteger;
        ITEM: Record Item;
        NetWeight: Decimal;
        ItemSKU: Text;
        k: Integer;
        SubProductCount: Integer;
        ChannelSKU: Code[20];
        InventoryVisualsoft: Integer;
        UnitPricetext: text;
    begin
        CLEAR(ChannelItemListing);
        ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
        //
        // need to added fields
        //
        ChannelItemListing.VALIDATE("Price Synced", TRUE);
        ChannelItemListing.VALIDATE("Inventory Synced", TRUE);
        ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);

        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelItemListing."Channel SKU" := GenericElement.InnerText;

        end;

        // Clear(GenericNode);
        // Clear(GenericElement);
        // if P_ItemDataNodeList.Get(5, GenericNode) then begin
        //     GenericElement := GenericNode.AsXmlElement();
        //     ChannelItemListing."ASIN No" := GenericElement.InnerText;
        // end;

        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(2, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelItemListing."Channel Title" := GenericElement.InnerText;
        end;

        if P_ItemDataNodeList.Get(18, SubProductXMLNode) then
            SubProductXMLElement := SubProductXMLNode.AsXmlElement();
        if not SubProductXMLElement.IsEmpty() and SubProductXMLElement.HasElements() then
            SubProductXMLNodeList := SubProductXMLElement.GetChildNodes();

        SubProductCount := SubProductXMLNodeList.Count;

        if SubProductXMLNodeList.Count > 0 then begin
            for k := 1 to SubProductXMLNodeList.Count do begin

                if SubProductXMLNodeList.get(K, SubProductXMLNode1) then
                    SubProductXMLElement1 := SubProductXMLNode1.AsXmlElement();
                SubProductXMLNodeList1 := SubProductXMLElement1.GetChildNodes();
                if SubProductXMLNodeList1.Get(K, SubProductXMLNode2) then
                    SubProductXMLElement2 := SubProductXMLNode2.AsXmlElement();

                //  CreateSubproduct(SubProductXMLNodeList1, ChannelItemListing, ChannelCode, ASINNO);

                Clear(GenericNode);
                Clear(GenericElement);
                if SubProductXMLNodeList1.Get(1, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    ChannelSKU := GenericElement.InnerText;
                end;
                //if ChannelSKU = ASINNO then begin

                Clear(GenericNode);
                Clear(GenericElement);
                if SubProductXMLNodeList1.Get(14, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    UnitPricetext := GenericElement.InnerText;
                    if UnitPricetext <> '' then
                        Evaluate(UnitPrice, GenericElement.InnerText);
                    ChannelItemListing."Unit Price" := UnitPrice;
                end;

                Clear(GenericNode);
                Clear(GenericElement);
                if SubProductXMLNodeList1.Get(8, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    ChannelItemListing."ASIN No" := GenericElement.InnerText;
                end;

                Clear(GenericNode);
                Clear(GenericElement);
                Clear(InventoryVisualsoft);
                if SubProductXMLNodeList1.Get(5, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    Evaluate(InventoryVisualsoft, GenericElement.InnerText);
                    ChannelItemListing."Channel Inventory" := InventoryVisualsoft;
                end;
                // end;
            end;
        end;
        ChannelItemListing.INSERT(TRUE);
    end;

    procedure CreateSubproduct(SubproductNoeList: XmlNodeList; ChannelItemListing: Record "Channel Item Listing"; ChannelCode: Code[10]; ASINNO: Text)
    var
        ChannelSKU: Text;
        UnitPrice: Decimal;

    begin
        Clear(GenericNode);
        Clear(GenericElement);
        if SubproductNoeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelSKU := GenericElement.InnerText;
        end;
        if ChannelSKU <> ASINNO then begin

            ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
            ChannelItemListing.VALIDATE("Price Synced", TRUE);
            ChannelItemListing.VALIDATE("Inventory Synced", TRUE);
            //  ChannelItemListing."ASIN No" := ASINNO;


            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(1, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing."Channel SKU" := GenericElement.InnerText;
            end;

            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(3, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing."Channel Title" := GenericElement.InnerText;

            end;

            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(28, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing.Description := GenericElement.InnerText;

            end;

            ChannelItemListing.Insert();

        end else begin
            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(18, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                Evaluate(UnitPrice, GenericElement.InnerText);
                ChannelItemListing."Unit Price" := UnitPrice;

            end;
            ChannelItemListing.Modify();
        End;
    end;

    procedure UpdateSubproduct(SubproductNoeList: XmlNodeList; ChannelItemListing: Record "Channel Item Listing"; ChannelCode: Code[10]; ASINNO: Text)
    var
        ChannelSKU: Text;
    begin
        Clear(GenericNode);
        Clear(GenericElement);
        if SubproductNoeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelSKU := GenericElement.InnerText;
        end;
        if ChannelSKU <> ASINNO then begin


            ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
            ChannelItemListing.VALIDATE("Price Synced", TRUE);
            ChannelItemListing.VALIDATE("Inventory Synced", TRUE);
            ChannelItemListing."ASIN No" := ASINNO;

            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(1, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing."Channel SKU" := GenericElement.InnerText;

            end;

            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(3, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing."Channel Title" := GenericElement.InnerText;

            end;

            Clear(GenericNode);
            Clear(GenericElement);
            if SubproductNoeList.Get(28, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                ChannelItemListing.Description := GenericElement.InnerText;

            end;

            ChannelItemListing.Modify();

        end;
    end;

    procedure UpdateProductStok(ChannelCode: code[20])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        j: Integer;
        TradePartner: Record "Trade Partner";
        ChannelItemListing: Record "Channel Item Listing";
        Stock: Text;
        ChannelSKU: Text;
        ItemRec: Record Item;
        GeneralSetup: Record "General Setup - Channels";
    begin
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETFILTER("Inventory Synced", '%1', FALSE);
        ChannelItemListing.SetFilter("Item No.", '<>%1', '');
        //ChannelItemListing.SetRange("Item No.", 'DANNY1');
        if ChannelItemListing.FindSet() then begin
            repeat
                Clear(URL);
                Clear(RequestMessage);
                Clear(Content);
                Clear(Headers);
                Clear(Client);
                Clear(ResponseMessage);
                Clear(Stock);
                Clear(ChannelSKU);

                ItemRec.Reset();
                ItemRec.SetRange("No.", ChannelItemListing."Item No.");
                ItemRec.SetRange("Production Item", true);
                if ItemRec.FindFirst() then begin
                    Clear(Stock);
                    Clear(ChannelSKU);
                    GeneralSetup.Get();
                    Stock := format(GeneralSetup."Production Item Inventory");
                    ChannelSKU := ItemRec."No.";
                end
                else begin
                    Clear(Stock);
                    Clear(ChannelSKU);
                    Stock := format(ChannelItemListing."Channel Inventory");
                    ChannelSKU := ChannelItemListing."Channel SKU";
                end;

                GetCredentials(ChannelCode);
                //Live Request Body++
                Clear(RequestBody);
                RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + ServiceURL + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username> <Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ser:SetStock><product_reference>' + ChannelSKU + '</product_reference><stock_level>' + Stock + '</stock_level></ser:SetStock></soapenv:Body></soapenv:Envelope>';
                //Live Request Body--

                //SoapAction := SoapActionUrl + '#SetStock';

                URL := ServiceURL;
                Clear(RequestMessage);
                RequestMessage.SetRequestUri(URL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Headers := Client.DefaultRequestHeaders;
                Headers.Add('Authorization', CreateBasicAuth(AccessKeyId, BasicAuthPassword, MarketplaceId));
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Clear();
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                //Headers.Add('soapAction', SoapAction);
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);
                ResponseMessage.Content().ReadAs(Response);
                if ResponseMessage.HttpStatusCode = 200 then begin
                    Evaluate(ChannelItemListing."Channel Inventory", Stock);
                    ChannelItemListing."Inventory Synced" := TRUE;
                    ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                    ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    ChannelItemListing.Remarks := 'Inventory updated successfully';
                end;
                ChannelItemListing.Modify();
                Commit();
                Sleep(2000);
            UNTIL ChannelItemListing.NEXT = 0;
        end;
    End;

    local procedure setInventory(ChannelCode: Code[20])
    var
        CIL: Record "Channel Item Listing";
        Items: Record Item;
        ChannelInventory: Integer;
    begin
        CIL.RESET;
        CIL.SETRANGE("Channel Code", ChannelCode);
        IF CIL.FINDSET THEN BEGIN
            REPEAT
                if CIL."Item No." = '' then begin
                    CIL."Channel Inventory" := 0;
                    CIL.Modify();
                end
                else begin
                    Clear(ChannelInventory);
                    Items.Reset();
                    Items.SetRange("No.", CIL."Item No.");
                    if Items.FindFirst() then begin
                        ChannelInventory := CIL."Channel Inventory";
                        Items.CalcFields(Inventory, "Qty. on Sales Order");
                        CIL."Channel Inventory" := Items.Inventory;
                        if CIL."Channel Inventory" < 0 then
                            CIL.Validate("Channel Inventory", 0);
                        CIL.Modify();
                        IF ChannelInventory <> CIL."Channel Inventory" THEN begin
                            CIL."Inventory Synced" := false;
                            CIL.Modify();
                        end;
                    end;
                end;

            UNTIL CIL.NEXT = 0;
        END;
    end;

    local procedure UpdateChannelItemListing(ChannelCode: Code[20])
    var
        ChannelItemListing: Record "Channel Item Listing";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        TradePartner: Record "Trade Partner";
        ItemQuery: Query ItemQuery;
        AvailableInventory: Decimal;
        BOMComponent: Record "BOM Component";
        Counter: Integer;
        LowestInventory: Decimal;
        Rec_Item: Record Item;
        GeneralSetup: Record "General Setup - Channels";
    begin
        GeneralSetup.Get();
        if TradePartner.Get(ChannelCode) then;
        ChannelItemListing.Reset();
        ChannelItemListing.SetRange("Channel Code", ChannelCode);
        ChannelItemListing.SetFilter("Item No.", '<>%1', '');
        //ChannelItemListing.SetFilter("Item No.", 'ILW20008-SAMPLE');
        if ChannelItemListing.FindSet() then begin
            repeat
                if Item.Get(ChannelItemListing."Item No.") then begin
                    if Item."Production Item" = true then begin
                        if ChannelItemListing."Channel Inventory" <> GeneralSetup."Production Item Inventory" then begin
                            ChannelItemListing."Channel Inventory" := GeneralSetup."Production Item Inventory";
                            ChannelItemListing."Inventory Synced" := false;
                        end
                        else begin
                            ChannelItemListing."Inventory Synced" := true;
                        end;
                    end
                    else begin
                        ItemCategory.Reset();
                        ItemCategory.SetRange(Code, Item."Item Category Code");
                        if ItemCategory.FindFirst() then;

                        if ItemCategory."Auto Assembly Order" = true then begin
                            Counter := 0;
                            Clear(LowestInventory);
                            BOMComponent.Reset();
                            BOMComponent.SetRange("Parent Item No.", ChannelItemListing."Item No.");
                            BOMComponent.SetRange(Type, BOMComponent.Type::Item);
                            if BOMComponent.FindSet() then begin
                                repeat
                                    if Rec_Item.Get(BOMComponent."No.") then begin
                                        Clear(AvailableInventory);
                                        CLEAR(ItemQuery);
                                        ItemQuery.SETRANGE(ItemQuery.No, BOMComponent."No.");
                                        ItemQuery.SETRANGE(ItemQuery.Location_Filter, TradePartner.Location);
                                        ItemQuery.SetFilter(ItemQuery.Bin_Type_Filter, 'PUTAWAY|PUTPICK|PICK');

                                        ItemQuery.OPEN;
                                        IF ItemQuery.READ THEN begin
                                            AvailableInventory := (ItemQuery.Inventory_Qty_) - (ItemQuery.Qty_on_Sales_Order + ItemQuery.Qty_on_Web_Order + ItemQuery.Qty__on_Assembly_Order);
                                        END;
                                        ItemQuery.CLOSE;

                                        if Counter = 0 then begin
                                            LowestInventory := AvailableInventory;
                                        end
                                        else begin
                                            if AvailableInventory < LowestInventory then
                                                LowestInventory := AvailableInventory;
                                        end;
                                        Counter += 1;
                                    end;
                                until BOMComponent.Next() = 0;
                            end;

                            if LowestInventory <> ChannelItemListing."Channel Inventory" then begin
                                if LowestInventory < 0 then begin
                                    ChannelItemListing.Validate("Channel Inventory", 0);
                                end
                                else begin
                                    ChannelItemListing.Validate("Channel Inventory", LowestInventory);
                                end;
                                ChannelItemListing."Inventory Synced" := false;
                                ChannelItemListing."Modified On" := CurrentDateTime;
                            end;
                        end
                        else begin
                            Clear(AvailableInventory);
                            CLEAR(ItemQuery);
                            ItemQuery.SETRANGE(ItemQuery.No, ChannelItemListing."Item No.");
                            ItemQuery.SETRANGE(ItemQuery.Location_Filter, TradePartner.Location);
                            ItemQuery.SetFilter(ItemQuery.Bin_Type_Filter, 'PUTAWAY|PUTPICK|PICK');

                            ItemQuery.OPEN;
                            IF ItemQuery.READ THEN begin
                                AvailableInventory := (ItemQuery.Inventory_Qty_) - (ItemQuery.Qty_on_Sales_Order + ItemQuery.Qty_on_Web_Order);
                            END;
                            ItemQuery.CLOSE;

                            if AvailableInventory <> ChannelItemListing."Channel Inventory" then begin
                                if AvailableInventory < 0 then begin
                                    ChannelItemListing.Validate("Channel Inventory", 0);
                                end
                                else begin
                                    ChannelItemListing.Validate("Channel Inventory", AvailableInventory);
                                end;
                                ChannelItemListing."Inventory Synced" := false;
                                ChannelItemListing."Modified On" := CurrentDateTime;
                            end;
                        end;
                    end;
                end
                else begin
                    ChannelItemListing.Remarks := 'Item Not Found ' + ChannelItemListing."Item No.";
                    ChannelItemListing."Modified On" := CurrentDateTime;
                end;

                ChannelItemListing.Modify(true);
                Commit();
            until ChannelItemListing.Next() = 0;
        end;
    end;

    procedure UpdateOrderStatus(Channelcode: Code[20])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        OrderStatusBody: Text;
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        ShippingRule: Record "Shipping Rule";
    begin
        HandledInterimSalesHeader.Reset();
        HandledInterimSalesHeader.SetRange("Trade Partner Code", Channelcode);
        HandledInterimSalesHeader.SetFilter("FullFillment Status", '<>%1', HandledInterimSalesHeader."FullFillment Status"::Fullfilled);
        HandledInterimSalesHeader.SetRange("Document Type", HandledInterimSalesHeader."Document Type"::Order);
        HandledInterimSalesHeader.SetFilter("Package Tracking No.", '<>%1', '');
        HandledInterimSalesHeader.SetFilter(status, '%1', HandledInterimSalesHeader.status::Dispatched);
        //HandledInterimSalesHeader.SetFilter("No.", '%1', 'WEB32600');
        if HandledInterimSalesHeader.FindSet() then begin
            repeat
                ClearAll();
                Clear(URL);
                Clear(Headers);
                Clear(Content);
                Clear(Client);
                Clear(CourierName);
                Clear(OrderAmount);
                Clear(RequestBody);
                Clear(RequestMessage);
                Clear(ResponseMessage);

                GetCredentials(ChannelCode);

                if HandledInterimSalesHeader."Shipping Agent Code" <> '' then begin
                    CourierName := HandledInterimSalesHeader."Shipping Agent Code";
                end
                else begin
                    if HandledInterimSalesHeader."Web Shipment Method" <> '' then begin
                        ShippingRule.Reset();
                        ShippingRule.SetRange("Channel Code", Channelcode);
                        ShippingRule.SetRange("Web Shipment Method", HandledInterimSalesHeader."Web Shipment Method");
                        if ShippingRule.FindFirst() then begin
                            CourierName := ShippingRule."Shipping Agent";
                        end;
                    end;
                end;

                if HandledInterimSalesHeader."Order Amount" <> 0 then begin
                    OrderAmount := HandledInterimSalesHeader."Order Amount";
                end
                else begin
                    HandledInterimSalesLine.Reset();
                    HandledInterimSalesLine.SetRange("Document Type", HandledInterimSalesHeader."Document Type");
                    HandledInterimSalesLine.SetRange("Document No", HandledInterimSalesHeader."No.");
                    HandledInterimSalesLine.SetFilter(Type, '%1|%2', HandledInterimSalesLine.Type::Item, HandledInterimSalesLine.Type::"G/L Account");
                    if HandledInterimSalesLine.FindSet() then begin
                        repeat
                            OrderAmount := OrderAmount + HandledInterimSalesLine."Amount Including VAT";
                        until HandledInterimSalesLine.Next() = 0;
                    end;
                end;

                Clear(OrderStatusBody);
                OrderStatusBody := GenerateOrderStatus(HandledInterimSalesHeader);

                RequestBody := StrSubstNo('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="%1">' +
                                '<soapenv:Header><VSAuth><ClientID>%2</ClientID><Username>%3</Username><Password>%4</Password>' +
                                '</VSAuth></soapenv:Header><soapenv:Body><ns:OrderStatusUpdate><order_update_data><![CDATA[<ORDER_STATUSES>%5</ORDER_STATUSES>]]>' +
                                '</order_update_data><data_type>xml</data_type></ns:OrderStatusUpdate></soapenv:Body></soapenv:Envelope>', ServiceURL,
                                MarketplaceId, AccessKeyId, SecretAccessKey, OrderStatusBody);

                URL := ServiceURL;
                RequestMessage.SetRequestUri(URL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Headers := Client.DefaultRequestHeaders;
                Headers.Add('Authorization', CreateBasicAuth(AccessKeyId, BasicAuthPassword, MarketplaceId));
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Clear();
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);

                ResponseMessage.Content().ReadAs(Response);
                if ResponseMessage.HttpStatusCode = 200 then begin
                    HandledInterimSalesHeader.Validate("FullFillment Status", HandledInterimSalesHeader."FullFillment Status"::Fullfilled);
                    if HandledInterimSalesHeader.Remarks <> '' then
                        HandledInterimSalesHeader.Remarks := '';
                end
                else begin
                    HandledInterimSalesHeader.Remarks := CopyStr('Order No. - ' + HandledInterimSalesHeader."No." + ' Error Message -> ' + Response, 1, 250);
                end;
                HandledInterimSalesHeader.Modify();
                Commit();
                Sleep(1500);
            until HandledInterimSalesHeader.Next() = 0;
        end;
    end;


    local procedure GenerateOrderStatus(var P_HandledInterimSalesHeader: Record "Handled Interim Sales Header"): Text
    var
        L_OrderStatusBody: Text;
        ShipmentTracking: Record "Shipment Tracking";
    begin
        Clear(L_OrderStatusBody);
        ShipmentTracking.Reset();
        ShipmentTracking.SetRange("Document No.", P_HandledInterimSalesHeader."No.");
        ShipmentTracking.SetRange("Document Type", P_HandledInterimSalesHeader."Document Type");
        if ShipmentTracking.FindSet() then begin
            repeat
                L_OrderStatusBody += StrSubstNo('<ORDER_STATUS><ORDER_ID>%1</ORDER_ID><ORDER_STATUS>Order Dispatched</ORDER_STATUS>' +
                                    '<SEND_CUSTOMER_EMAIL>true</SEND_CUSTOMER_EMAIL><BASIC_TRACKING_NUMBER>%2</BASIC_TRACKING_NUMBER>' +
                                    '<TRACKING_NUMBER_COURIER>%3</TRACKING_NUMBER_COURIER><SHIPPING_LABEL></SHIPPING_LABEL>' +
                                    '<CUSTOMER_COMMENTS></CUSTOMER_COMMENTS><ADMIN_COMMENTS></ADMIN_COMMENTS><TAKE_PAYMENT>%4</TAKE_PAYMENT></ORDER_STATUS>',
                                P_HandledInterimSalesHeader."Channel Order ID", ShipmentTracking."Tracking No.", CourierName, OrderAmount);
            until ShipmentTracking.Next() = 0;
        end
        else begin
            if P_HandledInterimSalesHeader."Package Tracking No." <> '' then
                L_OrderStatusBody := StrSubstNo('<ORDER_STATUS><ORDER_ID>%1</ORDER_ID><ORDER_STATUS>Order Dispatched</ORDER_STATUS>' +
                                    '<SEND_CUSTOMER_EMAIL>true</SEND_CUSTOMER_EMAIL><BASIC_TRACKING_NUMBER>%2</BASIC_TRACKING_NUMBER>' +
                                    '<TRACKING_NUMBER_COURIER>%3</TRACKING_NUMBER_COURIER><SHIPPING_LABEL></SHIPPING_LABEL>' +
                                    '<CUSTOMER_COMMENTS></CUSTOMER_COMMENTS><ADMIN_COMMENTS></ADMIN_COMMENTS><TAKE_PAYMENT>%4</TAKE_PAYMENT></ORDER_STATUS>',
                                P_HandledInterimSalesHeader."Channel Order ID", P_HandledInterimSalesHeader."Package Tracking No.", CourierName, OrderAmount);
        end;
        exit(L_OrderStatusBody);
    end;


    procedure UpdateProductPrice(ChannelCode: code[20])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        j: Integer;
        TradePartner: Record "Trade Partner";
        responseText: Text;
        ChannelItemListing: Record "Channel Item Listing";
        Stock: Text;
        ChannelSKU: Text;
    begin
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETFILTER("Price Synced", '%1', FALSE);
        if ChannelItemListing.FindFirst() then begin
            repeat
                Clear(Stock);
                Clear(ChannelSKU);
                Stock := format(ChannelItemListing."Unit Price");
                ChannelSKU := ChannelItemListing."Channel SKU";

                GetCredentials(ChannelCode);
                //Live Request Body++
                Clear(RequestBody);
                RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="https://demo.visualsoft.co.uk/api/soap/service"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username> <Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ser:SetStock><product_reference>' + ChannelSKU + '</product_reference><stock_level>' + Stock + '</stock_level></ser:SetStock></soapenv:Body></soapenv:Envelope>';
                //Live Request Body--

                URL := ServiceURL;
                Clear(RequestMessage);
                RequestMessage.SetRequestUri(URL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Headers := Client.DefaultRequestHeaders;
                Headers.Add('Authorization', CreateBasicAuth(AccessKeyId, BasicAuthPassword, MarketplaceId));
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Clear();
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                //Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service/5#GetOrdersByDateRange');
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);
                ResponseMessage.Content().ReadAs(Response);
                ResponseMessage.Content.ReadAs(responseText);
                if ResponseMessage.HttpStatusCode = 200 then begin
                    ChannelItemListing."Price Synced" := TRUE;
                    ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                    ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                end
                else begin
                    ChannelItemListing.Remarks := copystr(responseText, 1, 100);
                end;
                ChannelItemListing.MODIFY;
            UNTIL ChannelItemListing.NEXT = 0;
        END;
        Message('Price Updated Sucessfully');
    end;

    procedure CreateBasicAuth(UserName: Text; Password: Text; Domain: Text): Text
    var
        CUTempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
        InStrm: InStream;
        tempText: Text;
    begin
        tempText := StrSubstNo('%1:%2:%3', UserName, Password, Domain);
        CUTempBlob.CreateOutStream(OutStm, TextEncoding::UTF8);
        OutStm.WriteText(StrSubstNo('%1:%2:%3', UserName, Password, Domain));
        CUTempBlob.CreateInStream(InStrm);
        exit(StrSubstNo('Basic %1', Base64Convert.ToBase64(InStrm)));
    end;

    local procedure GenerateDateTime(createDate: Text): DateTime
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        TimeType: Time;
        Convertdate: DateTime;
    begin
        if (createDate <> '') And (createDate <> '0000-00-00 00:00:00') then begin
            evaluate(Day, copystr(createDate, 9, 2));
            evaluate(Month, copystr(createDate, 6, 2));
            evaluate(Year, copystr(createDate, 1, 4));
            evaluate(TimeType, copystr(createDate, 12, 8));
            Convertdate := createdatetime(DMY2DATE(Day, Month, Year), TimeType);
        End;
        exit(Convertdate);
    end;

    local procedure GenerateNewDate(Orderdate: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Convertdate: Date;
        Lenght: Integer;
        ISh: Record "Interim Sales Header";
    begin
        if Orderdate <> '' then begin
            Orderdate := Orderdate.Substring(1, 10);
            Lenght := StrLen(Orderdate.Trim());
            if Lenght > 0 then begin
                if StrPos(Orderdate, '/') > 0 then begin
                    Evaluate(Year, Orderdate.Split('/').Get(1));
                    Evaluate(Month, Orderdate.Split('/').Get(2));
                    Evaluate(Day, Orderdate.Split('/').Get(3));
                    Convertdate := DMY2Date(Day, Month, Year);
                end;
                if StrPos(Orderdate, '-') > 0 then begin
                    Evaluate(Year, Orderdate.Split('-').Get(1));
                    Evaluate(Month, Orderdate.Split('-').Get(2));
                    Evaluate(Day, Orderdate.Split('-').Get(3));
                    Convertdate := DMY2Date(Day, Month, Year);
                end;
            end;
        end;
        exit(Convertdate);
    end;

    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        SyncItemLabel: Label 'SyncItem';
        UpdateInventoryLabel: label 'UpdateInventory';
        StartDate: Text;
        AccessKeyId: Text;
        MarketplaceId: Text;
        SecretAccessKey: Text;
        StartDateTime: DateTime;
        EndDate: Text;
        ServiceURL: Text;
        ProductCount: text;
        ProductPageCount: text;
        BasicAuthPassword: text;
        G_ShippingPrice: Decimal;
        GenericNode: XmlNode;
        GenericElement: XmlElement;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        SubProductXMLNodeList: XmlNodeList;
        SubProductXMLNode: XmlNode;
        SubProductXMLElement: XmlElement;
        SubProductXMLNodeList1: XmlNodeList;
        SubProductXMLNode1: XmlNode;
        SubProductXMLElement1: XmlElement;
        SubProductXMLNode2: XmlNode;
        SubProductXMLElement2: XmlElement;
        EndDateTime: DateTime;
        NoOfDays: Decimal;
        NoOfHours: Decimal;
        NewDateTime: DateTime;
        NewDate: Date;
        DateDuration: Duration;
        productOffset: Integer;
        ProductLoop: Boolean;
        CourierName: Code[10];
        OrderAmount: Decimal;
        TradePartner: Record "Trade Partner";
        IsError: Boolean;
        PaymentMethod: array[5] of Text;
}