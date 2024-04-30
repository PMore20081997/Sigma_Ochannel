codeunit 90030 "Sigma FTP Integration"
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
                    ReadContainerfile(StartParameter);

                    G_TradePartner.Reset();
                    if G_TradePartner.Get(StartParameter) then begin
                        G_TradePartner."Last Order Sync" := CurrentDateTime;
                        G_TradePartner.Modify();
                    end;
                    Message('Order Sync Completed');
                End;
        end;

    end;

    var
        StartParameter: Text;
        RunType: Text;
        SyncOrderLabel: Label 'SyncOrder';
        TempCSVBuffer: Record "CSV Buffer" temporary;
        G_TradePartner: Record "Trade Partner";
        G_StorageName: Text;
        G_AccessKey: Text;
        G_IncomingContainerName: Text;

    local procedure ReadContainerfile(P_ChannelCode: Code[20])
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSBlobClient: Codeunit "ABS Blob Client";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Authorization: Interface "Storage Service Authorization";
        instr: Instream;
        AccountAccessKey: text;
        AccountName: Text;
        AccountContainer: Text;
        filename: Text;
        ABSContainerContent: Record "ABS Container Content";
        L_TradPartner: Record "Trade Partner";
    begin
        ClearLastError();

        //Get Credentials++
        //GetCredentials(P_ChannelCode);

        //Start process to read files from azure container++
        // AccountName := G_StorageName;
        // AccountAccessKey := G_AccessKey;
        // AccountContainer := G_IncomingContainerName;
        AccountName := 'sigmaplc2';
        AccountAccessKey := 'zyB/uq/85iwkagIIk0G4nDZXF/3jPUp8LKFQcC9ikAdt5p5AzptjcN/z1/O69UGsi+HJxJ7mwhfR+AStOAQVEA==';
        AccountContainer := 'orders';
        Authorization := StorageServiceAuthorization.CreateSharedKey(AccountAccessKey);
        ABSBlobClient.Initialize(AccountName, AccountContainer, Authorization);
        ABSOperationResponse := ABSBlobClient.ListBlobs(ABSContainerContent);
        if ABSOperationResponse.IsSuccessful() then begin
            ABSContainerContent.Reset();
            if ABSContainerContent.FindSet() then
                repeat
                    Clear(instr);
                    ABSOperationResponse := ABSBlobClient.GetBlobAsStream(ABSContainerContent.Name, instr);
                    if ABSOperationResponse.IsSuccessful() then
                        Message('File read successfully.');
                until ABSContainerContent.Next() = 0;
        end;
    end;


    local procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        Clear(G_StorageName);
        Clear(G_AccessKey);
        Clear(G_IncomingContainerName);
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            G_StorageName := TradePartner."Incoming Orders Conatiner Name";
            G_AccessKey := TradePartner."Incoming Orders Token";
            G_IncomingContainerName := TradePartner."Status Conatiner Name";
        End;
    end;
}