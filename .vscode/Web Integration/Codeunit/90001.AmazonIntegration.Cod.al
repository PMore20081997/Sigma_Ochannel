codeunit 90001 "Amazon Integration"
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
                    ListOrders(StartParameter, '');
                End;
        end;
    end;

    procedure ListOrders(ChannelCode: Code[250]; Token: Text);
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        CreatedAfter: Text;
        CreatedBefore: Text;
        UpdateddAfter: Text;
        UpdatedBefore: Text;
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
        existInHandled: Text[250];
        existInIncoming: Boolean;
        num: Integer;
        CreateDatetimeAfetr: Text;
        CreateDatetimeBefore: text;
        hardcodeDate: Text;
        TradePartner: Record "Trade Partner";
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        TokenCount: Integer;
    begin
        GetCreadentils(ChannelCode);
        CreatedAfter := FORMAT(LastOrderSync, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>');//01042020
        CreatedBefore := FORMAT(CurrentDateTime - (10 * 60 * 1000), 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>');//01042020
        ApplicationVersion := '1.0';
        Clear(URL);
        /*  URL := 'http://' + 'webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrdersByFilterTest?AccessKeyId=' + AccessKeyId +
          '&applicationName=' + ApplicationName + '&applicationVersion=' + ApplicationVersion +
          '&marketplaceId=' + MarketPlaceId + '&merchantId=' + MerchantId + '&MWSAuthToken=' + MWSAuthToken +
          '&SecretAccessKey=' + SecretAccessKey + '&ServiceURL=' + ServiceURL +
          '&MarketPlaceIds=' + MarketPlaceIds + '&maxResultsPerPage=' + MaxResultsPerPage +
          '&LastUpdatedAfter=' + UpdateddAfter + '&LastUpdatedBefore=' + UpdatedBefore +
          '&orderStatus=Shipped,Unshipped&fulfillmentChannel=&paymentMethod=&buyerEmail=' +
          '&sellerOrderId=&tfmShipmentStatus=&Token=' + Token;*/
        URL := StrSubstNo('http://webintegrationapi.azurewebsites.net/api/AmazonAPI/GetOrdersByFilterTest?' +
        'AccessKeyId=%1&applicationName=%2&applicationVersion=%3&marketplaceId=%4&merchantId=%5' +
        '&MWSAuthToken=%6&SecretAccessKey=%7&ServiceURL=%8&MarketPlaceIds=%9&maxResultsPerPage=100' +
        '&createdAfter=%10&LastUpdatedAfter=&createdBefore=%11&LastUpdatedBefore=&orderStatus=Shipped,Unshipped&fulfillmentChannel=' +
        '&paymentMethod=&buyerEmail=&sellerOrderId=&tfmShipmentStatus=&Token=%12', AccessKeyId, ApplicationName, ApplicationVersion, MarketPlaceId, MerchantId, MWSAuthToken, SecretAccessKey, ServiceURL, MarketPlaceIds, CreatedAfter, CreatedBefore, Token);

        if Client.Get(URL, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(responseText);
            jObject.ReadFrom(responseText);
            if GetJsonvalue(jObject, 'NextToken').IsNull = false then begin
                Token := GetJsonvalue(jObject, 'NextToken').AsText();
                TokenCount := strlen(Token);
                if TokenCount < 10 then
                    Token := '';
            end
            else
                Token := '';
            jArray := GetJsonToken(jObject, 'orderList').AsArray();
            i := jArray.Count();
            noOfResult := jArray.Count();
            message('No oF Count:%1', Format(noOfResult));
            for i := 0 to noOfResult - 1 do begin
                InterimSalesHeader.DeleteAll();
                InterimSalesLine.DeleteAll();
                ShipmnetTracking.DeleteAll();
                PaymentDetails.DeleteAll();
                jArray.Get(i, orderToken);
                orderHeaderObject := orderToken.AsObject();
                WebHeaderObject := GetJsonToken(orderHeaderObject, 'WebHeader').AsObject();
                InsertInSalesHeader(WebHeaderObject, ChannelCode, InterimSalesHeader);
                InsertInSalesLine(InterimSalesHeader, InterimSalesLine, orderHeaderObject);
                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
            End;
        End;
        if Token <> '' then
            ListOrders(ChannelCode, Token);
        MESSAGE('Order Sync Completed...');
    end;


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



    local procedure InsertInSalesLine(var InterimSalesHeader: Record "Interim Sales Header"; var InterimSalesLine: Record "Interim Sales Line" temporary; jsonMainReq: JsonObject)
    var
        OrderAmount: Decimal;
        LineNo: Integer;
        ShippingPrice: Decimal;
        ItemArray: JsonArray;
        itemCount: Integer;
        k: Integer;
        LineObject: JsonObject;
        WebLineToken: JsonToken;
        ShippingRule: Record "OCHANNEL Shipping Rule";
        CourierIntegration: Codeunit "Courier Integration";
    begin
        ItemArray := GetJsonToken(jsonMainReq, 'webLines').AsArray();

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
                InterimSalesHeader."Shipment Method Code" := ShippingRule."NAV Shipment Method";
                InterimSalesHeader.MODIFY;
            end;
        end;
    End;

    procedure GetAmazonItems(ChannelCode: Code[20])
    var
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
        TradePartner: Record "Trade Partner";
        Count: Integer;
    begin
        if TradePartner.Get(ChannelCode) then;
        AccessKeyId := TradePartner.AccessKeyId;
        SecretAccessKey := TradePartner.SecretAccessKey;
        MerchantId := TradePartner.MerchantId;
        MWSAuthToken := '';
        ServiceURL := TradePartner."Sevice/API URL";
        MarketPlaceId := TradePartner.MarketplaceId;
        ApplicationName := 'Test';
        ApplicationVersion := '1.0';

        URL := 'https://' + 'webintegrationapi.azurewebsites.net/api/AmazonAPI/GetAllProduct?' +
       'accessKeyId=' + AccessKeyId + '&applicationName=Test&applicationVersion=1.0' +
       '&marketplaceId=' + MarketPlaceId + '&merchantId=' + MerchantId + '&MWSAuthToken=' + MWSAuthToken +
       '&secretAccessKey=' + SecretAccessKey + '&serviceURL=' + ServiceURL;

        if (Client.Get(URL, ResponseMessage)) then begin
            ResponseMessage.Content.ReadAs(responseText);
            jObject.ReadFrom(responseText);
            jsonAray := GetJsonToken(jObject, 'productList').AsArray();
            i := jsonAray.Count();
            noOfResults := jsonAray.Count();
            for i := 0 to noOfResults - 1 do begin
                jsonAray.Get(i, productToken);
                ProductObject := productToken.AsObject;
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
                ChannelItemListing.SETRANGE("Channel SKU", GetJsonvalue(ProductObject, 'ChannelSKU').AsCode());

                IF ChannelItemListing.FINDFIRST THEN BEGIN
                    UpdateProductAmazon(FALSE);
                END

                ELSE BEGIN
                    UpdateProductAmazon(TRUE);
                END;
            end;
        end;
        Message('Item sync Completed...');

    end;

    local procedure UpdateProductAmazon(bool: Boolean)
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
        ChannelItemListing."Channel Code" := 'AMAZON';

        if GetJsonvalue(productObject, 'ChannelSKU').IsNull = false then begin
            ChannelItemListing."Channel SKU" := GetJsonToken(productObject, 'ChannelSKU').AsValue().AsCode();
        end;

        if GetJsonvalue(productObject, 'ASINNo').IsNull = false then begin
            ChannelItemListing."ASIN No" := GetJsonToken(productObject, 'ASINNo').AsValue().AsCode();
        end;

        if GetJsonvalue(productObject, 'UnitPrice').IsNull = false then begin
            ChannelItemListing."Unit Price" := GetJsonToken(productObject, 'UnitPrice').AsValue().AsDecimal();
        end;

        if GetJsonvalue(productObject, 'QtyPerUnitofMeasure').IsNull = false then begin
            ChannelItemListing."Qty Per Unit of Measure" := GetJsonToken(productObject, 'QtyPerUnitofMeasure').AsValue().AsDecimal();
        end;

        if GetJsonvalue(productObject, 'itemName').IsNull = false then begin
            ChannelItemListing."Channel Title" := CopyStr(GetJsonToken(productObject, 'itemName').AsValue().AsText(), 1, 50);
        end;



        IF bool then begin
            ChannelItemListing.INSERT(TRUE);
        END

        ELSE BEGIN
            ChannelItemListing.MODIFY(TRUE);
        END
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


    var
        myInt: Integer;
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
        // for Item
        Windows: Dialog;
        NoOfRecs: Integer;
        Text006: Label 'Importing Items to Nav...';
        ProductObject: JsonObject;
        bool: Boolean;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        LastOrderSync: DateTime;
        Token: Text;
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';

}