codeunit 90030 "Datawarehouse-WebDezign"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        IF (STRPOS(Rec."Parameter String", ';')) > 0 THEN begin
            StartParameter := COPYSTR(Rec."Parameter String", 1, (STRPOS(Rec."Parameter String", ';') - 1));
            RunType := COPYSTR(Rec."Parameter String", (STRPOS(Rec."Parameter String", ';') + 1), (STRLEN(Rec."Parameter String") - STRPOS(Rec."Parameter String", ';')));
        end;

        CASE RunType OF

            Datawarehouse:
                begin

                    UploadFileToContainer();

                end;


        end;
    end;

    local procedure UploadFileToContainer()
    var
        TempBlob: Codeunit "Temp Blob";
        xmlmio10: XmlPort mio10;
        XMLOutStream: OutStream;
        XMLInStream: InStream;
        FileName: Text;
    begin
        #Region mio10
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio10.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio10.SetDestination(XMLOutStream);
        xmlmio10.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        DownloadFromStream(XMLInStream, '', '', '', FileName);
        //UploadFileToEDIAzureContainer(XMLInStream, xmlmio10, TradepartnerRecord.Code);
        #endregion

    end;

    local procedure UploadFileToEDIAzureContainer(var P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
    var
        ArchiveAuthorization: Interface "Storage Service Authorization";
        ArchiveStorageServiceAuthorization: Codeunit "Storage Service Authorization";
        GetFileABSBlobClient: Codeunit "ABS Blob Client";
        GetFileResponse: Codeunit "ABS Operation Response";
        FileInstream: InStream;
        ArchiveABSBlobClient: Codeunit "ABS Blob Client";
        DeleteABSBlobClient: Codeunit "ABS Blob Client";
        ArchiveResponse: Codeunit "ABS Operation Response";
        DeleteResponse: Codeunit "ABS Operation Response";
    begin
        GetCredentials(P_ChannelCode);

        Clear(ArchiveAuthorization);
        Clear(ArchiveStorageServiceAuthorization);
        ArchiveAuthorization := ArchiveStorageServiceAuthorization.CreateSharedKey(SharedAccessKey);

        #Region Upload File in Archive Container and Delete from Order Container
        Clear(ArchiveABSBlobClient);
        ArchiveABSBlobClient.Initialize(StorageAccountName, ArchiveContainerName, ArchiveAuthorization);

        Clear(ArchiveResponse);
        ArchiveResponse := ArchiveABSBlobClient.PutBlobBlockBlobStream(P_FileName, FileInstream);

        #endregion
    end;

    local procedure GetCredentials(ChannelCode: Code[20])
    var
        TradePartner: Record "Trade Partner";
    begin
        TradePartner.Reset();
        if TradePartner.Get(ChannelCode) then begin
            OutgoingContainerName := TradePartner."Order Acknow. Container Name";
            StorageAccountName := TradePartner."Storage Account Name";
            SharedAccessKey := TradePartner."Shared Access Key";

        End;
    end;

    var
        StartParameter: Text;
        RunType: Text;
        Datawarehouse: Label 'Datawarehouse';
        outgoingContainerName: Text;
        OutgoingSasToken: Text;
        StorageAccountName: Text;
        SharedAccessKey: SecretText;
        ArchiveContainerName: Text;
}

