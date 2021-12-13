codeunit 90007 "OnBuy Integration"
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
                    GetOnBuyOrders(StartParameter);
                End;
        end;
    end;

    var
        secretKey: Text;
        consumerKey: Text;
        serviceURL: Text;
        modifiedSinceDate: Text;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';


    //Procedure to get the Credentials from Trade Partner for Particular Channel Code
    procedure GetCredentials("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            secretKey := tradePartner.AccessKeyId;
            consumerKey := tradePartner.SecretAccessKey;
            serviceURL := TradePartner."Sevice/API URL";
            modifiedSinceDate := Format(tradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2> <Hours12,2>:<Minutes,2>:<Seconds,2>');
        end;
    End;


    //Procedure to Retrieve Token for OnBuy
    procedure GetOnBuyToken(ChannelCode: Code[10]): Text
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        jObject: JsonObject;
        Token: Text;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();

        content.WriteFrom('secret_key=' + secretKey + '&consumer_key=' + consumerKey);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        //URL := 'https://api.onbuy.com/v2/auth/request-token';
        URL := serviceURL + 'auth/request-token';

        if client.Post(URL, content, responseMessage) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            Token := GetJsonvalue(jObject, 'access_token').AsText();
            exit(Token);
        end
        else begin
            Message('No Token Getting From OnBuy');
        end;

    end;


    //Procedure to Retrieve Orders from OnBuy
    procedure GetOnBuyOrders(ChannelCode: Code[10])
    var
        client: HttpClient;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
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
    begin
        headers := Client.DefaultRequestHeaders();
        Token := GetOnBuyToken(ChannelCode);
        headers.Add(StrSubstNo('Authorization', '%1'), Token);
        GetCredentials(ChannelCode);
        URL := serviceURL + 'orders?site_id=2000&filter[modified_since]=' + modifiedSinceDate;

        if client.Get(URL, responseMessage) then begin

            if responseMessage.HttpStatusCode = 200 then begin

                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);

                jArray := GetJsonToken(jObject, 'results').AsArray();
                noOfRecords := jArray.Count;

                for i := 0 to noOfRecords - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();
                    jArray.Get(i, orderToken);
                    orderObject := orderToken.AsObject();

                    ChannelOrderId := GetJsonvalue(orderObject, 'order_id').AsText();

                    InsertInSalesHeader(orderObject, ChannelOrderId, ChannelCode, InterimSalesHeader);
                    InsertInSalesLine(InterimSalesHeader, orderObject, InterimSalesLine);

                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                end;

            end;

        end;

        MESSAGE('OnBuy Order Sync Completed...');

    end;


    //Procedure to Insert Order Header Data in Interim Sales Header Table
    procedure InsertInSalesHeader(Orderheaders: JsonObject; var ChannelOrderId: Text; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        orderDate: Text;
        buyerObject: JsonObject;
        billingAddressObject: JsonObject;
        deliveryAddressObject: JsonObject;
    begin
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."No." := ChannelOrderId;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;

        buyerObject := GetJsonToken(Orderheaders, 'buyer').AsObject();
        billingAddressObject := GetJsonToken(Orderheaders, 'billing_address').AsObject();
        deliveryAddressObject := GetJsonToken(Orderheaders, 'delivery_address').AsObject();

        InterimSalesHeader."Order Date" := Today;

        if GetJsonvalue(Orderheaders, 'price_total').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonToken(Orderheaders, 'price_total').AsValue().AsDecimal();
        end;

        If GetJsonvalue(Orderheaders, 'currency_code').IsNull = false then begin
            InterimSalesHeader."Currency Code" := CopyStr(GetJsonToken(Orderheaders, 'currency_code').AsValue().AsCode(), 1, 10);
        end;

        if GetJsonvalue(buyerObject, 'name').IsNull = false then begin
            InterimSalesHeader."Buyer Name" := CopyStr(GetJsonToken(buyerObject, 'name').AsValue.AsText(), 1, 100);
        end;

        if GetJsonvalue(buyerObject, 'email').IsNull = false then begin
            InterimSalesHeader."Buyer Email" := CopyStr(GetJsonToken(buyerObject, 'email').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(buyerObject, 'phone').IsNull = false then begin
            InterimSalesHeader."Customer Phone Number" := CopyStr(GetJsonToken(buyerObject, 'phone').AsValue().AsCode(), 1, 20);
        end;

        if GetJsonvalue(billingAddressObject, 'name').IsNull = false then begin
            InterimSalesHeader."Bill- to Name" := CopyStr(GetJsonToken(billingAddressObject, 'name').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(billingAddressObject, 'line_1').IsNull = false then begin
            InterimSalesHeader.Address := CopyStr(GetJsonToken(billingAddressObject, 'line_1').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(billingAddressObject, 'line_2').IsNull = false then begin
            InterimSalesHeader."Address 2" := CopyStr(GetJsonToken(billingAddressObject, 'line_2').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(billingAddressObject, 'town').IsNull = false then begin
            InterimSalesHeader."City" := CopyStr(GetJsonToken(billingAddressObject, 'town').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(billingAddressObject, 'county').IsNull = false then begin
            InterimSalesHeader."Bill-to County" := CopyStr(GetJsonToken(billingAddressObject, 'county').AsValue.AsText(), 1, 30);
        end;

        If GetJsonvalue(billingAddressObject, 'postcode').IsNull = false then begin
            InterimSalesHeader."Post Code" := CopyStr(GetJsonToken(billingAddressObject, 'postcode').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(billingAddressObject, 'country').IsNull = false then begin
            InterimSalesHeader."Sell to Country" := CopyStr(GetJsonToken(billingAddressObject, 'country').AsValue.AsCode(), 1, 20);
        end;

        if GetJsonvalue(deliveryAddressObject, 'name').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := CopyStr(GetJsonToken(deliveryAddressObject, 'name').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(deliveryAddressObject, 'line_1').IsNull = false then begin
            InterimSalesHeader."Ship-to Address" := CopyStr(GetJsonToken(deliveryAddressObject, 'line_1').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(deliveryAddressObject, 'line_2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := CopyStr(GetJsonToken(deliveryAddressObject, 'line_2').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(deliveryAddressObject, 'town').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := CopyStr(GetJsonToken(deliveryAddressObject, 'town').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(deliveryAddressObject, 'county').IsNull = false then begin
            InterimSalesHeader."Ship-to County" := CopyStr(GetJsonToken(deliveryAddressObject, 'county').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(deliveryAddressObject, 'postcode').IsNull = false then begin
            InterimSalesHeader."Ship-to Post Code" := CopyStr(GetJsonToken(deliveryAddressObject, 'postcode').AsValue().AsCode(), 1, 20);
        end;

        if GetJsonvalue(deliveryAddressObject, 'country').IsNull = false then begin
            InterimSalesHeader."Ship-to Country" := CopyStr(GetJsonToken(deliveryAddressObject, 'country').AsValue().AsCode(), 1, 20);
        end;

        if GetJsonvalue(deliveryAddressObject, 'country_code').IsNull = false then begin
            InterimSalesHeader."Ship-to Country/Region Code" := CopyStr(GetJsonToken(deliveryAddressObject, 'country_code').AsValue().AsCode(), 1, 10);
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
        itemArray := GetJsonToken(OrderObject, 'products').AsArray();

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

                if GetJsonvalue(lineObject, 'name').IsNull = false then begin
                    InterimSalesLine.Description := Copystr(GetJsonToken(lineObject, 'name').AsValue().AsText(), 1, 100);
                end;

                if GetJsonvalue(lineObject, 'sku').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := CopyStr(GetJsonToken(lineObject, 'sku').AsValue().AsText(), 1, 50);
                end;

                if GetJsonvalue(lineObject, 'quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonToken(lineObject, 'quantity').AsValue().AsDecimal();
                end;

                if GetJsonvalue(lineObject, 'unit_price').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonToken(lineObject, 'unit_price').AsValue().AsDecimal();
                end;

                // if GetJsonvalue(lineObject, 'total_price').IsNull = false then begin
                //     InterimSalesLine.Amount := GetJsonToken(lineObject, 'total_price').AsValue().AsDecimal();
                // end;

                InterimSalesLine.Insert();

            end;

        end;

    end;


    //Procedure to Retrieve OnBuy Products
    procedure GetOnBuyProducts(ChannelCode: Code[10])
    var
        client: HttpClient;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        productToken: JsonToken;
        productObject: JsonObject;
        i: Integer;
        noOfRecords: Integer;
        ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        Token := GetOnBuyToken(ChannelCode);
        headers.Add(StrSubstNo('Authorization', '%1'), Token);

        URL := serviceURL + 'listings?sort[last_created]=asc&filter[in_stock]=true&limit=300&site_id=2000';

        if client.Get(URL, responseMessage) then begin

            if responseMessage.HttpStatusCode = 200 then begin

                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);

                jArray := GetJsonToken(jObject, 'results').AsArray();
                noOfRecords := jArray.Count;

                for i := 0 to noOfRecords - 1 do begin

                    jArray.Get(i, productToken);
                    productObject := productToken.AsObject();

                    ChannelItemListing.Reset();
                    ChannelItemListing.SetRange("Channel Code", ChannelCode);
                    ChannelItemListing.SetRange("Channel SKU", GetJsonvalue(productObject, 'sku').AsText());

                    IF ChannelItemListing.FINDFIRST THEN BEGIN
                        UpdateOnBuyProduct(FALSE, productObject, ChannelCode);
                    END
                    ELSE BEGIN
                        UpdateOnBuyProduct(TRUE, productObject, ChannelCode);
                    END;

                end;

            end;


        end;

    end;


    //Procedure to Modify or Insert Product Details
    local procedure UpdateOnBuyProduct(bool: Boolean; productObject: JsonObject; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
    begin
        CLEAR(ChannelItemListing);
        ChannelItemListing."Channel Code" := ChannelCode;

        if GetJsonvalue(productObject, 'sku').IsNull = false then begin
            ChannelItemListing.Validate("Channel SKU", CopyStr(GetJsonvalue(productObject, 'sku').AsText(), 1, 50));
        end;

        if GetJsonvalue(productObject, 'name').IsNull = false then begin
            ChannelItemListing.Validate("Channel Title", CopyStr(GetJsonvalue(productObject, 'name').AsText(), 1, 50));
        end;

        if GetJsonvalue(productObject, 'price').IsNull = false then begin
            ChannelItemListing.Validate("Channel Unit Price", GetJsonvalue(productObject, 'price').AsDecimal());
        end;

        if GetJsonvalue(productObject, 'stock').IsNull = false then begin
            ChannelItemListing.Validate("Channel Inventory", GetJsonvalue(productObject, 'stock').AsInteger());
        end;

        IF bool then begin
            ChannelItemListing."Created On" := CurrentDateTime;
            ChannelItemListing.INSERT(TRUE);
        END
        ELSE BEGIN
            ChannelItemListing."Modified On" := CurrentDateTime;
            ChannelItemListing.MODIFY(TRUE);
        END

    end;


    //Procedure to Update Inventory and Price for OnBuy Products using SKU
    procedure UpdateOnBuyInventoryPrice(ChannelCode: Code[10])
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        serviceURL: Text;
        body: Text;
        sku: Text;
        price: Text;
        quantity: Text;
        tradePartner: Record "Trade Partner";
        ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETFILTER("Inventory Synced", '%1', FALSE);
        ChannelItemListing.SetFilter("Price Synced", '%1', false);

        IF ChannelItemListing.FINDSET THEN BEGIN
            sku := ChannelItemListing."Channel SKU";
            price := format(ChannelItemListing."Channel Unit Price");
            quantity := format(ChannelItemListing."Channel Inventory");

            headers := Client.DefaultRequestHeaders();
            Token := GetOnBuyToken(ChannelCode);
            headers.Add(StrSubstNo('Authorization', '%1'), Token);
            body := strsubstno('{"site_id": 2000,"listings":[{"sku": "' + sku + '","price": "' + price + '","stock": "' + quantity + '"}]}');

            Client.DefaultRequestHeaders().Add('accept', 'application/json');
            Client.DefaultRequestHeaders().Add('charset', 'UTF-8');

            content.WriteFrom(body);
            content.GetHeaders(headers);
            headers.Remove('Content-Type');
            headers.Add('Content-Type', 'application/json');

            REPEAT

                URL := serviceURL + 'listings/by-sku';

                if client.Put(URL, content, responseMessage) then begin

                    if responseMessage.HttpStatusCode = 201 then begin
                        ChannelItemListing."Inventory Synced" := TRUE;
                        ChannelItemListing."Price Synced" := true;
                        ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                        ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                        ChannelItemListing.Remarks := 'Inventory updated successfully';
                        ChannelItemListing.MODIFY;
                    end;

                END
                ELSE BEGIN
                    //Need to test with Real time testing and then put Message Accordingly
                    ChannelItemListing.Remarks := '';
                    ChannelItemListing.Modify();
                END;

            UNTIL ChannelItemListing.NEXT = 0;

        END;

    end;


    //Procedure for OnBuy Order Fulfillment
    procedure OnBuyOrderFulfillment(ChannelCode: Code[10])
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        body: Text;
        orderId: Text;
        sku: Text;
        opc: Text;
        quantity: Text;
        trackingId: Text;
        supplierName: Text;
        number: Text;
        trackingUrl: Text;
        itemCount: Integer;
        orderObject: JsonObject;
        itemArray: JsonArray;
        lineObject: JsonObject;
        lineItemToken: JsonToken;
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        Token := GetOnBuyToken(ChannelCode);
        headers.Add(StrSubstNo('Authorization', '%1'), Token);

        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETRANGE("Trade Partner Code", ChannelCode);
        HandledInterimSalesHeader.SETFILTER("FullFillment Status", '<>%1', HandledInterimSalesHeader."FullFillment Status"::Fullfilled);
        HandledInterimSalesHeader.SETRANGE(Status, HandledInterimSalesHeader.Status::Dispatched);
        HandledInterimSalesHeader.SETFILTER("Package Tracking No.", '<>%1', '');
        HandledInterimSalesHeader.SETFILTER("Scanned Date", '>%1', CREATEDATETIME(20210212D, TIME));

        If HandledInterimSalesHeader.FindSet() then begin
            repeat

                orderId := HandledInterimSalesHeader."Channel Order ID";
                orderObject := GetSingleOnBuyOrder(ChannelCode, Token, orderId);

                itemArray := GetJsonToken(OrderObject, 'products').AsArray();
                itemCount := itemArray.Count;
                //Not sure if need to add loop to get all the Item Details and insert it
                if itemCount > 0 then begin
                    itemArray.Get(0, lineItemToken);
                    lineObject := lineItemToken.AsObject();

                    if GetJsonvalue(lineObject, 'sku').IsNull = false then begin
                        sku := GetJsonvalue(lineObject, 'sku').AsText();
                    end;

                    if GetJsonvalue(lineObject, 'opc').IsNull = false then begin
                        opc := GetJsonvalue(lineObject, 'opc').AsText();
                    end;

                    if GetJsonvalue(lineObject, 'quantity').IsNull = false then begin
                        quantity := GetJsonvalue(lineObject, 'quantity').AsText();
                    end;
                end;

                //Not Sure From where to get Tracking Details
                body := '{"orders": [{"order_id": "' + orderId + '", "products": [{"sku": "' + sku + '", "opc": "' + opc + '",' +
                ' "quantity": "' + quantity + '"}], "tracking": {"tracking_id": "' + trackingId + '", "supplier_name": "' + supplierName + '",' +
                ' "number": "' + number + '", "url": "' + trackingUrl + '"}}]}';
                Client.DefaultRequestHeaders().Add('accept', 'application/json');
                Client.DefaultRequestHeaders().Add('charset', 'UTF-8');
                content.WriteFrom(body);
                content.GetHeaders(headers);
                headers.Remove('Content-Type');
                headers.Add('Content-Type', 'application/json');

                URL := serviceURL + 'orders/dispatch';

                if client.Put(URL, content, responseMessage) then begin
                    HandledInterimSalesHeader."FullFillment Status" := HandledInterimSalesHeader."FullFillment Status"::Fullfilled;
                end;

            until HandledInterimSalesHeader.Next = 0;
        end;

    end;


    //Procedure to Get Single Order Data using Order Id and Return thst response to Order Fulfillment Code
    procedure GetSingleOnBuyOrder(ChannelCode: Code[10]; Token: Text; orderId: Text): JsonObject
    var
        client: HttpClient;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        jObject: JsonObject;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        headers.Add(StrSubstNo('Authorization', '%1'), Token);

        URL := serviceURL + 'orders?site_id=2000&filter[order_ids]=' + orderId;

        if client.Get(URL, responseMessage) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            exit(jObject);
        end;
    end;


    //Procedure to Convert Text Formatted Date into Date Data Type.
    local procedure GenerateDate(Orderdate: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Converdate: Date;
        Lenght: Integer;
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