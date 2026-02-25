codeunit 90040 "PS Manifest File Job"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        if StrPos(Rec."Parameter String", ';') > 0 then begin
            StartParameter := CopyStr(Rec."Parameter String", 1, StrPos(Rec."Parameter String", ';') - 1);
            RunType := CopyStr(
                Rec."Parameter String",
                StrPos(Rec."Parameter String", ';') + 1);
        end;

        case RunType of
            'PolarSpeed':
                UploadManifestFileToContainer();
        end;
    end;

    local procedure UploadManifestFileToContainer()
    var
        OutStr: OutStream;
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
        Manifest: XmlPort Manifest;
        FileName: Text;
        ShipDate: Date;
        i: Integer;
    begin
        ShipDate := WorkDate();
        for i := 0 to 1 do begin
            Clear(TempBlob);
            Clear(Manifest);

            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);

            Manifest.GetFilters(ShipDate, i);
            Manifest.SetDestination(OutStr);
            Manifest.Export();

            FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', ShipDate));
            TempBlob.CreateInStream(InStr, TextEncoding::UTF8);

            UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
        end;
    end;

    local procedure UploadFileToEDIAzureContainer(
        var FileInStream: InStream;
        FileName: Text;
        ChannelCode: Code[20])
    var
        Authorization: Interface "Storage Service Authorization";
        StorageAuth: Codeunit "Storage Service Authorization";
        BlobClient: Codeunit "ABS Blob Client";
        Response: Codeunit "ABS Operation Response";
    begin
        GetCredentials(ChannelCode);

        Authorization := StorageAuth.CreateSharedKey(SharedAccessKey);
        BlobClient.Initialize(StorageAccountName, OutgoingContainerName, Authorization);
        Response := BlobClient.PutBlobBlockBlobStream(FileName, FileInStream);
    end;

    local procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        if TradePartner.Get(ChannelCode) then begin
            OutgoingContainerName := TradePartner."Order Acknow. Container Name";
            StorageAccountName := TradePartner."Storage Account Name";
            SharedAccessKey := TradePartner."Shared Access Key";
        end;
    end;

    local procedure GetFileName(FileDate: Date): Text
    var
        Y: Text[4];
        M: Text[2];
        D: Text[2];
        T: Text[6];
    begin
        Y := Format(Date2DMY(FileDate, 3));
        M := PadStr(Format(Date2DMY(FileDate, 2)), 2, '0');
        D := PadStr(Format(Date2DMY(FileDate, 1)), 2, '0');
        T := Format(Time(), 0, '<Hours,2><Minutes,2><Seconds,2>');
        exit('Sigma-' + Y + M + D + T + '.csv');
    end;

    var
        StartParameter: Text;
        RunType: Text;
        OutgoingContainerName: Text;
        StorageAccountName: Text;
        SharedAccessKey: SecretText;
}
