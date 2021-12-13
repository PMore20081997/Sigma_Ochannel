codeunit 90011 "Wowcher Integration"
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
                    GetOrder(StartParameter);
                End;
        end;
    end;
    //Procedure to get the Credentials from Trade Partner for Particular Channel Code
    procedure GetCredentials("ChannelCode": Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            userId := TradePartner.AccessKeyId;
            password := TradePartner.SecretAccessKey;
            Service_URL := TradePartner."Sevice/API URL";
            deal_id := '';
            per_page := '100';
            G_Status := 'redeemed';
        end;
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
        exit(StrSubstNo('%1', Base64Convert.ToBase64(InStrm)));
    end;

    procedure GetOrder(ChannelCode: Code[10])
    var

        HttpHeaders: HttpHeaders;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        URL: Text;
        UserName_Password: text;
        responseText: Text;

        OrderObject: JsonObject;
        OrderMainObject: JsonObject;
        WebHeaderObject: JsonObject;
        OrderArray: JsonArray;
        Arraycount: Integer;
        i: Integer;
        OrderToken: JsonToken;
        current_page: Integer;
        j: Integer;

        TradePartner1: Record "Trade Partner";
        InterimSalesLine: Record "Interim Sales Line" temporary;
        InterimSalesHeader: Record "Interim Sales Header" temporary;
        ShipmnetTracking: Record "Shipment Tracking" temporary;
        PaymentDetails: Record "Channel Media" temporary;

    begin
        current_page := 1;
        GetCredentials(ChannelCode);
        UserName_Password := CreateBasicAuth(userId, password);
        if current_page <> last_page then begin
            repeat
                Clear(URL);
                URL := Service_URL + 'orders?' + 'deal_id=' + deal_id + '&page=' + format(current_page) + '&per_page=100' + '&Status=' + G_Status;
                // URL := 'https://api.redemption.wowcher.co.uk/v1/orders?deal_id=&page=1&per_page=100&Status=redeemed';
                HttpClient.Clear();
                HttpClient.DefaultRequestHeaders().TryAddWithoutValidation('Authorization', UserName_Password);
                if HttpClient.Get(URL, HttpResponse) then begin
                    if not HttpResponse.IsSuccessStatusCode then
                        Error(HttpResponse.ReasonPhrase);
                    HttpResponse.Content.ReadAs(responseText);
                end;
                OrderObject.ReadFrom(responseText);
                OrderMainObject := GetJsonToken(OrderObject, 'data').AsObject();
                last_page := GetJsonValue(OrderMainObject, 'last_page').AsInteger();
                OrderArray := GetJsonToken(OrderMainObject, 'data').AsArray();
                // i := OrderArray.Count;
                for i := 0 to OrderArray.Count - 1 do begin
                    InterimSalesHeader.DeleteAll();
                    InterimSalesLine.DeleteAll();
                    ShipmnetTracking.DeleteAll();
                    PaymentDetails.DeleteAll();
                    OrderArray.Get(i, OrderToken);
                    WebHeaderObject := OrderToken.AsObject();

                    //ChannelOrderID := GetJsonValue(WebHeaderObject, 'id').AsCode();
                    //ProgressCount += 1;

                    InsertInSalesHeader(WebHeaderObject, ChannelCode, InterimSalesHeader);
                    InsertInSalesLine(WebHeaderObject, InterimSalesHeader, InterimSalesLine);
                    CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);
                end;
                current_page := current_page + 1;
            until current_page > last_page;
        end;
        MESSAGE('Order Sync Completed...');
    end;

    //Interim Sales Header
    local procedure InsertInSalesHeader(WebHeaderObject: JsonObject; ChannelCode: Code[20]; var InterimSalesHeader: Record "Interim Sales Header" temporary)
    var
        First_Name: Text;
        Last_Name: Text;
        L_DocumentDate: Text;
    begin
        InterimSalesHeader."Trade Partner Code" := ChannelCode;
        InterimSalesHeader."Channel Order ID" := GetJsonValue(WebHeaderObject, 'id').AsCode();
        InterimSalesHeader."Document Type" := InterimSalesHeader."Document Type"::Order;
        InterimSalesHeader."No." := GetJsonValue(WebHeaderObject, 'id').AsCode();

        if GetJsonValue(WebHeaderObject, 'deal_id').IsNull = false then begin
            InterimSalesHeader."Deal ID" := GetJsonValue(WebHeaderObject, 'deal_id').AsCode();
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_first_name').IsNull = false then begin
            First_Name := GetJsonValue(WebHeaderObject, 'delivery_first_name').AsText();
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_last_name').IsNull = false then begin
            Last_Name := GetJsonValue(WebHeaderObject, 'delivery_last_name').AsText();
        end;

        if GetJsonValue(WebHeaderObject, 'delivery_first_name').IsNull = false then begin
            InterimSalesHeader."Ship-to Name" := (GetJsonValue(WebHeaderObject, 'delivery_first_name').AsText() + GetJsonValue(WebHeaderObject, 'delivery_last_name').AsText());
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_line_1').IsNull = false then begin
            InterimSalesHeader."Ship-to Address" := CopyStr(GetJsonValue(WebHeaderObject, 'delivery_line_1').AsText(), 1, 50);
        end;

        if GetJsonValue(WebHeaderObject, 'delivery_line_2').IsNull = false then begin
            InterimSalesHeader."Ship-to Address 2" := CopyStr(GetJsonValue(WebHeaderObject, 'delivery_line_2').AsText(), 1, 50);
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_city').IsNull = false then begin
            InterimSalesHeader."Ship-to City" := CopyStr(GetJsonValue(WebHeaderObject, 'delivery_city').AsText(), 1, 30);
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_county').IsNull = false then begin
            InterimSalesHeader."Ship-to County" := CopyStr(GetJsonValue(WebHeaderObject, 'delivery_county').AsText(), 1, 30);
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_postcode').IsNull = false then begin
            InterimSalesHeader."Ship-to Post Code" := GetJsonValue(WebHeaderObject, 'delivery_postcode').AsCode();
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_country').IsNull = false then begin
            InterimSalesHeader."Ship-to Country" := GetJsonValue(WebHeaderObject, 'delivery_country').AsCode();
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_telephone').IsNull = false then begin
            InterimSalesHeader."Ship-to Phone" := GetJsonValue(WebHeaderObject, 'delivery_telephone').AsText();
        end;
        if GetJsonValue(WebHeaderObject, 'delivery_email').IsNull = false then begin
            InterimSalesHeader."Ship-to Email" := GetJsonValue(WebHeaderObject, 'delivery_email').AsText();
        end;
        if GetJsonValue(WebHeaderObject, 'currency').IsNull = false then begin
            InterimSalesHeader."Currency Code" := GetJsonValue(WebHeaderObject, 'currency').AsCode();
        end;
        if GetJsonValue(WebHeaderObject, 'tracking_number').IsNull = false then begin
            InterimSalesHeader."Tracking No." := GetJsonValue(WebHeaderObject, 'tracking_number').AsCode();
        end;
        if GetJsonValue(WebHeaderObject, 'shipping_method').IsNull = false then begin
            InterimSalesHeader."Shipment Method Code" := GetJsonValue(WebHeaderObject, 'shipping_method').AsCode();
        end;
        if GetJsonValue(WebHeaderObject, 'created_at').IsNull = false then begin
            L_DocumentDate := GetJsonValue(WebHeaderObject, 'created_at').AsText();
            InterimSalesHeader."Document Date" := GenerateDate(L_DocumentDate);
        end;

        InterimSalesHeader.Insert();
    end;

    //Date Procedure
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
                    Evaluate(Year, Orderdate.Split('-').Get(1));
                    Evaluate(Month, Orderdate.Split('-').Get(2));
                    Evaluate(Day, Orderdate.Split('-').Get(3));
                    Converdate := DMY2Date(Day, Month, Year);
                end;
            end;
        end;
        exit(Converdate);
    end;
    //interim Sales line
    local procedure InsertInSalesLine(WebHeaderObject: JsonObject; InterimSalesHeader: Record "Interim Sales Header" temporary; ISL: Record "Interim Sales Line" temporary)
    var
        ItemArray: JsonArray;
        itemCount: Integer;
        OrderAmount: Decimal;
        LineNo: Integer;


        k: Integer;
        LineObject: JsonObject;
        WebLineToken: JsonToken;
        ShippingRule: Record "OCHANNEL Shipping Rule";
        CourierIntegration: Codeunit "Courier Integration";
    begin
        ItemArray := GetJsonToken(WebHeaderObject, 'items').AsArray();
        itemCount := ItemArray.Count;
        if itemCount > 0 then begin
            for k := 0 to itemCount - 1 do begin
                LineNo := 1000 + k;
                ItemArray.Get(k, WebLineToken);
                LineObject := WebLineToken.AsObject();

                ISL.Init;
                ISL."Line No." := LineNo;
                ISL."Document Type" := ISL."Document Type"::Order;
                ISL.Type := ISL.type::Item;
                ISL."Document No" := InterimSalesHeader."No.";
                ISL."Channel Order ID" := InterimSalesHeader."Channel Order ID";

                if GetJsonValue(LineObject, 'sku').IsNull = false then begin
                    ISL."Channel SKU" := GetJsonValue(LineObject, 'sku').AsText();
                end;
                if GetJsonValue(LineObject, 'quantity').IsNull = false then begin
                    ISL.Quantity := GetJsonValue(LineObject, 'quantity').AsDecimal();
                end;
                if GetJsonValue(WebHeaderObject, 'product_code').IsNull = false then begin
                    ISL."No." := CopyStr(GetJsonValue(WebHeaderObject, 'product_code').AsCode(), 1, 20);
                end;
                if GetJsonValue(WebHeaderObject, 'product_name').IsNull = false then begin
                    ISL.Description := CopyStr(GetJsonValue(WebHeaderObject, 'product_name').AsText(), 1, 100);
                end;
                if GetJsonValue(WebHeaderObject, 'price').IsNull = false then begin
                    ISL."Unit Price" := GetJsonValue(WebHeaderObject, 'price').AsDecimal();
                end;
                if GetJsonValue(WebHeaderObject, 'full_price').IsNull = false then begin
                    ISL."Amount Including VAT" := GetJsonValue(WebHeaderObject, 'full_price').AsDecimal();
                end;
                ISL.Insert(true);
            end;
        end;
    end;

    procedure GetJsonToken(var aJsonObject: Jsonobject; Tokenkey: Text) aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then;
    end;


    procedure GetJsonValue(var aJsonobject: JsonObject; Tokenkey: text) aJsonvalue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonobject.Get(TokenKey, aJsonToken) then
            error('Could not find a token with kye %1', Tokenkey)
        else
            aJsonValue := aJsonToken.AsValue();
    end;

    var
        myInt: Integer;
        CUWebOrderMgt: Codeunit "Web Order Mgt";
        userId: Text;
        password: Text;
        Service_URL: Text;
        deal_id: Text;
        per_page: Text;
        current_page: Integer;
        last_page: Integer;
        G_Status: Text;
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';


}