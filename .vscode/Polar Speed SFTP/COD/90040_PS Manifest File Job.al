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
                UploadManifestFileToContainer(StartParameter);
        end;
    end;

    procedure UploadManifestFileToContainer(_ChannelCode: Code[20])
    var
        OutStr: OutStream;
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
        Manifest: XmlPort "PS Manifest File";
        FileName: Text;
        ShipDate: Date;
        i: Integer;
        PSLableQuery: Query "PS Lable Query";
        PsLabelDetails: Record "Polar Speed Barcode Details";
        sales_receivable: Record "Sales & Receivables Setup";
    begin
        sales_receivable.Get();
        #Region Check Mandatory fields++
        if _ChannelCode = '' then
            Error('Channel Code is missing in request parameter');
        CheckMadatoryfields(_ChannelCode);
        #EndRegion Check Mandatory fields++

        #Region Credential Check++
        GetCredentials(_ChannelCode);
        #EndRegion Credential Check++

        // //Starte Process++
        // Clear(PSLableQuery);
        // PSLableQuery.SetRange(PSLableQuery.Shipment_Date, WorkDate());
        // PSLableQuery.Open();
        // while PSLableQuery.Read() do begin
        //     for i := 0 to 1 do begin
        //         Clear(TempBlob);
        //         Clear(Manifest);

        //         TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        //         Manifest.GetFilters(WorkDate(), i, PSLableQuery.Temprature);
        //         Manifest.SetDestination(OutStr);
        //         Manifest.Export();

        //         FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', WorkDate()));
        //         TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        //         UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
        //     end;
        // end;

        //Start  Process++
        //Chilled

        PsLabelDetails.Reset();
        PsLabelDetails.SetRange(Temprature, 'Chilled');
        PsLabelDetails.SetRange("Print Date", WorkDate());
        if PsLabelDetails.FindFirst() then begin
            if sales_receivable."Send Collection File" = true then begin
                for i := 0 to 1 do begin
                    Clear(TempBlob);
                    Clear(Manifest);

                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Manifest.GetFilters(WorkDate(), i, 'Chilled');
                    Manifest.SetDestination(OutStr);
                    Manifest.Export();

                    FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', WorkDate()));
                    TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
                    UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
                end;
            end else begin
                Clear(TempBlob);
                Clear(Manifest);
                i := 0;
                TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                Manifest.GetFilters(WorkDate(), i, 'Chilled');
                Manifest.SetDestination(OutStr);
                Manifest.Export();

                FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', WorkDate()));
                TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
                UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
            end;
        end;

        //Ambient
        if sales_receivable."Send Collection File" = true then begin
            for i := 0 to 1 do begin
                Clear(TempBlob);
                Clear(Manifest);

                TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                Manifest.GetFilters(WorkDate(), i, 'Ambient');
                Manifest.SetDestination(OutStr);
                Manifest.Export();

                FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', WorkDate()));
                TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
                UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
            end;
        end else begin
            i := 0;
            Clear(TempBlob);
            Clear(Manifest);

            TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
            Manifest.GetFilters(WorkDate(), i, 'Ambient');
            Manifest.SetDestination(OutStr);
            Manifest.Export();

            FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', WorkDate()));
            TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
            UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
        end;





        // Clear(ShipDate);
        // ShipDate := WorkDate();
        // for i := 0 to 1 do begin
        //     Clear(TempBlob);
        //     Clear(Manifest);

        //     TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        //     Manifest.GetFilters(ShipDate, i);
        //     Manifest.SetDestination(OutStr);
        //     Manifest.Export();

        //     FileName := GetFileName(CalcDate('<' + Format(i) + 'D>', ShipDate));
        //     TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        //     UploadFileToEDIAzureContainer(InStr, FileName, StartParameter);
        // end;
    end;


    local procedure CheckMadatoryfields(_ChannelCode: Code[20])
    var
        L_TradePartner: Record "Trade Partner";
    begin
        L_TradePartner.Reset();
        L_TradePartner.SetRange(Code, _ChannelCode);
        if L_TradePartner.FindFirst() then begin
            L_TradePartner.TestField("Storage Account Name");
            L_TradePartner.TestField("Shared Access Key");
            L_TradePartner.TestField("Order Acknow. Container Name");
        end else
            Error('Trade Partner setup missing for %1', _ChannelCode);
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
        Authorization := StorageAuth.CreateSharedKey(SharedAccessKey);
        BlobClient.Initialize(StorageAccountName, OutgoingContainerName, Authorization);
        Response := BlobClient.PutBlobBlockBlobStream(FileName, FileInStream);
    end;

    local procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        Clear(OutgoingContainerName);
        Clear(StorageAccountName);
        Clear(SharedAccessKey);
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
        M := Format(Date2DMY(FileDate, 2));
        if STRLEN(M) = 1 then
            M := '0' + M;
        D := Format(Date2DMY(FileDate, 1));
        if STRLEN(D) = 1 then
            D := '0' + D;
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
