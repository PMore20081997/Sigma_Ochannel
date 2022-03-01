codeunit 90089 "DPD Courier"
{
    TableNo = 36;
    trigger OnRun()
    begin
        GenerateGeoSession(Rec);
    end;

    var
        Username: Text;
        Password: Text;
        ServiceURL: Text;
        DPDAccountNo: Text;
        LabelServiceURL: Text;

    local procedure GetCredentials(ChannelCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            Username := ShippingAgent."Access Key";
            Password := ShippingAgent."Secret Key";
            ServiceURL := ShippingAgent."API URL";
            DPDAccountNo := ShippingAgent."Client Id";
            LabelServiceURL := ShippingAgent."Internet Address";
        End;
    end;


    procedure GenerateGeoSession(var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        HttpHeader: HttpHeaders;
        HttpClients: HttpClient;
        HttpContents: HttpContent;
        HttpResponse: HttpResponseMessage;
        TextRequest: Text;
        responseText: Text;
        auth: Text;
        jObject: JsonObject;
        DataObject: JsonObject;
        GeoSession: Text;
    begin
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        auth := CreateBasicAuth(Username, Password);
        HttpHeader := HttpClients.DefaultRequestHeaders;
        ServiceURL := ServiceURL + '/user/?action=login';
        HttpHeader.Add('Authorization', auth);
        HttpContents.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        if HttpClients.Post(ServiceURL, HttpContents, HttpResponse) then begin
            if HttpResponse.HttpStatusCode = 200 then begin
                HttpResponse.Content.ReadAs(responseText);
                jObject.ReadFrom(responseText);
                DataObject := GetJsonToken(jObject, 'data').AsObject();
                GeoSession := GetJsonvalue(DataObject, 'geoSession').AsText();
                CreateShipment(GeoSession, Temp_SalesHeader);
            end
            else begin
                HttpResponse.Content.ReadAs(responseText);
                Message(responseText);
            end;
        end;
    end;


    procedure CreateShipment(GeoSession: Text; var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        CollectionDate: Text;
        TextRequest: Text;
        HeaderText: Text;
        LineText: Text;
        location: Record Location;
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpresponseMessage: HttpResponseMessage;
        L_response: Text;
        body: Text;
        jObject: JsonObject;
        URL: Text;
        responseData: JsonObject;
        Error: Text;
        ErrorArray: JsonArray;
        L_Interimsalesheader: Record "Interim Sales Header";
        i: Integer;
        noOfResult: Integer;
        NoofRecs: Integer;
        orderToken: JsonToken;
        orderHeaderObject: JsonObject;
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        //DPDAccountNo := '100201';
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        ServiceURL := ServiceURL + '/shipping/shipment';

        location.Reset();
        if location.Get(Temp_SalesHeader."Location Code") then;

        if Temp_SalesHeader."Shipment Date" < Today then
            CollectionDate := Format(Today, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00')
        else
            CollectionDate := Format(Temp_SalesHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

        if ((Temp_SalesHeader."Ship-to Address" <> '') and (Temp_SalesHeader."Ship-to Country/Region Code" <> '') and
         (Temp_SalesHeader."Ship-to Post Code" <> '') and (Temp_SalesHeader."Ship-to City" <> '') and
         (Temp_SalesHeader."Shipping Agent Service Code" <> '')) then begin

            TextRequest := StrSubstNo('{"jobId":null,"collectionOnDelivery":false,"invoice":null,"collectionDate":"%1",' +
            '"consolidate":false,"consignment":[{"consignmentNumber":"' + Temp_SalesHeader."Applies-to ID" + '","consignmentRef":null,"parcel":[],' +
            '"collectionDetails":{"contactDetails":{"contactName":"%2","telephone":"%3"},"address":{"organisation":"%4","countryCode":"%5","postcode":"%6","street":"%7","town":"%8","county":"%9"}},' +
            '"deliveryDetails":{"contactDetails":{"contactName":"%10","telephone":"%11"},"address":{"organisation":"%12","countryCode":"%13","postcode":"%14","street":"%15","town":"%16","county":"%17"},' +
            '"notificationDetails":{"email":"%18","mobile":"%19"}},"networkCode":"%20","numberOfParcels":1,"totalWeight":%21,"liabilityValue":null,"liability":false}]}',
            CollectionDate, location.Name, location.Contact, location.Name, location."Country/Region Code", location."Post Code", location.County, location.County, location.County,
            CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Sell-to Phone No.", CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Ship-to Country/Region Code", Temp_SalesHeader."Ship-to Post Code", CopyStr(Temp_SalesHeader."Ship-to Address", 1, 35), Temp_SalesHeader."Ship-to City", Temp_SalesHeader."Ship-to County",
            Temp_SalesHeader."Sell-to E-Mail", Temp_SalesHeader."Sell-to Phone No.", Temp_SalesHeader."Shipping Agent Service Code", Temp_SalesHeader."Currency Factor");

            /*salesHeader."Sell-to Phone No."
                    TextRequest := StrSubstNo('{"jobId":null,"collectionOnDelivery":false,"invoice":null,"collectionDate":"%1",' +
                    '"consolidate":false,"consignment":[{"consignmentNumber":null,"consignmentRef":null,"parcel":[],' +
                    '"collectionDetails":{"contactDetails":{"contactName":"%2","telephone":"%3"},"address":{"countryCode":"%4","postcode":"%5","street":"%6","town":"%7","county":"%8"}},' +
                    '"deliveryDetails":{"contactDetails":{"contactName":"%9","telephone":"%10"},"address":{"countryCode":"%11","postcode":"%12","street":"%13","town":"%14","county":"%15"},' +
                    '"notificationDetails":{"email":"%16","mobile":"%17"}},"networkCode":"%18","numberOfParcels":1,"totalWeight":%19,"liabilityValue":null,"liability":false}]}',
                    '2021-11-02T04:00:00', 'xyz', '0121 500 2500', 'GB', 'B66 1BY', 'Roebuck Lane', 'Birmingham', 'West Midlands',
                    'abc', '0121 500 2500', 'GB', 'B66 1BY', 'Roebuck Lane', 'Birmingham', 'West Midlands',
                    'my.email@dpdgroup.co.uk', '07921000001', '1^12', '5');
            */

            L_httpcontent.WriteFrom(TextRequest);
            L_httpcontent.GetHeaders(L_httpheaders);
            L_httpheaders.Clear();
            L_httpheaders.Add('Content-Type', 'application/json');
            //L_httpheaders.Add('GEOClient', 'account/' + DPDAccountNo);
            L_httpheaders.Add('GEOSession', GeoSession);
            if L_httpclient.Post(ServiceURL, L_httpcontent, L_httpresponseMessage) then begin
                if L_httpresponseMessage.HttpStatusCode = 200 then begin
                    L_httpresponseMessage.Content.ReadAs(L_response);
                    jObject.ReadFrom(L_response);

                    if (GetJsonToken(jObject, 'error').IsValue = false) then begin
                        ErrorArray := GetJsonToken(jObject, 'error').AsArray();
                        i := ErrorArray.Count();
                        noOfResult := ErrorArray.Count();
                        NoofRecs := ErrorArray.Count();
                        for i := 0 to noOfResult - 1 do begin
                            ErrorArray.Get(i, orderToken);
                            orderHeaderObject := orderToken.AsObject();
                            Error := GetJsonvalue(orderHeaderObject, 'errorMessage').AsText();
                            L_Interimsalesheader.Reset();
                            L_Interimsalesheader.SetRange("No.", Temp_SalesHeader."No.");
                            if L_Interimsalesheader.FindFirst() then begin
                                L_Interimsalesheader.Remarks := Error;
                                L_Interimsalesheader.Modify();
                            end;
                        end;
                    end
                    else begin
                        UpdateShipmentHeader(jObject, Temp_SalesHeader);
                        L_Interimsalesheader.Reset();
                        L_Interimsalesheader.SetRange("No.", Temp_SalesHeader."No.");
                        if L_Interimsalesheader.FindFirst() then;
                        GetDPDLables(L_Interimsalesheader, GeoSession, ServiceURL, DPDAccountNo);
                    end;

                end
                else begin
                    L_httpresponseMessage.Content.ReadAs(L_response);
                    Message(L_response);
                end;
            end;
        end;
    end;


    procedure UpdateShipmentHeader(responseObject: JsonObject; var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        responseData: JsonObject;
        consignmentData: JsonObject;
        parcelData: JsonArray;
        PackageToken: JsonToken;
        packageobj: JsonObject;
        trackingNo: Text;
        L_InterimSalesHeader: Record "Interim Sales Header";
        i: Integer;
    begin
        responseData := GetJsonToken(responseObject, 'data').AsObject();
        trackingNo := GetJsonvalue(responseData, 'shipmentId').AsText();
        /*
                consignmentData := GetJsonToken(responseData, 'consignmentDetail').AsObject();
                parcelData := GetJsonToken(consignmentData, 'parcelNumbers').AsArray();
                parcelData.Get(i, PackageToken);
                packageobj := PackageToken.AsObject();
                trackingNo := Format(packageobj.AsToken());// CopyStr(GetJsonvalue(packageobj, '').AsText(), 1, 30);
        */
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
        if L_InterimSalesHeader.FindFirst() then begin
            L_InterimSalesHeader.Validate("Package Tracking No.", trackingNo);
            L_InterimSalesHeader.Remarks := '';
            L_InterimSalesHeader.Modify();
        end;
    end;

    procedure GetDPDLables(var Temp_salesheader: Record "Interim Sales Header" temporary; GeoSession: text; SURL: Text; DPDAcctno: Text)
    var
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpresponseMessage: HttpResponseMessage;
        L_response: Text;
        body: Text;
        jObject: JsonObject;
        URL: Text;
        ShipmentTrack: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
        Base64StringLabel: Text;
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
    begin
        ClearAll();
        GetCredentials(Temp_salesheader."Shipping Agent Code");

        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        // ServiceURL := 'https://api.dpd.co.uk/shipping/shipment/' + Format(Temp_salesheader."Package Tracking No.") + '/label';
        ServiceURL := LabelServiceURL + '?shipmentid=' + Format(Temp_salesheader."Package Tracking No.") + '&url=' + SURL + '&dpdaccountno=' + DPDAcctno + '&geosession=' + GeoSession;
        //ServiceURL := 'http://dpdlabelapi.azurewebsites.net/api/DPD/GetLabels?shipmentid=745602544&url=' + SURL + '&dpdaccountno=' + DPDAcctno + '&geosession=' + GeoSession;
        L_httpheaders.Add('Accept', 'application/json');
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        if L_httpclient.Get(ServiceURL, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                jObject.ReadFrom(L_response);

                Base64StringLabel := GetJsonvalue(jObject, 'LabelImageBase64').AsText();
                if Base64StringLabel <> 'null' then begin
                    ShipmentTrack.INIT;
                    ShipmentTrack.VALIDATE("Document Type", ShipmentTrack."Document Type"::Order);
                    if Temp_SalesHeader.FindFirst() then;

                    ShipmentTrack.Validate("Document No.", Temp_SalesHeader."No.");
                    ShipmentTrack.Validate("Shipping Agent Code", Temp_SalesHeader."Shipping Agent Code");
                    ShipmentTrack.VALIDATE("Shipping Agent Service Code", Temp_SalesHeader."Shipping Agent Service Code");

                    //ShipmentTrack.Validate("Shipping Agent Code", 'DPD');
                    //ShipmentTrack.VALIDATE("Shipping Agent Service Code", '1^12');
                    ShipmentTrack.Validate("Entry Created", Today);

                    IF RecShipmentTracking.FINDLAST THEN
                        ShipmentTrack."Entry No." := RecShipmentTracking."Entry No." + 1
                    ELSE
                        ShipmentTrack."Entry No." := 1;
                    ShipmentTrack.VALIDATE("Tracking No.", Temp_SalesHeader."Package Tracking No.");

                    //Base64StringLabel := GetJsonvalue(jObject, 'LabelImageBase64').AsText();
                    IF (Base64StringLabel <> '') THEN BEGIN
                        ShipmentTrack.CalcFields(Label);
                        ShipmentTrack.Label.CreateOutStream(OutStm);
                        Base64Convert.FromBase64(Base64StringLabel, OutStm);
                    END;
                    ShipmentTrack.INSERT;
                end;
            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                Message(L_response);
            end;
        end;
        Temp_salesheader.DeleteAll();
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