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
            ServiceURL := ShippingAgent."Internet Address";
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
        List_FullName: List of [Text];
        FirstName: Text;
        LastName: Text;
        OrderAmount: Decimal;
        TotalWeight: Decimal;
        TotalWeightText: Text;
        NoOfItems: Integer;
        CurrencyCode: Text;
        JObject: JsonObject;
        routingResponseEntriesObject: JsonObject;
        routingResponseEntryObject: JsonObject;
        outboundCarriersObject: JsonObject;
        PDFBase64Label: Text;
        ImageBase64Label: Text;
        carrier1Object: JsonObject;
        barcode1Object: JsonObject;
        barcodeNumber: Text;
        carrierName: Text;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_InterimSalesHeader: Record "Interim Sales Header";
        CU_ShipmentTrackingInsertion: Codeunit "Shipment Tracking Insertion";
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        // authorization := CreateBasicAuth(Username, Password);
        // L_httpheaders.Add('Authorization', authorization);

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

        // body := '<deliveryRoutingRequest><clientId>' + ClientId + '</clientId><clientName>' + ClientName + '</clientName>' +
        // '<sourceOfRequest>CLIENTWS</sourceOfRequest><deliveryRoutingRequestEntries><deliveryRoutingRequestEntry>' +
        // '<addressValidationRequired>false</addressValidationRequired><customer><address>' +
        // '<lastName>' + Temp_SalesHeader."Ship-to Name" + '</lastName><streetName>' + CopyStr(Temp_SalesHeader."Ship-to Address", 1, 32) + '</streetName>' +
        // '<city>Morley</city><postCode>LS27 0WH</postCode><countryCode>GB</countryCode></address>' +
        // '<customerReference1>UKDomestic1-1</customerReference1></customer><parcel><weight>1000</weight>' +
        // '<length>50</length><width>50</width><depth>20</depth><girth>140</girth><combinedDimension>190</combinedDimension>' +
        // '<volume>40000</volume><currency>GBP</currency><value>1000</value><numberOfItems>1</numberOfItems>' +
        // '<description>Footwear</description><originOfParcel>GB</originOfParcel></parcel><services>' +
        // '<nextDay>true</nextDay></services><expectedDespatchDate>2022-03-18</expectedDespatchDate>' +
        // '<countryOfOrigin>GB</countryOfOrigin></deliveryRoutingRequestEntry></deliveryRoutingRequestEntries></deliveryRoutingRequest>';

        // body := '{"Username": "ILoveWallpaper-sit","Password": "0k4Bxn2YQ3Ec","deliveryRoutingRequest": {"clientId": "2348",' +
        //                 '"clientName": "Wallpaper Warehouse","sourceOfRequest": "CLIENTWS","deliveryRoutingRequestEntries": {' +
        //                 '"deliveryRoutingRequestEntry": {"addressValidationRequired": "false","customer": {"address": {"firstName": "Test",' +
        //                 '"lastName": "Customer","streetName": "Capitol Close","city": "Morley","postCode": "LS27 0WH","countryCode": "GB"},' +
        //                 '"customerReference1": "UKDomestic1-1"},"parcel": {"weight": "1000","length": "50","width": "50","depth": "20",' +
        //                 '"girth": "140","combinedDimension": "190","volume": "40000","currency": "GBP","value": "1000","numberOfItems": "1",' +
        //                 '"description": "Footwear","originOfParcel": "GB"},"services": {"nextDay": "true"},"expectedDespatchDate": "2022-03-09",' +
        //                 '"countryOfOrigin": "GB"}}}}';

        List_FullName := Temp_SalesHeader."Ship-to Name".Split(' ');
        Clear(FirstName);
        Clear(LastName);
        FirstName := List_FullName.Get(1);
        LastName := List_FullName.Get(2);
        if List_FullName.Count > 2 then begin
            LastName := LastName + ' ' + List_FullName.Get(3);
        end;

        Clear(OrderAmount);
        Clear(TotalWeight);
        Clear(NoOfItems);
        Clear(CurrencyCode);
        if Temp_SalesHeader.FindFirst() then begin
            L_InterimSalesHeader.Reset();
            L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
            if L_InterimSalesHeader.FindFirst() then begin
                CurrencyCode := L_InterimSalesHeader."Currency Code";
                NoOfItems := L_InterimSalesHeader."No. of Items";
            end;

            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document No", Temp_SalesHeader."No.");
            if L_InterimSalesLine.FindSet() then begin
                repeat
                    OrderAmount := OrderAmount + L_InterimSalesLine."Amount Including VAT";
                until L_InterimSalesLine.Next() = 0;
            end;
        end;

        TotalWeight := Temp_SalesHeader."Currency Factor" * 1000;
        if ((TotalWeight = 0) and (NoOfItems <> 0)) then
            TotalWeight := NoOfItems * 1000;

        TotalWeightText := Format(TotalWeight);

        if TotalWeightText.Contains(',') then begin
            TotalWeightText := TotalWeightText.Replace(',', '');
        end;

        body := StrSubstNo('{"Username": "%1","Password": "%2","deliveryRoutingRequest": {"clientId": "%3",' +
                '"clientName": "%4","sourceOfRequest": "CLIENTWS","deliveryRoutingRequestEntries": {' +
                '"deliveryRoutingRequestEntry": {"addressValidationRequired": "false","customer": {"address": {"firstName": "%5",' +
                '"lastName": "%6","streetName": "%7","city": "%8","postCode": "%9","countryCode": "%10"},' +
                '"customerReference1": "UKDomestic1-1"},"parcel": {"weight": "%11","length": "50","width": "50","depth": "20",' +
                '"girth": "140","combinedDimension": "190","volume": "40000","currency": "%12","value": "%13","numberOfItems": "%14",' +
                '"description": "","originOfParcel": ""},"services": {"nextDay": "true"},"expectedDespatchDate": "%15",' +
                '"countryOfOrigin": "%16"}}}}', Username, Password, ClientId, ClientName, FirstName, LastName, CopyStr(Temp_SalesHeader."Ship-to Address", 1, 32),
                Temp_SalesHeader."Ship-to City", Temp_SalesHeader."Ship-to Post Code", Temp_SalesHeader."Ship-to Country/Region Code",
                TotalWeightText, CurrencyCode, OrderAmount, NoOfItems, Format(Temp_SalesHeader."Shipment Date", 0, '20<Year>-<Month,2>-<Day,2>'), Temp_SalesHeader."Ship-to Country/Region Code");

        L_httpcontent.WriteFrom(body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');

        ServiceURL := ServiceURL + '/Hermes/GenerateOrderShipment';

        if L_httpclient.Post(ServiceURL, L_httpcontent, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);

                JObject.ReadFrom(L_response);

                routingResponseEntriesObject := GetJsonToken(JObject, 'routingResponseEntries').AsObject();
                routingResponseEntryObject := GetJsonToken(routingResponseEntriesObject, 'routingResponseEntry').AsObject();
                outboundCarriersObject := GetJsonToken(routingResponseEntryObject, 'outboundCarriers').AsObject();

                Clear(PDFBase64Label);
                if GetJsonvalue(outboundCarriersObject, 'labelImage').IsNull = false then begin
                    PDFBase64Label := GetJsonvalue(outboundCarriersObject, 'labelImage').AsText();
                end;

                if PDFBase64Label <> '' then begin
                    ImageBase64Label := ConvertPDFtoImageBase64(PDFBase64Label, Temp_SalesHeader);

                    if ImageBase64Label <> '' then begin
                        carrier1Object := GetJsonToken(outboundCarriersObject, 'carrier1').AsObject();
                        barcode1Object := GetJsonToken(carrier1Object, 'barcode1').AsObject();

                        Clear(carrierName);
                        if GetJsonvalue(carrier1Object, 'carrierName').IsNull = false then begin
                            carrierName := GetJsonvalue(carrier1Object, 'carrierName').AsText();
                        end;

                        Clear(barcodeNumber);
                        if GetJsonvalue(barcode1Object, 'barcodeNumber').IsNull = false then begin
                            barcodeNumber := GetJsonvalue(barcode1Object, 'barcodeNumber').AsText();
                        end;

                        //Code to Insert Shipment Details in Shipment Tracking
                        CU_ShipmentTrackingInsertion.InsertShipmentTracking(barcodeNumber, ImageBase64Label, '', carrierName, '', Temp_SalesHeader);
                    end;
                end;

                // L_response := CU_XMLDOMMgmt.RemoveNamespaces(L_response);
                // XmlDocument.ReadFrom(L_response, L_XmlDocument);

                // L_RoutingResponseList := L_XmlDocument.GetDescendantElements('routingResponse');
                // if L_RoutingResponseList.Get(4, L_RoutingResponseEntriesNode) then
                //     L_RoutingResponseEntriesElement := L_RoutingResponseEntriesNode.AsXmlElement();
                // if not L_RoutingResponseEntriesElement.IsEmpty() and L_RoutingResponseEntriesElement.HasElements() then begin
                //     L_RoutingResponseEntryList := L_RoutingResponseEntriesElement.GetChildNodes();
                // end;
            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                If Temp_SalesHeader.FindFirst() then
                    Message('Error Message - ' + L_response + '-->' + 'for Order No. ' + Temp_SalesHeader."No.");
            end;
        end;
    end;


    local procedure ConvertPDFtoImageBase64(var PDFBase64Label: Text; var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        C_httpclient: HttpClient;
        C_httpheaders: HttpHeaders;
        C_httpcontent: HttpContent;
        C_httpresponseMessage: HttpResponseMessage;
        C_response: Text;
        requestBody: Text;
        JArray: JsonArray;
        JToken: JsonToken;
        ImageBase64Label: Text;
    begin
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        C_httpheaders := C_httpclient.DefaultRequestHeaders;

        requestBody := StrSubstNo('{"PdfBase64": "%1"}', PDFBase64Label);

        C_httpcontent.WriteFrom(requestBody);
        C_httpcontent.GetHeaders(C_httpheaders);
        C_httpheaders.Clear();
        C_httpheaders.Add('Content-Type', 'application/json');

        ServiceURL := ServiceURL + '/PdfToImage/PdfToImageConversion';
        Clear(ImageBase64Label);
        if C_httpclient.Post(ServiceURL, C_httpcontent, C_httpresponseMessage) then begin
            if C_httpresponseMessage.HttpStatusCode = 200 then begin
                C_httpresponseMessage.Content.ReadAs(C_response);
                JArray.ReadFrom(C_response);
                JArray.Get(0, JToken);
                ImageBase64Label := Format(JToken);
                if ImageBase64Label.Contains('"') then
                    ImageBase64Label := ImageBase64Label.Replace('"', '');
                exit(ImageBase64Label);
            end
            else begin
                exit(ImageBase64Label);
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

    procedure GetJsonToken(var JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then;
    end;


    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: text) aJsonValue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        Else
            aJsonValue := aJsonToken.AsValue();
    end;
}