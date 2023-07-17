codeunit 90069 "Amazon Testing"
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
                    ListOrdersV1(StartParameter, '');
                End;
        end;
    end;

    var
        SyncOrderLabel: Label 'SyncOrder';
        RunType: Text;
        StartParameter: Text;
        AccessKeyId: Text;
        SecretAccessKey: Text;
        MerchantId: Text;
        MWSAuthToken: Text;
        ServiceURL: Text;
        MarketPlaceId: Text;
        MarketPlaceIds: Text;
        ApplicationVersion: Text;
        URL: Text;
        ApplicationName: Text;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        LastOrderSync: DateTime;


    procedure GetCreadentils("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            AccessKeyId := TradePartner.AccessKeyId;
            SecretAccessKey := TradePartner.SecretAccessKey;
            MerchantId := TradePartner.MerchantId;
            ServiceURL := TradePartner."Sevice/API URL";
            MarketPlaceId := '';
            MarketPlaceIds := TradePartner.MarketplaceId;
            LastOrderSync := TradePartner."Last Order Sync";
        end;
        ApplicationName := 'Test';
        ApplicationVersion := '1.0';
        MWSAuthToken := '';
    End;


    //Procedure for List Orders Testing Shubham (Version 1)
    procedure ListOrdersV1(ChannelCode: Code[250]; NextToken: Text)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        CreatedAfter: Text;
        CreatedBefore: Text;
        responseText: Text;
        i: Integer;
        noOfResult: Integer;
        jObject: JsonObject;
        HeaderObject: JsonObject;
        WebHeaderObject: List of [JsonObject];
        orderHeaderObject: JsonObject;
        jArray: JsonArray;
        itemObject: JsonObject;
        orderToken: JsonToken;
        ChannelOrderID: Code[20];
        TokenCount: Integer;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
    begin
        GetCreadentils(ChannelCode);
        CreatedAfter := FORMAT(LastOrderSync, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
        CreatedBefore := FORMAT(CurrentDateTime - (10 * 60 * 1000), 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>');
        Clear(URL);

        URL := StrSubstNo('http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrderHeaders?' +
       'AccessKeyId=%1&applicationName=%2&applicationVersion=%3&marketplaceId=%4&merchantId=%5' +
       '&MWSAuthToken=%6&SecretAccessKey=%7&ServiceURL=%8&MarketPlaceIds=%9&maxResultsPerPage=100' +
       '&createdAfter=%10&LastUpdatedAfter=&createdBefore=%11&LastUpdatedBefore=&orderStatus=Shipped,Unshipped&fulfillmentChannel=' +
       '&paymentMethod=&buyerEmail=&sellerOrderId=&tfmShipmentStatus=&Token=%12', AccessKeyId, ApplicationName, ApplicationVersion, MarketPlaceId, MerchantId, MWSAuthToken, SecretAccessKey, ServiceURL, MarketPlaceIds, CreatedAfter, CreatedBefore, NextToken);

        if Client.Get(URL, ResponseMessage) then begin

            if ResponseMessage.HttpStatusCode = 200 then begin

                ResponseMessage.Content.ReadAs(responseText);
                jObject.ReadFrom(responseText);
                if GetJsonvalue(jObject, 'NextToken').IsNull = false then begin
                    NextToken := GetJsonvalue(jObject, 'NextToken').AsText();
                    TokenCount := strlen(NextToken);
                    if TokenCount < 10 then
                        NextToken := '';
                end
                else
                    NextToken := '';
                jArray := GetJsonToken(jObject, 'orderList').AsArray();
                noOfResult := jArray.Count();
                message('No of Count:%1', Format(noOfResult));
                for i := 0 to noOfResult - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();

                    jArray.Get(i, orderToken);
                    orderHeaderObject := orderToken.AsObject();

                    HeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                    InsertInSalesHeader(HeaderObject, ChannelCode, InterimSalesHeader);

                    if GetJsonvalue(HeaderObject, 'ChannelOrderID').IsNull = false then begin
                        ChannelOrderID := CopyStr(GetJsonvalue(HeaderObject, 'ChannelOrderID').AsCode(), 1, 20);
                    end;

                    itemObject := ListOrderItemsV1(ChannelCode, ChannelOrderID);
                    if itemObject.Keys.Count <> 0 then begin
                        InsertInSalesLine(InterimSalesHeader, InterimSalesLine, itemObject);
                    end
                    else begin
                        itemObject := ListOrderItemsV1(ChannelCode, ChannelOrderID);
                        if itemObject.Keys.Count <> 0 then begin
                            InsertInSalesLine(InterimSalesHeader, InterimSalesLine, itemObject);
                        end
                    end;

                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

                End;

            end;

        End;

        if NextToken <> '' then
            ListOrdersV1(ChannelCode, NextToken);
        MESSAGE('Order Sync Completed...');

    end;


    //Procedure to List Order Item Testing Shubham (Version 1)
    procedure ListOrderItemsV1(ChannelCode: Code[250]; orderId: Code[20]): JsonObject
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        responseText: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        orderToken: JsonToken;
        lineItemObject: JsonObject;
        j: Integer;
        recordCount: Integer;
    begin
        GetCreadentils(ChannelCode);
        Clear(URL);
        URL := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrderLineItems?' +
        'AccessKeyId=' + AccessKeyId + '&applicationName=' + ApplicationName +
        '&applicationVersion=' + ApplicationVersion + '&marketplaceId=&merchantId=' + MerchantId +
        '&MWSAuthToken=&SecretAccessKey=' + SecretAccessKey + '&ServiceURL=' + ServiceURL +
        '&MarketPlaceIds=' + MarketPlaceIds + '&orderId=' + orderId;

        if Client.Get(URL, ResponseMessage) then begin

            if ResponseMessage.HttpStatusCode = 200 then begin
                ResponseMessage.Content.ReadAs(responseText);
                jObject.ReadFrom(responseText);
                jArray := GetJsonToken(jObject, 'orderList').AsArray();
                recordCount := jArray.Count;

                if recordCount <> 0 then begin

                    for j := 0 to recordCount - 1 do begin
                        jArray.Get(j, orderToken);
                        lineItemObject := orderToken.AsObject();
                        exit(lineItemObject);
                    end;

                end
                else
                    ListOrderItemsV1(ChannelCode, orderId);

            end;

        end;

    end;


    //Procedure for List Orders Testing Shubham (Version 2)
    procedure ListOrdersV2(ChannelCode: Code[250]; NextToken: Text)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        CreatedAfter: Text;
        CreatedBefore: Text;
        responseText: Text;
        i: Integer;
        noOfResult: Integer;
        jObject: JsonObject;
        HeaderObject: JsonObject;
        orderHeaderObject: JsonObject;
        jArray: JsonArray;
        itemObject: JsonObject;
        orderToken: JsonToken;
        ChannelOrderID: Code[20];
        TokenCount: Integer;
        recordCount: Integer;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        orderId: Text;
    begin
        GetCreadentils(ChannelCode);
        CreatedAfter := FORMAT(LastOrderSync, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');
        CreatedBefore := FORMAT(CurrentDateTime - (10 * 60 * 1000), 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>');
        Clear(URL);

        URL := StrSubstNo('http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrderHeaders?' +
       'AccessKeyId=%1&applicationName=%2&applicationVersion=%3&marketplaceId=%4&merchantId=%5' +
       '&MWSAuthToken=%6&SecretAccessKey=%7&ServiceURL=%8&MarketPlaceIds=%9&maxResultsPerPage=100' +
       '&createdAfter=%10&LastUpdatedAfter=&createdBefore=%11&LastUpdatedBefore=&orderStatus=Shipped,Unshipped&fulfillmentChannel=' +
       '&paymentMethod=&buyerEmail=&sellerOrderId=&tfmShipmentStatus=&Token=%12', AccessKeyId, ApplicationName, ApplicationVersion, MarketPlaceId, MerchantId, MWSAuthToken, SecretAccessKey, ServiceURL, MarketPlaceIds, CreatedAfter, CreatedBefore, NextToken);

        if Client.Get(URL, ResponseMessage) then begin

            if ResponseMessage.HttpStatusCode = 200 then begin
                ResponseMessage.Content.ReadAs(responseText);
                jObject.ReadFrom(responseText);
                if GetJsonvalue(jObject, 'NextToken').IsNull = false then begin
                    NextToken := GetJsonvalue(jObject, 'NextToken').AsText();
                    TokenCount := strlen(NextToken);
                    if TokenCount < 10 then
                        NextToken := '';
                end
                else
                    NextToken := '';
                jArray := GetJsonToken(jObject, 'orderList').AsArray();
                noOfResult := jArray.Count();
                message('No of Count:%1', Format(noOfResult));

                for i := 0 to noOfResult - 1 do begin
                    jArray.Get(i, orderToken);
                    orderHeaderObject := orderToken.AsObject();

                    HeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                    InsertInSalesHeader(HeaderObject, ChannelCode, InterimSalesHeader);
                    recordCount := InterimSalesHeader.Count;
                End;
            end;

        End;

        if NextToken <> '' then begin
            ListOrdersV2(ChannelCode, NextToken);
        end;

        //Need to figure out which filter to apply to get the list of Headers which got inserted just now.

        InterimSalesHeader.SetRange("Trade Partner Code", ChannelCode);
        InterimSalesHeader.SetRange("No.", InterimSalesHeader."No.");

        if InterimSalesHeader.FindSet() then begin
            recordCount := InterimSalesHeader.Count;
            repeat
                orderId := InterimSalesHeader."Channel Order ID";
                ListOrderItemsV2(ChannelCode, InterimSalesHeader, orderId);
            until InterimSalesHeader.Next() = 0;
        end;

        MESSAGE('Order Sync Completed...');

    end;


    //Procedure to List Order Item Testing Shubham (Version 2)
    procedure ListOrderItemsV2(ChannelCode: Code[250]; var InterimSalesHeader: Record "Interim Sales Header" temporary; orderId: Text)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        responseText: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        orderToken: JsonToken;
        lineItemObject: JsonObject;
        i: Integer;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
    begin
        GetCreadentils(ChannelCode);
        Clear(URL);
        URL := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrderLineItems?' +
        'AccessKeyId=' + AccessKeyId + '&applicationName=' + ApplicationName +
        '&applicationVersion=' + ApplicationVersion + '&marketplaceId=&merchantId=' + MerchantId +
        '&MWSAuthToken=&SecretAccessKey=' + SecretAccessKey + '&ServiceURL=' + ServiceURL +
        '&MarketPlaceIds=' + MarketPlaceIds + '&orderId=' + orderId;

        if Client.Get(URL, ResponseMessage) then begin

            if ResponseMessage.HttpStatusCode = 200 then begin
                InterimSalesLine.DeleteAll();
                ShipmnetTracking.DeleteAll();
                PaymentDetails.DeleteAll();

                ResponseMessage.Content.ReadAs(responseText);
                jObject.ReadFrom(responseText);
                jArray := GetJsonToken(jObject, 'orderList').AsArray();
                jArray.Get(0, orderToken);
                lineItemObject := orderToken.AsObject();
                InsertInSalesLine(InterimSalesHeader, InterimSalesLine, lineItemObject);

                InterimSalesHeader.SetRange("Trade Partner Code", ChannelCode);
                InterimSalesHeader.SetRange("No.", InterimSalesLine."Document No");
                InterimSalesHeader.FindFirst();

                if (InterimSalesHeader."Trade Partner Code" = InterimSalesLine."Trade Partner Code") and (InterimSalesHeader."No." = InterimSalesLine."Document No") then begin
                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                end;
            end;

        end;

    end;


    local procedure InsertInSalesHeader(WebHeaderObject: JsonObject; ChannelCode: Code[20]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        CountryCode: Text;
        TradePartner1: Record "Trade Partner";
        ShippingDate: DateTime;
        FullfillmentChannel: Text;
        Orderdate: Text;
        BigAddress: text[100];

    begin

        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Channel Order ID" := GetJsonvalue(WebHeaderObject, 'ChannelOrderID').AsCode();
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := GetJsonvalue(WebHeaderObject, 'ChannelOrderID').AsCode();


        If GetJsonvalue(WebHeaderObject, 'Country').IsNull = false then begin
            InterimSalesHeader."Ship-to Country" := GetJsonvalue(WebHeaderObject, 'Country').AsText();
        End;


        If GetJsonvalue(WebHeaderObject, 'PostCode').IsNull = false then begin
            InterimSalesHeader."Post Code" := GetJsonToken(WebHeaderObject, 'PostCode').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'City').IsNull = false then begin
            InterimSalesHeader."City" := CopyStr(GetJsonToken(WebHeaderObject, 'City').AsValue.AsText(), 1, 30);
        end;

        if GetJsonvalue(WebHeaderObject, 'BuyerEmail').IsNull = false then begin
            InterimSalesHeader."Buyer Email" := GetJsonToken(WebHeaderObject, 'BuyerEmail').AsValue.AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoCity').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := CopyStr(GetJsonToken(WebHeaderObject, 'ShiptoCity').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoAddress').IsNull = false then begin
            InterimSalesHeader."Ship-to Address" := CopyStr(GetJsonToken(WebHeaderObject, 'ShiptoAddress').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(WebHeaderObject, 'ShiptoAddress2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := CopyStr(GetJsonToken(WebHeaderObject, 'ShiptoAddress2').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(WebHeaderObject, 'BuyerName').IsNull = false then begin
            InterimSalesHeader."Buyer Name" := GetJsonToken(WebHeaderObject, 'BuyerName').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoName').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := GetJsonToken(WebHeaderObject, 'ShiptoName').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'BilltoName').IsNull = false then begin
            InterimSalesHeader."Bill- to Name" := GetJsonToken(WebHeaderObject, 'BilltoName').AsValue().AsText();
        end;
        if GetJsonvalue(WebHeaderObject, 'Address').IsNull = false then begin
            BigAddress := GetJsonToken(WebHeaderObject, 'Address').AsValue().AsText();
            InterimSalesHeader.Address := CopyStr(BigAddress, 1, 50);
            InterimSalesHeader."Address 2" := CopyStr(BigAddress, 51, 50);
        end;

        if GetJsonvalue(WebHeaderObject, 'ShippingCategory').IsNull = false then begin
            InterimSalesHeader."Web Shipment Method" := Copystr(GetJsonToken(WebHeaderObject, 'ShippingCategory').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(WebHeaderObject, 'FullfillmentChannel').IsNull = false then begin
            FullfillmentChannel := GetJsonToken(WebHeaderObject, 'FullfillmentChannel').AsValue().AsText();
        end;
        If FullfillmentChannel = 'AFN' then
            InterimSalesHeader.Validate("Fullfillment Channel", InterimSalesHeader."Fullfillment Channel"::Amazon)
        else
            InterimSalesHeader.Validate("Fullfillment Channel", InterimSalesHeader."Fullfillment Channel"::Seller);

        if GetJsonvalue(WebHeaderObject, 'PaymentMethod').IsNull = false then begin
            InterimSalesHeader."Payment Method" := GetJsonvalue(WebHeaderObject, 'PaymentMethod').AsText();
        end;
        if GetJsonvalue(WebHeaderObject, 'OrderDate').IsNull = false then begin
            Orderdate := GetJsonvalue(WebHeaderObject, 'OrderDate').AsText();
            InterimSalesHeader."Document Date" := GenerateDate(Orderdate);
        end;

        InterimSalesHeader."Order Date" := Today;
        InterimSalesHeader.VALIDATE("Pickup Date", TODAY + 1);
        InterimSalesHeader.VALIDATE("Pickup Time", 170000T);
        InterimSalesHeader.VALIDATE("No. Of Parcels", 1);

        InterimSalesHeader.Insert();
    End;


    local procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header"; var InterimSalesLine: Record "Interim Sales Line" temporary; var jObject: JsonObject)
    var
        OrderAmount: Decimal;
        LineNo: Integer;
        ShippingPrice: Decimal;
        ItemArray: JsonArray;
        itemCount: Integer;
        k: Integer;
        itemObject: JsonObject;
        LineObject: JsonObject;
        WebLineToken: JsonToken;
        ShippingRule: Record "Shipping Rule";
        CourierIntegration: Codeunit "Courier Integration";
    begin
        if jObject.Keys.Count <> 0 then begin

            ItemArray := GetJsonToken(jObject, 'webLines').AsArray();
            itemCount := ItemArray.Count;

            if itemCount > 0 then begin
                for k := 0 to itemCount - 1 do begin
                    ItemArray.Get(k, WebLineToken);
                    LineObject := WebLineToken.AsObject;

                    InterimSalesLine.Init;
                    InterimSalesLine."Line No." := K;
                    InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                    InterimSalesLine.Type := InterimSalesLine.type::Item;

                    if GetJsonvalue(LineObject, 'Quantity').IsNull = false then begin
                        InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'Quantity').AsDecimal;
                    end;

                    if GetJsonvalue(LineObject, 'UnitPrice').IsNull = false then begin
                        InterimSalesLine.Amount := GetJsonvalue(LineObject, 'UnitPrice').AsDecimal();
                    end;

                    if (InterimSalesLine.Quantity > 1) And (InterimSalesLine.Quantity <> 0) then begin
                        InterimSalesLine."Unit Price" := InterimSalesLine.Amount / InterimSalesLine.Quantity;
                    end else begin
                        InterimSalesLine."Unit Price" := InterimSalesLine.Amount;
                    end;

                    if GetJsonvalue(LineObject, 'ChannelItemId').IsNull = false then begin
                        InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'ChannelItemId').AsText();
                    end;

                    if GetJsonvalue(LineObject, 'Description').IsNull = false then begin
                        InterimSalesLine.Description := Copystr(GetJsonvalue(LineObject, 'Description').AsText(), 1, 100);
                    end;

                    if (GetJsonvalue(LineObject, 'ShippingPrice').IsNull = false) then begin
                        ShippingPrice := GetJsonvalue(LineObject, 'ShippingPrice').AsDecimal();
                    end;

                    if GetJsonvalue(LineObject, 'ChannelSKU').IsNull = false then begin
                        InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'ChannelSKU').AsCode;
                    end;

                    if GetJsonvalue(LineObject, 'ChannelSKU').IsNull = false then begin
                        InterimSalesLine."No." := GetJsonvalue(LineObject, 'ChannelSKU').AsCode();
                    End;
                    InterimSalesLine."Shipping Price" := ShippingPrice;

                    OrderAmount += InterimSalesLine.Amount;
                    InterimSalesHeader.Reset();
                    InterimSalesHeader.SetRange("No.", InterimSalesLine."Document No");
                    if InterimSalesHeader.FindFirst() then begin
                        InterimSalesHeader."Order Amount" := OrderAmount + ShippingPrice;
                    End;

                    InterimSalesLine.Insert();
                end;
                if InterimSalesHeader."Trade Partner Code" <> '' then begin
                    CourierIntegration.GetNavShippingAgentFromWebShipping(InterimSalesHeader."Trade Partner Code", '', InterimSalesHeader."Web Shipment Method", ShippingRule);
                    InterimSalesHeader."Web Shipping Agent" := ShippingRule."Shipping Agent";
                    InterimSalesHeader."Shipping Agent Service Code" := ShippingRule."Shipping Agent Service";
                    InterimSalesHeader."Shipping Agent Code" := ShippingRule."Shipping Agent";
                    InterimSalesHeader."Shipment Method Code" := ShippingRule."BC Shipment Method";
                    InterimSalesHeader.MODIFY;
                end;
            end;
        end
        else
            itemObject := ListOrderItemsV1(InterimSalesHeader."Trade Partner Code", InterimSalesHeader."Channel Order ID");
        if itemObject.Keys.Count <> 0 then
            InsertInSalesLine(InterimSalesHeader, InterimSalesLine, itemObject);

    End;


    local procedure GenerateDate(Orderdate: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Converdate: Date;
        Lenght: Integer;
        ISh: Record "Interim Sales Header";
    begin

        if Orderdate <> '' then begin
            Orderdate := Orderdate.Split(' ').Get(1);
            Lenght := StrLen(Orderdate.Trim());
            if Lenght > 0 then begin
                if StrPos(Orderdate, '/') > 0 then begin
                    Evaluate(Month, Orderdate.Split('/').Get(1));
                    Evaluate(Day, Orderdate.Split('/').Get(2));
                    Evaluate(Year, Orderdate.Split('/').Get(3));
                    Converdate := DMY2Date(Day, Month, Year);
                end;
                if StrPos(Orderdate, '-') > 0 then begin
                    Evaluate(Month, Orderdate.Split('-').Get(1));
                    Evaluate(Day, Orderdate.Split('-').Get(2));
                    Evaluate(Year, Orderdate.Split('-').Get(3));
                    Converdate := DMY2Date(Day, Month, Year);
                end;
            end;

        End;
        exit(Converdate);
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