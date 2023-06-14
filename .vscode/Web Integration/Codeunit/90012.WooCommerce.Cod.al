codeunit 90012 "Woo Commerce"
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
                    ListOrders(StartParameter);
                End;
            SyncShipmentLabel:
                BEGIN
                    SyncShipment(StartParameter);
                End;

            SyncItemLabel:
                Begin
                    GetWOOCOMMERItem(StartParameter);
                End;

            SyncUpdateInventoryLabel:
                begin
                    UpdateInventory(StartParameter);
                end;
            CustomerSyncLabel:
                begin
                    SyncCustomer(StartParameter);
                end;
        end;
    End;

    procedure ListOrders(ChannelCode: Code[250]);
    var
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        pageNo: text;
        PageNumber: Integer;
        NoofRecs: Integer;
        num: Integer;
        consumerKey: Text;
        consumerSecret: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        MaxResultsPerPage: Text;
        responseText: Text;
        i: Integer;
        noOfResult: Integer;
        jObject: JsonObject;
        WebHeaderObject: JsonObject;
        webLinesObject: JsonObject;
        orderHeaderObject: JsonObject;
        jArray: JsonArray;
        orderToken: JsonToken;
        ChannelOrderID: Code[20];
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        TradePartner1: Record "Trade Partner";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        URL: Text;
        HttpRequest: HttpRequestMessage;
        HttpClient: HttpClient;
        URLText: Text[250];
        InterimSalesLine: Record "Interim Sales Line" temporary;
    begin
        PageNumber := 1;
        TradePartner1.Get(ChannelCode);
        consumerKey := TradePartner1.AccessKeyId;
        consumerSecret := TradePartner1.SecretAccessKey;
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(consumerKey, consumerSecret));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        Clear(URLText);
        if TradePartner1.Code = 'WOOCOMMERC' then begin
            repeat
                pageNo := Format(PageNumber);
                URL := StrSubstNo('%1/orders?consumer_key=%2&consumer_secret=%3&status=processing&page=%4', TradePartner1."Sevice/API URL", consumerKey, consumerSecret, pageNo);
                if HttpClient.Get(URL, ResponseMessage) then begin
                    ResponseMessage.Content.ReadAs(responseText);
                    jArray.ReadFrom(responseText);
                    i := jArray.Count();
                    noOfResult := jArray.Count();
                    NoofRecs := jArray.Count();
                    for i := 0 to noOfResult - 1 do begin
                        jArray.Get(i, orderToken);
                        InterimSalesHeader.DeleteAll();
                        InterimSalesLine.DeleteAll();
                        ShipmnetTracking.DeleteAll();
                        PaymentDetails.DeleteAll();
                        orderHeaderObject := orderToken.AsObject();
                        //WebHeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                        BillingAddress := GetJsonToken(orderHeaderObject, 'billing').AsObject();
                        ShippingAddress := GetJsonToken(orderHeaderObject, 'shipping').AsObject();
                        ChannelOrderID := GetJsonvalue(orderHeaderObject, 'id').AsCode();
                        InsertInSalesHeader(orderHeaderObject, BillingAddress, ShippingAddress, ChannelCode, InterimSalesHeader, ChannelOrderID, ShipmnetTracking);
                        InsertInSalesLine(InterimSalesHeader, orderHeaderObject, InterimSalesLine);
                        CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                    end;
                end;
                PageNumber += 1;
            Until NoofRecs < 10
        end;
        MESSAGE('Order Sync Completed...');
    end;

    local procedure InsertInSalesHeader(orderHeaderObject: JsonObject; BillingAddress: JsonObject; ShippingAddress: JsonObject; ChannelCode: Code[20]; var InterimSalesHeader: Record "Interim Sales Header" temporary; ChannelOrderID: Code[20]; ShippmentTracking: Record "Shipment Tracking" temporary)
    var
        paymentMethod: Text;
        CountryCode: Text;
        TradePartner1: Record "Trade Partner";
        ShippingDate: DateTime;
        FullfillmentChannel: Text;
        OrderType: text;
        Orderdate: DateTime;
        BigAddress: text[100];
        Status: Text;

    begin

        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := ChannelOrderID;
        InterimSalesHeader."Package Tracking No." := ChannelOrderID;

        //  InterimSalesHeader."Doc Type" := InterimSalesHeader."Doc Type"::WebOrder;
        //   InterimSalesHeader."Sales Order Type" := InterimSalesHeader."Sales Order Type"::"Web Order";

        If GetJsonvalue(BillingAddress, 'country').IsNull = false then begin
            InterimSalesHeader.Validate("Bill-to County", GetJsonvalue(BillingAddress, 'country').AsText());
        End;

        If GetJsonvalue(BillingAddress, 'postcode').IsNull = false then begin
            InterimSalesHeader.Validate("Post Code", GetJsonvalue(BillingAddress, 'postcode').AsCode());

        end;

        if GetJsonvalue(BillingAddress, 'city').IsNull = false then begin
            InterimSalesHeader.Validate("City", GetJsonvalue(BillingAddress, 'city').AsText());
        end;

        if GetJsonvalue(BillingAddress, 'email').IsNull = false then begin
            InterimSalesHeader.Validate("Buyer Email", GetJsonvalue(BillingAddress, 'email').AsText());

        end;
        if GetJsonvalue(ShippingAddress, 'address_1').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Address", CopyStr(GetJsonvalue(ShippingAddress, 'address_1').AsText(), 1, 50));
        end;
        if GetJsonvalue(ShippingAddress, 'address_2').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Address 2", Copystr(GetJsonvalue(ShippingAddress, 'address_2').AsText(), 1, 50));
        end;
        if GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to city", Copystr(GetJsonvalue(ShippingAddress, 'city').AsText(), 1, 50));
        end;
        if GetJsonvalue(ShippingAddress, 'postcode').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Post Code", Copystr(GetJsonvalue(ShippingAddress, 'postcode').AsText(), 1, 50));
        end;


        if GetJsonvalue(ShippingAddress, 'country').IsNull = false then begin
            InterimSalesHeader.Validate("ship-to country", GetJsonvalue(ShippingAddress, 'country').AsText());
        end;

        if GetJsonvalue(ShippingAddress, 'first_name').IsNull = false then begin
            InterimSalesHeader.Validate("Ship-to Name", GetJsonvalue(ShippingAddress, 'first_name').AsText());
        end;

        if GetJsonvalue(BillingAddress, 'first_name').IsNull = false then begin
            InterimSalesHeader.Validate("Bill- to Name", GetJsonvalue(BillingAddress, 'first_name').AsText());
        end;
        if GetJsonvalue(BillingAddress, 'address_1').IsNull = false then begin
            BigAddress := GetJsonToken(BillingAddress, 'address_1').AsValue().AsText();
            InterimSalesHeader.Address := CopyStr(BigAddress, 1, 50);
            InterimSalesHeader."Address 2" := CopyStr(BigAddress, 51, 50);
        end;

        InterimSalesHeader.Validate("External Document No.", ChannelOrderId);


        if GetJsonvalue(orderHeaderObject, 'payment_method').IsNull = false then begin
            paymentMethod := GetJsonvalue(orderHeaderObject, 'payment_method').AsText();

        end;
        if GetJsonvalue(orderHeaderObject, 'date_created').IsNull = false then begin
            InterimSalesHeader."Order Placed At" := GetJsonvalue(orderHeaderObject, 'date_created').AsDateTime();
            Orderdate := GetJsonvalue(orderHeaderObject, 'date_created').AsDateTime();
            InterimSalesHeader."Document Date" := DT2DATE(Orderdate);

        end;


        if GetJsonvalue(orderHeaderObject, 'total').IsNull = false then begin
            InterimSalesHeader.validate("Order Amount", GetJsonvalue(orderHeaderObject, 'total').AsDecimal());
        end;

        if GetJsonvalue(orderHeaderObject, 'status').IsNull = false then begin
            Status := GetJsonvalue(orderHeaderObject, 'status').AsText();
        end;
        if Status = 'cancelled' then begin
            InterimSalesHeader.VALIDATE(Status, InterimSalesHeader.Status::Rejected);
        end;
        if Status = 'completed' then begin
            InterimSalesHeader.VALIDATE(Status, InterimSalesHeader.Status::Confirmed);
        end;
        if Status = 'pending' then begin
            InterimSalesHeader.VALIDATE(Status, InterimSalesHeader.Status::"In Progress");
        end;


        InterimSalesHeader.VALIDATE("Pickup Date", TODAY + 1);
        InterimSalesHeader.VALIDATE("Pickup Time", 170000T);
        InterimSalesHeader.VALIDATE("No. Of Parcels", 1);
        InterimSalesHeader.INSERT(TRUE);

    End;

    local procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; orderHeaderObject: JsonObject; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        CourierIntegration: Codeunit "Courier Integration";
        SKU: Code[30];
        OrderAmount: Decimal;
        SumofQty: Integer;
        LineNo: Integer;
        ShippingAgent: Record "Shipping Agent";
        ShippingPrice: Decimal;
        ItemArray: JsonArray;
        itemCount: Integer;
        IsError: Boolean;
        ShipHeader: JsonObject;
        i: Integer;
        j: Integer;
        k: Integer;
        LineObject: JsonObject;
        WebLineToken: JsonToken;
        Item: Record Item;
        itemNo: Text;
        ChannelSKU: Code[20];
        GLAccount: Text;
        TradePartner2: Record "Trade Partner";
        Couier: Text;
        LineCount: Integer;
        ShippingRule: Record "OCHANNEL Shipping Rule";

    begin
        ItemArray := GetJsonToken(orderHeaderObject, 'line_items').AsArray();

        itemCount := ItemArray.Count;
        if itemCount > 0 then begin

            for k := 0 to itemCount - 1 do begin
                ItemArray.Get(k, WebLineToken);
                LineObject := WebLineToken.AsObject;
                LineNo := 1000 + k;
                InterimSalesLine.Init;
                InterimSalesLine."Line No." := LineNo;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";
                InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";
                InterimSalesLine.Weight := 1;


                if GetJsonvalue(LineObject, 'quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'quantity').AsDecimal;
                end;

                if GetJsonvalue(LineObject, 'product_id').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'product_id').AsText();
                end;


                if GetJsonvalue(LineObject, 'price').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'price').AsDecimal();
                end;
                // if GetJsonvalue(LineObject, 'total').IsNull = false then begin
                //     InterimSalesLine.Amount := GetJsonvalue(LineObject, 'total').AsDecimal();
                // end;
                //No needed
                if GetJsonvalue(LineObject, 'name').IsNull = false then begin
                    InterimSalesLine.Description := CopyStr(GetJsonvalue(LineObject, 'name').AsText(), 1, 100);
                end;

                if GetJsonvalue(LineObject, 'sku').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'sku').AsCode();

                    SKU := GetJsonvalue(LineObject, 'sku').AsCode()
                end;
                GETUOM(SKU);//for UOM 
                InterimSalesLine."Unit of Measure Code" := ItemUoM;

                InterimSalesLine.Insert(true);

            end;
            InterimSalesLine.SetFilter("Item Type", '<>%1', InterimSalesLine."Item Type"::Component);
            if InterimSalesLine.FindSet() then begin
                repeat
                    SumofQty += InterimSalesLine.Quantity;
                until InterimSalesLine.Next() = 0;
            end;
            if InterimSalesHeader."Trade Partner Code" <> '' then begin
                InterimSalesHeader."No. of Items" := SumofQty;
                // CourierIntegration.GetNavShippingAgentFromWebShipping(InterimSalesHeader."Trade Partner Code", '', InterimSalesHeader."Web Shipment Method", ShippingRule);
                // InterimSalesHeader."Web Shipping Agent" := ShippingRule."Shipping Agent";
                // InterimSalesHeader."Shipping Agent Service Code" := ShippingRule."Shipping Agent Service";
                // InterimSalesHeader."Shipping Agent Code" := ShippingRule."Shipping Agent";
                // InterimSalesHeader."Shipment Method Code" := ShippingRule."NAV Shipment Method";
                InterimSalesHeader.MODIFY;
            end;
        end;


    End;


    procedure SyncCustomer(ChannelCode: Code[20])
    var
        k: Integer;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpClient: HttpClient;
        Httpresponse: HttpResponseMessage;
        responseText: Text;
        jsonObjet: JsonObject;
        jArray: JsonArray;
        billingAddArray: JsonArray;
        shippingaAddArray: JsonArray;
        i: Integer;
        customerToken: JsonToken;
        URL: Text;
        TradePartner: Record "Trade Partner";
        InterimCustomer: Record "Interim Customer";
        Customer: Record Customer;
        j: Integer;
        NoOfBillAddRecs: Integer;
        NoOfShippAddRecs: Integer;
        NoOfRecs: Integer;
        billingAddressToken: JsonToken;
        shippingAddressToken: JsonToken;
        HandledCustomer: Record "Handled Customer";
        consumerkey: Text;
        consumerSecret: Text;
        serviceUrl: Text;
        bool: Boolean;
        Count: Integer;
        PageNumber: Integer;
    begin
        PageNumber := 1;
        if TradePartner.Get(ChannelCode) then;
        consumerkey := TradePartner.AccessKeyId;
        consumerSecret := TradePartner.SecretAccessKey;
        serviceUrl := TradePartner."Sevice/API URL";
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(consumerkey, consumerSecret));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        URL := serviceUrl + '/customers?consumer_key=' + consumerkey + '&consumer_secret=' + consumerSecret;
        if HttpClient.Get(URL, Httpresponse) then begin
            Httpresponse.Content.ReadAs(responseText);
            Windows.Open(Text006 + ' @1@@@@@@@@@@@@@\' + InterimCustomer.FieldCaption("No.") + ' #3##########');
            jArray.ReadFrom(responseText);
            i := jArray.Count();
            NoOfRecs := jArray.Count();
            for i := 0 to NoOfRecs - 1 do begin
                jArray.Get(i, customerToken);
                customerHeaderObject := customerToken.AsObject;
                IF bool then begin
                    Count += 1;
                    IF NoOfRecs <= 100 then
                        Windows.Update(1, (Count / NoOfRecs * 10000) DIV 1)
                    else
                        IF Count MOD (NoOfRecs DIV 100) = 0 then BEGIN
                            Windows.Update(1, (Count / NoOfRecs * 10000) DIV 1)
                        END;
                    Windows.Update(3, Format(InterimCustomer."No."));
                end;
                InterimCustomer.Reset;
                InterimCustomer.SetRange("Channel Code", ChannelCode);
                InterimCustomer.SetRange("No.", GetJsonvalue(customerHeaderObject, 'id').AsCode());
                if not InterimCustomer.FindFirst then begin
                    HandledCustomer.Reset;
                    HandledCustomer.SetRange("Trade Partner Code", ChannelCode);
                    HandledCustomer.SetRange("Web Customer No.", GetJsonvalue(customerHeaderObject, 'id').AsCode());
                    if not HandledCustomer.FindFirst then begin
                        InterimCustomer.Init;
                        InterimCustomer.Validate("Channel Code", ChannelCode);
                        if GetJsonvalue(customerHeaderObject, 'id').IsNull = false then begin
                            InterimCustomer.Validate("No.", GetJsonvalue(customerHeaderObject, 'id').AsCode());
                        end;
                        if GetJsonvalue(customerHeaderObject, 'email').IsNull = false then begin
                            InterimCustomer.Validate("E-Mail", GetJsonvalue(customerHeaderObject, 'email').AsText());
                        end;
                        if GetJsonvalue(customerHeaderObject, 'first_name').IsNull = false then begin
                            InterimCustomer.Validate(Name, CopyStr(GetJsonvalue(customerHeaderObject, 'first_name').AsText(), 1, 50));
                        end;

                        billingaddressHeaderObject := GetJsonToken(customerHeaderObject, 'billing').AsObject();

                        if GetJsonvalue(billingaddressHeaderObject, 'company').IsNull = false then begin
                            InterimCustomer.Validate("Company Name", GetJsonvalue(billingaddressHeaderObject, 'company').AsText());
                        end;
                        if GetJsonvalue(billingaddressHeaderObject, 'address_1').IsNull = false then begin
                            InterimCustomer.Validate(Address, GetJsonvalue(billingaddressHeaderObject, 'address_1').AsText());
                        end;
                        if GetJsonvalue(billingaddressHeaderObject, 'address_2').IsNull = false then begin
                            InterimCustomer.Validate("Address 2", GetJsonvalue(billingaddressHeaderObject, 'address_2').AsText());
                        end;
                        if GetJsonvalue(billingaddressHeaderObject, 'city').IsNull = false then begin
                            InterimCustomer.Validate(City, GetJsonvalue(billingaddressHeaderObject, 'city').AsText());
                        end;
                        if GetJsonvalue(billingaddressHeaderObject, 'postcode').IsNull = false then begin
                            InterimCustomer.Validate("Post Code", GetJsonvalue(billingaddressHeaderObject, 'postcode').AsText());
                        end;
                        if GetJsonvalue(billingaddressHeaderObject, 'country').IsNull = false then begin
                            InterimCustomer.Validate(Country, GetJsonvalue(billingaddressHeaderObject, 'country').AsText());
                        end;
                        if GetJsonvalue(billingaddressHeaderObject, 'phone').IsNull = false then begin
                            InterimCustomer.Validate("Phone No", GetJsonvalue(billingaddressHeaderObject, 'phone').AsText());
                        end;

                        shippingaddressHeaderObject := GetJsonToken(customerHeaderObject, 'shipping').AsObject();

                        if GetJsonvalue(shippingaddressHeaderObject, 'first_name').IsNull = false then begin
                            InterimCustomer.Validate("Shipping Contact", GetJsonvalue(shippingaddressHeaderObject, 'first_name').AsText());
                        end;
                        if GetJsonvalue(shippingaddressHeaderObject, 'address_1').IsNull = false then begin
                            InterimCustomer.Validate("Shipping Address", GetJsonvalue(shippingaddressHeaderObject, 'address_1').AsText());
                        end;
                        if GetJsonvalue(shippingaddressHeaderObject, 'address_2').IsNull = false then begin
                            InterimCustomer.Validate("Shipping Address 2", GetJsonvalue(shippingaddressHeaderObject, 'address_2').AsText());
                        end;
                        if GetJsonvalue(shippingaddressHeaderObject, 'city').IsNull = false then begin
                            InterimCustomer.Validate("Shipping City", GetJsonvalue(shippingaddressHeaderObject, 'city').AsText());
                        end;
                        if GetJsonvalue(shippingaddressHeaderObject, 'postcode').IsNull = false then begin
                            InterimCustomer.Validate("Shipping Post Code", GetJsonvalue(shippingaddressHeaderObject, 'postcode').AsText());
                        end;
                        if GetJsonvalue(shippingaddressHeaderObject, 'country').IsNull = false then begin
                            InterimCustomer.Validate("Shipping Country", GetJsonvalue(shippingaddressHeaderObject, 'country').AsText());
                        end;
                        InterimCustomer.Insert;
                    end;
                end;
            end;
        end;
        Message('Customer Sync Completed...');
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

    procedure GetWOOCOMMERItem(ChannelCode: Code[20])
    var
        NoOfRecs: Integer;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        responseText: Text;
        jObject: JsonObject;
        jsonAray: JsonArray;
        i: Integer;
        noOfResults: Integer;
        productToken: JsonToken;
        ChannelItemListing: Record "Channel Item Listing";
        SKU: Code[100];
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        Count: Integer;
        Windows: Dialog;
        bool: Boolean;
        TradePartner1: Record "Trade Partner";
        consumerKey: Text;
        consumerSecret: Text;
        pageNo: text;
        PageNumber: Integer;
    begin
        TradePartner1.Get(ChannelCode);
        consumerKey := TradePartner1.AccessKeyId;
        consumerSecret := TradePartner1.SecretAccessKey;
        PageNumber := 1;
        HttpHeaders := Client.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(consumerKey, consumerSecret));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        if TradePartner1.Code = ChannelCode then begin
            repeat
                pageNo := Format(PageNumber);
                URL := StrSubstNo('%1/products?consumer_key=%2&consumer_secret=%3&page=%4', TradePartner1."Sevice/API URL", consumerKey, consumerSecret, pageNo);
                if (Client.Get(URL, ResponseMessage)) then begin
                    ResponseMessage.Content.ReadAs(responseText);
                    jsonAray.ReadFrom(responseText);
                    i := jsonAray.Count();
                    NoOfRecs := jsonAray.Count();
                    noOfResults := jsonAray.Count();
                    for i := 0 to noOfResults - 1 do begin
                        jsonAray.Get(i, productToken);
                        productObject := productToken.AsObject;
                        IF bool THEN BEGIN
                            Count += 1;
                            IF noOfResults <= 100 THEN
                                Windows.UPDATE(1, (Count / noOfResults * 10000) DIV 1)
                            ELSE
                                IF Count MOD (noOfResults DIV 100) = 0 THEN BEGIN
                                    Windows.UPDATE(1, (Count / noOfResults * 10000) DIV 1)
                                END;
                            Windows.UPDATE(3, FORMAT(ChannelItemListing."Channel Code"));
                        END;

                        ChannelItemListing.RESET;
                        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                        ChannelItemListing.SETRANGE("Channel SKU", GetJsonvalue(productObject, 'sku').AsCode());

                        IF ChannelItemListing.FINDFIRST THEN BEGIN
                            UpdateProduct(FALSE, ChannelItemListing);
                        END

                        ELSE BEGIN
                            CreateProduct(TRUE);
                        END;
                    end;
                end;
                PageNumber += 1;
            Until NoOfRecs < 10
        end;
        Message('Item sync Completed...');

    end;

    local procedure CreateProduct(bool: Boolean)
    var
        ItemName: Text;
        ItemDescription: Text;
        ChannelItemListing: Record "Channel Item Listing";
        unitPrice: Decimal;
        ChannelInvquantity: Decimal;
        ChannelInvOldquantity: Decimal;
        InvItemId: BigInteger;
        ITEM: Record 27;
        NetWeight: Decimal;
        ItemSKU: Text;
    begin

        CLEAR(ChannelItemListing);
        ChannelItemListing."Channel Code" := 'WOOCOMMERC';

        if GetJsonvalue(productObject, 'sku').IsNull = false then begin
            ChannelItemListing.Validate("Channel SKU", GetJsonvalue(productObject, 'sku').AsCode());
        end;

        if GetJsonvalue(productObject, 'id').IsNull = false then begin
            ChannelItemListing.Validate("ASIN No", GetJsonvalue(productObject, 'id').AsCode());
            ChannelItemListing."ASIN No" := GetJsonToken(productObject, 'id').AsValue().AsCode();
        end;

        if GetJsonvalue(productObject, 'price').IsNull = false then begin
            ChannelItemListing.Validate("Unit Price", GetJsonvalue(productObject, 'price').AsDecimal());
        end;

        if GetJsonvalue(productObject, 'name').IsNull = false then begin
            ChannelItemListing.Validate("Channel Title", Copystr(GetJsonvalue(productObject, 'name').AsText(), 1, 50));
        end;
        ChannelItemListing.Insert();
    end;

    procedure UpdateProduct(bool: Boolean; CIL: Record "Channel Item Listing")
    var
    begin
        CIL.Validate("Channel SKU", CIL."Channel SKU");
        CIL.Validate("ASIN No", CIL."ASIN No");

        if GetJsonvalue(productObject, 'price').IsNull = false then begin
            CIL.Validate("Unit Price", GetJsonvalue(productObject, 'price').AsDecimal());
        end;

        if GetJsonvalue(productObject, 'name').IsNull = false then begin
            CIL.Validate("Channel Title", Copystr(GetJsonvalue(productObject, 'name').AsText(), 1, 50));
        end;
        CIL.Modify();
    end;

    procedure UpdateInventory(ChannelCode: Code[20])
    var
        CIL: Record "Channel Item Listing";
        URL: Text;
        TradePartner1: Record "Trade Partner";
        Users: Text;
        Password: Text;
        HttpHeaders: HttpHeaders;
        Client: HttpClient;
        HttpContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        TrackingNo: Text;
        id: Code[50];
        ChannelQty: Text;
        responseText: Text;

    begin
        CIL.Reset();
        CIL.SetRange("Inventory Synced", false);
        CIL.SetRange("ASIN No", '1844');
        if CIL.FindFirst() then begin
            TradePartner1.Get('WOOCOMMERC');
            Users := TradePartner1.AccessKeyId;
            Password := TradePartner1.SecretAccessKey;
            HttpHeaders := Client.DefaultRequestHeaders();
            //  HttpHeaders.Add('Authorization', CreateBasicAuth('ck_2baa8ea5b0272ab1465bdab1d636095afa367dd6', 'cs_a8bbe5a9e61e93c8326d615e180a2225e735876e'));
            HttpHeaders.Add('Authorization', CreateBasicAuth(Users, Password));
            repeat
                id := CIL."ASIN No";
                ChannelQty := Format(CIL."Channel Inventory");
                ChannelQty := StrSubstNo('{"stock_quantity":"%1"}', ChannelQty);
                HttpContent.WriteFrom(ChannelQty);
                HttpContent.GetHeaders(HttpHeaders);
                HttpHeaders.Clear();
                HttpHeaders.Add('Content-Type', 'application/json');
                // URL := 'https://cannabotech.co.uk/wp-json/wc/v3/products';
                URL := StrSubstNo('%1/products/%2', TradePartner1."Sevice/API URL", id);
                if Client.Put(URL, HttpContent, ResponseMessage) then begin
                    ResponseMessage.Content.ReadAs(responseText);
                    CIL."Inventory Synced" := TRUE;
                    CIL.Action := CIL.Action::Updated;
                    CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    CIL.Remarks := 'Inventory updated successfully';
                    CIL.MODIFY;
                end Else begin
                    CIL.Modify();
                end;
            until CIL.Next = 0;
        end;

    end;

    procedure UpdateStatusComplete()
    var
        SalesHeader: Record "Sales Header";
        Id: Code[20];
        TradePartner1: Record "Trade Partner";
        Users: Text;
        Password: Text;
        HttpHeaders: HttpHeaders;
        Client: HttpClient;
        TrackingNo: Text;
        HttpContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        responseText: Text;

    begin
        SalesHeader.Reset();
        SalesHeader.SetFilter("Completely Shipped", 'True');
        SalesHeader.SetFilter("External Document No.", '<>%1''');
        if SalesHeader.FindFirst() then begin
            TradePartner1.Get('WOOCOMMERC');
            Users := TradePartner1.AccessKeyId;
            Password := TradePartner1.SecretAccessKey;
            HttpHeaders := Client.DefaultRequestHeaders();
            //  HttpHeaders.Add('Authorization', CreateBasicAuth('ck_2baa8ea5b0272ab1465bdab1d636095afa367dd6', 'cs_a8bbe5a9e61e93c8326d615e180a2225e735876e'));
            HttpHeaders.Add('Authorization', CreateBasicAuth(Users, Password));
            repeat
                Id := SalesHeader."External Document No.";
                TrackingNo := '{"status":"complete"}';
                HttpContent.WriteFrom(TrackingNo);
                HttpContent.GetHeaders(HttpHeaders);
                HttpHeaders.Clear();
                HttpHeaders.Add('Content-Type', 'application/json');
                // URL := 'https://cannabotech.co.uk/wp-json/wc/v3/products';
                URL := StrSubstNo('%1/orders/%2', TradePartner1."Sevice/API URL", id);
                if Client.Put(URL, HttpContent, ResponseMessage) then begin
                    ResponseMessage.Content.ReadAs(responseText);
                    //  ISH.Status := ISH.Status::"In Progress";
                end;
            until SalesHeader.Next = 0;
        end;
        Message('Status Update Completed');
    end;

    local procedure GetItemNoFromSKU(ChannelSKU: Text[20]): Text
    var
        ITEM: Record Item; //27
        ItemCrossReference: Record "Item Reference"; //5717
        ChannelItemListing: Record "Channel Item Listing"; //90014
    begin

        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel SKU", ChannelSKU);
        IF ChannelItemListing.FINDSET THEN
            EXIT(ChannelItemListing."Item No.");
    End;

    local procedure GETUOM(SKU: Text): Text
    var

        RecItemCrossReference: Record "Item Reference";
        RecChannelItemListing: Record "Channel Item Listing";
        // ItemUoM: Code[10];
        ItemChannelCode: Text;
        item: Record Item;
    begin
        Item.Reset();
        Item.SetRange("No.", SKU);
        IF Item.FINDFIRST THEN BEGIN
            CLEAR(ItemUoM);
            ItemUoM := Item."Base Unit of Measure";

        END;
        EXIT(ItemUoM);
    end;

    procedure SyncShipment(ChannelCode: Code[250])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            case TradePartner."Process Order Type" of
                TradePartner."Process Order Type"::"Internal Pick":
                    begin

                    end;

                TradePartner."Process Order Type"::"Single Order", TradePartner."Process Order Type"::"Consolidate Order":
                    begin
                        UpdateTrackingNo()
                    end;
            end;
        end;
    end;

    procedure UpdateTrackingNo()
    var
        ISH: Record "Interim Sales Header";
        IHL: Record "Interim Sales Line";
        URL: Text;
        TradePartner: Record "Trade Partner";
        Users: Text;
        Password: Text;
        HttpHeaders: HttpHeaders;
        Client: HttpClient;
        HttpContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        TrackingNo: Text;
        id: Code[50];
        TrackingNumber: Code[30];
        responseText: Text;
        SalesShptHdr: Record "Sales Shipment Header";
        IsHandled: Boolean;
        tracking_provider: Text;

    begin
        OnBeforeUpdateTrackingNo(SalesShptHdr, IsHandled);
        if IsHandled then
            exit;

        SalesShptHdr.Reset();
        SalesShptHdr.SetFilter("Package Tracking No.", '<>%1', '');
        if SalesShptHdr.FindSet() then
            repeat
                Users := TradePartner.AccessKeyId;
                Password := TradePartner.SecretAccessKey;
                HttpHeaders := Client.DefaultRequestHeaders();
                HttpHeaders.Add('Authorization', CreateBasicAuth(Users, Password));
                id := SalesShptHdr."External Document No.";
                TrackingNumber := SalesShptHdr."Package Tracking No.";
                tracking_provider := SalesShptHdr."Shipping Agent Code";
                if (tracking_provider = '') Or (tracking_provider = 'RM') then
                    tracking_provider := 'ROYAL MAIL';
                TrackingNo := StrSubstNo('{"tracking_provider":"%1","tracking_number":"%2"}', tracking_provider, TrackingNumber);
                HttpContent.WriteFrom(TrackingNo);
                HttpContent.GetHeaders(HttpHeaders);
                HttpHeaders.Clear();
                HttpHeaders.Add('Content-Type', 'application/json');
                URL := StrSubstNo('https://cannabotech.co.uk/wp-json/wc-shipment-tracking/v3/orders/%1/shipment-trackings', id);
                if Client.Post(URL, HttpContent, ResponseMessage) then begin

                end;
            until SalesShptHdr.Next() = 0;

        OnAfterUpdateTrackingNo(SalesShptHdr);
    end;

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
            End;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTrackingNo(SalesShptHdr: Record "Sales Shipment Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateTrackingNo(SalesShptHdr: Record "Sales Shipment Header")
    begin
    end;

    var
        ShippingJsonobject: JsonObject;
        ItemUoM: Code[10];
        myInt: Integer;
        ApplicationName: Text;
        ApplicationVersion: Text;
        URL: Text;
        BillingAddress: JsonObject;
        ShippingAddress: JsonObject;
        documentNo: Text;
        productObject: JsonObject;
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        SyncItemLabel: Label 'SyncItem';
        SyncUpdateInventoryLabel: Label 'UpdateInventory';
        CustomerSyncLabel: Label 'CustomerSync';
        Windows: Dialog;
        Text006: Label 'Importing Customers to Nav...';
        customerHeaderObject: JsonObject;
        billingaddressHeaderObject: JsonObject;
        shippingaddressHeaderObject: JsonObject;
}