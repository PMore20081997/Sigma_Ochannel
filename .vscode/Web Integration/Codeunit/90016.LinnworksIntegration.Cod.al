codeunit 90016 "Linnworks Integration"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF
            SyncOrderLabel:
                BEGIN
                    GetOpenOrders(StartParameter);
                End;
        end;
    end;

    var
        ApplicationId: Text;
        ApplicationSecret: Text;
        G_Token: Text;
        serviceURL: Text;
        Datefrom: Text;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        DateTo: Text;
        Source: Text;
        fulfilmentCenter: Text;


    //Procedure to get the Credentials from Trade Partner for Particular Channel Code
    procedure GetCredentials("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            ApplicationId := tradePartner.AccessKeyId;
            ApplicationSecret := tradePartner.SecretAccessKey;
            G_Token := TradePartner.MerchantId;
            serviceURL := TradePartner."Sevice/API URL";
            Datefrom := Format(tradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2> <Hours12,2>:<Minutes,2>:<Seconds,2>');
            DateTo := format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');
            Source := TradePartner.Name;
            fulfilmentCenter := TradePartner.MarketplaceId;
        end;
    End;


    //Procedure to Retrieve Token
    procedure GetToken(ChannelCode: Code[10]): Text
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        jObject: JsonObject;
        Token: Text;
        L_Body: Text;
    begin
        Clear(L_Body);
        Clear(client);
        Clear(content);
        Clear(headers);
        Clear(responseMessage);
        Clear(response);
        headers := Client.DefaultRequestHeaders();
        L_Body := '{"ApplicationId":' + '"' + ApplicationId + '"' + ',"ApplicationSecret":' + '"' + ApplicationSecret + '"' + ',"Token":' + '"' + G_Token + '"' + '}';
        content.WriteFrom(L_Body);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');

        URL := 'https://api.linnworks.net/api/Auth/AuthorizeByApplication';

        if client.Post(URL, content, responseMessage) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            Token := GetJsonvalue(jObject, 'Token').AsText();
            exit(Token);
        end
        else begin
            Message('No Token Getting From Linnwork');
        end;

    end;


    //Procedure to Retrieve Orders
    procedure GetOpenOrders(ChannelCode: Code[10])
    var
        L_client: HttpClient;
        L_headers: HttpHeaders;
        L_responseMessage: HttpResponseMessage;
        L_content: HttpContent;
        L_URL: Text;
        L_response: Text;
        Token: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        orderToken: JsonToken;
        orderObject: JsonObject;
        i: Integer;
        noOfRecords: Integer;
        ChannelOrderId: Text;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        ArrayText: Text;
    begin
        Clear(ArrayText);
        GetCredentials(ChannelCode);
        Clear(L_client);
        Clear(L_content);
        Clear(L_headers);
        Clear(L_response);
        Clear(L_responseMessage);
        Clear(L_URL);
        L_headers := L_Client.DefaultRequestHeaders();
        Token := GetToken(ChannelCode);
        L_headers.Add(StrSubstNo('Authorization', '%1'), Token);
        ArrayText := StrSubstNo('{"entriesPerPage":100, "pageNumber":1,"filters":{"DateFields":[{"FieldCode":"GENERAL_INFO_DATE","Type":"Range","DateFrom":"%1","DateTo":"%2"}],"TextFields":[{"FieldCode":"GENERAL_INFO_SOURCE" ,"Text":"%3","Type": "Equal"}]},"sorting":[],"fulfilmentCenter": "%4"}', Datefrom, DateTo, Source, fulfilmentCenter);
        L_content.WriteFrom(ArrayText);

        L_content.GetHeaders(L_headers);
        L_headers.Remove('Content-Type');
        L_headers.Add('Content-Type', 'application/json');

        L_URL := serviceURL + 'Orders/GetOpenOrders';

        if L_client.Post(L_URL, L_content, L_responseMessage) then begin

            if L_responseMessage.HttpStatusCode = 200 then begin

                L_responseMessage.Content.ReadAs(L_response);
                jObject.ReadFrom(L_response);

                jArray := GetJsonToken(jObject, 'Data').AsArray();
                noOfRecords := jArray.Count;

                for i := 0 to noOfRecords - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();
                    jArray.Get(i, orderToken);
                    orderObject := orderToken.AsObject();

                    ChannelOrderId := GetJsonvalue(orderObject, 'NumOrderId').AsText();

                    InsertInSalesHeader(orderObject, ChannelOrderId, ChannelCode, InterimSalesHeader);
                    InsertInSalesLine(InterimSalesHeader, orderObject, InterimSalesLine);

                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                end;

            end;

        end;

        MESSAGE('Order Sync Completed...');

    end;
    //Procedure to Insert Order Header Data in Interim Sales Header Table
    procedure InsertInSalesHeader(Orderheaders: JsonObject; var ChannelOrderId: Text; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        orderDate: Text;
        HeaderObject: JsonObject;
        ShipHeader: JsonObject;
        PaymentHeader: JsonObject;
        CustomerInfo: JsonObject;
        Address: JsonObject;
        CountryCode: Code[20];
        paymethod: Text[50];
        L_TradePartner: Record "Trade Partner";
    begin
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."No." := ChannelOrderId;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        L_TradePartner.Get(ChannelCode);
        InterimSalesHeader."Sell-to Customer No." := L_TradePartner."Customer No.";
        InterimSalesHeader."Location Code" := L_TradePartner.Location;

        HeaderObject := GetJsonToken(Orderheaders, 'GeneralInfo').AsObject();
        ShipHeader := GetJsonToken(Orderheaders, 'ShippingInfo').AsObject();
        PaymentHeader := GetJsonToken(Orderheaders, 'TotalsInfo').AsObject();
        CustomerInfo := GetJsonToken(Orderheaders, 'CustomerInfo').AsObject();
        Address := GetJsonToken(CustomerInfo, 'Address').AsObject();

        InterimSalesHeader."Order Date" := Today;
        if GetJsonvalue(HeaderObject, 'ExternalReferenceNum').IsNull = false then begin
            InterimSalesHeader.Validate("External Document No.", CopyStr(GetJsonvalue(HeaderObject, 'ExternalReferenceNum').AsCode(), 1, 20));  //  NumOrderId
            InterimSalesHeader."External Document No." := CopyStr(GetJsonToken(HeaderObject, 'ExternalReferenceNum').AsValue().AsCode(), 1, 20); // NumOrderId
        End;
        if GetJsonvalue(HeaderObject, 'ReceivedDate').IsNull = false then begin
            InterimSalesHeader.Validate("Order Placed At", GetJsonvalue(HeaderObject, 'ReceivedDate').AsDateTime());
            InterimSalesHeader."Order Placed At" := GetJsonToken(HeaderObject, 'ReceivedDate').AsValue().AsDateTime();
            InterimSalesHeader."Document Date" := DT2Date(GetJsonToken(HeaderObject, 'ReceivedDate').AsValue().AsDateTime());
        end;
        /*if GetJsonvalue(ShipHeader, 'Vendor').IsNull = false then begin
            InterimSalesHeader.VALIDATE("Shipping Agent Code", CopyStr(GetJsonvalue(ShipHeader, 'Vendor').AsCode(), 1, 10));
            InterimSalesHeader."Shipping Agent Code" := CopyStr(GetJsonToken(ShipHeader, 'Vendor').AsValue.AsCode(), 1, 10);
        end;*/
        if GetJsonvalue(ShipHeader, 'PostalServiceName').IsNull = false then begin
            InterimSalesHeader.VALIDATE("Web Shipment Method", GetJsonvalue(ShipHeader, 'PostalServiceName').AsCode);
            InterimSalesHeader."Web Shipment Method" := GetJsonToken(ShipHeader, 'PostalServiceName').AsValue.AsCode();
        end;
        if GetJsonvalue(ShipHeader, 'TrackingNumber').IsNull = false then begin
            InterimSalesHeader.VALIDATE("Package Tracking No.", CopyStr((GetJsonvalue(ShipHeader, 'TrackingNumber').AsCode), 1, 30));
            InterimSalesHeader."Package Tracking No." := CopyStr(GetJsonToken(ShipHeader, 'TrackingNumber').AsValue.AsCode(), 1, 30);
        end;
        if GetJsonvalue(ShipHeader, 'TotalWeight').IsNull = false then begin
            InterimSalesHeader.Validate("Total Weight", GetJsonvalue(ShipHeader, 'TotalWeight').AsDecimal());
            InterimSalesHeader."Total Weight" := GetJsonToken(ShipHeader, 'TotalWeight').AsValue().AsDecimal();
        end;
        if GetJsonvalue(PaymentHeader, 'TotalCharge').IsNull = false then begin  //Ranjit 26/7 its pervious Subtotal
            InterimSalesHeader.Validate("Order Amount", GetJsonvalue(PaymentHeader, 'TotalCharge').AsDecimal());
        end;
        if GetJsonvalue(PaymentHeader, 'PaymentMethod').IsNull = false then begin
            paymethod := GetJsonvalue(PaymentHeader, 'PaymentMethod').AsText();
            InterimSalesHeader."Payment Method" := CopyStr(paymethod, 1, 10);
        end;
        if GetJsonvalue(Address, 'FullName').IsNull = false then begin
            InterimSalesHeader.Validate("Bill- to Name", CopyStr(GetJsonvalue(Address, 'FullName').AsText(), 1, 50));
            InterimSalesHeader."Bill- to Name" := CopyStr(GetJsonToken(Address, 'FullName').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(Address, 'EmailAddress').IsNull = false then begin
            InterimSalesHeader.Validate("Email (Location)", GetJsonvalue(Address, 'EmailAddress').AsText());
            InterimSalesHeader."Email (Location)" := GetJsonToken(Address, 'EmailAddress').AsValue.AsText();
        end;
        if GetJsonvalue(Address, 'PhoneNumber').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Phone", Copystr(GetJsonvalue(Address, 'PhoneNumber').AsCode(), 1, 20));
            InterimSalesHeader."Ship-to Phone" := copystr(GetJsonToken(Address, 'PhoneNumber').AsValue().AsCode(), 1, 20);
        end;
        If GetJsonvalue(Address, 'Country').IsNull = false then begin
            CountryCode := GetJsonvalue(Address, 'Country').AsText();

            IF CountryCode = 'US' THEN
                InterimSalesHeader."Ship-to Country/Region Code" := 'US';
            IF (CountryCode = 'UK') OR (CountryCode = 'UNITED KINGDOM') THEN
                InterimSalesHeader."Ship-to Country/Region Code" := 'GB';
            IF CountryCode = 'Canada' THEN
                InterimSalesHeader."Ship-to Country/Region Code" := 'CA';
            if CountryCode = 'Australia' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'AU';
            If CountryCode = 'France' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'FR';
            if CountryCode = 'Germany' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'DE';
            if CountryCode = 'Italy' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'IT';
            if CountryCode = 'Spain' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'ES';
            if CountryCode = 'Netherlands' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'NL';
            if CountryCode = 'Belgium_French' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'BEFR';
            if CountryCode = 'Belgium_Dutch' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'BENL';
            if CountryCode = 'Austria' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'AT';
            if CountryCode = 'Switzerland' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'CH';
            if CountryCode = 'Ireland' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'IE';
            If CountryCode = 'Sweden' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'SE';
            If CountryCode = '"Poland": ' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'PL';
            If CountryCode = 'Taiwan' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'TW';
            If CountryCode = 'Singapore' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'SG';
            If CountryCode = 'India' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'IN';
            If CountryCode = 'China' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'CN';
            If CountryCode = 'HongKong' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'HK';
            If CountryCode = 'Malaysia' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'MY';
            If CountryCode = 'Philippines' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'PH';
            If CountryCode = 'eBayMotors' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'eBayMotors';
            If CountryCode = 'CustomCode' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'US';
            If CountryCode = 'CanadaFrench' then
                InterimSalesHeader."Ship-to Country/Region Code" := 'CAFR';
        end;

        If GetJsonvalue(Address, 'PostCode').IsNull = false then begin
            InterimSalesHeader.Validate("Post Code", CopyStr(GetJsonvalue(Address, 'PostCode').AsCode(), 1, 30));
            InterimSalesHeader."Post Code" := copystr(GetJsonToken(Address, 'PostCode').AsValue().AsText(), 1, 30);
        end;
        If GetJsonvalue(Address, 'Town').IsNull = false then begin
            InterimSalesHeader.Validate(City, CopyStr(GetJsonvalue(Address, 'Town').AsText(), 1, 30));
            InterimSalesHeader.City := CopyStr(GetJsonToken(Address, 'Town').AsValue().AsText(), 1, 30);
        end;
        If GetJsonvalue(Address, 'Address1').IsNull = false then begin
            InterimSalesHeader.Address := CopyStr(GetJsonToken(Address, 'Address1').AsValue().AsText(), 1, 50);
        end;
        If GetJsonvalue(Address, 'Address2').IsNull = false then begin
            InterimSalesHeader.Validate("Address 2", CopyStr(GetJsonvalue(Address, 'Address2').AsText(), 1, 50));
            InterimSalesHeader."Address 2" := CopyStr(GetJsonToken(Address, 'Address2').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(Address, 'EmailAddress').IsNull = false then begin
            InterimSalesHeader.Validate("Buyer Email", CopyStr(GetJsonvalue(Address, 'EmailAddress').AsText(), 1, 50));
            InterimSalesHeader."Buyer Email" := Copystr(GetJsonToken(Address, 'EmailAddress').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(Address, 'Address1').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Address", Copystr(GetJsonvalue(Address, 'Address1').AsText(), 1, 50));
            InterimSalesHeader."Ship-to Address" := Copystr(GetJsonToken(Address, 'Address1').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(Address, 'Address2').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Address 2", Copystr(GetJsonvalue(Address, 'Address2').AsText(), 1, 50));
            InterimSalesHeader."Ship-to Address 2" := CopyStr(GetJsonToken(Address, 'Address2').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(Address, 'Town').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to City", CopyStr(GetJsonvalue(Address, 'Town').AsText(), 1, 30));
            InterimSalesHeader."Ship-to City" := Copystr(GetJsonToken(Address, 'Town').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(Address, 'PostCode').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Post Code", Copystr(GetJsonvalue(Address, 'PostCode').AsText(), 1, 20));
            InterimSalesHeader."Ship-to Post Code" := Copystr(GetJsonToken(Address, 'PostCode').AsValue().AsText(), 1, 20);
        end;

        if GetJsonvalue(Address, 'FullName').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Name", Copystr(GetJsonvalue(Address, 'FullName').AsText(), 1, 50));
            InterimSalesHeader."Ship-to Name" := CopyStr(GetJsonToken(Address, 'FullName').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(Address, 'Region').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to County", copystr(GetJsonvalue(Address, 'Region').AsText(), 1, 30));
            InterimSalesHeader."Ship-to County" := CopyStr(GetJsonToken(Address, 'Region').AsValue().AsText(), 1, 30);
        end;
        InterimSalesHeader.status := InterimSalesHeader.status::"In Progress";

        InterimSalesHeader.Insert();
    end;


    //Procedure to Insert Line Items into Interim Sales Line Table
    procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; OrderObject: JsonObject; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        itemArray: JsonArray;
        j: Integer;
        itemCount: Integer;
        lineItemToken: JsonToken;
        lineObject: JsonObject;
    begin
        itemArray := GetJsonToken(OrderObject, 'Items').AsArray();

        itemCount := itemArray.Count;
        if itemCount > 0 then begin

            for j := 0 to itemCount - 1 do begin
                itemArray.Get(j, lineItemToken);
                lineObject := lineItemToken.AsObject();
                InterimSalesLine.Init();
                InterimSalesLine."Line No." := j;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";
                InterimSalesLine."Trade Partner Code" := InterimSalesHeader."Trade Partner Code";
                InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";
                InterimSalesLine."Location Code" := InterimSalesHeader."Location Code";

                if GetJsonvalue(LineObject, 'Quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'Quantity').AsDecimal;
                end;
                if GetJsonvalue(LineObject, 'ChannelSKU').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'ChannelSKU').AsCode;
                end;


                if GetJsonvalue(LineObject, 'ItemId').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'ItemId').AsText();
                end;

                if GetJsonvalue(LineObject, 'Title').IsNull = false then begin
                    InterimSalesLine.Description := GetJsonvalue(LineObject, 'Title').AsText();
                end;

                if GetJsonvalue(LineObject, 'Cost').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'Cost').AsDecimal();
                end;

                InterimSalesLine.Insert();

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