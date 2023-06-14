codeunit 90090 "DPD Courier"
{
    TableNo = 36;
    trigger OnRun()
    begin
        GenerateGeoSession(Rec);
    end;

    var
        ILWUsername: Text;
        ILWPassword: Text;

        LANUsername: Text;
        LANPassword: Text;
        SHOPIFYUsername: Text;
        SHOPIFYPassword: Text;
        ServiceURL: Text;
        //DPDAccountNo: Text;
        LabelServiceURL: Text;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
        L_InterimSalesHeader: Record "Interim Sales Header";
        G_InterimSalesLine: Record "Interim Sales Line" temporary;
        TrackingNumber: Text;

    local procedure GetCredentials(ChannelCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            ILWUsername := ShippingAgent."Access Key";
            ILWPassword := ShippingAgent."Secret Key";
            ServiceURL := ShippingAgent."API URL";
            SHOPIFYUsername := ShippingAgent."Client Id";
            SHOPIFYPassword := ShippingAgent."Client Secret";
            LANUsername := ShippingAgent."Access Token";
            LANPassword := ShippingAgent."Refresh Token";
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
        TradePartner: Record "Trade Partner";
    begin
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        Clear(auth);
        TradePartner.Reset();
        TradePartner.SetRange(Code, Temp_SalesHeader."Bill-to Customer No.");
        if TradePartner.FindFirst() then begin
            auth := CreateBasicAuth(SHOPIFYUsername, SHOPIFYPassword);
        end;

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
                Clear(GeoSession);
                GeoSession := GetJsonvalue(DataObject, 'geoSession').AsText();
                if GeoSession <> '' then begin
                    CreateShipment(GeoSession, Temp_SalesHeader);
                end;
            end
            else begin
                HttpResponse.Content.ReadAs(responseText);
                //Code to Insert Error log
                if Temp_SalesHeader.FindFirst() then begin
                    L_InterimSalesHeader.Reset();
                    L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                    L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                    if L_InterimSalesHeader.FindFirst() then begin
                        CU_WebOrderMgmt.InsertErrorLog(responseText, L_InterimSalesHeader);
                    end;
                end;
            end;
        end
        else begin
            HttpResponse.Content.ReadAs(responseText);
            //Code to Insert Error log
            if Temp_SalesHeader.FindFirst() then begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                if L_InterimSalesHeader.FindFirst() then begin
                    CU_WebOrderMgmt.InsertErrorLog(responseText, L_InterimSalesHeader);
                end;
            end;
        end;
    end;


    procedure CreateShipment(GeoSession: Text; var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        EnvInformation: Codeunit "Environment Information";
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
        Error1: Text;
        ErroMessage: Text;
        ErrorArray: JsonArray;
        L_Interimsalesheader: Record "Interim Sales Header";
        i: Integer;
        j: Integer;
        noOfResult: Integer;
        NoofRecs: Integer;
        orderToken: JsonToken;
        orderHeaderObject: JsonObject;
        ShipmentID: Text;
        NumberofParcels: Integer;
        CustomsValue: Text;
        ParcelProduct: Text;
        ShippingRule: Record "Shipping Rule";
        InternationalPostCode: Text;
        CompanyInfo: Record "Company Information";
        HandledInterimHeader: Record "Handled Interim Sales Header";
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        //DPDAccountNo := '100201';
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        ServiceURL := ServiceURL + '/shipping/shipment';

        CustomsValue := 'null';
        //if Temp_SalesHeader."Ship-to Country/Region Code" <> 'GB' then
        CustomsValue := Format(Temp_SalesHeader."VAT Base Discount %");
        if CustomsValue.Contains(',') then
            CustomsValue := CustomsValue.Replace(',', '');

        location.Reset();
        if location.Get(Temp_SalesHeader."Location Code") then;

        if CompanyInfo.Get() then;

        if Temp_SalesHeader."Shipment Date" < Today then
            CollectionDate := Format(Today, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00')
        else
            CollectionDate := Format(Temp_SalesHeader."Shipment Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

        if ((Temp_SalesHeader."Ship-to Address" <> '') and (Temp_SalesHeader."Ship-to Country/Region Code" <> '') and (Temp_SalesHeader."Ship-to City" <> '') and
         (Temp_SalesHeader."Shipping Agent Service Code" <> '') and (Temp_SalesHeader."Ship-to Name" <> '')) then begin

            // Clear(NumberofParcels);
            // NumberofParcels := 0;
            // if Temp_SalesHeader."Currency Factor" <> 0 then begin
            //     ShippingRule.Reset();
            //     ShippingRule.SetRange("Shipping Agent", Temp_SalesHeader."Shipping Agent Code");
            //     ShippingRule.SetRange("Shipping Agent Service", Temp_SalesHeader."Shipping Agent Service Code");
            //     if ShippingRule.FindFirst() then begin
            //         NumberofParcels := Round(Temp_SalesHeader."Currency Factor" / ShippingRule.Weight, 1, '>');
            //     end;
            // end;

            //Bug 12674++
            if Temp_SalesHeader."Ship-to Address" = Temp_SalesHeader."Ship-to Address 2" then
                Temp_SalesHeader."Ship-to Address 2" := '';
            //Bug 12674--

            if Temp_SalesHeader."Ship-to Country/Region Code" <> 'GB' then begin
                Clear(ParcelProduct);
                ParcelProduct := GetParcels(Temp_SalesHeader, Temp_SalesHeader."No. Printed");

                if ParcelProduct <> '' then begin
                    Clear(InternationalPostCode);
                    if Temp_SalesHeader."Ship-to Post Code" <> '' then begin

                        if Temp_SalesHeader."Ship-to Country/Region Code" = 'US' then begin   //United States
                            InternationalPostCode := Temp_SalesHeader."Ship-to Post Code";
                            if InternationalPostCode.Contains('-') then begin
                                IF (STRPOS(Temp_SalesHeader."Ship-to Post Code", '-')) > 0 then begin
                                    InternationalPostCode := COPYSTR(Temp_SalesHeader."Ship-to Post Code", 1, (STRPOS(Temp_SalesHeader."Ship-to Post Code", '-') - 1));
                                end;
                            end;
                        end;

                        if Temp_SalesHeader."Ship-to Country/Region Code" = 'CA' then begin  //Canada
                            InternationalPostCode := Temp_SalesHeader."Ship-to Post Code";
                            if InternationalPostCode.Contains(' ') then
                                InternationalPostCode := InternationalPostCode.Replace(' ', '');
                        end;

                        if Temp_SalesHeader."Ship-to Country/Region Code" = 'PL' then begin  //Poland
                            InternationalPostCode := Temp_SalesHeader."Ship-to Post Code";
                            if InternationalPostCode.Contains('-') then
                                InternationalPostCode := InternationalPostCode.Replace('-', '');
                        end;

                        if Temp_SalesHeader."Ship-to Country/Region Code" = 'NL' then begin  //Netherlands
                            InternationalPostCode := Temp_SalesHeader."Ship-to Post Code";
                            if InternationalPostCode.Contains(' ') then
                                InternationalPostCode := InternationalPostCode.Replace(' ', '');
                        end;

                        if Temp_SalesHeader."Ship-to Country/Region Code" = 'SE' then begin  //Sweden
                            InternationalPostCode := Temp_SalesHeader."Ship-to Post Code";
                            if InternationalPostCode.Contains(' ') then
                                InternationalPostCode := InternationalPostCode.Replace(' ', '');
                        end;

                        if ((Temp_SalesHeader."Ship-to Country/Region Code" <> 'US') and (Temp_SalesHeader."Ship-to Country/Region Code" <> 'CA') and (Temp_SalesHeader."Ship-to Country/Region Code" <> 'PL')
                        and (Temp_SalesHeader."Ship-to Country/Region Code" <> 'NL') and (Temp_SalesHeader."Ship-to Country/Region Code" <> 'SE') and (Temp_SalesHeader."Ship-to Country/Region Code" <> 'GB')) then begin
                            InternationalPostCode := Temp_SalesHeader."Ship-to Post Code";
                        end;
                    end;

                    if EnvInformation.IsSandbox() then begin
                        //Test Request++
                        TextRequest := StrSubstNo('{"jobId": null,"collectionOnDelivery": false,"generateCustomsData": "Y",' +
                        '"invoice": {"invoiceExportReason": "01","invoiceTermsOfDelivery": "DAP","invoiceType": 1,' +
                        '"invoiceShipperDetails": {"address": {"organisation": "%1","countryCode": "%2","postcode": "%3",' +
                        '"street": "%4","town": "%5"},"eoriNumber": "GB721821949000"},' +
                        '"invoiceDeliveryDetails": {"valueAddedTaxNumber": "","eoriNumber": "",' +
                        '"pidNumber": ""}},"collectionDate": "%6","consolidate": false,"consignment": [{' +
                        '"consignmentNumber": "%7","consignmentRef": null,"parcel": [%8],' +
                        '"collectionDetails": {"address": {"organisation": "%9","countryCode": "%10","postcode": "%11","street": "%12",' +
                        '"town": "%13"}},"deliveryDetails": {"contactDetails": {"contactName": "%14","telephone": "1234"' +
                        '},"address": {"organisation": "%15","countryCode": "%16","postcode": "%17","street": "%18",' +
                        '"locality": "%25","town": "%19"},"notificationDetails": {"email": "test@gmail.com","mobile": "1234"}},"networkCode": "%20",' +
                        '"numberOfParcels":%21,"totalWeight": %22,"customsValue": %23,"shippingRef1": "%24",' +
                        '"liabilityValue": null,"parcelDescription": "Wallpaper for Decorative Purposes","liability": false,"shippersDestinationTaxId": "IM3720008430","vatPaid": "Y"}]}',
                        CopyStr(CompanyInfo.Name, 1, 35), CompanyInfo."Country/Region Code", CompanyInfo."Post Code",
                        CopyStr(CompanyInfo.Address, 1, 35), CompanyInfo.City, CollectionDate, Temp_SalesHeader."Applies-to ID",
                        ParcelProduct, CopyStr(CompanyInfo.Name, 1, 35), CompanyInfo."Country/Region Code",
                        CompanyInfo."Post Code", CopyStr(CompanyInfo.Address, 1, 35), CompanyInfo.City,
                        CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Ship-to Country/Region Code",
                        InternationalPostCode, CopyStr(Temp_SalesHeader."Ship-to Address", 1, 35), Temp_SalesHeader."Ship-to City",
                        Temp_SalesHeader."Shipping Agent Service Code", Temp_SalesHeader."No. Printed", Temp_SalesHeader."Currency Factor", CustomsValue, Temp_SalesHeader."Applies-to ID",
                        CopyStr(Temp_SalesHeader."Ship-to Address 2", 1, 35));
                        //Test Request--
                    end
                    else begin
                        //Live Request++
                        TextRequest := StrSubstNo('{"jobId": null,"collectionOnDelivery": false,"generateCustomsData": "Y",' +
                        '"invoice": {"invoiceExportReason": "01","invoiceTermsOfDelivery": "DAP","invoiceType": 1,' +
                        '"invoiceShipperDetails": {"address": {"organisation": "%1","countryCode": "%2","postcode": "%3",' +
                        '"street": "%4","town": "%5"},"eoriNumber": "GB721821949000"},' +
                        '"invoiceDeliveryDetails": {"valueAddedTaxNumber": "","eoriNumber": "",' +
                        '"pidNumber": ""}},"collectionDate": "%6","consolidate": false,"consignment": [{' +
                        '"consignmentNumber": "%7","consignmentRef": null,"parcel": [%8],' +
                        '"collectionDetails": {"address": {"organisation": "%9","countryCode": "%10","postcode": "%11","street": "%12",' +
                        '"town": "%13"}},"deliveryDetails": {"contactDetails": {"contactName": "%14","telephone": "%15"' +
                        '},"address": {"organisation": "%16","countryCode": "%17","postcode": "%18","street": "%19",' +
                        '"locality": "%28","town": "%20"},"notificationDetails": {"email": "%21","mobile": "%22"}},"networkCode": "%23",' +
                        '"numberOfParcels":%24,"totalWeight": %25,"customsValue": %26,"shippingRef1": "%27","liabilityValue": null,"parcelDescription": "Wallpaper for Decorative Purposes","liability": false,"shippersDestinationTaxId": "IM3720008430","vatPaid": "Y"}]}',
                        CopyStr(CompanyInfo.Name, 1, 35), CompanyInfo."Country/Region Code", CompanyInfo."Post Code",
                        CopyStr(CompanyInfo.Address, 1, 35), CompanyInfo.City, CollectionDate, Temp_SalesHeader."Applies-to ID",
                        ParcelProduct, CopyStr(CompanyInfo.Name, 1, 35), CompanyInfo."Country/Region Code",
                        CompanyInfo."Post Code", CopyStr(CompanyInfo.Address, 1, 35), CompanyInfo.City,
                        CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Sell-to Phone No.", CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Ship-to Country/Region Code",
                        InternationalPostCode, CopyStr(Temp_SalesHeader."Ship-to Address", 1, 35), Temp_SalesHeader."Ship-to City",
                        Temp_SalesHeader."Sell-to E-Mail", Temp_SalesHeader."Sell-to Phone No.", Temp_SalesHeader."Shipping Agent Service Code",
                        Temp_SalesHeader."No. Printed", Temp_SalesHeader."Currency Factor", CustomsValue, Temp_SalesHeader."Applies-to ID",
                        CopyStr(Temp_SalesHeader."Ship-to Address 2", 1, 35));
                        //Live Request--
                    end;
                end;
            end
            else begin
                if EnvInformation.IsSandbox() then begin
                    //Test Request++
                    TextRequest := StrSubstNo('{"jobId":null,"collectionOnDelivery":false,"invoice":null,"collectionDate":"%1",' +
                                                '"consolidate":false,"consignment":[{"consignmentNumber":"' + Temp_SalesHeader."Applies-to ID" + '","consignmentRef":null,"parcel":[],' +
                                                '"collectionDetails":{"contactDetails":{"contactName":"%2","telephone":"12334"},"address":{"organisation":"%3","countryCode":"%4","postcode":"%5","street":"%6","town":"%7","county":"%8"}},' +
                                                '"deliveryDetails":{"contactDetails":{"contactName":"%9","telephone":"12334"},"address":{"organisation":"%10","countryCode":"%11","postcode":"%12","street":"%13","locality": "%21","town":"%14","county":"%15"},' +
                                                '"notificationDetails":{"email":"test@gmail.com","mobile":"12334"}},"networkCode":"%16","numberOfParcels":%17,"totalWeight":%18,"customsValue": %19,"shippingRef1": "%20","liabilityValue":null,"liability":false}]}',
                                                CollectionDate, CopyStr(CompanyInfo."Contact Name", 1, 35), CopyStr(CompanyInfo.Name, 1, 35), CompanyInfo."Country/Region Code", CompanyInfo."Post Code",
                                                CopyStr(CompanyInfo.Address, 1, 35), CompanyInfo.City, CompanyInfo.County,
                                                CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Ship-to Country/Region Code",
                                                Temp_SalesHeader."Ship-to Post Code", CopyStr(Temp_SalesHeader."Ship-to Address", 1, 35), Temp_SalesHeader."Ship-to City", Temp_SalesHeader."Ship-to County",
                                                 Temp_SalesHeader."Shipping Agent Service Code", Temp_SalesHeader."No. Printed", Temp_SalesHeader."Currency Factor", CustomsValue, Temp_SalesHeader."Applies-to ID", CopyStr(Temp_SalesHeader."Ship-to Address 2", 1, 35));
                    //Test Request--
                end
                else begin
                    //Live Request++
                    TextRequest := StrSubstNo('{"jobId":null,"collectionOnDelivery":false,"invoice":null,"collectionDate":"%1",' +
                                '"consolidate":false,"consignment":[{"consignmentNumber":"' + Temp_SalesHeader."Applies-to ID" + '","consignmentRef":null,"parcel":[],' +
                                '"collectionDetails":{"contactDetails":{"contactName":"%2","telephone":"%3"},"address":{"organisation":"%4","countryCode":"%5","postcode":"%6","street":"%7","town":"%8","county":"%9"}},' +
                                '"deliveryDetails":{"contactDetails":{"contactName":"%10","telephone":"%11"},"address":{"organisation":"%12","countryCode":"%13","postcode":"%14","street":"%15","locality": "%25","town":"%16","county":"%17"},' +
                                '"notificationDetails":{"email":"%18","mobile":"%19"}},"networkCode":"%20","numberOfParcels":%21,"totalWeight":%22,"customsValue": %23,"shippingRef1": "%24","liabilityValue":null,"liability":false}]}',
                                CollectionDate, CopyStr(CompanyInfo."Contact Name", 1, 35), CompanyInfo."Phone No.", CopyStr(CompanyInfo.Name, 1, 35), CompanyInfo."Country/Region Code", CompanyInfo."Post Code",
                                CopyStr(CompanyInfo.Address, 1, 35), CompanyInfo.City, CompanyInfo.County,
                                CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Sell-to Phone No.", CopyStr(Temp_SalesHeader."Ship-to Name", 1, 35), Temp_SalesHeader."Ship-to Country/Region Code",
                                Temp_SalesHeader."Ship-to Post Code", CopyStr(Temp_SalesHeader."Ship-to Address", 1, 35), Temp_SalesHeader."Ship-to City", Temp_SalesHeader."Ship-to County",
                                Temp_SalesHeader."Sell-to E-Mail", Temp_SalesHeader."Sell-to Phone No.", Temp_SalesHeader."Shipping Agent Service Code", Temp_SalesHeader."No. Printed", Temp_SalesHeader."Currency Factor", CustomsValue, Temp_SalesHeader."Applies-to ID", CopyStr(Temp_SalesHeader."Ship-to Address 2", 1, 35));
                    //Live Request--
                end;
            end;

            if TextRequest <> '' then begin
                //Message(TextRequest);
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
                                Clear(Error1);
                                Error1 := GetJsonvalue(orderHeaderObject, 'obj').AsText();
                                if Temp_SalesHeader.FindFirst() then;
                                L_Interimsalesheader.Reset();
                                L_Interimsalesheader.SetRange("No.", Temp_SalesHeader."No.");
                                if L_Interimsalesheader.FindFirst() then begin
                                    if Error1 <> '' then begin
                                        CU_WebOrderMgmt.InsertErrorLog(Error1, L_InterimSalesHeader);
                                    end
                                    else begin
                                        CU_WebOrderMgmt.InsertErrorLog(Error, L_InterimSalesHeader);
                                    end;
                                    L_Interimsalesheader.Remarks := CopyStr(Error, 1, 250);
                                    L_Interimsalesheader.Modify();
                                end;
                            end;
                        end
                        else begin
                            ShipmentID := UpdateShipmentHeader(jObject, Temp_SalesHeader);
                            if Temp_SalesHeader.FindFirst() then;
                            L_Interimsalesheader.Reset();
                            L_Interimsalesheader.SetRange("No.", Temp_SalesHeader."No.");
                            if L_Interimsalesheader.FindFirst() then
                                GetDPDLabel(ShipmentID, Temp_SalesHeader, GeoSession, ServiceURL, Temp_SalesHeader."No. Printed")
                            else begin
                                HandledInterimHeader.Reset();
                                HandledInterimHeader.SetRange("No.", Temp_SalesHeader."No.");
                                if HandledInterimHeader.FindFirst() then
                                    GetDPDLabel(ShipmentID, Temp_SalesHeader, GeoSession, ServiceURL, Temp_SalesHeader."No. Printed")
                            end;
                        end;
                    end
                    else begin
                        Clear(L_response);
                        L_httpresponseMessage.Content.ReadAs(L_response);
                        //Code to Insert Error log
                        if Temp_SalesHeader.FindFirst() then begin
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
                    Clear(L_response);
                    L_httpresponseMessage.Content.ReadAs(L_response);
                    //Code to Insert Error log
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
        end
        else begin
            if Temp_SalesHeader.FindFirst() then begin
                Clear(ErroMessage);
                ErroMessage := 'Please Check if Ship-to Name, Ship-to Address, Ship-to Country/Region, Ship-to City, and Shipping Agent Service Code is Populated or Not on Order ' + Temp_SalesHeader."No.";

                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                L_InterimSalesHeader.SetRange("Document Type", Temp_SalesHeader."Document Type");
                if L_InterimSalesHeader.FindFirst() then begin
                    CU_WebOrderMgmt.InsertErrorLog(ErroMessage, L_InterimSalesHeader);
                end;
            end;
        end;
    end;


    local procedure GetParcels(var P_SalesHeader: Record "Sales Header" temporary; NoofParcels: Integer): Text
    var
        Temp_InterimSalesLine: Record "Interim Sales Line" temporary;
        L_InterimSalesLine1: Record "Interim Sales Line";
        ParcelRequest: Text;
        L_Item: Record Item;
        ItemDescription: Text;
        CountryOfOrigin: Code[10];
        HarmonisedCode: Code[20];
        ProductType: Text;
        ItemCategory: Record "Item Category";
        Counter: Integer;
        TotalItems: Integer;
        ParcelProductRequest: Text;
        ErroMessage: Text;
        LineNoList: List of [Integer];
        i: Integer;
        TotalWeight: Decimal;
        ScannedQuantity: Decimal;
        StartingLines: Boolean;
        ParcelWeight: Array[1000] of Decimal;
        DespatchScanBool: Boolean;
        DespatchScanLine: Record "Warehouse Shipment Line";
        InterimLine: Record "Handled Interim Sales Line";
    begin
        TotalItems := 0;
        Clear(TotalWeight);
        DespatchScanBool := false;

        Temp_InterimSalesLine.DeleteAll();
        if P_SalesHeader.FindFirst() then begin
            L_InterimSalesLine1.Reset();
            L_InterimSalesLine1.SetCurrentKey(Weight);
            L_InterimSalesLine1.SetRange("Document No", P_SalesHeader."No.");
            L_InterimSalesLine1.SetRange(Type, L_InterimSalesLine1.Type::Item);
            L_InterimSalesLine1.SetAscending(Weight, false);
            if L_InterimSalesLine1.FindSet() then begin
                repeat
                    Clear(ScannedQuantity);
                    DespatchScanLine.Reset();
                    DespatchScanLine.SetFilter("Source No.", P_SalesHeader."No.");
                    DespatchScanLine.SetFilter("Item No.", '%1', L_InterimSalesLine1."No.");
                    if DespatchScanLine.FindFirst() then begin
                        DespatchScanBool := true;
                        ScannedQuantity := DespatchScanLine."Scanned Quantity";

                        if ScannedQuantity > 0 then begin
                            for i := 1 to ScannedQuantity do begin
                                TotalItems += 1;
                                Temp_InterimSalesLine.Init();
                                Temp_InterimSalesLine.Type := Temp_InterimSalesLine.Type::Item;
                                Temp_InterimSalesLine."Document Type" := Temp_InterimSalesLine."Document Type"::Order;
                                Temp_InterimSalesLine."Document No" := L_InterimSalesLine1."Document No";
                                Temp_InterimSalesLine."No." := L_InterimSalesLine1."No.";
                                Temp_InterimSalesLine."Line No." := TotalItems * 10000;
                                Temp_InterimSalesLine."Unit Price" := L_InterimSalesLine1."Unit Price";
                                Temp_InterimSalesLine.Quantity := 1;
                                Temp_InterimSalesLine.Weight := L_InterimSalesLine1.Weight;
                                Temp_InterimSalesLine.Description := L_InterimSalesLine1.Description;

                                TotalWeight += L_InterimSalesLine1.Weight;
                                Temp_InterimSalesLine.Insert();
                            end;
                        end;
                    end
                    else begin
                        for i := 1 to L_InterimSalesLine1.Quantity do begin
                            TotalItems += 1;
                            Temp_InterimSalesLine.Init();
                            Temp_InterimSalesLine.Type := Temp_InterimSalesLine.Type::Item;
                            Temp_InterimSalesLine."Document Type" := Temp_InterimSalesLine."Document Type"::Order;
                            Temp_InterimSalesLine."Document No" := L_InterimSalesLine1."Document No";
                            Temp_InterimSalesLine."No." := L_InterimSalesLine1."No.";
                            Temp_InterimSalesLine."Line No." := TotalItems * 10000;
                            Temp_InterimSalesLine."Unit Price" := L_InterimSalesLine1."Unit Price";
                            Temp_InterimSalesLine.Quantity := 1;
                            Temp_InterimSalesLine.Weight := L_InterimSalesLine1.Weight;
                            Temp_InterimSalesLine.Description := L_InterimSalesLine1.Description;

                            TotalWeight += L_InterimSalesLine1.Weight;
                            Temp_InterimSalesLine.Insert();
                        end;
                    end;
                until L_InterimSalesLine1.Next() = 0;
            end else begin
                InterimLine.Reset();
                InterimLine.SetCurrentKey(Weight);
                InterimLine.SetRange("Document No", P_SalesHeader."No.");
                InterimLine.SetRange(Type, InterimLine.Type::Item);
                InterimLine.SetAscending(Weight, false);
                if InterimLine.FindSet() then begin
                    repeat
                        for i := 1 to InterimLine.Quantity do begin
                            TotalItems += 1;
                            Temp_InterimSalesLine.Init();
                            Temp_InterimSalesLine.Type := Temp_InterimSalesLine.Type::Item;
                            Temp_InterimSalesLine."Document Type" := Temp_InterimSalesLine."Document Type"::Order;
                            Temp_InterimSalesLine."Document No" := InterimLine."Document No";
                            Temp_InterimSalesLine."No." := InterimLine."No.";
                            Temp_InterimSalesLine."Line No." := TotalItems * 10000;
                            Temp_InterimSalesLine."Unit Price" := InterimLine."Unit Price";
                            Temp_InterimSalesLine.Quantity := 1;
                            Temp_InterimSalesLine.Weight := InterimLine.Weight;
                            Temp_InterimSalesLine.Description := InterimLine.Description;

                            TotalWeight += InterimLine.Weight;
                            Temp_InterimSalesLine.Insert();
                        end;
                    until InterimLine.Next() = 0;
                end;
            end;
        end;

        if TotalItems >= NoOfParcels then begin
            Clear(ParcelRequest);

            Counter := 1;
            //Loop to Add Parcel Numbers on Initial Lines
            if Temp_InterimSalesLine.FindSet() then begin
                repeat
                    if Counter <= NoofParcels then begin
                        ParcelWeight[Counter] := Temp_InterimSalesLine.Weight;
                        //Message(StrSubstNo('No. - %1 and Parcel No. - %2', Temp_InterimSalesLine."No.", Counter));
                        Temp_InterimSalesLine."Destination Doc. Line No" := Counter;
                        Temp_InterimSalesLine.Modify();
                    end;
                    Counter += 1;
                until Temp_InterimSalesLine.Next() = 0;
            end;

            if Temp_InterimSalesLine.FindSet() then begin
                repeat
                    if Temp_InterimSalesLine."Destination Doc. Line No" = 0 then begin
                        for Counter := 1 to NoofParcels do begin
                            if Temp_InterimSalesLine.Weight + ParcelWeight[Counter] <= 30 then begin
                                ParcelWeight[Counter] += Temp_InterimSalesLine.Weight;
                                //Message(StrSubstNo('No. - %1 and Parcel No. - %2', Temp_InterimSalesLine."No.", Counter));
                                Temp_InterimSalesLine."Destination Doc. Line No" := Counter;
                                Temp_InterimSalesLine.Modify();
                                break;
                            end;
                        end;
                    end;
                until Temp_InterimSalesLine.Next() = 0;
            end;

            for Counter := 1 to NoOfParcels do begin
                Clear(ParcelProductRequest);
                ParcelProductRequest := GenerateParcelProductRequest(Temp_InterimSalesLine, Counter);

                ParcelRequest += StrSubstNo('{"packageNumber": %1,"parcelProduct": [%2]},', Counter, ParcelProductRequest);
                TotalItems := TotalItems - 1;
            end;
        end
        else begin
            if P_SalesHeader.FindFirst() then begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", P_SalesHeader."No.");
                L_InterimSalesHeader.SetRange("Document Type", P_SalesHeader."Document Type");
                if L_InterimSalesHeader.FindFirst() then begin
                    if DespatchScanBool = true then begin
                        CU_WebOrderMgmt.InsertErrorLog('Total Scanned Quantity is less than No. of Parcel.', L_InterimSalesHeader);
                    end
                    else begin
                        CU_WebOrderMgmt.InsertErrorLog('Total Order Quantity is less than No. of Parcel.', L_InterimSalesHeader);
                    end;
                end;
            end;
            if DespatchScanBool = true then begin
                Error('Total Scanned Quantity is less than No. of Parcel.');
            end
            else begin
                Error('Total Order Quantity is less than No. of Parcel.');
            end;
        end;

        ParcelRequest := ParcelRequest.TrimEnd(',');
        //Message(ParcelRequest);
        exit(ParcelRequest);
    end;


    local procedure GenerateParcelProductRequest(var Temp_InterimSalesLine: Record "Interim Sales Line" temporary; P_Counter: Integer): Text
    var
        ParcelProductRequest: Text;
        CountryOfOrigin: Code[10];
        HarmonisedCode: Code[20];
        ProductType: Text;
        ItemDescription: Text;
        L_Item: Record Item;
        RecCount: Integer;
        ItemCategory: Record "Item Category";
    begin
        Clear(ParcelProductRequest);
        Temp_InterimSalesLine.Reset();
        Temp_InterimSalesLine.SetFilter("Destination Doc. Line No", '%1', P_Counter);
        if Temp_InterimSalesLine.FindSet() then begin
            repeat
                Clear(ItemDescription);
                ItemDescription := Temp_InterimSalesLine.Description;

                Clear(CountryOfOrigin);
                Clear(HarmonisedCode);
                Clear(ProductType);
                L_Item.Reset();
                L_Item.SetRange("No.", Temp_InterimSalesLine."No.");
                if L_Item.FindFirst() then begin
                    CountryOfOrigin := L_Item."Country/Region of Origin Code";
                    HarmonisedCode := L_Item."Tariff No.";

                    if L_Item."Item Category Code" <> '' then begin
                        ItemCategory.Reset();
                        ItemCategory.SetRange(Code, L_Item."Item Category Code");
                        if ItemCategory.FindFirst() then begin
                            if ItemCategory.Description <> '' then begin
                                ProductType := ItemCategory.Description;
                            end
                            else begin
                                ProductType := ItemCategory.Code;
                            end;
                        end;
                    end;
                end;

                ParcelProductRequest += StrSubstNo('{"productCode": "%1","productTypeDescription": "%2","productItemsDescription": "%3","countryOfOrigin": "%4","productHarmonisedCode": "%5",' +
                                            '"unitWeight": %6,"numberOfItems": %7,"unitValue": %8},', Temp_InterimSalesLine."No.", ProductType, ItemDescription, CountryOfOrigin, HarmonisedCode, Temp_InterimSalesLine.Weight, Temp_InterimSalesLine.Quantity, Temp_InterimSalesLine."Unit Price");

            until Temp_InterimSalesLine.Next() = 0;

            ParcelProductRequest := ParcelProductRequest.TrimEnd(',');
            exit(ParcelProductRequest);
        end;
    end;


    procedure UpdateShipmentHeader(responseObject: JsonObject; var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        responseData: JsonObject;
        consignmentData: JsonObject;
        parcelData: JsonArray;
        PackageToken: JsonToken;
        packageobj: JsonObject;
        ShipmentId: Text;
        L_InterimSalesHeader: Record "Interim Sales Header";
        InterimHeader: Record "Handled Interim Sales Header";
        i: Integer;
        ConsignmentDetailsArray: JsonArray;
        ConsignmentDetailsToken: JsonToken;
        ConsignmentDetailsObject: JsonObject;
    begin
        responseData := GetJsonToken(responseObject, 'data').AsObject();
        Clear(ShipmentId);
        ShipmentId := GetJsonvalue(responseData, 'shipmentId').AsText();

        ConsignmentDetailsArray := GetJsonToken(responseData, 'consignmentDetail').AsArray();
        if ConsignmentDetailsArray.Count > 0 then begin
            ConsignmentDetailsArray.Get(0, ConsignmentDetailsToken);
            ConsignmentDetailsObject := ConsignmentDetailsToken.AsObject();

            Clear(TrackingNumber);
            TrackingNumber := GetJsonvalue(ConsignmentDetailsObject, 'consignmentNumber').AsText();
            if TrackingNumber <> '' then begin
                if Temp_SalesHeader.FindFirst() then;
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."Applies-to Doc. No.");
                if L_InterimSalesHeader.FindFirst() then begin
                    L_InterimSalesHeader.Validate("Package Tracking No.", TrackingNumber);
                    L_InterimSalesHeader.Remarks := '';
                    L_InterimSalesHeader.Modify();
                end else begin
                    InterimHeader.Reset();
                    InterimHeader.SetRange("No.", Temp_SalesHeader."Applies-to Doc. No.");
                    if InterimHeader.FindFirst() then begin
                        InterimHeader.Validate("Package Tracking No.", TrackingNumber);
                        InterimHeader.Remarks := '';
                        InterimHeader.Modify();
                    end;
                end;
            end;
        end;

        exit(ShipmentId);
    end;

    procedure GetDPDLables(TrackingNo: Text; var Temp_salesheader: Record "Sales Header" temporary; GeoSession: text; SURL: Text; DPDAcctno: Text; P_NumberofParcels: Integer)
    var
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpresponseMessage: HttpResponseMessage;
        L_response: Text;
        jObject: JsonObject;
        LabelImageArray: JsonArray;
        i: Integer;
        LabelImageToken: JsonToken;
        URL: Text;
        Base64StringLabel: Text;
        CU_ShipmentTrackingInsertion: Codeunit "Shipment Tracking Insertion";
    begin
        ClearAll();
        GetCredentials(Temp_salesheader."Shipping Agent Code");
        L_httpheaders := L_httpclient.DefaultRequestHeaders;

        if P_NumberofParcels = 1 then begin
            ServiceURL := LabelServiceURL + 'GetLabels?shipmentid=' + TrackingNo + '&url=' + SURL + '&dpdaccountno=' + DPDAcctno + '&geosession=' + GeoSession;
        end;

        if (P_NumberofParcels > 1) then begin
            ServiceURL := LabelServiceURL + 'GetDPDLabels?shipmentid=' + TrackingNo + '&url=' + SURL + '&dpdaccountno=' + DPDAcctno + '&geosession=' + GeoSession + '&numberofparcel=' + Format(P_NumberofParcels);
        end;

        L_httpheaders.Add('Accept', 'application/json');
        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        if L_httpclient.Get(ServiceURL, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                jObject.ReadFrom(L_response);

                if P_NumberofParcels = 1 then begin
                    Clear(Base64StringLabel);
                    Base64StringLabel := GetJsonvalue(jObject, 'LabelImageBase64').AsText();
                    if Base64StringLabel <> 'null' then begin
                        //Generic Shipment Tracking Insertion Code
                        CU_ShipmentTrackingInsertion.InsertShipmentTracking(TrackingNo, Base64StringLabel, '', '', '', Temp_salesheader);
                    end;
                end;

                if (P_NumberofParcels > 1) then begin
                    LabelImageArray := GetJsonToken(jObject, 'LabelImageBase64').AsArray();
                    for i := 0 to LabelImageArray.Count - 1 do begin
                        Clear(LabelImageToken);
                        Clear(Base64StringLabel);
                        LabelImageArray.Get(i, LabelImageToken);
                        Base64StringLabel := Format(LabelImageToken);
                        if Base64StringLabel <> '' then begin
                            if Base64StringLabel.Contains('"') then begin
                                Base64StringLabel := Base64StringLabel.Replace('"', '');
                            end;
                            CU_ShipmentTrackingInsertion.InsertShipmentTracking(TrackingNo, Base64StringLabel, '', '', '', Temp_salesheader);
                        end;
                    end;
                end;
            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                //Code to Insert Error log
                if Temp_SalesHeader.FindFirst() then begin
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
            //Code to Insert Error log
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


    local procedure GetDPDLabel(ShipmentId: Text; var Temp_salesheader: Record "Sales Header" temporary; GeoSession: text; SURL: Text; P_NumberofParcels: Integer)
    var
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpresponseMessage: HttpResponseMessage;
        L_response: Text;
        URL: Text;
        L_ShipmentTrack: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
        OutStm: OutStream;
        InStm: InStream;
        ReadInStream: Text;
        Base64: Codeunit "Base64 Convert";
        Base64Label: Text;
    begin
        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        //L_httpheaders.Add('Accept', 'text/html');
        L_httpheaders.Add('Accept', 'text/vnd.eltron-epl');
        //L_httpheaders.Add('Accept', 'text/vnd.citizen-clp');
        L_httpheaders.Add('GEOSession', GeoSession);
        L_httpcontent.GetHeaders(L_httpheaders);
        //L_httpheaders.Clear();

        URL := StrSubstNo('https://api.dpd.co.uk/shipping/shipment/%1/label/', ShipmentId);

        if L_httpclient.Get(URL, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);

                L_ShipmentTrack.Init();
                L_ShipmentTrack.VALIDATE("Document Type", L_ShipmentTrack."Document Type"::Order);
                if Temp_SalesHeader.FindFirst() then;
                L_ShipmentTrack.Validate("Document No.", Temp_SalesHeader."No.");
                L_ShipmentTrack.Validate("Shipping Agent Code", Temp_SalesHeader."Shipping Agent Code");
                L_ShipmentTrack.VALIDATE("Shipping Agent Service Code", Temp_SalesHeader."Shipping Agent Service Code");
                L_ShipmentTrack.Validate("Entry Created", Today);

                IF RecShipmentTracking.FINDLAST THEN
                    L_ShipmentTrack."Entry No." := RecShipmentTracking."Entry No." + 1
                ELSE
                    L_ShipmentTrack."Entry No." := 1;

                L_ShipmentTrack.VALIDATE("Tracking No.", TrackingNumber);
                L_ShipmentTrack.Validate("Agent Shipment No.", ShipmentId);

                IF (L_response <> '') THEN BEGIN
                    // Message(L_response);
                    Clear(Base64Label);
                    Base64Label := Base64.ToBase64(L_response);
                    //Message(Base64Label);

                    L_ShipmentTrack.CalcFields(Label);
                    L_ShipmentTrack.Label.CreateOutStream(OutStm);
                    OutStm.WriteText(Base64Label);

                    // L_ShipmentTrack.Label.CreateInStream(InStm);
                    // InStm.ReadText(ReadInStream);

                    // Clear(Base64Label);
                    // Base64Label := Base64.FromBase64(ReadInStream);

                    //L_ShipmentTrack.Validate("RAW Text", L_response);
                END;

                L_ShipmentTrack.INSERT;
            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                Error('Status Code - ' + Format(L_httpresponseMessage.HttpStatusCode) + ' Error Message - ' + L_response);
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