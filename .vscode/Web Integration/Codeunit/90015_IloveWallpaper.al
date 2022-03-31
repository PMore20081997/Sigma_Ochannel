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
                    MESSAGE('Order Sync Completed...');
                End;
            SyncItemLabel:
                Begin
                    Getitems(StartParameter);
                    MESSAGE('items Sync Completed...');
                End;
            UpdateInventoryLabel:
                begin
                    UpdateProductStok(StartParameter);
                    MESSAGE('Update Inventory  Sucessfully...');
                end;

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
        TradePartner: Record "Trade Partner";
        SoapAction: text;

    begin

        GetCredentials(ChannelCode);
        //Live Request Body++
        //RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + SoapActionUrl + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetProducts><product_references SOAP-ENC:arrayType="xsd:string[2]" xsi:type="SOAP-ENC:Array"><item xsi:type="xsd:string">REF1</item></product_references><get_data xsi:nil="true"/><limit xsi:type="xsd:int">' + ProductCount + '</limit><offset xsi:type="xsd:int">' + ProductPageCount + '</offset><file_type xsi:type="xsd:string">xml</file_type></ns1:GetProducts></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + SoapActionUrl + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body> <ns1:GetProducts><product_references xsi:nil="true"/><get_data xsi:nil="true"/><file_type xsi:type="xsd:string">xml</file_type><limit xsi:type="xsd:int">' + ProductCount + '</limit><offset xsi:type="xsd:int">' + ProductPageCount + '</offset></ns1:GetProducts></soapenv:Body></soapenv:Envelope>';

        // URL := 'https://demo.visualsoft.co.uk/api/soap/service/5';
        URL := ServiceURL;

        SoapAction := SoapActionUrl + '#GetProducts';
        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        //Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service#GetProducts');
        Headers.Add('soapAction', SoapAction);
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        if ResponseMessage.HttpStatusCode = 200 then begin
            InsertProductXMLResponse(Response, ChannelCode);


            TradePartner.Reset();
            TradePartner.SetRange(Code, ChannelCode);
            if TradePartner.FindFirst() then begin
                TradePartner."Last Product Sync" := CurrentDateTime;
                TradePartner.Modify();
            end;
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
            //EndDate := Format(Today, 0, '20<Year>-<Month,2>-<Day,2>');
            EndDate := Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');
            StartDate := Format(TradePartner."Last Order Sync", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');
            // StartDate := Format(TradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2>');
            ProductCount := TradePartner."API Attribute";
            ProductPageCount := TradePartner."API Endpoint";
            SoapActionUrl := TradePartner.MerchantId;
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
        GetCredentials(ChannelCode);
        //Live Request Body++
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="' + ServiceURL + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username><Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetOrdersByDateRange><from_date xsi:type="xsd:date">' + StartDate + '</from_date><to_date xsi:type="xsd:date">' + EndDate + '</to_date><successful_only xsi:nil="true"/></ns1:GetOrdersByDateRange></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--

        //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
        //URL := ServiceURL;
        URL := ServiceURL;

        SoapAction := SoapActionUrl + '/6#GetOrdersByDateRange';
        RequestMessage.SetRequestUri(URL);
        RequestMessage.Method('POST');
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml;charset=utf-8');
        // Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service/5#GetOrdersByDateRange');
        Headers.Add('soapAction', SoapAction);
        RequestMessage.Content := Content;
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content().ReadAs(Response);
        if ResponseMessage.HttpStatusCode = 200 then begin
            InsertXMLResponse(Response, ChannelCode);


            TradePartner.Reset();
            TradePartner.SetRange(Code, ChannelCode);
            if TradePartner.FindFirst() then begin
                TradePartner."Last Order Sync" := CurrentDateTime;
                TradePartner.Modify();
            end;
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
                InterimSalesHeader.DeleteAll();
                InterimSalesLine.DeleteAll();

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

                if SubProductXMLNodeList1.Get(8, GenericNode) then begin
                    GenericElement := GenericNode.AsXmlElement();
                    ChannelItemListing."ASIN No" := GenericElement.InnerText;

                end;

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

    procedure InsertIntrimSalesHeader(P_OrderDataNodeList: XmlNodeList; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        TradePartner1: Record "Trade Partner";
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
        LeghtString: Text;
        TotalDiscountIn: Decimal;


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
        if CustomerNodeList.Get(26, GenericNode) then begin
            GenericElement := GenericNode.AsXmlElement();
            InterimSalesHeader."Ship-to Country/Region Code" := Copystr(GenericElement.InnerText(), 1, 10);
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
        GLAccount: Code[20];
        TradePartner1: Record "Trade Partner";
        DiscountExtext: Text;
        DiscountEx: Decimal;
        DiscountExFinal: Text;
        InterimSalesLine1: Record "Interim Sales Line";
        CountLine: Integer;
        G_CountLine: Integer;
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

                    InterimSalesLine.Init;
                    InterimSalesLine."Line No." := j;
                    InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                    InterimSalesLine.Type := InterimSalesLine.type::Item;
                    InterimSalesLine."Document No" := InterimSalesHeader."No.";
                    InterimSalesLine.Weight := 1;
                    InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";
                    Clear(G_CountLine);
                    if CountLine > 1 then
                        G_CountLine := j;

                    if OrderItemNodeList.get(j, itemlistNode) then
                        itemlistelement := itemlistNode.AsXmlElement();
                    if not itemlistelement.IsEmpty() and itemlistelement.HasElements() then
                        ItemlistXLMlist := itemlistelement.GetChildNodes();

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(5, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        InterimSalesLine."No." := GenericElement.InnerText;
                        InterimSalesLine."Channel SKU" := GenericElement.InnerText;
                    end;

                    // Clear(GenericNode);
                    // Clear(GenericElement);
                    // if ItemlistXLMlist.Get(2, GenericNode) then begin
                    //     GenericElement := GenericNode.AsXmlElement();
                    //     InterimSalesLine."No." := GenericElement.InnerText;
                    // end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(14, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        Evaluate(QTY, GenericElement.InnerText);
                        InterimSalesLine.Quantity := Qty;
                    end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(15, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        Evaluate(UnitPrice, GenericElement.InnerText);
                        InterimSalesLine."Unit Price" := UnitPrice;
                    end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(11, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        InterimSalesLine.Description := GenericElement.InnerText();
                    end;

                    Clear(GenericNode);
                    Clear(GenericElement);
                    if ItemlistXLMlist.Get(19, GenericNode) then begin
                        GenericElement := GenericNode.AsXmlElement();
                        DiscountExtext := GenericElement.InnerText;
                        if (DiscountExtext <> '') and (DiscountExtext <> '0') then begin
                            DiscountExFinal := DiscountExtext.Remove(1, 1);
                            Evaluate(DiscountEx, DiscountExFinal);
                            InterimSalesLine.Discount := DiscountEx;
                        end else begin
                            Evaluate(DiscountEx, DiscountExtext);
                            InterimSalesLine.Discount := DiscountEx;
                        end;
                    end;
                    if j = 1 then begin
                        if G_ShippingPrice > 0 then
                            InterimSalesLine."Shipping Price" := G_ShippingPrice;
                    end;
                    //Shipping Price

                    InterimSalesLine.Insert();
                end;
            end;

            //Shipping Price


        End;
    end;
    // IF G_ShippingPrice > 0 THEN BEGIN
    //     LineNo := 1000;
    //     InterimSalesLine1.RESET;
    //     InterimSalesLine1.INIT;
    //     InterimSalesLine1.Type := InterimSalesLine1.Type::"G/L Account";

    //     InterimSalesLine1."Document No" := InterimSalesHeader."No.";
    //     InterimSalesLine.SETRANGE("Document No", InterimSalesHeader."No."); //Pass NAV Created DocumentNo

    //     IF InterimSalesLine.FINDLAST THEN
    //         LineNo := LineNo + InterimSalesLine."Line No.";
    //     InterimSalesLine1."Line No." := LineNo;
    //     InterimSalesLine1."Document Type" := InterimSalesLine1."Document Type"::Order;
    //     InterimSalesLine1.Amount := G_ShippingPrice;
    //     InterimSalesLine1."Unit Price" := G_ShippingPrice;
    //     InterimSalesLine1."Shipping Price" := G_ShippingPrice;

    //     InterimSalesLine1.Quantity := 1;

    //     If TradePartner1.FindFirst then begin
    //         GLAccount := TradePartner1."Shipping G/L No.";

    //     end;
    //     InterimSalesLine1.VALIDATE("No.", GLAccount);





    //     InterimSalesLine1.VALIDATE("Trade Partner Code", InterimSalesHeader."Trade Partner Code");
    //     InterimSalesLine1.VALIDATE("Sell-to Customer No.", InterimSalesHeader."Sell-to Customer No.");





    //     InterimSalesLine1.Description := 'Shipping Charge';
    //     InterimSalesLine1.INSERT(TRUE);

    // END; //For Shiping Charge Line: End
    // end;

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

        setInventory(ChannelCode);
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETFILTER("Inventory Synced", '%1', FALSE);
        if ChannelItemListing.FindFirst() then begin

            repeat

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
                    ItemRec.CalcFields(Inventory);
                    Stock := format(ItemRec.Inventory);
                    ChannelSKU := ChannelItemListing."Channel SKU";
                end;


                GetCredentials(ChannelCode);
                //Live Request Body++
                Clear(RequestBody);
                RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="' + SoapActionUrl + '"><soapenv:Header><VSAuth><ClientID>' + MarketplaceId + '</ClientID><Username>' + AccessKeyId + '</Username> <Password>' + SecretAccessKey + '</Password></VSAuth></soapenv:Header><soapenv:Body><ser:SetStock><product_reference>' + ChannelSKU + '</product_reference><stock_level>' + Stock + '</stock_level></ser:SetStock></soapenv:Body></soapenv:Envelope>';
                //Live Request Body--

                //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
                //URL := ServiceURL;

                SoapAction := SoapActionUrl + '#SetStock';

                URL := ServiceURL;
                Clear(RequestMessage);
                RequestMessage.SetRequestUri(URL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Clear();
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                //Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service/5#GetOrdersByDateRange');
                Headers.Add('soapAction', SoapAction);
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);
                ResponseMessage.Content().ReadAs(Response);
                if ResponseMessage.HttpStatusCode = 200 then begin
                    ChannelItemListing."Inventory Synced" := TRUE;
                    ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                    ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    ChannelItemListing.Remarks := 'Inventory updated successfully';

                end;
                ChannelItemListing.Modify();
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

    procedure UpdateOrderStatus(Channelcode: Code[20])
    var
    begin

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

                //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
                //URL := ServiceURL;
                URL := ServiceURL;
                Clear(RequestMessage);
                RequestMessage.SetRequestUri(URL);
                RequestMessage.Method('POST');
                Content.WriteFrom(RequestBody);
                Content.GetHeaders(Headers);
                Headers.Remove('Content-Type');
                Headers.Clear();
                Headers.Add('Content-Type', 'text/xml;charset=utf-8');
                Headers.Add('soapAction', 'https://demo.visualsoft.co.uk/api/soap/service/5#GetOrdersByDateRange');
                RequestMessage.Content := Content;
                Client.Send(RequestMessage, ResponseMessage);
                ResponseMessage.Content().ReadAs(Response);
                ResponseMessage.Content.ReadAs(responseText);
                if ResponseMessage.HttpStatusCode = 200 then begin
                    //if (HttpResponse.HttpStatusCode = 200) then begin
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

    var
        LineNo: Integer;
        StartParameter: Text;
        SoapAction: text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        SyncItemLabel: Label 'SyncItem';
        UpdateInventoryLabel: label 'UpdateInventory';
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
        ProductCount: text;
        ProductPageCount: text;

        SoapActionUrl: text;

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
        SubProductXMLNodeList2: XmlNodeList;
        SubProductXMLNode2: XmlNode;
        SubProductXMLElement2: XmlElement;
}