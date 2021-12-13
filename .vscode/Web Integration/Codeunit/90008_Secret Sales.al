codeunit 90008 "Secret Sales"
{
    trigger OnRun()
    begin

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

    procedure GetSecretSalesOrders()
    var
        ChannelCode: Code[20];
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        i: Integer;
        InterimSalesHeader: Record "Interim Sales Header";
        orderHeareToken: JsonToken;
        ChannelOrderID: Code[50];
        Customer: JsonObject;
    begin

        GetCreadentils(ChannelCode);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add(StrSubstNo('Authorization', '%1'), AccessKeyId);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        if HttpClient.Get(URL, HttpResponse) then begin
            HttpResponse.Content.ReadAs(responseText);
            OrderObject.ReadFrom(responseText);
            JsonObjectInArray := GetJsonToken(OrderObject, 'orders').AsArray();
            i := JsonObjectInArray.Count;
            NoOfRecs := JsonObjectInArray.Count;
            for i := 0 to NoOfRecs - 1 do begin
                If InterimSalesHeader.FindSet then;
                JsonObjectInArray.Get(i, orderHeareToken);
                OrderHeader := orderHeareToken.AsObject();
                Customer := GetJsonToken(OrderHeader, 'customer').AsObject();
                ShippingAddress := GetJsonToken(Customer, 'shipping_address').AsObject();
                BillingAddress := GetJsonToken(Customer, 'billing_address').AsObject();
                ChannelOrderID := GetJsonvalue(Customer, 'name').AsCode();

            end;
            InsertIntSalesHeader(ChannelOrderID, Customer, ChannelCode);
            InsertInterimSalesLine(InterimSalesHeader, Customer);
        end;
    End;

    procedure GetCreadentils("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin

        TradePartner.RESET;
        if ChannelCode = ChannelCode then begin
            if TradePartner.Get(ChannelCode) then begin
                AccessKeyId := TradePartner.AccessKeyId;
            End;
        end;

    End;

    local procedure InsertIntSalesHeader(ChannelOrderId: Text; HeaderObject: JsonObject; ChannelCode: Code[20])
    var


        AddressLenght: Integer;
        BigAddress: Text[100];
        TotalWeight: Decimal;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        CountryCode: Code[20];
        FulfillmentChannel: Text[250];
        TradePartner1: Record "Trade Partner";

    begin
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Trade Partner Code" := CopyStr(ChannelCode, 1, 6);
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := ChannelOrderId;

        if GetJsonvalue(BillingAddress, 'firstname').IsNull = false then begin
            InterimSalesHeader."Bill- to Name" := CopyStr(GetJsonToken(BillingAddress, 'firstname').AsValue().AsText(), 1, 50);
        end;


        InterimSalesHeader."External Document No." := ChannelOrderId;
        if GetJsonvalue(HeaderObject, 'created_date').IsNull = false then begin
            InterimSalesHeader."Order Placed At" := GetJsonToken(HeaderObject, 'created_date').AsValue().AsDateTime();
        end;

        // if GetJsonvalue(OrderHeader, 'gateway').IsNull = false then begin
        //     InterimSalesHeader."Payment Method" := GetJsonToken(OrderHeader, 'gateway').AsValue.AsCode();
        // end;

        // if GetJsonvalue(OrderHeader, 'email').IsNull = false then begin

        //     InterimSalesHeader."Email (Location)" := GetJsonToken(OrderHeader, 'email').AsValue.AsText();
        // end;
        if GetJsonvalue(OrderHeader, 'phone').IsNull = false then begin

            InterimSalesHeader."Ship-to Phone" := GetJsonToken(OrderHeader, 'phone').AsValue().AsCode();
        end;


        If GetJsonvalue(BillingAddress, 'country_iso_code').IsNull = false then begin
            CountryCode := GetJsonvalue(BillingAddress, 'country_iso_code').AsText();

            IF CountryCode = 'US' THEN
                InterimSalesHeader."Ship-to Country/Region Code" := 'US';
            IF (CountryCode = 'UK') OR (CountryCode = 'UNITED KINGDOM') THEN
                InterimSalesHeader."Ship-to Country/Region Code" := 'UK';
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
            //  end;

            If GetJsonvalue(ShippingAddress, 'zip_code').IsNull = false then begin

                InterimSalesHeader."Post Code" := GetJsonToken(ShippingAddress, 'zip_code').AsValue().AsText();
            end;
            If GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
                InterimSalesHeader.City := GetJsonToken(ShippingAddress, 'city').AsValue().AsText();
            end;
            If GetJsonvalue(ShippingAddress, 'street_1').IsNull = false then begin


                AddressLenght := StrLen(GetJsonToken(ShippingAddress, 'street_1').AsValue().AsText());
                if AddressLenght > 50 then begin
                    BigAddress := GetJsonToken(ShippingAddress, 'street_1').AsValue().AsText();
                    InterimSalesHeader.Address := CopyStr(BigAddress, 1, 50);
                    InterimSalesHeader."Address 2" := CopyStr(BigAddress, 51, 50);
                end else begin
                    InterimSalesHeader.Validate(Address, GetJsonToken(ShippingAddress, 'street_2').AsValue().AsText());
                    If GetJsonvalue(ShippingAddress, 'street_2').IsNull = false then begin
                        InterimSalesHeader.Validate("Address 2", GetJsonvalue(ShippingAddress, 'street_2').AsText());
                    end;
                end;
            end;

            // if GetJsonvalue(OrderHeader, 'email').IsNull = false then begin
            //     InterimSalesHeader.Validate("Buyer Email", CopyStr(GetJsonvalue(OrderHeader, 'email').AsText(), 1, 50));
            //     InterimSalesHeader."Buyer Email" := Copystr(GetJsonToken(OrderHeader, 'email').AsValue().AsText(), 1, 50);
            // end;
            if GetJsonvalue(ShippingAddress, 'street_1').IsNull = false then begin
                InterimSalesHeader."Ship-to Address" := GetJsonToken(ShippingAddress, 'street_1').AsValue().AsText();
            end;
            if GetJsonvalue(ShippingAddress, 'street_2').IsNull = false then begin
                InterimSalesHeader."Ship-to Address 2" := GetJsonToken(ShippingAddress, 'street_2').AsValue().AsText();
            end;
            if GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
                InterimSalesHeader."Ship-to City" := Copystr(GetJsonToken(ShippingAddress, 'city').AsValue().AsText(), 1, 30);
            end;

            if GetJsonvalue(ShippingAddress, 'zip_code').IsNull = false then begin
                InterimSalesHeader."Ship-to Post Code" := GetJsonToken(ShippingAddress, 'zip_code').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'firstname').IsNull = false then begin
                InterimSalesHeader."Ship-to Name" := GetJsonToken(ShippingAddress, 'firstname').AsValue().AsText();
            end;
            if GetJsonvalue(ShippingAddress, 'phone').IsNull = false then begin

                InterimSalesHeader."Ship-to Phone" := GetJsonToken(ShippingAddress, 'phone').AsValue().AsText();
            end;
            if GetJsonvalue(ShippingAddress, 'country').IsNull = false then begin
                InterimSalesHeader."Ship-to County" := GetJsonToken(ShippingAddress, 'country').AsValue().AsText();
            end;

            if GetJsonvalue(OrderHeader, 'total_price').IsNull = false then begin  //Ranjit 26/7 its pervious Subtotal
                InterimSalesHeader.Validate("Order Amount", GetJsonvalue(OrderHeader, 'total_price').AsDecimal());

            end;


        end;
        TradePartner1.Reset();
        TradePartner1.SetRange(Code, CopyStr((ChannelCode), 1, 7));
        if TradePartner1.FindFirst then;
        InterimSalesHeader."Sell-to Customer No." := TradePartner1."Customer No.";
        InterimSalesHeader."Location Code" := TradePartner1.Location;
        InterimSalesHeader.Validate("Sell-to Customer No.", TradePartner1."Customer No.");

    End;

    local procedure InsertInterimSalesLine(InterimSalesHeader: Record "Interim Sales Header"; jsonMainReq: JsonObject)
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
        InterimSalesLine: Record "Interim Sales Line" temporary;
        DiscontCount: Integer;


    begin
        ItemArray := GetJsonToken(jsonMainReq, 'order_lines').AsArray();

        cnt := ItemArray.Count;
        if cnt > 0 then begin
            P := 0;
            for k := 0 to cnt - 1 do begin
                ItemArray.Get(k, WebLineToken);
                LineObject := WebLineToken.AsObject;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");


                if GetJsonvalue(LineObject, 'quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'quantity').AsDecimal;
                    InterimSalesLine.Validate(Quantity, GetJsonvalue(LineObject, 'quantity').AsDecimal);
                end;

                if GetJsonvalue(LineObject, 'product_id').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'product_id').AsText();
                    InterimSalesLine.Validate("Channel Item Id", GetJsonvalue(LineObject, 'product_id').AsText());
                end;

                if GetJsonvalue(LineObject, 'price').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'price').AsDecimal();
                end;

                InterimSalesLine.Amount := Round(InterimSalesLine."Unit Price" * InterimSalesLine.Quantity);

                if GetJsonvalue(LineObject, 'title').IsNull = false then begin
                    InterimSalesLine.Description := Copystr(GetJsonvalue(LineObject, 'title').AsText(), 1, 100);
                end;
                DiscountArray := GetJsonToken(LineObject, 'discount_allocations').AsArray();
                DiscontCount := DiscountArray.Count;
                if DiscontCount <> 0 then begin
                    DiscountArray.Get(p, Disconttoken);
                    DiscountJsonobejt := Disconttoken.AsObject;
                    if GetJsonvalue(DiscountJsonobejt, 'amount').IsNull = false then begin
                        InterimSalesLine.Validate(Discount, GetJsonvalue(DiscountJsonobejt, 'amount').AsDecimal());
                    end;
                End;

                if GetJsonvalue(LineObject, 'sku').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'sku').AsCode;
                end;
            End;
        end;



    end;

    var
        myInt: Integer;
        AccessKeyId: Text;
        SecretAccessKey: Text;
        OrderObject: JsonObject;
        JsonObjectInArray: JsonArray;
        NoOfRecs: Integer;
        ShippingAddress: JsonObject;
        BillingAddress: JsonObject;
        OrderHeader: JsonObject;
}