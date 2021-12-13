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
                End;
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

        ShippingPrice: Decimal;

        LastOrderSync: DateTime;
        LastCustomerSyncDate: Text;
        Tradepartner: Record "Trade Partner";
        CUWebOrderMgt: Codeunit "Web Order Mgt";

    procedure GetCustomer(ChannelCode: Code[250])
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
    begin
        GetCreadentils('B2B');

        if Tradepartner.FindFirst() then;
        LastCustomerSyncDate := Format(Tradepartner."Last Customer Sync", 0, '<Year4>-<Month,2>-<Day,2>');

        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(userName, PassWord));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');

        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/GetB2BCustomerAll?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&LastCustomerSyncDate=' + LastCustomerSyncDate;//+ LastCustomerSyncDate//Shreya
        if HttpClient.Get(URL, HttpResponse) then begin

            HttpResponse.Content.ReadAs(responseText);
            jsonMainReq.ReadFrom(responseText);

            customerArray := GetJsonToken(jsonMainReq, 'customerlist').AsArray();
            i := customerArray.Count;
            NoOfRecs := customerArray.Count;

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
                InsertCustomer(ChannelCustomerID, jsonMainReq);

            End;
        End;

        MESSAGE('Customer Sync Completed...');
    End;


    procedure GetOrders(ChannelCode: Code[250])
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

    begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        LastOrderSyncDate := Format(LastOrderSync, 0, '<Year4>-<Month,2>-<Day,2>');
        URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/GetOrdersAll?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&LastOrderSyncDate=' + LastOrderSyncDate; //shreya
        if (client.Get(URL, responseMessage)) then begin
            responseMessage.Content.ReadAs(response);
            jObject.ReadFrom(response);
            jArray := GetJsonToken(jObject, 'orderList').AsArray();
            ordersCount := jArray.Count;
            for i := 0 to ordersCount - 1 do begin
                ShipmnetTracking.DeleteAll();
                PaymentDetails.DeleteAll();
                jArray.Get(i, orderToken);
                orderHeaderObject := orderToken.AsObject();
                WebHeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                ChannelOrderID := GetJsonvalue(WebHeaderObject, 'ChannelOrderID').AsCode();
                InsertInSalesHeader(ChannelOrderID, WebHeaderObject, ChannelCode, InterimSalesHeader);
                InsertInSalesLine(InterimSalesHeader, orderHeaderObject, ShippingPrice, InterimSalesLine);
                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
            end;
        end;
        MESSAGE('Order Sync Completed...');
    end;

    procedure CategorySync(ChannelCode: Code[250])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        name: Code[10];
        ItemCategory: Record "Item Category";
        categoryCount: Integer;
        i: Integer;
        isSuccess: Text;
        errorMessage: Text;
        NavCategoryId: Text;
        NAVCategoryCode: Text;

    begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        if ItemCategory.FindSet() then begin
            repeat
                ItemCategory.RESET;
                name := ItemCategory.Code;
                NAVCategoryCode := ItemCategory.Code;
                ItemCategory.SETRANGE("Parent Category", '');

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/CategorySync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + name + '&NavCategoryId=' + NavCategoryId + '&NAVCategoryCode=' + NAVCategoryCode + '&WebCategory=' + 'true';
                if (Client.Post(URL, content, ResponseMessage)) then begin

                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);

                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'false') then begin

                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        Message(errorMessage);
                    end;
                end;
            until ItemCategory.Next() = 0;
        end;
        Message('Category Sync Successfully...');

    end;

    procedure ManufacutrerSync(ChannelCode: Code[250])
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        URL: Text;
        response: Text;
        name: Code[10];
        description: Text;
        manufacturer: Record Manufacturer;
        isSuccess: Text;
        errorMessage: Text;
    begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        if manufacturer.FindSet() then begin
            repeat
                name := manufacturer.Code;
                description := manufacturer.Name;

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/ManufacturerSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Code=' + name + '&Name=' + description;
                if (Client.Post(URL, content, ResponseMessage)) then begin

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

    procedure GetCreadentils("ChannelCode": Code[20])
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
        orderCreatedOn: Text;
    begin
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := ChannelOrderId;

        If GetJsonvalue(WebHeaderObject, 'PostCode').IsNull = false then begin
            InterimSalesHeader."Post Code" := GetJsonToken(WebHeaderObject, 'PostCode').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'City').IsNull = false then begin
            InterimSalesHeader."City" := GetJsonToken(WebHeaderObject, 'City').AsValue.AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'BuyerName').IsNull = false then begin
            InterimSalesHeader."Buyer Name" := GetJsonToken(WebHeaderObject, 'BuyerName').AsValue.AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoCity').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := GetJsonToken(WebHeaderObject, 'ShiptoCity').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'Address').IsNull = false then begin
            InterimSalesHeader."Address" := GetJsonToken(WebHeaderObject, 'Address').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'Address2').IsNull = false then begin
            InterimSalesHeader."Address 2" := GetJsonToken(WebHeaderObject, 'Address2').AsValue().AsText();
        end;


        if GetJsonvalue(WebHeaderObject, 'ShiptoAddress').IsNull = false then begin
            InterimSalesHeader."Ship-to Address" := GetJsonToken(WebHeaderObject, 'ShiptoAddress').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoAddress2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := GetJsonToken(WebHeaderObject, 'ShiptoAddress2').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'OrderAmount').IsNull = false then begin
            InterimSalesHeader."Order Amount" := GetJsonToken(WebHeaderObject, 'OrderAmount').AsValue().AsDecimal();
        end;

        if GetJsonvalue(WebHeaderObject, 'ShiptoName').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := GetJsonToken(WebHeaderObject, 'ShiptoName').AsValue().AsText();
        end;

        if GetJsonvalue(WebHeaderObject, 'PhoneNumber').IsNull = false then begin
            InterimSalesHeader."Customer Phone Number" := GetJsonToken(WebHeaderObject, 'PhoneNumber').AsValue().AsCode();
        end;

        if GetJsonvalue(WebHeaderObject, 'WebShipmentMethod').IsNull = false then begin
            InterimSalesHeader."Web Shipment Method" := GetJsonToken(WebHeaderObject, 'WebShipmentMethod').AsValue().AsCode();
        end;

        if GetJsonvalue(WebHeaderObject, 'AmountIncludingVAT').IsNull = false then begin
            InterimSalesHeader."Amount Including VAT" := GetJsonToken(WebHeaderObject, 'AmountIncludingVAT').AsValue().AsDecimal();
        end;
        if GetJsonvalue(WebHeaderObject, 'OrderShippingExclTax').IsNull = false then begin
            ShippingPrice := GetJsonvalue(WebHeaderObject, 'OrderShippingExclTax').AsDecimal();
        end;
        //ShippingPrice := 0;

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

                end;

                if GetJsonvalue(LineObject, 'AmountIncludingVAT').IsNull = false then begin
                    InterimSalesLine."Amount Including VAT" := GetJsonvalue(LineObject, 'AmountIncludingVAT').AsDecimal;

                end;

                if GetJsonvalue(LineObject, 'ChannelItemId').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'ChannelItemId').AsText();

                end;

                if GetJsonvalue(LineObject, 'UnitPrice').IsNull = false then begin
                    InterimSalesLine."Unit Price" := GetJsonvalue(LineObject, 'UnitPrice').AsDecimal();

                    InterimSalesLine.Amount := Round(InterimSalesLine."Unit Price" * InterimSalesLine.Quantity);

                    if GetJsonvalue(LineObject, 'Description').IsNull = false then begin
                        InterimSalesLine.Description := Copystr(GetJsonvalue(LineObject, 'Description').AsText(), 1, 100);
                    end;

                    if GetJsonvalue(LineObject, 'ChannelSKU').IsNull = false then begin
                        InterimSalesLine."Channel SKU" := GetJsonvalue(LineObject, 'ChannelSKU').AsCode;
                    end;

                    InterimSalesLine."Shipping Price" := ShippingPrice;
                end;
                InterimSalesLine.Insert();
            end;
        end;
    end;

    Local procedure InsertCustomer(ChanneCustId: Code[20]; CustJsonObject: jsonobject)
    var
        InterimCustomer: Record "Interim Customer";
        cust: Record Customer;
    begin

        IF NOT cust.FINDFIRST THEN BEGIN

            InterimCustomer.INIT;
            InterimCustomer."Channel Code" := 'B2B';  //Shailesh 09032021
            if GetJsonvalue(CustJsonObject, 'No').IsNull = false then begin
                InterimCustomer."No." := GetJsonToken(CustJsonObject, 'No').AsValue().AsCode();
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
        ItemCrossReference: Record "Item Reference";
        ChannelItemListing: Record "Channel Item Listing";
    begin
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel SKU", ChannelSKU);
        IF ChannelItemListing.FINDSET THEN
            EXIT(ChannelItemListing."Item No.");
    End;


    procedure VATSync()
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
    begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');
        VATProdPostGroup.Reset();
        VATProdPostGroup.SetFilter(Code, '<>%1', '');
        if VATProdPostGroup.FindFirst() then begin
            repeat
                code1 := VATProdPostGroup.Code;
                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/ProdVATSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Code=' + code1;
                if (Client.Post(URL, content, ResponseMessage)) then begin

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

    procedure BrandSync(ChannelCode: Code[250])
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
        GetCreadentils('B2B');
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

    procedure SyncProdNavToNop()
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
        Text001: TextConst ENU = 'Import Products..';
        ListStatus: Integer;
    begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        CIL.Reset();
        CIL.SETRANGE("Channel Code", 'B2B');
        CIL.SETRANGE(Status, CIL.Status::Active);
        CIL.SETRANGE("Listing Status", CIL."Listing Status"::"Not Listed");
        NoOfRecs := CIL.COUNT;
        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Product Sync..' + ' #3##########' + 'Please Wait..');
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

                name := CIL."Channel Title";
                shortdesc := CIL."Channel Title";
                fulldesc := CIL."Channel Title";
                sku := CIL."Channel SKU";

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/ProductSync?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + name + '&ShortDescription=' + shortdesc + '&FullDescription=' + fulldesc + '&SKU=' + sku + '&TaxCategoryId=' + taxcategoryid + '&StockQuantity=' + Format(stockqty) + '&Price=' + DeleteComma(Price) + '&NavProductid=' + NAVProdId + '&PackSize=' + PackSize + '&UOM=' + uom + '&PackFormat=&NavBrandId=&NavCategoryId=' + NavCategoryID + '&NavManufacturerId=' + NavManufacturerID + '';
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
        Message('Product Sync Completed...');

    END;

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
                        CIL.MODIFY;
                    UNTIL CIL.NEXT = 0;
                END;
            UNTIL Item.NEXT = 0;
        END;
    end;

    Procedure SyncPriceUpdate()
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
                CIL.SETRANGE("Channel Code", 'B2B');
                IF CIL.FINDSET THEN BEGIN
                    REPEAT
                        CIL.MODIFY;
                    UNTIL CIL.NEXT = 0;
                END;
            UNTIL Item.NEXT = 0;
        END;
    End;

    procedure UpdateInventory()
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
        Text001: TextConst ENU = 'Import Products..';
    begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        CIL.RESET;
        CIL.SETFILTER("Channel Code", 'B2B');
        CIL.SETRANGE(Status, CIL.Status::Active);
        CIL.SETRANGE("Listing Status", CIL."Listing Status"::Listed);
        CIL.SETFILTER("Inventory Synced", '%1', FALSE);

        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Inventory Updating..' + ' #3##########' + 'Please Wait..');
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

                name := CIL."Channel Title";
                shortdesc := CIL."Channel Title";
                fulldesc := CIL."Channel Title";
                sku := CIL."Channel SKU";

                stockqty := CIL."Channel Inventory";
                Price := CIL."Unit Price";
                NAVProdId := CIL."Item No.";

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdateInventory?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&Name=' + name + '&NavProductid=' + NAVProdId + '&StockQuantity=' + Format(stockqty) + '&NavCategoryId=' + NavCategoryID + '&UOM=' + uom + '';
                if (Client.Post(URL, content, ResponseMessage)) then begin

                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);

                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin

                        CIL."Inventory Synced" := TRUE;
                        CIL.Action := CIL.Action::Updated;
                        CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    end
                    else begin
                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        CIL.Remarks := errorMessage;
                    end;
                    CIL.Modify();
                end;
            UNTIL CIL.NEXT = 0;
        END;

        Windows.CLOSE;
        Message('Inventory Updated Sucessfully...');

    end;

    Procedure UpdatePrice()
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
        Text001: TextConst ENU = 'Import Products..';
    Begin
        GetCreadentils('B2B');
        headers := Client.DefaultRequestHeaders();
        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');


        CIL.RESET;
        CIL.SETFILTER("Channel Code", 'B2B');
        CIL.SETRANGE(Status, CIL.Status::Active);
        CIL.SETRANGE("Listing Status", CIL."Listing Status"::Listed);
        CIL.SETFILTER("Price Synced", '%1', FALSE);

        Windows.OPEN(Text001 + ' @1@@@@@@@@@@@@@\' + 'Price Updating..' + ' #3##########' + 'Please Wait..');
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

                name := CIL."Channel Title";
                shortdesc := CIL."Channel Title";
                fulldesc := CIL."Channel Title";
                sku := CIL."Channel SKU";

                stockqty := CIL."Channel Inventory";
                Price := CIL."Unit Price";
                NAVProdId := CIL."Item No.";

                URL := 'http://b2bextensionapi.azurewebsites.net/api/B2B/UpdatePrice?ServerName=' + serverName + '&DatabaseName=' + databaseName + '&UserName=' + userName + '&Password=' + PassWord + '&NavProductid=' + NAVProdId + '&NavCategoryId=' + NavCategoryID + '&Price=' + DeleteComma(Price) + '&UOM=' + uom + '';
                if (Client.Post(URL, content, ResponseMessage)) then begin
                    ResponseMessage.Content.ReadAs(response);
                    jObject.ReadFrom(response);

                    isSuccess := GetJsonvalue(jObject, 'IsSuccess').AsText();
                    if (isSuccess = 'true') then begin

                        CIL."Price Synced" := TRUE;
                        CIL.Action := CIL.Action::Updated;
                        CIL."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                        CIL.MODIFY;
                    end
                    else begin
                        errorMessage := GetJsonvalue(jObject, 'ErrorMessage').AsText();
                        CIL.Remarks := errorMessage;
                    end;
                    CIL.Modify();
                end;
            UNTIL CIL.NEXT = 0;
        END;

        Windows.CLOSE;
        Message('Price Updated Sucessfully...');

    End;
}