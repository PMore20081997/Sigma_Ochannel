codeunit 90003 "Magento Integration"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        myInt: Integer;
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF
            SyncOrderLabel:
                BEGIN
                    GetMagentoOrders(StartParameter);
                End;
        end;
    end;

    var
        serviceURL: Text;
        username: Text;
        password: Text;
        fromDate: Text;
        fromDateProduct: Text;
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
            username := TradePartner.AccessKeyId;
            password := TradePartner.SecretAccessKey;
            serviceURL := TradePartner."Sevice/API URL";
            fromDate := Format(tradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2> <Hours12,2>:<Minutes,2>:<Seconds,2>');
            fromDateProduct := Format(tradePartner."Last Product Sync", 0, '20<Year>-<Month,2>-<Day,2> <Hours12,2>:<Minutes,2>:<Seconds,2>');
        end;
    End;


    //Procedure to Get Token from Magento
    procedure GetMagentoToken(ChannelCode: Code[10]): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        body: Text;
        Token: Text;
    begin
        GetCredentials(ChannelCode);
        HttpHeaders := HttpClient.DefaultRequestHeaders;
        HttpContent.GetHeaders(HttpHeaders);
        //body := '{"username":"' + username + '","password":"' + password + '"}';
        body := '{"username":"robosol","password":"Tf8Yj6*re!"}';
        HttpContent.WriteFrom(body);
        //HttpClient.DefaultRequestHeaders().Add('accept', 'application/json');
        HttpClient.DefaultRequestHeaders().Add('charset', 'UTF-8');
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/json');

        URL := serviceURL + '/rest/V1/integration/admin/token/';
        //URL := 'https://dev.penheaven.magetry.com/rest/V1/integration/admin/token/';

        if HttpClient.Post(URL, HttpContent, HttpResponseMessage) then begin

            if HttpResponseMessage.HttpStatusCode = 200 then begin
                HttpResponseMessage.Content.ReadAs(response);
                //Need to Test how to accept Token from Response as it is in Double Inverted only not in Json format
                Token := response;
                if Token.Contains('"') then begin
                    Token := Token.Replace('"', '');
                    Token := Token.Trim();
                end;
                exit(Token);
            end;

        end
        else begin
            HttpResponseMessage.Content.ReadAs(response);
            Error(response);
        end;

    end;


    //Procedure to Retrieve Orders from Magento 
    procedure GetMagentoOrders(ChannelCode: Code[10])
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        toDate: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        i: Integer;
        noOfRecords: Integer;
        ChannelOrderId: Text;
        orderToken: JsonToken;
        orderObject: JsonObject;
        extensionAttributeObject: JsonObject;
        orderIdObject: JsonObject;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
    begin
        toDate := Format(CurrentDateTime, 0, '20<Year>-<Month,2>-<Day,2> <Hours12,2>:<Minutes,2>:<Seconds,2>');
        Client.DefaultRequestHeaders().Add('accept', 'application/json');
        Token := GetMagentoToken(ChannelCode);
        headers.Add('Authorization', CreateBearerToken(Token));
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');
        GetCredentials(ChannelCode);

        URL := serviceURL + '/rest/V1/orders?searchCriteria[filter_groups][0][filters][0][field]=created_at&' +
            'searchCriteria[filter_groups][0][filters][0][condition_type]=from&' +
            'searchCriteria[filter_groups][0][filters][0][value]=' + fromDate +
            '&searchCriteria[filter_groups][1][filters][0][field]=created_at&' +
            'searchCriteria[filter_groups][1][filters][0][condition_type]=to&' +
            'searchCriteria[filter_groups][1][filters][0][value]=' + toDate;

        if client.Get(URL, responseMessage) then begin

            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                jArray := GetJsonToken(jObject, 'items').AsArray();
                noOfRecords := jArray.Count;

                for i := 0 to noOfRecords - 1 do begin

                    jArray.Get(i, orderToken);
                    orderObject := orderToken.AsObject();
                    extensionAttributeObject := GetJsonToken(orderObject, 'extension_attributes').AsObject();
                    orderIdObject := GetJsonToken(extensionAttributeObject, 'amazon_order_reference_id').AsObject();

                    ChannelOrderId := GetJsonvalue(orderIdObject, 'order_id').AsText();

                    InsertInSalesHeader(orderObject, ChannelOrderId, ChannelCode, InterimSalesHeader);
                    InsertInSalesLine(InterimSalesHeader, orderObject, InterimSalesLine);

                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

                end;
            end
            else begin
                Message('No Orders Getting from Magento');
            end;
        end;

        MESSAGE('Magento Order Sync Completed...');

    end;


    //Procedure to Insert Order Headers Data into Interim Sales Header Table
    local procedure InsertInSalesHeader(Orderheaders: JsonObject; var ChannelOrderId: Text; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        paymentMethod: Text;
        firstName: Text;
        lastName: Text;
        fullName: Text;
        billingObject: JsonObject;
        paymentObject: JsonObject;
        extensionAttributeObject: JsonObject;
        shippingAssignmentArray: JsonArray;
        shippingCount: Integer;
        i: Integer;
        jObject: JsonObject;
        shippingToken: JsonToken;
        shippingObject: JsonObject;
        shippingAddressObject: JsonObject;
    begin

        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."No." := ChannelOrderId;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;

        billingObject := GetJsonToken(Orderheaders, 'billing_address').AsObject();
        paymentObject := GetJsonToken(Orderheaders, 'payment').AsObject();
        extensionAttributeObject := GetJsonToken(Orderheaders, 'extension_attributes').AsObject();
        shippingAssignmentArray := GetJsonToken(extensionAttributeObject, 'shipping_assignments').AsArray();
        shippingCount := shippingAssignmentArray.Count;

        If GetJsonvalue(Orderheaders, 'created_at').IsNull = false then begin
            InterimSalesHeader."Order Placed At" := GetJsonvalue(Orderheaders, 'created_at').AsDateTime();
        end;

        InterimSalesHeader."Order Date" := Today;

        if GetJsonvalue(Orderheaders, 'customer_email').IsNull = false then begin
            InterimSalesHeader."Buyer Email" := CopyStr(GetJsonToken(Orderheaders, 'customer_email').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(Orderheaders, 'customer_firstname').IsNull = false and GetJsonvalue(Orderheaders, 'customer_lastname').IsNull = false then begin
            firstName := GetJsonvalue(Orderheaders, 'customer_firstname').AsText();
            lastName := GetJsonvalue(Orderheaders, 'customer_lastname').AsText();
            fullName := firstName + ' ' + lastName;
            InterimSalesHeader."Buyer Name" := CopyStr(fullName, 1, 100);
        end;

        if GetJsonvalue(Orderheaders, 'grand_total').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonToken(Orderheaders, 'grand_total').AsValue().AsDecimal();
        end;

        if GetJsonvalue(Orderheaders, 'order_currency_code').IsNull = false then begin
            InterimSalesHeader."Currency Code" := CopyStr(GetJsonToken(Orderheaders, 'order_currency_code').AsValue().AsCode(), 1, 10);
        end;

        InterimSalesHeader.status := InterimSalesHeader.status::"In Progress";

        if GetJsonvalue(billingObject, 'city').IsNull = false then begin
            InterimSalesHeader.City := CopyStr(GetJsonToken(billingObject, 'city').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(billingObject, 'firstname').IsNull = false and GetJsonvalue(billingObject, 'lastname').IsNull = false then begin
            firstName := GetJsonvalue(billingObject, 'firstname').AsText();
            lastName := GetJsonvalue(billingObject, 'lastname').AsText();
            fullName := firstName + ' ' + lastName;
            InterimSalesHeader."Bill- to Name" := CopyStr(fullName, 1, 50);
        end;

        if GetJsonvalue(billingObject, 'postcode').IsNull = false then begin
            InterimSalesHeader."Post Code" := CopyStr(GetJsonToken(billingObject, 'postcode').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(billingObject, 'telephone').IsNull = false then begin
            InterimSalesHeader."Customer Phone Number" := CopyStr(GetJsonToken(billingObject, 'telephone').AsValue().AsCode(), 1, 20);
        end;

        if shippingCount > 0 then begin

            shippingAssignmentArray.Get(0, shippingToken);
            jObject := shippingToken.AsObject();

            shippingObject := GetJsonToken(jObject, 'shipping').AsObject();
            shippingAddressObject := GetJsonToken(shippingObject, 'address').AsObject();

            if GetJsonvalue(shippingAddressObject, 'city').IsNull = false then begin
                InterimSalesHeader."Ship-to City" := CopyStr(GetJsonToken(shippingAddressObject, 'city').AsValue().AsText(), 1, 30);
            end;

            if GetJsonvalue(shippingAddressObject, 'country_id').IsNull = false then begin
                InterimSalesHeader."Ship-to Country/Region Code" := CopyStr(GetJsonToken(shippingAddressObject, 'country_id').AsValue().AsCode(), 1, 10);
            end;

            if GetJsonvalue(shippingAddressObject, 'email').IsNull = false then begin
                InterimSalesHeader."Ship-to Email" := CopyStr(GetJsonToken(shippingAddressObject, 'email').AsValue().AsText(), 1, 80);
            end;

            if GetJsonvalue(shippingAddressObject, 'firstname').IsNull = false and GetJsonvalue(shippingAddressObject, 'lastname').IsNull = false then begin
                firstName := GetJsonvalue(shippingAddressObject, 'firstname').AsText();
                lastName := GetJsonvalue(shippingAddressObject, 'lastname').AsText();
                fullName := firstName + ' ' + lastName;
                InterimSalesHeader."Ship-to Name" := CopyStr(fullName, 1, 50);
            end;

            if GetJsonvalue(shippingAddressObject, 'postcode').IsNull = false then begin
                InterimSalesHeader."Ship-to Post Code" := CopyStr(GetJsonToken(shippingAddressObject, 'postcode').AsValue().AsCode(), 1, 20);
            end;

            if GetJsonvalue(shippingAddressObject, 'telephone').IsNull = false then begin
                InterimSalesHeader."Ship-to Phone" := CopyStr(GetJsonToken(shippingAddressObject, 'telephone').AsValue().AsText(), 1, 20);
            end;

        end;

        InterimSalesHeader.Insert();

    end;


    //Procedure to Insert Line Items into Interim Sales Line Table
    local procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; OrderObject: JsonObject; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        itemArray: JsonArray;
        j: Integer;
        itemCount: Integer;
        lineItemToken: JsonToken;
        lineObject: JsonObject;
        LineNo: Integer;
        shippingPrice: Decimal;
    begin
        itemArray := GetJsonToken(OrderObject, 'items').AsArray();

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

                // if GetJsonvalue(lineObject, 'price').IsNull = false then begin
                //     InterimSalesLine.Amount := GetJsonToken(lineObject, 'price').AsValue().AsDecimal();
                // end;

                if GetJsonvalue(lineObject, 'price_incl_tax').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonToken(lineObject, 'price_incl_tax').AsValue().AsDecimal();
                end;

                if GetJsonvalue(lineObject, 'item_id').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonToken(lineObject, 'item_id').AsValue().AsCode();
                end;

                if GetJsonvalue(lineObject, 'qty_ordered').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonToken(lineObject, 'qty_ordered').AsValue().AsDecimal();
                end;

                if GetJsonvalue(lineObject, 'sku').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := CopyStr(GetJsonToken(lineObject, 'sku').AsValue().AsText(), 1, 50);
                end;

                if GetJsonvalue(lineObject, 'tax_amount').IsNull = false then begin
                    InterimSalesLine."VAT amount" := GetJsonToken(lineObject, 'tax_amount').AsValue().AsDecimal();
                end;

                if GetJsonvalue(lineObject, 'tax_percent').IsNull = false then begin
                    InterimSalesLine."VAT%" := CopyStr(GetJsonToken(lineObject, 'tax_percent').AsValue().AsText(), 1, 30);
                end;

                //Header Level need to figure
                if GetJsonvalue(OrderObject, 'shipping_incl_tax').IsNull = false then begin
                    InterimSalesLine."Shipping Price" := GetJsonvalue(OrderObject, 'shipping_incl_tax').AsDecimal();
                end;

                InterimSalesLine.Insert();

            end;

        end;

    end;


    //Procedure to Retrieve Products from Magento
    procedure GetMagentoProducts(ChannelCode: Code[10])
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        fromDate: Text;
        toDate: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        i: Integer;
        noOfRecords: Integer;
        productToken: JsonToken;
        productObject: JsonObject;
        ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);
        toDate := Format(CurrentDateTime, 0, '20<Year>-<Month,2>-<Day,2> <Hours12,2>:<Minutes,2>:<Seconds,2>');

        Client.DefaultRequestHeaders().Add('accept', 'application/json');
        Token := GetMagentoToken(ChannelCode);
        headers.Add('Authorization', CreateBearerToken(Token));
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');

        URL := serviceURL + '/rest/V1/products?' +
            'searchCriteria[filter_groups][0][filters][0][field]=updated_at&' +
            'searchCriteria[filter_groups][0][filters][0][condition_type]=from&' +
            'searchCriteria[filter_groups][0][filters][0][value]=' + fromDateProduct +
            '&searchCriteria[filter_groups][1][filters][0][field]=updated_at&' +
            'searchCriteria[filter_groups][1][filters][0][condition_type]=to&' +
            'searchCriteria[filter_groups][1][filters][0][value]=' + toDate +
            '&searchCriteria[filter_groups][2][filters][0][field]=type_id&' +
            'searchCriteria[filter_groups][2][filters][0][condition_type]=type_id&' +
            'searchCriteria[filter_groups][2][filters][0][value]=simple&' +
            'searchCriteria[filter_groups][3][filters][0][field]=status&' +
            'searchCriteria[filter_groups][3][filters][0][condition_type]=status&' +
            'searchCriteria[filter_groups][3][filters][0][value]=1';

        if client.Get(URL, responseMessage) then begin

            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                jArray := GetJsonToken(jObject, 'items').AsArray();
                noOfRecords := jArray.Count;

                for i := 0 to noOfRecords - 1 do begin

                    jArray.Get(i, productToken);
                    productObject := productToken.AsObject();

                    ChannelItemListing.Reset();
                    ChannelItemListing.SetRange("Channel Code", ChannelCode);
                    ChannelItemListing.SetRange("Channel SKU", GetJsonvalue(productObject, 'sku').AsText());

                    IF ChannelItemListing.FINDFIRST THEN BEGIN
                        UpdateMagentoProduct(FALSE, productObject, ChannelCode);
                    END
                    ELSE BEGIN
                        UpdateMagentoProduct(TRUE, productObject, ChannelCode);
                    END;

                end;
            end;

        end;

    end;


    //Procedure to Modify or Insert Products into Channel Item Listing Table
    procedure UpdateMagentoProduct(bool: Boolean; productObject: JsonObject; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
        status: Text;
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

        if GetJsonvalue(productObject, 'status').IsNull = false then begin
            status := GetJsonvalue(productObject, 'status').AsText();

            if (status = '1') then
                ChannelItemListing.Validate(Status, ChannelItemListing.Status::Active);

            if (status = '2') then
                ChannelItemListing.Validate(Status, ChannelItemListing.Status::Inactive);

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


    //Need to Test First and Check if this is the Correct code or not
    //Procedure to Update Inventory Price for Magento Products
    procedure UpdateMagentoInventoryPrice(ChannelCode: Code[10])
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        serviceURL: Text;
        sku: Text;
        price: Text;
        quantity: Text;
        body: Text;
        tradePartner: Record "Trade Partner";
        ChannelItemListing: Record "Channel Item Listing";
    begin
        Token := GetMagentoToken(ChannelCode);
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SetFilter("Inventory Synced", '%1', false);
        ChannelItemListing.SetFilter("Price Synced", '%1', false);

        IF ChannelItemListing.FINDSET THEN BEGIN

            REPEAT
                sku := ChannelItemListing."Channel SKU";
                price := format(ChannelItemListing."Channel Unit Price");
                quantity := format(ChannelItemListing."Channel Inventory");

                headers := Client.DefaultRequestHeaders();
                headers.Add('Authorization', CreateBearerToken(Token));
                body := strsubstno('{"product": {"price": "' + price + '", "extension_attributes": {"stock_item": {"qty": "' + quantity + '"}}}}');

                Client.DefaultRequestHeaders().Add('accept', 'application/json');
                Client.DefaultRequestHeaders().Add('charset', 'UTF-8');

                content.WriteFrom(body);
                content.GetHeaders(headers);
                headers.Remove('Content-Type');
                headers.Add('Content-Type', 'application/json');
                URL := serviceURL + '/rest/V1/products/' + sku;

                if client.Put(URL, content, responseMessage) then begin

                    ChannelItemListing."Inventory Synced" := TRUE;
                    ChannelItemListing."Price Synced" := true;
                    ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                    ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    ChannelItemListing.Remarks := 'Inventory And Price updated successfully';
                    ChannelItemListing.MODIFY;

                END
                ELSE BEGIN
                    //Need to Test First for Message to Print
                    ChannelItemListing.Remarks := '';
                    ChannelItemListing.MODIFY;
                END;

            UNTIL ChannelItemListing.NEXT = 0;

        END;

    end;


    //Procedure to Fulfill the Order
    procedure MagentoOrderFulfillment(ChannelCode: Code[10])
    var
        client: HttpClient;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        Token: Text;
        orderId: Text;
        orderObject: JsonObject;
        shippingObject: JsonObject;
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin
        headers := Client.DefaultRequestHeaders();
        Client.DefaultRequestHeaders().Add('accept', 'application/json');
        Token := GetMagentoToken(ChannelCode);
        headers.Add('Authorization', CreateBearerToken(Token));
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');

        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETRANGE("Trade Partner Code", ChannelCode);
        HandledInterimSalesHeader.SETFILTER("FullFillment Status", '<>%1', HandledInterimSalesHeader."FullFillment Status"::Fullfilled);
        HandledInterimSalesHeader.SETRANGE(Status, HandledInterimSalesHeader.Status::Dispatched);
        HandledInterimSalesHeader.SETFILTER("Package Tracking No.", '<>%1', '');
        HandledInterimSalesHeader.SETFILTER("Scanned Date", '>%1', CREATEDATETIME(20210212D, TIME));

        If HandledInterimSalesHeader.FindSet() then begin
            repeat
                orderId := HandledInterimSalesHeader."Channel Order ID";
                orderObject := GetSingleOrder(ChannelCode, Token, orderId);
                shippingObject := PostShipping(ChannelCode, orderObject, Token);
                PostShipmentTrack(ChannelCode, shippingObject, Token, HandledInterimSalesHeader);
            until HandledInterimSalesHeader.Next = 0;
        end;

    end;


    //Procedure to Get Single Order Detail using Order Id and 
    //return the Response to create request body for Post Shipment API
    procedure GetSingleOrder(ChannelCode: Code[10]; Token: Text; orderId: Text): JsonObject
    var
        URL: Text;
        client: HttpClient;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        response: Text;
        jObject: JsonObject;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        Client.DefaultRequestHeaders().Add('accept', 'application/json');
        headers.Add('Authorization', CreateBearerToken(Token));
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');

        URL := serviceURL + '/rest/V1/orders/' + orderId;
        if client.Get(URL, responseMessage) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            exit(jObject);
        end;

    end;


    //Procedure to Post Shipment and get the response to pass it to Post Shipment Track API
    procedure PostShipping(ChannelCode: Code[10]; orderObject: JsonObject; Token: Text): JsonObject
    var
        URL: Text;
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        body: Text;
        response: Text;
        jObject: JsonObject;
        itemArray: JsonArray;
        lineItemToken: JsonToken;
        lineObject: JsonObject;
        itemCount: Integer;
        i: Integer;
        entityId: text;
        incrementId: Text;
        name: Text;
        orderItemId: Text;
        parentId: Text;
        price: Text;
        productId: Text;
        quantity: Text;
        rowTotal: Text;
        sku: Text;
        weight: Text;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        headers.Add(StrSubstNo('Authorization', '%1'), Token);

        if GetJsonvalue(orderObject, 'entity_id').IsNull = false then begin
            entityId := GetJsonvalue(orderObject, 'entity_id').AsText();
        end;

        if GetJsonvalue(orderObject, 'increment_id').IsNull = false then begin
            incrementId := GetJsonvalue(orderObject, 'increment_id').AsText();
        end;

        itemArray := GetJsonToken(OrderObject, 'items').AsArray();

        itemCount := itemArray.Count;
        if itemCount > 0 then begin
            //Not Sure if need to add loop for to get all item Details
            for i := 0 to itemCount - 1 do begin

            end;

            itemArray.Get(0, lineItemToken);
            lineObject := lineItemToken.AsObject();

            If GetJsonvalue(lineObject, 'name').IsNull = false then begin
                name := GetJsonvalue(lineObject, 'name').AsText();
            end;

            if GetJsonvalue(lineObject, 'item_id').IsNull = false then begin
                orderItemId := GetJsonvalue(lineObject, 'item_id').AsText();
            end;

            if GetJsonvalue(lineObject, 'price').IsNull = false then begin
                price := GetJsonvalue(lineObject, 'price').AsText();
            end;

            if GetJsonvalue(lineObject, 'product_id').IsNull = false then begin
                productId := GetJsonvalue(lineObject, 'product_id').AsText();
            end;

            if GetJsonvalue(lineObject, 'qty_ordered').IsNull = false then begin
                quantity := GetJsonvalue(lineObject, 'qty_ordered').AsText();
            end;

            if GetJsonvalue(lineObject, 'row_total').IsNull = false then begin
                rowTotal := GetJsonvalue(lineObject, 'row_total').AsText();
            end;

            if GetJsonvalue(lineObject, 'sku').IsNull = false then begin
                sku := GetJsonvalue(lineObject, 'sku').AsText();
            end;

            if GetJsonvalue(lineObject, 'weight').IsNull = false then begin
                weight := GetJsonvalue(lineObject, 'weight').AsText();
            end;
        end;

        body := strsubstno('{"entity": {"entity_id": "' + entityId + '", "increment_id": "' + incrementId + '",' +
                        ' "items": {"name": "' + name + '", "order_item_id": "' + orderItemId + '", ' +
                        ' "price": "' + price + '", "product_id": "' + productId + '", "qty": "' + quantity + '", "row_total": "' + rowTotal + '",' +
                        ' "sku": "' + sku + '", "weight": "' + weight + '"}}}');
        Client.DefaultRequestHeaders().Add('accept', 'application/json');
        Client.DefaultRequestHeaders().Add('charset', 'UTF-8');
        content.WriteFrom(body);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');

        URL := serviceURL + '/rest/V1/shipment/';
        if client.Post(URL, content, responseMessage) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            exit(jObject);
        end;

    end;


    //Procedure to Post Shipment Tracking.
    procedure PostShipmentTrack(ChannelCode: Code[10]; shippingObject: JsonObject; Token: Text; HandledInterimSalesHeader: Record "Handled Interim Sales Header")
    var
        URL: Text;
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        body: Text;
        response: Text;
        jObject: JsonObject;
        orderId: Text;
        parentId: Text;
        weight: Text;
        quantity: Text;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        headers.Add(StrSubstNo('Authorization', '%1'), Token);

        if GetJsonvalue(shippingObject, 'order_id').IsNull = false then begin
            orderId := GetJsonvalue(shippingObject, 'order_id').AsText();
        end;

        if GetJsonvalue(shippingObject, 'entity_id').IsNull = false then begin
            parentId := GetJsonvalue(shippingObject, 'entity_id').AsText();
        end;

        if GetJsonvalue(shippingObject, 'total_weight').IsNull = false then begin
            weight := GetJsonvalue(shippingObject, 'total_weight').AsText();
        end;

        if GetJsonvalue(shippingObject, 'total_qty').IsNull = false then begin
            quantity := GetJsonvalue(shippingObject, 'total_qty').AsText();
        end;

        body := strsubstno('{"entity": {"order_id": "' + orderId + '", "parent_id": "' + parentId + '",' +
                                ' "weight": "' + weight + '", "qty": "' + quantity + '"}}');
        Client.DefaultRequestHeaders().Add('accept', 'application/json');
        Client.DefaultRequestHeaders().Add('charset', 'UTF-8');
        content.WriteFrom(body);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');

        URL := serviceURL + '/rest/V1/shipment/track';

        if client.Post(URL, content, responseMessage) then begin
            HandledInterimSalesHeader."FullFillment Status" := HandledInterimSalesHeader."FullFillment Status"::Fullfilled;
        end;

    end;


    //Prcedure to return Bearer Token Format
    procedure CreateBearerToken(Token: Text): Text
    begin
        exit(StrSubstNo('Bearer %1', Token));
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


    //Procedure to convert Text Formatted Date into DateTime Format
    local procedure GenerateDateTime(createDate: Text): DateTime
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        TimeType: Time;
        Convertdate: DateTime;
    begin
        if createDate <> '' then begin

            evaluate(Day, copystr(createDate, 9, 2));
            evaluate(Month, copystr(createDate, 6, 2));
            evaluate(Year, copystr(createDate, 1, 4));
            evaluate(TimeType, copystr(createDate, 12, 8));
            Convertdate := createdatetime(DMY2DATE(Day, Month, Year), TimeType);

        End;
        exit(Convertdate);
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