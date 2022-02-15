codeunit 90015 IloveWallpaper
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
                    GetOrders(StartParameter);
                End;
            SyncItemLabel:
                Begin
                    Getitems(StartParameter);
                End;

        end;
    End;

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
    begin

        GetCredentials(ChannelCode);
        //Live Request Body++
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="https://demo.visualsoft.co.uk/api/soap/service"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetProducts><product_references SOAP-ENC:arrayType="xsd:string[2]" xsi:type="SOAP-ENC:Array"><item xsi:type="xsd:string">REF1</item></product_references><get_data xsi:nil="true"/><limit xsi:type="xsd:int">10</limit><offset xsi:type="xsd:int">10</offset><file_type xsi:type="xsd:string">xml</file_type></ns1:GetProducts></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--

        //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
        //URL := ServiceURL;
        // URL := 'https://demo.visualsoft.co.uk/api/soap/service/5';
        URL := ServiceURL;


        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service#GetProducts');
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        if ResponseMessage.HttpStatusCode = 200 then begin
            InsertProductXMLResponse(Response, ChannelCode);
        end;
    end;


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
            StartDate := Format(Today, 0, '20<Year>-<Month,2>-<Day,2>');
            EndDate := Format(TradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2>');
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
    begin
        GetCredentials(ChannelCode);
        //Live Request Body++
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="https://demo.visualsoft.co.uk/api/soap/service/5"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetOrdersByDateRange><from_date xsi:type="xsd:date">' + EndDate + '</from_date><to_date xsi:type="xsd:date">' + StartDate + '</to_date><successful_only xsi:nil="true"/></ns1:GetOrdersByDateRange></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--

        //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
        //URL := ServiceURL;
        URL := ServiceURL;


        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service/5#GetOrdersByDateRange');
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
                if WebOrderXLMList.get(j, WebOrderXLMNode2) then
                    WebOrderXLMElement1 := WebOrderXLMNode2.AsXmlElement();
                L_OrderNodeList := WebOrderXLMElement1.GetChildNodes();
                if L_OrderNodeList.Get(j, WebOrderXLMNode3) then
                    WebOrderXLMElement3 := WebOrderXLMNode3.AsXmlElement();
                if not WebOrderXLMElement3.IsEmpty() and WebOrderXLMElement3.HasElements() then
                    WebOrderXLMList3 := WebOrderXLMElement3.GetChildNodes();

                InsertIntrimSalesHeader(WebOrderXLMList3, ChannelCode, InterimSalesHeader);

                InsertInInterimSalesLine(WebOrderXLMList3, ChannelCode, InterimSalesHeader, InterimSalesLine);

                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

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

    local procedure InsertProductXMLResponse(P_Response: Text; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
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
                //ItemsInsertCode

                ChannelItemListing.RESET;
                ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                ChannelItemListing.SETRANGE("Channel SKU", Generictext);
                IF ChannelItemListing.FINDFIRST THEN BEGIN
                    UpdateProduct(WebOrderXLMList3, FALSE, ChannelItemListing, ChannelCode);
                END
                ELSE BEGIN
                    CreateProduct(WebOrderXLMList3, true, ChannelCode);
                END;
                //ItemsInsertCode

                //  InsertIntrimSalesHeader(WebOrderXLMList3, ChannelCode, InterimSalesHeader);

                //  InsertInInterimSalesLine(WebOrderXLMList3, ChannelCode, InterimSalesHeader, InterimSalesLine);

                // CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

                // if WebOrderXLMList3.Get(2, WebOrderXLMNode4) then
                //     WebOrderXLMElement4 := WebOrderXLMNode4.AsXmlElement();
                // WebOrderXLMList4 := WebOrderXLMElement4.GetChildNodes();
                // Clear(GenericElement);
                // Clear(GenericNode);
                // if WebOrderXLMList4.get(1, GenericNode) then begin/
                //     GenericElement := GenericNode.AsXmlElement();
                //     Generictext := GenericElement.InnerText;
                // end;
            end;
        end;
    end;

    local procedure UpdateProduct(P_ItemDataNodeList: XmlNodeList; bool: Boolean; ChannelItemListing: Record "Channel Item Listing"; ChannelCode: Code[10])
    var
        ItemName: Text;
        ItemDescription: Text;
        //ChannelItemListing: Record "Channel Item Listing";
        unitPrice: Decimal;
        ChannelInvquantity: Decimal;
        ChannelInvOldquantity: Decimal;
        InvItemId: BigInteger;
        ITEM: Record 27;
        NetWeight: Decimal;
        ItemSKU: Text;
    begin

        CLEAR(ChannelItemListing);
        ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
        //
        // need to added fields
        //
        ChannelItemListing.VALIDATE("Price Synced", TRUE);
        ChannelItemListing.VALIDATE("Inventory Synced", TRUE);

        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelItemListing."Channel SKU" := GenericElement.InnerText;

        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(2, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelItemListing."Channel Title" := GenericElement.InnerText;
        end;


        ChannelItemListing.VALIDATE("Price Synced", TRUE);
        ChannelItemListing.VALIDATE("Inventory Synced", TRUE);
        //
        //need to added fields here 
        //

        ChannelItemListing.MODIFY(TRUE);

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
    begin

        CLEAR(ChannelItemListing);
        ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
        //
        // need to added fields
        //
        ChannelItemListing.VALIDATE("Price Synced", TRUE);
        ChannelItemListing.VALIDATE("Inventory Synced", TRUE);

        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(1, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelItemListing."Channel SKU" := GenericElement.InnerText;

        end;

        Clear(GenericNode);
        Clear(GenericElement);
        if P_ItemDataNodeList.Get(2, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            ChannelItemListing."Channel Title" := GenericElement.InnerText;
        end;


        ChannelItemListing.INSERT(TRUE);

    end;

    procedure InsertIntrimSalesHeader(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        CustomerNodeList: XmlNodeList;
        BillingAddressNodeList: XmlNodeList;
        ShippingAddressNodeList: XmlNodeList;
        OrderNodeList: XmlNodeList;
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
        if CustomerNodeList.Get(4, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Bill- to Name" := Copystr(GenericElement.InnerText(), 1, 50);
        end;

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
            InterimSalesHeader."Post Code" := Copystr(GenericElement.InnerText(), 1, 30);
        end;


        //Customer Node List

        InterimSalesHeader.Insert();

    end;

    local procedure InsertInInterimSalesLine(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        OrderItemNodeList: XmlNodeList;
        OrderItemList: XmlNodeList;
        itemlistNode: XmlNode;
        ItemlistXLMlist: XmlNodeList;
        itemlistelement: XmlElement;
        j: Integer;
        UnitPrice: Decimal;
        Quantity: Decimal;
        Amount: Decimal;
        ShippingPrice: Decimal;
        LineCount: Integer;
        Qty: Decimal;
        Unitprices: Decimal;
    begin

        //OrderItem
        Clear(GenericNode);
        Clear(GenericElement);

        if P_OrderDataNodeList.Get(3, GenericNode) then
            GenericElement := GenericNode.AsXmlElement();
        if not GenericElement.IsEmpty() and GenericElement.HasElements() then begin
            OrderItemNodeList := GenericElement.GetChildNodes();


            if OrderItemNodeList.get(1, itemlistNode) then
                itemlistelement := itemlistNode.AsXmlElement();
            if not itemlistelement.IsEmpty() and itemlistelement.HasElements() then
                ItemlistXLMlist := itemlistelement.GetChildNodes();


            if ItemlistXLMlist.Count > 0 then begin
                for j := 1 to ItemlistXLMlist.Count do begin
                    InterimSalesLine.Init;
                    InterimSalesLine."Line No." := j;
                    InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                    InterimSalesLine.Type := InterimSalesLine.type::Item;
                    InterimSalesLine."Document No" := InterimSalesHeader."No.";
                    InterimSalesLine.Weight := 1;
                    InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";


                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(2, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        InterimSalesLine."No." := GenericElement.InnerText;
                    end;

                    // Clear(GenericNode);
                    // Clear(GenericElement);
                    // if ItemlistXLMlist.Get(2, GenericNode) then begin
                    //     GenericElement := GenericNode.AsXmlElement();
                    //     InterimSalesLine."No." := GenericElement.InnerText;
                    // end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(13, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        Evaluate(QTY, GenericElement.InnerText);
                        InterimSalesLine.Quantity := Qty;
                    end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(14, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        Evaluate(UnitPrice, GenericElement.InnerText);
                        InterimSalesLine."Unit Price" := UnitPrice;
                    end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(7, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        InterimSalesLine.Description := GenericElement.InnerText;
                    end;

                End;
                InterimSalesLine.Insert();
            End;
        end;
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


    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        SyncItemLabel: Label 'SyncItem';
        TokenId: Text;
        SiteId: Text;
        OrderStatus: Text;
        StartDate: Text;
        AccessKeyId: Text;
        MarketplaceId: Text;
        SecretAccessKey: Text;
        StartDateTime: DateTime;
        EndDate: Text;
        ServiceURL: Text;

        GenericNode: XmlNode;
        GenericElement: XmlElement;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
}