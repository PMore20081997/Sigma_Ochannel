codeunit 90015 IloveWallpaper
{
    trigger OnRun()
    begin

    end;

    procedure GetCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            TokenId := TradePartner.AccessKeyId;
            SiteId := TradePartner.MarketplaceId;
            ServiceURL := TradePartner."Sevice/API URL";
        end;
        GetOrders(ChannelCode);

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
        RequestBody := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="https://demo.visualsoft.co.uk/api/soap/service/5"><soapenv:Header><VSAuth><ClientID>DemoSite</ClientID><Username>DemoSiteUser</Username><Password>zeC9xPemee3h</Password></VSAuth></soapenv:Header><soapenv:Body><ns1:GetOrdersByDateRange><from_date xsi:type="xsd:date">2022-01-01</from_date><to_date xsi:type="xsd:date">2022-02-04</to_date><successful_only xsi:nil="true"/></ns1:GetOrdersByDateRange></soapenv:Body></soapenv:Envelope>';
        //Live Request Body--

        //URL := 'https://eufy1.cloudfyuat.com/navisionservices/Services/Navision.svc';
        //URL := ServiceURL;
        URL := 'https://demo.visualsoft.co.uk/api/soap/service/5';


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

                    // Clear(GenericNode);
                    // Clear(GenericElement);
                    // //if L_OrderNodeList.Get(16, GenericNode) then begin
                    // //if L_OrderNodeList.Get(18, GenericNode) then begin   //Live
                    // if L_OrderNodeList.Get(19, GenericNode) then begin  //UAT
                    //     GenericElement := GenericNode.AsXmlElement();
                    //     OrderSource := GenericElement.InnerText();
                    // end;

                    // TradePartner.Reset();
                    // if TradePartner.Get(ChannelCode) then begin
                    //     if (OrderSource = 'Cloudfy') and (ChannelCode = 'CLOUDFYB2B') then begin
                    //         InsertInInterimSalesHeader(L_OrderNodeList, ChannelCode, InterimSalesHeader, PaymentDetails, OrderSource);
                    //         InsertInInterimSalesLine(L_OrderNodeList, ChannelCode, InterimSalesHeader, InterimSalesLine);

                    //         CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                    //         UpdateOrderTracking(ChannelCode);
                    //         ConvertStatusToAcknowledge(ChannelCode);
                    //     end;

                    //     if (OrderSource = 'API') and (ChannelCode = 'CLOUDFYB2C') then begin
                    //         InsertInInterimSalesHeader(L_OrderNodeList, ChannelCode, InterimSalesHeader, PaymentDetails, OrderSource);
                    //         InsertInInterimSalesLine(L_OrderNodeList, ChannelCode, InterimSalesHeader, InterimSalesLine);

                    //         CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                    //         UpdateOrderTracking(ChannelCode);
                    //         ConvertStatusToAcknowledge(ChannelCode);
                    //     end;

                    //     if (OrderSource = 'NEXT') and (ChannelCode = 'CLOUDFYNXT') then begin
                    //         InsertInInterimSalesHeader(L_OrderNodeList, ChannelCode, InterimSalesHeader, PaymentDetails, OrderSource);
                    //         InsertInInterimSalesLine(L_OrderNodeList, ChannelCode, InterimSalesHeader, InterimSalesLine);

                    //         CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                    //         UpdateOrderTracking(ChannelCode);
                    //         ConvertStatusToAcknowledge(ChannelCode);
                    //     end;
                    // end;
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
        ServiceURL: Text;
}