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
        xmlmio06cc: XmlPort mio06cc;
        xmlmio24: XmlPort mio24;
        xmlmio03: XmlPort mio03;
        xmlmio06su: XmlPort mio06su;
        xmlmio01: XmlPort mio01;
        xmlmio47: XmlPort mio47;
        xmlmio10: XmlPort mio10;
        xmlmio0617: XmlPort mio0617;
        xmlmio06cl: XmlPort mio06cl;
        xmlmio06con: XmlPort mio06con;
        xmlmio06cr: XmlPort mio06cr;
        xmlmio06dp: XmlPort mio06dp;
        xmlmio06mc: XmlPort mio06mc;
        xmlmio06oc: XmlPort mio06oc;
        xmlmio06rd: XmlPort mio06rd;
        xmlmio06rp: XmlPort mio06rp;
        xmlmio06tm: XmlPort mio06tm;
        xmlmio06vt: XmlPort mio06vt;
        xmlmio06cu: XmlPort mio06cu;
        xmlmio06pg: XmlPort mio06pg;
        xmlmio09: XmlPort mio09;
        xmlmio86: XmlPort mio86;
        xmlproductsc: XmlPort "productsc File";
        xmlsigusage: XmlPort "sigusage File";
        xmlmio82: XmlPort mio82;
        xmlcontractprices: XmlPort "Contract Price Lists";
        xmlmio06ct: XmlPort mio06ct;
        xmlproductvariant: XmlPort "Product variant";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
        FileName: Text;
    begin

        #region "mio24" 01
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio24.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio24.SetDestination(XMLOutStream);
        xmlmio24.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio03" 02
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio03.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio03.SetDestination(XMLOutStream);
        xmlmio03.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06su" 03
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06su.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06su.SetDestination(XMLOutStream);
        xmlmio06su.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio01" 04
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio01.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio01.SetDestination(XMLOutStream);
        xmlmio01.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio47" 05
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio47.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio47.SetDestination(XMLOutStream);
        xmlmio47.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio10" 06
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio10.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio10.SetDestination(XMLOutStream);
        xmlmio10.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio0617" 07
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio0617.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio0617.SetDestination(XMLOutStream);
        xmlmio0617.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06cc" 08
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06cc.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06cc.SetDestination(XMLOutStream);
        xmlmio06cc.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06cl" 09
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06cl.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06cl.SetDestination(XMLOutStream);
        xmlmio06cl.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06con" 10
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06con.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06con.SetDestination(XMLOutStream);
        xmlmio06con.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06cr" 11
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06cr.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06cr.SetDestination(XMLOutStream);
        xmlmio06cr.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06dp" 12
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06dp.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06dp.SetDestination(XMLOutStream);
        xmlmio06dp.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06mc" 13
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06mc.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06mc.SetDestination(XMLOutStream);
        xmlmio06mc.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06oc" 14
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06oc.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06oc.SetDestination(XMLOutStream);
        xmlmio06oc.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06rd" 15
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06rd.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06rd.SetDestination(XMLOutStream);
        xmlmio06rd.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06rp" 16
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06rp.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06rp.SetDestination(XMLOutStream);
        xmlmio06rp.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06tm" 17
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06tm.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06tm.SetDestination(XMLOutStream);
        xmlmio06tm.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06vt" 18
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06vt.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06vt.SetDestination(XMLOutStream);
        xmlmio06vt.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06cu" 19
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06cu.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06cu.SetDestination(XMLOutStream);
        xmlmio06cu.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06pg" 20
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06pg.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06pg.SetDestination(XMLOutStream);
        xmlmio06pg.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio09" 21
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio09.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio09.SetDestination(XMLOutStream);
        xmlmio09.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio86" 22
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio86.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio86.SetDestination(XMLOutStream);
        xmlmio86.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "productsc" 23
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'productsc.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlproductsc.SetDestination(XMLOutStream);
        xmlproductsc.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "sigusage" 24
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'sigusage.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlsigusage.SetDestination(XMLOutStream);
        xmlsigusage.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio82" 25
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio82.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio82.SetDestination(XMLOutStream);
        xmlmio82.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "contractprices" 26
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'contractprices.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlcontractprices.SetDestination(XMLOutStream);
        xmlcontractprices.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "mio06ct" 27
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'mio06ct.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlmio06ct.SetDestination(XMLOutStream);
        xmlmio06ct.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion

        #region "productvariant" 28
        Clear(TempBlob);
        Clear(XMLInStream);
        Clear(XMLOutStream);
        FileName := 'productvariant.csv';
        TempBlob.CreateOutStream(XMLOutStream);
        xmlproductvariant.SetDestination(XMLOutStream);
        xmlproductvariant.Export();
        TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // DownloadFromStream(XMLInStream, '', '', '', FileName);
        UploadFileToEDIAzureContainer(XMLInStream, FileName, StartParameter);
        #endregion




    end;

    local procedure UploadFileToEDIAzureContainer(var P_FileInstream: InStream; P_FileName: Text; P_ChannelCode: Code[20])
    var
        Authorization: Interface "Storage Service Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        ABSBlobClient: Codeunit "ABS Blob Client";
        Response: Codeunit "ABS Operation Response";

    begin
        GetCredentials(P_ChannelCode);
        Clear(Authorization);
        Clear(StorageServiceAuthorization);
        Authorization := StorageServiceAuthorization.CreateSharedKey(SharedAccessKey);

        Clear(ABSBlobClient);
        ABSBlobClient.Initialize(StorageAccountName, OutgoingContainerName, Authorization);

        Clear(Response);
        Response := ABSBlobClient.PutBlobBlockBlobStream(P_FileName, P_FileInstream);
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


}

