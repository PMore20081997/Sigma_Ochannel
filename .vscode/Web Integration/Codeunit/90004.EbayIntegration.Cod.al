codeunit 90004 "Ebay Integration"
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
                    //GetEbayOrders(StartParameter);
                    GetEbayOrdersREST(StartParameter, '', '');
                    TradePartner.Reset();
                    TradePartner.SetRange(Code, StartParameter);
                    if TradePartner.FindFirst() then begin
                        TradePartner."Last Order Sync" := CreateDateTime(WorkDate, Time);
                        TradePartner.Modify;
                    end;
                End;
            SyncItemLabel:
                Begin
                    //GetEbayProducts(StartParameter);
                    GetEbayInventoryItemsREST(StartParameter, '', '');
                End;
            SyncShipmentLabel:
                begin
                    EbayOrderFulfillmentREST(StartParameter);
                end;
        end;
    end;

    var
        productObject: JsonObject;
        applicationId: Text;
        certificateId: Text;
        developerId: Text;
        Service_URL: Text;
        StatusFilter: Text;
        CreateDateFrom: Text;
        CreateDateTimeFrom: DateTime;
        CreateDate: Date;
        startDateTime: Text;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        StartParameter: Text;
        RunType: Text;
        TradePartner: Record "Trade Partner";
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        SyncItemLabel: Label 'SyncItem';


    //Procedure to get the Credentials from Trade Partner for Particular Channel Code
    procedure GetCredentials("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            applicationId := TradePartner.AccessKeyId;
            certificateId := TradePartner.SecretAccessKey;
            developerId := TradePartner.MerchantId;
            Service_URL := TradePartner."Sevice/API URL";
            StatusFilter := TradePartner.MarketplaceId;
            //CreateDateFrom := Format(tradePartner."Last Order Sync", 0, '20<Year><Month,2><Day,2><Hours12,2><Minutes,2><Seconds,2>');
            CreateDateTimeFrom := tradePartner."Last Order Sync";
            //CreateDateFrom := Format(tradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>.200Z');            
            CreateDate := DT2Date(CreateDateTimeFrom);
            CreateDate := CalcDate('-1D', CreateDate);
            CreateDateTimeFrom := CreateDateTime(CreateDate, DT2Time(CreateDateTimeFrom));
            CreateDateFrom := Format(CreateDateTimeFrom, 0, '20<Year>-<Month,2>-<Day,2>T<Hours12,2>:<Minutes,2>:<Seconds,2>.200Z');
            startDateTime := Format(tradePartner."Last Product Sync", 0, '20<Year><Month,2><Day,2><Hours12,2><Minutes,2><Seconds,2>');
        end;
    End;


    local procedure GetAccessTokenREST(ChannelCode: Code[20]): Text
    var
        client: HttpClient;
        content: HttpContent;
        headers: HttpHeaders;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        body: Text;
        AccessToken: Text;
        jObject: JsonObject;
        authorization: Text;
        grantType: Text;
        refreshToken: Text;
    begin
        GetCredentials(ChannelCode);
        headers := client.DefaultRequestHeaders;
        authorization := CreateBasicAuth(applicationId, certificateId);                                                              //For Live
        //authorization := CreateBasicAuth('ShubhamJ-Developm-SBX-dc8ee5576-d1315059', 'SBX-c8ee55767b77-f986-4142-a07e-cc79');        //For Sandbox
        headers.Add('Authorization', authorization);

        grantType := 'refresh_token';
        refreshToken := 'v^1.1#i^1#p^3#I^3#f^0#r^1#t^Ul4xMF82OjVDQjhCM0VENTI1MUQ2MTNBQTY1NDMzRkIyMEYzOTI2XzFfMSNFXjI2MA=='; //Live Refresh Token
        //refreshToken := 'v^1.1#i^1#I^3#f^0#p^3#r^1#t^Ul4xMF8yOjI3M0ZCNjY1MzUyMzMyNjE2Qjk5RTY0RUM4OUFEN0ZGXzFfMSNFXjEyODQ=';   //Sandbox Refresh Token

        body := StrSubstNo('grant_type=%1&refresh_token=%2', grantType, refreshToken);
        content.WriteFrom(body);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        URL := Service_URL + '/identity/v1/oauth2/token';                     //Live URL
        //URL := 'https://api.sandbox.ebay.com/identity/v1/oauth2/token';         //Sandbox URL
        if client.Post(URL, content, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                AccessToken := GetJsonvalue(jObject, 'access_token').AsText();
                exit(AccessToken);
            end
            else begin
                Error('Error Code : %1', responseMessage.HttpStatusCode);
            end;
        end;
    end;


    procedure GetEbayOrdersREST(ChannelCode: Code[20]; NextURL: Text; AccessToken: Text)
    var
        orderClient: HttpClient;
        orderHeaders: HttpHeaders;
        orderContent: HttpContent;
        orderResponseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        orderToken: JsonToken;
        orderHeaderObject: JsonObject;
        noOfResult: Integer;
        i: Integer;
        ChannelOrderId: Text;
        authorization: Text;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
    begin
        GetCredentials(ChannelCode);
        if AccessToken = '' then begin
            AccessToken := GetAccessTokenREST(ChannelCode);
        end;

        orderHeaders := orderClient.DefaultRequestHeaders;
        authorization := 'Bearer ' + AccessToken;
        orderHeaders.Add('Authorization', authorization);
        orderContent.GetHeaders(orderHeaders);
        orderHeaders.Clear();
        orderHeaders.Add('Content-Type', 'application/json');


        if NextURL <> '' then begin
            URL := NextURL;
        end
        else begin
            if StatusFilter <> '' then begin
                //Without Status URL
                URL := Service_URL + '/sell/fulfillment/v1/order?filter=' + StatusFilter + '&filter=creationdate:%5B' + CreateDateFrom + '..%5D';
            end
            else begin
                URL := Service_URL + '/sell/fulfillment/v1/order?filter=creationdate:%5B' + CreateDateFrom + '..%5D';
            end;
            //With Status URL
            //URL := Service_URL + '/sell/fulfillment/v1/order?filter=orderfulfillmentstatus:{NOT_STARTED|IN_PROGRESS}&filter=creationdate:%5B2021-05-20T15:05:43.026Z..%5D';

            //URL := Service_URL + '/sell/fulfillment/v1/order?filter=creationdate:%5B2021-05-01T15:05:43.026Z..%5D';
        end;

        if orderClient.Get(URL, orderResponseMessage) then begin
            if orderResponseMessage.HttpStatusCode = 200 then begin
                orderResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);

                if jObject.Contains('next') then begin
                    if GetJsonvalue(jObject, 'next').IsNull = false then begin
                        NextURL := GetJsonvalue(jObject, 'next').AsText();
                    end;
                end
                else begin
                    NextURL := '';
                end;

                jArray := GetJsonToken(jObject, 'orders').AsArray();
                noOfResult := jArray.Count();

                for i := 0 to noOfResult - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();
                    jArray.Get(i, orderToken);
                    orderHeaderObject := orderToken.AsObject();

                    ChannelOrderId := GetJsonvalue(orderHeaderObject, 'orderId').AsText();

                    InsertInterimSalesHeaderREST(orderHeaderObject, ChannelOrderId, ChannelCode, InterimSalesHeader, PaymentDetails);
                    InsertInterimSalesLineREST(InterimSalesHeader, orderHeaderObject, InterimSalesLine);

                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                end;

            end
            else begin
                Error('Error Code : %1', orderResponseMessage.HttpStatusCode);
            end;
        end
        else begin
            Error('Error Code : %1', orderResponseMessage.HttpStatusCode);
        end;

        if NextURL <> '' then
            GetEbayOrdersREST(ChannelCode, NextURL, AccessToken);

        if NextURL = '' then
            MESSAGE('Ebay Orders Sync Completed...');
    end;


    local procedure InsertInterimSalesHeaderREST(Orderheaders: JsonObject; var ChannelOrderId: Text; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary; var PaymentDetails: Record "Channel Media" temporary)
    var
        TradePartner: Record "Trade Partner";
        fullfillmentStatus: Text;
        pricingSummaryObject: JsonObject;
        totalPriceObject: JsonObject;
        paymentSummaryObject: JsonObject;
        paymentArray: JsonArray;
        paymentToken: JsonToken;
        paymentObject: JsonObject;
        paymentAmountObject: JsonObject;
        fullfillmentStartInstructionArray: JsonArray;
        fullfillmentInstructionToken: JsonToken;
        fullfillmentInstructionObject: JsonObject;
        shippingStepObject: JsonObject;
        shipToObject: JsonObject;
        contactAddressObject: JsonObject;
        primaryphoneObject: JsonObject;
        OrderDate: Text;
        PaymentDate: Text;
        ShippingRule: Record "Shipping Rule";
    begin
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."No." := CopyStr(ChannelOrderId, 1, 20);
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."External Document No." := ChannelOrderId;

        if TradePartner.Get(ChannelCode) then begin
            InterimSalesHeader."Sell-to Customer No." := TradePartner."Customer No.";
        end;

        if GetJsonvalue(Orderheaders, 'creationDate').IsNull = false then begin
            InterimSalesHeader."Order Created On" := GetJsonvalue(Orderheaders, 'creationDate').AsDateTime();
            InterimSalesHeader."Order Placed At" := GetJsonvalue(Orderheaders, 'creationDate').AsDateTime();
            OrderDate := GetJsonvalue(Orderheaders, 'creationDate').AsText();
            InterimSalesHeader."Order Date" := GenerateNewDate(OrderDate);
            InterimSalesHeader."Document Date" := GenerateNewDate(OrderDate);
        end;

        // if GetJsonvalue(Orderheaders, 'orderFulfillmentStatus').IsNull = false then begin
        //     fullfillmentStatus := GetJsonvalue(Orderheaders, 'orderFulfillmentStatus').AsText();
        //     if fullfillmentStatus = 'FULFILLED' then begin
        //         InterimSalesHeader."FullFillment Status" := InterimSalesHeader."FullFillment Status"::Fullfilled;
        //     end
        //     else begin
        //         InterimSalesHeader."FullFillment Status" := InterimSalesHeader."FullFillment Status"::"Not Acknowledged";
        //     end;
        // end;

        pricingSummaryObject := GetJsonToken(Orderheaders, 'pricingSummary').AsObject();
        totalPriceObject := GetJsonToken(pricingSummaryObject, 'total').AsObject();

        if GetJsonvalue(totalPriceObject, 'value').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonvalue(totalPriceObject, 'value').AsDecimal();
        end;

        if GetJsonvalue(totalPriceObject, 'convertedFromCurrency').IsNull = false then begin
            InterimSalesHeader."Currency Code" := GetJsonvalue(totalPriceObject, 'convertedFromCurrency').AsCode();
        end;

        paymentSummaryObject := GetJsonToken(Orderheaders, 'paymentSummary').AsObject();
        paymentArray := GetJsonToken(paymentSummaryObject, 'payments').AsArray();
        if paymentArray.Count > 0 then begin
            paymentArray.Get(0, paymentToken);
            paymentObject := paymentToken.AsObject();

            //Payment Details
            PaymentDetails.Init();
            PaymentDetails."Channel Code" := ChannelCode;
            PaymentDetails."Channel Order ID" := CopyStr(ChannelOrderId, 1, 50);

            if GetJsonvalue(paymentObject, 'paymentMethod').IsNull = false then begin
                InterimSalesHeader."Payment Method" := CopyStr(GetJsonvalue(paymentObject, 'paymentMethod').AsCode(), 1, 20);
                PaymentDetails."Payment Method" := CopyStr(GetJsonvalue(paymentObject, 'paymentMethod').AsText(), 1, 50);
            end;

            if GetJsonvalue(paymentObject, 'paymentReferenceId').IsNull = false then begin
                PaymentDetails."Transaction ID" := CopyStr(GetJsonvalue(paymentObject, 'paymentReferenceId').AsCode(), 1, 50);
            end;

            if GetJsonvalue(paymentObject, 'paymentDate').IsNull = false then begin
                PaymentDate := GetJsonvalue(paymentObject, 'paymentDate').AsText();
                PaymentDetails."Transaction Date" := GenerateNewDate(PaymentDate);
            end;

            if GetJsonvalue(paymentObject, 'paymentStatus').IsNull = false then begin
                PaymentDetails."Payment Status" := CopyStr(GetJsonvalue(paymentObject, 'paymentStatus').AsCode(), 1, 20);
            end;

            paymentAmountObject := GetJsonToken(paymentObject, 'amount').AsObject();
            if GetJsonvalue(paymentAmountObject, 'value').IsNull = false then begin
                PaymentDetails.Amount := GetJsonvalue(paymentAmountObject, 'value').AsDecimal();
            end;

            if GetJsonvalue(paymentAmountObject, 'currency').IsNull = false then begin
                PaymentDetails."Currency Code" := CopyStr(GetJsonvalue(paymentAmountObject, 'currency').AsCode(), 1, 10);
            end;

            PaymentDetails.Insert();
        end;

        fullfillmentStartInstructionArray := GetJsonToken(Orderheaders, 'fulfillmentStartInstructions').AsArray();
        if fullfillmentStartInstructionArray.Count > 0 then begin
            fullfillmentStartInstructionArray.Get(0, fullfillmentInstructionToken);
            fullfillmentInstructionObject := fullfillmentInstructionToken.AsObject();
            shippingStepObject := GetJsonToken(fullfillmentInstructionObject, 'shippingStep').AsObject();

            // if GetJsonvalue(shippingStepObject, 'shippingCarrierCode').IsNull = false then begin
            //     InterimSalesHeader."Shipping Agent Code" := CopyStr(GetJsonvalue(shippingStepObject, 'shippingCarrierCode').AsCode(), 1, 10);
            // end;

            if GetJsonvalue(shippingStepObject, 'shippingServiceCode').IsNull = false then begin
                InterimSalesHeader."Web Shipment Method" := CopyStr(GetJsonvalue(shippingStepObject, 'shippingServiceCode').AsCode(), 1, 50);
            end;

            ShippingRule.Reset();
            ShippingRule.SetRange("Channel Code", ChannelCode);
            ShippingRule.SetRange("Web Shipment Method", InterimSalesHeader."Web Shipment Method");
            if ShippingRule.FindFirst() then begin
                InterimSalesHeader."Shipping Agent Service Code" := ShippingRule."Shipping Agent Service";
                InterimSalesHeader."Shipping Agent Code" := ShippingRule."Shipping Agent";
            end;

            shipToObject := GetJsonToken(shippingStepObject, 'shipTo').AsObject();
            if GetJsonvalue(shipToObject, 'fullName').IsNull = false then begin
                InterimSalesHeader."Ship-to Name" := CopyStr(GetJsonvalue(shipToObject, 'fullName').AsText(), 1, 50);
                InterimSalesHeader."Buyer Name" := CopyStr(GetJsonvalue(shipToObject, 'fullName').AsText(), 1, 100);
            end;

            if GetJsonvalue(shipToObject, 'email').IsNull = false then begin
                InterimSalesHeader."Ship-to Email" := CopyStr(GetJsonvalue(shipToObject, 'email').AsText(), 1, 80);
            end;

            contactAddressObject := GetJsonToken(shipToObject, 'contactAddress').AsObject();
            if GetJsonvalue(contactAddressObject, 'addressLine1').IsNull = false then begin
                InterimSalesHeader."Ship-to Address" := CopyStr(GetJsonvalue(contactAddressObject, 'addressLine1').AsText(), 1, 50);
            end;

            if GetJsonvalue(contactAddressObject, 'city').IsNull = false then begin
                InterimSalesHeader."Ship-to City" := CopyStr(GetJsonvalue(contactAddressObject, 'city').AsText(), 1, 30);
            end;

            if GetJsonvalue(contactAddressObject, 'postalCode').IsNull = false then begin
                InterimSalesHeader."Ship-to Post Code" := CopyStr(GetJsonvalue(contactAddressObject, 'postalCode').AsCode(), 1, 20);
            end;

            if GetJsonvalue(contactAddressObject, 'countryCode').IsNull = false then begin
                InterimSalesHeader."Ship-to Country/Region Code" := CopyStr(GetJsonvalue(contactAddressObject, 'countryCode').AsCode(), 1, 10);
            end;

            if shipToObject.Contains('primaryPhone') then begin
                primaryphoneObject := GetJsonToken(shipToObject, 'primaryPhone').AsObject();
                if primaryphoneObject.Contains('phoneNumber') then begin
                    if GetJsonvalue(primaryphoneObject, 'phoneNumber').IsNull = false then begin
                        InterimSalesHeader."Ship-to Phone" := CopyStr(GetJsonvalue(primaryphoneObject, 'phoneNumber').AsText(), 1, 20);
                    end;
                end;
            end;

        end;

        InterimSalesHeader.Insert();

    end;


    local procedure InsertInterimSalesLineREST(var InterimSalesHeader: Record "Interim Sales Header" temporary; orderHeaderObject: JsonObject; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        ItemArray: JsonArray;
        itemCount: Integer;
        lineItemObject: JsonObject;
        j: Integer;
        lineItemToken: JsonToken;
        lineItemCostObject: JsonObject;
        deliveryCostObject: JsonObject;
        shippingCostObject: JsonObject;
        lineItemFullfillObject: JsonObject;
        ShipmentDate: Text;
        LineAmount: Decimal;
        LineQuantity: Decimal;
    begin
        ItemArray := GetJsonToken(orderHeaderObject, 'lineItems').AsArray();
        itemCount := ItemArray.Count;
        if itemCount > 0 then begin

            for j := 0 to itemCount - 1 do begin
                ItemArray.Get(j, lineItemToken);
                lineItemObject := lineItemToken.AsObject;

                InterimSalesLine.Init;
                InterimSalesLine."Line No." := j;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";
                InterimSalesLine.Weight := 1;
                InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";

                if GetJsonvalue(lineItemObject, 'lineItemId').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(lineItemObject, 'lineItemId').AsCode();
                end;

                if GetJsonvalue(lineItemObject, 'sku').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := CopyStr(GetJsonvalue(lineItemObject, 'sku').AsText(), 1, 50);
                end;

                if GetJsonvalue(lineItemObject, 'title').IsNull = false then begin
                    InterimSalesLine.Description := CopyStr(GetJsonvalue(lineItemObject, 'title').AsText(), 1, 100);
                end;

                if GetJsonvalue(lineItemObject, 'quantity').IsNull = false then begin
                    Clear(LineQuantity);
                    LineQuantity := GetJsonvalue(lineItemObject, 'quantity').AsDecimal();
                    InterimSalesLine.Quantity := GetJsonvalue(lineItemObject, 'quantity').AsDecimal();
                end;

                lineItemCostObject := GetJsonToken(lineItemObject, 'lineItemCost').AsObject();
                if GetJsonvalue(lineItemCostObject, 'value').IsNull = false then begin
                    Clear(LineAmount);
                    LineAmount := GetJsonvalue(lineItemCostObject, 'value').AsDecimal();
                    InterimSalesLine.Amount := GetJsonvalue(lineItemCostObject, 'value').AsDecimal();
                    InterimSalesLine."Unit Price" := Round(LineAmount / LineQuantity, 0.01);
                end;

                if GetJsonvalue(lineItemCostObject, 'convertedFromCurrency').IsNull = false then begin
                    InterimSalesLine."Currency Code" := CopyStr(GetJsonvalue(lineItemCostObject, 'convertedFromCurrency').AsCode(), 1, 10);
                end;

                deliveryCostObject := GetJsonToken(lineItemObject, 'deliveryCost').AsObject();
                shippingCostObject := GetJsonToken(deliveryCostObject, 'shippingCost').AsObject();
                if GetJsonvalue(shippingCostObject, 'value').IsNull = false then begin
                    InterimSalesLine."Shipping Price" := GetJsonvalue(shippingCostObject, 'value').AsDecimal();
                end;

                //For Shipment Date in Header
                lineItemFullfillObject := GetJsonToken(lineItemObject, 'lineItemFulfillmentInstructions').AsObject();
                if GetJsonvalue(lineItemFullfillObject, 'shipByDate').IsNull = false then begin
                    ShipmentDate := GetJsonvalue(lineItemFullfillObject, 'shipByDate').AsText();
                    InterimSalesHeader."Shipment Date" := GenerateNewDate(ShipmentDate);
                    InterimSalesHeader.Modify();
                end;

                InterimSalesLine.Insert();
            end;

        end;
    end;


    procedure GetEbayInventoryItemsREST(ChannelCode: Code[20]; NextURL: Text; AccessToken: Text)
    var
        inventoryClient: HttpClient;
        inventoryHeaders: HttpHeaders;
        inventoryContent: HttpContent;
        inventoryResponseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        authorization: Text;
        jObject: JsonObject;
        totalRecords: Integer;
        noOfRecords: Integer;
        i: Integer;
        jArray: JsonArray;
        inventoryItemToken: JsonToken;
        inventoryItemObject: JsonObject;
        sku: Text;
        getOfferObject: JsonObject;
        groupIdArray: JsonArray;
        groupIdToken: JsonToken;
        groupIdObject: JsonObject;
        groupId: Text;
        ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);
        if AccessToken = '' then begin
            AccessToken := GetAccessTokenREST(ChannelCode);
        end;

        inventoryHeaders := inventoryClient.DefaultRequestHeaders;
        authorization := 'Bearer ' + AccessToken;
        inventoryHeaders.Add('Authorization', authorization);
        inventoryContent.GetHeaders(inventoryHeaders);
        inventoryHeaders.Clear();
        inventoryHeaders.Add('Content-Type', 'application/json');

        if NextURL <> '' then begin
            URL := Service_URL + NextURL;
        end
        else begin
            URL := Service_URL + '/sell/inventory/v1/inventory_item';                     //Live URL
            //URL := 'https://api.sandbox.ebay.com/sell/inventory/v1/inventory_item';         //Sandbox URL
        end;

        if inventoryClient.Get(URL, inventoryResponseMessage) then begin

            if inventoryResponseMessage.HttpStatusCode = 200 then begin

                inventoryResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);

                if jObject.Contains('next') then begin
                    if GetJsonvalue(jObject, 'next').IsNull = false then begin
                        NextURL := GetJsonvalue(jObject, 'next').AsText();
                    end;
                end
                else begin
                    NextURL := '';
                end;

                totalRecords := GetJsonvalue(jObject, 'total').AsInteger();
                if totalRecords > 0 then begin

                    jArray := GetJsonToken(jObject, 'inventoryItems').AsArray();
                    noOfRecords := jArray.Count;

                    for i := 0 to noOfRecords - 1 do begin
                        jArray.Get(i, inventoryItemToken);
                        inventoryItemObject := inventoryItemToken.AsObject();

                        //Getting SKU
                        if GetJsonvalue(inventoryItemObject, 'sku').IsNull = false then begin
                            sku := GetJsonvalue(inventoryItemObject, 'sku').AsText();
                        end;

                        if sku <> '' then begin
                            //Getting Offer Details using SKU
                            getOfferObject := GetOfferBySkuREST(ChannelCode, AccessToken, sku);

                            ChannelItemListing.RESET;
                            ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                            ChannelItemListing.SETRANGE("Channel SKU", sku);

                            IF ChannelItemListing.FINDFIRST THEN BEGIN
                                UpdateProductEbayREST(FALSE, ChannelCode, sku, ChannelItemListing, getOfferObject, inventoryItemObject);
                            END
                            ELSE BEGIN
                                Clear(ChannelItemListing);
                                UpdateProductEbayREST(TRUE, ChannelCode, sku, ChannelItemListing, getOfferObject, inventoryItemObject);
                            END;

                            //Getting Group Id Value
                            if inventoryItemObject.Contains('groupIds') then begin
                                groupIdArray := GetJsonToken(inventoryItemObject, 'groupIds').AsArray();
                                groupIdArray.Get(0, groupIdToken);
                                groupId := groupIdToken.AsValue().AsText();

                                //Create Main Item
                                ChannelItemListing.Reset();
                                ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                                ChannelItemListing.SETRANGE("Channel SKU", groupId);

                                if ChannelItemListing.FindFirst() then begin
                                    CreateMainItemREST(False, ChannelCode, groupId, ChannelItemListing, inventoryItemObject, getOfferObject);
                                end
                                else begin
                                    Clear(ChannelItemListing);
                                    CreateMainItemREST(true, ChannelCode, groupId, ChannelItemListing, inventoryItemObject, getOfferObject);
                                end;
                            end;
                        end;
                    end;

                end
                else begin
                    ChannelItemListing.Remarks := 'No Inventory Getting From Portal';
                    ChannelItemListing."Modified On" := CurrentDateTime;
                    ChannelItemListing.Modify(true);
                end;

            end
            else begin
                ChannelItemListing.Remarks := StrSubstNo('Getting Error Code %1 While Sending API Request', inventoryResponseMessage.HttpStatusCode);
                ChannelItemListing."Modified On" := CurrentDateTime;
                ChannelItemListing.Modify(true);
            end;

        end;

        if NextURL <> '' then
            GetEbayInventoryItemsREST(ChannelCode, NextURL, AccessToken);

        //Create Item on Portal
        // ChannelItemListing.RESET;
        // ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        // ChannelItemListing.SETRANGE("Listing Status", ChannelItemListing."Listing Status"::"Not Listed");
        // ChannelItemListing.SETRANGE("ASIN No", '');
        // if ChannelItemListing.FindSet() then begin
        //     repeat
        //         CreateBulkInventoryItemREST(ChannelCode, ChannelItemListing, AccessToken);
        //     until ChannelItemListing.Next = 0;
        // end;
        if NextURL = '' then begin
            Message('Inventory Sync Complete');
        end;
    end;


    procedure CreateMainItemREST(bool: Boolean; ChannelCode: Code[20]; sku: Text; ChannelItemListing: Record "Channel Item Listing"; inventoryItemObject: JsonObject; getOfferObject: JsonObject)
    var
        productObject: JsonObject;
        availabilityObject: JsonObject;
        shipToLocationAvailabilityObject: JsonObject;
        pricingSummaryObject: JsonObject;
        priceObject: JsonObject;
        listingObject: JsonObject;
        ListingId: Code[50];
        Title: Text;
        Quantity: Integer;
        UnitPrice: Decimal;
    begin
        //Channel Title
        productObject := GetJsonToken(inventoryItemObject, 'product').AsObject();
        if GetJsonvalue(productObject, 'title').IsNull = false then begin
            Clear(Title);
            Title := GetJsonvalue(productObject, 'title').AsText();
        end;

        //Quantity
        if inventoryItemObject.Contains('availability') then begin
            availabilityObject := GetJsonToken(inventoryItemObject, 'availability').AsObject();
            if availabilityObject.Contains('shipToLocationAvailability') then begin
                shipToLocationAvailabilityObject := GetJsonToken(availabilityObject, 'shipToLocationAvailability').AsObject();

                if GetJsonvalue(shipToLocationAvailabilityObject, 'quantity').IsNull = false then begin
                    Clear(Quantity);
                    Quantity := GetJsonvalue(shipToLocationAvailabilityObject, 'quantity').AsInteger();
                end;
            end;
        end;

        //Unit Price
        pricingSummaryObject := GetJsonToken(getOfferObject, 'pricingSummary').AsObject();
        priceObject := GetJsonToken(pricingSummaryObject, 'price').AsObject();

        if GetJsonvalue(priceObject, 'value').IsNull = false then begin
            Clear(UnitPrice);
            UnitPrice := GetJsonvalue(priceObject, 'value').AsDecimal();
        end;

        //Listing ID
        if getOfferObject.Contains('listing') then begin
            listingObject := GetJsonToken(getOfferObject, 'listing').AsObject();

            if GetJsonvalue(listingObject, 'listingId').IsNull = false then begin
                Clear(ListingId);
                ListingId := CopyStr(GetJsonvalue(listingObject, 'listingId').AsCode(), 1, 50);
            end;
        End;

        if bool then begin
            ChannelItemListing."Channel Code" := ChannelCode;
            ChannelItemListing.Validate("Channel SKU", sku);
            ChannelItemListing.Validate("Channel Title", CopyStr(Title, 1, 250));
            ChannelItemListing.Validate("Channel Inventory", Quantity);
            ChannelItemListing.Validate("Unit Price", UnitPrice);
            ChannelItemListing.Validate("ASIN No", ListingId);
            ChannelItemListing."Created On" := CurrentDateTime;
            ChannelItemListing.INSERT(TRUE);
        end
        else begin
            ChannelItemListing.Rename(ChannelItemListing."Channel Code", ChannelItemListing."Channel SKU", ChannelItemListing."ASIN No", '');
            ChannelItemListing.Validate("Channel Title", CopyStr(Title, 1, 250));
            ChannelItemListing.Validate("Channel Inventory", Quantity);
            ChannelItemListing.Validate("Unit Price", UnitPrice);
            ChannelItemListing."Modified On" := CurrentDateTime;
            ChannelItemListing.MODIFY(TRUE);
        end;
    end;


    procedure GetOfferBySkuREST(ChannelCode: Code[20]; AccessToken: Text; sku: Text): JsonObject
    var
        getOfferClient: HttpClient;
        getOfferHeaders: HttpHeaders;
        getOfferContent: HttpContent;
        getOfferResponseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        authorization: Text;
        jObject: JsonObject;
        offersArray: JsonArray;
        offersToken: JsonToken;
        offerObject: JsonObject;
    begin
        if sku <> '' then begin
            GetCredentials(ChannelCode);

            getOfferHeaders := getOfferClient.DefaultRequestHeaders;
            authorization := 'Bearer ' + AccessToken;
            getOfferHeaders.Add('Authorization', authorization);
            getOfferContent.GetHeaders(getOfferHeaders);
            getOfferHeaders.Clear();
            getOfferHeaders.Add('Content-Type', 'application/json');

            URL := Service_URL + '/sell/inventory/v1/offer?sku=' + sku;                   //Live URL
            //URL := 'https://api.sandbox.ebay.com/sell/inventory/v1/offer?sku=' + sku;       //Sandbox URL

            if getOfferClient.Get(URL, getOfferResponseMessage) then begin

                if getOfferResponseMessage.HttpStatusCode = 200 then begin
                    getOfferResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    offersArray := GetJsonToken(jObject, 'offers').AsArray();
                    offersArray.Get(0, offersToken);
                    offerObject := offersToken.AsObject();
                    exit(offerObject);
                end
                else begin
                    Error('Error Code : %1', getOfferResponseMessage.HttpStatusCode);
                end;

            end;
        end;
    end;


    local procedure UpdateProductEbayREST(bool: Boolean; ChannelCode: Code[10]; ChannelSKU: Text; ChannelItemListing: Record "Channel Item Listing"; getOfferObject: JsonObject; inventoryItemObject: JsonObject)
    var
        productObject: JsonObject;
        availabilityObject: JsonObject;
        shipToLocationAvailabilityObject: JsonObject;
        pricingSummaryObject: JsonObject;
        priceObject: JsonObject;
        listingObject: JsonObject;
        quantityToken: JsonToken;
        Title: Text;
        Quantity: Integer;
        UnitPrice: Decimal;
        Status: Text;
        OfferId: Text;
        ListingId: Code[50];
    begin
        //Channel Title
        productObject := GetJsonToken(inventoryItemObject, 'product').AsObject();
        if GetJsonvalue(productObject, 'title').IsNull = false then begin
            Clear(Title);
            Title := GetJsonvalue(productObject, 'title').AsText();
        end;

        //Quantity
        if inventoryItemObject.Contains('availability') then begin
            availabilityObject := GetJsonToken(inventoryItemObject, 'availability').AsObject();
            if availabilityObject.Contains('shipToLocationAvailability') then begin
                shipToLocationAvailabilityObject := GetJsonToken(availabilityObject, 'shipToLocationAvailability').AsObject();
                Clear(Quantity);
                Quantity := GetJsonvalue(shipToLocationAvailabilityObject, 'quantity').AsInteger();
            end;
        end;

        //Unit Price
        pricingSummaryObject := GetJsonToken(getOfferObject, 'pricingSummary').AsObject();
        priceObject := GetJsonToken(pricingSummaryObject, 'price').AsObject();

        if GetJsonvalue(priceObject, 'value').IsNull = false then begin
            Clear(UnitPrice);
            UnitPrice := GetJsonvalue(priceObject, 'value').AsDecimal();
        end;

        //Offer Id
        if GetJsonvalue(getOfferObject, 'offerId').IsNull = false then begin
            Clear(OfferId);
            OfferId := GetJsonvalue(getOfferObject, 'offerId').AsText();
        end;

        //Listing Id
        if getOfferObject.Contains('listing') then begin
            listingObject := GetJsonToken(getOfferObject, 'listing').AsObject();
            if GetJsonvalue(listingObject, 'listingId').IsNull = false then begin
                Clear(ListingId);
                ListingId := CopyStr(GetJsonvalue(listingObject, 'listingId').AsCode(), 1, 50);
            end;

            //Status
            if GetJsonvalue(listingObject, 'listingStatus').IsNull = false then begin
                Clear(Status);
                Status := GetJsonvalue(listingObject, 'listingStatus').AsText();
            end;
        end;

        if not bool then begin
            ChannelItemListing.Rename(ChannelItemListing."Channel Code", ChannelItemListing."Channel SKU", ListingId, OfferId);
            ChannelItemListing.Validate("Channel Title", CopyStr(Title, 1, 250));
            ChannelItemListing.Validate("Channel Inventory", Quantity);
            ChannelItemListing.Validate("Unit Price", UnitPrice);
            IF Status = 'ACTIVE' then begin
                ChannelItemListing.VALIDATE(Status, ChannelItemListing.Status::Active);
            end
            else begin
                ChannelItemListing.VALIDATE(Status, ChannelItemListing.Status::Inactive);
            end;
            ChannelItemListing."Modified On" := CurrentDateTime;
            ChannelItemListing.MODIFY(TRUE);
        end
        else begin
            ChannelItemListing."Channel Code" := ChannelCode;
            ChannelItemListing.Validate("Channel SKU", ChannelSKU);
            ChannelItemListing.Validate("Channel Title", CopyStr(Title, 1, 250));
            ChannelItemListing.Validate("Channel Inventory", Quantity);
            ChannelItemListing.Validate("Unit Price", UnitPrice);
            ChannelItemListing.Validate("ASIN No", ListingId);
            ChannelItemListing.Validate("Channel Variant", CopyStr(OfferId, 1, 50));
            IF Status = 'ACTIVE' then begin
                ChannelItemListing.VALIDATE(Status, ChannelItemListing.Status::Active);
            end
            else begin
                ChannelItemListing.VALIDATE(Status, ChannelItemListing.Status::Inactive);
            end;
            ChannelItemListing."Created On" := CurrentDateTime;
            ChannelItemListing.INSERT(TRUE);
        end;
    end;


    procedure CreateBulkInventoryItemREST(ChannelCode: Code[20]; ChannelItemListing: Record "Channel Item Listing"; AccessToken: Text)
    var
        inventoryClient: HttpClient;
        inventoryHeaders: HttpHeaders;
        inventoryContent: HttpContent;
        inventoryResponseMessage: HttpResponseMessage;
        requestBody: Text;
        URL: Text;
        response: Text;
        jObject: JsonObject;
        authorization: Text;
        quantity: Decimal;
        description: Text[250];
        imageURL: Text[200];
        title: Text[250];
        sku: Text[50];
        length: Decimal;
        width: Decimal;
        height: Decimal;
        weight: Decimal;
        offerId: Text;
        listingId: Code[50];
        remarksMessage: Text[100];
        itemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        GetCredentials(ChannelCode);
        if AccessToken = '' then begin
            AccessToken := GetAccessTokenREST(ChannelCode);
        end;

        inventoryHeaders := inventoryClient.DefaultRequestHeaders;
        authorization := 'Bearer ' + AccessToken;
        inventoryHeaders.Add('Authorization', authorization);

        Clear(quantity);
        Clear(description);
        Clear(imageURL);
        Clear(title);
        Clear(sku);
        Clear(length);
        Clear(width);
        Clear(height);
        Clear(weight);

        quantity := ChannelItemListing."Channel Inventory";
        description := CopyStr(ChannelItemListing."Channel Description", 1, 250);
        title := CopyStr(ChannelItemListing."Channel Title", 1, 250);
        imageURL := CopyStr(ChannelItemListing."Image Url 1", 1, 200);
        sku := CopyStr(ChannelItemListing."Channel SKU", 1, 50);

        itemUnitOfMeasure.SetRange("Item No.", ChannelItemListing."Item No.");
        if itemUnitOfMeasure.FindFirst() then begin
            length := itemUnitOfMeasure.Length;
            width := itemUnitOfMeasure.Width;
            height := itemUnitOfMeasure.Height;
            weight := itemUnitOfMeasure.Weight;
        end;


        if (description <> '') and (imageURL <> '') and (title <> '') and (sku <> '') and (length <> 0) and (width <> 0) and (height <> 0) and (weight <> 0) then begin

            //Dynamic Request Body
            // requestBody := '{"requests": [{"availability": {"shipToLocationAvailability": {"quantity": "' + Format(quantity) + '"}},"condition": "NEW","locale": "en_GB",' +
            // '"packageWeightAndSize": {"dimensions": {"height": "' + format(height) + '","length": "' + Format(length) + '","unit": "INCH","width": "' + Format(width) + '"},' +
            // '"packageType": "LETTER","weight": {"unit": "GRAM","value": "' + Format(weight) + '"}},"product": {"aspects": {"Brand": ["!Solid"],"Colour": ["Black"],' +
            // '"Department": ["Unisex Kids"],"Style": ["Boat Shoe"],"Type": ["Casual"],"Upper Material": ["Acetate"],"Shoe Size": ["E 31"]},' +
            // '"brand": "!Solid","description": "' + description + '","imageUrls": ["' + imageURL + '"],"mpn": "Does not apply","title": "' + title + '"},"sku": "' + sku + '"}]}';

            //Hard Coded Request Body
            requestBody := '{"requests": [{"availability": {"shipToLocationAvailability": {"quantity": "10"}},"condition": "NEW","locale": "en_GB",' +
            '"packageWeightAndSize": {"dimensions": {"height": "21.0","length": "12.0","unit": "INCH","width": "15.0"},' +
            '"packageType": "LETTER","weight": {"unit": "GRAM","value": "20.5"}},"product": {"aspects": {"Brand": ["!Solid"],"Colour": ["Black"],' +
            '"Department": ["Unisex Kids"],"Style": ["Boat Shoe"],"Type": ["Casual"],"Upper Material": ["Acetate"],"Shoe Size": ["E 31"]},' +
            '"brand": "!Solid","description": "TEST DESCRIPTION","imageUrls": ["https://i.ebayimg.com/00/s/OTk5WDc0OQ==/z/54IAAOSw3thbW20V/$_12.JPG?set_id=880000500F"],"mpn": "Does not apply","title": "' + title + '"},"sku": "' + sku + '"}]}';
            inventoryContent.WriteFrom(requestBody);
            inventoryContent.GetHeaders(inventoryHeaders);

            inventoryHeaders.Clear();
            inventoryHeaders.Add('Content-Type', 'application/json');
            inventoryHeaders.Add('X-EBAY-C-MARKETPLACE-ID', 'EBAY_GB');

            //URL := Service_URL + '/sell/inventory/v1/bulk_create_or_replace_inventory_item';                  //Live URL
            URL := 'https://api.sandbox.ebay.com/sell/inventory/v1/bulk_create_or_replace_inventory_item';      //Sandbox URL

            if inventoryClient.Post(URL, inventoryContent, inventoryResponseMessage) then begin

                if inventoryResponseMessage.HttpStatusCode = 200 then begin
                    offerId := CreateOfferREST(ChannelCode, ChannelItemListing, AccessToken);
                    listingId := PublishOfferREST(ChannelCode, offerId, AccessToken, ChannelItemListing);
                    if listingId <> '' then begin
                        ChannelItemListing.Validate("ASIN No", CopyStr(listingId, 1, 50));
                        ChannelItemListing."Modified On" := CurrentDateTime;
                        ChannelItemListing.Modify(true);
                    end;
                end
                else begin
                    Error('Error Code : %1', inventoryResponseMessage.HttpStatusCode);
                end;

            end
            else begin
                ChannelItemListing.Remarks := StrSubstNo('Create Inventory API Request Failed to Send with Error Code : %1', inventoryResponseMessage.HttpStatusCode);
                ChannelItemListing."Modified On" := CurrentDateTime;
                ChannelItemListing.Modify(true);
            end;

        end
        else begin
            if description = '' then
                remarksMessage := 'Description ';
            if imageURL = '' then
                remarksMessage := remarksMessage + 'Image URL ';
            if title = '' then
                remarksMessage := remarksMessage + 'Title ';
            if sku = '' then
                remarksMessage := remarksMessage + 'SKU ';

            remarksMessage := remarksMessage + 'Can not be pass as blank ';

            if length = 0 then
                remarksMessage := remarksMessage + 'Length ';
            if width = 0 then
                remarksMessage := remarksMessage + 'Width ';
            if height = 0 then
                remarksMessage := remarksMessage + 'Height ';
            if weight = 0 then
                remarksMessage := remarksMessage + 'Weight ';

            remarksMessage := remarksMessage + 'Can not be pass as Zero';
            ChannelItemListing.Remarks := CopyStr(remarksMessage, 1, 100);
            ChannelItemListing."Modified On" := CurrentDateTime;
            ChannelItemListing.Modify(true);
        end;

    end;


    procedure CreateOfferREST(ChannelCode: Code[20]; ChannelItemListing: Record "Channel Item Listing"; AccessToken: Text): Text
    var
        createOfferClient: HttpClient;
        createOfferHeaders: HttpHeaders;
        createOfferContent: HttpContent;
        createOfferResponseMessage: HttpResponseMessage;
        requestBody: Text;
        URL: Text;
        response: Text;
        jObject: JsonObject;
        authorization: Text;
        sku: Text[50];
        quantity: Text;
        description: Text[250];
        price: Decimal;
        offerId: Text;
        errorResponse: Text;
        errorObject: JsonObject;
        errorArray: JsonArray;
        errorToken: JsonToken;
        noOfErrors: Integer;
        i: Integer;
        errorMessageObject: JsonObject;
        errorMessage: Text;
        remarksMessage: Text;
    begin
        GetCredentials(ChannelCode);
        if AccessToken = '' then begin
            AccessToken := GetAccessTokenREST(ChannelCode);
        end;

        createOfferHeaders := createOfferClient.DefaultRequestHeaders;
        authorization := 'Bearer ' + AccessToken;
        createOfferHeaders.Add('Authorization', authorization);

        Clear(sku);
        Clear(quantity);
        Clear(description);
        Clear(price);

        sku := CopyStr(ChannelItemListing."Channel SKU", 1, 50);
        quantity := Format(ChannelItemListing."Channel Inventory");
        description := ChannelItemListing."Channel Description";
        price := ChannelItemListing."Unit Price";

        if (description <> '') and (sku <> '') and (price <> 0) then begin

            //With Policy Details Request Body
            //requestBody := '{"sku": "' + sku + '","marketplaceId": "EBAY_GB","merchantLocationKey":"TESTWarehouse","format": "FIXED_PRICE","availableQuantity": ' + quantity + ',' +
            //'"categoryId": "155202","listingDescription": "' + description + '","listingPolicies": {"fulfillmentPolicyId": "3*********0","paymentPolicyId": "3*********0",' +
            //'"returnPolicyId": "3*********0"},"pricingSummary": {"price": {"currency": "GBP","value": "' + Format(price) + '"}},"quantityLimitPerBuyer": 5,"includeCatalogProductDetails": true}';

            //Without Policy Details Request Body
            requestBody := '{"sku": "' + sku + '","marketplaceId": "EBAY_GB","merchantLocationKey":"TESTWarehouse","format": "FIXED_PRICE","availableQuantity": ' + quantity + ',' +
            '"categoryId": "155202","listingDescription": "TEST DESCRIPTION","pricingSummary": {"price": {"currency": "GBP","value": "' + Format(price) + '"}},' +
            '"quantityLimitPerBuyer": 5,"includeCatalogProductDetails": true}';
            createOfferContent.WriteFrom(requestBody);
            createOfferContent.GetHeaders(createOfferHeaders);

            createOfferHeaders.Clear();
            createOfferHeaders.Add('Content-Type', 'application/json');
            createOfferHeaders.Add('Content-Language', 'en-GB');
            createOfferHeaders.Add('X-EBAY-C-MARKETPLACE-ID', 'EBAY_GB');

            //URL := Service_URL + '/sell/inventory/v1/offer';                  //Live URL
            URL := 'https://api.sandbox.ebay.com/sell/inventory/v1/offer';      //Sandbox URL

            if createOfferClient.Post(URL, createOfferContent, createOfferResponseMessage) then begin

                if createOfferResponseMessage.HttpStatusCode = 201 then begin
                    createOfferResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);

                    if GetJsonvalue(jObject, 'offerId').IsNull = false then begin
                        offerId := GetJsonvalue(jObject, 'offerId').AsText();
                        ChannelItemListing.Validate("Channel Variant", CopyStr(offerId, 1, 50));
                        ChannelItemListing."Modified On" := CurrentDateTime;
                        ChannelItemListing.Modify(true);
                        exit(offerId);
                    end;

                end
                else begin
                    createOfferResponseMessage.Content.ReadAs(errorResponse);
                    errorObject.ReadFrom(errorResponse);
                    errorArray := GetJsonToken(errorObject, 'errors').AsArray();
                    noOfErrors := errorArray.Count;
                    for i := 0 to noOfErrors - 1 do begin
                        Clear(errorMessage);
                        errorArray.Get(i, errorToken);
                        errorMessageObject := errorToken.AsObject();
                        errorMessage := GetJsonvalue(errorMessageObject, 'message').AsText();
                        ChannelItemListing.Remarks := CopyStr(errorMessage, 1, 100);
                        ChannelItemListing."Modified On" := CurrentDateTime;
                        ChannelItemListing.Modify(true);
                    end;
                end;

            end
            else begin
                ChannelItemListing.Remarks := StrSubstNo('Create Offer API Request Failed to Send with Error Code : %1', createOfferResponseMessage.HttpStatusCode);
                ChannelItemListing."Modified On" := CurrentDateTime;
                ChannelItemListing.Modify(true);
            end;
        end
        else begin
            if description = '' then
                remarksMessage := 'Description ';
            if sku = '' then
                remarksMessage := remarksMessage + 'SKU ';

            remarksMessage := remarksMessage + 'can not be pass as Blank ';

            if price = 0 then
                remarksMessage := remarksMessage + 'Price can not be pass as Zero';

            ChannelItemListing.Remarks := CopyStr(remarksMessage, 1, 100);
            ChannelItemListing."Modified On" := CurrentDateTime;
            ChannelItemListing.Modify(true);
        end;

    end;


    procedure PublishOfferREST(ChannelCode: Code[20]; offerId: Text; AccessToken: Text; ChannelItemListing: Record "Channel Item Listing"): Code[50]
    var
        publishOfferClient: HttpClient;
        publishOfferHeaders: HttpHeaders;
        publishOfferContent: HttpContent;
        publishOfferResponseMessage: HttpResponseMessage;
        requestBody: Text;
        URL: Text;
        response: Text;
        jObject: JsonObject;
        authorization: Text;
        listingId: Code[50];
        errorResponse: Text;
        errorObject: JsonObject;
        errorArray: JsonArray;
        errorToken: JsonToken;
        noOfErrors: Integer;
        i: Integer;
        errorMessageObject: JsonObject;
        errorMessage: Text;
    begin
        GetCredentials(ChannelCode);
        if AccessToken = '' then begin
            AccessToken := GetAccessTokenREST(ChannelCode);
        end;

        publishOfferHeaders := publishOfferClient.DefaultRequestHeaders;
        authorization := 'Bearer ' + AccessToken;
        publishOfferHeaders.Add('Authorization', authorization);

        publishOfferContent.GetHeaders(publishOfferHeaders);
        publishOfferHeaders.Clear();
        publishOfferHeaders.Add('Content-Type', 'application/json');
        publishOfferHeaders.Add('X-EBAY-C-MARKETPLACE-ID', 'EBAY_GB');

        //URL := Service_URL + '/sell/inventory/v1/offer/' + offerId + '/publish/';                     //Live URL
        URL := 'https://api.sandbox.ebay.com/sell/inventory/v1/offer/' + offerId + '/publish/';         //Sandbox URL

        if publishOfferClient.Post(URL, publishOfferContent, publishOfferResponseMessage) then begin

            if publishOfferResponseMessage.HttpStatusCode = 200 then begin
                publishOfferResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                if GetJsonvalue(jObject, 'listingId').IsNull = false then begin
                    listingId := GetJsonvalue(jObject, 'listingId').AsCode();
                    exit(listingId);
                end;
            end
            else begin
                publishOfferResponseMessage.Content.ReadAs(errorResponse);
                errorObject.ReadFrom(errorResponse);
                errorArray := GetJsonToken(errorObject, 'errors').AsArray();
                noOfErrors := errorArray.Count;
                for i := 0 to noOfErrors - 1 do begin
                    Clear(errorMessage);
                    errorArray.Get(i, errorToken);
                    errorMessageObject := errorToken.AsObject();
                    errorMessage := GetJsonvalue(errorMessageObject, 'message').AsText();
                    ChannelItemListing.Remarks := CopyStr(errorMessage, 1, 100);
                    ChannelItemListing."Modified On" := CurrentDateTime;
                    ChannelItemListing.Modify(true);
                end;
            end;

        end
        else begin
            Error('Error Code : %1', publishOfferResponseMessage.HttpStatusCode);
        end;
    end;


    procedure EbayOrderFulfillmentREST(P_Channel: Code[20])
    var
        fullfillmentclient: HttpClient;
        fullfillmentcontent: HttpContent;
        fullfillmentheaders: HttpHeaders;
        fullfillmentresponseMessage: HttpResponseMessage;
        fullfillmentURL: Text;
        fullfillmentresponse: Text;
        AccessToken: Text;
        authorization: Text;
        requestBody: Text;
        itemId: Text;
        Quantity: Text;
        ShipmentDate: Text;
        L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_TradePartner: Record "Trade Partner";
    begin
        if L_TradePartner.Get(P_Channel) then begin
            if L_TradePartner.OrderFullFilment = true then begin

                GetCredentials(L_TradePartner.Code);
                AccessToken := GetAccessTokenREST(L_TradePartner.Code);

                L_HandledInterimSalesHeader.RESET;
                L_HandledInterimSalesHeader.SETRANGE("Trade Partner Code", L_TradePartner.Code);
                L_HandledInterimSalesHeader.SETFILTER("FullFillment Status", '<>%1', L_HandledInterimSalesHeader."FullFillment Status"::Fullfilled);
                L_HandledInterimSalesHeader.SETRANGE(Status, L_HandledInterimSalesHeader.Status::Dispatched);
                L_HandledInterimSalesHeader.SETFILTER("Package Tracking No.", '<>%1', '');

                if L_HandledInterimSalesHeader.FindSet() then begin
                    repeat
                        Clear(ShipmentDate);
                        ShipmentDate := Format(L_HandledInterimSalesHeader."Shipment Date", 0, '20<Year>-<Month,2>-<Day,2>T00:00:00Z');

                        Clear(itemId);
                        Clear(Quantity);
                        L_InterimSalesLine.Reset();
                        L_InterimSalesLine.SetRange("Document No", L_HandledInterimSalesHeader."No.");
                        if L_InterimSalesLine.FindFirst() then begin
                            itemId := L_InterimSalesLine."Channel Item Id";
                            Quantity := Format(L_InterimSalesLine.Quantity);
                        end;

                        if itemId <> '' then begin
                            fullfillmentheaders := fullfillmentclient.DefaultRequestHeaders;
                            authorization := 'Bearer ' + AccessToken;
                            fullfillmentheaders.Add('Authorization', authorization);

                            requestBody := '{"lineItems" : [{"lineItemId": "' + itemId + '","quantity" : "' + Quantity + '"}],' +
                            '"shippedDate" : "' + ShipmentDate + '","shippingCarrierCode" : "''","trackingNumber" : "' + L_HandledInterimSalesHeader."Tracking No." + '"}';
                            fullfillmentcontent.WriteFrom(requestBody);
                            fullfillmentcontent.GetHeaders(fullfillmentheaders);

                            fullfillmentheaders.Clear();
                            fullfillmentheaders.Add('Content-Type', 'application/json');

                            fullfillmentURL := Service_URL + '/oauth/api_scope/sell.fulfillment';   //LIVE

                            if fullfillmentclient.Post(fullfillmentURL, fullfillmentcontent, fullfillmentresponseMessage) then begin
                                if fullfillmentresponseMessage.HttpStatusCode = 201 then begin
                                    L_HandledInterimSalesHeader."FullFillment Status" := L_HandledInterimSalesHeader."FullFillment Status"::Fullfilled;
                                    L_HandledInterimSalesHeader.Modify(true);
                                end;
                            end;
                        end;

                    until L_HandledInterimSalesHeader.Next() = 0;
                end;
            end;
        end;
    end;





    //*****************************************EBAY SOAP API******************************************************

    //Procedure to Retrieve Orders from Ebay with Date Filter
    procedure GetEbayOrders(ChannelCode: Code[10])
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        CreateDateTo: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        i: Integer;
        noOfResult: Integer;
        ChannelOrderId: Text;
        orderToken: JsonToken;
        orderHeaderObject: JsonObject;
        WebHeaderObject: JsonObject;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
    begin
        GetCredentials(ChannelCode);
        CreateDateTo := Format(CurrentDateTime, 0, '20<Year><Month,2><Day,2><Hours12,2><Minutes,2><Seconds,2>');

        URL := 'http://webintegrationapi.azurewebsites.net/api/EbayAPI/GetOrders?applicationId='
             + applicationId + '&certificateId=' + certificateId + '&developerId='
             + developerId + '&Service_URL=' + Service_URL +
            '&version=1057&ebayToken=AgAAAA**AQAAAA**aAAAAA**igiRYA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFk4OoAZGLqAmdj6x9nY+seQ**' +
            '+mYGAA**AAMAAA**gxRTEqkLBBoqGuU9MjjdwaKbqtQvD1hFWQaj8cVFmAPkX7NFGwJH1UX/Q5MjQHBjewb5VGpwvRVRn1zsKHVZjaIBa+uYWvRVRm7tGNMZcc8tZIojR+' +
            '8JxbOEnGKUPcdrKpVoXcxdlYSbQ/VTaVoHdMpTqcYUc++kjyQrDVl0fgle7nwLXWUnUsUa/KGxMRPdOZSiBHio/cORsvAfnOz4bELX4DqYBj9fQ386l1RmWloucp9qxn' +
            '37T0KVaTx8N7XnyYY4rQf3MA7PDJSLboylGy5vMn7tbP/g8vMdy5WYZJKOlgDVBm8UzgYcrm0FUhl4DW0Pgs3DFpWzPYgMwPlDojCIVSc3sEmChCLugNnYkN+' +
            'j4kLYsBVu07SnefLwtSqPL55QP1xbhtF/rNyqCDqa3UeHXzmkQwFWZx8zt40QmUWrJBetH8hFjUGUKM11ImPrzrqPAovDmmhNi0H3PtFrFx9SfoIOOButak2Iqglizna+' +
            'EzrOAE5LQ+Yvx//Vx5xeFm5i2RG1qRUZ/QISG6AY1gAi7fIXgMJnVnOMLh2RT/Jr9gN3wJgg/jRHozUv7s9DqQTmjdn0aVeQAG6NSiKOtn36rx23B1z1qlx42Ut9GZ3li' +
            'TzUkX9YFhWHLiZWJd7byaiQjaijevpnbt35i1gYUPrJrTZqj7GjLNG3oxSyM+/2ZeGg5NdeXTNSPIaaeIqEF7uYN+goorUy/VfceI3Q5PybBkNafiNgDcGOH0E3JV5VnHDjO5Pcuk5Mhy1vMIiQ' +
            '&CreateDateFrom=' + createDateFrom + '&createDateTo=' + createDateTo + '&orderRole=Seller&orderStatus=Completed';

        if client.Get(URL, responseMessage) then begin

            if responseMessage.HttpStatusCode = 200 then begin

                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                jArray := GetJsonToken(jObject, 'orderList').AsArray();
                noOfResult := jArray.Count();

                for i := 0 to noOfResult - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();
                    jArray.Get(i, orderToken);
                    orderHeaderObject := orderToken.AsObject();

                    //Getting WebHeader Object Data
                    WebHeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                    ChannelOrderId := GetJsonvalue(WebHeaderObject, 'ChannelOrderID').AsText();

                    InsertInInterimSalesHeader(WebHeaderObject, ChannelOrderId, ChannelCode, InterimSalesHeader);
                    InsertInterimSalesLine(InterimSalesHeader, orderHeaderObject, InterimSalesLine);

                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                end;
                MESSAGE('Ebay Order Sync Completed...');
            end;

        end
        else begin
            Message('Error Code : %1', responseMessage.HttpStatusCode);
        end;
    end;


    //Procedure to Insert Order Header Data in Interim Sales Header Table
    local procedure InsertInInterimSalesHeader(Orderheaders: JsonObject; var ChannelOrderId: Text; ChannelCode: Code[10]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        orderDate: Text;
        documentDate: Text;
        earliestDeliverydate: Text;
        earliestShipDate: Text;
        TradePartner: Record "Trade Partner";
    begin
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."No." := CopyStr(ChannelOrderId, 1, 20);
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;

        if TradePartner.Get(ChannelCode) then begin
            InterimSalesHeader."Sell-to Customer No." := TradePartner."Customer No.";
        end;

        If GetJsonvalue(Orderheaders, 'Address2').IsNull = false then begin
            InterimSalesHeader."Address 2" := CopyStr(GetJsonToken(Orderheaders, 'Address2').AsValue().AsText(), 1, 50);
        end;

        If GetJsonvalue(Orderheaders, 'PostCode').IsNull = false then begin
            InterimSalesHeader."Post Code" := CopyStr(GetJsonToken(Orderheaders, 'PostCode').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(Orderheaders, 'OrderDate').IsNull = false then begin
            orderDate := GetJsonvalue(Orderheaders, 'OrderDate').AsText();
            InterimSalesHeader."Order Date" := GenerateDate(orderDate);
        end;

        if GetJsonvalue(Orderheaders, 'DocumentDate').IsNull = false then begin
            documentDate := GetJsonvalue(Orderheaders, 'DocumentDate').AsText();
            InterimSalesHeader."Document Date" := GenerateDate(documentDate);
        end;

        if GetJsonvalue(Orderheaders, 'EarliestDeliverydate').IsNull = false then begin
            earliestDeliverydate := GetJsonvalue(Orderheaders, 'EarliestDeliverydate').AsText();
            InterimSalesHeader."Earliest Delivery date" := GenerateDate(earliestDeliverydate);
        end;

        if GetJsonvalue(Orderheaders, 'EarliestShipDate').IsNull = false then begin
            earliestShipDate := GetJsonvalue(Orderheaders, 'EarliestShipDate').AsText();
            InterimSalesHeader."Earliest Ship Date" := GenerateDate(earliestShipDate);
        end;

        if GetJsonvalue(Orderheaders, 'City').IsNull = false then begin
            InterimSalesHeader."City" := CopyStr(GetJsonToken(Orderheaders, 'City').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(Orderheaders, 'BuyerEmail').IsNull = false then begin
            InterimSalesHeader."Buyer Email" := CopyStr(GetJsonToken(Orderheaders, 'BuyerEmail').AsValue.AsText(), 1, 50);
        end;

        if GetJsonvalue(Orderheaders, 'BuyerName').IsNull = false then begin
            InterimSalesHeader."Buyer Name" := CopyStr(GetJsonToken(Orderheaders, 'BuyerName').AsValue.AsText(), 1, 100);
        end;

        if GetJsonvalue(Orderheaders, 'ShiptoName').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := CopyStr(GetJsonToken(Orderheaders, 'ShiptoName').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(Orderheaders, 'ShiptoAddress2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := CopyStr(GetJsonToken(Orderheaders, 'ShiptoAddress2').AsValue().AsText(), 1, 50);
        end;

        if GetJsonvalue(Orderheaders, 'ShiptoCity').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := Copystr(GetJsonToken(Orderheaders, 'ShiptoCity').AsValue().AsText(), 1, 30);
        end;

        if GetJsonvalue(Orderheaders, 'PhoneNumber').IsNull = false then begin
            InterimSalesHeader."Ship-to Phone" := CopyStr(GetJsonToken(Orderheaders, 'PhoneNumber').AsValue().AsText(), 1, 20);
        end;

        if GetJsonvalue(Orderheaders, 'OrderAmount').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonToken(Orderheaders, 'OrderAmount').AsValue().AsDecimal();
        end;

        if GetJsonvalue(Orderheaders, 'PaymentMethod').IsNull = false then begin
            InterimSalesHeader."Payment Method" := CopyStr(GetJsonvalue(Orderheaders, 'PaymentMethod').AsCode(), 1, 20);
        end;

        if GetJsonvalue(Orderheaders, 'WebShipmentMethod').IsNull = false then begin
            InterimSalesHeader."Web Shipment Method" := CopyStr(GetJsonToken(Orderheaders, 'WebShipmentMethod').AsValue().AsCode(), 1, 50);
        end;

        if GetJsonvalue(Orderheaders, 'Status').IsNull = false then begin
            InterimSalesHeader.status := InterimSalesHeader.status::"In Progress";
        end;

        InterimSalesHeader.Insert();

    end;


    //Procedure to Insert Line Item Data in Interim Sales Line Table
    local procedure InsertInterimSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; orderHeaderObject: JsonObject; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        ItemArray: JsonArray;
        itemCount: Integer;
        LineObject: JsonObject;
        j: Integer;
        WebLineToken: JsonToken;
    begin

        ItemArray := GetJsonToken(orderHeaderObject, 'webLines').AsArray();
        itemCount := ItemArray.Count;
        if itemCount > 0 then begin

            for j := 0 to itemCount - 1 do begin

                ItemArray.Get(j, WebLineToken);
                LineObject := WebLineToken.AsObject;

                InterimSalesLine.Init;
                InterimSalesLine."Line No." := j;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";

                if GetJsonvalue(LineObject, 'Description').IsNull = false then begin
                    InterimSalesLine.Description := Copystr(GetJsonToken(LineObject, 'Description').AsValue().AsText(), 1, 100);
                end;

                if GetJsonvalue(LineObject, 'UnitPrice').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonToken(LineObject, 'UnitPrice').AsValue().AsDecimal();
                End;

                if GetJsonvalue(LineObject, 'Quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonToken(LineObject, 'Quantity').AsValue().AsDecimal();
                end;

                if GetJsonvalue(LineObject, 'ChannelItemId').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonToken(LineObject, 'ChannelItemId').AsValue().AsCode();
                end;

                if GetJsonvalue(LineObject, 'ChannelSKU').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := CopyStr(GetJsonToken(LineObject, 'ChannelSKU').AsValue().AsText(), 1, 50);
                end;

                if GetJsonvalue(LineObject, 'ShippingPrice').IsNull = false then begin
                    InterimSalesLine."Shipping Price" := GetJsonToken(LineObject, 'ShippingPrice').AsValue().AsDecimal();
                end;

                InterimSalesLine.Insert();

            end;

        end;

    end;


    //Procedure to Retrieve Products from Ebay with Start and End Date Filter
    procedure GetEbayProducts(ChannelCode: Code[10])
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        endDateTime: Text;
        jObject: JsonObject;
        jArray: JsonArray;
        i: Integer;
        noOfResult: Integer;
        productToken: JsonToken;
        ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);
        endDateTime := Format(CurrentDateTime, 0, '20<Year><Month,2><Day,2><Hours12,2><Minutes,2><Seconds,2>');

        URL := 'http://webintegrationapi.azurewebsites.net/api/EbayAPI/GetProductsByFilter?' +
            'applicationId=' + applicationId + '&certificateId=' + certificateId + '&developerId=' + developerId + '&Service_URL=' + Service_URL +
            '&version=1057&ebayToken=AgAAAA**AQAAAA**aAAAAA**igiRYA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFk4OoAZGLqAmdj6x9nY+seQ**' +
            '+mYGAA**AAMAAA**gxRTEqkLBBoqGuU9MjjdwaKbqtQvD1hFWQaj8cVFmAPkX7NFGwJH1UX/Q5MjQHBjewb5VGpwvRVRn1zsKHVZjaIBa+uYWvRVRm7tGNMZcc8tZIojR+' +
            '8JxbOEnGKUPcdrKpVoXcxdlYSbQ/VTaVoHdMpTqcYUc++kjyQrDVl0fgle7nwLXWUnUsUa/KGxMRPdOZSiBHio/cORsvAfnOz4bELX4DqYBj9fQ386l1RmWloucp9qxn' +
            '37T0KVaTx8N7XnyYY4rQf3MA7PDJSLboylGy5vMn7tbP/g8vMdy5WYZJKOlgDVBm8UzgYcrm0FUhl4DW0Pgs3DFpWzPYgMwPlDojCIVSc3sEmChCLugNnYkN+' +
            'j4kLYsBVu07SnefLwtSqPL55QP1xbhtF/rNyqCDqa3UeHXzmkQwFWZx8zt40QmUWrJBetH8hFjUGUKM11ImPrzrqPAovDmmhNi0H3PtFrFx9SfoIOOButak2Iqglizna+' +
            'EzrOAE5LQ+Yvx//Vx5xeFm5i2RG1qRUZ/QISG6AY1gAi7fIXgMJnVnOMLh2RT/Jr9gN3wJgg/jRHozUv7s9DqQTmjdn0aVeQAG6NSiKOtn36rx23B1z1qlx42Ut9GZ3li' +
            'TzUkX9YFhWHLiZWJd7byaiQjaijevpnbt35i1gYUPrJrTZqj7GjLNG3oxSyM+/2ZeGg5NdeXTNSPIaaeIqEF7uYN+goorUy/VfceI3Q5PybBkNafiNgDcGOH0E3JV5VnHDjO5Pcuk5Mhy1vMIiQ' +
            '&startDateTime=' + startDateTime + '&endDateTime=' + endDateTime + '&isStartFilter=true';

        // URL := 'http://webintegrationapi.azurewebsites.net/api/EbayAPI/GetAllProducts?' +
        //             'applicationId=' + applicationId + '&certificateId=' + certificateId + '&developerId=' + developerId + '&Service_URL=' + Service_URL +
        //             '&version=1057&ebayToken=AgAAAA**AQAAAA**aAAAAA**igiRYA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6AFk4OoAZGLqAmdj6x9nY+seQ**' +
        //             '+mYGAA**AAMAAA**gxRTEqkLBBoqGuU9MjjdwaKbqtQvD1hFWQaj8cVFmAPkX7NFGwJH1UX/Q5MjQHBjewb5VGpwvRVRn1zsKHVZjaIBa+uYWvRVRm7tGNMZcc8tZIojR+' +
        //             '8JxbOEnGKUPcdrKpVoXcxdlYSbQ/VTaVoHdMpTqcYUc++kjyQrDVl0fgle7nwLXWUnUsUa/KGxMRPdOZSiBHio/cORsvAfnOz4bELX4DqYBj9fQ386l1RmWloucp9qxn' +
        //             '37T0KVaTx8N7XnyYY4rQf3MA7PDJSLboylGy5vMn7tbP/g8vMdy5WYZJKOlgDVBm8UzgYcrm0FUhl4DW0Pgs3DFpWzPYgMwPlDojCIVSc3sEmChCLugNnYkN+' +
        //             'j4kLYsBVu07SnefLwtSqPL55QP1xbhtF/rNyqCDqa3UeHXzmkQwFWZx8zt40QmUWrJBetH8hFjUGUKM11ImPrzrqPAovDmmhNi0H3PtFrFx9SfoIOOButak2Iqglizna+' +
        //             'EzrOAE5LQ+Yvx//Vx5xeFm5i2RG1qRUZ/QISG6AY1gAi7fIXgMJnVnOMLh2RT/Jr9gN3wJgg/jRHozUv7s9DqQTmjdn0aVeQAG6NSiKOtn36rx23B1z1qlx42Ut9GZ3li' +
        //             'TzUkX9YFhWHLiZWJd7byaiQjaijevpnbt35i1gYUPrJrTZqj7GjLNG3oxSyM+/2ZeGg5NdeXTNSPIaaeIqEF7uYN+goorUy/VfceI3Q5PybBkNafiNgDcGOH0E3JV5VnHDjO5Pcuk5Mhy1vMIiQ';

        if client.Get(URL, responseMessage) then begin

            if responseMessage.HttpStatusCode = 200 then begin

                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                jArray := GetJsonToken(jObject, 'productList').AsArray();
                noOfResult := jArray.Count();

                for i := 0 to noOfResult - 1 do begin
                    jArray.Get(i, productToken);
                    productObject := productToken.AsObject();

                    ChannelItemListing.RESET;
                    ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                    ChannelItemListing.SETRANGE("Channel SKU", GetJsonvalue(productObject, 'ChannelSKU').AsText());

                    IF ChannelItemListing.FINDFIRST THEN BEGIN
                        UpdateProductEbay(FALSE, ChannelCode);
                    END
                    ELSE BEGIN
                        UpdateProductEbay(TRUE, ChannelCode);
                    END;
                end;

            end;
            Message('Item Sync Completed');
        end
        else begin
            Message('Error Code : %1', responseMessage.HttpStatusCode);
        end;

    end;


    //Procedure to Modify or Insert Ebay Products in Channel Item Listing Table
    local procedure UpdateProductEbay(bool: Boolean; ChannelCode: Code[10])
    var
        ChannelItemListing: Record "Channel Item Listing";
        ITEM: Record Item;
        status: Text;
    begin

        CLEAR(ChannelItemListing);
        ChannelItemListing."Channel Code" := ChannelCode;

        if GetJsonvalue(productObject, 'ChannelSKU').IsNull = false then begin
            ChannelItemListing.Validate("Channel SKU", CopyStr(GetJsonvalue(productObject, 'ChannelSKU').AsText(), 1, 50));
        end;

        if GetJsonvalue(productObject, 'ChannelTitle').IsNull = false then begin
            ChannelItemListing.Validate("Channel Title", CopyStr(GetJsonvalue(productObject, 'ChannelTitle').AsText(), 1, 50));
        end;

        if GetJsonvalue(productObject, 'ChannelUnitPrice').IsNull = false then begin
            ChannelItemListing.Validate("Unit Price", GetJsonvalue(productObject, 'ChannelUnitPrice').AsDecimal());
        end;

        if GetJsonvalue(productObject, 'ChannelInventory').IsNull = false then begin
            ChannelItemListing.Validate("Channel Inventory", GetJsonvalue(productObject, 'ChannelInventory').AsInteger());
        end;

        if GetJsonvalue(productObject, 'Status').IsNull = false then begin
            status := GetJsonvalue(productObject, 'Status').AsText();

            IF (status = 'Active') THEN
                ChannelItemListing.VALIDATE(Status, ChannelItemListing.Status::Active);

            IF (status = 'Inactive') THEN
                ChannelItemListing.VALIDATE(Status, ChannelItemListing.Status::Inactive);
        end;

        if GetJsonvalue(productObject, 'ASINNo').IsNull = false then begin
            ChannelItemListing.Validate("ASIN No", CopyStr(GetJsonvalue(productObject, 'ASINNo').AsCode(), 1, 50));
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


    //Procedure to Update Inventory and Price for Ebay
    procedure UpdateEbayInventoryPrice(ChannelCode: Code[10])
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        quantity: Text;
        price: Text;
        itemId: Text;
        ChannelItemListing: Record "Channel Item Listing";
    begin
        GetCredentials(ChannelCode);
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETFILTER("Inventory Synced", '%1', FALSE);
        ChannelItemListing.SetFilter("Price Synced", '%1', false);

        IF ChannelItemListing.FINDSET THEN BEGIN

            REPEAT
                itemId := ChannelItemListing."ASIN No";
                price := format(ChannelItemListing."Channel Unit Price");
                quantity := format(ChannelItemListing."Channel Inventory");

                URL := 'http://webintegrationapi.azurewebsites.net/api/EbayAPI/UpdateInventoryPrice?ApplicationId=' +
                applicationId + '&certificateId=' + certificateId + '&developerId=' + developerId +
                '&Service_URL=' + Service_URL + '&version=1057&ebayToken=AgAAAA**AQAAAA**aAAAAA**' +
                'rQP3Xw**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6MFloSpDJKLowudj6x9nY+seQ**+mYGAA**AAMAAA**' +
                'UDWB7OcoMhtyl4xBWq0KB6uQlInXpsA3/tiddX+oQFcWTgMZlGcqiowu6ujFO+Xgz5b7OceAk9XITEU' +
                'anzhqvTFNsFiZytlfh5XmJWdJCZmdZzIL5AB0DhRUZxldQMyVemQp7sIy5VgcZeYC5k4cr5iEPsNKt1u' +
                'Ukc5s+I4FXQkSj9BaAn+slVhF19DCoSbzR0+To+ykxE9CvB+AzSy24fHRK/Fb7HGVmhUX6Z2sBNMfh6z' +
                '4DMBmIQQWDhK0rBL8Aq3x53OOPC1VIEda2gpkxj+NNLlXhNbTyX/7UTE/hgi8rUHYgjF5BQmbnfjMS1tgg' +
                'B5w6n4BgK5d+XQNv6u5UGtRbDSLiDgmZ+akgatcMEewNaiN3T7kuSz8czk4akrHVNaZ/VqeE8SPnLI8KC2' +
                'kD0zT+vaNHyskfuPHNOtIRDilFv+Srk3pdRraie0yP5n9dlmVQfIHMJuC7YFVeGsICVU4YBTHRkXGAM9h2Xk' +
                'ImaxuOXvTBGtatpcEOivJpc/INYIEDsYSap/Dt/JofAeljnQQGKSOBqMs3xXP8IoO1lW8eeYmBC79hS+' +
                'ImYN04tnySVre5xcESH2NBJI2rJ91volB+7H9hRPj8ZX4KSxhlE38Fn5mMWf65YESHOwZwP4iGhP+' +
                'u/xI7HdH8x6pwcUTWqw/T0QvuMDOW6nQDneIap/ul7cTSsCReKfFibfhE+An60mvAErbnqWUj2S2h1WZ' +
                'mwsogPzVcakLLYkaIxqkoEcED0FZ+VE0wm81RnhO/jDV&quantity=' + quantity + '&price=' +
                price + '&itemId=' + itemId;

                if client.Get(URL, responseMessage) then begin

                    ChannelItemListing."Inventory Synced" := TRUE;
                    ChannelItemListing."Price Synced" := true;
                    ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                    ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    ChannelItemListing.Remarks := 'Inventory updated successfully';
                    ChannelItemListing.MODIFY;

                END
                ELSE BEGIN
                    //Need to test with Real time testing and then put Message Accordingly
                    ChannelItemListing.Remarks := '';
                    ChannelItemListing.MODIFY;
                END;

            UNTIL ChannelItemListing.NEXT = 0;

        END;

    end;


    //Procedure for Ebay Order Fulfillment.
    procedure EbayOrderFulfillment(ChannelCode: Code[10])
    var
        client: HttpClient;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        URL: Text;
        response: Text;
        orderId: Text;
        shippedDate: Text;
        trackingNumber: Text;
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin
        GetCredentials(ChannelCode);
        HandledInterimSalesHeader.RESET;
        HandledInterimSalesHeader.SETRANGE("Trade Partner Code", ChannelCode);
        HandledInterimSalesHeader.SETFILTER("FullFillment Status", '<>%1', HandledInterimSalesHeader."FullFillment Status"::Fullfilled);
        HandledInterimSalesHeader.SETRANGE(Status, HandledInterimSalesHeader.Status::Dispatched);
        HandledInterimSalesHeader.SETFILTER("Package Tracking No.", '<>%1', '');
        HandledInterimSalesHeader.SETFILTER("Scanned Date", '>%1', CREATEDATETIME(20210212D, TIME));

        If HandledInterimSalesHeader.FindSet() then begin

            repeat
                orderId := HandledInterimSalesHeader."Channel Order ID";
                //Not Sure if the Shipped Date getting code is Correct.
                //shippedDate := format(HandledInterimSalesHeader."Shipment Date");
                shippedDate := FORMAT(CREATEDATETIME(WORKDATE, 170000T), 12, '<Year,2><Month,2><day,2><Hours24,2><Minutes,2><Seconds,2>');
                trackingNumber := HandledInterimSalesHeader."Package Tracking No.";

                URL := 'http://webintegrationapi.azurewebsites.net/api/EbayAPI/FullFillEbayOrder?' +
                        'developerId=' + developerId + '&applicationId=' + applicationId +
                        '&certificateId=' + certificateId + '&ebayToken=AgAAAA**AQAAAA**aAAAAA**rQP3Xw**nY+' +
                        'sHZ2PrBmdj6wVnY+sEZ2PrA2dj6MFloSpDJKLowudj6x9nY+seQ**+mYGAA**AAMAAA**UDWB7OcoMhtyl4' +
                        'xBWq0KB6uQlInXpsA3/tiddX+oQFcWTgMZlGcqiowu6ujFO+Xgz5b7OceAk9XITEUanzhqvTFNsFiZytlfh5' +
                        'XmJWdJCZmdZzIL5AB0DhRUZxldQMyVemQp7sIy5VgcZeYC5k4cr5iEPsNKt1uUkc5s+I4FXQkSj9BaAn+' +
                        'slVhF19DCoSbzR0+To+ykxE9CvB+AzSy24fHRK/Fb7HGVmhUX6Z2sBNMfh6z4DMBmIQQWDhK0rBL8Aq3x53OOPC1VIE' +
                        'da2gpkxj+NNLlXhNbTyX/7UTE/hgi8rUHYgjF5BQmbnfjMS1tggB5w6n4BgK5d+XQNv6u5UGtRbDSLiDgmZ+' +
                        'akgatcMEewNaiN3T7kuSz8czk4akrHVNaZ/VqeE8SPnLI8KC2kD0zT+vaNHyskfuPHNOtIRDilFv+Srk3pdRraie0' +
                        'yP5n9dlmVQfIHMJuC7YFVeGsICVU4YBTHRkXGAM9h2XkImaxuOXvTBGtatpcEOivJpc/INYIEDsYSap/Dt/' +
                        'JofAeljnQQGKSOBqMs3xXP8IoO1lW8eeYmBC79hS+ImYN04tnySVre5xcESH2NBJI2rJ91volB+7H9hRPj8ZX4KS' +
                        'xhlE38Fn5mMWf65YESHOwZwP4iGhP+u/xI7HdH8x6pwcUTWqw/T0QvuMDOW6nQDneIap/ul7cTSsCReKfFibfhE+' +
                        'An60mvAErbnqWUj2S2h1WZmwsogPzVcakLLYkaIxqkoEcED0FZ+VE0wm81RnhO/jDV&version=1057' +
                        '&Service_Url=' + Service_URL + '&orderId=' + orderId +
                        '&shippedDate=' + shippedDate + '&trackingNumber=' + trackingNumber;

                if client.Post(URL, content, responseMessage) then begin
                    //Not Sure if this is the correct code.
                    HandledInterimSalesHeader."FullFillment Status" := HandledInterimSalesHeader."FullFillment Status"::Fullfilled;
                end;

            until HandledInterimSalesHeader.Next = 0;

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
        if not aJsonObject.Get(TokenKey, aJsonToken) then begin
            //Error('Could not find a token with key %1', TokenKey)
        end
        Else begin
            aJsonValue := aJsonToken.AsValue();
        end;
    end;


    local procedure GenerateNewDate(Orderdate: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Convertdate: Date;
        Lenght: Integer;
        ISh: Record "Interim Sales Header";
    begin
        if Orderdate <> '' then begin
            Orderdate := Orderdate.Substring(1, 10);
            Lenght := StrLen(Orderdate.Trim());
            if Lenght > 0 then begin
                if StrPos(Orderdate, '/') > 0 then begin
                    Evaluate(Year, Orderdate.Split('/').Get(1));
                    Evaluate(Month, Orderdate.Split('/').Get(2));
                    Evaluate(Day, Orderdate.Split('/').Get(3));
                    Convertdate := DMY2Date(Day, Month, Year);
                end;
                if StrPos(Orderdate, '-') > 0 then begin
                    Evaluate(Year, Orderdate.Split('-').Get(1));
                    Evaluate(Month, Orderdate.Split('-').Get(2));
                    Evaluate(Day, Orderdate.Split('-').Get(3));
                    Convertdate := DMY2Date(Day, Month, Year);
                end;
            end;
        end;
        exit(Convertdate);
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
}