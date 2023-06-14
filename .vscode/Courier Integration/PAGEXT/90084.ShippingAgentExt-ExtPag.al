pageextension 90084 "Shipping Agent Ext" extends "Shipping Agents"
{
    layout
    {
        addafter("Internet Address")
        {
            field("API URL"; Rec."API URL")
            {
                ApplicationArea = All;
            }
            field("Access Key"; Rec."Access Key")
            {
                ApplicationArea = All;
            }
            field("Secret Key"; Rec."Secret Key")
            {
                ApplicationArea = All;
            }
            field("Business Account No"; Rec."Business Account No")
            {
                ApplicationArea = All;
            }
            field("Access Token"; Rec."Access Token")
            {
                ApplicationArea = All;
            }
            field("Refresh Token"; Rec."Refresh Token")
            {
                ApplicationArea = All;
            }
            field("Client Id"; Rec."Client Id")
            {
                ApplicationArea = All;
            }
            field("Client Secret"; Rec."Client Secret")
            {
                ApplicationArea = All;
            }
            field("Procesing Codeunit"; Rec."Procesing Codeunit")
            {
                ApplicationArea = All;
            }
            field("Printing Options"; Rec."Printing Options")
            {
                ApplicationArea = All;
            }
            field(New_AuthDate; Rec.New_AuthDate)
            {
                Caption = 'AuthDate';
                ApplicationArea = All;
            }
            field("Shipping G/L No."; Rec."Shipping G/L No.")
            {
                ApplicationArea = All;
            }

        }
    }

    actions
    {
        addafter("&Line")
        {
            action("Generate Manifest")
            {
                ApplicationArea = All;
                Image = ReleaseShipment;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;
                trigger OnAction()
                var
                    L_ShippingAgent: Record "Shipping Agent";
                    TokenDuration: Duration;
                    NoOfHours: Decimal;
                begin
                    Clear(L_ShippingAgent);
                    L_ShippingAgent := Rec;
                    CurrPage.SetSelectionFilter(L_ShippingAgent);
                    if L_ShippingAgent.FindSet() then begin
                        repeat
                            //Check if Shipping agent is Royal Mail or Not
                            if L_ShippingAgent.Code = 'RM' then begin
                                //Check if Shipping Agent has Clinet Id and Secret
                                if ((L_ShippingAgent."Client Id" <> '') and (L_ShippingAgent."Client Secret" <> '')) then begin

                                    GetCredentials(L_ShippingAgent);

                                    //Code to Check Validity of Token as Access Token is Valid For 4 Hours++
                                    if AccessToken = '' then begin
                                        AccessToken := GenerateAccessToken();
                                        L_ShippingAgent.Validate("Access Token", AccessToken);
                                        L_ShippingAgent.Validate(New_AuthDate, CreateDateTime(WorkDate, Time));
                                        L_ShippingAgent.Modify();
                                    end
                                    else begin
                                        if L_ShippingAgent.New_AuthDate <> 0DT then begin
                                            TokenDuration := CreateDateTime(WorkDate, Time) - L_ShippingAgent.New_AuthDate;
                                            NoOfHours := Round(TokenDuration / 3600000);
                                            if NoOfHours >= 3.9 then begin
                                                AccessToken := GenerateAccessToken();
                                                L_ShippingAgent.Validate("Access Token", AccessToken);
                                                L_ShippingAgent.Validate(New_AuthDate, CreateDateTime(WorkDate, Time));
                                                L_ShippingAgent.Modify();
                                            end;
                                        end;
                                    end;
                                    //Code to Check Validity of Token as Access Token is Valid For 4 Hours--

                                    GenerateManifest(L_ShippingAgent);
                                end;
                            end
                            else begin
                                Message('Manifest Generation Can Only be Done For RoyalMail Shipping Agent');
                            end;
                        until L_ShippingAgent.Next() = 0;
                    end;
                end;
            }
        }
    }


    //To Get Credentials From Shipping Agent
    local procedure GetCredentials(P_ShippingAgent: Record "Shipping Agent")
    var
    begin
        Username := P_ShippingAgent."Access Key";
        Password := P_ShippingAgent."Secret Key";
        ServiceURL := P_ShippingAgent."API URL";
        ClientID := P_ShippingAgent."Client Id";
        ClientSecret := P_ShippingAgent."Client Secret";
        AccessToken := P_ShippingAgent."Access Token";
    end;


    //To Generate Access Token
    local procedure GenerateAccessToken(): Text
    var
        client: HttpClient;
        headers: HttpHeaders;
        content: HttpContent;
        URL: Text;
        responseMessage: HttpResponseMessage;
        response: Text;
        jObject: JsonObject;
        TokenResponsetext: Text;
    begin
        headers := client.DefaultRequestHeaders;
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


    local procedure GenerateManifest(P_ShippingAgent: Record "Shipping Agent")
    var
        ManifestClient: HttpClient;
        ManifestHeaders: HttpHeaders;
        ManifestContent: HttpContent;
        ManifestBody: Text;
        ManifestURL: Text;
        ManifestResponseMessage: HttpResponseMessage;
        ManifestResponse: Text;
        ManifestJObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        ManifestObject: JsonObject;
        ManifestImage: Text;
        TempBlob: Codeunit "Temp Blob";
        OutStm: OutStream;
        InStrm: InStream;
        FileName: Text;
        ConvertBase64: Codeunit "Base64 Convert";
        ErrorJObject: JsonObject;
        ErrorJArray: JsonArray;
        ErrorJToken: JsonToken;
        ErrorObject: JsonObject;
    begin
        ManifestHeaders := ManifestClient.DefaultRequestHeaders;
        ManifestURL := ServiceURL + 'manifests';

        ManifestHeaders.Add('Accept', 'application/json');

        ManifestBody := '{"PostingLocation":"9000062214"}';
        ManifestContent.WriteFrom(ManifestBody);
        ManifestContent.GetHeaders(ManifestHeaders);
        ManifestHeaders.Clear();
        ManifestHeaders.Add('Content-Type', 'application/json');
        ManifestHeaders.Add('X-IBM-Client-Id', ClientID);
        ManifestHeaders.Add('X-RMG-Auth-Token', AccessToken);

        if ManifestClient.Post(ManifestURL, ManifestContent, ManifestResponseMessage) then begin
            if ManifestResponseMessage.HttpStatusCode = 200 then begin
                ManifestResponseMessage.Content.ReadAs(ManifestResponse);
                ManifestJObject.ReadFrom(ManifestResponse);
                JArray := GetJsonToken(ManifestJObject, 'Manifests').AsArray();

                JArray.Get(0, JToken);
                ManifestObject := JToken.AsObject();
                ManifestImage := GetJsonvalue(ManifestObject, 'ManifestImage').AsText();

                if ManifestImage.Contains('"') then begin
                    ManifestImage := ManifestImage.Replace('"', '');
                end;

                if ManifestImage <> '' then begin
                    P_ShippingAgent.CalcFields(Manifest);
                    P_ShippingAgent.Manifest.CreateOutStream(OutStm);
                    ConvertBase64.FromBase64(ManifestImage, OutStm);
                    P_ShippingAgent.Modify(true);

                    P_ShippingAgent.CalcFields(Manifest);
                    P_ShippingAgent.Manifest.CreateInStream(InStrm);
                    FileName := 'RoyalMailManifest-' + Format(WorkDate()) + '.pdf';
                    DownloadFromStream(InStrm, '', '', '', FileName);
                end;
            end
            else begin
                ManifestResponseMessage.Content.ReadAs(ManifestResponse);
                ErrorJObject.ReadFrom(ManifestResponse);
                ErrorJArray := GetJsonToken(ErrorJObject, 'Errors').AsArray();
                ErrorJArray.Get(0, ErrorJToken);
                ErrorObject := ErrorJToken.AsObject();
                Message(GetJsonvalue(ErrorObject, 'Message').AsText());
            end;
        end;
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


    procedure GetJsonToken(var JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then;
    end;


    var
        Username: Text;
        Password: Text;
        ServiceURL: Text;
        ClientID: Text;
        ClientSecret: Text;
        AccessToken: Text[250];
}