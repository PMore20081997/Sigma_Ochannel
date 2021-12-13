codeunit 90010 "Amazon SP API"
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
                    GetOrders(StartParameter);
                    //ImportOrders(StartParameter);
                    TradePartner.Reset();
                    TradePartner.SetRange(Code, StartParameter);
                    if TradePartner.FindFirst() then begin
                        TradePartner."Last Order Sync" := CreateDateTime(WorkDate, Time);
                        TradePartner.Modify;
                    end;
                End;
            SyncItemLabel:
                Begin
                    //GetItems(StartParameter);
                    GenerateItems('');
                End;
        end;
    end;

    var
        ServiceURL: Text;
        ClientId: Text;
        ClientSecret: Text;
        AccessKey: Text;
        SecretKey: Text;
        AmazonOrderStatus: Text;
        MarketPlaceId: Text;
        CreatedAfter: Text;
        CreatedDateAfter: Date;
        CreatedBefore: Text;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        StartParameter: Text;
        RunType: Text;
        TradePartner: Record "Trade Partner";
        SyncOrderLabel: Label 'SyncOrder';
        SyncItemLabel: Label 'SyncItem';
        Rec_ExcelBuffer: Record "Excel Buffer";
        RowNo: Integer;


    local procedure GetCredentials(ChannelCode: Code[10])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            AccessKey := TradePartner.AccessKeyId;
            SecretKey := TradePartner.SecretAccessKey;
            ClientId := TradePartner.MerchantId;
            //ClientSecret := TradePartner."FTP Archive File Path";
            ClientSecret := TradePartner."API Endpoint";
            AmazonOrderStatus := TradePartner."API Attribute";
            ServiceURL := TradePartner."Sevice/API URL";
            MarketPlaceId := TradePartner.MarketplaceId;
            //CreatedAfter := Format(TradePartner."Last Order Sync", 0, '20<Year>-<Month,2>-<Day,2>');
            CreatedDateAfter := DT2Date(TradePartner."Last Order Sync");
            CreatedDateAfter := CalcDate('-1D', CreatedDateAfter);
            CreatedAfter := Format(CreatedDateAfter, 0, '20<Year>-<Month,2>-<Day,2>');
            //CreatedBefore := Format(TradePartner."Last Customer Sync", 0, '20<Year>-<Month,2>-<Day,2>');
            //CreatedBefore := Format(CurrentDateTime, 0, '20<Year>-<Month,2>-<Day,2>');
        end;
    end;


    local procedure ImportOrders(ChannelCode: Code[10])
    var
        LineNo: Integer;
        Rows: Integer;
        Columns: Integer;
        DialogCaption: Text;
        UploadResult: Boolean;
        FileName: Text[100];
        InStr: InStream;
        SheetName: Text[100];
        CustomerNo: Code[20];
        Str: Text[100];
        POS: Integer;
        GetString: Text[100];
        ExistOrNot: Boolean;
        ItemNo: Code[20];
        InterimSalesHeader1: Record "Interim Sales Header";
        InterimSalesHeader: Record "Interim Sales Header";
        InterimSalesLine: Record "Interim Sales Line";
        LastIntSaleLine: Record "Interim Sales Line";
        Customer: Record Customer;
        ShippingAdd: Record "Ship-to Address";
        item: Record Item;
        ItemCrossReference: Record "Item Reference";
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        Clear(LineNo);
        Rec_ExcelBuffer.DeleteAll();
        Rows := 0;
        Columns := 0;
        DialogCaption := 'Select File to Upload';

        UploadResult := UploadIntoStream(DialogCaption, '', '', FileName, InStr);

        if FileName <> '' then
            SheetName := Rec_ExcelBuffer.SelectSheetsNameStream(InStr)
        else
            exit;

        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.OpenBookStream(InStr, SheetName);
        Rec_ExcelBuffer.ReadSheet();
        Commit();

        //Finiding Total No of Rows to Import
        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.SetRange("Column No.", 1);

        If Rec_ExcelBuffer.FindFirst() then
            repeat
                Rows := Rows + 1;
            until Rec_ExcelBuffer.Next() = 0;

        //Finding total number of columns to import
        Rec_ExcelBuffer.Reset();
        Rec_ExcelBuffer.SetRange("Row No.", 1);

        if Rec_ExcelBuffer.FindFirst() then
            repeat
                Columns := Columns + 1;
            until Rec_ExcelBuffer.Next() = 0;

        InterimSalesHeader1.Reset();
        InterimSalesHeader.Reset();
        InterimSalesHeader1.SetRange("File Name", FileName);
        if not InterimSalesHeader1.FindSet() then begin
            for RowNo := 2 to Rows do begin
                //Checking if Order already Exist
                //ExistOrNot := CheckOrderExist(GetValueAtIndex(RowNo, 1));
                InterimSalesHeader.Reset();
                Clear(InterimSalesHeader);
                InterimSalesHeader.SetRange("Channel Order ID", GetValueAtIndex(RowNo, 1));
                if not InterimSalesHeader.FindSet() then begin
                    GeneralSetup.Get;
                    GeneralSetup.TestField("Web Order Nos");
                    InterimSalesHeader.Init();
                    InterimSalesHeader."No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
                    InterimSalesHeader.Validate("Channel Order ID", GetValueAtIndex(RowNo, 1));
                    InterimSalesHeader.Validate("External Document No.", GetValueAtIndex(RowNo, 1));
                    Clear(CustomerNo);
                    if GetValueAtIndex(RowNo, 2) = 'MFBKL' then begin
                        InterimSalesHeader."Sell-to Customer No." := 'MF7GE';
                        CustomerNo := 'MF7GE';
                    end else begin
                        InterimSalesHeader.Validate("Sell-to Customer No.", GetValueAtIndex(RowNo, 2));
                        Evaluate(CustomerNo, GetValueAtIndex(RowNo, 2));
                    end;

                    Customer.Reset();
                    Customer.SetRange("No.", CustomerNo);
                    if Customer.FindFirst() then begin
                        InterimSalesHeader.Address := Customer.Address;
                        InterimSalesHeader."Address 2" := Customer."Address 2";
                        InterimSalesHeader.City := Customer.City;
                        InterimSalesHeader."Post Code" := Customer."Post Code";
                        InterimSalesHeader."Sell to Country" := Customer."Country/Region Code";
                        if Customer."Payment Terms Code" <> '' then
                            Evaluate(InterimSalesHeader."Payment Method", Customer."Payment Terms Code");
                    end;

                    ShippingAdd.Reset();
                    ShippingAdd.SetRange("Customer No.", CustomerNo);
                    ShippingAdd.SetRange(Code, GetString);
                    if ShippingAdd.FindFirst() then begin
                        InterimSalesHeader."Ship-to Name" := ShippingAdd.Name;
                        InterimSalesHeader."Ship-to Address" := ShippingAdd.Address;
                        InterimSalesHeader."Ship-to Address 2" := ShippingAdd."Address 2";
                        InterimSalesHeader."Ship-to City" := ShippingAdd.City;
                        InterimSalesHeader."Ship-to Post Code" := ShippingAdd."Post Code";
                        InterimSalesHeader."Ship-to County" := ShippingAdd.County;
                        InterimSalesHeader."Ship-to Country/Region Code" := ShippingAdd."Country/Region Code";
                    end;

                    if GetValueAtIndex(RowNo, 17) = 'GBP' then
                        InterimSalesHeader."Currency Code" := ''
                    else
                        InterimSalesHeader.Validate("Currency Code", GetValueAtIndex(RowNo, 17));

                    InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
                    InterimSalesHeader."Trade Partner Code" := ChannelCode;
                    InterimSalesHeader.Status := InterimSalesHeader.Status::"In Progress";
                    InterimSalesHeader."File Name" := FileName;
                    InterimSalesHeader.VALIDATE("Pickup Date", TODAY + 1);
                    InterimSalesHeader.VALIDATE("Pickup Time", 170000T);
                    InterimSalesHeader.VALIDATE("No. Of Parcels", 1);
                    InterimSalesHeader."Order Created On" := CurrentDateTime;
                    InterimSalesHeader."User ID" := UserId;
                    InterimSalesHeader.Validate("Order Date", WorkDate);
                    InterimSalesHeader.Insert();
                    Clear(InterimSalesLine);
                end;

                LastIntSaleLine.Reset();
                LastIntSaleLine.SetRange("Document No", GetValueAtIndex(RowNo, 1));
                if LastIntSaleLine.FindLast() then begin
                    InterimSalesLine.Init();
                    InterimSalesLine.Validate("Document No", InterimSalesHeader."No.");
                    InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                    InterimSalesLine."Line No." := LastIntSaleLine."Line No." + 1000;
                    InterimSalesLine.Type := InterimSalesLine.Type::Item;
                    Evaluate(InterimSalesLine."Channel SKU", GetValueAtIndex(RowNo, 4));

                    Clear(ItemNo);
                    ItemCrossReference.Reset();
                    ItemCrossReference.SetRange("Item No.", GetValueAtIndex(RowNo, 4));
                    ItemCrossReference.SetRange("Reference Type", ItemCrossReference."Reference Type"::"Bar Code");
                    if ItemCrossReference.FindFirst() then begin
                        InterimSalesLine.Validate("No.", ItemCrossReference."Item No.");
                        ItemNo := ItemCrossReference."Item No.";
                    end;

                    item.Reset();
                    item.SetRange("No.", ItemNo);
                    if item.FindFirst() then
                        InterimSalesLine."Unit of Measure Code" := item."Base Unit of Measure";

                    InterimSalesLine.Validate(Description, GetValueAtIndex(RowNo, 8));
                    Evaluate(InterimSalesLine.Quantity, GetValueAtIndex(RowNo, 14));
                    Evaluate(InterimSalesLine."Sell-to Customer No.", InterimSalesHeader."Sell-to Customer No.");
                    Evaluate(InterimSalesLine."Unit Price", GetValueAtIndex(RowNo, 16));
                    Evaluate(InterimSalesLine."Currency Code", InterimSalesHeader."Currency Code");
                    InterimSalesLine.Insert();
                end else begin
                    LineNo := 1000;
                    InterimSalesLine.Init();
                    InterimSalesLine.Validate("Document No", GetValueAtIndex(RowNo, 1));
                    InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                    InterimSalesLine."Line No." := LineNo;
                    InterimSalesLine.Type := InterimSalesLine.Type::Item;
                    Evaluate(InterimSalesLine."Channel SKU", GetValueAtIndex(RowNo, 4));

                    Clear(ItemNo);
                    ItemCrossReference.Reset();
                    ItemCrossReference.SetRange("Item No.", GetValueAtIndex(RowNo, 4));
                    ItemCrossReference.SetRange("Reference Type", ItemCrossReference."Reference Type"::"Bar Code");
                    if ItemCrossReference.FindFirst() then begin
                        InterimSalesLine.Validate("No.", ItemCrossReference."Item No.");
                        ItemNo := ItemCrossReference."Item No.";
                    end;

                    item.Reset();
                    item.SetRange("No.", ItemNo);
                    if item.FindFirst() then
                        InterimSalesLine."Unit of Measure Code" := item."Base Unit of Measure";

                    InterimSalesLine.Validate(Description, GetValueAtIndex(RowNo, 8));
                    Evaluate(InterimSalesLine.Quantity, GetValueAtIndex(RowNo, 14));
                    Evaluate(InterimSalesLine."Unit Price", GetValueAtIndex(RowNo, 16));
                    Evaluate(InterimSalesLine."Sell-to Customer No.", InterimSalesHeader."Sell-to Customer No.");
                    Evaluate(InterimSalesLine."Currency Code", InterimSalesHeader."Currency Code");
                    InterimSalesLine.Insert();
                end;
            end;
        end else begin
            Error('Process not completed because Sheet Name : %1 already exist', InterimSalesHeader1."File Name");
        end;
    end;


    local procedure GetValueAtIndex(RowNo: Integer; ColNo: Integer): Text
    var
        Rec_ExcelBuffer: Record "Excel Buffer";
    begin
        Rec_ExcelBuffer.Reset();
        If Rec_ExcelBuffer.Get(RowNo, ColNo) then
            exit(Rec_ExcelBuffer."Cell Value as Text");
    end;


    local procedure CheckOrderExist(OrderNo: Text): Boolean
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        ExistBoolean: Boolean;
    begin
        ExistBoolean := true;
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("No.", OrderNo);
        if L_InterimSalesHeader.FindFirst() then begin
            exit(ExistBoolean);
        end
        else begin
            ExistBoolean := false;
            exit(ExistBoolean);
        end;
    end;


    procedure GetAccessToken(ChannelCode: Code[10]): Text
    var
        headers: HttpHeaders;
        client: HttpClient;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        response: Text;
        Url: Text;
        body: Text;
        AccessToken: Text;
        jObject: JsonObject;
        tradePartner: Record "Trade Partner";
    begin
        GetCredentials(ChannelCode);
        headers := client.DefaultRequestHeaders();

        content.WriteFrom('grant_type=refresh_token&refresh_token=Atzr|IwEBIGQ70QC8ttOazedd4_byudqtjevDVZYfcOjDcEDoUdBD7CdxiFxKffLHDOzNSuw9AS6i1OuDgeyJFwpTAN5QP3pV_gj_GOi4_2YKId1DZ_FabDNpGnU05hKNbuTpQ547OEpBYtDKmZp7e9CS_njYQdrIsC6DwDp1xRNfgBqEcKdKidjxmmGbKplNx8rL4RREuhWQGbI_ORwCUEZXr7AcROPk-48skj2Z3rwgq7x3pSfRrGACJTvvpzP7YjV3zRBZYAqU3bWkGLDwO06tKq_o9sV0FbfjgQ5mvoViewYy_9Q7d9qWbhi3DDdlhg5Z8xhTq7M&client_id=' + ClientId + '&client_secret=' + ClientSecret);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        Url := 'https://api.amazon.com/auth/o2/token';

        if client.Post(Url, content, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                AccessToken := GetJsonvalue(jObject, 'access_token').AsText();
                exit(AccessToken);
            end
            else begin
                Error(StrSubstNo('Not able to Retrieve Access Token With Error Code %1', responseMessage.HttpStatusCode));
            end;
        end;
    end;


    procedure GetOrders(ChannelCode: Code[10])
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        response: Text;
        Url: Text;
        AccessToken: Text;
        noOfRec: Integer;
        i: Integer;
        jObject: JsonObject;
        payloadArray: JsonArray;
        payloadToken: JsonToken;
        payloadObject: JsonObject;
        orderHeaderObject: JsonObject;
        orderItemArray: JsonArray;
        ChannelOrderID: Code[20];
        AmazonOrderType: Text;
        TradePartner: Record "Trade Partner";
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
    begin
        GetCredentials(ChannelCode);
        AccessToken := GetAccessToken(ChannelCode);

        // if CreatedBefore = '' then begin
        //     CreatedBefore := Format(DT2Date(CurrentDateTime), 0, '20<Year>-<Month,2>-<Day,2>');
        // end;

        Url := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrderHeaders?' +
        'AccessKey=' + AccessKey + '&SecretKey=' + SecretKey + '&Region=eu-west-1' +
        '&MarketplaceIds=' + MarketPlaceId + '&CreatedAfter=' + CreatedAfter +
        '&CreatedBefore=' + CreatedBefore + '&MaxResultsPerPage=100&OrderStatuses=' + AmazonOrderStatus +
        '&accessToken=' + AccessToken;

        if client.Get(Url, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);

                payloadArray := GetJsonToken(jObject, 'payload').AsArray();
                noOfRec := payloadArray.Count;

                for i := 0 to noOfRec - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();

                    payloadArray.Get(i, payloadToken);
                    payloadObject := payloadToken.AsObject();
                    orderHeaderObject := GetJsonToken(payloadObject, 'Orders').AsObject();

                    Clear(ChannelOrderID);
                    ChannelOrderID := GetJsonvalue(orderHeaderObject, 'AmazonOrderId').AsCode();

                    if GetJsonvalue(orderHeaderObject, 'FulfillmentChannel').IsNull = false then begin
                        AmazonOrderType := GetJsonvalue(orderHeaderObject, 'FulfillmentChannel').AsText();
                    end;

                    TradePartner.Reset();
                    if TradePartner.Get(ChannelCode) then begin
                        if (AmazonOrderType = 'AFN') and (TradePartner.Code = 'AMAZONFBA') then begin
                            InsertInSalesHeader(ChannelOrderID, orderHeaderObject, ChannelCode, AccessToken, InterimSalesHeader);
                            orderItemArray := GetOrderItems(ChannelCode, ChannelOrderID, AccessToken);
                            InsertInSalesLine(InterimSalesHeader, orderItemArray, InterimSalesLine);

                            CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                        end;

                        if (AmazonOrderType = 'MFN') and (TradePartner.Code = 'AMAZONFBS') then begin
                            InsertInSalesHeader(ChannelOrderID, orderHeaderObject, ChannelCode, AccessToken, InterimSalesHeader);
                            orderItemArray := GetOrderItems(ChannelCode, ChannelOrderID, AccessToken);
                            InsertInSalesLine(InterimSalesHeader, orderItemArray, InterimSalesLine);

                            CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                        end;
                    end;

                end;
            end;
        end;
        MESSAGE('Order Sync Completed...');
    end;


    local procedure InsertInSalesHeader(ChannelOrderId: Text; orderHeaderObject: JsonObject; ChannelCode: Code[250]; AccessToken: Text; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        FullfillmentChannel: Text;
        PurchaseDate: Text;
        paymentMethod: Text;
        orderAmountObject: JsonObject;
        OrderType: Text;
        earliestShipDate: Text;
        earliestDeliveryDate: Text;
        shippingAddressObject: JsonObject;
        TradePartner: Record "Trade Partner";
        ShippingRule: Record "Shipping Rule";
    begin
        InterimSalesHeader."Trade Partner Code" := CopyStr(ChannelCode, 1, 250);
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."External Document No." := ChannelOrderId;
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := ChannelOrderId;

        if TradePartner.Get(ChannelCode) then begin
            InterimSalesHeader."Sell-to Customer No." := TradePartner."Customer No.";
        end;

        if GetJsonvalue(orderHeaderObject, 'FulfillmentChannel').IsNull = false then begin
            FullfillmentChannel := GetJsonvalue(orderHeaderObject, 'FulfillmentChannel').AsText();
        end;

        InterimSalesHeader."Fullfillment Channel" := InterimSalesHeader."Fullfillment Channel"::Amazon;
        If FullfillmentChannel = 'AFN' then
            InterimSalesHeader."Fullfillment Channel" := InterimSalesHeader."Fullfillment Channel"::Amazon
        else
            InterimSalesHeader."Fullfillment Channel" := InterimSalesHeader."Fullfillment Channel"::Seller;

        if GetJsonvalue(orderHeaderObject, 'PurchaseDate').IsNull = false then begin
            PurchaseDate := GetJsonvalue(orderHeaderObject, 'PurchaseDate').AsText();
            InterimSalesHeader."Order Date" := GenerateDate(PurchaseDate);
            InterimSalesHeader."Document Date" := GenerateDate(PurchaseDate);
            InterimSalesHeader."Order Placed At" := GenerateDateTime(PurchaseDate);
        end;

        if GetJsonvalue(orderHeaderObject, 'PaymentMethod').IsNull = false then begin
            InterimSalesHeader."Payment Method" := GetJsonvalue(orderHeaderObject, 'PaymentMethod').AsText();
        end;

        if GetJsonvalue(orderHeaderObject, 'ShipmentServiceLevelCategory').IsNull = false then begin
            InterimSalesHeader."Web Shipment Method" := GetJsonvalue(orderHeaderObject, 'ShipmentServiceLevelCategory').AsText();
        end;

        ShippingRule.Reset();
        ShippingRule.SetRange("Channel Code", ChannelCode);
        ShippingRule.SetRange("Web Shipment Method", InterimSalesHeader."Web Shipment Method");
        if ShippingRule.FindFirst() then begin
            InterimSalesHeader."Shipping Agent Service Code" := ShippingRule."Shipping Agent Service";
            InterimSalesHeader."Shipping Agent Code" := ShippingRule."Shipping Agent";
        end;

        //Getting Order Amount Object
        orderAmountObject := GetJsonToken(orderHeaderObject, 'OrderTotal').AsObject();

        if GetJsonvalue(orderAmountObject, 'CurrencyCode').IsNull = false then begin
            InterimSalesHeader."Currency Code" := GetJsonvalue(orderAmountObject, 'CurrencyCode').AsCode();
        end;

        if GetJsonvalue(orderAmountObject, 'Amount').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonvalue(orderAmountObject, 'Amount').AsDecimal();
        end;

        if GetJsonvalue(orderHeaderObject, 'EarliestShipDate').IsNull = false then begin
            earliestShipDate := GetJsonvalue(orderHeaderObject, 'EarliestShipDate').AsText();
            InterimSalesHeader."Earliest Ship Date" := GenerateDate(earliestShipDate);
        end;

        if GetJsonvalue(orderHeaderObject, 'EarliestDeliveryDate').IsNull = false then begin
            earliestDeliveryDate := GetJsonvalue(orderHeaderObject, 'EarliestDeliveryDate').AsText();
            InterimSalesHeader."Earliest Delivery date" := GenerateDate(earliestDeliveryDate);
        end;

        //Getting Shipping Address by Calling Shipping Address API
        shippingAddressObject := GetShippingAddress(ChannelCode, ChannelOrderId, AccessToken);
        Sleep(900);

        InterimSalesHeader."Ship-to Address" := '';
        if GetJsonvalue(shippingAddressObject, 'AddressLine1').IsNull = false then begin
            InterimSalesHeader."Ship-to Address" := CopyStr(GetJsonvalue(shippingAddressObject, 'AddressLine1').AsText(), 1, 50);
        end;

        InterimSalesHeader."Ship-to Address 2" := '';
        if GetJsonvalue(shippingAddressObject, 'AddressLine2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := Copystr(GetJsonvalue(shippingAddressObject, 'AddressLine2').AsText(), 1, 50);
        end;

        InterimSalesHeader."Ship-to Post Code" := '';
        If GetJsonvalue(shippingAddressObject, 'PostalCode').IsNull = false then begin
            InterimSalesHeader."Ship-to Post Code" := CopyStr(GetJsonvalue(shippingAddressObject, 'PostalCode').AsCode(), 1, 20);
        end;

        if GetJsonvalue(shippingAddressObject, 'CountryCode').IsNull = false then begin
            InterimSalesHeader."Ship-to Country/Region Code" := CopyStr(GetJsonvalue(shippingAddressObject, 'CountryCode').AsCode(), 1, 10);
        end;

        InterimSalesHeader."Ship-to City" := '';
        if GetJsonvalue(shippingAddressObject, 'City').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := CopyStr(GetJsonvalue(shippingAddressObject, 'City').AsText(), 1, 30);
        end;

        InterimSalesHeader."Ship-to Name" := '';
        If GetJsonvalue(shippingAddressObject, 'Name').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := CopyStr(GetJsonvalue(shippingAddressObject, 'Name').AsText(), 1, 50);
        End;

        InterimSalesHeader.INSERT(TRUE);
    end;


    local procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; orderItemArray: JsonArray; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        noOfItems: Integer;
        i: Integer;
        ShippingPrice: Decimal;
        ChannelSKU: Code[20];
        OrderAmount: Decimal;
        itemToken: JsonToken;
        LineObject: JsonObject;
        itemPriceObject: JsonObject;
        shippingPriceObject: JsonObject;
    begin
        noOfItems := orderItemArray.Count;
        if noOfItems > 0 then begin

            for i := 0 to noOfItems - 1 do begin
                orderItemArray.Get(i, itemToken);
                LineObject := itemToken.AsObject;

                InterimSalesLine.Init;
                InterimSalesLine."Line No." := i;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine.Type := InterimSalesLine.type::Item;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";
                InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";
                InterimSalesLine.Weight := 1;

                if GetJsonvalue(LineObject, 'OrderItemId').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'OrderItemId').AsCode();
                end;

                if GetJsonvalue(LineObject, 'QuantityOrdered').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'QuantityOrdered').AsDecimal();
                end;

                if GetJsonvalue(LineObject, 'Title').IsNull = false then begin
                    InterimSalesLine.Description := Copystr(GetJsonvalue(LineObject, 'Title').AsText(), 1, 100);
                end;

                itemPriceObject := GetJsonToken(LineObject, 'ItemPrice').AsObject();

                if GetJsonvalue(itemPriceObject, 'Amount').IsNull = false then begin
                    InterimSalesLine.Amount := GetJsonvalue(itemPriceObject, 'Amount').AsDecimal();
                end;
                if (InterimSalesLine.Quantity > 1) And (InterimSalesLine.Quantity <> 0) then begin
                    InterimSalesLine."Unit Price" := InterimSalesLine.Amount / InterimSalesLine.Quantity;
                end else begin
                    InterimSalesLine."Unit Price" := InterimSalesLine.Amount;
                end;

                if LineObject.Contains('ShippingPrice') then begin
                    shippingPriceObject := GetJsonToken(LineObject, 'ShippingPrice').AsObject();
                    if (GetJsonvalue(shippingPriceObject, 'Amount').IsNull = false) then begin
                        ShippingPrice := GetJsonvalue(shippingPriceObject, 'Amount').AsDecimal();
                        InterimSalesLine."Shipping Price" := ShippingPrice;
                    end;
                end;

                if GetJsonvalue(LineObject, 'SellerSKU').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'SellerSKU').AsText();
                end;

                InterimSalesLine.Insert(true);
            end;
        end;
    end;


    procedure GetShippingAddress(ChannelCode: Code[10]; ChannelOrderId: Text; AccessToken: Text): JsonObject
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        response: Text;
        Url: Text;
        jObject: JsonObject;
    begin
        GetCredentials(ChannelCode);

        Url := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetShippingAddress?' +
        'AccessToken=' + AccessToken + '&AccessKey=' + AccessKey + '&SecretKey=' + SecretKey +
        '&Region=eu-west-1&OrderId=' + ChannelOrderId;

        if client.Get(Url, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                exit(jObject);
            end;
        end;
    end;


    procedure GetOrderItems(ChannelCode: Code[10]; ChannelOrderId: Code[20]; AccessToken: Text): JsonArray
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        response: Text;
        Url: Text;
        jArray: JsonArray;
    begin
        GetCredentials(ChannelCode);

        Url := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrderItem?' +
        'AccessToken=' + AccessToken + '&AccessKey=' + AccessKey + '&SecretKey=' + SecretKey +
        '&Region=eu-west-1&OrderId=' + ChannelOrderId;

        if client.Get(Url, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jArray.ReadFrom(response);
                exit(jArray);
            end;
        end;
    end;


    local procedure GetItems(ChannelCode: Code[10])
    var
        headers: HttpHeaders;
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        response: Text;
        Url: Text;
        authorizedClient: HttpClient;
        authorizationUrl: Text;
        AuthorizationResponse: HttpResponseMessage;
        authorization: Text;
        AccessToken: Text;
        jObject: JsonObject;
        ReportsArray: JsonArray;
        ReportCount: Integer;
        i: Integer;
        ReportToken: JsonToken;
        ReportObject: JsonObject;
        ReportDocumentID: Text;
        ProcessingDate: Text;
        NewProcessingDate: Text;
        CurrentDate: Text;
        NewCurrentDate: Text;
    begin
        GetCredentials(ChannelCode);
        AccessToken := GetAccessToken(ChannelCode);

        headers := client.DefaultRequestHeaders;
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        headers.Add('x-amz-access-token', Format(AccessToken));

        authorizationUrl := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GenerateSignature?accessToken=' + AccessToken +
                                    '&AccessKeyId=' + AccessKey + '&SecretKey=' + SecretKey + '&Region=eu-west-1&MarketplaceIds=&APIRequest=Items&' +
                                    'CreatedAfter=&CreatedBefore=&OrderStatuses=&MaxResultsPerPage=&LastUpdatedAfter=&LastUpdatedBefore=&FulfillmentChannel=' +
                                    '&PaymentMethods=&BuyerEmail=&SellerOrderId=&EasyShipShipmentStatuses=&NextToken=&AmazonOrderIds=&ChannelOrderId=';
        if authorizedClient.Get(authorizationUrl, AuthorizationResponse) then begin
            if AuthorizationResponse.HttpStatusCode = 200 then begin
                AuthorizationResponse.Content.ReadAs(authorization);
                if authorization.Contains('"') then begin
                    authorization := authorization.Replace('"', '');
                end;
            end;
        end;

        headers.Add('Authorization', authorization);
        Url := ServiceURL + '/reports/2021-06-30/reports?reportTypes=GET_MERCHANT_LISTINGS_ALL_DATA';

        if client.Get(Url, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);

                ReportsArray := GetJsonToken(jObject, 'reports').AsArray();
                ReportCount := ReportsArray.Count;
                if ReportCount > 0 then begin
                    for i := 0 to ReportCount - 1 do begin
                        Clear(ReportDocumentID);
                        ReportsArray.Get(i, ReportToken);
                        ReportObject := ReportToken.AsObject();

                        if GetJsonvalue(ReportObject, 'processingEndTime').IsNull = false then begin
                            ProcessingDate := GetJsonvalue(ReportObject, 'processingEndTime').AsText();
                            NewProcessingDate := ProcessingDate.Substring(0, 10);
                        end;

                        CurrentDate := Format(CurrentDateTime, 0, '20<Year>-<Month,2>-<Day,2>');
                        NewCurrentDate := CurrentDate.Substring(0, 10);

                        if NewProcessingDate = NewCurrentDate then begin
                            if GetJsonvalue(ReportObject, 'reportDocumentId').IsNull = false then begin
                                ReportDocumentID := GetJsonvalue(ReportObject, 'reportDocumentId').AsText();
                            end;
                            GetReportDocument(ReportDocumentID, AccessToken);
                        end;
                    end;
                end;
            end;
        end;
    end;


    local procedure GetReportDocument(ReportDocumentID: Text; AccessToken: Text)
    var
        ReportHeaders: HttpHeaders;
        ReportClient: HttpClient;
        ReportResponseMessage: HttpResponseMessage;
        ReportResponse: Text;
        ReportUrl: Text;
        authorizeClient: HttpClient;
        authorizeUrl: Text;
        AuthorizeResponse: HttpResponseMessage;
        authorized: Text;
        jObject: JsonObject;
        ItemsURL: Text;
    begin
        ReportHeaders := ReportClient.DefaultRequestHeaders;
        ReportHeaders.Clear();
        ReportHeaders.Add('Content-Type', 'application/json');
        ReportHeaders.Add('x-amz-access-token', Format(AccessToken));

        authorizeUrl := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GenerateSignature?accessToken=' + AccessToken +
                                    '&AccessKeyId=' + AccessKey + '&SecretKey=' + SecretKey + '&Region=eu-west-1&MarketplaceIds=&APIRequest=Items&' +
                                    'CreatedAfter=&CreatedBefore=&OrderStatuses=&MaxResultsPerPage=&LastUpdatedAfter=&LastUpdatedBefore=&FulfillmentChannel=' +
                                    '&PaymentMethods=&BuyerEmail=&SellerOrderId=&EasyShipShipmentStatuses=&NextToken=&AmazonOrderIds=&ChannelOrderId=';
        if authorizeClient.Get(authorizeUrl, AuthorizeResponse) then begin
            if AuthorizeResponse.HttpStatusCode = 200 then begin
                AuthorizeResponse.Content.ReadAs(authorized);
                if authorized.Contains('"') then begin
                    authorized := authorized.Replace('"', '');
                end;
            end;
        end;

        ReportHeaders.Add('Authorization', authorized);
        ReportUrl := ServiceURL + '/reports/2021-06-30/documents/' + ReportDocumentID;

        if ReportClient.Get(ReportUrl, ReportResponseMessage) then begin
            if ReportResponseMessage.HttpStatusCode = 200 then begin
                ReportResponseMessage.Content.ReadAs(ReportResponse);
                jObject.ReadFrom(ReportResponse);
                if jObject.Contains('url') then begin
                    if GetJsonvalue(jObject, 'url').IsNull = false then begin
                        ItemsURL := GetJsonvalue(jObject, 'url').AsText();
                        GenerateItems(ItemsURL);
                    end;
                end;
            end;
        end;
    end;


    local procedure GenerateItems(ItemsURL: Text)
    var
        ItemHeaders: HttpHeaders;
        ItemsClient: HttpClient;
        ItemContent: HttpContent;
        ItemsResponseMessage: HttpResponseMessage;
        ItemsResponse: Text;
        CUTempBlob: Codeunit "Temp Blob";
        OutStrm: OutStream;
        Instrm: InStream;
        CSVBuffer: Record "CSV Buffer";
        TabSeperator: Text;
        TabChar: Char;
        NoOfLines: Integer;
    begin
        ItemsURL := 'https://tortuga-prod-eu.s3-eu-west-1.amazonaws.com/%2FNinetyDays/amzn1.tortuga.3.abc37497-41d6-4647-98c2-a4ac4de7bb2f.T2H76HS2Q66R6E?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20210812T150242Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=AKIAX2ZVOZFBD2CTMM2R%2F20210812%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Signature=71edee46740e30b426f1c7496d0a2d49e3b69abd1416f367383fdffba1ab83ab';

        // ItemHeaders := ItemsClient.DefaultRequestHeaders;
        // ItemContent.GetHeaders(ItemHeaders);
        // ItemHeaders.Clear();
        // ItemHeaders.Add('Content-Type', 'text/plain');

        if ItemsClient.Get(ItemsURL, ItemsResponseMessage) then begin
            If ItemsResponseMessage.HttpStatusCode = 200 then begin
                ItemsResponseMessage.Content.ReadAs(ItemsResponse);

                CUTempBlob.CreateOutStream(OutStrm);
                OutStrm.WriteText(ItemsResponse);

                CUTempBlob.CreateInStream(Instrm, TextEncoding::UTF8);

                Instrm.ReadText(ItemsResponse);
                CSVBuffer.DeleteAll();
                TabSeperator := '   ';
                CSVBuffer.LoadDataFromStream(Instrm, TabSeperator);

                NoOfLines := CSVBuffer.GetNumberOfLines();
            end;
        end;
    end;


    local procedure UpdateInventoryPrice(ChannelCode: Code[10])
    var
        headers: HttpHeaders;
        client: HttpClient;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        response: Text;
        Url: Text;
        authorizedClient: HttpClient;
        authorizationUrl: Text;
        AuthorizationResponse: HttpResponseMessage;
        authorization: Text;
        jObject: JsonObject;
        payloadObject: JsonObject;
        encryptionDetails: JsonObject;
        AccessToken: Text;
        AESIV: Text;
        AESKey: Text;
        UploadURL: Text;
    begin
        GetCredentials(ChannelCode);
        AccessToken := GetAccessToken(ChannelCode);

        headers := client.DefaultRequestHeaders;
        content.WriteFrom('{"contentType":"application/xml; charset=UTF-8"}');
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        headers.Add('x-amz-access-token', Format(AccessToken));

        authorizationUrl := 'http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GenerateSignature?accessToken=' + AccessToken +
                                    '&AccessKeyId=' + AccessKey + '&SecretKey=' + SecretKey + '&Region=eu-west-1&MarketplaceIds=&APIRequest=Items&' +
                                    'CreatedAfter=&CreatedBefore=&OrderStatuses=&MaxResultsPerPage=&LastUpdatedAfter=&LastUpdatedBefore=&FulfillmentChannel=' +
                                    '&PaymentMethods=&BuyerEmail=&SellerOrderId=&EasyShipShipmentStatuses=&NextToken=&AmazonOrderIds=&ChannelOrderId=';
        if authorizedClient.Get(authorizationUrl, AuthorizationResponse) then begin
            if AuthorizationResponse.HttpStatusCode = 200 then begin
                AuthorizationResponse.Content.ReadAs(authorization);
                if authorization.Contains('"') then begin
                    authorization := authorization.Replace('"', '');
                end;
            end;
        end;

        headers.Add('Authorization', authorization);
        Url := ServiceURL + '/feeds/2020-09-04/documents';

        if client.Post(Url, content, responseMessage) then begin
            if responseMessage.HttpStatusCode = 201 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                payloadObject := GetJsonToken(jObject, 'payload').AsObject();
                encryptionDetails := GetJsonToken(payloadObject, 'encryptionDetails').AsObject();

                if GetJsonvalue(encryptionDetails, 'initializationVector').IsNull = false then begin
                    AESIV := GetJsonvalue(encryptionDetails, 'initializationVector').AsText();
                end;
                if GetJsonvalue(encryptionDetails, 'key').IsNull = false then begin
                    AESKey := GetJsonvalue(encryptionDetails, 'key').AsText();
                end;
                if GetJsonvalue(payloadObject, 'url').IsNull = false then begin
                    UploadURL := GetJsonvalue(payloadObject, 'url').AsText();
                end;
            end;
        end;
    end;



    local procedure GenerateDate(Orderdate: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Convertdate: Date;
        Lenght: Integer;
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