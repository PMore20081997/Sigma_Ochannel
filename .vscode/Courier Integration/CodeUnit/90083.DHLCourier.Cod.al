CodeUnit 90083 "DHL Courier"
{
    TableNo = 36;
    trigger OnRun()
    var

    begin
        Retrive_Label(Rec);
    end;

    procedure GetCreadentils(ShippingAgentCode: Code[20])
    var
        ShipingAgent: Record "Shipping Agent";
    begin

        if ShipingAgent.Get(ShippingAgentCode) then begin
            ServiceURL := ShipingAgent."API URL";
            AccessKeyId := ShipingAgent."Access Key";
            SecretAccessKey := ShipingAgent."Secret Key";
            AccessToken := ShipingAgent."Access Token";
            RefreshToken := ShipingAgent."Refresh Token";
            AccNo := ShipingAgent."Business Account No";
            //AutheToken := ShipingAgent.AuthenticationToken;

            // LastOrderSync := TradePartner."Last Order Sync";
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

    procedure SSOAuthentication(ShipingAgentCode: Code[20])
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        TextRequest: Text;
        UserName: Text;
        Password: Text;
        URL: Text;
        responseText: Text;
        Api_Key: Text;
        JsonObj: JsonObject;
        HeaderObject: JsonObject;
        AuthArray: JsonArray;
        AuthToken: JsonToken;
        AuthJsonObj: JsonObject;
        i: Integer;
        j: Integer;
        AuthenticationToken: Text;
        AccountsArray: JsonArray;
        AccountToken: JsonToken;
        AccountObjcet: JsonObject;
        ShipingAgent: Record "Shipping Agent";
        AccountNo: Text[50];

    begin
        GetCreadentils(ShipingAgentCode);
        ShipingAgent.Get(ShipingAgentCode);
        if ShipingAgent.New_AuthDate < CreateDateTime(WorkDate, Time) then begin
            //UserName := 'ranjit.k@robosol.com';
            //Password := 'Robosol@2021';
            //Api_Key := '6ecac71a-e131-49e4-b8ec-3f13bc0b80f2';
            //URL := 'https://services.qa.dhlparcel.co.uk/gateway/SSOAuthenticationAPI/1.0/ssoAuth/users/authenticate?username=' + UserName + '&password=' + Password;
            URL := StrSubstNo('%1/gateway/SSOAuthenticationAPI/1.0/ssoAuth/users/authenticate?username=%2&password=%3', ServiceURL, AccessKeyId, SecretAccessKey);
            HttpClient.Clear();
            HttpClient.DefaultRequestHeaders.Add('x-api-key', AccessToken);
            if HttpClient.Get(url, HttpResponseMessage) then begin
                if not HttpResponseMessage.IsSuccessStatusCode then
                    Error(HttpResponseMessage.ReasonPhrase);
                HttpResponseMessage.Content.ReadAs(responseText);
                if (HttpResponseMessage.HttpStatusCode = 200) then begin
                    AuthArray.ReadFrom(responseText);
                    i := AuthArray.Count;
                    for i := 0 to i do begin
                        AuthArray.Get(i, AuthToken);
                        AuthJsonObj := AuthToken.AsObject();
                        AuthenticationToken := GetJsonvalue(AuthJsonObj, 'authenticationToken').AsText();
                        AccountsArray := GetJsonToken(AuthJsonObj, 'accounts').AsArray();
                        j := AccountsArray.Count;
                        for j := 0 to j do begin
                            AccountsArray.Get(j, AccountToken);
                            AccountObjcet := AccountToken.AsObject();
                            AccountNo := GetJsonvalue(AccountObjcet, 'accountNumber').AsText();
                            ShipingAgent.SetRange(Code, ShipingAgentCode);
                            if ShipingAgent.FindFirst() then begin
                                ShipingAgent.Validate("Refresh Token", AuthenticationToken);
                                // ShipingAgent.Validate("Business Account No", AccountNo);
                                ShipingAgent.Validate(New_AuthDate, CreateDateTime(WorkDate, Time));
                                ShipingAgent.Modify();
                            end;
                        end;
                    end
                end
            end
        end;
    end;

    procedure CollectionRequests(salesHeader: Record "Sales Header" temporary): Code[30]
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        URL: Text;
        TextRequest: Text;
        responseText: Text;
        Api_Key: Text;
        UserName: Text;
        Password: Text;
        Jobject: JsonObject;
        collectionJobNumber: Code[30];
        shipingAgent: Record "Shipping Agent";
        Collectiondate: Text;
        dateFilter: Text;
    begin
        // dateFilter := Format(Today);
        // Collectiondate := format(Today, 0, '20<Year,2>-<Month,2>-<Day,2>');
        if salesHeader."Shipment Date" < Today then
            Collectiondate := Format(Today, 0, '20<Year,2>-<Month,2>-<Day,2>')
        else
            Collectiondate := Format(salesHeader."Shipment Date", 0, '20<Year,2>-<Month,2>-<Day,2>');

        //Collectiondate := '2021-04-12'; //testing

        GetCreadentils(salesHeader."Shipping Agent Code");
        //TextRequest := '{"userName":"ranjit.k@robosol.com ","authenticationToken":"' + RefreshToken + '",' +
        //              '"accountNumber":"B021433","collectionDate":"2021-03-19","closedForLunch":false,"earliestTime":"09:00",' +
        //              '"latestTime":"17:00","specialInstructions":"Ring the bell"}';
        TextRequest := StrSubstNo('{"userName":"%1","authenticationToken":"%2","accountNumber":"%3","collectionDate":"%4",' +
        '"closedForLunch":false,"earliestTime":"09:00","latestTime":"17:00","specialInstructions":"Ring the bell"}', AccessKeyId, RefreshToken, AccNo, Collectiondate);
        //Api_Key := '6ecac71a-e131-49e4-b8ec-3f13bc0b80f2';
        URL := StrSubstNo('%1/v1/collection/collectionrequests', ServiceURL);
        HttpContent.WriteFrom(TextRequest);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('x-api-key', AccessToken);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        if HttpClient.Post(url, HttpContent, HttpResponseMessage) then begin
            if not HttpResponseMessage.IsSuccessStatusCode then
                Error(HttpResponseMessage.ReasonPhrase);
            HttpResponseMessage.Content.ReadAs(responseText);
            if (HttpResponseMessage.HttpStatusCode = 200) then begin
                Jobject.ReadFrom(responseText);
                collectionJobNumber := GetJsonvalue(Jobject, 'collectionJobNumber').AsCode();
                exit(collectionJobNumber);
            end
        end;
    end;

    procedure DHL_Label_Request(salesHeader: Record "Sales Header" temporary): Text
    var

        TextRequest: Text;
        collectionJobNumber: Code[30];
        weight: Integer;

    begin
        weight := salesHeader."Invoice Discount Value" div 1;
        GetCreadentils(salesHeader."Shipping Agent Code");
        collectionJobNumber := CollectionRequests(salesHeader);
        TextRequest := StrSubstNo('{"userName":"%1","authenticationToken":"%2",' +
                     '"accountNumber":"%3","collectionInfo":{"collectionJobNumber": "%4","collectionDate":""},' +
                     '"delivery":{"localContactName":"%5","localContactNumber":"%6",' +
                     '"localContactEmail":"%18","deliveryAddresses":[{"addressType":"doorstep",' +
                     '"address1":"%7","postalTown":"%8","postcode":"%9",' +
                     '"countryCode": "GBR"}]},"serviceKey":"%10",' +
                     '"items":"%11","totalWeight":"%12","recipient":{"contactName":"%13","contactEmail":"%14",' +
                     '"recipientAddress":{"address1":"%15","postalTown":"%16","postcode":"%17",' +
                     '"countryCode":"GBR","addressType":"business"},"preDeliveryNotificationType":"phone"},' +
                     '"labelFormat":"PNG6x4"}', AccessKeyId,
                     RefreshToken, AccNo, collectionJobNumber, CopyStr(salesHeader."Ship-to Name", 1, 35),
                     CopyStr(salesHeader."Ship-to Contact", 1, 35), CopyStr(salesHeader."Ship-to Address", 1, 35),
                     CopyStr(salesHeader."Ship-to City", 1, 30), CopyStr(salesHeader."Ship-to Post Code", 1, 20),
                      salesHeader."Shipping Agent Service Code",
                     salesHeader."No. Printed", weight, CopyStr(salesHeader."Ship-to Name", 1, 35),
                     salesHeader."Sell-to E-Mail", CopyStr(salesHeader."Ship-to Address", 1, 35), CopyStr(salesHeader."Ship-to City", 1, 30),
                     CopyStr(salesHeader."Ship-to Post Code", 1, 20), salesHeader."Sell-to E-Mail");
        exit(TextRequest);
    end;

    procedure Retrive_Label(salesHeader: Record "Sales Header" temporary)
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        url: Text;
        TextRequest: Text;
        Api_Key: Text;
        responseText: Text;
        Jobject: JsonObject;
        identifiersAsJsonArray: JsonArray;
        i: Integer;
        identifiersAsObj: JsonObject;
        identifierToken: JsonToken;
        identifierType: Text;
        identifierValue: Text;
        labelsAsJsonArray: JsonArray;
        labelsAsObj: JsonObject;
        labelsToken: JsonToken;
        j: Integer;
        noofrecord: Integer;
        collectionJobNumber: Code[30];
        shipingAgent: Record "Shipping Agent";
        LabelAsValue: JsonValue;
        LabelText: Text;
        parcelNo: Text;
        CU_GenericInsertShipment: Codeunit "Shipment Tracking Insertion";
    begin
        SSOAuthentication(salesHeader."Shipping Agent Code");
        //collectionJobNumber := CollectionRequests('DHL');
        GetCreadentils(salesHeader."Shipping Agent Code");
        /* TextRequest := '{"userName":"ranjit.k@robosol.com","authenticationToken": "' + RefreshToken + '",' +
                      '"accountNumber":"B021433","collectionInfo":{"collectionJobNumber": "' + collectionJobNumber + '","collectionDate":""},' +
                      '"delivery":{"localContactName":"Mr John Doe","localContactNumber":7691347758,"contactNumberType":"mobile",' +
                      '"localContactEmail":"JohnDoe@webmail.com","deliveryAddresses":[{"addressType":"doorstep","servicePointId":"1234-GB123456",' +
                      '"businessName":"Nile Tech Internet Cafe","address1":"56 Far Gosford Street","postalTown":"Coventry","postcode":"CV1 5DZ",' +
                      '"countryCode":"GBR"}],"specialInstructions":"special instructions","secureLocation":null},"serviceKey":"220",' +
                      '"items":"1","totalWeight":"11","recipient":{"contactName":"Mr John Doe","contactEmail":"JohnDoe@webmail.com",' +
                      '"recipientAddress":{"address1":"Apartment 1a","postalTown":"Coventry","county":null,"postcode":"CV1 5AA",' +
                      '"countryCode":"GBR","addressType":"residential"},"preDeliveryNotificationType":"phone"},"exchangeOnDelivery":false,' +
                      '"bookin":false,"inBoxReturn":false,"labelFormat":"PNG6x4","customsDeclaration":{},"$$ref":"../examples/domesticconsignment_v3_example.json"}';*/
        TextRequest := DHL_Label_Request(salesHeader);
        // Api_Key := '6ecac71a-e131-49e4-b8ec-3f13bc0b80f2';
        url := StrSubstNo('%1/gateway/DomesticConsignment/2.0/DomesticConsignment', ServiceURL);
        HttpContent.WriteFrom(TextRequest);
        HttpHeaders := HttpClient.DefaultRequestHeaders();
        HttpHeaders.Clear();
        HttpHeaders.Add('x-api-key', AccessToken);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        if HttpClient.Post(url, HttpContent, HttpResponseMessage) then begin
            if not HttpResponseMessage.IsSuccessStatusCode then
                Error(HttpResponseMessage.ReasonPhrase);
            HttpResponseMessage.Content.ReadAs(responseText);
            if (HttpResponseMessage.HttpStatusCode = 200) then begin
                Jobject.ReadFrom(responseText);
                identifiersAsJsonArray := GetJsonToken(Jobject, 'identifiers').AsArray();
                i := identifiersAsJsonArray.Count;
                for i := 0 to i do begin
                    identifiersAsJsonArray.Get(i, identifierToken);
                    identifiersAsObj := identifierToken.AsObject();
                    identifierType := GetJsonvalue(identifiersAsObj, 'identifierType').AsText();
                    identifierValue := GetJsonvalue(identifiersAsObj, 'identifierValue').AsText();
                    labelsAsJsonArray := GetJsonToken(Jobject, 'labels').AsArray();
                    j := labelsAsJsonArray.Count;
                    noofrecord := labelsAsJsonArray.Count;
                    for j := 0 to noofrecord - 1 do begin
                        parcelNo := GenerateParcelNo(j + 1);
                        labelsAsJsonArray.Get(j, labelsToken);
                        LabelAsValue := labelsToken.AsValue();
                        LabelText := LabelAsValue.AsText();
                        CU_GenericInsertShipment.InsertShipmentTracking(identifierValue + parcelNo, LabelText, '', '', identifierValue + parcelNo, salesHeader);
                        //InsertInShipmentTracking(salesHeader, LabelText, identifierValue + parcelNo);
                    end;
                end;
            end;
        end;
    end;

    local procedure GenerateParcelNo(count: Integer): Text
    var
        parcelNo: Text;
    begin
        Clear(parcelNo);
        if (count <= 9) then begin
            parcelNo := '00' + Format(count);
        end;
        if (count > 9) then begin
            parcelNo := '0' + Format(count);
        end;
        if (count > 99) then begin
            parcelNo := Format(count);
        end;
        exit(parcelNo);
    end;

    procedure InsertInShipmentTracking(salesHeader: record "Sales Header" temporary; Base64String: Text; Trackingno: Text)
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
        ShipmentTrack.VALIDATE("Agent Shipment No.", Trackingno);
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

    var
        ServiceURL: Text;
        AccessKeyId: Text;
        SecretAccessKey: Text;
        AccessToken: Text;
        RefreshToken: Text;
        AccNo: Text[50];
        LastOrderSync: DateTime;
        AutheToken: Text;

}