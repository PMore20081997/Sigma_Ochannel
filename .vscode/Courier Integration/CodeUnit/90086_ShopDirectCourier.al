codeunit 90086 "Shop Direct Courier"
{
    TableNo = 36;
    trigger OnRun()
    begin
        GetShipmentLabel(Rec);
    end;

    var
        Username: Text;
        Pasword: Text;
        ServiceURL: Text;


    local procedure GetCredentials(ChannelCode: Code[20])
    var
        ShippingAgent: Record "Shipping Agent";
        ShippingRule: Record "Shipping Rule";
    begin
        ShippingRule.Reset();
        ShippingRule.SetRange("Channel Code", ChannelCode);
        if ShippingRule.FindFirst() then begin
            ShippingAgent.RESET;
            if ShippingAgent.Get(ShippingRule."Shipping Agent") then begin
                Username := ShippingAgent."Access Key";
                Pasword := ShippingAgent."Secret Key";
                ServiceURL := ShippingAgent."API URL";
            End;
        end;
    end;


    procedure GetShipmentLabel(var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        responseMessage: HttpResponseMessage;
        response: Text;
        body: Text;
        authorization: Text;
        jObject: JsonObject;
        printResponseObject: JsonObject;
        OrderDate: Text;
    begin
        GetCredentials(Temp_SalesHeader."Bill-to Customer No.");
        headers := client.DefaultRequestHeaders;

        //Username := 'S776_API';
        //Pasword := 'xJG62Fbqs2dXuquk';
        authorization := CreateBasicAuth(Username, Pasword);
        headers.Add('Authorization', authorization);

        OrderDate := Format(Temp_SalesHeader."Order Date", 0, '20<Year>-<Month,2>-<Day,2>T08:00:00');
        body := '{"PRINT_REQUEST": {"LABEL_TYPE": "CARRIERDESPATCH","RESPONSE_FORMAT": "PNG","LABEL_SIZE": "SIZE_6X4","LABEL_DPI": "DPI_203",' +
                '"ORDER": {"NUMBER": "' + Temp_SalesHeader."Applies-to ID" + '","DATE": "' + OrderDate + '"}}}';
        //body := '{"PRINT_REQUEST": {"LABEL_TYPE": "CARRIER","RESPONSE_FORMAT": "PNG","LABEL_SIZE": "SIZE_6X4","LABEL_DPI": "DPI_203",' +
        //        '"ORDER": {"NUMBER": "1284983V","DATE": "2021-05-28T08:00:00"}}}';
        content.WriteFrom(body);

        content.GetHeaders(headers);
        headers.Clear();
        headers.Add('Content-Type', 'application/json');

        //ServiceURL := 'https://app-very-uat.commerce.blujaysolutions.net/PrintRequest/';

        if client.Post(ServiceURL, content, responseMessage) then begin
            if responseMessage.HttpStatusCode = 200 then begin
                responseMessage.Content.ReadAs(response);
                jObject.ReadFrom(response);
                printResponseObject := GetJsonToken(jObject, 'PRINT_RESPONSE').AsObject();
                InsertInShipmentTracking(printResponseObject, Temp_SalesHeader);
            end
            else begin
                Clear(response);
                responseMessage.Content.ReadAs(response);
                Temp_SalesHeader."Bill-to Name" := CopyStr(response, 1, 100);
                Temp_SalesHeader.Modify();
            end;
        end;
    end;


    local procedure InsertInShipmentTracking(printResponseObject: JsonObject; var P_SalesHeader: Record "Sales Header" temporary)
    var
        ShipmentTrack: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
        OutStm1: OutStream;
        TestOutStm: OutStream;
        InStm: InStream;
        CarrierDataArray: JsonArray;
        CarrierDataCount: Integer;
        CarrierDataToken: JsonToken;
        CarrierDataObject: JsonObject;
        LabelDataObject: JsonObject;
        ParcelObjet: JsonObject;
        CarrierObject: JsonObject;
        CarrierTrackingObject: JsonObject;
        DespatchNoteObject: JsonObject;
        i: Integer;
        orderNumber: Code[20];
        CarrierName: Text[50];
        TrackingNumber: Text[30];
        Base64StringLabel: Text;
        Base64Despatch: Text;
        FileTest: File;
        Tempblob: Codeunit "Temp Blob";
        Data: BigText;
        filename: Text;
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        ShipmentTrack.INIT;
        ShipmentTrack.VALIDATE("Document Type", ShipmentTrack."Document Type"::Order);
        ShipmentTrack.Validate("Document No.", P_SalesHeader."No.");
        ShipmentTrack.Validate("Shipping Agent Code", P_SalesHeader."Shipping Agent Code");
        ShipmentTrack.VALIDATE("Shipping Agent Service Code", P_SalesHeader."Shipping Agent Service Code");
        ShipmentTrack.Validate("Entry Created", Today);

        if P_SalesHeader."Customer Posting Group" = '' then begin
            CarrierDataObject := GetJsonToken(printResponseObject, 'CMS_CARRIER_DATA').AsObject();
            CarrierTrackingObject := GetJsonToken(CarrierDataObject, 'CARRIER_TRACKING_DETAILS').AsObject();

            Clear(TrackingNumber);
            TrackingNumber := CopyStr(GetJsonvalue(CarrierTrackingObject, 'TRACKINGID').AsText(), 1, 30);
            ShipmentTrack.VALIDATE("Tracking No.", TrackingNumber);

        end
        else begin
            CarrierDataArray := GetJsonToken(printResponseObject, 'CMS_CARRIER_DATA').AsArray();
            CarrierDataCount := CarrierDataArray.Count;

            if CarrierDataCount > 0 then begin
                for i := 0 to CarrierDataCount - 1 do begin
                    CarrierDataArray.Get(i, CarrierDataToken);
                    CarrierDataObject := CarrierDataToken.AsObject;
                    Clear(orderNumber);
                    orderNumber := CopyStr(GetJsonvalue(CarrierDataObject, 'ORDER_NUMBER').AsCode(), 1, 20);
                    if (orderNumber = P_SalesHeader."Applies-to ID") then begin
                        CarrierTrackingObject := GetJsonToken(CarrierDataObject, 'CARRIER_TRACKING_DETAILS').AsObject();
                        Clear(TrackingNumber);
                        TrackingNumber := CopyStr(GetJsonvalue(CarrierTrackingObject, 'TRACKINGID').AsText(), 1, 30);
                        ShipmentTrack.VALIDATE("Tracking No.", TrackingNumber);
                    end;
                end;
            end;
        end;

        Clear(CarrierName);
        CarrierName := CopyStr(GetJsonvalue(CarrierDataObject, 'CARRIER_NAME').AsText(), 1, 50);
        ShipmentTrack.Validate("Shipping Agent Code", CopyStr(CarrierName, 1, 10));

        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("No.", P_SalesHeader."No.");
        if L_InterimSalesHeader.FindFirst() then begin
            L_InterimSalesHeader."Shipping Agent Code" := CopyStr(CarrierName, 1, 10);
            if L_InterimSalesHeader."Package Tracking No." = '' then begin
                L_InterimSalesHeader."Package Tracking No." := TrackingNumber;
            end;
            L_InterimSalesHeader.Modify(true);
        end;

        IF RecShipmentTracking.FINDLAST THEN
            ShipmentTrack."Entry No." := RecShipmentTracking."Entry No." + 1
        ELSE
            ShipmentTrack."Entry No." := 1;

        LabelDataObject := GetJsonToken(printResponseObject, 'CMS_LABEL_DATA').AsObject();
        ParcelObjet := GetJsonToken(LabelDataObject, 'PARCEL').AsObject();
        CarrierObject := GetJsonToken(ParcelObjet, 'CARRIER').AsObject();
        Base64StringLabel := GetJsonvalue(CarrierObject, 'BASE64_DATA').AsText();

        IF (Base64StringLabel <> '') THEN BEGIN
            ShipmentTrack.CalcFields(Label);
            ShipmentTrack.Label.CreateOutStream(OutStm);
            Base64Convert.FromBase64(Base64StringLabel, OutStm);
        END;

        if LabelDataObject.Contains('DESPATCHNOTE') then begin
            DespatchNoteObject := GetJsonToken(LabelDataObject, 'DESPATCHNOTE').AsObject();
            Base64Despatch := GetJsonvalue(DespatchNoteObject, 'BASE64_DATA').AsText();

            if (Base64Despatch <> '') then begin
                ShipmentTrack.CalcFields("A6 Label1");
                ShipmentTrack."A6 Label1".CreateOutStream(OutStm1);
                Base64Convert.FromBase64(Base64Despatch, OutStm1);

                // ShipmentTrack."A6 Label1".CreateInStream(InStm);
                // filename := 'DespatchNote.pdf';
                // DownloadFromStream(InStm, '', '', '', filename);
            end;
        end;

        ShipmentTrack.INSERT;
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