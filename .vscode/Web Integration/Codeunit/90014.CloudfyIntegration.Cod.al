codeunit 90014 "Cloudfy Integration"
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
                    //GetOrders(StartParameter);
                    GetCredentials(StartParameter);
                End;
            SyncShipmentLabel:
                begin
                    UpdateOrderStatusToComplete(StartParameter);
                end;
        end;
    end;

    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        TokenId: Text;
        SiteId: Text;
        OrderStatus: Text;
        StartDate: Text;
        StartDateTime: DateTime;
        EndDate: Text;
        EndDateTime: DateTime;
        DateDuration: Duration;
        NoOfDays: Decimal;
        NoOfHours: Decimal;
        NewDateTime: DateTime;
        NewDate: Date;
        ServiceURL: Text;
        GenericNode: XmlNode;
        GenericElement: XmlElement;
        CUWebOrderMgt: Codeunit "Web Order Mgt";


    local procedure GetCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            TokenId := TradePartner.AccessKeyId;
            SiteId := TradePartner.MarketplaceId;
            ServiceURL := TradePartner."Sevice/API URL";
            OrderStatus := TradePartner."API Endpoint";
            //StartDateTime := TradePartner."Last Order Sync";            
            StartDateTime := CreateDateTime(CalcDate('-1D', DT2Date(TradePartner."Last Order Sync")), DT2Time(TradePartner."Last Order Sync"));
            //StartTime := DT2Time(StartDateTime);
            //StartTime := StartTime - 10800000;
            //StartDateTime := CreateDateTime(DT2Date(StartDateTime), StartTime);
            //StartDate := Format(StartDateTime, 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>');
            EndDateTime := TradePartner."Last Customer Sync";

            GenerateStartDateEndDate(ChannelCode);

            if EndDateTime <> 0DT then begin
                TradePartner."Last Order Sync" := EndDateTime;
                TradePartner.Modify;
            end
            else begin
                TradePartner."Last Order Sync" := CREATEDATETIME(WORKDATE, TIME);
                TradePartner.Modify;
            end;
            Message('Orders Sync Completed...');
        end;
    end;


    local procedure GenerateCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            TokenId := TradePartner.AccessKeyId;
            SiteId := TradePartner.MarketplaceId;
            ServiceURL := TradePartner."Sevice/API URL";
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
    begin
        //Live Request Body++
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nav="http://tempuri.org/Navision">' +
                '<soapenv:Header/><soapenv:Body><nav:GetOrders><nav:Token_Id>' + TokenId + '</nav:Token_Id>' +
                '<nav:Site_Id>' + SiteId + '</nav:Site_Id><nav:Records></nav:Records><nav:StartDate>' + StartDate + '</nav:StartDate>' +
                '<nav:EndDate>' + EndDate + '</nav:EndDate><nav:OrderStatus>' + OrderStatus + '</nav:OrderStatus></nav:GetOrders></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--

        //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
        URL := ServiceURL;

        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        Headers.Add('SOAPAction', 'http://tempuri.org/Navision/INavision/GetOrders');
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        if ResponseMessage.HttpStatusCode = 200 then begin
            InsertXMLResponse(Response, ChannelCode);
        end;
    end;


    local procedure InsertXMLResponse(P_Response: Text; ChannelCode: Code[10])
    var
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
    begin
        P_Response := CU_XMLDOMMgmt.RemoveNamespaces(P_Response);
        XmlDocument.ReadFrom(P_Response, L_XmlDocument);

        L_NavOrderResultList := L_XmlDocument.GetDescendantElements('GetOrdersResult');
        if L_NavOrderResultList.Get(1, L_NavOrderResultNode) then
            L_NavOrderResultElement := L_NavOrderResultNode.AsXmlElement();
        if not L_NavOrderResultElement.IsEmpty() and L_NavOrderResultElement.HasElements() then begin
            Clear(L_NavOrderResultList);
            L_NavOrderResultList := L_NavOrderResultElement.GetChildNodes();
        end;

        //Status
        if L_NavOrderResultList.Get(2, L_StatusNode) then
            L_StatusElement := L_StatusNode.AsXmlElement();
        if not L_StatusElement.IsEmpty() and L_StatusElement.HasElements() then
            L_StatusNodeList := L_StatusElement.GetChildNodes();
        //Status

        //Message
        if L_StatusNodeList.Get(1, L_MessageNode) then
            L_MessageElement := L_MessageNode.AsXmlElement();
        //Message

        if L_MessageElement.InnerText = 'Success' then begin
            //OrderData
            if L_NavOrderResultList.Get(1, L_OrderDataNode) then
                L_OrderDataElement := L_OrderDataNode.AsXmlElement();
            if not L_OrderDataElement.IsEmpty() and L_OrderDataElement.HasElements() then
                L_OrderDataNodeList := L_OrderDataElement.GetChildNodes();

            if L_OrderDataNodeList.Count > 0 then begin

                For i := 1 to L_OrderDataNodeList.Count do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();

                    Clear(L_OrderResponseNode);
                    Clear(L_OrderResponseElement);

                    if L_OrderDataNodeList.Get(i, L_OrderResponseNode) then
                        L_OrderResponseElement := L_OrderResponseNode.AsXmlElement();
                    if not L_OrderResponseElement.IsEmpty() and L_OrderResponseElement.HasElements() then begin
                        L_OrderNodeList := L_OrderResponseElement.GetChildNodes();
                    end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    //if L_OrderNodeList.Get(16, GenericNode) then begin
                    //if L_OrderNodeList.Get(18, GenericNode) then begin   //Live
                    if L_OrderNodeList.Get(19, GenericNode) then begin  //UAT
                        GenericElement := GenericNode.AsXmlElement();
                        OrderSource := GenericElement.InnerText();
                    end;

                    TradePartner.Reset();
                    if TradePartner.Get(ChannelCode) then begin
                        if (OrderSource = 'Cloudfy') and (ChannelCode = 'CLOUDFYB2B') then begin
                            InsertInInterimSalesHeader(L_OrderNodeList, ChannelCode, InterimSalesHeader, PaymentDetails, OrderSource);
                            InsertInInterimSalesLine(L_OrderNodeList, ChannelCode, InterimSalesHeader, InterimSalesLine, OrderSource);

                            CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                            Commit();
                            UpdateOrderTracking(ChannelCode);
                            ConvertStatusToAcknowledge(ChannelCode);
                        end;

                        if (OrderSource = 'API') and (ChannelCode = 'CLOUDFYB2C') then begin
                            InsertInInterimSalesHeader(L_OrderNodeList, ChannelCode, InterimSalesHeader, PaymentDetails, OrderSource);
                            InsertInInterimSalesLine(L_OrderNodeList, ChannelCode, InterimSalesHeader, InterimSalesLine, OrderSource);

                            CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                            Commit();
                            UpdateOrderTracking(ChannelCode);
                            ConvertStatusToAcknowledge(ChannelCode);
                        end;

                        if (OrderSource = 'NEXT') and (ChannelCode = 'CLOUDFYNXT') then begin
                            InsertInInterimSalesHeader(L_OrderNodeList, ChannelCode, InterimSalesHeader, PaymentDetails, OrderSource);
                            InsertInInterimSalesLine(L_OrderNodeList, ChannelCode, InterimSalesHeader, InterimSalesLine, OrderSource);

                            CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                            Commit();
                            UpdateOrderTracking(ChannelCode);
                            ConvertStatusToAcknowledge(ChannelCode);
                        end;
                    end;
                end;
            end
            else begin
                //Message('No Orders Received');
            end;
            //OrderData
        end
        else begin
            //Message(L_MessageElement.InnerText);
        end;
    end;


    local procedure InsertInInterimSalesHeader(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary; var PaymentDetails: Record "Channel Media" temporary; OrderSource: Text)
    var
        CustomerNodeList: XmlNodeList;
        BillingAddressNodeList: XmlNodeList;
        ShippingAddressNodeList: XmlNodeList;
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
    begin
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;

        //Customer Node List
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(CustomerNodeList);

        //if P_OrderDataNodeList.Get(5, GenericNode) then
        //if P_OrderDataNodeList.Get(7, GenericNode) then  //Live
        if P_OrderDataNodeList.Get(8, GenericNode) then  //UAT
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            CustomerNodeList := GenericElement.GetChildNodes();
        //Customer Node List

        Clear(GenericNode);
        Clear(GenericElement);
        if CustomerNodeList.Get(4, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Web Customer No." := CopyStr(GenericElement.InnerText(), 1, 20);
        end;

        if (OrderSource = 'API') or (OrderSource = 'NEXT') then begin
            TradePartner.Reset();
            if TradePartner.Get(ChannelCode) then begin
                InterimSalesHeader."Sell-to Customer No." := TradePartner."Customer No.";
            end;
        end
        else begin
            //Customer Number
            Clear(GenericNode);
            Clear(GenericElement);
            if CustomerNodeList.Get(4, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader."Sell-to Customer No." := CopyStr(GenericElement.InnerText(), 1, 20);
            end;
            //Customer Number
        end;

        //BillingAddressNodeList
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(BillingAddressNodeList);

        if P_OrderDataNodeList.Get(2, GenericNode) then
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            BillingAddressNodeList := GenericElement.GetChildNodes();
        //BillingAddressNodeList

        if OrderSource = 'Cloudfy' then begin
            //Billing Address
            //Address1
            Clear(GenericNode);
            Clear(GenericElement);
            Clear(BillingAddress1);
            if BillingAddressNodeList.Get(1, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader.Address := CopyStr(GenericElement.InnerText(), 1, 50);
                BillingAddress1 := CopyStr(GenericElement.InnerText(), 1, 50);
                if (BillingAddress1 = '') and (InterimSalesHeader.Address = '') then begin
                    Clear(GenericNode);
                    Clear(GenericElement);
                    if BillingAddressNodeList.Get(2, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        InterimSalesHeader.Address := CopyStr(GenericElement.InnerText(), 1, 50);
                    end;
                end;
            end;
            //Address1

            //Address2
            if (BillingAddress1 <> '') then begin
                Clear(GenericNode);
                Clear(GenericElement);
                if BillingAddressNodeList.Get(2, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    InterimSalesHeader."Address 2" := CopyStr(GenericElement.InnerText(), 1, 50);
                end;
            end;
            //Address2

            //City
            Clear(GenericNode);
            Clear(GenericElement);
            if BillingAddressNodeList.Get(4, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader.City := CopyStr(GenericElement.InnerText(), 1, 50);
            end;
            //City

            //Country (Which Field to Use)
            // Clear(GenericNode);
            // Clear(GenericElement);
            // if BillingAddressNodeList.Get(5, GenericNode) then begin
            //     GenericElement := GenericNode.AsXmlElement();
            //     InterimSalesHeader. := CopyStr(GenericElement.InnerText(), 1, 50);
            // end;
            //Country

            //County
            Clear(GenericNode);
            Clear(GenericElement);
            if BillingAddressNodeList.Get(6, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader."Bill-to County" := CopyStr(GenericElement.InnerText(), 1, 30);
            end;
            //County

            //FirstName and LastName
            Clear(GenericNode);
            Clear(GenericElement);
            Clear(FirstName);
            if BillingAddressNodeList.Get(7, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                FirstName := GenericElement.InnerText();
            end;
            Clear(GenericNode);
            Clear(GenericElement);
            Clear(LastName);
            if BillingAddressNodeList.Get(8, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                LastName := GenericElement.InnerText();
            end;
            Clear(FullName);
            FullName := FirstName + ' ' + LastName;
            InterimSalesHeader."Bill- to Name" := CopyStr(FullName, 1, 50);
            //FirstName and LastName

            //PostCode
            Clear(GenericNode);
            Clear(GenericElement);
            if BillingAddressNodeList.Get(9, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader."Post Code" := CopyStr(GenericElement.InnerText(), 1, 30);
            end;
            //PostCode

            //Email
            Clear(GenericNode);
            Clear(GenericElement);
            if BillingAddressNodeList.Get(11, GenericNode) then begin
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader."Buyer Email" := CopyStr(GenericElement.InnerText(), 1, 50);
            end;
            //Email

            //PhoneNumber (Which Field to Use)
            // Clear(GenericNode);
            // Clear(GenericElement);
            // if BillingAddressNodeList.Get(12, GenericNode) then begin
            //     GenericElement := GenericNode.AsXmlElement();
            //     InterimSalesHeader. := CopyStr(GenericElement.InnerText(), 1, 50);
            // end;
            //PhoneNumber
            //Billing Address
        end;

        //DeliveryDate
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(DeliveryDate);
        //if P_OrderDataNodeList.Get(8, GenericNode) then begin
        //if P_OrderDataNodeList.Get(10, GenericNode) then begin   //Live
        if P_OrderDataNodeList.Get(11, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            DeliveryDate := GenerateDate(GenericElement.InnerText());
            InterimSalesHeader."Shipment Date" := DeliveryDate;
        end;
        //DeliveryDate

        //Delivery Method
        Clear(GenericNode);
        Clear(GenericElement);
        //if P_OrderDataNodeList.Get(9, GenericNode) then begin
        //if P_OrderDataNodeList.Get(11, GenericNode) then begin  //Live
        if P_OrderDataNodeList.Get(12, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Web Shipment Method" := GenericElement.InnerText();
        end;
        //Delivery Method

        if (OrderSource = 'NEXT') or (OrderSource = 'Cloudfy') then begin
            //OrderCode
            Clear(GenericNode);
            Clear(GenericElement);
            Clear(OrderId);
            //if P_OrderDataNodeList.Get(12, GenericNode) then begin
            //if P_OrderDataNodeList.Get(14, GenericNode) then begin  //Live
            if P_OrderDataNodeList.Get(15, GenericNode) then begin  //UAT
                GenericElement := GenericNode.AsXmlElement();
                OrderId := GenericElement.InnerText();
                InterimSalesHeader."No." := CopyStr(GenericElement.InnerText(), 1, 20);
                InterimSalesHeader."Channel Order ID" := CopyStr(GenericElement.InnerText(), 1, 50);
                InterimSalesHeader."External Document No." := CopyStr(GenericElement.InnerText(), 1, 20);
            end;
            //OrderCode
        end
        else begin
            //PONumber
            Clear(GenericNode);
            Clear(GenericElement);
            Clear(OrderId);
            //if P_OrderDataNodeList.Get(19, GenericNode) then begin            
            //if P_OrderDataNodeList.Get(21, GenericNode) then begin  //Live
            if P_OrderDataNodeList.Get(22, GenericNode) then begin  //UAT
                GenericElement := GenericNode.AsXmlElement();
                OrderId := GenericElement.InnerText();
                InterimSalesHeader."No." := CopyStr(GenericElement.InnerText(), 1, 20);
                InterimSalesHeader."Channel Order ID" := CopyStr(GenericElement.InnerText(), 1, 50);
            end;
            Clear(GenericNode);
            Clear(GenericElement);
            //if P_OrderDataNodeList.Get(14, GenericNode) then begin  //Live
            if P_OrderDataNodeList.Get(15, GenericNode) then begin  //UAT
                GenericElement := GenericNode.AsXmlElement();
                InterimSalesHeader."External Document No." := CopyStr(GenericElement.InnerText(), 1, 20);
            end;
            //PONumber
        end;

        //OrderDate
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(OrderDate);
        //if P_OrderDataNodeList.Get(14, GenericNode) then begin
        //if P_OrderDataNodeList.Get(16, GenericNode) then begin  //Live
        if P_OrderDataNodeList.Get(17, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            OrderDate := GenerateDateTime(GenericElement.InnerText());
            InterimSalesHeader."Order Placed At" := OrderDate;
            InterimSalesHeader."Document Date" := DT2Date(OrderDate);
        end;
        //OrderDate

        //OrderStatus
        // Clear(GenericNode);
        // Clear(GenericElement);
        // Clear(OrderStatus);
        // if P_OrderDataNodeList.Get(17, GenericNode) then begin
        //     GenericElement := GenericNode.AsXmlElement();
        //     OrderStatus := GenericElement.InnerText();
        //     if OrderStatus = 'Processing' then begin
        //         InterimSalesHeader.status := InterimSalesHeader.status::Processing;
        //     end;
        // end;
        //OrderStatus

        //Discount Amount
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(DiscountAmount);
        //if P_OrderDataNodeList.Get(13, GenericNode) then begin  //Live
        if P_OrderDataNodeList.Get(14, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            Evaluate(DiscountAmount, GenericElement.InnerText());
            InterimSalesHeader."Order Discount Amount" := DiscountAmount;
        end;
        //Discount Amount

        //Total Price
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(OrderAmount);
        //if P_OrderDataNodeList.Get(28, GenericNode) then begin
        //if P_OrderDataNodeList.Get(31, GenericNode) then begin  //Live
        if P_OrderDataNodeList.Get(32, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            Evaluate(OrderAmount, GenericElement.InnerText());
            InterimSalesHeader."Order Amount" := OrderAmount;
        end;
        //Total Price

        //Payment Details++
        PaymentDetails.Init();
        PaymentDetails."Channel Code" := ChannelCode;
        PaymentDetails."Channel Order ID" := CopyStr(OrderId, 1, 50);
        PaymentDetails.Amount := OrderAmount;
        PaymentDetails."Transaction Date" := DT2Date(OrderDate);

        //Payment Mode (PaymentMode)
        Clear(GenericNode);
        Clear(GenericElement);
        //if P_OrderDataNodeList.Get(20, GenericNode) then begin
        //if P_OrderDataNodeList.Get(6, GenericNode) then begin
        //if P_OrderDataNodeList.Get(5, GenericNode) then begin  //Live
        if P_OrderDataNodeList.Get(6, GenericNode) then begin  //Live
            GenericElement := GenericNode.AsXmlElement();
            PaymentDetails."Payment Method" := CopyStr(GenericElement.InnerText(), 1, 50);
        end;
        //Payment Mode

        //Payment Status (PaymentStatus)
        Clear(GenericNode);
        Clear(GenericElement);
        //if P_OrderDataNodeList.Get(21, GenericNode) then begin
        //if P_OrderDataNodeList.Get(23, GenericNode) then begin  //Live
        if P_OrderDataNodeList.Get(24, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            PaymentDetails."Payment Status" := CopyStr(GenericElement.InnerText(), 1, 20);
        end;
        //Payment Status

        //Transaction Code (TransactionId)
        Clear(GenericNode);
        Clear(GenericElement);
        //if P_OrderDataNodeList.Get(34, GenericNode) then begin
        if P_OrderDataNodeList.Get(33, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            PaymentDetails."Transaction ID" := CopyStr(GenericElement.InnerText(), 1, 50);
        end;
        //Transaction Code

        PaymentDetails.Insert();
        //Payment Details--

        //ShippingAddress++
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(ShippingAddressNodeList);

        //if P_OrderDataNodeList.Get(24, GenericNode) then
        //if P_OrderDataNodeList.Get(27, GenericNode) then  //Live
        if P_OrderDataNodeList.Get(28, GenericNode) then  //UAT
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            ShippingAddressNodeList := GenericElement.GetChildNodes();

        //Address1
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(ShippingAddress1);
        Clear(FullShipToAddress);

        if ShippingAddressNodeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            FullShipToAddress := FullShipToAddress + CopyStr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(2, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            FullShipToAddress := FullShipToAddress + ' ' + CopyStr(GenericElement.InnerText(), 1, 50);
        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(3, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            FullShipToAddress := FullShipToAddress + ' ' + CopyStr(GenericElement.InnerText(), 1, 50);
        end;

        FullShipToAddress := FullShipToAddress.Trim();
        InterimSalesHeader."Ship-to Address" := CopyStr(FullShipToAddress, 1, 35);
        InterimSalesHeader."Ship-to Address 2" := '';
        if StrLen(FullShipToAddress) > 35 then begin
            InterimSalesHeader."Ship-to Address 2" := CopyStr(FullShipToAddress, 36, 70);
        end;

        /* if ShippingAddressNodeList.Get(1, GenericNode) then begin
             GenericElement := GenericNode.AsXmlElement();
             InterimSalesHeader."Ship-to Address" := CopyStr(GenericElement.InnerText(), 1, 50);
             ShippingAddress1 := CopyStr(GenericElement.InnerText(), 1, 50);
             if (ShippingAddress1 = '') and (InterimSalesHeader."Ship-to Address" = '') then begin
                 Clear(GenericNode);
                 Clear(GenericElement);
                 if ShippingAddressNodeList.Get(2, GenericNode) then begin
                     GenericElement := GenericNode.AsXmlElement();
                     InterimSalesHeader."Ship-to Address" := CopyStr(GenericElement.InnerText(), 1, 50);
                 end;
             end;
         end;
         //Address1

         //Address2
         InterimSalesHeader."Ship-to Address 2" := '';
         if ShippingAddress1 <> '' then begin
             Clear(GenericNode);
             Clear(GenericElement);
             if ShippingAddressNodeList.Get(2, GenericNode) then begin
                 GenericElement := GenericNode.AsXmlElement();
                 InterimSalesHeader."Ship-to Address 2" := CopyStr(GenericElement.InnerText(), 1, 50);
             end;
         end;*/
        //Address2

        //City
        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(4, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to City" := CopyStr(GenericElement.InnerText(), 1, 30);
        end;
        //City

        //Country
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(CountryCode);
        if ShippingAddressNodeList.Get(5, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            CountryCode := CopyStr(GenericElement.InnerText(), 1, 50);
            Rec_CountryRegion.Reset();
            Rec_CountryRegion.SetFilter(Name, CountryCode);
            if Rec_CountryRegion.FindFirst() then begin
                InterimSalesHeader."Ship-to Country/Region Code" := Rec_CountryRegion.Code;
            end;
        end;
        //Country

        //County
        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(6, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to County" := CopyStr(GenericElement.InnerText(), 1, 30);
        end;
        //County

        //FirstName and LastName
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(FirstName);
        if ShippingAddressNodeList.Get(7, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            FirstName := GenericElement.InnerText();
        end;
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(LastName);
        if ShippingAddressNodeList.Get(8, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            LastName := GenericElement.InnerText();
        end;
        Clear(FullName);
        FullName := FirstName + ' ' + LastName;
        InterimSalesHeader."Ship-to Name" := CopyStr(FullName, 1, 50);
        //FirstName and LastName

        //PostCode
        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(9, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Post Code" := CopyStr(GenericElement.InnerText(), 1, 20);
        end;
        //PostCode

        //CompanyName
        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(11, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to CompanyName" := CopyStr(GenericElement.InnerText(), 1, 50);
        end;
        //CompanyName

        //Email
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(InterimSalesHeader."Ship-to Email");
        // if ShippingAddressNodeList.Get(12, GenericNode) then begin
        //     GenericElement := GenericNode.AsXmlElement();
        //     InterimSalesHeader."Ship-to Email" := CopyStr(GenericElement.InnerText(), 1, 80);
        // end;
        if BillingAddressNodeList.Get(11, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Email" := CopyStr(GenericElement.InnerText(), 1, 50);
        end;
        //Email

        //PhoneNumber
        Clear(GenericNode);
        Clear(GenericElement);
        if ShippingAddressNodeList.Get(14, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Phone" := CopyStr(GenericElement.InnerText(), 1, 20);
        end;
        //PhoneNumber
        //ShippingAddress--

        //Shipping Price
        Clear(GenericNode);
        Clear(GenericElement);
        Clear(L_ShippingPrice);
        //if P_OrderDataNodeList.Get(28, GenericNode) then begin //Live
        if P_OrderDataNodeList.Get(29, GenericNode) then begin  //UAT
            GenericElement := GenericNode.AsXmlElement();
            Evaluate(L_ShippingPrice, GenericElement.InnerText());
        end;
        //Shipping Price

        if OrderSource = 'API' then begin
            ShippingRule.Reset();
            ShippingRule.SetRange("Channel Code", ChannelCode);
            ShippingRule.SetRange("Shipping Charge", L_ShippingPrice);
            if ShippingRule.FindFirst() then begin
                InterimSalesHeader."Shipping Agent Service Code" := ShippingRule."Shipping Agent Service";
                InterimSalesHeader."Shipping Agent Code" := ShippingRule."Shipping Agent";
            end;
        end
        else begin
            ShippingRule.Reset();
            ShippingRule.SetRange("Channel Code", ChannelCode);
            ShippingRule.SetRange("Web Shipment Method", InterimSalesHeader."Web Shipment Method");
            if ShippingRule.FindFirst() then begin
                InterimSalesHeader."Shipping Agent Service Code" := ShippingRule."Shipping Agent Service";
                InterimSalesHeader."Shipping Agent Code" := ShippingRule."Shipping Agent";
            end;
        end;

        InterimSalesHeader.Insert();
    end;


    local procedure InsertInInterimSalesLine(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary; var InterimSalesLine: Record "Interim Sales Line" temporary; OrderSource: Text)
    var
        OrderItemNodeList: XmlNodeList;
        OrderItemList: XmlNodeList;
        j: Integer;
        UnitPrice: Decimal;
        Quantity: Decimal;
        Amount: Decimal;
        ShippingPrice: Decimal;
        DeliveryDate: Date;
    begin
        //OrderItem
        Clear(GenericNode);
        Clear(GenericElement);
        //if P_OrderDataNodeList.Get(15, GenericNode) then
        //if P_OrderDataNodeList.Get(17, GenericNode) then  //Live
        if P_OrderDataNodeList.Get(18, GenericNode) then  //UAT
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then
            OrderItemNodeList := GenericElement.GetChildNodes();

        if OrderItemNodeList.Count > 0 then begin
            for j := 1 to OrderItemNodeList.Count do begin
                InterimSalesLine.Init;
                InterimSalesLine."Line No." := j;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";
                InterimSalesLine.Weight := 1;
                InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";

                Clear(GenericNode);
                Clear(GenericElement);
                if OrderItemNodeList.Get(j, GenericNode) then
                    GenericElement := GenericNode.AsXmlElement();
                if not GenericElement.IsEmpty() and GenericElement.HasElements() then begin
                    OrderItemList := GenericElement.GetChildNodes();
                end;

                //Delivery Date
                if (OrderSource = 'Cloudfy') and (ChannelCode = 'CLOUDFYB2B') then begin
                    Clear(GenericNode);
                    Clear(GenericElement);
                    if OrderItemList.Get(3, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        DeliveryDate := GenerateDate(GenericElement.InnerText());
                        InterimSalesLine."Shipment Date" := DeliveryDate;
                    end;
                end;
                //Delivery Date

                //Product Price (Unit Price)
                Clear(GenericNode);
                Clear(GenericElement);
                Clear(UnitPrice);
                if OrderItemList.Get(6, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    Evaluate(UnitPrice, GenericElement.InnerText);
                    InterimSalesLine."Unit Price" := UnitPrice;
                end;
                //Product Price

                //Quantity
                Clear(GenericNode);
                Clear(GenericElement);
                Clear(Quantity);
                if OrderItemList.Get(7, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    Evaluate(Quantity, GenericElement.InnerText);
                    InterimSalesLine.Quantity := Quantity;
                end;
                //Quantity

                //SKU
                Clear(GenericNode);
                Clear(GenericElement);
                if OrderItemList.Get(8, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    InterimSalesLine."Channel SKU" := CopyStr(GenericElement.InnerText(), 1, 50);
                end;
                //SKU

                //Total Price
                Clear(GenericNode);
                Clear(GenericElement);
                Clear(Amount);
                if OrderItemList.Get(9, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    Evaluate(Amount, GenericElement.InnerText);
                    InterimSalesLine.Amount := Amount;
                end;
                //Total Price

                //Product Name(Z_ProductName)
                Clear(GenericNode);
                Clear(GenericElement);
                if OrderItemList.Get(16, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    InterimSalesLine.Description := CopyStr(GenericElement.InnerText(), 1, 100);
                end;
                //Product Name

                if j = 1 then begin
                    //Shipping Price
                    Clear(GenericNode);
                    Clear(GenericElement);
                    Clear(ShippingPrice);
                    //if P_OrderDataNodeList.Get(25, GenericNode) then begin
                    //if P_OrderDataNodeList.Get(28, GenericNode) then begin  //Live
                    if P_OrderDataNodeList.Get(29, GenericNode) then begin  //UAT
                        GenericElement := GenericNode.AsXmlElement();
                        Evaluate(ShippingPrice, GenericElement.InnerText());
                        if ShippingPrice > 0 then begin
                            InterimSalesLine."Shipping Price" := ShippingPrice;
                        end;
                    end;
                    //Shipping Price
                end;

                InterimSalesLine.Insert();
            end;
        end;
        //OrderItem
    end;


    local procedure ConvertStatusToAcknowledge(ChannelCode: Code[10])
    var
        InterimSalesHeader: Record "Interim Sales Header";
    begin
        InterimSalesHeader.Reset();
        InterimSalesHeader.SetRange("Trade Partner Code", ChannelCode);
        InterimSalesHeader.SetFilter("FullFillment Status", '%1', InterimSalesHeader."FullFillment Status"::"Not Acknowledged");
        if InterimSalesHeader.FindSet() then begin
            repeat
                InterimSalesHeader."FullFillment Status" := InterimSalesHeader."FullFillment Status"::Acknowledged;
                InterimSalesHeader.Modify(true);
            until InterimSalesHeader.Next() = 0;
        end;
    end;


    local procedure UpdateOrderTracking(ChannelCode: Code[10])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        GenerateCredentials(ChannelCode);

        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Trade Partner Code", ChannelCode);
        L_InterimSalesHeader.SetFilter("FullFillment Status", '%1', L_InterimSalesHeader."FullFillment Status"::"Not Acknowledged");
        //L_InterimSalesHeader.SetFilter("No.", '%1|%2', 'WEB4223', 'WEB4222');
        if L_InterimSalesHeader.FindSet() then begin
            repeat
                RequestBody := '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><UpdateOrderTracking xmlns="http://tempuri.org/Navision">' +
                        '<Token_Id>' + TokenId + '</Token_Id><Site_Id>' + SiteId + '</Site_Id><OrderId>' + L_InterimSalesHeader."External Document No." +
                        '</OrderId><TrackingDetails></TrackingDetails><OrderStatus>Warehouse</OrderStatus></UpdateOrderTracking></Body></Envelope>';


                RequestMessage.SetRequestUri(ServiceURL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                Headers.Add('SOAPAction', 'http://tempuri.org/Navision/INavision/UpdateOrderTracking');
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);
                ResponseMessage.Content().ReadAs(Response);
                //Message(Response);

                Clear(RequestBody);
                Clear(RequestMessage);
                Clear(ResponseMessage);
                Clear(Content);
                Clear(Headers);
                Clear(Response);
                Clear(Client);
            until L_InterimSalesHeader.Next() = 0;
        end;
    end;


    local procedure UpdateOrderStatusToComplete(ChannelCode: Code[10])
    var
        RequestBody: Text;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Response: Text;
        URL: Text;
        L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin
        GenerateCredentials(ChannelCode);

        L_HandledInterimSalesHeader.Reset();
        L_HandledInterimSalesHeader.SetRange("Trade Partner Code", ChannelCode);
        if ChannelCode = 'CLOUDFYNXT' then
            L_HandledInterimSalesHeader.SetFilter(status, '%1', L_HandledInterimSalesHeader.status::Processing)
        else
            L_HandledInterimSalesHeader.SetFilter(status, '%1', L_HandledInterimSalesHeader.status::Dispatched);
        if L_HandledInterimSalesHeader.FindSet() then begin
            repeat
                RequestBody := '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><UpdateOrderTracking xmlns="http://tempuri.org/Navision">' +
                        '<Token_Id>' + TokenId + '</Token_Id><Site_Id>' + SiteId + '</Site_Id><OrderId>' + L_HandledInterimSalesHeader."External Document No." +
                        '</OrderId><TrackingDetails></TrackingDetails><OrderStatus>Complete</OrderStatus></UpdateOrderTracking></Body></Envelope>';


                RequestMessage.SetRequestUri(ServiceURL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                Headers.Add('SOAPAction', 'http://tempuri.org/Navision/INavision/UpdateOrderTracking');
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);
                ResponseMessage.Content().ReadAs(Response);
                //Message(Response);

                Clear(RequestBody);
                Clear(RequestMessage);
                Clear(ResponseMessage);
                Clear(Content);
                Clear(Headers);
                Clear(Response);
                Clear(Client);
            until L_HandledInterimSalesHeader.Next() = 0;
        end;
    end;


    local procedure GenerateDate(Orderdate: Text): Date
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


    local procedure GenerateDateTime(createDate: Text): DateTime
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        TimeType: Time;
        Convertdate: DateTime;
    begin
        if createDate <> '' then begin
            evaluate(Day, copystr(createDate, 9, 2));
            evaluate(Month, copystr(createDate, 6, 2));
            evaluate(Year, copystr(createDate, 1, 4));
            evaluate(TimeType, copystr(createDate, 12, 8));
            Convertdate := createdatetime(DMY2DATE(Day, Month, Year), TimeType);
        End;
        exit(Convertdate);
    end;
}