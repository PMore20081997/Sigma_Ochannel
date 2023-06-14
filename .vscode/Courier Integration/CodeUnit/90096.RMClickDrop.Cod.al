codeunit 90096 "RM Click & Drop"
{
    TableNo = 36;
    trigger OnRun()
    begin
        CreateOrder(Rec);
    end;

    var
        APIKey: Text;
        ServiceURL: Text;
        PdfToImgURL: Text;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
        OrderAmount: Decimal;


    local procedure GetCredentials(ChannelCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            APIKey := ShippingAgent."Access Key";
            ServiceURL := ShippingAgent."API URL";
            PdfToImgURL := ShippingAgent."Internet Address";
        End;
    end;


    local procedure CreateOrder(var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpResponseMessage: HttpResponseMessage;
        L_response: Text;
        body: Text;
        ItemBody: Text;
        jObject: JsonObject;
        L_URL: Text;
        ErrorsCount: Integer;
        SuccessCount: Integer;
        i: Integer;
        noOfResult: Integer;
        NoofRecs: Integer;
        j: Integer;
        ErrorMessage: Text;
        trackingNo: Text;
        PDFBase64Label: Text;
        ImageBase64Label: Text;
        OrderIdentifier: Text;
        ErrorArray: JsonArray;
        orderToken: JsonToken;
        orderHeaderObject: JsonObject;
        ErrorArrayIn: JsonArray;
        OrderArray: JsonArray;
        L_InterimSalesHeader: Record "Interim Sales Header";
        Rec_InterimSalesHeader: Record "Interim Sales Header";
        CU_ShipmentTrackingInsertion: Codeunit "Shipment Tracking Insertion";
        L_InterimHeader: Record "Handled Interim Sales Header";
        Base64Convert: CodeUnit "Base64 Convert";
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        //https://api.parcel.royalmail.com/api/v1/orders (ServiceURL)
        L_URL := ServiceURL;
        L_httpheaders.Add('Accept', 'application/json');
        L_httpheaders.Add('Authorization', 'Bearer ' + APIKey);
        body := RequestMapping(Temp_SalesHeader);

        L_httpcontent.WriteFrom(body);
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');

        if L_httpclient.Post(ServiceURL, L_httpcontent, L_httpResponseMessage) then begin
            if L_httpResponseMessage.HttpStatusCode = 200 then begin
                L_httpResponseMessage.Content.ReadAs(L_response);
                JObject.ReadFrom(L_response);

                SuccessCount := GetJsonvalue(JObject, 'successCount').AsInteger();
                ErrorsCount := GetJsonvalue(JObject, 'errorsCount').AsInteger();
                if ((ErrorsCount = 0) and (SuccessCount > 0)) then begin
                    OrderArray := GetJsonToken(jObject, 'createdOrders').AsArray();
                    noOfResult := OrderArray.Count();
                    for i := 0 to noOfResult - 1 do begin
                        OrderArray.Get(i, orderToken);
                        orderHeaderObject := orderToken.AsObject();

                        //Checking if Response has returned Tracking Number
                        if orderHeaderObject.Contains('trackingNumber') then begin
                            trackingNo := GetJsonvalue(orderHeaderObject, 'trackingNumber').AsText();
                        end;

                        //Updating Tracking Number on Web Order
                        if Temp_SalesHeader.FindFirst() then begin
                            Rec_InterimSalesHeader.Reset();
                            Rec_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                            if Rec_InterimSalesHeader.FindFirst() then begin
                                if trackingNo <> '' then begin
                                    Rec_InterimSalesHeader.Validate("Package Tracking No.", CopyStr(trackingNo, 1, 30));
                                end
                                else begin
                                    trackingNo := Rec_InterimSalesHeader."No.";
                                    Rec_InterimSalesHeader.Validate("Package Tracking No.", Rec_InterimSalesHeader."No.");
                                end;
                                Rec_InterimSalesHeader.Modify(true);
                            end else begin
                                L_InterimHeader.Reset();
                                L_InterimHeader.SetRange("No.", Temp_SalesHeader."No.");
                                if L_InterimHeader.FindFirst() then begin
                                    if trackingNo <> '' then begin
                                        L_InterimHeader.Validate("Package Tracking No.", CopyStr(trackingNo, 1, 30))
                                    end else begin
                                        trackingNo := L_InterimHeader."No.";
                                        L_InterimHeader.Validate("Package Tracking No.", L_InterimHeader."No.");
                                    end;
                                    L_InterimHeader.Modify(true);
                                end;
                            end;
                        end;

                        //Fetching OrderIdentifier for GetLabel API Call
                        // Clear(OrderIdentifier);
                        // OrderIdentifier := GetJsonvalue(orderHeaderObject, 'orderIdentifier').AsText();

                        Clear(PDFBase64Label);
                        Clear(ImageBase64Label);
                        PDFBase64Label := GetJsonvalue(orderHeaderObject, 'label').AsText();

                        if PDFBase64Label <> '' then begin
                            CU_ShipmentTrackingInsertion.InsertShipmentTracking(trackingNo, PDFBase64Label, '', '', '', Temp_SalesHeader);
                            //ImageBase64Label := ConvertPDFtoImageBase64(PDFBase64Label, Temp_SalesHeader); // removal of image conversion
                        end;
                        // else begin
                        //     if OrderIdentifier <> '' then begin
                        //         PDFBase64Label := GetLabel(OrderIdentifier, Temp_SalesHeader);
                        //     end;
                        // end;


                        Commit();
                    end;
                end
                else begin
                    if (GetJsonToken(JObject, 'failedOrders').IsValue = false) then begin
                        ErrorArray := GetJsonToken(JObject, 'failedOrders').AsArray();
                        noOfResult := ErrorArray.Count();
                        for i := 0 to noOfResult - 1 do begin
                            ErrorArray.Get(i, orderToken);
                            orderHeaderObject := orderToken.AsObject();
                            ErrorArrayIn := GetJsonToken(orderHeaderObject, 'errors').AsArray();
                            NoofRecs := ErrorArrayIn.Count();
                            for j := 0 to NoofRecs - 1 do begin
                                Clear(ErrorMessage);
                                ErrorArrayIn.Get(j, orderToken);
                                orderHeaderObject := orderToken.AsObject();
                                ErrorMessage := GetJsonvalue(orderHeaderObject, 'errorMessage').AsText();
                                If Temp_SalesHeader.FindFirst() then begin
                                    L_InterimSalesHeader.Reset();
                                    L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                                    L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                                    if L_InterimSalesHeader.FindFirst() then begin
                                        CU_WebOrderMgmt.InsertErrorLog(ErrorMessage, L_InterimSalesHeader);
                                    end;
                                end;
                            end;
                        end
                    end
                end;
            end
            else begin
                L_httpResponseMessage.Content.ReadAs(L_response);
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
            L_httpResponseMessage.Content.ReadAs(L_response);
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


    local procedure RequestMapping(var T_SalesH: Record "Sales Header" temporary): Text
    var
        TextRequest: Text;
        RequestDate: Text;
        TextItemCollection: Text;
        TextWeight: Text;
        DecimalWeight: Decimal;
        OrderAmountTxt: Text;
        PackageFormat: Text;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_InterimLine: Record "Handled Interim Sales Line";
    begin
        Clear(DecimalWeight);
        if T_SalesH.FindFirst() then begin
            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document No", T_SalesH."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            if L_InterimSalesLine.FindSet() then begin
                repeat
                    DecimalWeight += L_InterimSalesLine.Weight * 1000;
                until L_InterimSalesLine.Next() = 0;
            end else begin
                L_InterimLine.Reset();
                L_InterimLine.SetRange("Document No", T_SalesH."No.");
                L_InterimLine.SetRange(Type, L_InterimLine.Type::Item);
                if L_InterimLine.FindSet() then begin
                    repeat
                        DecimalWeight += L_InterimLine.Weight * 1000;
                    until L_InterimLine.Next() = 0;
                end;
            end;
        end;

        Clear(PackageFormat);
        if DecimalWeight <= 750 then begin
            PackageFormat := 'largeLetter';
        end;
        if (DecimalWeight > 750) and (DecimalWeight <= 2000) then begin
            PackageFormat := 'smallParcel';
        end;
        if DecimalWeight > 2000 then begin
            PackageFormat := 'mediumParcel';
        end;

        Clear(TextWeight);
        // Clear(DecimalWeight);
        // DecimalWeight := T_SalesH."Currency Factor" * 1000;
        TextWeight := Format(DecimalWeight);
        if TextWeight.Contains(',') then begin
            TextWeight := TextWeight.Replace(',', '');
        end;

        RequestDate := Format(T_SalesH."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');
        TextItemCollection := ItemCollection(T_SalesH);

        Clear(OrderAmountTxt);
        OrderAmountTxt := Format(OrderAmount);
        if OrderAmountTxt.Contains(',') then begin
            OrderAmountTxt := OrderAmountTxt.Replace(',', '');
        end;

        TextRequest := StrSubstNo('{"items":[{"orderReference":"%1","recipient":{"address":{"fullName":"%2"' +
        ',"addressLine1":"%3","addressLine2":"%4","city":"%5","postcode":"%6"' +
        ',"countryCode":"%7"}},"billing":{"address":{"fullName":"%8","addressLine1":"%9"' +
        ',"addressLine2":"%10","city":"%11","postcode":"%12","countryCode":"%13"}}' +
        ',"packages":[{"weightInGrams":%14,"packageFormatIdentifier":"' + PackageFormat + '","dimensions":{"heightInMms":1,"widthInMms":1,"depthInMms":1}' +
        ',"contents":[%15]}]' +
        ',"orderDate":"%16","subtotal":%17,"shippingCostCharged":0,"total":%18,"postageDetails":{"serviceCode":"%19"},"label":{"includeLabelInResponse":true,"includeCN":false,"includeReturnsLabel":false}}]}',
        T_SalesH."Applies-to ID", T_SalesH."Ship-to Name", T_SalesH."Ship-to Address", T_SalesH."Ship-to Address 2", T_SalesH."Ship-to City", T_SalesH."Ship-to Post Code"
        , T_SalesH."Ship-to Country/Region Code", T_SalesH."Bill-to Name", T_SalesH."Bill-to Address",
        T_SalesH."Bill-to Address 2", T_SalesH."Bill-to City", T_SalesH."Bill-to Post Code", T_SalesH."Bill-to Country/Region Code"
        , TextWeight, TextItemCollection
        , RequestDate, OrderAmountTxt, OrderAmountTxt, T_SalesH."Shipping Agent Service Code");
        exit(TextRequest);
    end;

    local procedure ItemCollection(var T_SHeader: Record "Sales Header" temporary): Text
    var
        T_SLine: Record "Interim Sales Line";
        InterimLine: Record "Handled Interim Sales Line";
        ItemRequest: Text;
        TextWeight: Text;
        DecimalWeight: Decimal;
        L_Item: Record Item;
        L_CustomsCode: Code[10];
        TariffNumber: Record "Tariff Number";
        L_CustomsDescription: Text[50];
        L_ExtendCustomsDescription: Text;
    begin
        Clear(OrderAmount);
        Clear(ItemRequest);
        if T_SHeader.FindFirst() then begin
            T_SLine.Reset();
            T_SLine.SetRange("Document No", T_SHeader."No.");
            T_SLine.SetRange(Type, T_SLine.Type::Item);
            if T_SLine.FindSet() then begin
                repeat
                    OrderAmount += T_SLine."Unit Price" * T_SLine.Quantity;

                    Clear(TextWeight);
                    Clear(DecimalWeight);
                    DecimalWeight := T_SLine.Weight * 1000;
                    TextWeight := Format(DecimalWeight);
                    if TextWeight.Contains(',') then begin
                        TextWeight := TextWeight.Replace(',', '');
                    end;

                    Clear(L_CustomsCode);
                    Clear(L_CustomsDescription);
                    Clear(L_ExtendCustomsDescription);
                    L_Item.Reset();
                    L_Item.SetRange("No.", T_SLine."No.");
                    if L_Item.FindFirst() then begin
                        if L_Item."Tariff No." <> '' then begin
                            L_CustomsCode := CopyStr(L_Item."Tariff No.", 1, 10);

                            TariffNumber.Reset();
                            TariffNumber.SetRange("No.", L_Item."Tariff No.");
                            if TariffNumber.FindFirst() then begin
                                L_CustomsDescription := CopyStr(TariffNumber.Description, 1, 50);
                                L_ExtendCustomsDescription := TariffNumber.Description;
                            end;
                        end;
                    end;

                    ItemRequest += StrSubstNo('{"name":"%1","SKU":"%2","quantity":%3,"unitValue":%4,"UnitWeightInGrams":%5,"originCountryCode":"%6","customsDescription": "%7","extendedCustomsDescription":"%8","customsCode": "%9","customsDeclarationCategory":"other"},',
                    T_SLine.Description, T_SLine."No.", T_SLine.Quantity, T_SLine."Unit Price", TextWeight, T_SHeader."Payment Method Code", L_CustomsDescription, L_ExtendCustomsDescription, L_CustomsCode);
                until T_SLine.Next() = 0;
            end else begin
                InterimLine.Reset();
                InterimLine.SetRange("Document No", T_SHeader."No.");
                InterimLine.SetRange(Type, InterimLine.Type::Item);
                if InterimLine.FindSet() then begin
                    OrderAmount += InterimLine."Unit Price" * InterimLine.Quantity;

                    Clear(TextWeight);
                    Clear(DecimalWeight);
                    DecimalWeight := InterimLine.Weight * 1000;
                    TextWeight := Format(DecimalWeight);
                    if TextWeight.Contains(',') then begin
                        TextWeight := TextWeight.Replace(',', '');
                    end;

                    Clear(L_CustomsCode);
                    Clear(L_CustomsDescription);
                    Clear(L_ExtendCustomsDescription);
                    L_Item.Reset();
                    L_Item.SetRange("No.", InterimLine."No.");
                    if L_Item.FindFirst() then begin
                        if L_Item."Tariff No." <> '' then begin
                            L_CustomsCode := CopyStr(L_Item."Tariff No.", 1, 10);

                            TariffNumber.Reset();
                            TariffNumber.SetRange("No.", L_Item."Tariff No.");
                            if TariffNumber.FindFirst() then begin
                                L_CustomsDescription := CopyStr(TariffNumber.Description, 1, 50);
                                L_ExtendCustomsDescription := TariffNumber.Description;
                            end;
                        end;
                    end;

                    ItemRequest += StrSubstNo('{"name":"%1","SKU":"%2","quantity":%3,"unitValue":%4,"UnitWeightInGrams":%5,"originCountryCode":"%6","customsDescription": "%7","extendedCustomsDescription":"%8","customsCode": "%9","customsDeclarationCategory":"other"},',
                    InterimLine.Description, InterimLine."No.", InterimLine.Quantity, InterimLine."Unit Price", TextWeight, T_SHeader."Payment Method Code", L_CustomsDescription, L_ExtendCustomsDescription, L_CustomsCode);
                end;
            end;
        end;
        ItemRequest := ItemRequest.TrimEnd(',');
        exit(ItemRequest);
    end;


    local procedure GetLabel(var OrderIdentifier: Text; var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        response: Text;
        labelUrl: Text;
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        Clear(labelUrl);
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        headers := client.DefaultRequestHeaders;
        headers.Add('Authorization', 'Bearer ' + APIKey);
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/pdf');

        labelUrl := ServiceURL + '/' + OrderIdentifier + '/label';

        if client.Get(labelUrl, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);

            end
            else begin
                responseMessage.Content.ReadAs(response);
                if Temp_SalesHeader.FindFirst() then begin
                    L_InterimSalesHeader.Reset();
                    L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                    L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                    if L_InterimSalesHeader.FindFirst() then begin
                        CU_WebOrderMgmt.InsertErrorLog(response, L_InterimSalesHeader);
                    end;
                end;
            end;
        end
        else begin
            responseMessage.Content.ReadAs(response);
            if Temp_SalesHeader.FindFirst() then begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                if L_InterimSalesHeader.FindFirst() then begin
                    CU_WebOrderMgmt.InsertErrorLog(response, L_InterimSalesHeader);
                end;
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
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        C_httpheaders := C_httpclient.DefaultRequestHeaders;

        requestBody := StrSubstNo('{"PdfBase64": "%1"}', PDFBase64Label);

        C_httpcontent.WriteFrom(requestBody);
        C_httpcontent.GetHeaders(C_httpheaders);
        C_httpheaders.Clear();
        C_httpheaders.Add('Content-Type', 'application/json');

        Clear(ImageBase64Label);
        if C_httpclient.Post(PdfToImgURL, C_httpcontent, C_httpresponseMessage) then begin
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