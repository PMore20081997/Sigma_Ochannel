codeunit 90087 "Royal Mail"
{
    TableNo = 36;
    trigger OnRun()
    begin
        MapConsignment(Rec);
    end;

    var
        Username: Text;
        Password: Text;
        ServiceURL: Text;
        ClientID: Text;
        ClientSecret: Text;
        AccessToken: Text[250];
        TotalPrice: Decimal;

    local procedure GetCredentials(ChannelCode: Code[10])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        ShippingAgent.RESET;
        if ShippingAgent.Get(ChannelCode) then begin
            Username := ShippingAgent."Access Key";
            Password := ShippingAgent."Secret Key";
            ServiceURL := ShippingAgent."API URL";
            ClientID := ShippingAgent."Client Id";
            ClientSecret := ShippingAgent."Client Secret";
            AccessToken := ShippingAgent."Access Token";
        End;
    end;

    procedure CreateConsignment(var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        URL: Text;
        responseMessage: HttpResponseMessage;
        response: Text;
        body: Text;
        jObject: JsonObject;
        TokenResponsetext: Text;
        X_IBM_Client_Id: Text;
        X_IBM_Client_Secret: Text;
        X_RMG_Security_Username: Text;
        X_RMG_Security_Password: Text;
    begin
        //GetCredentials(Temp_SalesHeader."Shipping Agent Code");
        headers := client.DefaultRequestHeaders;

        //X_IBM_Client_Id := 'd1c704ce-ca10-4cb4-874c-5e5fbec3a811';
        //X_IBM_Client_Secret := 'L7oX8yQ4jQ0hR0uI3cH4sU8cY0xO4kP0cF5cF2xP1oQ4qX6dT7';
        //X_RMG_Security_Username := '0787675003API';
        //X_RMG_Security_Password := 'Purpl3F1sh!';
        //ServiceURL := 'https://api.royalmail.net/shipping/v3/token';
        URL := ServiceURL + 'token';

        headers.Add('Accept', 'application/json');

        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('X-IBM-Client-Id', ClientID);
        headers.Add('X-IBM-Client-Secret', ClientSecret);
        headers.Add('X-RMG-Security-Username', Username);
        headers.Add('X-RMG-Security-Password', Password);

        if client.Post(URL, content, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                TokenResponsetext := GetJsonvalue(jObject, 'token').AsText();
                exit(TokenResponsetext);
            end
            else begin
                responseMessage.Content.ReadAs(response);
                Message(response);
            end;
        end;
    end;

    local procedure MapConsignment(var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        L_httpclient: HttpClient;
        L_httpheaders: HttpHeaders;
        L_httpcontent: HttpContent;
        L_httpresponseMessage: HttpResponseMessage;
        L_response: Text;
        body: Text;
        jObject: JsonObject;
        TextRequest: Text;
        URL: Text;
        X_IBM_Client_Id: Text;
        ShipperReference: Text;
        TokenDuration: Duration;
        NoOfHours: Decimal;
        PackagesArray: JsonArray;
        PackagesCount: Integer;
        i: Integer;
        PackageToken: JsonToken;
        PackageObject: JsonObject;
        TrackingNumber: Text[30];
        Base64StringLabel: Text;
        Base64ReturnLabel: Text;
        CU_ShipmentTrackingInsertion: Codeunit "Shipment Tracking Insertion";
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_ShippingAgent: Record "Shipping Agent";
    begin
        ClearAll();
        GetCredentials(Temp_SalesHeader."Shipping Agent Code");

        if AccessToken = '' then begin
            AccessToken := CreateConsignment(Temp_SalesHeader);
            L_ShippingAgent.Reset();
            L_ShippingAgent.SetRange(Code, Temp_SalesHeader."Shipping Agent Code");
            if L_ShippingAgent.FindFirst() then begin
                L_ShippingAgent.Validate("Access Token", AccessToken);
                L_ShippingAgent.Validate(New_AuthDate, CreateDateTime(WorkDate, Time));
                L_ShippingAgent.Modify();
            end;
        end
        else begin
            L_ShippingAgent.Reset();
            L_ShippingAgent.SetRange(Code, Temp_SalesHeader."Shipping Agent Code");
            if L_ShippingAgent.FindFirst() then begin
                if L_ShippingAgent.New_AuthDate <> 0DT then begin
                    TokenDuration := CreateDateTime(WorkDate, Time) - L_ShippingAgent.New_AuthDate;
                    //NoOfHours := Round(TokenDuration / 3600000, 3, '=');
                    NoOfHours := Round(TokenDuration / 3600000);
                    if NoOfHours >= 3.9 then begin
                        AccessToken := CreateConsignment(Temp_SalesHeader);
                        L_ShippingAgent.Validate("Access Token", AccessToken);
                        L_ShippingAgent.Validate(New_AuthDate, CreateDateTime(WorkDate, Time));
                        L_ShippingAgent.Modify();
                    end;
                end;
            end;
        end;

        L_httpheaders := L_httpclient.DefaultRequestHeaders;
        //X_IBM_Client_Id := 'd1c704ce-ca10-4cb4-874c-5e5fbec3a811';
        //ServiceURL := 'https://api.royalmail.net/shipping/v3/shipments';
        ServiceURL := ServiceURL + 'shipments';
        L_httpheaders.Add('Accept', 'application/json');

        if Temp_SalesHeader.FindFirst() then begin
            Clear(ShipperReference);
            ShipperReference := Temp_SalesHeader."External Document No." + '-' + Temp_SalesHeader."No.";
        end;

        body := ItemBody(Temp_SalesHeader);
        TextRequest := StrSubstNo('{"Shipper":{"ShipperReference":"%1"},"Destination":{"ContactName":"%2","AddressLine1":"%3","AddressLine2":"%4","AddressLine3":"%5","Town":"%6","CountryCode":"%7",' +
        '"Postcode":"%8"},"ShipmentInformation":{"ShipmentDate":"%9","ServiceCode":"%10","TotalPackages":1,"Value":%11,"Currency":"%12","TotalWeight":%13,"LabelFormat":"PNG",' +
        '"Packages":[{"Weight":%14}],"Items":[%15]}}', ShipperReference, Temp_SalesHeader."Ship-to Name", Temp_SalesHeader."Ship-to Address", Temp_SalesHeader."Ship-to Address 2", ''
        , Temp_SalesHeader."Ship-to City", Temp_SalesHeader."Ship-to Country/Region Code", Temp_SalesHeader."Ship-to Post Code", Format(Temp_SalesHeader."Shipment Date", 0, '20<Year>-<Month,2>-<Day,2>')
        , Temp_SalesHeader."Shipping Agent Service Code", TotalPrice, 'GBP', Temp_SalesHeader."Currency Factor", Temp_SalesHeader."Currency Factor", body);
        L_httpcontent.WriteFrom(TextRequest);

        L_httpcontent.GetHeaders(L_httpheaders);
        L_httpheaders.Clear();
        L_httpheaders.Add('Content-Type', 'application/json');
        L_httpheaders.Add('x-ibm-client-id', ClientID);
        L_httpheaders.Add('x-rmg-auth-token', AccessToken);


        if L_httpclient.Post(ServiceURL, L_httpcontent, L_httpresponseMessage) then begin
            if L_httpresponseMessage.HttpStatusCode = 200 then begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                jObject.ReadFrom(L_response);

                PackagesArray := GetJsonToken(jObject, 'Packages').AsArray();
                PackagesCount := PackagesArray.Count;
                if PackagesCount > 0 then begin
                    for i := 0 to PackagesCount - 1 do begin
                        PackagesArray.Get(i, PackageToken);
                        PackageObject := PackageToken.AsObject();
                        Clear(TrackingNumber);
                        Clear(Base64StringLabel);
                        Clear(Base64ReturnLabel);

                        //Getting Tracking Number
                        TrackingNumber := CopyStr(GetJsonvalue(PackageObject, 'TrackingNumber').AsText(), 1, 30);

                        //Getting Label and Return Label
                        Base64StringLabel := GetJsonvalue(jObject, 'LabelImages').AsText();
                        Base64ReturnLabel := GetJsonvalue(jObject, 'ReturnLabelImages').AsText();

                        if Temp_SalesHeader.FindFirst() then begin
                            L_InterimSalesHeader.Reset();
                            L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                            if L_InterimSalesHeader.FindFirst() then begin
                                L_InterimSalesHeader.Validate("Package Tracking No.", TrackingNumber);
                                L_InterimSalesHeader.Modify(true);
                            end;
                        end;

                        //Calling Generic Shipment Tracking Insert Method
                        CU_ShipmentTrackingInsertion.InsertShipmentTracking(TrackingNumber, Base64StringLabel, Base64ReturnLabel, '', '', Temp_SalesHeader);
                    end;
                end;

                //InsertInShipmentTracking(jObject, Temp_SalesHeader);  //Commented Shubham 11032022 (As Created Generic Codeunit)
            end
            else begin
                L_httpresponseMessage.Content.ReadAs(L_response);
                Message(L_response);
            end;
        end;
    end;


    local procedure InsertInShipmentTracking(responseObject: JsonObject; var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        ShipmentTrack: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
        OutStm1: OutStream;
        Base64StringLabel: Text;
        Base64ReturnLabel: Text;
        PackagesArray: JsonArray;
        PackagesCount: Integer;
        i: Integer;
        PackageToken: JsonToken;
        PackageObject: JsonObject;
        TrackingNumber: Text[30];
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        ShipmentTrack.INIT;
        ShipmentTrack.VALIDATE("Document Type", ShipmentTrack."Document Type"::Order);
        if Temp_SalesHeader.FindFirst() then;
        ShipmentTrack.Validate("Document No.", Temp_SalesHeader."No.");
        ShipmentTrack.Validate("Shipping Agent Code", Temp_SalesHeader."Shipping Agent Code");
        ShipmentTrack.VALIDATE("Shipping Agent Service Code", Temp_SalesHeader."Shipping Agent Service Code");
        ShipmentTrack.Validate("Entry Created", Today);

        IF RecShipmentTracking.FINDLAST THEN
            ShipmentTrack."Entry No." := RecShipmentTracking."Entry No." + 1
        ELSE
            ShipmentTrack."Entry No." := 1;

        PackagesArray := GetJsonToken(responseObject, 'Packages').AsArray();
        PackagesCount := PackagesArray.Count;
        if PackagesCount > 0 then begin
            for i := 0 to PackagesCount - 1 do begin
                PackagesArray.Get(i, PackageToken);
                PackageObject := PackageToken.AsObject();
                TrackingNumber := CopyStr(GetJsonvalue(PackageObject, 'TrackingNumber').AsText(), 1, 30);
                ShipmentTrack.VALIDATE("Tracking No.", TrackingNumber);

                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetRange("No.", Temp_SalesHeader."No.");
                if L_InterimSalesHeader.FindFirst() then begin
                    L_InterimSalesHeader.Validate("Package Tracking No.", TrackingNumber);
                    L_InterimSalesHeader.Modify(true);
                end;
            end;
        end;

        Base64StringLabel := GetJsonvalue(responseObject, 'LabelImages').AsText();
        IF (Base64StringLabel <> '') THEN BEGIN
            ShipmentTrack.CalcFields(Label);
            ShipmentTrack.Label.CreateOutStream(OutStm);
            Base64Convert.FromBase64(Base64StringLabel, OutStm);
        END;

        Base64ReturnLabel := GetJsonvalue(responseObject, 'ReturnLabelImages').AsText();
        if (Base64ReturnLabel <> '') then begin
            ShipmentTrack.CalcFields("A6 Label1");
            ShipmentTrack."A6 Label1".CreateOutStream(OutStm1);
            Base64Convert.FromBase64(Base64ReturnLabel, OutStm1);
        end;

        ShipmentTrack.INSERT;
    end;


    local procedure ItemBody(var Temp_SalesHeader: Record "Sales Header" temporary): Text
    var
        ItemJson: Text;
    begin
        Clear(TotalPrice);
        if Temp_SalesHeader.FindSet() then begin
            repeat
                ItemJson += StrSubstNo('{"Quantity":%1,"Description":"%2","Value":%3,"SkuCode":"%4","CountryOfOrigin":"%5"},'
                , Temp_SalesHeader."Invoice Discount Value", Temp_SalesHeader."Prepmt. Posting Description"
                , Temp_SalesHeader."Payment Discount %", Temp_SalesHeader."Bill-to Name 2"
                , Temp_SalesHeader."Payment Method Code");
                TotalPrice := TotalPrice + (Temp_SalesHeader."Invoice Discount Value" * Temp_SalesHeader."Payment Discount %");
            UNTIL Temp_SalesHeader.Next = 0;
            ItemJson := ItemJson.TrimEnd(',');
        end;
        exit(ItemJson);
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