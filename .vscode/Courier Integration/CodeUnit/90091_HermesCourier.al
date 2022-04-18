codeunit 90091 "Hermes Courier"
{
    TableNo = 36;
    trigger OnRun()
    begin
        GenerateLabel(Rec);
    end;

    var
        Username: Text;
        Password: Text;
        ServiceURL: Text;
        ClientId: Text;
        ClientName: Text;


    local procedure GetCredentials(ChannelCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            Username := ShippingAgent."Access Key";
            Password := ShippingAgent."Secret Key";
            ServiceURL := ShippingAgent."API URL";
            ClientId := ShippingAgent."Client Id";
            ClientName := ShippingAgent."Client Secret";
        End;
    end;


    local procedure GenerateLabel(var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpresponseMessage: HttpResponseMessage;
        L_response: Text;
        body: Text;
        authorization: Text;
        CU_XMLDOMMgmt: Codeunit "XML DOM Management";
        L_XmlDocument: XmlDocument;
        L_RoutingResponseList: XmlNodeList;
        L_RoutingResponseEntriesNode: XmlNode;
        L_RoutingResponseEntriesElement: XmlElement;
        L_RoutingResponseEntryList: XmlNodeList;
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        authorization := CreateBasicAuth(Username, Password);
        L_httpheaders.Add('Authorization', authorization);

        // body := '<deliveryRoutingRequest><clientId>2348</clientId><clientName>Wallpaper Warehouse</clientName>' +
        //         '<sourceOfRequest>CLIENTWS</sourceOfRequest><deliveryRoutingRequestEntries><deliveryRoutingRequestEntry>' +
        //         '<addressValidationRequired>false</addressValidationRequired><customer><address>' +
        //         '<firstName>Test</firstName><lastName>Customer</lastName><streetName>Capitol Close</streetName>' +
        //         '<city>Morley</city><postCode>LS27 0WH</postCode><countryCode>GB</countryCode></address>' +
        //         '<customerReference1>UKDomestic1-1</customerReference1></customer><parcel><weight>1000</weight>' +
        //         '<length>50</length><width>50</width><depth>20</depth><girth>140</girth><combinedDimension>190</combinedDimension>' +
        //         '<volume>40000</volume><currency>GBP</currency><value>1000</value><numberOfItems>1</numberOfItems>' +
        //         '<description>Footwear</description><originOfParcel>GB</originOfParcel></parcel><services>' +
        //         '<nextDay>true</nextDay></services><expectedDespatchDate>2022-03-18</expectedDespatchDate>' +
        //         '<countryOfOrigin>GB</countryOfOrigin></deliveryRoutingRequestEntry></deliveryRoutingRequestEntries></deliveryRoutingRequest>';

        body := '<deliveryRoutingRequest><clientId>' + ClientId + '</clientId><clientName>' + ClientName + '</clientName>' +
        '<sourceOfRequest>CLIENTWS</sourceOfRequest><deliveryRoutingRequestEntries><deliveryRoutingRequestEntry>' +
        '<addressValidationRequired>false</addressValidationRequired><customer><address>' +
        '<lastName>' + Temp_SalesHeader."Ship-to Name" + '</lastName><streetName>' + CopyStr(Temp_SalesHeader."Ship-to Address", 1, 32) + '</streetName>' +
        '<city>Morley</city><postCode>LS27 0WH</postCode><countryCode>GB</countryCode></address>' +
        '<customerReference1>UKDomestic1-1</customerReference1></customer><parcel><weight>1000</weight>' +
        '<length>50</length><width>50</width><depth>20</depth><girth>140</girth><combinedDimension>190</combinedDimension>' +
        '<volume>40000</volume><currency>GBP</currency><value>1000</value><numberOfItems>1</numberOfItems>' +
        '<description>Footwear</description><originOfParcel>GB</originOfParcel></parcel><services>' +
        '<nextDay>true</nextDay></services><expectedDespatchDate>2022-03-18</expectedDespatchDate>' +
        '<countryOfOrigin>GB</countryOfOrigin></deliveryRoutingRequestEntry></deliveryRoutingRequestEntries></deliveryRoutingRequest>';

        L_httpcontent.WriteFrom(body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'text/xml');

        if L_httpclient.Post(ServiceURL, L_httpcontent, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                L_response := CU_XMLDOMMgmt.RemoveNamespaces(L_response);
                XmlDocument.ReadFrom(L_response, L_XmlDocument);

                L_RoutingResponseList := L_XmlDocument.GetDescendantElements('routingResponse');
                if L_RoutingResponseList.Get(4, L_RoutingResponseEntriesNode) then
                    L_RoutingResponseEntriesElement := L_RoutingResponseEntriesNode.AsXmlElement();
                if not L_RoutingResponseEntriesElement.IsEmpty() and L_RoutingResponseEntriesElement.HasElements() then begin
                    L_RoutingResponseEntryList := L_RoutingResponseEntriesElement.GetChildNodes();
                end;
            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                If Temp_SalesHeader.FindFirst() then;
                Message(L_response + '-->' + 'for Order No. ' + Temp_SalesHeader."No.");
            end;
        end;
    end;


    procedure CreateBasicAuth(UserName: Text; Password: Text): Text
    var
        CUTempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
        InStrm: InStream;
        tempText: Text;
    begin
        tempText := StrSubstNo('%1:%2', UserName, Password);
        CUTempBlob.CreateOutStream(OutStm, TextEncoding::UTF8);
        OutStm.WriteText(StrSubstNo('%1:%2', UserName, Password));
        CUTempBlob.CreateInStream(InStrm);
        exit(StrSubstNo('Basic %1', Base64Convert.ToBase64(InStrm)));
    end;
}