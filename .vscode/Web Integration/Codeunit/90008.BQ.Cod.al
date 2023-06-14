codeunit 90008 "B&Q"
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
                    GetWaitingForAcceptSecretSalesOrders(StartParameter);
                    GetShippingSecretSalesOrders(StartParameter);
                    TradePartner.Reset();
                    TradePartner.SetRange(Code, StartParameter);
                    if TradePartner.FindFirst() then begin
                        TradePartner."Last Order Sync" := CreateDateTime(WorkDate, Time);
                        TradePartner.Modify;
                    end;
                    Message('Orders Sync Completed');
                End;
            'SyncShipment':
                OrderDispatchedConfirmation(StartParameter);
            'Refund':
                RequestRefunds(StartParameter);
            SyncItemLabel:
                Begin
                    SyncSecretSaleItemsOnPortal(StartParameter);
                    Message('Items Sync Complete');
                End;
            'AcceptOrders':
                GetWaitingForAcceptSecretSalesOrders(StartParameter);
            'GetShippingOrders':
                GetShippingSecretSalesOrders(StartParameter);
        end;
    end;


    var
        myInt: Integer;
        AccessKeyId: Text;
        SecretAccessKey: Text;
        WebAPIURL: Text;
        ServiceURL: Text;
        ShopId: Text;
        OrderObject: JsonObject;
        JsonObjectInArray: JsonArray;
        NoOfRecs: Integer;
        ShippingAddress: JsonObject;
        BillingAddress: JsonObject;
        OrderHeader: JsonObject;
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        G_TempInterimLine: Record "Interim Sales Line" temporary;
        G_TempInterimHeader: Record "Interim Sales Header" temporary;
        G_InterimSalesHeader: Record "Interim Sales Header" temporary;
        G_InterimSalesLine: Record "Interim Sales Line" temporary;
        G_ShipmentTracking: Record "Shipment Tracking" temporary;
        G_PaymentDetails: Record "Channel Media" temporary;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        SyncItemLabel: Label 'SyncItem';
        TradePartner: Record "Trade Partner";

    procedure GetCreadentils("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin

        TradePartner.RESET;
        if ChannelCode = ChannelCode then begin
            if TradePartner.Get(ChannelCode) then begin
                AccessKeyId := TradePartner.AccessKeyId;
                ServiceURL := TradePartner."Sevice/API URL";
                WebAPIURL := TradePartner.MerchantId;
                ShopId := TradePartner.MarketplaceId;
            End;
        end;

    End;

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

    procedure GetShippingSecretSalesOrders(ChannelCode: Code[10])
    var
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        i: Integer;
        orderHeareToken: JsonToken;
        ChannelOrderID: Text[50];
        Customer: JsonObject;
    begin

        GetCreadentils(ChannelCode);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        if HttpClient.Get(ServiceURL + 'orders?shop_id=' + ShopId + '&order_state_codes=SHIPPING', HttpResponse) then begin
            HttpResponse.Content.ReadAs(responseText);
            OrderObject.ReadFrom(responseText);
            JsonObjectInArray := GetJsonToken(OrderObject, 'orders').AsArray();
            i := JsonObjectInArray.Count;
            NoOfRecs := JsonObjectInArray.Count;
            G_InterimSalesHeader.DeleteAll();
            for i := 0 to NoOfRecs - 1 do begin
                JsonObjectInArray.Get(i, orderHeareToken);
                OrderHeader := orderHeareToken.AsObject();
                Customer := GetJsonToken(OrderHeader, 'customer').AsObject();
                ShippingAddress := GetJsonToken(Customer, 'shipping_address').AsObject();
                BillingAddress := GetJsonToken(Customer, 'billing_address').AsObject();
                ChannelOrderID := GetJsonvalue(OrderHeader, 'order_id').AsText();
                InsertIntSalesHeader(ChannelOrderID, OrderHeader, ChannelCode);
                InsertInterimSalesLine(G_InterimSalesHeader, OrderHeader);
                if G_InterimSalesHeader.FindSet() then begin
                    repeat
                        G_InterimSalesLine.Reset();
                        G_InterimSalesLine.SetRange("Document Type", G_InterimSalesHeader."Document Type");
                        G_InterimSalesLine.SetRange("Document No", G_InterimSalesHeader."No.");
                        if G_InterimSalesLine.FindSet() then begin
                            repeat
                                if G_InterimSalesLine."Channel Order ID" <> G_InterimSalesHeader."Channel Order ID" then
                                    G_InterimSalesLine.Delete(true);
                            until G_InterimSalesLine.Next() = 0;
                        end;
                    until G_InterimSalesHeader.Next() = 0;
                end;
                CUWebOrderMgt.CreateWebOrder(G_InterimSalesHeader, G_InterimSalesLine, G_ShipmentTracking, G_PaymentDetails);
            end;
        end;
    End;

    procedure GetWaitingForAcceptSecretSalesOrders(ChannelCode: Code[10])
    var
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        i: Integer;
        orderHeareToken: JsonToken;
        ChannelOrderID: Text[50];
        Customer: JsonObject;
    begin

        GetCreadentils(ChannelCode);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        if HttpClient.Get(ServiceURL + 'orders?shop_id=' + ShopId + '&order_state_codes=WAITING_ACCEPTANCE', HttpResponse) then begin
            HttpResponse.Content.ReadAs(responseText);
            OrderObject.ReadFrom(responseText);
            JsonObjectInArray := GetJsonToken(OrderObject, 'orders').AsArray();
            i := JsonObjectInArray.Count;
            NoOfRecs := JsonObjectInArray.Count;
            G_TempInterimHeader.DeleteAll();
            G_TempInterimLine.DeleteAll();
            for i := 0 to NoOfRecs - 1 do begin
                JsonObjectInArray.Get(i, orderHeareToken);
                OrderHeader := orderHeareToken.AsObject();
                Customer := GetJsonToken(OrderHeader, 'customer').AsObject();
                ChannelOrderID := GetJsonvalue(OrderHeader, 'order_id').AsText();
                TempInsertHeader(ChannelOrderID, Customer, ChannelCode);
                TempInsertLine(G_TempInterimHeader, OrderHeader);
            end;
        end;
    End;

    procedure SendTrackingInformation(CarrierCode: Code[10]; TrackingNumber: Text[30]; OrderNo: Text[50]; ChannelCode: Code[20])
    var
        L_HttpHeaders: HttpHeaders;
        L_HttpClient: HttpClient;
        L_HttpContent: HttpContent;
        L_Body: Text;
        HttpResponse: HttpResponseMessage;
        URL: Text;
        L_ShippingAgent: Record "Shipping Agent";
    begin
        if TrackingNumber <> '' then begin
            Clear(L_Body);
            L_ShippingAgent.Reset();
            L_ShippingAgent.SetRange(Code, CarrierCode);
            if L_ShippingAgent.FindFirst() then begin
                L_Body := StrSubstNo('{"carrier_code": "%1","tracking_number":"%2"}', L_ShippingAgent.Name, TrackingNumber);
                GetCreadentils(ChannelCode);
                L_HttpContent.WriteFrom(L_Body);
                L_HttpHeaders := L_HttpClient.DefaultRequestHeaders();
                L_HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
                L_HttpContent.GetHeaders(L_HttpHeaders);
                L_HttpHeaders.Clear();
                L_HttpHeaders.Add('Content-Type', 'application/json');
                URL := ServiceURL + 'orders/' + OrderNo + '/tracking?shop_id=' + ShopId;
                L_HttpClient.Put(URL, L_HttpContent, HttpResponse);
            end;
        end;
    end;



    local procedure InsertInterimSalesLine(InterimSalesHeader: Record "Interim Sales Header"; jsonMainReq: JsonObject)
    var
        p: Integer;
        DiscountArray: JsonArray;
        DiscountJsonobejt: JsonObject;
        Disconttoken: JsonToken;
        ItemArray: JsonArray;
        cnt: Integer;
        i: Integer;
        j: Integer;
        k: Integer;
        LineObject: JsonObject;
        WebLineToken: JsonToken;
        DiscontCount: Integer;
        DiscountObject: JsonObject;
        Item: Record Item;
        IsHandled: Boolean;

    begin
        OnBeforeInsertInterimSalesLine(InterimSalesHeader, jsonMainReq, IsHandled);
        if IsHandled then
            exit;

        ItemArray := GetJsonToken(jsonMainReq, 'order_lines').AsArray();

        cnt := ItemArray.Count;
        if cnt > 0 then begin
            P := 0;
            for k := 0 to cnt - 1 do begin
                ItemArray.Get(k, WebLineToken);
                LineObject := WebLineToken.AsObject;
                G_InterimSalesLine.Init();
                G_InterimSalesLine."Document Type" := G_InterimSalesLine."Document Type"::Order;
                G_InterimSalesLine.Type := G_InterimSalesLine.type::Item;
                G_InterimSalesLine."Document No" := InterimSalesHeader."No.";
                G_InterimSalesLine."Line No." := G_InterimSalesLine."Line No." + 10000;
                G_InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";
                G_InterimSalesLine.order_id := InterimSalesHeader.order_id;

                if k = 0 then begin
                    if GetJsonvalue(LineObject, 'shipping_price').IsNull = false then begin
                        G_InterimSalesLine."Shipping Price" := GetJsonToken(LineObject, 'shipping_price').AsValue().AsDecimal();
                    end;
                end;


                if GetJsonvalue(LineObject, 'quantity').IsNull = false then begin
                    G_InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'quantity').AsDecimal;
                end;

                if GetJsonvalue(LineObject, 'order_line_id').IsNull = false then begin
                    G_InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'order_line_id').AsText();
                    G_InterimSalesLine.Validate("Channel Item Id", GetJsonvalue(LineObject, 'order_line_id').AsText());
                    G_InterimSalesLine.order_line_id := GetJsonvalue(LineObject, 'order_line_id').AsText();
                end;

                if GetJsonvalue(LineObject, 'price_unit').IsNull = false then begin
                    G_InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'price_unit').AsDecimal();
                end;


                G_InterimSalesLine.Amount := Round(G_InterimSalesLine."Unit Price" * G_InterimSalesLine.Quantity);

                if GetJsonvalue(LineObject, 'product_title').IsNull = false then begin
                    G_InterimSalesLine.Description := Copystr(GetJsonvalue(LineObject, 'product_title').AsText(), 1, 100);
                end;
                DiscountObject := GetJsonToken(LineObject, 'price_amount_breakdown').AsObject();
                DiscountArray := GetJsonToken(DiscountObject, 'parts').AsArray();
                DiscountArray.Get(0, Disconttoken);
                DiscountJsonobejt := Disconttoken.AsObject;
                if GetJsonvalue(DiscountJsonobejt, 'amount').IsNull = false then begin
                    G_InterimSalesLine.Validate(Amount, GetJsonvalue(DiscountJsonobejt, 'amount').AsDecimal());
                end;
                if GetJsonvalue(LineObject, 'product_sku').IsNull = false then begin
                    G_InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'product_sku').AsCode;
                end;

                G_InterimSalesLine.Insert(true);
            End;

        end;



        OnAfterInsertInterimSalesLine(InterimSalesHeader, jsonMainReq);
    end;

    local procedure InsertIntSalesHeader(ChannelOrderId: Text; HeaderObject: JsonObject; ChannelCode: Code[20])
    var
        AddressLenght: Integer;
        BigAddress: Text[100];
        TotalWeight: Decimal;
        CountryCode: Code[20];
        FulfillmentChannel: Text[250];
        TradePartner1: Record "Trade Partner";
        IsHandled: Boolean;
        L_No: Code[20];
    begin
        OnBeforeInsertIntSalesHeader(ChannelOrderId, HeaderObject, ChannelCode, IsHandled);
        if IsHandled then
            exit;

        Clear(L_No);
        G_InterimSalesHeader.Reset();
        G_InterimSalesHeader.SetRange("Document Type", G_InterimSalesHeader."Document Type"::Order);
        if G_InterimSalesHeader.FindLast() then
            L_No := IncStr(G_InterimSalesHeader."No.")
        else
            L_No := '10000';
        G_InterimSalesHeader.Init();
        G_InterimSalesHeader."Trade Partner Code" := ChannelCode;
        G_InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        G_InterimSalesHeader.order_id := ChannelOrderId;
        G_InterimSalesHeader."Document Type" := G_InterimSalesHeader."Document Type"::Order;
        G_InterimSalesHeader."No." := L_No;
        //billing details
        if GetJsonvalue(BillingAddress, 'firstname').IsNull = false then begin
            G_InterimSalesHeader."Bill- to Name" := CopyStr(GetJsonToken(BillingAddress, 'firstname').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(BillingAddress, 'street_1').IsNull = false then begin
            G_InterimSalesHeader.Address := CopyStr(GetJsonToken(BillingAddress, 'street_1').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(BillingAddress, 'street_2').IsNull = false then begin
            G_InterimSalesHeader."Address 2" := CopyStr(GetJsonToken(BillingAddress, 'street_2').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(BillingAddress, 'city').IsNull = false then begin
            G_InterimSalesHeader.City := CopyStr(GetJsonToken(BillingAddress, 'city').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(BillingAddress, 'country').IsNull = false then begin
            G_InterimSalesHeader."Bill-to County" := CopyStr(GetJsonToken(BillingAddress, 'country').AsValue().AsText(), 1, 50);
        end;
        if GetJsonvalue(BillingAddress, 'zip_code').IsNull = false then begin
            G_InterimSalesHeader."Post Code" := CopyStr(GetJsonToken(BillingAddress, 'zip_code').AsValue().AsText(), 1, 50);
        end;




        G_InterimSalesHeader."External Document No." := ChannelOrderId;
        if GetJsonvalue(HeaderObject, 'created_date').IsNull = false then begin
            G_InterimSalesHeader."Order Placed At" := GetJsonToken(HeaderObject, 'created_date').AsValue().AsDateTime();
            G_InterimSalesHeader."Document Date" := DT2Date(GetJsonToken(HeaderObject, 'created_date').AsValue().AsDateTime());
            //G_InterimSalesHeader."Currency Code" := 'GBP';
        end;


        if GetJsonvalue(HeaderObject, 'payment_type').IsNull = false then begin
            G_InterimSalesHeader."Payment Method" := GetJsonToken(HeaderObject, 'payment_type').AsValue().AsCode();
        end;

        if GetJsonvalue(ShippingAddress, 'phone').IsNull = false then begin

            G_InterimSalesHeader."Ship-to Phone" := GetJsonToken(ShippingAddress, 'phone').AsValue().AsCode();
        end;


        If GetJsonvalue(BillingAddress, 'country_iso_code').IsNull = false then begin
            CountryCode := GetJsonvalue(BillingAddress, 'country_iso_code').AsText();

            IF CountryCode = 'US' THEN
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'US';
            IF (CountryCode = 'UK') OR (CountryCode = 'UNITED KINGDOM') THEN
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'UK';
            IF CountryCode = 'Canada' THEN
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'CA';
            if CountryCode = 'Australia' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'AU';
            If CountryCode = 'France' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'FR';
            if CountryCode = 'Germany' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'DE';
            if CountryCode = 'Italy' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'IT';
            if CountryCode = 'Spain' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'ES';
            if CountryCode = 'Netherlands' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'NL';
            if CountryCode = 'Belgium_French' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'BEFR';
            if CountryCode = 'Belgium_Dutch' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'BENL';
            if CountryCode = 'Austria' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'AT';
            if CountryCode = 'Switzerland' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'CH';
            if CountryCode = 'Ireland' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'IE';
            If CountryCode = 'Sweden' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'SE';
            If CountryCode = '"Poland": ' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'PL';
            If CountryCode = 'Taiwan' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'TW';
            If CountryCode = 'Singapore' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'SG';
            If CountryCode = 'India' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'IN';
            If CountryCode = 'China' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'CN';
            If CountryCode = 'HongKong' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'HK';
            If CountryCode = 'Malaysia' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'MY';
            If CountryCode = 'Philippines' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'PH';
            If CountryCode = 'eBayMotors' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'eBayMotors';
            If CountryCode = 'CustomCode' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'US';
            If CountryCode = 'CanadaFrench' then
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'CAFR';
            //  end;

            If GetJsonvalue(ShippingAddress, 'zip_code').IsNull = false then begin

                G_InterimSalesHeader."Post Code" := GetJsonToken(ShippingAddress, 'zip_code').AsValue().AsText();
            end;
            If GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
                G_InterimSalesHeader.City := GetJsonToken(ShippingAddress, 'city').AsValue().AsText();
            end;
            If GetJsonvalue(ShippingAddress, 'street_1').IsNull = false then begin


                AddressLenght := StrLen(GetJsonToken(ShippingAddress, 'street_1').AsValue().AsText());
                if AddressLenght > 50 then begin
                    BigAddress := GetJsonToken(ShippingAddress, 'street_1').AsValue().AsText();
                    G_InterimSalesHeader.Address := CopyStr(BigAddress, 1, 50);
                    G_InterimSalesHeader."Address 2" := CopyStr(BigAddress, 51, 50);
                end else begin
                    //  G_InterimSalesHeader.Validate(Address, GetJsonToken(ShippingAddress, 'street_2').AsValue().AsText());
                    If GetJsonvalue(ShippingAddress, 'street_2').IsNull = false then begin
                        G_InterimSalesHeader.Validate("Address 2", GetJsonvalue(ShippingAddress, 'street_2').AsText());
                    end;
                end;
            end;


            if GetJsonvalue(ShippingAddress, 'street_1').IsNull = false then begin
                G_InterimSalesHeader."Ship-to Address" := GetJsonToken(ShippingAddress, 'street_1').AsValue().AsText().TrimStart();
            end;
            if GetJsonvalue(ShippingAddress, 'state').IsNull = false then begin
                G_InterimSalesHeader."Ship-to Address 2" := GetJsonToken(ShippingAddress, 'state').AsValue().AsText();
            end;
            if GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
                G_InterimSalesHeader."Ship-to City" := Copystr(GetJsonToken(ShippingAddress, 'city').AsValue().AsText(), 1, 30);
            end;

            if GetJsonvalue(ShippingAddress, 'zip_code').IsNull = false then begin
                G_InterimSalesHeader."Ship-to Post Code" := GetJsonToken(ShippingAddress, 'zip_code').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'firstname').IsNull = false then begin
                G_InterimSalesHeader."Ship-to Name" += GetJsonToken(ShippingAddress, 'firstname').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'lastname').IsNull = false then begin
                G_InterimSalesHeader."Ship-to Name" += ' ' + GetJsonToken(ShippingAddress, 'lastname').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'phone').IsNull = false then begin

                G_InterimSalesHeader."Ship-to Phone" := GetJsonToken(ShippingAddress, 'phone').AsValue().AsText();
            end;
            if GetJsonvalue(ShippingAddress, 'country').IsNull = false then begin
                G_InterimSalesHeader."Ship-to County" := GetJsonToken(ShippingAddress, 'country').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'country_iso_code').IsNull = false then begin
                CountryCode := GetJsonToken(ShippingAddress, 'country_iso_code').AsValue().AsText();
            end;
            IF CountryCode = 'GBR' THEN
                G_InterimSalesHeader."Ship-to Country/Region Code" := 'GB';

            if GetJsonvalue(OrderHeader, 'total_price').IsNull = false then begin  //Ranjit 26/7 its pervious Subtotal
                G_InterimSalesHeader.Validate("Order Amount", GetJsonvalue(OrderHeader, 'total_price').AsDecimal());

            end;


        end;
        TradePartner1.Reset();
        TradePartner1.SetRange(Code, ChannelCode);
        if TradePartner1.FindFirst then;
        G_InterimSalesHeader."Sell-to Customer No." := TradePartner1."Customer No.";
        G_InterimSalesHeader."Location Code" := TradePartner1.Location;
        G_InterimSalesHeader.Validate("Sell-to Customer No.", TradePartner1."Customer No.");
        G_InterimSalesHeader.Insert(true);

        OnAfterInsertIntSalesHeader(ChannelOrderId, HeaderObject, ChannelCode);
    End;

    local procedure OrderDispatchedConfirmation(ChannelCode: Code[20])
    var
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        L_HttpHeaders: HttpHeaders;
        L_HttpClient: HttpClient;
        L_HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        L_URL: Text;
    begin
        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETRANGE("Trade Partner Code", ChannelCode);
        HandledInterimSalesHeader.SetRange("Document Type", HandledInterimSalesHeader."Document Type"::Order);
        HandledInterimSalesHeader.SetFilter(Status, '%1', HandledInterimSalesHeader.Status::Dispatched);
        HandledInterimSalesHeader.SetRange("Document Date", Today);
        IF HandledInterimSalesHeader.FindSet() THEN begin
            repeat
                Clear(L_URL);
                GetCreadentils(ChannelCode);
                Clear(L_HttpClient);
                Clear(L_HttpContent);
                Clear(L_HttpHeaders);
                Clear(HttpResponse);
                L_HttpHeaders := L_HttpClient.DefaultRequestHeaders();
                L_HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
                L_HttpContent.GetHeaders(L_HttpHeaders);
                L_HttpHeaders.Clear();
                L_HttpHeaders.Add('Content-Type', 'application/json');
                L_URL := ServiceURL + 'orders/' + HandledInterimSalesHeader.order_id + '/ship?shop_id=' + ShopId;
                L_HttpClient.Put(L_URL, L_HttpContent, HttpResponse);

            until HandledInterimSalesHeader.Next() = 0;
        end;
    end;

    local procedure RequestRefunds(ChannelCode: Code[20])
    var
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        L_HttpHeaders: HttpHeaders;
        L_HttpClient: HttpClient;
        L_HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        L_URL: Text;
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        L_Body: Text;
        L_ArrayText: Text;
    begin
        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETRANGE("Trade Partner Code", ChannelCode);
        HandledInterimSalesHeader.SetRange("Document Type", HandledInterimSalesHeader."Document Type"::"Return Order");
        //HandledInterimSalesHeader.SetRange(RequestRefundOnPortal, false);
        IF HandledInterimSalesHeader.FindSet() THEN begin
            repeat
                Clear(L_ArrayText);
                HandledInterimSalesLine.Reset();
                HandledInterimSalesLine.SetRange("Document Type", HandledInterimSalesHeader."Document Type");
                HandledInterimSalesLine.SetRange("Document No", HandledInterimSalesHeader."No.");
                HandledInterimSalesLine.SetRange(Type, HandledInterimSalesLine.Type::Item);
                if HandledInterimSalesLine.FindSet() then begin
                    repeat
                        L_ArrayText += StrSubstNo('{"amount": %1,"currency_iso_code": "GBP","order_line_id": "%2","quantity": %3,"reason_code": "%4","shipping_amount": 0}', HandledInterimSalesLine.Quantity * HandledInterimSalesLine."Unit Price", HandledInterimSalesLine.order_line_id, HandledInterimSalesLine.Quantity, 17);
                    until HandledInterimSalesLine.Next() = 0;
                    L_ArrayText := L_ArrayText.TrimEnd(',');
                    L_Body := StrSubstNo('{"refunds": [%1]}', L_ArrayText);
                    Clear(L_URL);
                    Clear(L_HttpHeaders);
                    Clear(L_HttpContent);
                    Clear(L_HttpClient);
                    Clear(HttpResponse);
                    GetCreadentils(ChannelCode);
                    L_HttpContent.WriteFrom(L_Body);
                    L_HttpHeaders := L_HttpClient.DefaultRequestHeaders();
                    L_HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
                    L_HttpContent.GetHeaders(L_HttpHeaders);
                    L_HttpHeaders.Clear();
                    L_HttpHeaders.Add('Content-Type', 'application/json');
                    L_URL := ServiceURL + 'orders/refund?shop_id=' + ShopId;
                    L_HttpClient.Put(L_URL, L_HttpContent, HttpResponse);
                    if ((HttpResponse.HttpStatusCode = 200) OR (HttpResponse.HttpStatusCode = 204)) then begin
                        //HandledInterimSalesHeader.Validate(RequestRefundOnPortal, true);
                        //HandledInterimSalesHeader.Modify(true);
                    end;
                end;

            until HandledInterimSalesHeader.Next() = 0;
        end;
    end;

    local procedure SyncSecretSaleItemsOnPortal(StartParameter: Text)
    var
        IsHandled: Boolean;
    begin
        OnBeforeSyncSecretSaleItemsOnPortal(StartParameter, IsHandled);
        if IsHandled then
            exit;


        OnAfterSyncSecretSaleItemsOnPortal(StartParameter);
    end;

    local procedure TempInsertHeader(ChannelOrderId: Text; HeaderObject: JsonObject; ChannelCode: Code[20])
    var


        AddressLenght: Integer;
        BigAddress: Text[100];
        TotalWeight: Decimal;
        CountryCode: Code[20];
        FulfillmentChannel: Text[250];
        TradePartner1: Record "Trade Partner";
        L_No: Code[20];
    begin
        Clear(L_No);
        G_TempInterimHeader.Reset();
        G_TempInterimHeader.SetRange("Document Type", G_TempInterimHeader."Document Type"::Order);
        if G_TempInterimHeader.FindLast() then
            L_No := IncStr(G_TempInterimHeader."No.")
        else
            L_No := '10000';
        G_TempInterimHeader.Init();
        G_TempInterimHeader."Trade Partner Code" := ChannelCode;
        G_TempInterimHeader."Trade Partner Code" := CopyStr(ChannelCode, 1, 6);
        G_TempInterimHeader."Channel Order ID" := ChannelOrderId;
        G_TempInterimHeader."Document Type" := G_TempInterimHeader."Document Type"::Order;
        G_TempInterimHeader."File Name" := ChannelOrderId;
        G_TempInterimHeader."No." := L_No;

        if GetJsonvalue(HeaderObject, 'firstname').IsNull = false then begin
            G_TempInterimHeader."Bill- to Name" := CopyStr(GetJsonToken(HeaderObject, 'firstname').AsValue().AsText(), 1, 50);
        end;

        G_TempInterimHeader."External Document No." := ChannelOrderId;

        TradePartner1.Reset();
        TradePartner1.SetRange(Code, ChannelCode);
        if TradePartner1.FindFirst then;
        G_TempInterimHeader."Sell-to Customer No." := TradePartner1."Customer No.";
        G_TempInterimHeader."Location Code" := TradePartner1.Location;
        G_TempInterimHeader.Validate("Sell-to Customer No.", TradePartner1."Customer No.");
        G_TempInterimHeader.Insert(true);
    End;

    local procedure TempInsertLine(G_TempInterimHeader: Record "Interim Sales Header"; jsonMainReq: JsonObject)
    var
        p: Integer;
        DiscountArray: JsonArray;
        DiscountJsonobejt: JsonObject;
        Disconttoken: JsonToken;
        ShippingAgent: Record "Shipping Agent" temporary;
        ItemArray: JsonArray;
        cnt: Integer;
        i: Integer;
        j: Integer;
        k: Integer;
        LineObject: JsonObject;
        WebLineToken: JsonToken;
        DiscontCount: Integer;
        L_HttpHeaders: HttpHeaders;
        L_HttpClient: HttpClient;
        L_HttpContent: HttpContent;
        Body: Text;
        HttpResponse: HttpResponseMessage;
        URL: Text;
        ArrayText: Text;
    begin
        ItemArray := GetJsonToken(jsonMainReq, 'order_lines').AsArray();

        cnt := ItemArray.Count;
        if cnt > 0 then begin
            P := 0;
            Clear(ArrayText);
            for k := 0 to cnt - 1 do begin
                ItemArray.Get(k, WebLineToken);
                LineObject := WebLineToken.AsObject;
                G_TempInterimLine.Init();
                G_TempInterimLine."Document Type" := G_TempInterimLine."Document Type"::Order;
                G_TempInterimLine.Type := G_TempInterimLine.type::Item;
                G_TempInterimLine."Document No" := G_TempInterimHeader."No.";
                G_TempInterimLine."Line No." := G_TempInterimLine."Line No." + 10000;
                G_TempInterimLine."Channel Order ID" := G_TempInterimHeader."Channel Order ID";
                G_TempInterimLine."Pack Description" := G_TempInterimHeader."File Name";



                if GetJsonvalue(LineObject, 'order_line_id').IsNull = false then begin
                    G_TempInterimLine.FileName := GetJsonvalue(LineObject, 'order_line_id').AsText();
                    G_TempInterimLine.Validate(FileName, GetJsonvalue(LineObject, 'order_line_id').AsText());
                end;

                if GetJsonvalue(LineObject, 'price').IsNull = false then begin
                    G_TempInterimLine."Unit Price" := GetJsonvalue(LineObject, 'price').AsDecimal();
                end;

                G_TempInterimLine.Amount := Round(G_TempInterimLine."Unit Price" * G_TempInterimLine.Quantity);

                if GetJsonvalue(LineObject, 'product_title').IsNull = false then begin
                    G_TempInterimLine.Description := Copystr(GetJsonvalue(LineObject, 'product_title').AsText(), 1, 100);
                end;

                if GetJsonvalue(LineObject, 'product_sku').IsNull = false then begin
                    G_TempInterimLine."Channel SKU" := GetJsonvalue(LineObject, 'product_sku').AsCode;
                end;
                G_TempInterimLine.Insert(true);
                ArrayText += StrSubstNo('{"accepted": true,"id": "%1"},', G_TempInterimLine.FileName);

            End;
            //AcceptLines++
            ArrayText := ArrayText.TrimEnd(',');
            Body := StrSubstNo('{"order_lines": [%1]}', ArrayText);
            //AcceptLines--
            GetCreadentils(StartParameter);
            L_HttpContent.WriteFrom(Body);
            L_HttpHeaders := L_HttpClient.DefaultRequestHeaders();
            L_HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
            L_HttpContent.GetHeaders(L_HttpHeaders);
            L_HttpHeaders.Clear();
            L_HttpHeaders.Add('Content-Type', 'application/json');
            URL := ServiceURL + 'orders/' + G_TempInterimLine."Pack Description" + '/accept?shop_id=' + ShopId;
            L_HttpClient.Put(URL, L_HttpContent, HttpResponse);

        end;



    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertInterimSalesLine(InterimSalesHeader: Record "Interim Sales Header"; jsonMainReq: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertIntSalesHeader(ChannelOrderId: Text; HeaderObject: JsonObject; ChannelCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSyncSecretSaleItemsOnPortal(StartParameter: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInterimSalesLine(InterimSalesHeader: Record "Interim Sales Header"; jsonMainReq: JsonObject; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIntSalesHeader(ChannelOrderId: Text; HeaderObject: JsonObject; ChannelCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSyncSecretSaleItemsOnPortal(StartParameter: Text; var IsHandled: Boolean)
    begin
    end;

}