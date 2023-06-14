CodeUnit 90080 "APC Courier"
{
    TableNo = 36;
    trigger OnRun()
    var
        myInt: Integer;
        APIName: Code[20];
    begin
        Order_Placing(Rec);
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

    procedure GetCreadentils("ChannelCode": Code[20])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            AccessKeyId := ShippingAgent."Access Key";
            SecretAccessKey := ShippingAgent."Secret Key";
            ServiceURL := ShippingAgent."API URL";
        End;

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

    procedure APC_Order_Request(salesHeader: Record "Sales Header" temporary): Text
    var
        CollectionDate: Text;
        TextRequest: Text;
        HeaderText: Text;
        LineText: Text;
        LSalesHeader: Record "Sales Header";
        ItemText: Text;

    begin
        Clear(ItemText);
        ItemText := ItemWeightCalculation(salesHeader);
        if salesHeader."Shipment Date" < Today then
            CollectionDate := Format(Today, 0, '<Day,2>/<Month,2>/<Year4>')
        else
            CollectionDate := Format(salesHeader."Shipment Date", 0, '<Day,2>/<Month,2>/<Year4>');

        TextRequest := StrSubstNo('{"Orders":{"Order":{"CollectionDate":"%1","ReadyAt":"18:00","ClosedAt": "18:30",' +
'"ProductCode":"%2","Collection":{"CompanyName":"%3","AddressLine1": "%4","AddressLine2":"%5",' +
'"PostalCode":"%6","City":"%7","County":"%8","CountryCode":"%9","Contact":{"PersonName":"%19","PhoneNumber":"%20",' +
'"Email":"%21"}},' +
'"Delivery":{"CompanyName":"%10","AddressLine1":"%11","AddressLine2":"%12","PostalCode":"%13",' +
'"City":"%14","County":"%15","CountryCode":"%16"},' +
'"ShipmentDetails":{"NumberOfPieces":"%17","Items":{"Item":[%18]}}}}}',
CollectionDate, salesHeader."Shipping Agent Service Code", salesHeader."Sell-to Customer Name",
salesHeader."Sell-to Address", salesHeader."Sell-to Address 2", salesHeader."Sell-to Post Code",
salesHeader."Sell-to City", salesHeader."Sell-to County", salesHeader."Sell-to Country/Region Code",
salesHeader."Ship-to Name", salesHeader."Ship-to Address", salesHeader."Ship-to Address 2",
salesHeader."Ship-to Post Code", salesHeader."Ship-to City", salesHeader."Ship-to County",
salesHeader."Ship-to Country/Region Code", salesHeader."No. Printed", ItemText, salesHeader."Sell-to Contact", salesHeader."Sell-to Contact No.", salesHeader."Sell-to E-Mail");
        exit(TextRequest);

    end;

    procedure ItemWeightCalculation(SalesHeader: Record "Sales Header"): Text
    var
        NoofCount: Integer;
        PerParsalWeight: Decimal;
        ItemJson: Text;
        K: Integer;
        ItemJsonCount: Integer;
    Begin
        NoofCount := SalesHeader."No. Printed";
        if NoofCount <> 0 then
            PerParsalWeight := Round(SalesHeader."Invoice Discount Value" / NoofCount);
        if NoofCount > 1 then begin
            for K := 0 to NoofCount - 1 do begin
                ItemJson += StrSubstNo('{"Weight":"%1"},', PerParsalWeight)
            end;
            ItemJson := ItemJson.TrimEnd(',');
        end else begin
            ItemJson := StrSubstNo('{"Weight":"%1"}', PerParsalWeight);
        end;
        exit(ItemJson);
    End;

    procedure
    Order_Placing(SalesOrder: Record "Sales Header" temporary)
    var
        HttpHeader: HttpHeaders;
        HttpClients: HttpClient;
        HttpContents: HttpContent;
        HttpResponse: HttpResponseMessage;
        TextRequest: Text;
        UserId_Password: Text;
        URL: Text;
        responseText: Text;
        SaleHead: Record "Sales Header";
        jObject: JsonObject;
        OrdersObj: JsonObject;
        OrderObj: JsonObject;
        WayBill: Code[30];
        ShipmentDetailsObj: JsonObject;
        ItemsObj: JsonObject;
        NoofPices: Integer;
        ItemsArray: JsonArray;
        k: Integer;
        ItemTrackingNo: Text;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        SalesOrderNo: Code[20];
    begin
        /* TextRequest := '{"Orders":{"Order":{"CollectionDate": "04/03/2021","ReadyAt": "18:00",' +
         '"ClosedAt": "18:30","ProductCode": "ND16","Reference": "TEST","Collection":{"CompanyName": "APC API and Co",' +
         '"AddressLine1": "National Sortation Centre","AddressLine2": "Kingswood Lakeside","PostalCode": "WS11 8LD",' +
         '"City": "Cannock","County": "Staffordshire","CountryCode": "GB","Contact": {"PersonName": "Fred Smith",' +
         '"PhoneNumber": "01922 702587","Email": "cmsteam@apc-overnight.com"}},"Delivery": {"CompanyName": "The Big Company Ltd",' +
         '"AddressLine1": "Big Company House","AddressLine2": "177 Big Street","PostalCode": "M17 1WA","City": "Sale",' +
         '"County": "Cheshire","CountryCode": "GB","Contact": {"PersonName": "Jack Jones","PhoneNumber": "0800 0000000",' +
         '"MobileNumber": "07785 476095","Email": "name@example.com"},"Instructions": "Leave with neighbour"},"GoodsInfo": {' +
         '"GoodsValue": "20","GoodsDescription": "books","Fragile": "false","Security": "false","IncreasedLiability": "false"},' +
         '"ShipmentDetails": {"NumberOfPieces": "1","Items": {"Item": {"Type": "ALL","Weight": "1","Length": "32","Width": "23",' +
         '"Height": "16","Reference": "PartA"}}}}}}';*/


        GetCreadentils(SalesOrder."Shipping Agent Code");
        Clear(SalesOrderNo);
        TextRequest := APC_Order_Request(SalesOrder);
        // UserId_Password := CreateBasicAuth('admin@pioneervet.co.uk', 'Password!');
        UserId_Password := CreateBasicAuth(AccessKeyId, SecretAccessKey);
        // URL := 'https://apc-training.hypaship.com/api/3.0/Orders.json';
        URL := StrSubstNo('%1.json', ServiceURL);
        HttpContents.WriteFrom(TextRequest);
        HttpHeader := HttpClients.DefaultRequestHeaders();
        HttpHeader.Clear();
        HttpHeader.Add('Authorization', UserId_Password);
        HttpContents.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        if HttpClients.Post(URL, HttpContents, HttpResponse) then begin
            if (HttpResponse.HttpStatusCode = 200) then begin
                HttpResponse.Content.ReadAs(responseText);
                Message(responseText);
                jObject.ReadFrom(responseText);
                SalesOrderNo := SalesOrder."No.";
                OrdersObj := GetJsonToken(jObject, 'Orders').AsObject();
                OrderObj := GetJsonToken(OrdersObj, 'Order').AsObject();
                WayBill := GetJsonvalue(OrderObj, 'WayBill').AsCode();
                Sleep(8000);
                if WayBill <> '' then
                    Label_Retriving(WayBill, SalesOrder);

                // ShipmentDetailsObj := GetJsonToken(OrderObj, 'ShipmentDetails').AsObject();
                //ItemsObj := GetJsonToken(OrderObj, 'Items').AsObject();
                // NoofPices := GetJsonvalue(ItemsObj, 'NumberOfPieces').AsInteger();
                // if (NoofPices > 1) then begin
                //     ItemsArray := GetJsonToken(ItemsObj, 'Item').AsArray();
                //     k := ItemsArray.Count;
                //     for k := 0 to k - 1 do begin
                //         Clear(ItemTrackingNo);
                //         ItemsArray.Get(k, ItemToken);
                //         ItemObj := ItemToken.AsObject();
                //         ItemTrackingNo := GetJsonvalue(ItemObj, 'TrackingNumber').AsText();
                //         InsertInShipmentTracking(SalesOrderNo, WayBill, ItemTrackingNo);
                //         Label_Retriving(WayBill);
                //     end;
                // end;
                // if (NoofPices = 1) then begin
                //     ItemObj := GetJsonToken(ItemsObj, 'Item').AsObject();
                //     ItemTrackingNo := GetJsonvalue(ItemObj, 'TrackingNumber').AsText();
                //     InsertInShipmentTracking(SalesOrderNo, WayBill, ItemTrackingNo);
                //     Label_Retriving(WayBill);
                // end;
            end;
        end;

    end;

    procedure Label_Retriving(ChannelCode: code[30]; SalesHeader: Record "Sales Header" temporary)
    var
        Header: HttpHeaders;
        content: HttpContent;
        clients: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JsonObj: JsonObject;
        HeaderObject: JsonObject;
        OrderObject: JsonObject;
        ShipmentObject: JsonObject;
        ItemsObject: JsonObject;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemJsonObject: JsonObject;
        LabelObject: JsonObject;
        LabelText: Text;
        ItemTrackingNo: Text;
        BText: Text;
        TextRequest: Text;
        URL: Text;
        UserId_Password: Text;
        responseText: Text;
        k: Integer;
        NoofPices: Integer;
        WayBillNumber: text;
    begin
        GetCreadentils(SalesHeader."Shipping Agent Code");
        //  TextRequest := StrSubstNo('2021031001310300000007.JSON?searchtype=CarrierWaybill&labelformat=PNG&markprinted=True&searchtype=CarrierWaybill&labels=True');
        TextRequest := StrSubstNo('%1.JSON?searchtype=CarrierWaybill&labelformat=PNG&markprinted=True&searchtype=CarrierWaybill&labels=True', ChannelCode);
        // UserId_Password := CreateBasicAuth('admin@pioneervet.co.uk', 'Password!');
        UserId_Password := CreateBasicAuth(AccessKeyId, SecretAccessKey);
        URL := StrSubstNo('%1/%2', ServiceURL, TextRequest);
        clients.Clear();
        clients.DefaultRequestHeaders.Add('Authorization', UserId_Password);
        if clients.Get(url, Response) then begin
            if not Response.IsSuccessStatusCode then
                Error(Response.ReasonPhrase);
            Response.Content.ReadAs(responseText);
            //Message(responseText);
            if (Response.HttpStatusCode = 200) then begin
                JsonObj.ReadFrom(responseText);
                JsonObj := GetJsonToken(JsonObj, 'Orders').AsObject();
                HeaderObject := JsonObj;
                OrderObject := GetJsonToken(HeaderObject, 'Order').AsObject();
                ShipmentObject := GetJsonToken(OrderObject, 'ShipmentDetails').AsObject();
                ItemsObject := GetJsonToken(ShipmentObject, 'Items').AsObject();
                NoofPices := GetJsonvalue(ShipmentObject, 'NumberOfPieces').AsInteger();
                if (NoofPices > 1) then begin
                    ItemsArray := GetJsonToken(ItemsObject, 'Item').AsArray();
                    k := ItemsArray.Count;
                    for k := 0 to ItemsArray.Count - 1 do begin
                        Clear(BText);
                        Clear(ItemTrackingNo);
                        ItemsArray.Get(k, ItemToken);
                        ItemJsonObject := ItemToken.AsObject();
                        ItemTrackingNo := GetJsonvalue(ItemJsonObject, 'TrackingNumber').AsText();
                        ItemTrackingNo := ItemTrackingNo.Substring(9);
                        if GetJsonvalue(OrderObject, 'WayBill').AsText() <> '' then
                            WayBillNumber := GetJsonvalue(OrderObject, 'WayBill').AsText();

                        LabelObject := GetJsonToken(ItemJsonObject, 'Label').AsObject();
                        BText := (GetJsonvalue(LabelObject, 'Content').AsText());
                        InsertInShipmentTracking(SalesHeader, BText, ItemTrackingNo, WayBillNumber);
                    end;
                end;
                if (NoofPices = 1) then begin
                    ItemJsonObject := GetJsonToken(ItemsObject, 'Item').AsObject();
                    ItemTrackingNo := GetJsonvalue(ItemJsonObject, 'TrackingNumber').AsText();
                    ItemTrackingNo := ItemTrackingNo.Substring(9);
                    if GetJsonvalue(OrderObject, 'WayBill').AsText() <> '' then
                        WayBillNumber := GetJsonvalue(OrderObject, 'WayBill').AsText();
                    LabelObject := GetJsonToken(ItemJsonObject, 'Label').AsObject();
                    BText := (GetJsonvalue(LabelObject, 'Content').AsText());
                    InsertInShipmentTracking(SalesHeader, BText, ItemTrackingNo, WayBillNumber);
                end;
            end;

        end
    end;

    procedure InsertInShipmentTracking(SalesHeader: Record "Sales Header" temporary; Base64String: Text; Trackingno: Text; WayBillNo: Text)
    var
        ShipmentTrack: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
    begin
        ShipmentTrack.INIT;
        ShipmentTrack.VALIDATE("Document Type", ShipmentTrack."Document Type"::Order);
        // ShipmentTrack.VALIDATE("Document No.", '101');
        ShipmentTrack.Validate("Document No.", SalesHeader."External Document No.");
        //ShipmentTrack.VALIDATE("Shipping Agent Code", 'APC');
        ShipmentTrack.Validate("Shipping Agent Code", SalesHeader."Shipping Agent Code");
        //   ShipmentTrack.VALIDATE("Shipping Agent Service Code", 'ND16');
        ShipmentTrack.VALIDATE("Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
        //ShipmentTrack.VALIDATE("Agent Shipment No.", Trackingno);
        ShipmentTrack.VALIDATE("Agent Shipment No.", WayBillNo);
        ShipmentTrack.Validate("Entry Created", Today);//Sofyan
        ShipmentTrack.VALIDATE("Tracking No.", Trackingno);
        IF RecShipmentTracking.FINDLAST THEN
            ShipmentTrack."Entry No." := RecShipmentTracking."Entry No." + 1
        ELSE
            ShipmentTrack."Entry No." := 1;

        IF (Base64String <> '') THEN BEGIN
            ShipmentTrack.CalcFields(Label);
            ShipmentTrack.Label.CreateOutStream(OutStm);
            Base64Convert.FromBase64(Base64String, OutStm);
        END;
        ShipmentTrack.INSERT;
    end;


    procedure Orders_Tracking(ChannelCode: code[20])
    var
        Header: HttpHeaders;
        content: HttpContent;
        clients: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

        TextRequest: Text;
        URL: Text;
        UserId_Password: Text;
        responseText: Text;
    begin
        TextRequest := StrSubstNo('2021030401310300000004?searchtype=CarrierWaybill&labelformat=PDF&markprinted=True&searchtype=CarrierWaybill&labels=True');
        UserId_Password := CreateBasicAuth('admin@pioneervet.co.uk', 'Password!');
        URL := StrSubstNo('https://apc-training.hypaship.com/api/3.0//Orders/%1', TextRequest);
        clients.Clear();
        clients.DefaultRequestHeaders.Add('Authorization', UserId_Password);
        //clients.DefaultRequestHeaders.Remove('Content-Type');
        //clients.DefaultRequestHeaders.Add('Accept', 'application/json');
        //clients.DefaultRequestHeaders.Add('Content-Type', 'application/json');
        if clients.Get(url, Response) then begin
            if not Response.IsSuccessStatusCode then
                Error(Response.ReasonPhrase);
            Response.Content.ReadAs(responseText);
            Message(responseText);
        end;
    end;

    procedure Orders_Canceling(ChannelCode: code[20])
    var
        Header: HttpHeaders;
        content: HttpContent;
        clients: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;

        TextRequest: Text;
        URL: Text;
        UserId_Password: Text;
        responseText: Text;
    begin
        TextRequest := StrSubstNo('{"CancelOrder":{"Order":{"Status":"CANCELLED"}}}');
        UserId_Password := CreateBasicAuth('admin@pioneervet.co.uk', 'Password!');
        URL := StrSubstNo('https://apc-training.hypaship.com/api/3.0/Orders/000000000009742844?searchtype=CarrierWaybill');
        clients.Clear();
        clients.DefaultRequestHeaders.Add('Authorization', UserId_Password);
        content.WriteFrom(TextRequest);
        if clients.Put(url, content, Response) then begin
            if not Response.IsSuccessStatusCode then
                Error(Response.ReasonPhrase);
            Response.Content.ReadAs(responseText);
            Message(responseText);
        end;
    end;

    var
        myInt: Integer;
        AccessKeyId: Text;
        SecretAccessKey: Text;
        ServiceURL: Text;
        LastOrderSync: DateTime;

}