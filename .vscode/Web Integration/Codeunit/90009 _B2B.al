codeunit 90009 B2B
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
                    ProcessB2BOrders(StartParameter);
                End;
            SyncCustomerLabel:
                begin
                    GetCustomer(StartParameter);
                end;
            SyncCategoryLabel:
                begin
                    CategorySync(StartParameter);
                end;
            SyncManufacturerLabel:
                begin
                    ManufacturerSync(StartParameter);
                end;
            SyncVatLabel:
                begin
                    VATSync(StartParameter);
                end;
            SyncCurrencyLabel:
                begin
                    UpdateCurrencyCode(StartParameter);
                end;
            GenerateChannelLabel:
                begin
                    GenerateListing(StartParameter);
                end;
            SyncProductLabel:
                begin
                    SyncProdNavToNop(StartParameter);
                end;
            SyncSalesPriceLabel:
                begin
                    //SyncSalesPrice(StartParameter);
                    SyncCustomerBasedPrice(StartParameter);
                    SyncedCustomerBasedItemPrice(StartParameter);
                end;
            UpdatePriceLabel:
                begin
                    UpdatePrice(StartParameter);
                end;
            UpdateInventoryLable:
                begin
                    UpdateInventory(StartParameter);
                end;
            SyncShipmentLabel:
                begin
                    UpdateOrderStatusComplete(StartParameter);
                end;
            UpdateProductLable:
                begin
                    SyncUpdateProdNavToNop(StartParameter);
                end;
            SyncCustomerAddressLabel:
                begin
                    SyncCustomerAddresses(StartParameter, '');
                end;
        end;
    end;

    var
        myInt: Integer;

        userName: Text;
        PassWord: Text;
        serverName: Text;
        databaseName: Text;
        NoOfRecs: Integer;
        ProgressCount: Integer;
        Windows: Dialog;
        bool: Boolean;
        Count: Integer;
        jObject: JsonObject;
        jArray: JsonArray;
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        SyncShipmentLabel: Label 'SyncShipment';
        SyncCustomerLabel: Label 'CustomerSync';
        SyncCategoryLabel: Label 'CategorySync';
        SyncSalesPriceLabel: Label 'SyncSalesPrice';
        SyncManufacturerLabel: Label 'ManufacturerSync';
        SyncVatLabel: Label 'VatSync';
        SyncCurrencyLabel: Label 'CurrencySync';
        GenerateChannelLabel: Label 'GenerateChannelList';
        SyncProductLabel: Label 'SyncItem';
        UpdatePriceLabel: Label 'UpdatePrice';
        UpdateInventoryLable: Label 'UpdateInventory';
        UpdateProductLable: Label 'UpdateProduct';
        SyncCustomerAddressLabel: Label 'CustomerSyncAddress';
        ShippingPrice: Decimal;

        LastOrderSync: DateTime;
        LastCustomerSyncDate: Text;
        Tradepartner: Record "Trade Partner";
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        HandledCustomer: Record "Handled Customer";


    procedure GetCustomer(ChannelCode: Code[20])
    var
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        URL: Text;
        HttpRequest: HttpRequestMessage;
        HttpClient: HttpClient;
        responseText: Text;
        AuthText: Text;
        JsonObject: JsonObject;
        jsonMainReq: JsonObject;
        customerArray: JsonArray;
        i: Integer;
        customerToken: JsonToken;
        ChannelCustomerID: Code[20];
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        Text001: TextConst ENU = 'Importing Customers In BC..';
        LastCustomerSync: DateTime;
    begin
        ProgressCount := 0;
        GetCredentials(ChannelCode);
        Tradepartner.Reset;
        Tradepartner.SetRange(Code, ChannelCode);
        if Tradepartner.FindFirst() then;
        LastCustomerSync := CREATEDATETIME(DT2DATE(TradePartner."Last Customer Sync") - 1, DT2TIME(TradePartner."Last Customer Sync"));
        LastCustomerSyncDate := Format(LastCustomerSync, 0, '<Year4>-<Month,2>-<Day,2>');

        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(userName, PassWord));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');

        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/GetB2BCustomerAll?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&LastCustomerSyncDate=' + LastCustomerSyncDate;
        if HttpClient.Get(URL, HttpResponse) then begin

            HttpResponse.Content.ReadAs(responseText);
            jsonMainReq.ReadFrom(responseText);

            customerArray := GetJsonToken(jsonMainReq, 'customerlist').AsArray();
            i := customerArray.Count;
            NoOfRecs := customerArray.Count;
            Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Cutomer Sync..' + ' #3##########' + 'Please Wait..');
            for i := 0 to customerArray.Count - 1 do begin

                customerArray.Get(i, customerToken);
                jsonMainReq := customerToken.AsObject();

                ChannelCustomerID := GetJsonvalue(jsonMainReq, 'No').AsCode();
                ProgressCount += 1;

                IF bool THEN BEGIN

                    IF NoOfRecs <= 100 THEN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)

                    ELSE
                        IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                            Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                        END;
                    Windows.UPDATE(3, FORMAT(ChannelCustomerID));

                END;
                InsertCustomer(ChannelCustomerID, jsonMainReq, ChannelCode);

            End;
        End;

        MESSAGE('Customer Sync Completed...');
    End;


    procedure GetOrders(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        Tradepartner: Record "Trade Partner";
        ordersCount: Integer;
        i: Integer;
        orderToken: JsonToken;
        orderHeaderObject: JsonObject;
        WebHeaderObject: JsonObject;
        ChannelOrderID: Code[20];
        LastOrderSyncDate: Text;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        InterimSalesLine: Record "Interim Sales Line" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        Text001: TextConst ENU = 'Importing Orders In BC..';

    begin
        ProgressCount := 0;
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        Tradepartner.Reset();
        Tradepartner.SetRange(Code, ChannelCode);
        If Tradepartner.FindFirst() then;
        //LastOrderSync := Tradepartner."Last Order Sync";
        LastOrderSync := CREATEDATETIME(DT2DATE(TradePartner."Last Order Sync") - 1, DT2TIME(TradePartner."Last Order Sync"));
        LastOrderSyncDate := Format(LastOrderSync, 0, '<Year4>-<Month,2>-<Day,2>');
        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/GetOrdersAll?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&LastOrderSyncDate=' + LastOrderSyncDate;
        if (client.Get(URL, responseMessage)) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            jArray := GetJsonToken(jObject, 'orderList').AsArray();
            ordersCount := jArray.Count;
            NoOfRecs := jArray.Count;
            Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Order Sync..' + ' #3##########' + 'Please Wait..');
            for i := 0 to ordersCount - 1 do begin
                ShipmnetTracking.DeleteAll();
                PaymentDetails.DeleteAll();
                InterimSalesHeader.DeleteAll();
                InterimSalesLine.DeleteAll();
                jArray.Get(i, orderToken);
                orderHeaderObject := orderToken.AsObject();
                WebHeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                ChannelOrderID := GetJsonvalue(WebHeaderObject, 'ChannelOrderID').AsCode();
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, ChannelOrderID);
                InsertInSalesHeader(ChannelOrderID, WebHeaderObject, ChannelCode, InterimSalesHeader);
                InsertInSalesLine(InterimSalesHeader, orderHeaderObject, ShippingPrice, InterimSalesLine);
                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                UpdateOrderStatusProcessing(InterimSalesHeader."Channel Order ID");
            end;
        end;

        TradePartner."Last Order Sync" := CREATEDATETIME(WORKDATE, TIME);
        TradePartner.Modify;

        MESSAGE('Order Sync Completed...');
    end;

    procedure CategorySync(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        name: Text;
        ItemCategory: Record "Item Category";
        ItemCategory1: Record "Item Category";
        ItemCategory2: Record "Item Category";
        categoryCount: Integer;
        i: Integer;
        isSuccess: Text;
        errorMessage: Text;
        NavCategoryId: Text;
        NAVCategoryCode: Text;
        webcat: Boolean;
        Text001: TextConst ENU = 'Importing Categories In B2B..';
        TypeHelper: Codeunit "Type Helper";

    begin
        GetCredentials(ChannelCode);
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Category Sync..' + ' #3##########' + 'Please Wait..');
        ItemCategory.Reset();
        ItemCategory.SetFilter(Code, '<>%1', '');
        ItemCategory.SetRange(Indentation, 0);
        ItemCategory.SetFilter("Parent Category", '%1', '');
        //ItemCategory.SetRange("Has Children", true);
        if ItemCategory.FindSet() then begin
            NoOfRecs := ItemCategory.Count;
            repeat
                Clear(headers);
                Clear(content);
                headers := Client.DefaultRequestHeaders();
                content.GetHeaders(headers);
                headers.Clear();
                headers.Add('Content-Type', 'application/json');
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, ItemCategory.Code);
                Clear(name);
                Clear(NAVCategoryCode);
                Clear(NavCategoryId);
                Clear(URL);
                Clear(response);
                name := ItemCategory.Code;
                NAVCategoryCode := ItemCategory.Code;
                NavCategoryId := '';


                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/CategorySync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + TypeHelper.UrlEncode(name) + '&NavCategoryId=' + TypeHelper.UrlEncode(NavCategoryId) + '&NAVCategoryCode=' + TypeHelper.UrlEncode(NAVCategoryCode) + '&WebCategory=' + 'true';
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);

                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'false') then begin
                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        Message(errorMessage);
                    end;
                end;
                ItemCategory1.Reset();
                ItemCategory1.SetFilter(Code, '<>%1', '');
                ItemCategory1.SetFilter(Indentation, '<>%1', 0);
                ItemCategory1.SetRange("Parent Category", ItemCategory.Code);

                if ItemCategory1.FindSet() then begin
                    repeat
                        Clear(headers);
                        Clear(content);
                        headers := Client.DefaultRequestHeaders();
                        content.GetHeaders(headers);
                        headers.Clear();
                        headers.Add('Content-Type', 'application/json');
                        Clear(name);
                        Clear(NAVCategoryCode);
                        Clear(NavCategoryId);
                        Clear(URL);
                        Clear(response);
                        name := ItemCategory1.Code;
                        NAVCategoryCode := ItemCategory1.Code;
                        NavCategoryId := ItemCategory.Code;

                        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/CategorySync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + TypeHelper.UrlEncode(name) + '&NavCategoryId=' + TypeHelper.UrlEncode(NavCategoryId) + '&NAVCategoryCode=' + TypeHelper.UrlEncode(NAVCategoryCode) + '&WebCategory=' + 'true';
                        Client.Post(URL, content, ResponseMessage);
                        if (ResponseMessage.HttpStatusCode = 200) then begin
                            ResponseMessage.Content.ReadAs(response);
                            jObject.ReadFrom(response);

                            isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                            if (isSuccess = 'false') then begin
                                errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                                Message(errorMessage);
                            end;
                        end;
                        //+
                        ItemCategory2.Reset();
                        ItemCategory2.SetFilter(Code, '<>%1', '');
                        ItemCategory2.SetFilter(Indentation, '<>%1', 0);
                        ItemCategory2.SetRange("Parent Category", ItemCategory1.Code);

                        if ItemCategory2.FindSet() then begin
                            repeat
                                Clear(headers);
                                Clear(content);
                                headers := Client.DefaultRequestHeaders();
                                content.GetHeaders(headers);
                                headers.Clear();
                                headers.Add('Content-Type', 'application/json');
                                Clear(name);
                                Clear(NAVCategoryCode);
                                Clear(NavCategoryId);
                                Clear(URL);
                                Clear(response);
                                name := ItemCategory2.Code;
                                NAVCategoryCode := ItemCategory2.Code;
                                NavCategoryId := ItemCategory1.Code;

                                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/CategorySync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + TypeHelper.UrlEncode(name) + '&NavCategoryId=' + TypeHelper.UrlEncode(NavCategoryId) + '&NAVCategoryCode=' + TypeHelper.UrlEncode(NAVCategoryCode) + '&WebCategory=' + 'true';
                                Client.Post(URL, content, ResponseMessage);
                                if (ResponseMessage.HttpStatusCode = 200) then begin
                                    ResponseMessage.Content.ReadAs(response);
                                    jObject.ReadFrom(response);

                                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                                    if (isSuccess = 'false') then begin
                                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                                        Message(errorMessage);
                                    end;
                                end;
                            until ItemCategory2.Next() = 0;
                        end;

                    //-
                    until ItemCategory1.Next() = 0;
                end;
            until ItemCategory.Next() = 0;
        end;
        Message('Category Sync Successfully...');

    end;

    procedure ManufacturerSync(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        name: Text;
        description: Text;
        manufacturer: Record Manufacturer;
        isSuccess: Text;
        errorMessage: Text;
        Text001: TextConst ENU = 'Importing Manufacturers In B2B..';
        TypeHelper: Codeunit "Type Helper";
    begin
        GetCredentials(ChannelCode);

        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Manufacturer Sync..' + ' #3##########' + 'Please Wait..');
        manufacturer.Reset();
        manufacturer.SetFilter(Code, '<>%1', '');
        if manufacturer.FindSet() then begin
            NoOfRecs := manufacturer.Count;

            repeat
                Clear(headers);
                Clear(content);
                headers := Client.DefaultRequestHeaders();
                content.GetHeaders(headers);
                headers.Clear();
                headers.Add('Content-Type', 'application/json');
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, manufacturer.Code);
                Clear(name);
                Clear(description);
                Clear(URL);
                Clear(ResponseMessage);
                Clear(response);
                Clear(jObject);
                name := manufacturer.Code;
                description := manufacturer.Name;

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/ManufacturerSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Code=' + TypeHelper.UrlEncode(name) + '&Name=' + TypeHelper.UrlEncode(description);
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);

                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'false') then begin
                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        Message(errorMessage);
                    end;

                end;
            until manufacturer.Next() = 0;

        end;
        Message('Manufacturer Sync Successfully...');
    end;


    procedure GetJsonToken(var JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then;
    end;

    procedure GetCredentials("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            userName := TradePartner.AccessKeyId;
            PassWord := TradePartner.SecretAccessKey;
            serverName := TradePartner.MerchantId;
            databaseName := TradePartner.MarketplaceId;
            LastOrderSync := TradePartner."Last Order Sync";
        end;
    End;

    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: text) aJsonValue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        Else
            aJsonValue := aJsonToken.AsValue();
    end;

    procedure InsertInSalesHeader(ChannelOrderId: Text; WebHeaderObject: JsonObject; ChannelCode: Code[20]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        TradePartner: Record "Trade Partner";
        OrderDate: Text;
        CurrencyRate: Decimal;
        CustomExtDocNo: Text;
        Pos: Integer;
        sbstr: Text;
        Comment: Text;
    begin
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := ChannelOrderId;

        If GetJsonvalue(WebHeaderObject, 'OrderCreatedOn').IsNull = false then begin
            Clear(OrderDate);
            OrderDate := GetJsonToken(WebHeaderObject, 'OrderCreatedOn').AsValue().AsText();
            InterimSalesHeader."Document Date" := GenerateDate(OrderDate);
            InterimSalesHeader."Order Placed At" := CreateDateTime(GenerateDate(OrderDate), Time);
        end;


        If GetJsonvalue(WebHeaderObject, 'BilltoCustomerNo').IsNull = false then begin
            InterimSalesHeader."Sell-to Customer No." := GetJsonToken(WebHeaderObject, 'BilltoCustomerNo').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'BuyerName').IsNull = false then begin
            InterimSalesHeader."Bill- to Name" := GetJsonToken(WebHeaderObject, 'BuyerName').AsValue.AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'Address').IsNull = false then begin
            InterimSalesHeader."Address" := GetJsonToken(WebHeaderObject, 'Address').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'Address2').IsNull = false then begin
            InterimSalesHeader."Address 2" := GetJsonToken(WebHeaderObject, 'Address2').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'City').IsNull = false then begin
            InterimSalesHeader."City" := GetJsonToken(WebHeaderObject, 'City').AsValue.AsText();
        end;

        If GetJsonvalue(WebHeaderObject, 'PostCode').IsNull = false then begin
            InterimSalesHeader."Post Code" := GetJsonToken(WebHeaderObject, 'PostCode').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoName').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := GetJsonToken(WebHeaderObject, 'ShiptoName').AsValue.AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'BuyerName').IsNull = false then begin
            InterimSalesHeader."Buyer Name" := GetJsonToken(WebHeaderObject, 'BuyerName').AsValue.AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoAddress').IsNull = false then begin
            InterimSalesHeader."Ship-to Address" := GetJsonToken(WebHeaderObject, 'ShiptoAddress').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoAddress2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := GetJsonToken(WebHeaderObject, 'ShiptoAddress2').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoCity').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := GetJsonToken(WebHeaderObject, 'ShiptoCity').AsValue().AsText();
        end;

        If GetJsonvalue(WebHeaderObject, 'ShiptoCountryRegionCode').IsNull = false then begin
            InterimSalesHeader."Ship-to Post Code" := GetJsonToken(WebHeaderObject, 'ShiptoCountryRegionCode').AsValue().AsText();
        end;

        If GetJsonvalue(WebHeaderObject, 'ShiptoCounty').IsNull = false then begin
            InterimSalesHeader."Ship-to Country/Region Code" := GetJsonToken(WebHeaderObject, 'ShiptoCounty').AsValue().AsText();
        end;

        Clear(CurrencyRate);
        if GetJsonvalue(WebHeaderObject, 'CurrencyFactor').IsNull = false then begin
            InterimSalesHeader."Currency Factor" := GetJsonToken(WebHeaderObject, 'CurrencyFactor').AsValue().AsDecimal();
            CurrencyRate := InterimSalesHeader."Currency Factor";
        end;

        if GetJsonvalue(WebHeaderObject, 'OrderAmount').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonToken(WebHeaderObject, 'OrderAmount').AsValue().AsDecimal();
            InterimSalesHeader."Order Amount" := Round(InterimSalesHeader."Order Amount" * CurrencyRate);
        end;

        if GetJsonvalue(WebHeaderObject, 'PhoneNumber').IsNull = false then begin
            InterimSalesHeader."Customer Phone Number" := GetJsonToken(WebHeaderObject, 'PhoneNumber').AsValue().AsCode();
        end;

        if GetJsonvalue(WebHeaderObject, 'WebShipmentMethod').IsNull = false then begin
            InterimSalesHeader."Web Shipment Method" := GetJsonToken(WebHeaderObject, 'WebShipmentMethod').AsValue().AsCode();
        end;

        if GetJsonvalue(WebHeaderObject, 'OrderShippingExclTax').IsNull = false then begin
            ShippingPrice := GetJsonvalue(WebHeaderObject, 'OrderShippingExclTax').AsDecimal();
            ShippingPrice := Round(ShippingPrice * CurrencyRate);
        end;
        InterimSalesHeader.Remarks := '';
        if GetJsonvalue(WebHeaderObject, 'Comments').IsNull = false then begin
            Clear(Comment);
            Comment := GetJsonvalue(WebHeaderObject, 'Comments').AsText();
            InterimSalesHeader.Remarks := Comment;
        end;

        if GetJsonvalue(WebHeaderObject, 'CurrencyCode').IsNull = false then begin
            InterimSalesHeader."Currency Code" := GetJsonvalue(WebHeaderObject, 'CurrencyCode').AsText();
        end;

        InterimSalesHeader."External Document No." := '';
        if GetJsonvalue(WebHeaderObject, 'CustomString').IsNull = false then begin
            Clear(sbstr);
            Clear(CustomExtDocNo);
            CustomExtDocNo := GetJsonvalue(WebHeaderObject, 'CustomString').AsText();
            Pos := STRPOS(CustomExtDocNo, ':');
            IF Pos > 0 THEN BEGIN
                sbstr := COPYSTR(CustomExtDocNo, 20, Pos - 1);
            end;
            InterimSalesHeader."External Document No." := sbstr;
        end;

        InterimSalesHeader.Insert();
    end;

    procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; jsonMainReq: JsonObject; ShippingPrice: Decimal; var InterimSalesLine: Record "Interim Sales Line" temporary)
    var
        ItemArray: JsonArray;
        itemCount: Integer;
        k: Integer;
        WebLineToken: JsonToken;
        LineObject: JsonObject;
        LineNo: Integer;
        itemNo: Text;
        Item: Record Item;
        ChannelSKU: Code[20];
        IsError: Boolean;
        TradePartner: Record "Trade Partner";
    begin
        ItemArray := GetJsonToken(jsonMainReq, 'webLines').AsArray();
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

                if GetJsonvalue(LineObject, 'Quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'Quantity').AsDecimal;

                end;

                if GetJsonvalue(LineObject, 'VATamount').IsNull = false then begin
                    InterimSalesLine."VAT amount" := GetJsonvalue(LineObject, 'VATamount').AsDecimal;
                    InterimSalesLine."VAT amount" := Round(InterimSalesLine."VAT amount" * InterimSalesHeader."Currency Factor");
                end;

                if GetJsonvalue(LineObject, 'AmountIncludingVAT').IsNull = false then begin
                    InterimSalesLine."Amount Including VAT" := GetJsonvalue(LineObject, 'AmountIncludingVAT').AsDecimal;
                    InterimSalesLine."Amount Including VAT" := Round(InterimSalesLine."Amount Including VAT" * InterimSalesHeader."Currency Factor");
                end;

                if GetJsonvalue(LineObject, 'ChannelItemId').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'ChannelItemId').AsText();

                end;

                TradePartner.Get(InterimSalesHeader."Trade Partner Code");
                if TradePartner."Prices Including VAT" then begin
                    if GetJsonvalue(LineObject, 'UnitPrice').IsNull = false then begin
                        InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'UnitPrice').AsDecimal();
                        InterimSalesLine."Unit Price" := Round(InterimSalesLine."Unit Price" * InterimSalesHeader."Currency Factor");
                    end;

                    if GetJsonvalue(LineObject, 'Discount').IsNull = false then begin
                        InterimSalesLine.Discount := GetJsonvalue(LineObject, 'Discount').AsDecimal();
                        InterimSalesLine.Discount := Round(InterimSalesLine.Discount * InterimSalesHeader."Currency Factor");
                    end;

                end
                else begin
                    if GetJsonvalue(LineObject, 'UnitPriceExclusiveVAT').IsNull = false then begin
                        InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'UnitPriceExclusiveVAT').AsDecimal();
                        InterimSalesLine."Unit Price" := Round(InterimSalesLine."Unit Price" * InterimSalesHeader."Currency Factor");
                    end;

                    if GetJsonvalue(LineObject, 'DiscountExclusiveVAT').IsNull = false then begin
                        InterimSalesLine.Discount := GetJsonvalue(LineObject, 'DiscountExclusiveVAT').AsDecimal();
                        InterimSalesLine.Discount := Round(InterimSalesLine.Discount * InterimSalesHeader."Currency Factor");
                    end;
                end;


                if GetJsonvalue(LineObject, 'Description').IsNull = false then begin
                    InterimSalesLine.Description := Copystr(GetJsonvalue(LineObject, 'Description').AsText(), 1, 100);
                end;

                if GetJsonvalue(LineObject, 'ChannelItemId').IsNull = false then begin
                    InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'ChannelItemId').AsCode;
                    InterimSalesLine."No." := GetJsonvalue(LineObject, 'ChannelItemId').AsCode;
                end;

                if GetJsonvalue(LineObject, 'UnitofMeasureCode').IsNull = false then begin
                    InterimSalesLine."Unit of Measure Code" := GetJsonvalue(LineObject, 'UnitofMeasureCode').AsCode();
                end;
                if (k = 0) and (ShippingPrice > 0) then
                    InterimSalesLine."Shipping Price" := ShippingPrice;

                InterimSalesLine.Insert();
                InterimSalesLine.Amount := Round(InterimSalesLine."Unit Price" * InterimSalesLine.Quantity);
                InterimSalesLine.Modify();
            end;
        end;
    end;

    Local procedure InsertCustomer(ChanneCustId: Code[20]; CustJsonObject: jsonobject; ChannelCode: Code[20])
    var
        InterimCustomer: Record "Interim Customer";
        cust: Record Customer;
    begin

        InterimCustomer.Reset;
        InterimCustomer.SetRange("No.", GetJsonToken(CustJsonObject, 'No').AsValue().AsCode());


        IF NOT InterimCustomer.FindFirst THEN BEGIN
            HandledCustomer.Reset;
            HandledCustomer.SetRange("Web Customer No.", GetJsonToken(CustJsonObject, 'No').AsValue().AsCode());
            if not HandledCustomer.FindFirst then begin
                InterimCustomer.INIT;
                if GetJsonvalue(CustJsonObject, 'No').IsNull = false then begin
                    InterimCustomer."No." := GetJsonToken(CustJsonObject, 'No').AsValue().AsCode();
                    InterimCustomer."Channel Code" := 'B2B';
                end;

                if GetJsonvalue(CustJsonObject, 'EMail').IsNull = false then begin
                    InterimCustomer."E-Mail" := GetJsonToken(CustJsonObject, 'EMail').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'Name').IsNull = false then begin
                    InterimCustomer.Name := GetJsonToken(CustJsonObject, 'Name').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'Company_Name').IsNull = false then begin
                    InterimCustomer."Company Name" := GetJsonToken(CustJsonObject, 'Company_Name').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'Address').IsNull = false then begin
                    InterimCustomer.Address := GetJsonToken(CustJsonObject, 'Address').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'Address2').IsNull = false then begin
                    InterimCustomer."Address 2" := GetJsonToken(CustJsonObject, 'Address2').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'City').IsNull = false then begin
                    InterimCustomer.City := GetJsonToken(CustJsonObject, 'City').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'Phone_No').IsNull = false then begin
                    InterimCustomer."Phone No" := GetJsonToken(CustJsonObject, 'Phone_No').AsValue().AsText();
                end;

                if GetJsonvalue(CustJsonObject, 'Post_Code').IsNull = false then begin
                    InterimCustomer."Post Code" := GetJsonToken(CustJsonObject, 'Post_Code').AsValue().AsText();
                end;

                InterimCustomer.INSERT();
                Tradepartner.Reset;
                Tradepartner.SetRange(Code, ChannelCode);
                IF Tradepartner.FindFirst then begin
                    Tradepartner."Last Customer Sync" := CurrentDateTime;
                    Tradepartner.Modify;
                end;
            end;
        end;
    end;


    procedure CustomerStatusSync(WebCustomerId: Code[20]; ChannelCode: Code[20]) //Shailesh 140621
    var
        InterimCustomer: Record "Interim Customer";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        custid: Text;

    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        InterimCustomer.Reset;
        InterimCustomer.SetRange("No.", WebCustomerId);
        InterimCustomer.SetRange("Channel Code", ChannelCode);
        if InterimCustomer.FindFirst then begin
            Clear(custid);
            custid := InterimCustomer."No.";
            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/CustomerStatusSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&CustId=' + custid;
            Client.Post(URL, content, ResponseMessage);
            if (ResponseMessage.HttpStatusCode = 200) then begin
                ResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                if (isSuccess = 'true') then begin
                    //Message('Account Activated...');
                end;
            end;
        end;

    end;

    procedure UpdateCustomer(WebCustomerId: Code[20]; ChannelCode: Code[20]) //Shailesh 150621
    var
        Customer: Record Customer;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        custid: Text;
        navcustid: Text;
        credit_limit_lcy: Text;
        balance_lcy: Text;
        customer_price_group: Text;
        countrycode: Text;
        city: Text;
        address1: Text;
        address2: Text;
        county: Text;
        zipcode: Text;


    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Customer.Reset;
        Customer.SetRange("Web Customer No. 2", WebCustomerId);
        if Customer.FindFirst then begin
            Clear(custid);
            custid := Customer."Web Customer No. 2";
            Clear(navcustid);
            navcustid := Format(Customer."No.");
            Clear(credit_limit_lcy);
            credit_limit_lcy := Format(Customer."Credit Limit (LCY)");
            Clear(balance_lcy);
            balance_lcy := Format(Customer."Balance (LCY)");
            Clear(customer_price_group);
            if Customer."Customer Price Group" <> '' then begin
                customer_price_group := Customer."Customer Price Group";
            end
            else begin
                customer_price_group := 'NULL';
            end;
            Clear(countrycode);
            if Customer."Country/Region Code" <> '' then begin
                countrycode := Customer."Country/Region Code";
            end
            else begin
                countrycode := 'NULL';
            end;
            Clear(city);
            if Customer.City <> '' then begin
                city := Customer.City;
            end
            else begin
                city := 'NULL';
            end;
            Clear(address1);
            if Customer.Address <> '' then begin
                address1 := Customer.Address;
            end
            else begin
                address1 := 'NULL';
            end;
            Clear(address2);
            if Customer."Address 2" <> '' then begin
                address2 := Customer."Address 2";
            end
            else begin
                address2 := 'NULL';
            end;
            Clear(county);
            if Customer.County <> '' then begin
                county := Customer.County;
            end
            else begin
                county := 'NULL';
            end;
            Clear(zipcode);
            if Customer."Post Code" <> '' then begin
                zipcode := Customer."Post Code";
            end
            else begin
                zipcode := 'NULL';
            end;

            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateCustomer?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&WebCustomerNo=' + custid + '&NavCustID=' + navcustid + '&Credit_Limit_LCY=' + credit_limit_lcy + '&Balance_LCY=' + balance_lcy + '&Customer_Price_Group=' + customer_price_group + '&CountryCode=' + countrycode + '&City=' + city + '&Address1=' + address1 + '&Address2=' + address2 + '&County=' + county + '&ZipPostalCode=' + zipcode;
            Client.Post(URL, content, ResponseMessage);
            if (ResponseMessage.HttpStatusCode = 200) then begin
                ResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                if (isSuccess = 'true') then begin
                    //Message('Billing Address Updated...');
                end;
            end;
        end;
    end;

    procedure UpdateShippingAddress(WebCustomerId: Code[20]; ChannelCode: Code[20])
    var
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        shiptoaddresscode: Text;
        shiptoname: Text;
        shiptoname2: Text;
        shiptoemail: Text;
        shiptophone: Text;
        shiptofax: Text;
        shiptoaddress1: Text;
        shiptoaddress2: Text;
        shiptocity: Text;
        shiptocountry: Text;
        shiptocounty: Text;
        shiptopostcode: Text;
        custid: Text;
        isShipingAddr: Integer;
        TypeHelper: Codeunit "Type Helper";

    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Customer.Reset;
        Customer.SetRange("Web Customer No. 2", WebCustomerId);
        if Customer.FindFirst then begin
            ShiptoAddress.Reset;
            ShiptoAddress.SetRange("Customer No.", Customer."No.");
            ShiptoAddress.SetFilter(Code, '<>%1', '');
            if ShiptoAddress.FindSet() then begin
                repeat
                    Clear(URL);
                    Clear(response);
                    Clear(ResponseMessage);
                    Clear(content);
                    clear(shiptoaddresscode);
                    if (ShiptoAddress.Code = '') then
                        shiptoaddresscode := 'NULL'
                    else
                        shiptoaddresscode := ShiptoAddress.Code;

                    Clear(shiptoname);
                    if (ShiptoAddress.Name = '') then
                        shiptoname := '-'
                    else
                        shiptoname := TypeHelper.UrlEncode(ShiptoAddress.Name);

                    Clear(shiptoname2);
                    if (ShiptoAddress."Name 2" = '') then
                        shiptoname2 := '-'
                    ELSE
                        shiptoname2 := TypeHelper.UrlEncode(ShiptoAddress."Name 2");

                    Clear(shiptoemail);
                    if (ShiptoAddress."E-Mail" = '') then
                        shiptoemail := 'NULL'
                    else
                        shiptoemail := ShiptoAddress."E-Mail";

                    Clear(shiptophone);
                    if (ShiptoAddress."Phone No." = '') then
                        shiptophone := '-'
                    else
                        shiptophone := ShiptoAddress."Phone No.";

                    Clear(shiptofax);
                    if (ShiptoAddress."Fax No." = '') then
                        shiptofax := '-'
                    else
                        shiptofax := ShiptoAddress."Fax No.";

                    Clear(shiptoaddress1);
                    if (ShiptoAddress.Address = '') THEN
                        shiptoaddress1 := '-'
                    else
                        shiptoaddress1 := TypeHelper.UrlEncode(ShiptoAddress.Address);

                    Clear(shiptoaddress2);
                    if (ShiptoAddress."Address 2" = '') then
                        shiptoaddress2 := '-'
                    else
                        shiptoaddress2 := TypeHelper.UrlEncode(ShiptoAddress."Address 2");

                    Clear(shiptocity);
                    if (ShiptoAddress.City = '') then
                        shiptocity := '-'
                    else
                        shiptocity := TypeHelper.UrlEncode(ShiptoAddress.City);

                    Clear(shiptocountry);
                    if (ShiptoAddress."Country/Region Code" = '') then
                        shiptocountry := '-'
                    else
                        shiptocountry := ShiptoAddress."Country/Region Code";

                    Clear(shiptocounty);
                    if (ShiptoAddress.County = '') then
                        shiptocounty := '-'
                    else
                        shiptocounty := TypeHelper.UrlEncode(ShiptoAddress.County);

                    Clear(shiptopostcode);
                    if (ShiptoAddress."Post Code" = '') then
                        shiptopostcode := '-'
                    ELSE
                        shiptopostcode := ShiptoAddress."Post Code";
                    Clear(custid);
                    custid := Customer."Web Customer No. 2";
                    isShipingAddr := 1;
                    URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateShippingAddress?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&ShipToAddressCode=' + shiptoaddresscode + '&ShipToName=' + shiptoname + '&ShipToName2=' + shiptoname2 + '&ShipToEmail=' + shiptoemail + '&ShipToPhone=' + shiptophone + '&ShipToFax=' + shiptofax + '&ShipToAddress1=' + shiptoaddress1 + '&ShipToAddress2=' + shiptoaddress2 + '&ShipToCity=' + shiptocity + '&ShipToCountry=' + shiptocountry + '&ShipToCounty=' + shiptocounty + '&ShipToPostCode=' + shiptopostcode + '&WebCustomerNo=' + custid + '&IsShippingAddr=' + format(isShipingAddr);
                    Client.Post(URL, content, ResponseMessage);
                    if (ResponseMessage.HttpStatusCode = 200) then begin
                        ResponseMessage.Content.ReadAs(response);
                        jObject.ReadFrom(response);
                        isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                        if (isSuccess = 'true') then begin
                            //Message('Shipping Address Updated...');
                        end;
                    end;
                    Sleep(2000);
                until ShiptoAddress.Next() = 0;
            end;
        end;
    end;

    procedure UpdateBillingAddress(WebCustomerId: Code[20]; ChannelCode: Code[20])
    var
        Customer: Record Customer;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        Shiptoaddresscode: Text;
        Billtoname: Text;
        Billtoname2: Text;
        Billtoemail: Text;
        Billtophone: Text;
        Billtofax: Text;
        Billtoaddress1: Text;
        Billtoaddress2: Text;
        Billtocity: Text;
        Billtocountry: Text;
        Billtocounty: Text;
        Billtopostcode: Text;
        custid: Text;
        isShipingAddr: Integer;
        TypeHelper: Codeunit "Type Helper";

    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Customer.Reset;
        Customer.SetRange("Web Customer No. 2", WebCustomerId);
        if Customer.FindFirst then begin
            clear(shiptoaddresscode);
            shiptoaddresscode := 'NULL';

            Clear(Billtoname);
            if (Customer.Name = '') then
                Billtoname := '-'
            else
                Billtoname := TypeHelper.UrlEncode(Customer.Name);

            Clear(Billtoname2);
            if (Customer."Name 2" = '') then
                Billtoname2 := '-'
            ELSE
                Billtoname2 := TypeHelper.UrlEncode(Customer."Name 2");

            Clear(Billtoemail);
            if (Customer."E-Mail" = '') then
                Billtoemail := '-'
            else
                Billtoemail := Customer."E-Mail";

            Clear(Billtophone);
            if (Customer."Phone No." = '') then
                Billtophone := '-'
            else
                Billtophone := Customer."Phone No.";

            Clear(Billtofax);
            if (Customer."Fax No." = '') then
                Billtofax := '-'
            else
                Billtofax := Customer."Fax No.";

            Clear(Billtoaddress1);
            if (Customer.Address = '') THEN
                Billtoaddress1 := '-'
            else
                Billtoaddress1 := TypeHelper.UrlEncode(Customer.Address);

            Clear(Billtoaddress2);
            if (Customer."Address 2" = '') then
                Billtoaddress2 := '-'
            else
                Billtoaddress2 := TypeHelper.UrlEncode(Customer."Address 2");

            Clear(Billtocity);
            if (Customer.City = '') then
                Billtocity := '-'
            else
                Billtocity := TypeHelper.UrlEncode(Customer.City);

            Clear(Billtocountry);
            if (Customer."Country/Region Code" = '') then
                Billtocountry := '-'
            else
                Billtocountry := Customer."Country/Region Code";

            Clear(Billtocounty);
            if (Customer.County = '') then
                Billtocounty := '-'
            else
                Billtocounty := TypeHelper.UrlEncode(Customer.County);

            Clear(Billtopostcode);
            if (Customer."Post Code" = '') then
                Billtopostcode := '-'
            ELSE
                Billtopostcode := Customer."Post Code";
            Clear(custid);
            custid := Customer."Web Customer No. 2";
            isShipingAddr := 0;
            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateShippingAddress?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&ShipToAddressCode=' + Shiptoaddresscode + '&ShipToName=' + Billtoname + '&ShipToName2=' + Billtoname2 + '&ShipToEmail=' + Billtoemail + '&ShipToPhone=' + Billtophone + '&ShipToFax=' + Billtofax + '&ShipToAddress1=' + Billtoaddress1 + '&ShipToAddress2=' + Billtoaddress2 + '&ShipToCity=' + Billtocity + '&ShipToCountry=' + Billtocountry + '&ShipToCounty=' + Billtocounty + '&ShipToPostCode=' + Billtopostcode + '&WebCustomerNo=' + custid + '&IsShippingAddr=' + format(isShipingAddr);
            Client.Post(URL, content, ResponseMessage);
            if (ResponseMessage.HttpStatusCode = 200) then begin
                ResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                if (isSuccess = 'true') then begin
                    //Message('Shipping Address Updated...');
                end;
            end;
        end;
    end;

    procedure SendConfirmationEmail(CompanyName: Text[200]; CompanyEmail: Text[50]; CustomerName: Text[100]; CustomerEmail: List of [Text]; Subject: Text[100])  //Shailesh 160621
    var
        UserSetup: Record "User Setup";
        // SMTPMail: Codeunit "SMTP Mail";
        SenderID: Text;
        // SMTPMailSetup: Record "SMTP Mail Setup";
        ReceipiantID: Text;
        Company: Record "Company Information";
        BCCEmail: List of [Text];
        customeremailexist: Text;
    begin
        /*
        foreach customeremailexist in CustomerEmail do
            IF CheckValidEmail(CustomerEmail) = TRUE THEN BEGIN
                IF SMTPMailSetup.GET THEN BEGIN
                    SenderID := SMTPMailSetup."User ID";
                    IF SenderID <> '' THEN BEGIN
                        IF (customeremailexist <> '') THEN
                            Subject := 'Welcome to ' + CompanyName + ' - Account Activated ';
                        SMTPMail.CreateMessage(USERID, SenderID, CustomerEmail, Subject, '', TRUE);
                        Clear(BCCEmail);
                        BCCEmail.Add('shailesh.d@robosol.com');
                        SMTPMail.AddBCC(BCCEmail);
                        SMTPMail.AppendBody('<font face="Calibri" color="black"> Dear ' + CustomerName + '</font>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('We welcome you to ' + CompanyName + '');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('Your acccount is activated. Now you can place the orders.');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('You can now take part in the various services we have to offer you. Some of these services include:');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<b>Permanent Cart</b> - Any products added to your online cart remain there until you remove them, or check them out.');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<b>Address Book</b> - We can now deliver your products to another address other than yours! This is perfect to send birthday gifts direct to the birthday-person themselves.');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<b>Order History</b> - View your history of purchases that you have made with us.');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<b>Products Reviews</b> - Share your opinions on products with our other customers.');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('For help with any of our online services, please email the store-owner : ' + CompanyEmail + '');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<br>');
                        SMTPMail.AppendBody('<b>Note :</b> This email address was provided on our registration page. If you own the email and did not register on our site, please send an email to ' + CompanyEmail + '');
                        IF SMTPMail.Send() THEN;
                    end;
                end;
            end;*/
    end;

    procedure CheckValidEmail(ShipEmail: List of [Text]): Boolean   //Shailesh 160621
    var
        i: Integer;
        NoOfAtSigns: Integer;
        EmailBool: Boolean;
        shipemailexist: text;
    begin
        EmailBool := TRUE;
        foreach shipemailexist in ShipEmail do
            shipemailexist := DELCHR(shipemailexist, '<>');
        IF shipemailexist = '' THEN
            EmailBool := FALSE;
        IF (shipemailexist[1] = '@') OR (shipemailexist[STRLEN(shipemailexist)] = '@') THEN
            EmailBool := FALSE;
        FOR i := 1 TO STRLEN(shipemailexist) DO BEGIN
            IF shipemailexist[i] = '@' THEN
                NoOfAtSigns := NoOfAtSigns + 1
            ELSE
                IF shipemailexist[i] = ' ' THEN
                    EmailBool := FALSE;
        END;
        IF NoOfAtSigns <> 1 THEN
            EmailBool := FALSE;

        EXIT(EmailBool);
    end;

    procedure UpdateCustomerToInactive(CustomerNo: Code[20]) //Shailesh 170621
    var
        Customer: Record Customer;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        custNo: Text;
        blocked: Text;

    begin
        GetCredentials('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Customer.Reset;
        Customer.SetFilter("Web Customer No. 2", '<>%1', '');
        Customer.SetRange("No.", CustomerNo);
        if Customer.FindFirst then begin
            Clear(custNo);
            custNo := Customer."No.";
            Clear(blocked);
            blocked := Format(Customer.Blocked);

            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateCustomerToInactive?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&CustomerNo=' + custNo + '&Blocked=' + blocked;
            Client.Post(URL, content, ResponseMessage);
            if (ResponseMessage.HttpStatusCode = 200) then begin
                ResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                if (isSuccess = 'true') then begin
                    Message('Customer Account Inactivated...');
                end;
            end;
        end;
    end;

    procedure UpdateOrderStatusProcessing(DocumentNo: Code[30]) //Shailesh 170621
    var
        ISH: Record "Interim Sales Header";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        docno: Text;
        orderid: Text;
        navcustid: Text;
        lineaction: Text;
        rejectmsg: Text;

    begin
        ISH.Reset;
        ISH.SetRange("Channel Order ID", DocumentNo);
        ISH.SetRange("Document Type", ISH."Document Type"::Order);
        if ISH.FindFirst then begin
            Clear(docno);
            docno := Format(ISH."No.");
            Clear(orderid);
            orderid := Format(ISH."Channel Order ID");
            Clear(navcustid);
            navcustid := Format(ISH."Sell-to Customer No.");
            Clear(lineaction);
            if (ISH.status = ISH.status::"In Progress") then begin
                lineaction := Format('Accept');
            end
            else
                if (ISH.status = ISH.status::Confirmed) then begin
                    lineaction := Format('Accept');
                end
                ELSE
                    if (ISH.status = ISH.status::Rejected) then begin
                        lineaction := Format('Reject');
                    end
                    else begin
                        lineaction := 'NULL';
                    end;
            Clear(rejectmsg);
            if ISH.Comments <> '' then begin
                rejectmsg := Format(ISH.Comments);
            end
            else begin
                rejectmsg := 'NULL';
            end;


            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateOrderStatusProcessingForRaman?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&DocumentNo=' + docno + '&OrderId=' + orderid + '&NavCustId=' + navcustid + '&LineAction=' + lineaction + '&RejectMessage=' + rejectmsg;
            Client.Post(URL, content, ResponseMessage);
            if (ResponseMessage.HttpStatusCode = 200) then begin
                ResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                if (isSuccess = 'true') then begin
                    //Message('Procssing Status Updated...');
                end;
            end;
        end;
    end;

    procedure UpdateOrderStatusComplete(ChannelCode: Code[20]) //Shailesh 170621
    var
        HandledOrder: Record "Handled Interim Sales Header";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        docno: Text;
        navcustid: Text;
        extdocno: Text;
        lineaction: Text;
        rejectmsg: Text;

    begin
        GetCredentials(ChannelCode);
        HandledOrder.Reset;
        HandledOrder.SetRange("Trade Partner Code", ChannelCode);
        HandledOrder.SetRange(status, HandledOrder.status::Dispatched);
        if HandledOrder.FindSet() then begin
            repeat
                Clear(docno);
                docno := Format(HandledOrder."Destination Doc No.");//Need to check in code
                Clear(navcustid);
                navcustid := Format(HandledOrder."Sell-to Customer No.");
                Clear(extdocno);
                extdocno := Format(HandledOrder."External Document No.");
                lineaction := 'Accept';
                rejectmsg := 'NULL';

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateOrderStatusCompleteForRaman?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&No=' + docno + '&NavCustId=' + navcustid + '&ExternalDocNo=' + extdocno + '&LineAction=' + lineaction + '&RejectMessage=' + rejectmsg;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        //Message('Complete Status Updated...');
                    end;
                end;
            until HandledOrder.Next() = 0;
        end;
    end;

    procedure SyncSalesPrice(ChannelCode: Code[20])
    var
        //SalesPrice: Record "Sales Price";
        ProductId: Text;
        StartDate: Text;
        EndDate: Text;
        Qty: Text;
        Price: Text;
        URL: Text;
        response: Text;
        isSuccess: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        Text001: TextConst ENU = 'Importing Sales Prices In B2B..';
    begin
        /* GetCredentials(ChannelCode);
         Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Sales Price Sync..' + ' #3##########' + 'Please Wait..');
         SalesPrice.Reset();
         SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
         //SalesPrice.SetFilter("Sales Code",''); //Need to check
         if SalesPrice.FindSet() then begin
             NoOfRecs := SalesPrice.Count;
             repeat
                 Clear(headers);
                 Clear(content);
                 Clear(ProductId);
                 Clear(StartDate);
                 Clear(EndDate);
                 Clear(Qty);
                 Clear(Price);

                 headers := Client.DefaultRequestHeaders();
                 content.GetHeaders(headers);
                 headers.Clear();
                 headers.Add('Content-Type', 'application/json');
                 ProgressCount += 1;
                 IF NoOfRecs <= 100 THEN
                     Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                 ELSE
                     IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                         Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                     END;
                 Windows.UPDATE(3, SalesPrice."Item No.");

                 ProductId := Format(SalesPrice."Item No.");
                 if (Format(SalesPrice."Starting Date") <> '') then begin
                     StartDate := FORMAT(SalesPrice."Starting Date", 0, '<Month,2>/<Day,2>/<Year4>');
                 end else begin
                     StartDate := 'NULL';
                 end;
                 if (Format(SalesPrice."Ending Date") <> '') then begin
                     EndDate := FORMAT(SalesPrice."Ending Date", 0, '<Month,2>/<Day,2>/<Year4>');
                 end else begin
                     EndDate := 'NULL';
                 end;
                 Qty := Format(SalesPrice."Minimum Quantity");
                 Price := Format(SalesPrice."Unit Price");

                 URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/SyncSalesPrice?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Product_Id=' + ProductId + '&Start_Date=' + StartDate + '&End_Date=' + EndDate + '&Qty=' + Qty + '&Price=' + Price;
                 Client.Post(URL, content, ResponseMessage);
                 if (ResponseMessage.HttpStatusCode = 200) then begin
                     ResponseMessage.Content.ReadAs(response);
                     jObject.ReadFrom(response);
                     isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                     if (isSuccess = 'true') then begin
                         //Message('Complete Status Updated...');
                     end;
                 end;

             until SalesPrice.Next = 0;
         end;*/
    end;

    procedure SyncCustomerBasedPrice(ChannelCode: Code[20])
    var
        SalesPrice: Record "Sales Price";
        NavCustId: Text;
        ProductId: Text;
        StartDate: Text;
        EndDate: Text;
        MinQty: Text;
        Price: Text;
        SalesType: Text;
        UOMCode: Text;
        CustPriceGroup: Text;
        VariantCode: Text;
        URL: Text;
        response: Text;
        isSuccess: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        Text001: TextConst ENU = 'Sync CustomerBased Prices of Products..';
    begin
        DeleteCustomerBasedPrice(ChannelCode);
        GetCredentials(ChannelCode);
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Product Price Sync..' + ' #3##########' + 'Please Wait..');
        SalesPrice.Reset();
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Customer);
        if SalesPrice.FindSet() then begin
            NoOfRecs := SalesPrice.COUNT;
            repeat
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, SalesPrice."Item No.");

                Clear(headers);
                Clear(content);
                Clear(NavCustId);
                Clear(ProductId);
                Clear(StartDate);
                Clear(EndDate);
                Clear(MinQty);
                Clear(Price);
                Clear(SalesType);
                Clear(UOMCode);
                Clear(CustPriceGroup);
                Clear(VariantCode);
                headers := Client.DefaultRequestHeaders();
                content.GetHeaders(headers);
                headers.Clear();
                headers.Add('Content-Type', 'application/json');

                NavCustId := Format(SalesPrice."Sales Code");
                ProductId := Format(SalesPrice."Item No.");
                if (Format(SalesPrice."Starting Date") <> '') then begin
                    StartDate := FORMAT(SalesPrice."Starting Date", 0, '<Month,2>/<Day,2>/<Year4>');
                end
                else begin
                    StartDate := 'NULL'
                end;
                if (Format(SalesPrice."Ending Date") <> '') then begin
                    EndDate := FORMAT(SalesPrice."Ending Date", 0, '<Month,2>/<Day,2>/<Year4>');
                end
                else begin
                    EndDate := 'NULL'
                end;
                MinQty := Format(SalesPrice."Minimum Quantity");
                Price := Format(SalesPrice."Unit Price");
                SalesType := Format(SalesPrice."Sales Type");
                UOMCode := Format(SalesPrice."Unit of Measure Code");
                CustPriceGroup := 'NULL';
                if (SalesPrice."Variant Code" <> '') then begin
                    VariantCode := Format(SalesPrice."Variant Code");
                end
                else begin
                    VariantCode := 'NULL';
                end;
                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/SyncCustomerPriceGroup?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Nav_Customer_Id=' + NavCustId + '&Product_Id=' + ProductId + '&Start_Date=' + StartDate + '&End_Date=' + EndDate + '&Min_Qty=' + MinQty + '&Price=' + Price + '&Sales_Type=' + SalesType + '&Unit_of_Measure_Code=' + UOMCode + '&Customer_Price_Group=' + CustPriceGroup + '&Variant_Code=' + VariantCode;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        //Message('Complete Status Updated...');
                    end;
                end;
            until SalesPrice.Next = 0;
        end;
    end;

    procedure DeleteCustomerBasedPrice(ChannelCode: Code[20])
    var
        SalesPrice: Record "Sales Price";
        SalesType: Text;
        URL: Text;
        response: Text;
        isSuccess: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
    begin
        GetCredentials(ChannelCode);
        SalesPrice.Reset();
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::Customer);
        if SalesPrice.FindSet() then begin
            repeat
                Clear(headers);
                Clear(content);
                Clear(SalesType);
                headers := Client.DefaultRequestHeaders();
                content.GetHeaders(headers);
                headers.Clear();
                headers.Add('Content-Type', 'application/json');

                SalesType := Format(SalesPrice."Sales Type"::Customer);
                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/DeleteCustomerPrice?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&SalesType=' + SalesType;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        //Message('Complete Status Updated...');
                    end;
                end;
            until SalesPrice.Next = 0;
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

    local procedure GetItemNoFromSKU(ChannelSKU: Text[20]): Text
    var
        ITEM: Record Item;
        ChannelItemListing: Record "Channel Item Listing";
    begin
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel SKU", ChannelSKU);
        IF ChannelItemListing.FINDSET THEN
            EXIT(ChannelItemListing."Item No.");
    End;


    procedure VATSync(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        code1: Code[10];
        VATProdPostGroup: Record "VAT Product Posting Group";
        isSuccess: Text;
        errorMessage: Text;
        Text001: TextConst ENU = 'Sync VAT Product Posting Groups..';
    begin
        GetCredentials('B2B');
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'VAT Sync..' + ' #3##########' + 'Please Wait..');
        VATProdPostGroup.Reset();
        VATProdPostGroup.SetFilter(Code, '<>%1', '');
        if VATProdPostGroup.FindSet() then begin
            NoOfRecs := VATProdPostGroup.Count;
            repeat
                Clear(headers);
                Clear(content);
                headers := Client.DefaultRequestHeaders();
                content.GetHeaders(headers);
                headers.Clear();
                headers.Add('Content-Type', 'application/json');
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, VATProdPostGroup.Code);
                Clear(code1);
                Clear(URL);
                Clear(content);
                Clear(response);
                Clear(jObject);
                code1 := VATProdPostGroup.Code;
                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/ProdVATSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Code=' + code1;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'false') then begin
                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        Message(errorMessage);
                        break;
                    end;
                end;
            until VATProdPostGroup.Next() = 0;
        end;
        Message('Vat Product Posting Group Sync Completed...');
    end;

    procedure GenerateListing(ChannelCode: Code[20])
    var
        ChannelItemListing: Record "Channel Item Listing";
        Item: Record Item;
    begin
        Item.Reset();
        Item.SetRange(Blocked, false);
        if Item.FindSet() then begin
            repeat
                Item.CalcFields(Inventory);
                ChannelItemListing.Reset();
                ChannelItemListing.SetRange("Channel Code", 'B2B');
                ChannelItemListing.SetRange("Item No.", Item."No.");
                IF ChannelItemListing.FindSet() then begin
                    repeat
                        ChannelItemListing.Validate("ASIN No", Item."No.");
                        ChannelItemListing.Validate("Item No.", Item."No.");
                        ChannelItemListing.Validate("Unit of Measure code", Item."Base Unit of Measure");
                        ChannelItemListing.Validate("Channel SKU", Item."No.");
                        ChannelItemListing.Validate("Item Category Code", Item."Item Category Code");
                        ChannelItemListing.Validate(Manufacturer, Item."Manufacturer Code");
                        ChannelItemListing.Validate("Channel Title", Item.Description);
                        ChannelItemListing.Validate("Unit Price", Item."Unit Price");
                        ChannelItemListing.Validate("Channel Unit Price", Item."Unit Price");
                        ChannelItemListing.Validate("Channel Inventory", Item.Inventory);
                        ChannelItemListing.Validate("Channel brand ID", Item."VAT Prod. Posting Group");
                        ChannelItemListing.Modify(true);
                    until ChannelItemListing.Next() = 0;
                end
                else begin
                    ChannelItemListing.INIT;
                    ChannelItemListing.Validate("Channel Code", 'B2B');
                    ChannelItemListing.Validate("Channel Title", Item.Description);
                    ChannelItemListing.Validate("Channel Inventory", Item.Inventory);
                    ChannelItemListing.Validate("Unit of Measure code", Item."Base Unit of Measure");
                    ChannelItemListing.Validate("Unit Price", Item."Unit Price");
                    ChannelItemListing.Validate("Item Category Code", Item."Item Category Code");
                    ChannelItemListing.Validate(Manufacturer, Item."Manufacturer Code");
                    ChannelItemListing.Validate("Channel SKU", Item."No.");
                    ChannelItemListing.Validate("Item No.", Item."No.");
                    ChannelItemListing.Validate("ASIN No", Item."No.");
                    ChannelItemListing.Validate("Created On", CREATEDATETIME(WORKDATE, TIME));
                    ChannelItemListing.Validate("Channel brand ID", Item."VAT Prod. Posting Group");
                    ChannelItemListing.Validate("Price Synced", TRUE);
                    ChannelItemListing.Validate("Inventory Synced", TRUE);
                    ChannelItemListing.Validate(Status, ChannelItemListing.Status::Active);
                    ChannelItemListing.Validate(Action, ChannelItemListing.Action::Update);
                    ChannelItemListing.Validate("Listing Status", ChannelItemListing."Listing Status"::Listed);
                    ChannelItemListing.Insert();
                end;
            until Item.Next() = 0;
        end;
        Message('Channel Item Listing Generated...');
    end;

    procedure BrandSync(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        coode: Code[10];
        isSuccess: Text;
        errorMessage: Text;
        Description: Text;
        ManufacturerCode: Text;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/BrandSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Code=' + coode + '&Description=' + Description + '&ManufacturerCode=' + ManufacturerCode;
        if (Client.Post(URL, content, ResponseMessage)) then begin

            ResponseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);

            isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
            if (isSuccess = 'false') then begin

                errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                Message(errorMessage);
            end;
        end;
        Message('Brand Sync Completed...');
    end;

    procedure DeleteComma(decPAR: Decimal) NumberTxt: Text[20]
    var
    begin
        NumberTxt := FORMAT(decPAR);
        NumberTxt := DELCHR(NumberTxt, '=', ',');
        EXIT(NumberTxt);
    end;

    procedure SyncProdNavToNop(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        CIL: Record "Channel Item Listing";
        isSuccess: Text;
        name: text;
        shortdesc: text;
        fulldesc: text;
        sku: text;
        taxcategoryid: text;
        stockqty: Integer;
        Price: Decimal;
        NAVProdId: Text;
        PackSize: Text;
        uom: Text;
        NavCategoryID: Text;
        NavManufacturerID: Text;
        productToken: JsonToken;
        productHeaderObject: JsonObject;
        i: Integer;
        B2BProdId: Code[50];
        ordersCount: Integer;
        Text001: TextConst ENU = 'Importing Products..';
        ListStatus: Integer;
        packformat: Text;
        navbrandid: Text;
        TradePartner: Record "Trade Partner";
        TypeHelper: Codeunit "Type Helper";
        LayerQuantity: Text;
        PalletQuantity: text;
        CaseBarcode: Text;
        recItem: Record item;
        PurchaseQty: Text;
        EAN: Text;
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Product Sync..' + ' #3##########' + 'Please Wait..');
        CIL.Reset();
        CIL.SETRANGE("Channel Code", ChannelCode);
        //CIL.SETRANGE(Status, CIL.Status::Active);
        // CIL.SETRANGE("Listing Status", CIL."Listing Status"::"Not Listed");
        //CIL.SETRANGE(IsAttributePresent, 'Yes');
        //CIL.SetRange("Item No.", '23358');
        TradePartner.Reset();
        TradePartner.SetRange(Code, ChannelCode);
        if TradePartner.FindFirst() then;
        //CIL.SetFilter("Created On", '%1..%2', TradePartner."Last Product Sync", CurrentDateTime);
        IF CIL.FINDSET THEN BEGIN
            NoOfRecs := CIL.COUNT;
            REPEAT
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, CIL."Channel SKU");
                Clear(name);
                Clear(shortdesc);
                Clear(fulldesc);
                Clear(sku);
                Clear(taxcategoryid);
                Clear(stockqty);
                Clear(Price);
                Clear(NAVProdId);
                Clear(NavCategoryID);
                Clear(NavManufacturerID);
                Clear(PackSize);
                Clear(uom);
                Clear(URL);
                Clear(response);
                Clear(ResponseMessage);
                Clear(content);
                Clear(navbrandid);
                Clear(packformat);
                Clear(LayerQuantity);
                Clear(PalletQuantity);
                Clear(CaseBarcode);
                Clear(PurchaseQty);
                Clear(EAN);
                name := CIL."Channel Title";
                shortdesc := CIL."Channel Title";
                fulldesc := CIL."Channel Title";
                sku := CIL."Channel SKU";
                taxcategoryid := CIL."Channel brand ID";
                stockqty := CIL."Channel Inventory";
                Price := CIL."Unit Price";
                NAVProdId := CIL."Item No.";
                NavCategoryID := CIL."Item Category Code";
                NavManufacturerID := CIL.Manufacturer;
                //PackSize := '';
                uom := CIL."Unit of Measure code";
                navbrandid := '';
                //packformat := '';
                recItem.Get(CIL."Item No.");
                recItem.CalcFields("Qty. on Purch. Order");
                LayerQuantity := 'null';
                PalletQuantity := 'null';
                CaseBarcode := 'null';
                PackSize := 'null';
                packformat := 'null';
                PurchaseQty := 'null';
                EAN := 'null';


                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/ProductSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + TypeHelper.UrlEncode(name) + '&ShortDescription=' + TypeHelper.UrlEncode(shortdesc) + '&FullDescription=' + TypeHelper.UrlEncode(fulldesc) + '&SKU=' + TypeHelper.UrlEncode(sku) + '&TaxCategoryId=' + taxcategoryid + '&StockQuantity=' + Format(stockqty) + '&Price=' + DeleteComma(Price) + '&NavProductid=' + NAVProdId + '&PackSize=' + PackSize + '&UOM=' + uom + '&PackFormat=' + packformat + '&NavBrandId=' + navbrandid + '&NavCategoryId=' + TypeHelper.UrlEncode(NavCategoryID) + '&NavManufacturerId=' + TypeHelper.UrlEncode(NavManufacturerID) + '&LayerQuantity=' + LayerQuantity + '&PalletQuantity=' + PalletQuantity + '&CaseBarcode=' + CaseBarcode + '&PurchaseQty=' + PurchaseQty + '&EAN=' + EAN;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        jArray := GetJsonToken(jObject, 'productList').AsArray();
                        ordersCount := jArray.Count;

                        for i := 0 to ordersCount - 1 do begin
                            jArray.Get(i, productToken);
                            productHeaderObject := productToken.AsObject();
                            Clear(B2BProdId);
                            B2BProdId := GetJsonvalue(productHeaderObject, 'productId').AsText();
                            CIL.RENAME(CIL."Channel Code", CIL."Channel SKU", B2BProdId, CIL."Channel Variant");
                            CIL."Price Synced" := TRUE;
                            CIL."Inventory Synced" := TRUE;
                            CIL."Listing Status" := CIL."Listing Status"::Listed;
                            CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                            CIL.Remarks := '';
                            CIL.Modify();
                        end;
                    end;
                end
                else begin
                    CIL.Remarks := response;
                end;

            UNTIL CIL.NEXT = 0;
        END;

        Windows.CLOSE;

        TradePartner."Last Product Sync" := CurrentDateTime();
        TradePartner.Modify();

        Message('Product Sync Completed...');

    END;

    procedure CalculateWhseShipmentQuantity(var Rec: Record Item): Decimal
    var
        L_WhseShipmentLine: Record "Warehouse Shipment Line";
        L_WhseQty: Decimal;
    begin

        Clear(L_WhseQty);
        L_WhseShipmentLine.Reset();
        L_WhseShipmentLine.SetRange("Item No.", Rec."No.");
        if L_WhseShipmentLine.FindSet() then begin
            repeat
                L_WhseQty += (L_WhseShipmentLine.Quantity - L_WhseShipmentLine."Qty. Shipped");
            until L_WhseShipmentLine.Next() = 0;
        end;
        exit(L_WhseQty);
    end;

    Procedure SyncStockUpdate()
    var
        Item: Record "Item";
        CIL: Record "Channel Item Listing";
    begin
        Item.RESET;
        Item.SETRANGE(Blocked, FALSE);
        IF Item.FINDSET THEN BEGIN
            REPEAT
                CIL.RESET;
                CIL.SETRANGE("Channel Code", 'B2B');
                CIL.SETRANGE("Item No.", Item."No.");
                IF CIL.FINDSET THEN BEGIN
                    REPEAT
                        Item.CALCFIELDS(Inventory, "Qty. on Sales Order");
                        // CIL."Channel Inventory" := Item.Inventory - CalculateWhseShipmentQuantity(Item);
                        CIL."Channel Inventory" := Item.Inventory - Item."Qty. on Sales Order"; //22-03-2022
                        CIL.MODIFY;
                    UNTIL CIL.NEXT = 0;
                END;
            UNTIL Item.NEXT = 0;
        END;
    end;

    Procedure SyncPriceUpdate(ChannelCode: Code[20])
    var
        Item: record "item";
        CIL: Record "Channel Item Listing";
    Begin
        Item.RESET;
        Item.SETRANGE(Blocked, FALSE);
        IF Item.FINDSET THEN BEGIN
            REPEAT
                CIL.RESET;
                CIL.SETRANGE("Item No.", Item."No.");
                CIL.SETRANGE("Channel Code", ChannelCode);
                IF CIL.FINDSET THEN BEGIN
                    REPEAT
                        CIL."Unit Price" := Item."Unit Price";
                        CIL."Channel Unit Price" := Item."Unit Price";
                        CIL.MODIFY;
                    UNTIL CIL.NEXT = 0;
                END;
            UNTIL Item.NEXT = 0;
        END;
    End;

    procedure UpdateInventory(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        CIL: Record "Channel Item Listing";
        isSuccess: Text;
        errorMessage: Text;
        name: text;
        shortdesc: text;
        fulldesc: text;
        sku: text;
        taxcategoryid: text;
        stockqty: Integer;
        Price: Decimal;
        NAVProdId: Text;
        PackSize: Text;
        uom: Text;
        NavCategoryID: Text;
        NavManufacturerID: Text;
        i: Integer;
        Text001: TextConst ENU = 'Updating Products..';
    begin
        SyncStockUpdate();
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        CIL.RESET;
        CIL.SETFILTER("Channel Code", ChannelCode);
        CIL.SETRANGE(Status, CIL.Status::Active);
        CIL.SETRANGE("Listing Status", CIL."Listing Status"::Listed);
        NoOfRecs := CIL.COUNT;
        //CIL.SETFILTER("Inventory Synced", '%1', FALSE);
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Inventory Updating..' + ' #3##########' + 'Please Wait..');
        IF CIL.FINDSET THEN BEGIN
            REPEAT
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, CIL."Channel SKU");

                Clear(stockqty);
                Clear(NAVProdId);
                Clear(NavCategoryID);
                Clear(NavManufacturerID);
                Clear(uom);
                Clear(URL);
                Clear(response);
                Clear(ResponseMessage);
                Clear(content);

                if CIL."Channel Inventory" > 0 then
                    stockqty := CIL."Channel Inventory"
                else
                    stockqty := 0;

                NAVProdId := CIL."Item No.";
                NavCategoryID := CIL."Item Category Code";
                uom := CIL."Unit of Measure code";

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateInventory?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&NavProductid=' + NAVProdId + '&StockQuantity=' + Format(stockqty) + '&NavCategoryId=' + NavCategoryID + '&UOM=' + uom;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        CIL."Inventory Synced" := TRUE;
                        CIL.Action := CIL.Action::Updated;
                        CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    end;
                end
                else begin
                    errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                    CIL.Remarks := errorMessage;
                end;
                CIL.Modify();
            UNTIL CIL.NEXT = 0;
        END;


        Windows.CLOSE;


        if TradePartner.Get(ChannelCode) then;
        Tradepartner."Last Inventory Sync" := CurrentDateTime;
        Tradepartner.Modify();

        Message('Inventory Updated Sucessfully...');

    end;

    Procedure UpdatePrice(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        CIL: Record "Channel Item Listing";
        isSuccess: Text;
        errorMessage: Text;
        name: text;
        shortdesc: text;
        fulldesc: text;
        sku: text;
        taxcategoryid: text;
        stockqty: Integer;
        Price: Decimal;
        NAVProdId: Text;
        PackSize: Text;
        uom: Text;
        NavCategoryID: Text;
        NavManufacturerID: Text;
        Text001: TextConst ENU = 'Updating Products..';
    Begin
        SyncPriceUpdate(ChannelCode);
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        CIL.RESET;
        CIL.SETFILTER("Channel Code", ChannelCode);
        CIL.SETRANGE(Status, CIL.Status::Active);
        CIL.SETRANGE("Listing Status", CIL."Listing Status"::Listed);
        //CIL.SETFILTER("Price Synced", '%1', FALSE);
        NoOfRecs := CIL.COUNT;
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Price Updating..' + ' #3##########' + 'Please Wait..');
        IF CIL.FINDSET THEN BEGIN
            REPEAT
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, CIL."Channel SKU");

                Clear(Price);
                Clear(NAVProdId);
                Clear(NavCategoryID);
                Clear(NavManufacturerID);
                Clear(uom);
                Clear(URL);
                Clear(response);
                Clear(ResponseMessage);
                Clear(content);

                Price := CIL."Unit Price";
                NAVProdId := CIL."Item No.";
                NavCategoryID := CIL."Item Category Code";
                uom := CIL."Unit of Measure code";

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdatePrice?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&NavProductid=' + NAVProdId + '&NavCategoryId=' + NavCategoryID + '&Price=' + DeleteComma(Price) + '&UOM=' + uom;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        CIL."Price Synced" := TRUE;
                        CIL.Action := CIL.Action::Updated;
                        CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                        CIL.MODIFY;
                    end;
                end
                else begin
                    errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                    CIL.Remarks := errorMessage;
                end;
                CIL.Modify();
            UNTIL CIL.NEXT = 0;
        END;

        Windows.CLOSE;
        Message('Price Updated Sucessfully...');

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

    procedure SyncUpdateProdNavToNop(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        CIL: Record "Channel Item Listing";
        isSuccess: Text;
        errorMsg: Text;
        ProductId: Text;
        name: text;
        shortdesc: text;
        fulldesc: text;
        sku: text;
        taxcategoryid: text;
        stockqty: Integer;
        Price: Decimal;
        NAVProdId: Text;
        PackSize: Text;
        uom: Text;
        NavCategoryID: Text;
        NavManufacturerID: Text;
        productToken: JsonToken;
        productHeaderObject: JsonObject;
        i: Integer;
        B2BProdId: Code[50];
        ordersCount: Integer;
        Text001: TextConst ENU = 'Importing Products..';
        ListStatus: Integer;
        packformat: Text;
        navbrandid: Text;
        TradePartner: Record "Trade Partner";
        TypeHelper: Codeunit "Type Helper";
        LayerQuantity: Text;
        PalletQuantity: Text;
        CaseBarcode: Text;
        recItem: Record item;
        PurchaseQty: Text;
        EAN: Text;
        B2Battaributestatus: text;
    begin
        UpdateItemsFromItemtoCIL(ChannelCode);
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Product Sync..' + ' #3##########' + 'Please Wait..');
        CIL.Reset();
        CIL.SETRANGE("Channel Code", ChannelCode);
        //CIL.SETRANGE(IsAttributePresent, 'Yes');
        // CIL.SETRANGE(Status, CIL.Status::Active);
        //CIL.SETRANGE("Listing Status", CIL."Listing Status"::Listed);
        //CIL.SETRANGE("ASIN No", '317');
        IF CIL.FINDSET THEN BEGIN
            NoOfRecs := CIL.COUNT;
            REPEAT
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, CIL."Channel SKU");
                Clear(ProductId);
                Clear(name);
                Clear(shortdesc);
                Clear(fulldesc);
                Clear(sku);
                Clear(taxcategoryid);
                Clear(stockqty);
                Clear(Price);
                Clear(NAVProdId);
                Clear(PackSize);
                Clear(uom);
                Clear(packformat);
                Clear(navbrandid);
                Clear(NavCategoryID);
                Clear(NavManufacturerID);
                Clear(LayerQuantity);
                Clear(PalletQuantity);
                Clear(CaseBarcode);
                Clear(PurchaseQty);
                Clear(EAN);
                Clear(B2Battaributestatus);
                Clear(URL);
                Clear(response);
                Clear(ResponseMessage);
                Clear(content);

                ProductId := CIL."ASIN No";
                name := CIL."Channel Title";
                shortdesc := CIL."Channel Title";
                fulldesc := CIL."Channel Title";
                sku := CIL."Channel SKU";
                taxcategoryid := CIL."Channel brand ID";
                stockqty := CIL."Channel Inventory";
                Price := CIL."Unit Price";
                NAVProdId := CIL."Item No.";
                //PackSize := Format(CIL.Pack);
                uom := CIL."Unit of Measure code";
                //packformat := CIL."Pack Description";
                navbrandid := CIL.Brand;
                NavCategoryID := CIL."Item Category Code";
                NavManufacturerID := CIL.Manufacturer;
                recItem.Get(CIL."Item No.");
                recItem.CalcFields("Qty. on Purch. Order");
                LayerQuantity := 'null';
                PalletQuantity := 'null';
                CaseBarcode := 'null';
                PackSize := 'null';
                packformat := 'null';
                PurchaseQty := 'null';
                EAN := 'null';
                B2Battaributestatus := 'null';
                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateB2BProduct?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&ProductId=' + ProductId + '&Name=' + TypeHelper.UrlEncode(name) + '&ShortDescription=' + TypeHelper.UrlEncode(shortdesc) + '&FullDescription=' + TypeHelper.UrlEncode(fulldesc) + '&SKU=' + sku + '&TaxCategoryId=' + taxcategoryid + '&StockQuantity=' + Format(stockqty) + '&Price=' + Format(DeleteComma(Price)) + '&NavProductid=' + NAVProdId + '&PackSize=' + PackSize + '&UOM=' + uom + '&PackFormat=' + packformat + '&NavBrandId=' + navbrandid + '&NavCategoryId=' + TypeHelper.UrlEncode(NavCategoryID) + '&NavManufacturerId=' + TypeHelper.UrlEncode(NavManufacturerID) + '&LayerQuantity=' + LayerQuantity + '&PalletQuantity=' + PalletQuantity + '&CaseBarcode=' + CaseBarcode + '&PurchaseQty=' + PurchaseQty + '&EAN=' + EAN + '&B2BAttributeStatus=' + B2Battaributestatus;
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin
                        if (B2Battaributestatus = 'Yes') then BEGIN
                            CIL."Listing Status" := CIL."Listing Status"::Listed;
                            CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                            //CIL.IsAttributePresent := 'Yes';
                            CIL.Remarks := '';
                        END;
                        /*
                        ELSE BEGIN
                            CIL."Listing Status" := CIL."Listing Status"::"Not Listed";
                            CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                            CIL.IsAttributePresent := 'Yes';
                            CIL.Remarks := '';
                        END;
                        */

                        CIL.Modify();
                    end
                    else begin
                        errorMsg := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        CIL.Remarks := errorMsg;
                        CIL.Modify();
                    end;
                end
                else begin
                    CIL.Remarks := response;
                end;

            UNTIL CIL.NEXT = 0;
        END;

        Message('Products Updated Completed...');

    END;

    procedure SyncedCustomerBasedItemPrice(ChannelCode: Code[20])
    var
        RecSalePriceHeader: Record "Price List Header";
        RecSalesPriceLine: Record "Price List Line";
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        CIL: Record "Channel Item Listing";
        isSuccess: Text;
        errorMsg: Text;
        ProductID: Code[10];
        Pricecode: Text;
        Price: Decimal;
        Itemqty: Integer;
        NavproductID: text;
        RRPPrice: Decimal;
        Text001: TextConst ENU = 'Sync Sales Prices of Products..';
        RecSalesPrice: Record "Sales Price";
        StartDate: Text;
        EndDate: Text;
        SalesType: Text;
    begin
        ProgressCount := 0;
        DeleteTierPrice(ChannelCode);
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Product Price Sync..' + ' #3##########' + 'Please Wait..');
        CIL.Reset();
        CIL.SETRANGE("Channel Code", ChannelCode);
        //CIL.SETRANGE(IsAttributePresent, 'Yes');
        // CIL.SetRange("Item No.", '10009');
        //CIL.SETRANGE(Status, CIL.Status::Active);
        //CIL.SETRANGE("Listing Status", CIL."Listing Status"::Listed);
        // CIL.SETRANGE("ASIN No", '3010');p
        IF CIL.FINDSET THEN BEGIN
            NoOfRecs := CIL.COUNT;
            REPEAT
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, CIL."Channel SKU");
                RecSalesPrice.Reset();
                RecSalesPrice.SetRange("Sales Type", RecSalesPrice."Sales Type"::"Customer Price Group");
                //RecSalesPrice.SetRange("Sales Code", 'SC2');
                RecSalesPrice.SetRange("Item No.", CIL."Item No.");
                if RecSalesPrice.FindSet() then begin
                    repeat
                        Clear(ProductId);
                        Clear(Pricecode);
                        Clear(Price);
                        Clear(Itemqty);
                        Clear(NavproductID);
                        CLEAR(RRPPrice);
                        Clear(URL);
                        Clear(response);
                        Clear(ResponseMessage);
                        Clear(content);
                        Clear(StartDate);
                        Clear(EndDate);
                        Clear(SalesType);
                        if (CIL."ASIN No" <> '') then begin
                            ProductID := CIL."ASIN No";
                        end
                        else begin
                            ProductID := '0';
                        end;
                        if (RecSalesPrice."Sales Code" <> '') then begin
                            Pricecode := RecSalesPrice."Sales Code";
                        end
                        else begin
                            Pricecode := 'NULL';
                        end;
                        if (Format(RecSalesPrice."Unit Price") <> '') then begin
                            Price := RecSalesPrice."Unit Price";
                        end
                        else begin
                            Price := 0.0;
                        end;
                        if (Format(RecSalesPrice."Minimum Quantity") <> '') then begin
                            Itemqty := RecSalesPrice."Minimum Quantity";
                        end
                        else begin
                            Itemqty := 0;
                        end;
                        if (Format(CIL."Channel SKU") <> '') then begin
                            NavproductID := CIL."Channel SKU";
                        end
                        else begin
                            NavproductID := 'NULL';
                        end;

                        RRPPrice := 0.0;

                        if (RecSalesPrice."Starting Date" <> 0D) then begin
                            StartDate := Format(RecSalesPrice."Starting Date");
                        end
                        else begin
                            StartDate := '-';
                        end;
                        if (RecSalesPrice."Ending Date" <> 0D) then begin
                            EndDate := Format(RecSalesPrice."Ending Date");
                        end
                        else begin
                            EndDate := '-';
                        end;

                        SalesType := Format(RecSalesPrice."Sales Type"::"Customer Price Group");


                        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/syncCustomerbasePricefromBCTOB2B?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&ProductID=' + ProductID + '&Pricecode=' + Pricecode + '&Price=' + Format(Price) + '&Itemqty=' + Format(Itemqty) + '&NavproductID=' + NavproductID + '&RRPPrice=' + Format(RRPPrice) + '&StartDate=' + StartDate + '&EndDate=' + EndDate + '&SalesType=' + SalesType;
                        Client.Post(URL, content, ResponseMessage);
                        if (ResponseMessage.HttpStatusCode = 200) then begin
                            ResponseMessage.Content.ReadAs(response);
                            jObject.ReadFrom(response);
                            isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                            if (isSuccess = 'true') then begin

                            end
                            else begin
                                errorMsg := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                                CIL.Remarks := errorMsg;
                                CIL.Modify();
                            end;
                        end
                        else begin
                            CIL.Remarks := response;
                            CIL.Modify();
                        end;
                    until RecSalesPrice.Next = 0;
                end;

            /*
                            RecSalePriceHeader.Reset();
                            RecSalePriceHeader.SetRange(Status, RecSalePriceHeader.Status::Active);
                            //RecSalePriceHeader.SetRange(Code, 'S00003');
                            if RecSalePriceHeader.FindSet() then begin
                                repeat
                                    RecSalesPriceLine.Reset();
                                    RecSalesPriceLine.SetRange("Price List Code", RecSalePriceHeader.Code);
                                    RecSalesPriceLine.SetRange("Source Type", RecSalePriceHeader."Source Type");
                                    RecSalesPriceLine.SetRange("Asset No.", CIL."Item No.");
                                    RecSalesPriceLine.SetRange("Unit of Measure Code", CIL."Unit of Measure code");
                                    if RecSalesPriceLine.FindSet() then begin
                                        repeat
                                            Clear(ProductId);
                                            Clear(Pricecode);
                                            Clear(Price);
                                            Clear(Itemqty);
                                            Clear(NavproductID);
                                            CLEAR(RRPPrice);
                                            Clear(URL);
                                            Clear(response);
                                            Clear(ResponseMessage);
                                            Clear(content);
                                            if (CIL."ASIN No" <> '') then begin
                                                ProductID := CIL."ASIN No";
                                            end
                                            else begin
                                                ProductID := '0';
                                            end;
                                            if (RecSalesPriceLine."Source No." <> '') then begin
                                                Pricecode := RecSalesPriceLine."Source No.";
                                            end
                                            else begin
                                                Pricecode := 'NULL';
                                            end;
                                            if (Format(RecSalesPriceLine."Unit Price") <> '') then begin
                                                Price := RecSalesPriceLine."Unit Price";
                                            end
                                            else begin
                                                Price := 0.0;
                                            end;
                                            if (Format(RecSalesPriceLine."Minimum Quantity") <> '') then begin
                                                Itemqty := RecSalesPriceLine."Minimum Quantity";
                                            end
                                            else begin
                                                Itemqty := 0;
                                            end;
                                            if (Format(CIL."Channel SKU") <> '') then begin
                                                NavproductID := CIL."Channel SKU";
                                            end
                                            else begin
                                                NavproductID := 'NULL';
                                            end;
                                            if (Format(RecSalesPriceLine."RRP Price") <> '') then begin
                                                RRPPrice := RecSalesPriceLine."RRP Price";
                                            end
                                            else begin
                                                RRPPrice := 0.0;
                                            end;
                                            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/syncCustomerbasePricefromBCTOB2B?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&ProductID=' + ProductID + '&Pricecode=' + Pricecode + '&Price=' + Format(Price) + '&Itemqty=' + Format(Itemqty) + '&NavproductID=' + NavproductID + '&RRPPrice=' + Format(RRPPrice);
                                            Client.Post(URL, content, ResponseMessage);
                                            if (ResponseMessage.HttpStatusCode = 200) then begin
                                                ResponseMessage.Content.ReadAs(response);
                                                jObject.ReadFrom(response);
                                                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                                                if (isSuccess = 'true') then begin

                                                end
                                                else begin
                                                    errorMsg := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                                                    CIL.Remarks := errorMsg;
                                                    CIL.Modify();
                                                end;
                                            end
                                            else begin
                                                CIL.Remarks := response;
                                                CIL.Modify();
                                            end;

                                        until RecSalesPriceLine.Next() = 0;
                                    end
                                until RecSalePriceHeader.Next() = 0;
                            end
            */

            UNTIL CIL.NEXT = 0;
        end;
    end;


    local procedure UpdateItemsFromItemtoCIL(ChannelCode: Code[20])
    var
        recCIL: Record "Channel Item Listing";
        recItem: Record Item;
        P_ItemAttributevaluemap: Record "Item Attribute Value Mapping";
        P_ItemAttributevalue: Record "Item Attribute Value";
        itemattrid: Integer;
        itemattrvalue: text;
    begin
        recCIL.Reset();
        recCIL.SetRange("Channel Code", ChannelCode);
        //recCIL.SetRange("Channel SKU", '21909');
        if recCIL.FindSet() then begin
            repeat
                recItem.Reset();
                recItem.SetRange("No.", recCIL."Item No.");
                if recItem.FindFirst() then begin
                    if (recItem.Blocked = true) then begin
                        recCIL."Listing Status" := recCIL."Listing Status"::"Not Listed";
                        recCIL.Status := recCIL.Status::Inactive;
                        //recCIL.IsAttributePresent := 'No';
                    end
                    else begin
                        Clear(itemattrid);
                        Clear(itemattrvalue);
                        P_ItemAttributevaluemap.Reset();
                        P_ItemAttributevaluemap.SetRange("No.", recItem."No.");
                        P_ItemAttributevaluemap.SetRange("Item Attribute ID", 30);
                        if P_ItemAttributevaluemap.FindFirst() then begin
                            itemattrid := P_ItemAttributevaluemap."Item Attribute Value ID";
                        end;
                        P_ItemAttributevalue.Reset();
                        P_ItemAttributevalue.SetRange(ID, itemattrid);
                        P_ItemAttributevalue.SetRange("Attribute Name", 'B2B');
                        if P_ItemAttributevalue.FindFirst() then begin
                            itemattrvalue := P_ItemAttributevalue.Value;
                        end;
                        if itemattrvalue = 'Yes' THEN
                            recCIL.Status := recCIL.Status::Active
                        else
                            recCIL.Status := recCIL.Status::Inactive;
                        //recCIL.IsAttributePresent := itemattrvalue;
                        recCIL."Unit Price" := recItem."Unit Price";
                        recItem.CalcFields(Inventory);
                        recCIL."Channel Inventory" := recItem.Inventory;
                    end;
                    recCIL.Modify();
                end;
            until recCIL.Next() = 0;
        end;
    end;

    procedure SyncCustomerAddresses(ChannelCode: code[10]; CustomerNo: text)
    var
        recCustomer: Record Customer;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        isSuccess: Text;
        errorMsg: Text;
        NavCustid: Text;
        CustPriceGrp: Text;
        CustCurrencyCode: Text;
        WebCustId: Text;
        Text001: TextConst ENU = 'Importing Address..';
        TypeHelper: Codeunit "Type Helper";
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Address Sync..' + ' #3##########' + 'Please Wait..');
        recCustomer.Reset();

        if CustomerNo <> '' then
            recCustomer.SetRange("No.", CustomerNo);

        //recCustomer.SetRange("No.", 'AAS001');
        //recCustomer.SetFilter("Web Customer No.", '<>%1', '');
        if recCustomer.FindSet() then begin
            repeat
                NoOfRecs := recCustomer.COUNT;
                ProgressCount += 1;
                IF NoOfRecs <= 100 THEN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                ELSE
                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                    END;
                Windows.UPDATE(3, recCustomer."No.");

                Clear(NavCustid);
                Clear(CustPriceGrp);
                Clear(URL);
                Clear(response);
                Clear(ResponseMessage);
                Clear(content);

                NavCustid := recCustomer."No.";
                CustPriceGrp := recCustomer."Customer Price Group";
                CustCurrencyCode := recCustomer."Currency Code";
                if (CustCurrencyCode = '') then begin
                    CustCurrencyCode := 'NULL';
                end;
                if (CustPriceGrp <> '') then begin
                    URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/CustomerWiseBCRolesSyncResponseB2B?ServerName=' + serverName + '&DatabaseName=' + DatabaseName + '&UserName=' + UserName + '&Password=' + Password + '&NavCustomerID=' + TypeHelper.UrlEncode(NavCustid) + '&CustomerPriceGroup=' + CustPriceGrp + '&CustomerCurrencyCode=' + CustCurrencyCode;
                    Client.Post(URL, content, ResponseMessage);
                    if (ResponseMessage.HttpStatusCode = 200) then begin
                        ResponseMessage.Content.ReadAs(response);
                        jObject.ReadFrom(response);
                        isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                        WebCustId := GetJsonvalue(jObject, 'webCustomerID').AsText();
                        if (isSuccess = 'true') then begin
                            if (WebCustId <> '') then begin
                                recCustomer."Web Customer No. 2" := WebCustId;
                                recCustomer.Modify();
                                UpdateBillingAddress(WebCustId, ChannelCode);
                                UpdateShippingAddress(WebCustId, ChannelCode);
                            end;
                        end
                        else begin
                            errorMsg := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                            Message(Format(errorMsg));
                        end;
                    end
                end;
            until recCustomer.Next() = 0;
        end;
    end;

    procedure ProcessB2BOrders(ChannelCode: code[10])
    var
        InterimSalesHeader: Record "Interim Sales Header";
    begin
        if ChannelCode = 'B2B' then begin
            REPORT.RUN(90000, false, FALSE, InterimSalesHeader);
        end;
    end;

    procedure UpdateCurrencyCode(ChannelCode: Code[20])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        isSuccess: Text;
        errorMessage: Text;
        CurrencyCode: Text;
        CurrencyRate: Decimal;
        i: Integer;
        Text001: TextConst ENU = 'Currency Syncing..';
    begin
        GetCredentials(ChannelCode);
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        Currency.RESET;
        Currency.SetRange(Code, 'EUR');
        NoOfRecs := Currency.COUNT;
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Currency Syncing..' + ' #3##########' + 'Please Wait..');
        IF Currency.FINDSET THEN BEGIN

            ProgressCount += 1;
            IF NoOfRecs <= 100 THEN
                Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
            ELSE
                IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                END;
            Windows.UPDATE(3, Currency.Code);
            CurrencyExchangeRate.Reset();
            CurrencyExchangeRate.SetRange("Currency Code", Currency.Code);
            if CurrencyExchangeRate.FindLast then begin
                Clear(CurrencyCode);
                Clear(CurrencyRate);
                Clear(URL);
                Clear(response);
                Clear(ResponseMessage);
                Clear(content);
                //CurrencyExchangeRate.CalcFields("Currency Code");
                CurrencyCode := CurrencyExchangeRate."Currency Code";
                CurrencyRate := CurrencyExchangeRate."Exchange Rate Amount";


                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/syncCurrencyBCTOB2B?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&CurrencyCode=' + CurrencyCode + '&CurrencyRate=' + Format(CurrencyRate);
                Client.Post(URL, content, ResponseMessage);
                if (ResponseMessage.HttpStatusCode = 200) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);
                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin

                    end;
                end
                else begin
                    errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();

                end;
            end;


        END;

        Windows.CLOSE;
    end;

    procedure DeleteTierPrice(ChannelCode: Code[20])
    var
        SalesPrice: Record "Sales Price";
        SalesType: Text;
        URL: Text;
        response: Text;
        isSuccess: Text;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
    begin
        GetCredentials(ChannelCode);
        SalesPrice.Reset();
        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
        if SalesPrice.FindFirst() then begin

            Clear(headers);
            Clear(content);
            Clear(SalesType);
            headers := Client.DefaultRequestHeaders();
            content.GetHeaders(headers);
            headers.Clear();
            headers.Add('Content-Type', 'application/json');

            SalesType := Format(SalesPrice."Sales Type"::"Customer Price Group");
            URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/DeleteTierPrices?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&SalesType=' + SalesType;
            Client.Post(URL, content, ResponseMessage);
            if (ResponseMessage.HttpStatusCode = 200) then begin
                ResponseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                if (isSuccess = 'true') then begin
                    //Message('Complete Status Updated...');
                end;
            end;
        end;
    end;
}