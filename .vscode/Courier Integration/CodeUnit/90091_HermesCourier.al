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
        NextDayText: Text;
        FirstName: Text;
        LastName: Text;
        TotalWeightText: Text;
        CurrencyCode: Text;
        OrderAmount: Decimal;
        NoOfItems: Integer;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";


    local procedure GetCredentials(ChannelCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            Username := ShippingAgent."Access Key";
            Password := ShippingAgent."Secret Key";
            ServiceURL := ShippingAgent."Internet Address";
            //ServiceURL := ShippingAgent."API URL";
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
        ReqeustBody: Text;
        authorization: Text;
        CU_XMLDOMMgmt: Codeunit "XML DOM Management";
        L_XmlDocument: XmlDocument;
        L_RoutingResponseList: XmlNodeList;
        L_RoutingResponseListNode: XmlNode;
        L_RoutingResponseListElement: XmlElement;
        L_RoutingResponseEntryList: XmlNodeList;
        List_FullName: List of [Text];
        TotalWeight: Decimal;
        JObject: JsonObject;
        routingResponseEntriesObject: JsonObject;
        routingResponseEntryArray: JsonArray;
        routingResponseEntryToken: JsonToken;
        routingResponseEntryObject: JsonObject;
        outboundCarriersObject: JsonObject;
        PDFBase64Label: Text;
        ImageBase64Label: Text;
        carrier1Object: JsonObject;
        barcode1Object: JsonObject;
        ErrorObject: JsonObject;
        ErrorMessage: Text;
        barcodeNumber: Text;
        carrierName: Text;
        deliveryRoutingRequestEntry: Text;
        ResponseCount: Integer;
        i: Integer;
        ErrorMessageToken: JsonToken;
        OutboundCarrierToken: JsonToken;
        ChildClientId: Text;
        ChildClientName: Text;
        WebShipmentMethod: Code[50];
        ShippingRule: Record "Shipping Rule";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_InterimSalesHeader: Record "Interim Sales Header";
        Rec_InterimSalesHeader: Record "Interim Sales Header";
        CU_ShipmentTrackingInsertion: Codeunit "Shipment Tracking Insertion";
        L_InterimHeader: Record "Handled Interim Sales Header";
        L_InterimLine: Record "Handled Interim Sales Line";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        Clear(List_FullName);
        Clear(FirstName);
        Clear(LastName);
        if Temp_SalesHeader."Ship-to Name".Contains(' ') then begin
            List_FullName := Temp_SalesHeader."Ship-to Name".Split(' ');
            FirstName := List_FullName.Get(1);
            LastName := List_FullName.Get(2);
            if List_FullName.Count > 2 then begin
                LastName := LastName + ' ' + List_FullName.Get(3);
            end;
        end
        else begin
            FirstName := Temp_SalesHeader."Ship-to Name";
        end;


        Clear(OrderAmount);
        Clear(TotalWeight);
        Clear(NoOfItems);
        Clear(CurrencyCode);
        Clear(WebShipmentMethod);
        if Temp_SalesHeader.FindFirst() then begin
            L_InterimSalesHeader.Reset();
            L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
            if L_InterimSalesHeader.FindFirst() then begin
                CurrencyCode := L_InterimSalesHeader."Currency Code";
                NoOfItems := L_InterimSalesHeader."No. of Items";
                WebShipmentMethod := L_InterimSalesHeader."Web Shipment Method";
            end else begin
                L_InterimHeader.Reset();
                L_InterimHeader.SetRange("No.", Temp_SalesHeader."No.");
                if L_InterimHeader.FindFirst() then begin
                    CurrencyCode := L_InterimHeader."Currency Code";
                    NoOfItems := L_InterimHeader."No. of Items";
                    WebShipmentMethod := L_InterimHeader."Web Shipment Method";
                end
            end;

            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document No", Temp_SalesHeader."No.");
            if L_InterimSalesLine.FindSet() then begin
                repeat
                    OrderAmount := OrderAmount + L_InterimSalesLine."Amount Including VAT";
                until L_InterimSalesLine.Next() = 0;
            end else begin
                L_InterimLine.Reset();
                L_InterimLine.SetRange("Document No", Temp_SalesHeader."No.");
                L_InterimLine.SetRange(Type, L_InterimLine.Type::Item);
                if L_InterimLine.FindSet() then begin
                    repeat
                        OrderAmount := OrderAmount + L_InterimLine."Amount Including VAT";
                    until L_InterimLine.Next() = 0;
                end
            end;
        end;

        TotalWeight := Temp_SalesHeader."Currency Factor" * 1000;
        if ((TotalWeight = 0) and (NoOfItems <> 0)) then
            TotalWeight := NoOfItems * 1000;

        Clear(TotalWeightText);
        TotalWeightText := Format(TotalWeight);

        if TotalWeightText.Contains(',') then begin
            TotalWeightText := TotalWeightText.Replace(',', '');
        end;

        Clear(NextDayText);
        NextDayText := '';
        if Temp_SalesHeader."Shipping Agent Service Code" <> '84' then begin
            NextDayText := 'true';
        end;

        Clear(ChildClientId);
        Clear(ChildClientName);
        ShippingRule.Reset();
        ShippingRule.SetRange("Channel Code", Temp_SalesHeader."Bill-to Customer No.");
        ShippingRule.SetRange("Web Shipment Method", WebShipmentMethod);
        ShippingRule.SetRange("Shipping Agent", Temp_SalesHeader."Shipping Agent Code");
        if ShippingRule.FindFirst() then begin
            ChildClientId := ShippingRule."Child Client Id";
            ChildClientName := ShippingRule."Child Client Name";
        end;

        //Code to Generate Multiple DeliveryRoutingRequest Based on Number of Parcels
        Clear(deliveryRoutingRequestEntry);
        deliveryRoutingRequestEntry := GenerateDeliveryRoutingRequestEntry(Temp_SalesHeader);

        body := StrSubstNo('<deliveryRoutingRequest><clientId>%1</clientId><clientName>%2</clientName><childClientId>%3</childClientId>' +
                        '<childClientName>%4</childClientName><sourceOfRequest>CLIENTWS</sourceOfRequest>' +
                        '<deliveryRoutingRequestEntries>%5</deliveryRoutingRequestEntries></deliveryRoutingRequest>', ClientId, ClientName, ChildClientId, ChildClientName, deliveryRoutingRequestEntry);

        Clear(ReqeustBody);
        ReqeustBody := StrSubstNo('{"RequestBody":"%1","Username": "%2","Password": "%3"}', body, Username, Password);

        // body := StrSubstNo('{"Username": "%1","Password": "%2","deliveryRoutingRequest": {"clientId": "%3",' +
        //         '"clientName": "%4","sourceOfRequest": "CLIENTWS","deliveryRoutingRequestEntries": {' +
        //         '"deliveryRoutingRequestEntry": {"addressValidationRequired": "false","customer": {"address": {"firstName": "%5",' +
        //         '"lastName": "%6","streetName": "%7","city": "%8","postCode": "%9","countryCode": "%10"},' +
        //         '"customerReference1": "UKDomestic1-1"},"parcel": {"weight": "%11","length": "50","width": "50","depth": "20",' +
        //         '"girth": "140","combinedDimension": "190","volume": "40000","currency": "%12","value": "%13","numberOfItems": "%14",' +
        //         '"description": "","originOfParcel": ""},"services": {"nextDay": "%15"},"expectedDespatchDate": "%16",' +
        //         '"countryOfOrigin": "%17"}}}}', Username, Password, ClientId, ClientName, FirstName, LastName, CopyStr(Temp_SalesHeader."Ship-to Address", 1, 32),
        //         Temp_SalesHeader."Ship-to City", Temp_SalesHeader."Ship-to Post Code", Temp_SalesHeader."Ship-to Country/Region Code",
        //         TotalWeightText, CurrencyCode, OrderAmount, NoOfItems, NextDayText, Format(Temp_SalesHeader."Shipment Date", 0, '20<Year>-<Month,2>-<Day,2>'), Temp_SalesHeader."Ship-to Country/Region Code");
        //Message(ReqeustBody);
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        // authorization := CreateBasicAuth(Username, Password);
        // L_httpheaders.Add('Authorization', authorization);
        L_httpcontent.WriteFrom(ReqeustBody);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');

        ServiceURL := ServiceURL + '/Hermes/GenerateHermesOrderShipment';

        if L_httpclient.Post(ServiceURL, L_httpcontent, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);

                JObject.ReadFrom(L_response);

                routingResponseEntriesObject := GetJsonToken(JObject, 'RoutingResponseEntries').AsObject();
                routingResponseEntryArray := GetJsonToken(routingResponseEntriesObject, 'RoutingResponseEntry').AsArray();
                Clear(ResponseCount);
                ResponseCount := routingResponseEntryArray.Count;

                if ResponseCount > 0 then begin
                    for i := 0 to ResponseCount - 1 do begin
                        routingResponseEntryArray.Get(i, routingResponseEntryToken);
                        routingResponseEntryObject := routingResponseEntryToken.AsObject();

                        //Checking if there is No Error in Response
                        routingResponseEntryObject.Get('ErrorMessages', ErrorMessageToken);
                        if Format(ErrorMessageToken) = 'null' then begin

                            //Checking if Outbound Carrier is Not Null in Response
                            routingResponseEntryObject.Get('OutboundCarriers', OutboundCarrierToken);
                            if Format(OutboundCarrierToken) <> 'null' then begin

                                outboundCarriersObject := GetJsonToken(routingResponseEntryObject, 'OutboundCarriers').AsObject();
                                Clear(PDFBase64Label);
                                if GetJsonvalue(outboundCarriersObject, 'LabelImage').IsNull = false then begin
                                    PDFBase64Label := GetJsonvalue(outboundCarriersObject, 'LabelImage').AsText();
                                end;

                                if PDFBase64Label <> '' then begin
                                    Clear(ImageBase64Label);
                                    //ImageBase64Label := ConvertPDFtoImageBase64(PDFBase64Label, Temp_SalesHeader);

                                    carrier1Object := GetJsonToken(outboundCarriersObject, 'Carrier1').AsObject();
                                    barcode1Object := GetJsonToken(carrier1Object, 'Barcode1').AsObject();

                                    Clear(barcodeNumber);
                                    if GetJsonvalue(barcode1Object, 'BarcodeNumber').IsNull = false then begin
                                        barcodeNumber := GetJsonvalue(barcode1Object, 'BarcodeNumber').AsText();
                                    end;

                                    //Updating Tracking Number on Web Order
                                    if barcodeNumber <> '' then begin
                                        if Temp_SalesHeader.FindFirst() then begin
                                            Rec_InterimSalesHeader.Reset();
                                            Rec_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                                            if Rec_InterimSalesHeader.FindFirst() then begin
                                                Rec_InterimSalesHeader.Validate("Package Tracking No.", CopyStr(barcodeNumber, 1, 30));
                                                Rec_InterimSalesHeader.Modify(true);
                                            end else begin
                                                L_InterimHeader.Reset();
                                                L_InterimHeader.SetRange("No.", Temp_SalesHeader."No.");
                                                if L_InterimHeader.FindFirst() then begin
                                                    L_InterimHeader.Validate("Package Tracking No.", CopyStr(barcodeNumber, 1, 30));
                                                    L_InterimHeader.Modify(true);
                                                end
                                            end;
                                        end;
                                    end;

                                    //Message(PDFBase64Label); // debugging
                                    //Code to Insert Shipment Details in Shipment Tracking
                                    CU_ShipmentTrackingInsertion.InsertShipmentTracking(barcodeNumber, PDFBase64Label, '', '', '', Temp_SalesHeader);
                                    Commit();
                                    Sleep(500);

                                end;
                            end;
                        end
                        else begin
                            ErrorObject := GetJsonToken(routingResponseEntryObject, 'ErrorMessages').AsObject();
                            Clear(ErrorMessage);
                            ErrorMessage := GetJsonvalue(ErrorObject, 'ErrorDescription').AsText();
                            If Temp_SalesHeader.FindFirst() then begin
                                L_InterimSalesHeader.Reset();
                                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                                L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                                if L_InterimSalesHeader.FindFirst() then begin
                                    CU_WebOrderMgmt.InsertErrorLog(ErrorMessage, L_InterimSalesHeader);
                                end;
                            end;
                        end;
                    end;
                end;

            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                If Temp_SalesHeader.FindFirst() then begin
                    L_InterimSalesHeader.Reset();
                    L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                    L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                    if L_InterimSalesHeader.FindFirst() then begin
                        CU_WebOrderMgmt.InsertErrorLog(L_response, L_InterimSalesHeader);
                    end;
                end;
            end;
        end
        else begin
            L_httpresponseMessage.Content.ReadAs(L_response);
            if Temp_SalesHeader.FindFirst() then begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                if L_InterimSalesHeader.FindFirst() then begin
                    CU_WebOrderMgmt.InsertErrorLog(L_response, L_InterimSalesHeader);
                end;
            end;
        end;
    end;


    local procedure GenerateDeliveryRoutingRequestEntry(var P_TempSalesHeader: Record "Sales Header" temporary): Text
    var
        RoutingRequestEntry: Text;
        i: Integer;
        Street: Text;
        TypeHelper: Codeunit "Type Helper";
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        Clear(RoutingRequestEntry);
        for i := 0 to P_TempSalesHeader."No. Printed" - 1 do begin
            Clear(Street);
            Street := CopyStr(P_TempSalesHeader."Ship-to Address", 1, 32);
            if Street.Contains('&') then begin
                //Street := TypeHelper.UrlEncode(Street);
                Street := Street.Replace('&', '&amp;');
            end;
            if Street.Contains('"') then begin
                Street := Street.Replace('"', '&quot;');
            end;
            RoutingRequestEntry += StrSubstNo('<deliveryRoutingRequestEntry><addressValidationRequired>false</addressValidationRequired>' +
                                    '<customer><address><firstName>%1</firstName><lastName>%2</lastName><streetName>%3</streetName>' +
                                    '<city>%4</city><postCode>%5</postCode><countryCode>%6</countryCode></address>' +
                                    '<customerReference1>%7</customerReference1></customer><parcel><weight>%8</weight>' +
                                    '<length>50</length><width>50</width><depth>20</depth><girth>140</girth><combinedDimension>190</combinedDimension>' +
                                    '<volume>40000</volume><currency>%9</currency><value>%10</value><numberOfItems>%11</numberOfItems>' +
                                    '<description></description><originOfParcel></originOfParcel></parcel><services><nextDay>%12</nextDay>' +
                                    '</services><senderAddress><addressLine1>%13</addressLine1><addressLine2>%14</addressLine2>' +
                                    '<addressLine3>%15</addressLine3><addressLine4>%16</addressLine4></senderAddress>' +
                                    '<expectedDespatchDate>%17</expectedDespatchDate><countryOfOrigin>%18</countryOfOrigin></deliveryRoutingRequestEntry>',
                                    FirstName, LastName, Street,
                                    P_TempSalesHeader."Ship-to City", P_TempSalesHeader."Ship-to Post Code", P_TempSalesHeader."Ship-to Country/Region Code", P_TempSalesHeader."Applies-to ID",
                                    TotalWeightText, CurrencyCode, OrderAmount, NoOfItems, NextDayText, CompanyInfo.Address, CompanyInfo."Address 2",
                                    CompanyInfo.City, CompanyInfo."Post Code", Format(P_TempSalesHeader."Shipment Date", 0, '20<Year>-<Month,2>-<Day,2>'), P_TempSalesHeader."Ship-to Country/Region Code");
        end;
        exit(RoutingRequestEntry);
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
        L_InterimSalesHeader: Record "Interim Sales Header";
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
                C_httpresponseMessage.Content.ReadAs(C_response);
                if Temp_SalesHeader.FindFirst() then begin
                    L_InterimSalesHeader.Reset();
                    L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                    L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                    if L_InterimSalesHeader.FindFirst() then begin
                        CU_WebOrderMgmt.InsertErrorLog(C_response, L_InterimSalesHeader);
                    end;
                end;
            end;
        end
        else begin
            C_httpresponseMessage.Content.ReadAs(C_response);
            if Temp_SalesHeader.FindFirst() then begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                if L_InterimSalesHeader.FindFirst() then begin
                    CU_WebOrderMgmt.InsertErrorLog(C_response, L_InterimSalesHeader);
                end;
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