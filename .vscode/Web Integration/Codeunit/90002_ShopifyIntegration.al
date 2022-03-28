codeunit 90002 "Shopify Integration"
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
                    GetShopifyOrder(StartParameter, '');
                    MESSAGE('Order Sync Completed...');
                End;
            SyncItemLabel:
                Begin
                    GetItems(StartParameter, '');
                End;
            SyncInventoryLabel:
                begin
                    UpdateInventoryShopify(StartParameter);
                end;
            CustomerSyncLabel:
                begin
                    SyncCustomer(StartParameter);
                end;
            SyncPriceLabel:
                begin
                    UpdatePriceShopify(StartParameter);
                end;
        end;
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

    procedure GetShopifyOrder(ChannelCode: Code[20]; NextURL: Text)
    var
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        URL: Text;
        user: text;
        password: text;
        HttpRequest: HttpRequestMessage;
        HttpClient: HttpClient;
        responseText: Text;
        L_LineNo: Integer;
        JsonObject: JsonObject;
        OrderhearerArray: JsonArray;
        i: Integer;
        orderHeareToken: JsonToken;
        ChannelOrderID: Code[20];
        Datefrom: text;
        DateTo: Text;
        TradePartner1: Record "Trade Partner";
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;
        TradePartner: Record "Trade Partner";
        ShippingAddr: Boolean;
        BillingAddr: Boolean;
        custBoolean: Boolean;
        checkChar: Text;
        testid: Code[50];
        index: Integer;
        LinkHeaderBool: Boolean;
        LinkHeaderValue: array[2] of Text;
        LinkHeaderTextValue: Text;
    begin
        GetCredentials(ChannelCode);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Datefrom := FORMAT(LastOrderSync, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');
        DateTo := format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec.>Z');

        //TradePartner1."Sevice/API URL":='https://winter-in-venice-store.myshopify.com/admin/api';
        if NextURL = '' then begin
            URL := StrSubstNo('%1/orders.json?status=any&limit=250&created_at_min="%2"&created_at_max="%3"', ServiceURL, Datefrom, DateTo);
        end;
        //URL := 'https://milroys.myshopify.com/admin/api/2020-07/orders.json';

        if NextURL <> '' then begin
            URL := NextURL;
        end;

        if HttpClient.Get(URL, HttpResponse) then begin
            //Getting Next API Call URL From Response Header ++
            LinkHeaderBool := HttpResponse.Headers.GetValues('Link', LinkHeaderValue);
            if LinkHeaderBool = true then begin
                Clear(LinkHeaderTextValue);
                LinkHeaderTextValue := LinkHeaderValue[1];
            end;
            //Getting Next API Call URL From Response Header--

            HttpResponse.Content.ReadAs(responseText);
            OrderObject.ReadFrom(responseText);
            JsonObjectInArray := GetJsonToken(OrderObject, 'orders').AsArray();
            i := JsonObjectInArray.Count;
            NoOfRecs := JsonObjectInArray.Count;
            for i := 0 to NoOfRecs - 1 do begin
                InterimSalesHeader.DeleteAll();
                InterimSalesLine.DeleteAll();
                ShipmnetTracking.DeleteAll();
                PaymentDetails.DeleteAll();
                Clear(checkChar);
                Clear(ShippingAddr);
                Clear(BillingAddr);
                Clear(custBoolean);
                // If InterimSalesHeader.FindSet then;

                JsonObjectInArray.Get(i, orderHeareToken);
                OrderHeader := orderHeareToken.AsObject();

                checkChar := Format(OrderHeader);
                ShippingAddr := checkChar.Contains('shipping_address');
                BillingAddr := checkChar.Contains('billing_address');

                custBoolean := checkChar.Contains('customer');
                testid := GetJsonvalue(OrderHeader, 'id').AsCode();
                ChannelOrderID := GetJsonvalue(OrderHeader, 'name').AsCode();
                if ShippingAddr = true then begin
                    ShippingAddress := GetJsonToken(OrderHeader, 'shipping_address').AsObject();
                end;

                if BillingAddr = true then begin
                    BillingAddress := GetJsonToken(OrderHeader, 'billing_address').AsObject();
                end;

                if custBoolean = true then begin
                    CustomerDetails := GetJsonToken(OrderHeader, 'customer').AsObject();
                end;

                GetShippingPrice();

                if GetJsonvalue(OrderHeader, 'email').IsNull = false then begin
                    InterimSalesHeader."Email (Location)" := GetJsonToken(OrderHeader, 'email').AsValue.AsText();
                end;

                InsertIntSalesHeader(ChannelOrderID, OrderHeader, ChannelCode, InterimSalesHeader, ShippingAddr, BillingAddr, custBoolean);
                InsertInterimSalesLine(InterimSalesHeader, OrderHeader, InterimSalesLine);
                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
            End;
        end;

        //Code to Get Next URL From Response Header++
        if LinkHeaderTextValue.Contains('"next"') then begin
            if LinkHeaderTextValue.Contains('>; rel="next"') and LinkHeaderTextValue.Contains('<') then begin
                LinkHeaderTextValue := LinkHeaderTextValue.Replace('>; rel="next"', '');
                LinkHeaderTextValue := LinkHeaderTextValue.Replace('<', '');
            end;
            if LinkHeaderTextValue.Contains('>; rel="previous", ') then begin
                index := LinkHeaderTextValue.IndexOf('", ');
                if (index > 0) then begin
                    LinkHeaderTextValue := LinkHeaderTextValue.Substring(index);
                end;
                LinkHeaderTextValue := LinkHeaderTextValue.Replace('", ', '');
            end;
            Clear(NextURL);
            NextURL := LinkHeaderTextValue;
            GetShopifyOrder(ChannelCode, NextURL);
        end;
        //Code to Get Next URL From Response Header--

        TradePartner.Reset();
        TradePartner.SetRange(Code, ChannelCode);
        if TradePartner.FindFirst() then begin
            TradePartner."Last Order Sync" := CurrentDateTime;
            TradePartner.Modify();
        end;
    End;

    procedure GetCredentials("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            AccessKeyId := TradePartner.AccessKeyId;
            SecretAccessKey := TradePartner.SecretAccessKey;
            ServiceURL := TradePartner."Sevice/API URL";
            LastOrderSync := TradePartner."Last Order Sync";
        End;
    End;

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


    local procedure InsertIntSalesHeader(ChannelOrderId: Text; HeaderObject: JsonObject; ChannelCode: Code[20]; var InterimSalesHeader: Record "Interim Sales Header" temporary; ShippingAddr: Boolean; BillingAddr: Boolean; custBoolean: Boolean)
    var
        AddressLenght: Integer;
        BigAddress: Text[100];
        TotalWeight: Decimal;
        CountryCode: Code[20];
        FulfillmentChannel: Text[250];
        TradePartner1: Record "Trade Partner";
        CountyRegionCode: Record "Country/Region";
        CustomerId: Code[30];
        Customer: Record Customer;
    begin
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Channel Order ID" := ChannelOrderId;
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := ChannelOrderId;
        InterimSalesHeader."External Document No." := ChannelOrderId;
        //InterimSalesHeader."Package Tracking No." := ChannelOrderId;

        if BillingAddr = true then begin
            if GetJsonvalue(BillingAddress, 'name').IsNull = false then begin
                InterimSalesHeader."Bill- to Name" := CopyStr(GetJsonToken(BillingAddress, 'name').AsValue().AsText(), 1, 50);
            end;
        end;//Robo

        if GetJsonvalue(HeaderObject, 'total_weight').IsNull = false then begin
            TotalWeight := GetJsonvalue(HeaderObject, 'total_weight').AsDecimal() / 1000;
            InterimSalesHeader."Total Weight" := TotalWeight;
        end;
        if ShippingLinebool = true then begin
            if GetJsonvalue(ShippinglineObject, 'title').IsNull = false then begin
                InterimSalesHeader."Web Shipment Method" := GetJsonToken(ShippinglineObject, 'title').AsValue().AsCode(); // NumOrderId
            end;
        end;

        if GetJsonvalue(HeaderObject, 'created_at').IsNull = false then begin
            InterimSalesHeader."Order Placed At" := GetJsonToken(HeaderObject, 'created_at').AsValue().AsDateTime();
        end;

        if GetJsonvalue(HeaderObject, 'created_at').IsNull = false then begin
            InterimSalesHeader."Document Date" := DT2Date(GetJsonToken(HeaderObject, 'created_at').AsValue().AsDateTime());
        end;


        TradePartner1.Reset();
        if TradePartner1.Get(ChannelCode) then begin
            if TradePartner1."Customer Mapping" = TradePartner1."Customer Mapping"::"Default Customer" then
                InterimSalesHeader."Sell-to Customer No." := TradePartner1."Customer No.";
        end;

        // if custBoolean = true then begin
        //     if GetJsonvalue(CustomerDetails, 'id').IsNull = false then begin
        //         CustomerId := GetJsonToken(CustomerDetails, 'id').AsValue().AsCode();
        //         Customer.Reset();
        //         Customer.SetFilter("Web Customer No. 2", '%1', CustomerId);
        //         if Customer.FindFirst then;
        //         InterimSalesHeader."Sell-to Customer No." := Customer."No.";
        //     end;
        // end;

        if GetJsonvalue(OrderHeader, 'gateway').IsNull = false then begin
            InterimSalesHeader."Payment Method" := GetJsonToken(OrderHeader, 'gateway').AsValue.AsCode();
        end;

        if GetJsonvalue(OrderHeader, 'email').IsNull = false then begin
            InterimSalesHeader."Email (Location)" := GetJsonToken(OrderHeader, 'email').AsValue.AsText();
        end;

        if GetJsonvalue(OrderHeader, 'phone').IsNull = false then begin
            InterimSalesHeader."Ship-to Phone" := GetJsonToken(OrderHeader, 'phone').AsValue().AsCode();
        end;

        if BillingAddr = true then begin
            If GetJsonvalue(BillingAddress, 'country').IsNull = false then begin
                CountryCode := GetJsonvalue(BillingAddress, 'country').AsText();
            end;
        end;

        CountyRegionCode.Reset();
        CountyRegionCode.SetRange(Name, CountryCode);
        if CountyRegionCode.FindFirst() then begin
            InterimSalesHeader."Ship-to Country/Region Code" := CountyRegionCode.Code;
        end;
        if ShippingAddr = true then begin
            If GetJsonvalue(ShippingAddress, 'zip').IsNull = false then begin
                InterimSalesHeader."Post Code" := GetJsonToken(ShippingAddress, 'zip').AsValue().AsText();
            end;
        end;

        if ShippingAddr = true then begin
            If GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
                InterimSalesHeader.City := GetJsonToken(ShippingAddress, 'city').AsValue().AsText();
            end;
        end;

        if ShippingAddr = true then begin
            If GetJsonvalue(ShippingAddress, 'address1').IsNull = false then begin
                AddressLenght := StrLen(GetJsonToken(ShippingAddress, 'address1').AsValue().AsText());
                if AddressLenght > 50 then begin
                    BigAddress := GetJsonToken(ShippingAddress, 'address1').AsValue().AsText();
                    InterimSalesHeader.Address := CopyStr(BigAddress, 1, 50);
                    InterimSalesHeader."Address 2" := CopyStr(BigAddress, 51, 50);
                end else begin
                    InterimSalesHeader.Validate(Address, GetJsonToken(ShippingAddress, 'address1').AsValue().AsText());
                    If GetJsonvalue(ShippingAddress, 'address2').IsNull = false then begin
                        InterimSalesHeader.Validate("Address 2", GetJsonvalue(ShippingAddress, 'address2').AsText());
                    end;
                end;
            end;
        end;

        if GetJsonvalue(OrderHeader, 'email').IsNull = false then begin
            InterimSalesHeader."Buyer Email" := Copystr(GetJsonToken(OrderHeader, 'email').AsValue().AsText(), 1, 50);
        end;
        if ShippingAddr = true then begin
            if GetJsonvalue(ShippingAddress, 'address1').IsNull = false then begin
                InterimSalesHeader."Ship-to Address" := CopyStr(GetJsonToken(ShippingAddress, 'address1').AsValue().AsText(), 1, 50);
            end;

            if GetJsonvalue(ShippingAddress, 'address2').IsNull = false then begin
                InterimSalesHeader."Ship-to Address 2" := CopyStr(GetJsonToken(ShippingAddress, 'address2').AsValue().AsText(), 1, 50);
            end;

            if GetJsonvalue(ShippingAddress, 'city').IsNull = false then begin
                InterimSalesHeader."Ship-to City" := Copystr(GetJsonToken(ShippingAddress, 'city').AsValue().AsText(), 1, 30);
            end;

            if GetJsonvalue(ShippingAddress, 'zip').IsNull = false then begin
                InterimSalesHeader."Ship-to Post Code" := GetJsonToken(ShippingAddress, 'zip').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'name').IsNull = false then begin
                InterimSalesHeader."Ship-to Name" := GetJsonToken(ShippingAddress, 'name').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'phone').IsNull = false then begin
                InterimSalesHeader."Ship-to Phone" := GetJsonToken(ShippingAddress, 'phone').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'country').IsNull = false then begin
                InterimSalesHeader."Ship-to County" := GetJsonToken(ShippingAddress, 'country').AsValue().AsText();
            end;

            if GetJsonvalue(ShippingAddress, 'country_code').IsNull = false then begin
                InterimSalesHeader."Ship-to Country/Region Code" := GetJsonToken(ShippingAddress, 'country_code').AsValue().AsCode();
            end;
        end;
        if GetJsonvalue(OrderHeader, 'total_price').IsNull = false then begin
            InterimSalesHeader.Validate("Order Amount", GetJsonvalue(OrderHeader, 'total_price').AsDecimal());
        end;

        // InterimSalesHeader.VALIDATE("Pickup Date", TODAY + 1);
        // InterimSalesHeader.VALIDATE("Pickup Time", 170000T);
        InterimSalesHeader.VALIDATE("No. Of Parcels", 1);

        InterimSalesHeader.Insert();
    end;


    local procedure InsertInterimSalesLine(var InterimSalesHeader: Record "Interim Sales Header" temporary; jsonMainReq: JsonObject; var InterimSalesLine: Record "Interim Sales Line" temporary)
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
        TotalItemQty: Integer;
    begin
        TotalItemQty := 0;
        ItemArray := GetJsonToken(jsonMainReq, 'line_items').AsArray();
        cnt := ItemArray.Count;
        if cnt > 0 then begin
            P := 0;
            for k := 0 to cnt - 1 do begin
                ItemArray.Get(k, WebLineToken);
                LineObject := WebLineToken.AsObject;
                InterimSalesLine."Document Type" := InterimSalesLine."Document Type"::Order;
                InterimSalesLine."Document No" := InterimSalesHeader."No.";
                InterimSalesLine."Channel Order ID" := InterimSalesHeader."Channel Order ID";
                InterimSalesLine."Line No." := k;
                InterimSalesLine.Type := InterimSalesLine.type::Item;

                if GetJsonvalue(LineObject, 'quantity').IsNull = false then begin
                    InterimSalesLine.Quantity := GetJsonvalue(LineObject, 'quantity').AsDecimal;
                    TotalItemQty := InterimSalesLine.Quantity + TotalItemQty;
                end;

                if GetJsonvalue(LineObject, 'product_id').IsNull = false then begin
                    InterimSalesLine."Channel Item Id" := GetJsonvalue(LineObject, 'product_id').AsText();

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
                InterimSalesLine.Weight := 1;
                InterimSalesLine.Insert();
            End;
        end;
        InterimSalesHeader."No. of Items" := TotalItemQty;
        InterimSalesHeader.Modify();
    end;

    procedure GetItems(ChannelCode: Code[20]; NextURL: Text)
    var
        k: Integer;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpClient: HttpClient;
        Httpresponse: HttpResponseMessage;
        URL: Text;
        variants: JsonArray;
        VariantsToken: JsonToken;
        user: text;
        password: Text;
        PageNoTxt: Text;
        responseText: Text;
        RequestTxt: Text;
        jsonObject: JsonObject;
        Array: JsonArray;
        orderHeareToken: JsonToken;
        i: Integer;
        ItemNo: Code[20];
        ChannelItemListing: Record "Channel Item Listing";
        TradePartner: Record "Trade Partner";
        ItemName: Text;
        ItemDescription: Text;
        unitPrice: Decimal;
        ITEM: Record Item;
        NetWeight: Decimal;
        ItemToken: Text;
        TradePartner1: Record "Trade Partner";
        SKU: Code[50];
        Text007: Label 'Creating products on Shopify from NAV...';
        headerBool: Boolean;
        linkHeaderValue: array[2] of Text;
        linkHeaderText: Text;
        index: Integer;
        portalSku: Code[20];
    begin
        if TradePartner.Get(ChannelCode) then;
        GetCredentials(ChannelCode); //For Credentials
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        if NextURL = '' then begin
            URL := StrSubstNo('%1/products.json?limit=250', TradePartner."Sevice/API URL");
        end;
        if NextURL <> '' then begin
            URL := NextURL;
        end;
        if HttpClient.Get(URL, HttpResponse) then begin
            headerBool := Httpresponse.Headers().GetValues('Link', linkHeaderValue);
            linkHeaderText := linkHeaderValue[1];
            HttpResponse.Content.ReadAs(responseText);
            jsonObject.ReadFrom(responseText);
            Array := GetJsonToken(jsonObject, 'products').AsArray();
            i := Array.Count;
            NoOfRecs := Array.Count;
            for i := 0 to NoOfRecs - 1 do begin

                Array.Get(i, orderHeareToken);
                orderheaderObject := orderHeareToken.AsObject;
                GETSKU();
                portalSku := GetJsonvalue(variantJsonobject, 'sku').AsCode();
                Windows.OPEN(Text006 + ' @1@@@@@@@@@@@@@\' + portalSku + ' #3##########');
                IF bool THEN BEGIN
                    Count += 1;
                    IF NoOfRecs <= 100 THEN
                        Windows.UPDATE(1, (Count / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                            Windows.UPDATE(1, (Count / NoOfRecs * 10000) DIV 1)
                        END;
                    Windows.UPDATE(3, FORMAT(ChannelItemListing."Channel Code"));
                END;
                //need to manage this code 
                // SKU := SKU1;
                //GETImages();
                ChannelItemListing.RESET;
                ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
                ChannelItemListing.SetRange("ASIN No", GetJsonvalue(variantJsonobject, 'product_id').AsCode());
                ChannelItemListing.SETRANGE("Channel SKU", GetJsonvalue(variantJsonobject, 'sku').AsCode());
                IF ChannelItemListing.FINDFIRST THEN BEGIN
                    UpdateProduct(FALSE, ChannelItemListing);
                END
                ELSE BEGIN
                    CreateProduct(true, ChannelCode);
                END;
            end;
        END;

        //Windows.Close();
        //Next Page Code
        if linkHeaderText.Contains('"next"') then begin
            if linkHeaderText.Contains('>; rel="next"') and linkHeaderText.Contains('<') then begin
                linkHeaderText := linkHeaderText.Replace('>; rel="next"', '');
                linkHeaderText := linkHeaderText.Replace('<', '');
            end;
            if linkHeaderText.Contains('>; rel="previous", ') then begin
                index := linkHeaderText.IndexOf('", ');
                if (index > 0) then begin
                    linkHeaderText := linkHeaderText.Substring(index);
                end;
                linkHeaderText := linkHeaderText.Replace('", ', '');
            end;
            NextURL := linkHeaderText;
            GetItems(ChannelCode, NextURL);
        end;

        // ChannelItemListing.RESET;
        // ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        // ChannelItemListing.SETRANGE("Listing Status", ChannelItemListing."Listing Status"::"Not Listed");
        // ChannelItemListing.SETRANGE("ASIN No", '');
        // if ChannelItemListing.FindFirst then begin
        //     repeat

        //         Windows.OPEN(Text007 + ' @1@@@@@@@@@@@@@\' + ChannelItemListing.FieldCaption("Channel SKU") + ' #3##########');
        //         NoOfRecs := ChannelItemListing.Count;
        //         IF bool THEN BEGIN
        //             Count += 1;
        //             IF NoOfRecs <= 100 THEN
        //                 Windows.UPDATE(1, (Count / NoOfRecs * 10000) DIV 1)
        //             ELSE
        //                 IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
        //                     Windows.UPDATE(1, (Count / NoOfRecs * 10000) DIV 1)
        //                 END;
        //             Windows.UPDATE(3, FORMAT(ChannelItemListing."Channel SKU"));
        //         END;

        //         CreateProductShopify(ChannelItemListing);
        //     until ChannelItemListing.Next = 0;
        //     if bool then
        //         Windows.Close();
        // end;


        Message('Item Sync Completed...');
    end;

    local procedure UpdateProduct(bool: Boolean; ChannelItemListing: Record "Channel Item Listing")
    var
        ItemName: Text;
        ItemDescription: Text;
        //ChannelItemListing: Record "Channel Item Listing";
        unitPrice: Decimal;
        ChannelInvquantity: Decimal;
        ChannelInvOldquantity: Decimal;
        InvItemId: BigInteger;
        ITEM: Record 27;
        NetWeight: Decimal;
        ItemSKU: Text;
        imagesArray: JsonArray;
    begin
        //CLEAR(ChannelItemListing);
        ChannelItemListing.VALIDATE("Channel Code", 'SHOPIFY');
        /* if GetJsonvalue(variantJsonobject, 'sku').IsNull = false then begin
             ChannelItemListing."Channel SKU" := GetJsonToken(variantJsonobject, 'sku').AsValue().AsCode();
         end;*/

        if GetJsonvalue(orderheaderObject, 'title').IsNull = false then begin
            ChannelItemListing."Channel Title" := CopyStr(GetJsonToken(orderheaderObject, 'title').AsValue().AsCode(), 1, 50);
        end;

        if GetJsonvalue(orderheaderObject, 'id').IsNull = false then begin
            ChannelItemListing."EAN" := GetJsonToken(orderheaderObject, 'id').AsValue().AsCode();
        end;


        /*if GetJsonvalue(variantJsonobject, 'product_id').IsNull = false then begin
            ChannelItemListing."ASIN No" := CopyStr(GetJsonToken(variantJsonobject, 'product_id').AsValue().AsCode(), 1, 20);
        end;*/

        if GetJsonvalue(variantJsonobject, 'price').IsNull = false then begin
            ChannelItemListing."Unit Price" := GetJsonToken(variantJsonobject, 'price').AsValue().AsDecimal();
        end;

        if GetJsonvalue(variantJsonobject, 'old_inventory_quantity').IsNull = false then begin
            ChannelItemListing."Channel Inventory" := GetJsonToken(variantJsonobject, 'old_inventory_quantity').AsValue().AsInteger();
        end;
        if GetJsonvalue(variantJsonobject, 'inventory_quantity').IsNull = false then begin
            ChannelItemListing."Original Inventory" := GetJsonToken(variantJsonobject, 'inventory_quantity').AsValue().AsDecimal();
        end;

        // if GetJsonvalue(imagesJsonobject, 'src').IsNull = false then begin
        //     ChannelItemListing."Image Url 1" := GetJsonToken(imagesJsonobject, 'src').AsValue().AsText();
        // end;

        ChannelItemListing.VALIDATE("Price Synced", TRUE);
        ChannelItemListing.VALIDATE("Inventory Synced", TRUE);


        ChannelItemListing.MODIFY(TRUE);

    end;

    local procedure CreateProduct(bool: Boolean; ChannelCode: Code[20])
    var
        ItemName: Text;
        ItemDescription: Text;
        ChannelItemListing: Record "Channel Item Listing";
        unitPrice: Decimal;
        ChannelInvquantity: Decimal;
        ChannelInvOldquantity: Decimal;
        InvItemId: BigInteger;
        ITEM: Record Item;
        NetWeight: Decimal;
        ItemSKU: Text;
        imagesArray: JsonArray;
    begin

        CLEAR(ChannelItemListing);
        ChannelItemListing.VALIDATE("Channel Code", ChannelCode);
        if GetJsonvalue(variantJsonobject, 'sku').IsNull = false then begin
            ChannelItemListing."Channel SKU" := GetJsonToken(variantJsonobject, 'sku').AsValue().AsCode();
        end;

        if GetJsonvalue(orderheaderObject, 'title').IsNull = false then begin
            ChannelItemListing."Channel Title" := CopyStr(GetJsonToken(orderheaderObject, 'title').AsValue().AsText(), 1, 250);
        end;

        if GetJsonvalue(orderheaderObject, 'id').IsNull = false then begin
            ChannelItemListing."EAN" := GetJsonToken(orderheaderObject, 'id').AsValue().AsCode();
        end;


        if GetJsonvalue(variantJsonobject, 'product_id').IsNull = false then begin
            ChannelItemListing."ASIN No" := CopyStr(GetJsonToken(variantJsonobject, 'product_id').AsValue().AsCode(), 1, 20);
        end;

        if GetJsonvalue(variantJsonobject, 'price').IsNull = false then begin
            ChannelItemListing."Unit Price" := GetJsonToken(variantJsonobject, 'price').AsValue().AsDecimal();
        end;

        if GetJsonvalue(variantJsonobject, 'old_inventory_quantity').IsNull = false then begin
            ChannelItemListing."Original Inventory" := GetJsonToken(variantJsonobject, 'old_inventory_quantity').AsValue().AsInteger();
        end;

        if GetJsonvalue(variantJsonobject, 'inventory_quantity').IsNull = false then begin
            ChannelItemListing."Channel Inventory" := GetJsonToken(variantJsonobject, 'inventory_quantity').AsValue().AsDecimal();
        end;

        // if GetJsonvalue(imagesJsonobject, 'src').IsNull = false then begin
        //     ChannelItemListing."Image Url 1" := GetJsonToken(imagesJsonobject, 'src').AsValue().AsText();
        // end;

        ChannelItemListing.VALIDATE("Price Synced", TRUE);
        ChannelItemListing.VALIDATE("Inventory Synced", TRUE);


        ChannelItemListing.INSERT(TRUE);

    end;

    procedure UpdateInventoryShopify(ChannelCode: Code[20])
    var
        ChannelItemListing: Record "Channel Item Listing";
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        httpContent: HttpContent;
        TextRequest: Text;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        ProductID: Code[20];
        user: text;
        password: Text;
        available: Integer;
        variantsArray: JsonArray;
        Jsontoken: JsonToken;
        jsonObject: JsonObject;
        Array: JsonArray;
        orderHeareToken: JsonToken;
        i: Integer;
        res: Boolean;
        l: Integer;
        res_getitemid: BigInteger;
        res_locationid: BigInteger;
        TradePartner: Record "Trade Partner";
    begin
        setInventory(ChannelCode);
        GetCredentials(ChannelCode);
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETFILTER("Inventory Synced", '%1', FALSE);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        httpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        l := 0;
        IF ChannelItemListing.FINDSET THEN BEGIN
            REPEAT
                l := l + 1;
                // ProductID := ChannelItemListing.EAN;
                ProductID := ChannelItemListing."ASIN No";
                Windows.OPEN(Text006 + ' @1@@@@@@@@@@@@@\' + ProductID + '-' + format(l) + ' #3##########');
                res_getitemid := GetInventoryItemID(ProductID);
                if (res_getitemid <> 0) then begin
                    res_locationid := GetInventoryLocationID(res_getitemid);
                    if (res_locationid <> 0) then begin
                        Sleep(3000);
                        available := ChannelItemListing."Channel Inventory";
                        TextRequest := StrSubstNo('{"location_id":%1,"inventory_item_id":%2,"available":%3}', res_locationid, res_getitemid, available);
                        httpContent.WriteFrom(TextRequest);
                        HttpHeaders := HttpClient.DefaultRequestHeaders();
                        HttpHeaders.Clear();
                        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
                        HttpContent.GetHeaders(HttpHeaders);
                        HttpHeaders.Clear();
                        HttpHeaders.Add('Content-Type', 'application/json');
                        URL := StrSubstNo('%1/2019-07/inventory_levels/set.json', ServiceURL);
                        if HttpClient.Post(URL, httpContent, HttpResponse) then begin
                            HttpResponse.Content.ReadAs(responseText);
                            if (HttpResponse.HttpStatusCode = 200) then begin
                                ChannelItemListing."Inventory Synced" := TRUE;
                                ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                                ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                                ChannelItemListing.Remarks := 'Inventory updated successfully';
                            end
                            else begin
                                ChannelItemListing.Remarks := responseText;
                            end;
                        END;
                    end
                    else begin
                        ChannelItemListing.Remarks := 'Error in Location ID generation for product ' + ProductID;
                    end;
                end
                else begin
                    ChannelItemListing.Remarks := 'Error in Inventory ID generation for product ' + ProductID;
                end;
                ChannelItemListing.MODIFY;
            UNTIL ChannelItemListing.NEXT = 0;
        END;
        Message('Inventory Update Complete');
    end;

    procedure GetInventoryItemID(Prodid: Code[20]): BigInteger
    var
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        httpContent: HttpContent;
        TextRequest: Text;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        flag: Boolean;
        Jsontoken: JsonToken;
        jsonObject: JsonObject;
        Array: JsonArray;
        orderHeareToken: JsonToken;
        variantsArray: JsonArray;
        inventory_item_id: BigInteger;
        k: Integer;
        Tradepartner: Record "Trade Partner";
    begin
        Sleep(3000);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        httpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        URL := StrSubstNo('%1/2020-07/products/' + Prodid + '.json', ServiceURL);
        if HttpClient.Get(URL, HttpResponse) then begin
            HttpResponse.Content.ReadAs(responseText);
            if (HttpResponse.HttpStatusCode = 200) then begin
                jsonObject.ReadFrom(responseText);
                jsonObject := GetJsonToken(jsonObject, 'product').AsObject();
                orderheaderObject := jsonObject;
                variantsArray := GetJsonToken(orderheaderObject, 'variants').AsArray();
                k := variantsArray.Count;
                for k := 0 to k do begin
                    variantsArray.Get(k, Jsontoken);
                    variantJsonobject := Jsontoken.AsObject();
                    inventory_item_id := GetJsonvalue(variantJsonobject, 'inventory_item_id').AsBigInteger();
                end;
            end
            else begin

                inventory_item_id := 0;
            end;
        end;
        exit(inventory_item_id);

    end;

    procedure GetInventoryLocationID(inventory_item_id: BigInteger): BigInteger
    var
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        httpContent: HttpContent;
        TextRequest: Text;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        flag: Boolean;
        Jsontoken: JsonToken;
        jsonObject: JsonObject;
        Array: JsonArray;
        orderHeareToken: JsonToken;
        variantsArray: JsonArray;
        Location_ID: BigInteger;
        i: Integer;
        Tradepartner: Record "Trade Partner";
    BEGIN
        Sleep(3000);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        httpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        URL := StrSubstNo('%1/2019-07/inventory_levels.json?inventory_item_ids=' + FORMAT(inventory_item_id), ServiceURL);
        if HttpClient.Get(URL, HttpResponse) then begin
            HttpResponse.Content.ReadAs(responseText);
            if (HttpResponse.HttpStatusCode = 200) then begin
                jsonObject.ReadFrom(responseText);
                Array := GetJsonToken(jsonObject, 'inventory_levels').AsArray();
                for i := 0 to Array.Count - 1 do begin
                    Array.Get(i, orderHeareToken);
                    orderheaderObject := orderHeareToken.AsObject;
                    Location_ID := GetJsonvalue(orderheaderObject, 'location_id').AsBigInteger();
                end;
            end
            else begin
                Location_ID := 0;
            end;
        end;
        exit(Location_ID);
    END;

    local procedure GETImages()
    var
        imagesArray: JsonArray;
        k: Integer;
        Jsontoken: JsonToken;
    begin
        imagesArray := GetJsonToken(orderheaderObject, 'images').AsArray();
        k := imagesArray.Count;
        if (k > 0) then begin
            for k := 0 to k do begin
                imagesArray.Get(k, Jsontoken);
                imagesJsonobject := Jsontoken.AsObject();
                //SKU1 := GetJsonvalue(variantJsonobject, 'sku').AsCode();
            end;
        end;
    end;

    local procedure GETSKU()
    var
        variantsArray: JsonArray;
        k: Integer;
        Jsontoken: JsonToken;
    begin
        variantsArray := GetJsonToken(orderheaderObject, 'variants').AsArray();
        k := variantsArray.Count;
        for k := 0 to k do begin
            variantsArray.Get(k, Jsontoken);
            variantJsonobject := Jsontoken.AsObject();
            SKU1 := GetJsonvalue(variantJsonobject, 'sku').AsCode();
        end;
    end;

    local procedure GetShippingPrice()
    var
        variantsArray: JsonArray;
        k: Integer;
        Jsontoken: JsonToken;
        Shippingtitle: text;
        CheckChar: Text;

    begin
        Shippingline := GetJsonToken(OrderHeader, 'shipping_lines').AsArray();//Rohit
        k := Shippingline.Count;
        if (k = 1) then begin
            for k := 0 to k do begin
                Shippingline.Get(0, Jsontoken);
                ShippinglineObject := Jsontoken.AsObject();
                CheckChar := Format(ShippinglineObject);
                ShippingLinebool := CheckChar.Contains('title');
                if ShippingLinebool = true then begin
                    Shippingtitle := GetJsonvalue(ShippinglineObject, 'title').Astext();
                end;
            end;
        end;
    end;

    procedure CreateProductShopify(RecChannelItemListing: Record "Channel Item Listing")
    var
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        httpContent: HttpContent;
        TextRequest: Text;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        variantsArray: JsonArray;
        Jsontoken: JsonToken;
        jsonObject: JsonObject;
        Array: JsonArray;
        Title: Text[50];
        BodyHtml: Text[60];
        Vendor: Text[50];
        Price: Decimal;
        SKU: Text[10];
        Quantity: Decimal;
        ImgSrc: Text[250];
        i: Integer;
        orderHeareToken: JsonToken;
        ProductId: Code[20];
        ProductVariantObject: JsonObject;
        ProductObject: JsonObject;
    begin

        GetCredentials(RecChannelItemListing."Channel Code");
        Clear(Title);
        Clear(BodyHtml);
        Clear(Vendor);
        Clear(Price);
        Clear(SKU);
        Clear(Quantity);
        Clear(ImgSrc);
        Clear(TextRequest);
        Title := CopyStr(RecChannelItemListing."Channel Title", 1, 50);
        BodyHtml := CopyStr(RecChannelItemListing."Channel Description", 1, 60);
        Vendor := 'Milroys';
        Price := RecChannelItemListing."Unit Price";
        SKU := RecChannelItemListing."Channel SKU";
        Quantity := RecChannelItemListing."Channel Inventory";
        ImgSrc := RecChannelItemListing."Image Url 1";
        TextRequest := StrSubstNo('{"product":{"title":"%1","body_html":"%2","vendor":"%3","variants":[{"price":"%4","sku":"%5","inventory_quantity":"%6","inventoryItem": {"tracked": true,"inventory_levels":{"location_id":51971522721}}}],"images":[{"src":"%7"}]}}', Title, BodyHtml, Vendor, Price, SKU, Quantity, ImgSrc);
        httpContent.WriteFrom(TextRequest);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'application/json');
        URL := StrSubstNo('%1/2021-01/products.json', ServiceURL);
        if HttpClient.Post(URL, httpContent, HttpResponse) then begin
            HttpResponse.Content.ReadAs(responseText);
            if (HttpResponse.HttpStatusCode = 201) then begin
                jsonObject.ReadFrom(responseText);

                ProductObject := GetJsonToken(jsonObject, 'product').AsObject();
                Array := GetJsonToken(ProductObject, 'variants').AsArray();

                //Array := GetJsonToken(jsonObject, 'variants').AsArray();
                NoOfRecs := Array.Count;
                for i := 0 to NoOfRecs - 1 do begin
                    Array.Get(i, orderHeareToken);
                    ProductVariantObject := orderHeareToken.AsObject;
                    if GetJsonvalue(ProductVariantObject, 'product_id').IsNull = false then begin
                        ProductId := CopyStr(GetJsonToken(ProductVariantObject, 'product_id').AsValue().AsCode(), 1, 20);
                    end;
                end;
                RecChannelItemListing.RENAME(RecChannelItemListing."Channel Code", RecChannelItemListing."Channel SKU", ProductId, RecChannelItemListing."Channel Variant");
                RecChannelItemListing."Listing Status" := RecChannelItemListing."Listing Status"::Listed;
                RecChannelItemListing.Action := RecChannelItemListing.Action::Create;
                RecChannelItemListing.Status := RecChannelItemListing.Status::Active;
                RecChannelItemListing."Created On" := CREATEDATETIME(WORKDATE, TIME);
            end;

        end
        else begin
            RecChannelItemListing.Remarks := responseText;
        end;
        RecChannelItemListing.Modify();
    END;

    procedure SyncCustomer(ChannelCode: Code[20]) //Shailesh 08032021
    var
        k: Integer;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpClient: HttpClient;
        Httpresponse: HttpResponseMessage;
        responseText: Text;
        jsonObjet: JsonObject;
        Array: JsonArray;
        AddressArray: JsonArray;
        i: Integer;
        customerToken: JsonToken;
        URL: Text;
        TradePartner: Record "Trade Partner";
        InterimCustomer: Record "Interim Customer";
        Customer: Record Customer;
        j: Integer;
        NoOfAddRecs: Integer;
        addressToken: JsonToken;
        HandledCustomer: Record "Handled Customer";

    begin
        if TradePartner.Get(ChannelCode) then;
        GetCredentials(ChannelCode);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        URL := 'https://2f973f9fb3fb5f7b51984e59bc2ffad2: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@milroys.myshopify.com/admin/api/2021-01/customers.json';
        if HttpClient.Get(URL, Httpresponse) then begin
            Httpresponse.Content.ReadAs(responseText);
            Windows.Open(Text006 + ' @1@@@@@@@@@@@@@\' + InterimCustomer.FieldCaption("No.") + ' #3##########');
            jsonObjet.ReadFrom(responseText);
            Array := GetJsonToken(jsonObjet, 'customers').AsArray();
            i := Array.Count;
            NoOfRecs := Array.Count;
            for i := 0 to NoOfRecs - 1 do begin
                Array.Get(i, customerToken);
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
                InterimCustomer.SetRange("No.", GetJsonvalue(customerHeaderObject, 'id').AsCode());
                if not InterimCustomer.FindFirst then begin
                    HandledCustomer.Reset;
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
                            InterimCustomer.Validate(Name, GetJsonvalue(customerHeaderObject, 'first_name').AsText());
                        end;
                        if GetJsonvalue(customerHeaderObject, 'phone').IsNull = false then begin
                            InterimCustomer.Validate("Phone No", GetJsonvalue(customerHeaderObject, 'phone').AsText());
                        end;

                        AddressArray := GetJsonToken(customerHeaderObject, 'addresses').AsArray();
                        j := AddressArray.Count;
                        NoOfAddRecs := AddressArray.Count;
                        if NoOfAddRecs <> 0 then begin

                            for j := 0 to NoOfAddRecs - 1 do begin
                                AddressArray.Get(j, addressToken);
                                addressHeaderObject := addressToken.AsObject;

                                if GetJsonvalue(addressHeaderObject, 'company').IsNull = false then begin
                                    InterimCustomer.Validate("Company Name", GetJsonvalue(addressHeaderObject, 'company').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'address1').IsNull = false then begin
                                    InterimCustomer.Validate(Address, GetJsonvalue(addressHeaderObject, 'address1').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'address2').IsNull = false then begin
                                    InterimCustomer.Validate("Address 2", GetJsonvalue(addressHeaderObject, 'address2').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'city').IsNull = false then begin
                                    InterimCustomer.Validate(City, GetJsonvalue(addressHeaderObject, 'city').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'country_code').IsNull = false then begin
                                    InterimCustomer.Validate(Country, GetJsonvalue(addressHeaderObject, 'country_code').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'country_name').IsNull = false then begin
                                    InterimCustomer.Validate("Country Name", GetJsonvalue(addressHeaderObject, 'country_name').AsText());
                                end;

                                if GetJsonvalue(addressHeaderObject, 'zip').IsNull = false then begin
                                    InterimCustomer.Validate("Post Code", GetJsonvalue(addressHeaderObject, 'zip').AsText());
                                end;


                                if GetJsonvalue(addressHeaderObject, 'address1').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Address", GetJsonvalue(addressHeaderObject, 'address1').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'address2').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Address 2", GetJsonvalue(addressHeaderObject, 'address2').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'city').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping City", GetJsonvalue(addressHeaderObject, 'city').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'country_code').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Country", GetJsonvalue(addressHeaderObject, 'country_code').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'country_name').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Country Name", GetJsonvalue(addressHeaderObject, 'country_name').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'zip').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Post Code", GetJsonvalue(addressHeaderObject, 'zip').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'phone').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Phone No.", GetJsonvalue(addressHeaderObject, 'phone').AsText());
                                end;
                                if GetJsonvalue(addressHeaderObject, 'name').IsNull = false then begin
                                    InterimCustomer.Validate("Shipping Contact", GetJsonvalue(addressHeaderObject, 'name').AsText());
                                end;
                            end;
                        end;
                        InterimCustomer.Insert;
                    end;

                end;

            end;
        end;
        Message('Customer Sync Completed...');
    end;

    procedure UpdatePriceShopify(ChannelCode: Code[20])
    var
        ChannelItemListing: Record "Channel Item Listing";
        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        httpContent: HttpContent;
        TextRequest: Text;
        URL: Text;
        HttpResponse: HttpResponseMessage;
        responseText: Text;
        ProductID: Code[20];
        user: text;
        password: Text;
        variantsArray: JsonArray;
        Jsontoken: JsonToken;
        jsonObject: JsonObject;
        Array: JsonArray;
        orderHeareToken: JsonToken;
        res: Boolean;
        l: Integer;
        ProductPrice: Decimal;
        TradePartner: Record "Trade Partner";
        Text007: Label 'Updating Price in NAV...';
    begin
        GetCredentials(ChannelCode);

        l := 0;
        ChannelItemListing.RESET;
        ChannelItemListing.SETRANGE("Channel Code", ChannelCode);
        ChannelItemListing.SETRANGE("Listing Status", ChannelItemListing."Listing Status"::Listed);
        ChannelItemListing.SetFilter("Price Synced", '%1', false);
        IF ChannelItemListing.FINDSET THEN BEGIN
            REPEAT
                l := l + 1;
                Clear(httpContent);
                Clear(HttpClient);
                Clear(HttpHeaders);
                Clear(HttpResponse);
                Clear(responseText);
                Clear(URL);
                Clear(ProductID);
                Clear(ProductPrice);
                ProductID := ChannelItemListing."ASIN No";
                ProductPrice := ChannelItemListing."Unit Price";
                Windows.OPEN(Text007 + ' @1@@@@@@@@@@@@@\' + ProductID + '-' + format(l) + ' #3##########');
                TextRequest := StrSubstNo('{"product":{"id":%1,"variants":[{"price":"%2"}]}}', ProductID, ProductPrice);
                httpContent.WriteFrom(TextRequest);
                HttpHeaders := HttpClient.DefaultRequestHeaders();
                HttpHeaders.Add('Authorization', CreateBasicAuth(AccessKeyId, SecretAccessKey));
                httpContent.GetHeaders(HttpHeaders);
                HttpHeaders.Clear();
                HttpHeaders.Add('Content-Type', 'application/json');
                URL := StrSubstNo('%1/2021-01/products/' + ProductID + '.json', ServiceURL);
                if HttpClient.Put(URL, httpContent, HttpResponse) then begin
                    HttpResponse.Content.ReadAs(responseText);
                    if (HttpResponse.HttpStatusCode = 200) then begin
                        ChannelItemListing."Price Synced" := TRUE;
                        ChannelItemListing.Action := ChannelItemListing.Action::Updated;
                        ChannelItemListing."Modified On" := CREATEDATETIME(WORKDATE, TIME);
                    end
                    else begin
                        ChannelItemListing.Remarks := copystr(responseText, 1, 100);
                    end;
                END;
                ChannelItemListing.MODIFY;
            UNTIL ChannelItemListing.NEXT = 0;
        END;
        Message('Price Updated Sucessfully');
    end;

    local procedure setInventory(ChannelCode: Code[20])
    var
        CIL: Record "Channel Item Listing";
        Items: Record Item;
        ChannelInventory: Integer;
    begin
        CIL.RESET;
        CIL.SETRANGE("Channel Code", ChannelCode);
        IF CIL.FINDSET THEN BEGIN
            REPEAT
                if CIL."Item No." = '' then begin
                    CIL."Channel Inventory" := 0;
                    CIL.Modify();
                end
                else begin
                    Clear(ChannelInventory);
                    Items.Reset();
                    Items.SetRange("No.", CIL."Item No.");
                    if Items.FindFirst() then begin
                        ChannelInventory := CIL."Channel Inventory";
                        Items.CalcFields(Inventory, "Qty. on Sales Order");
                        CIL."Channel Inventory" := Items.Inventory - Items."Qty. on Sales Order";
                        if CIL."Channel Inventory" < 0 then
                            CIL.Validate("Channel Inventory", 0);
                        CIL.Modify();
                        IF ChannelInventory <> CIL."Channel Inventory" THEN begin
                            CIL."Inventory Synced" := false;
                            CIL.Modify();
                        end;
                    end;
                end;

            UNTIL CIL.NEXT = 0;
        END;
    end;

    var

        ShippingLinebool: Boolean;//Rohit
        myInt: Integer;
        AccessKeyId: Text;
        SecretAccessKey: text;
        OrderObject: JsonObject;
        JsonObjectInArray: JsonArray;
        NoOfRecs: Integer;
        ShippingAddress: JsonObject;
        BillingAddress: JsonObject;
        OrderHeader: JsonObject;
        CustomerDetails: JsonObject;
        ShippinglineObject: JsonObject;

        ServiceURL: Text;

        LastOrderSync: DateTime;
        //for Product
        variantJsonobject: JsonObject;
        Windows: Dialog;
        Text006: Label 'Importing Items to Nav...';
        orderheaderObject: JsonObject;
        customerHeaderObject: JsonObject;
        customerJsonObject: JsonObject;
        addressHeaderObject: JsonObject;
        bool: Boolean;
        Count: Integer;
        SKU1: Code[50];
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        Shippingline: JsonArray;
        StartParameter: Text;
        RunType: Text;

        SyncOrderLabel: Label 'SyncOrder';
        SyncItemLabel: Label 'SyncItem';
        SyncInventoryLabel: Label 'UpdateInventory';
        imagesJsonobject: JsonObject;
        CustomerSyncLabel: Label 'CustomerSync';
        SyncPriceLabel: Label 'UpdatePrice';

}