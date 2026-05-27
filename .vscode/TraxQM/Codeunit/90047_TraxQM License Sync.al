codeunit 90047 "TraxQM License Sync"
{
    trigger OnRun()
    begin

    end;

    var
        AccessKeyId: Text;
        SecretAccessKey: Text;
        ServiceURL: Text;
        CachedToken: Text;

    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: Text) aJsonValue: JsonValue
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        else
            aJsonValue := aJsonToken.AsValue();
    end;

    procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
        InStr: InStream;
        TokenText: Text;
    begin
        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            AccessKeyId := TradePartner.AccessKeyId;
            SecretAccessKey := TradePartner.SecretAccessKey;
            ServiceURL := TradePartner."Sevice/API URL";

            TradePartner.CalcFields(Token);
            if TradePartner.Token.HasValue then begin
                TradePartner.Token.CreateInStream(InStr);
                InStr.ReadText(TokenText);
                CachedToken := TokenText;
            end;
        end else
            Error('Trade Partner %1 not found. Please check the TraxQM setup.', ChannelCode);
    end;

    procedure GetCDToken(): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpResponseMessage: HttpResponseMessage;
        URL: Text;
        ResponseBody: Text;
        JsonObject: JsonObject;
        NewToken: Text;
        RequestBody: Text;
    begin
        URL := 'https://auth.codesplice.com/oauth2/token';

        RequestBody := StrSubstNo(
            'grant_type=client_credentials&client_id=%1&client_secret=%2&scope=sigma/read',
            AccessKeyId,
            SecretAccessKey
        );

        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        if HttpClient.Post(URL, HttpContent, HttpResponseMessage) then begin
            HttpResponseMessage.Content.ReadAs(ResponseBody);
            if HttpResponseMessage.HttpStatusCode = 200 then begin
                JsonObject.ReadFrom(ResponseBody);
                NewToken := GetJsonvalue(JsonObject, 'access_token').AsText();

            end else
                Error('Failed to obtain Sigma access token.\HTTP Status: %1\Response: %2',
                    HttpResponseMessage.HttpStatusCode, ResponseBody);
        end else
            Error('Could not connect to auth.codesplice.com.\Please check your internet connection and TraxQM setup.');

        exit(NewToken);
    end;

    local procedure EnsureValidToken(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
        TokenDuration: Duration;
        NoOfHours: Decimal;
    begin
        if CachedToken = '' then begin
            CachedToken := GetCDToken();
            SaveTokenToSetup(ChannelCode, CachedToken);
            exit;
        end;

        TradePartner.RESET;
        if TradePartner.Get(ChannelCode) then begin
            if TradePartner."Auth Date" <> 0DT then begin
                TokenDuration := CreateDateTime(WorkDate, Time) - TradePartner."Auth Date";
                NoOfHours := TokenDuration / 3600000;

                if NoOfHours >= 0.9 then begin
                    CachedToken := GetCDToken();
                    SaveTokenToSetup(ChannelCode, CachedToken);
                end;
            end else begin
                CachedToken := GetCDToken();
                SaveTokenToSetup(ChannelCode, CachedToken);
            end;
        end;
    end;

    local procedure SaveTokenToSetup(ChannelCode: Code[20]; NewToken: Text)
    var
        TradePartner: Record "Trade Partner";
        OutStr: OutStream;
    begin
        TradePartner.RESET;
        TradePartner.SetRange(Code, ChannelCode);
        if TradePartner.FindFirst() then begin
            TradePartner.Token.CreateOutStream(OutStr);
            OutStr.WriteText(NewToken);
            TradePartner.Validate("Auth Date", CreateDateTime(WorkDate, Time));
            TradePartner.Modify();
        end;
    end;

    // ─── Change Log Helpers ───────────────────────────────────────────────────

    /// <summary>
    /// Captures field-level differences between the snapshot taken before the sync
    /// and the record state after the sync, then writes one log entry per changed
    /// (or unchanged) field so a full audit trail is available.
    /// </summary>
    procedure InsertLogLine(FieldCaption: Text[100]; OldVal: Text[250]; NewVal: Text[250]; var CompanyLicHdr: Record "Company License Header";
        SyncStatusValue: Option;
        HttpStatusCode: Integer;
        ErrorMsg: Text)
    var
        LogEntry: Record "License Sync Log";
    begin
        LogEntry.Init();
        LogEntry."License No." := CompanyLicHdr."License No.";
        LogEntry."Sync DateTime" := CreateDateTime(WorkDate, Time);
        LogEntry."Synced By" := CopyStr(UserId, 1, 50);
        LogEntry."Field Name" := FieldCaption;
        LogEntry."Old Value" := OldVal;
        LogEntry."New Value" := NewVal;
        LogEntry."Sync Status" := SyncStatusValue;
        LogEntry."HTTP Status" := HttpStatusCode;
        LogEntry."Error Message" := CopyStr(ErrorMsg, 1, 500);
        //LogEntry."Batch ID" := BatchId;
        LogEntry.Insert();
    end;

    local procedure WriteChangeLog(
        var CompanyLicHdr: Record "Company License Header";
        //BatchId: Guid;
        OldVerificationDate: Date;
        OldExpiryDate: Date;
        OldReviewDate: Date;
        OldVerifiedBy: Text;
        OldSynced: Boolean;
        SyncStatusValue: Option;
        HttpStatusCode: Integer;
        ErrorMsg: Text
    )


    begin
        // Verification Date
        InsertLogLine(
            'Verification Date',
            FormatDateForLog(OldVerificationDate),
            FormatDateForLog(CompanyLicHdr."Verification Date"), CompanyLicHdr, SyncStatusValue, HttpStatusCode, ErrorMsg
        );

        // Expiry Date
        InsertLogLine(
            'Expiry Date',
            FormatDateForLog(OldExpiryDate),
            FormatDateForLog(CompanyLicHdr."Expiry Date"), CompanyLicHdr, SyncStatusValue, HttpStatusCode, ErrorMsg
        );

        // Review Date
        InsertLogLine(
            'Review Date',
            FormatDateForLog(OldReviewDate),
            FormatDateForLog(CompanyLicHdr."Review Date"), CompanyLicHdr, SyncStatusValue, HttpStatusCode, ErrorMsg
        );

        // Verified By
        InsertLogLine(
            'Verified By',
            CopyStr(OldVerifiedBy, 1, 250),
            CopyStr(CompanyLicHdr."Verified By", 1, 250), CompanyLicHdr, SyncStatusValue, HttpStatusCode, ErrorMsg
        );

        // Synced (boolean flag)
        InsertLogLine(
            'Synced',
            Format(OldSynced),
            Format(CompanyLicHdr.Synced), CompanyLicHdr, SyncStatusValue, HttpStatusCode, ErrorMsg
        );
    end;

    local procedure FormatDateForLog(d: Date): Text[250]
    begin
        if d = 0D then
            exit('(blank)');
        exit(CopyStr(Format(d, 0, '<Day,2>/<Month,2>/<Year4>'), 1, 250));
    end;

    // ─── API Call ─────────────────────────────────────────────────────────────

    local procedure CallTraxApi(Url: Text; Token: Text; var CompanyLicHdr: Record "Company License Header"): Text
    var
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        ResponseText: Text;
        JsonObject: JsonObject;
        IsSuccessful: Boolean;
        ChannelCode: Code[20];
        LicNoURL: Text;
        ResultMessage: Text;
        TraxTransportErr: Label 'Could not connect to Sigma TraxQM.\URL: %1\Please check your internet connection and that sigma.traxqm.com is in the Allowed HttpClient Domains list.', Comment = '%1=URL';

        // Snapshot fields BEFORE applying API values
        BatchId: Guid;
        OldVerificationDate: Date;
        OldExpiryDate: Date;
        OldReviewDate: Date;
        OldVerifiedBy: Text;
        OldSynced: Boolean;

        SyncSuccessOpt: Option Success,Failed,"Token Refreshed";
        FinalStatus: Option Success,Failed,"Token Refreshed";
    begin
        ChannelCode := 'TRAXQM';
        LicNoURL := Url + CompanyLicHdr."License No.";

        // ── Capture pre-sync snapshot ──────────────────────────────────────────
        BatchId := CreateGuid();
        OldVerificationDate := CompanyLicHdr."Verification Date";
        OldExpiryDate := CompanyLicHdr."Expiry Date";
        OldReviewDate := CompanyLicHdr."Review Date";
        OldVerifiedBy := CompanyLicHdr."Verified By";
        OldSynced := CompanyLicHdr.Synced;

        HttpClient.Clear();
        HttpClient.Timeout := 60000;
        HttpClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', Token));
        HttpClient.DefaultRequestHeaders.Add('Accept', '*/*');
        HttpClient.DefaultRequestHeaders.Add('User-Agent', 'BusinessCentral-TraxIntegration/1.0');
        HttpClient.DefaultRequestHeaders.Add('Accept-Encoding', 'gzip, deflate, br');

        IsSuccessful := HttpClient.Get(LicNoURL, HttpResponse);

        if not IsSuccessful then
            Error(TraxTransportErr, LicNoURL);

        if HttpResponse.HttpStatusCode() = 200 then begin
            HttpResponse.Content.ReadAs(ResponseText);
            JsonObject.ReadFrom(ResponseText);

            if GetJsonvalue(JsonObject, 'Verification_Date').IsNull = false then
                CompanyLicHdr.Validate(
                    "Verification Date",
                    ParseISO8601Date(GetJsonvalue(JsonObject, 'Verification_Date').AsText())
                );

            if GetJsonvalue(JsonObject, 'Expiry_Date').IsNull = false then
                CompanyLicHdr.Validate(
                    "Expiry Date",
                    ParseISO8601Date(GetJsonvalue(JsonObject, 'Expiry_Date').AsText())
                );

            if GetJsonvalue(JsonObject, 'Review_Date').IsNull = false then
                CompanyLicHdr.Validate(
                    "Review Date",
                    ParseISO8601Date(GetJsonvalue(JsonObject, 'Review_Date').AsText())
                );

            if GetJsonvalue(JsonObject, 'Verified_By').IsNull = false then
                CompanyLicHdr.Validate(
                    "Verified By",
                    GetJsonvalue(JsonObject, 'Verified_By').AsText()
                );

            if GetJsonvalue(JsonObject, 'Synced').IsNull = false then
                CompanyLicHdr.Validate(
                    "Synced",
                    GetJsonvalue(JsonObject, 'Synced').AsBoolean()
                );

            CompanyLicHdr.Modify(true);

            // ── Write change log (success) ─────────────────────────────────────
            WriteChangeLog(
                CompanyLicHdr,
                OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                SyncSuccessOpt::Success, 200, ''
            );

            ResultMessage := StrSubstNo(
                'Licence %1 synced successfully.\' +
                'Verification Date : %2\' +
                'Expiry Date       : %3\' +
                'Review Date       : %4\' +
                'Verified By       : %5',
                CompanyLicHdr."License No.",
                Format(CompanyLicHdr."Verification Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                Format(CompanyLicHdr."Expiry Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                Format(CompanyLicHdr."Review Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                CompanyLicHdr."Verified By"
            );
        end

        else if HttpResponse.HttpStatusCode() = 401 then begin
            CachedToken := GetCDToken();
            SaveTokenToSetup(ChannelCode, CachedToken);

            HttpClient.Clear();
            HttpClient.Timeout := 60000;
            HttpClient.DefaultRequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', CachedToken));
            HttpClient.DefaultRequestHeaders.Add('Accept', '*/*');
            HttpClient.DefaultRequestHeaders.Add('User-Agent', 'BusinessCentral-TraxIntegration/1.0');
            HttpClient.DefaultRequestHeaders.Add('Accept-Encoding', 'gzip, deflate, br');

            if HttpClient.Get(LicNoURL, HttpResponse) then begin
                if HttpResponse.HttpStatusCode() = 200 then begin
                    HttpResponse.Content.ReadAs(ResponseText);
                    JsonObject.ReadFrom(ResponseText);

                    if GetJsonvalue(JsonObject, 'Verification_Date').IsNull = false then
                        CompanyLicHdr.Validate(
                            "Verification Date",
                            ParseISO8601Date(GetJsonvalue(JsonObject, 'Verification_Date').AsText())
                        );
                    if GetJsonvalue(JsonObject, 'Expiry_Date').IsNull = false then
                        CompanyLicHdr.Validate(
                            "Expiry Date",
                            ParseISO8601Date(GetJsonvalue(JsonObject, 'Expiry_Date').AsText())
                        );
                    if GetJsonvalue(JsonObject, 'Review_Date').IsNull = false then
                        CompanyLicHdr.Validate(
                            "Review Date",
                            ParseISO8601Date(GetJsonvalue(JsonObject, 'Review_Date').AsText())
                        );
                    if GetJsonvalue(JsonObject, 'Verified_By').IsNull = false then
                        CompanyLicHdr.Validate(
                            "Verified By",
                            GetJsonvalue(JsonObject, 'Verified_By').AsText()
                        );
                    if GetJsonvalue(JsonObject, 'Synced').IsNull = false then
                        CompanyLicHdr.Validate(
                            "Synced",
                            GetJsonvalue(JsonObject, 'Synced').AsBoolean()
                        );
                    CompanyLicHdr.Modify(true);

                    // ── Write change log (token refreshed, then success) ───────────
                    WriteChangeLog(
                        CompanyLicHdr,
                        OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                        SyncSuccessOpt::"Token Refreshed", 200, ''
                    );

                    ResultMessage := StrSubstNo(
                        'Licence %1 synced successfully (token was refreshed).\' +
                        'Verification Date : %2\' +
                        'Expiry Date       : %3\' +
                        'Review Date       : %4\' +
                        'Verified By       : %5',
                        CompanyLicHdr."License No.",
                        Format(CompanyLicHdr."Verification Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                        Format(CompanyLicHdr."Expiry Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                        Format(CompanyLicHdr."Review Date", 0, '<Day,2>/<Month,2>/<Year4>'),
                        CompanyLicHdr."Verified By"
                    );
                end else begin
                    HttpResponse.Content.ReadAs(ResponseText);

                    // ── Write failure log after token refresh ──────────────────────
                    WriteChangeLog(
                        CompanyLicHdr,
                        OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                        SyncSuccessOpt::Failed,
                        HttpResponse.HttpStatusCode(),
                        CopyStr(ResponseText, 1, 500)
                    );

                    ResultMessage := StrSubstNo(
                        'Licence %1: Sync failed after token refresh.\' +
                        'HTTP Status : %2\' +
                        'Response    : %3',
                        CompanyLicHdr."License No.",
                        HttpResponse.HttpStatusCode(),
                        CopyStr(ResponseText, 1, 250)
                    );
                end;
            end else begin
                // ── Write failure log (could not reconnect) ────────────────────────
                WriteChangeLog(
                    CompanyLicHdr,
                    OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                    SyncSuccessOpt::Failed, 0,
                    'Could not reconnect to Sigma after token refresh.'
                );

                ResultMessage := StrSubstNo(
                    'Licence %1: Could not reconnect to Sigma after token refresh.',
                    CompanyLicHdr."License No."
                );
            end;
        end

        else if HttpResponse.HttpStatusCode() = 403 then begin
            WriteChangeLog(
                CompanyLicHdr,
                OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                SyncSuccessOpt::Failed, 403,
                'Access denied (HTTP 403 Forbidden).'
            );

            ResultMessage := StrSubstNo(
                'Licence %1: Access denied to update the Licence (HTTP 403 Forbidden).',
                CompanyLicHdr."License No."
            );
        end

        else if HttpResponse.HttpStatusCode() = 404 then begin
            WriteChangeLog(
                CompanyLicHdr,
                OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                SyncSuccessOpt::Failed, 404,
                'Licence not found in Sigma TraxQM (HTTP 404).'
            );

            ResultMessage := StrSubstNo(
                'Licence %1 was not found in Sigma TraxQM (HTTP 404).\' +
                'No record has been updated.',
                CompanyLicHdr."License No."
            );
        end

        else begin
            HttpResponse.Content.ReadAs(ResponseText);

            WriteChangeLog(
                CompanyLicHdr,
                OldVerificationDate, OldExpiryDate, OldReviewDate, OldVerifiedBy, OldSynced,
                SyncSuccessOpt::Failed,
                HttpResponse.HttpStatusCode(),
                CopyStr(ResponseText, 1, 500)
            );

            ResultMessage := StrSubstNo(
                'Licence %1: Unexpected response from Sigma TraxQM.\' +
                'HTTP Status : %2\' +
                'Response    : %3',
                CompanyLicHdr."License No.",
                HttpResponse.HttpStatusCode(),
                CopyStr(ResponseText, 1, 250)
            );
        end;

        exit(ResultMessage);
    end;

    procedure SyncGPHCLicense(var CompanyLicHdr: Record "Company License Header")
    var
        URL: Text;
        ChannelCode: Code[20];
        ResultMessage: Text;
    begin
        ChannelCode := 'TRAXQM';

        GetCredentials(ChannelCode);

        EnsureValidToken(ChannelCode);

        if CachedToken = '' then begin
            Message('Could not obtain a Sigma access token. Sync aborted.\Please check the TraxQM Trade Partner setup.');
            exit;
        end;

        URL := 'https://sigma.traxqm.com/bc/gphc/';
        ResultMessage := CallTraxApi(URL, CachedToken, CompanyLicHdr);

        Message(ResultMessage);
    end;



    local procedure ParseISO8601Date(ISO8601Text: Text): Date
    var
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        if ISO8601Text = '' then exit(0D);
        if StrLen(ISO8601Text) < 10 then exit(0D);
        if not Evaluate(Year, CopyStr(ISO8601Text, 1, 4)) then exit(0D);
        if not Evaluate(Month, CopyStr(ISO8601Text, 6, 2)) then exit(0D);
        if not Evaluate(Day, CopyStr(ISO8601Text, 9, 2)) then exit(0D);
        exit(DMY2Date(Day, Month, Year));
    end;


}