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
        // Clear(TempBlob);
        // Clear(XMLInStream);
        // Clear(XMLOutStream);
        // FileName := 'mio47.csv';
        // TempBlob.CreateOutStream(XMLOutStream);
        // xmlmio47.SetDestination(XMLOutStream);
        // xmlmio47.Export();
        // TempBlob.CreateInStream(XMLInStream, TextEncoding::UTF8);
        // // DownloadFromStream(XMLInStream, '', '', '', FileName);
        CreateGRN();
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

    procedure CreateGRN()
    var
        Excelbuffer: Record "Excel Buffer" temporary;
        CSVBuffer: Record "CSV Buffer" temporary;
        GRNInstream: InStream;
        GRNOutstrem: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Filename: Text;
        LineNo: Integer;
        L_SalesInvoiceLine: Record "Sales Invoice Line";
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        cust: record Customer;
        L_Item: Record Item;
        CompInfo: Record "Company Information";
        sales_Shipment_Header: Record "Sales Shipment Header";
        L_SalesCreditMemoLine: Record "Sales Cr.Memo Line";
        L_SalesCreditMemoHeader: Record "Sales Cr.Memo Header";

    begin
        Clear(CSVBuffer);
        CSVBuffer.Reset();
        CSVBuffer.DeleteAll();

        //Create Header++
        CSVBuffer.Init();
        LineNo := 1;
        CSVBuffer.InsertEntry(LineNo, 1, 'Cust Code');
        CSVBuffer.InsertEntry(LineNo, 2, 'Prod Code');
        CSVBuffer.InsertEntry(LineNo, 3, 'Qty');
        CSVBuffer.InsertEntry(LineNo, 4, 'Val');
        CSVBuffer.InsertEntry(LineNo, 5, 'Cst');
        CSVBuffer.InsertEntry(LineNo, 6, 'Del Date');
        CSVBuffer.InsertEntry(LineNo, 7, 'Rep Code');
        CSVBuffer.InsertEntry(LineNo, 8, 'Terr Man');
        CSVBuffer.InsertEntry(LineNo, 9, 'Price Type');
        CSVBuffer.InsertEntry(LineNo, 10, 'Supp Dep');
        CSVBuffer.InsertEntry(LineNo, 11, 'Ord No');
        CSVBuffer.InsertEntry(LineNo, 12, 'Op Code');
        CSVBuffer.InsertEntry(LineNo, 13, 'Ord Type');
        CSVBuffer.InsertEntry(LineNo, 14, 'Round');
        CSVBuffer.InsertEntry(LineNo, 15, 'Pack Price');
        CSVBuffer.InsertEntry(LineNo, 16, 'Prod Group');
        CSVBuffer.InsertEntry(LineNo, 17, 'Margin');
        CSVBuffer.InsertEntry(LineNo, 18, 'Period');
        CSVBuffer.InsertEntry(LineNo, 19, 'Supp Code');
        CSVBuffer.InsertEntry(LineNo, 20, 'Weight');
        CSVBuffer.InsertEntry(LineNo, 21, 'Ord Date');
        CSVBuffer.InsertEntry(LineNo, 22, 'FOC Ind');
        CSVBuffer.InsertEntry(LineNo, 23, 'Vehicle Reg');
        CSVBuffer.InsertEntry(LineNo, 24, 'Inv/Cred');
        CSVBuffer.InsertEntry(LineNo, 25, 'Cred Reason');
        CSVBuffer.InsertEntry(LineNo, 26, 'Drop Seq');
        CSVBuffer.InsertEntry(LineNo, 27, 'Comb Disc');
        CSVBuffer.InsertEntry(LineNo, 28, 'Del Code');
        CSVBuffer.InsertEntry(LineNo, 29, 'Lost Pick');
        CSVBuffer.InsertEntry(LineNo, 30, 'Lost Desp');
        CSVBuffer.InsertEntry(LineNo, 31, 'Pick Conf Code');
        CSVBuffer.InsertEntry(LineNo, 32, 'Order Time');
        CSVBuffer.InsertEntry(LineNo, 33, 'Company');
        CSVBuffer.InsertEntry(LineNo, 34, 'Picker Code');
        CSVBuffer.InsertEntry(LineNo, 35, 'Line Type');
        CSVBuffer.InsertEntry(LineNo, 36, 'Volume');
        CSVBuffer.InsertEntry(LineNo, 37, 'Inv Date');
        CSVBuffer.InsertEntry(LineNo, 38, 'Cust Ord No');
        CSVBuffer.InsertEntry(LineNo, 39, 'Inv No');
        CSVBuffer.InsertEntry(LineNo, 40, 'Promise Date');
        CSVBuffer.InsertEntry(LineNo, 41, 'Account Year');
        CSVBuffer.InsertEntry(LineNo, 42, 'Account Month');
        CSVBuffer.InsertEntry(LineNo, 43, 'Sell by date');
        CSVBuffer.InsertEntry(LineNo, 44, 'CustProdCode');
        CSVBuffer.InsertEntry(LineNo, 45, 'SalesAd1');
        CSVBuffer.InsertEntry(LineNo, 46, 'SalesAd2');
        CSVBuffer.InsertEntry(LineNo, 47, 'SalesAd3');
        CSVBuffer.InsertEntry(LineNo, 48, 'SalesAd4');
        CSVBuffer.InsertEntry(LineNo, 49, 'SalesAd5');
        CSVBuffer.InsertEntry(LineNo, 50, 'SalesAd6');
        CSVBuffer.InsertEntry(LineNo, 51, 'SalesAnal1');
        CSVBuffer.InsertEntry(LineNo, 52, 'SalesAnal2');
        CSVBuffer.InsertEntry(LineNo, 53, 'SalesAnal3');
        CSVBuffer.InsertEntry(LineNo, 54, 'SalesAnal4');
        CSVBuffer.InsertEntry(LineNo, 55, 'SalesAnal5');
        CSVBuffer.InsertEntry(LineNo, 56, 'SalesAnal6');
        CSVBuffer.InsertEntry(LineNo, 57, 'Job Number');
        CSVBuffer.InsertEntry(LineNo, 58, 'Master Ord No');
        CSVBuffer.InsertEntry(LineNo, 59, 'Purch Ord No');
        CSVBuffer.InsertEntry(LineNo, 60, 'Sord Line No');
        CSVBuffer.InsertEntry(LineNo, 61, 'Pord Line No');
        CSVBuffer.InsertEntry(LineNo, 62, 'ActCst');
        CSVBuffer.InsertEntry(LineNo, 63, 'Sord Line Desc');
        CSVBuffer.InsertEntry(LineNo, 64, 'Qty Ordered');
        CSVBuffer.InsertEntry(LineNo, 65, 'Landed Cost');
        CSVBuffer.InsertEntry(LineNo, 66, 'FC Val');
        CSVBuffer.InsertEntry(LineNo, 67, 'Exch Rate');
        CSVBuffer.InsertEntry(LineNo, 68, 'Foreign Curr Code');
        CSVBuffer.InsertEntry(LineNo, 69, 'RM Cost');
        CSVBuffer.InsertEntry(LineNo, 70, 'Direct Labour');
        CSVBuffer.InsertEntry(LineNo, 71, 'Direct OH');
        CSVBuffer.InsertEntry(LineNo, 72, 'Indirect OH');
        CSVBuffer.InsertEntry(LineNo, 73, 'Finishing Costs');
        CSVBuffer.InsertEntry(LineNo, 74, 'Transfer Disc');
        CSVBuffer.InsertEntry(LineNo, 75, 'Av Cost Value');
        CSVBuffer.InsertEntry(LineNo, 76, 'XXXXXXXXXXXX');


        //Create Body++
        //Windows.OPEN('Downloading..' + ' @1@@@@@@@@@@@@@\' + 'Updating..' + ' #3##########' + 'Please Wait..');
        L_SalesInvoiceLine.Reset();
        L_SalesInvoiceLine.SetFilter(Quantity, '>%1', 0);
        L_SalesInvoiceLine.SetRange(Type, L_SalesInvoiceLine.Type::Item);
        if L_SalesInvoiceLine.FindSet() then begin
            repeat
                // NoOfRecs := L_SalesInvoiceLine.Count;
                // ProgressCount += 1;
                // IF NoOfRecs <= 100 THEN
                //     Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                // ELSE
                //     IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                //         Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                //     END;
                // Windows.UPDATE(3, L_SalesInvoiceLine."No.");
                LineNo += 1;
                L_SalesInvoiceHeader.Reset();
                L_SalesInvoiceHeader.SetRange("No.", L_SalesInvoiceLine."Document No.");
                if L_SalesInvoiceHeader.FindFirst() then begin
                    L_SalesInvoiceHeader.CalcFields(Amount);
                    CSVBuffer.InsertEntry(LineNo, 1, L_SalesInvoiceHeader."Sell-to Customer No.");  // Cust Code
                    CSVBuffer.InsertEntry(LineNo, 2, L_SalesInvoiceLine."No.");  // Prod Code
                    CSVBuffer.InsertEntry(LineNo, 3, DelChr(Format(L_SalesInvoiceLine.Quantity), '=', ','));  // Qty
                    CSVBuffer.InsertEntry(LineNo, 4, DelChr(Format(L_SalesInvoiceLine.Amount), '=', ','));  // Val
                    CSVBuffer.InsertEntry(LineNo, 5, DelChr(Format(L_SalesInvoiceLine."Unit Cost (LCY)"), '=', ','));  // Cst
                    CSVBuffer.InsertEntry(LineNo, 6, FormatDateForCSV(L_SalesInvoiceHeader."Shipment Date"));  // Del Date
                    cust.Reset();
                    cust.SetRange("No.", L_SalesInvoiceHeader."Sell-to Customer No.");
                    if cust.FindFirst() then begin
                        CSVBuffer.InsertEntry(LineNo, 7, cust."Territory Code");  // Rep Code
                    end;
                    CSVBuffer.InsertEntry(LineNo, 8, '');  // Terr Man
                    CSVBuffer.InsertEntry(LineNo, 9, '');  // Price Type
                    CSVBuffer.InsertEntry(LineNo, 10, L_SalesInvoiceHeader."Location Code");  // Supp Dep
                    CSVBuffer.InsertEntry(LineNo, 11, L_SalesInvoiceHeader."Order No.");  // Ord No
                    CSVBuffer.InsertEntry(LineNo, 12, L_SalesInvoiceHeader."Salesperson Code");  // Op Code
                    CSVBuffer.InsertEntry(LineNo, 13, '');  // Ord Type
                    CSVBuffer.InsertEntry(LineNo, 14, L_SalesInvoiceHeader."Shipping Agent Code");  // Round
                    CSVBuffer.InsertEntry(LineNo, 15, DelChr(Format(L_SalesInvoiceLine."Unit Price"), '=', ','));  // Pack Price
                    CSVBuffer.InsertEntry(LineNo, 16, L_SalesInvoiceLine."Item Category Code");  // Prod Group
                    CSVBuffer.InsertEntry(LineNo, 17, DelChr(Format(L_SalesInvoiceLine."Unit Price" - L_SalesInvoiceLine."Unit Cost"), '=', ','));  // Margin
                    CSVBuffer.InsertEntry(LineNo, 18, CopyStr(Format(L_SalesInvoiceHeader."Posting Date", 0, '<Month Text>'), 1, 3));  // Period
                    if L_Item.Get(L_SalesInvoiceLine."No.") then;
                    CSVBuffer.InsertEntry(LineNo, 19, L_Item."Vendor No.");  // Supp Code
                    CSVBuffer.InsertEntry(LineNo, 20, DelChr(Format(L_SalesInvoiceLine."Net Weight"), '=', ','));  // Weight
                    CSVBuffer.InsertEntry(LineNo, 21, FormatDateForCSV(L_SalesInvoiceHeader."Order Date"));  // Ord Date
                    CSVBuffer.InsertEntry(LineNo, 22, 'Paid Sale');  // FOC Ind
                    CSVBuffer.InsertEntry(LineNo, 23, '');  // Vehicle Reg
                    CSVBuffer.InsertEntry(LineNo, 24, 'Invoice');  // Inv/Cred
                    CSVBuffer.InsertEntry(LineNo, 25, '');  // Cred Reason
                    CSVBuffer.InsertEntry(LineNo, 26, '');  // Drop Seq
                    CSVBuffer.InsertEntry(LineNo, 27, '');  // Comb Disc
                    CSVBuffer.InsertEntry(LineNo, 28, L_SalesInvoiceHeader."Ship-to Code");  // Del Code
                    CSVBuffer.InsertEntry(LineNo, 29, '');  // Lost Pick
                    CSVBuffer.InsertEntry(LineNo, 30, '');  // Lost Desp
                    CSVBuffer.InsertEntry(LineNo, 31, '');  // Pick Conf Code
                    CSVBuffer.InsertEntry(LineNo, 32, '');  // Order Time
                    CompInfo.Get();
                    CSVBuffer.InsertEntry(LineNo, 33, CompInfo.Name);  // Company
                    CSVBuffer.InsertEntry(LineNo, 34, '');  // Picker Code
                    CSVBuffer.InsertEntry(LineNo, 35, 'Y');  // Line Type
                    CSVBuffer.InsertEntry(LineNo, 36, '');  // Volume
                    CSVBuffer.InsertEntry(LineNo, 37, FormatDateForCSV(L_SalesInvoiceHeader."Posting Date"));  // Inv Date
                    CSVBuffer.InsertEntry(LineNo, 38, DelChr(Format(L_SalesInvoiceHeader."External Document No."), '=', ','));  // Cust Ord No
                    CSVBuffer.InsertEntry(LineNo, 39, L_SalesInvoiceHeader."No.");  // Inv No
                    sales_Shipment_Header.Reset();
                    sales_Shipment_Header.SetRange("Order No.", L_SalesInvoiceHeader."Order No.");
                    if sales_Shipment_Header.FindFirst() then begin
                        CSVBuffer.InsertEntry(LineNo, 40, FormatDateForCSV(sales_Shipment_Header."Promised Delivery Date"));  // Promise Date
                    end else begin
                        CSVBuffer.InsertEntry(LineNo, 40, '');  // Promise Date
                    end;
                    CSVBuffer.InsertEntry(LineNo, 41, '');  // Account Year
                    CSVBuffer.InsertEntry(LineNo, 42, '');  // Account Month
                    CSVBuffer.InsertEntry(LineNo, 43, '00/00/00');  // Sell by date
                    CSVBuffer.InsertEntry(LineNo, 44, L_SalesInvoiceLine."Item Reference No.");  // CustProdCode
                    CSVBuffer.InsertEntry(LineNo, 45, '');  // SalesAd1
                    CSVBuffer.InsertEntry(LineNo, 46, '');  // SalesAd2
                    CSVBuffer.InsertEntry(LineNo, 47, '');  // SalesAd3
                    CSVBuffer.InsertEntry(LineNo, 48, '');  // SalesAd4
                    CSVBuffer.InsertEntry(LineNo, 49, '');  // SalesAd5
                    CSVBuffer.InsertEntry(LineNo, 50, '');  // SalesAd6
                    CSVBuffer.InsertEntry(LineNo, 51, '');  // SalesAnal1
                    CSVBuffer.InsertEntry(LineNo, 52, '');  // SalesAnal2
                    CSVBuffer.InsertEntry(LineNo, 53, '');  // SalesAnal3
                    CSVBuffer.InsertEntry(LineNo, 54, '');  // SalesAnal4
                    CSVBuffer.InsertEntry(LineNo, 55, '');  // SalesAnal5
                    CSVBuffer.InsertEntry(LineNo, 56, '');  // SalesAnal6
                    CSVBuffer.InsertEntry(LineNo, 57, '');  // Job Number
                    CSVBuffer.InsertEntry(LineNo, 58, '');  // Master Ord No
                    CSVBuffer.InsertEntry(LineNo, 59, '');  // Purch Ord No
                    CSVBuffer.InsertEntry(LineNo, 60, Format(L_SalesInvoiceLine."Line No."));  // Sord Line No
                    CSVBuffer.InsertEntry(LineNo, 61, '');  // Pord Line No
                    CSVBuffer.InsertEntry(LineNo, 62, DelChr(Format(L_SalesInvoiceLine."Line Amount"), '=', ','));  // ActCst
                    CSVBuffer.InsertEntry(LineNo, 63, DelChr((Format(L_SalesCreditMemoLine.Description)), '=', ','));  // Sord Line Desc
                    CSVBuffer.InsertEntry(LineNo, 64, DelChr(Format(L_SalesInvoiceLine."Original Order Quantity"), '=', ','));  // Qty Ordered
                    CSVBuffer.InsertEntry(LineNo, 65, DelChr(Format(L_SalesInvoiceLine."Unit Cost (LCY)"), '=', ','));  // Landed Cost
                    CSVBuffer.InsertEntry(LineNo, 66, DelChr(Format(L_SalesInvoiceHeader.Amount), '=', ','));  // FC Val
                    CSVBuffer.InsertEntry(LineNo, 67, Format(L_SalesInvoiceHeader."Currency Factor"));  // Exch Rate
                    CSVBuffer.InsertEntry(LineNo, 68, Format(L_SalesInvoiceHeader."Currency Code"));  // Foreign Curr Code
                    CSVBuffer.InsertEntry(LineNo, 69, '');  // RM Cost
                    CSVBuffer.InsertEntry(LineNo, 70, '');  // Direct Labour
                    CSVBuffer.InsertEntry(LineNo, 71, '');  // Direct OH
                    CSVBuffer.InsertEntry(LineNo, 72, '');  // Indirect OH
                    CSVBuffer.InsertEntry(LineNo, 73, '');  // Finishing Costs
                    CSVBuffer.InsertEntry(LineNo, 74, '');  // Transfer Disc
                    CSVBuffer.InsertEntry(LineNo, 75, DelChr(Format(L_SalesInvoiceLine."Unit Cost"), '=', ','));  // Av Cost Value
                    CSVBuffer.InsertEntry(LineNo, 76, '');
                end;
            until L_SalesInvoiceLine.Next() = 0;
        end;

        L_SalesCreditMemoLine.Reset();
        L_SalesCreditMemoLine.SetFilter(Quantity, '>%1', 0);
        L_SalesCreditMemoLine.SetRange(Type, L_SalesCreditMemoLine.Type::Item);
        if L_SalesCreditMemoLine.FindSet() then begin
            repeat
                LineNo += 1;
                L_SalesCreditMemoHeader.Reset();
                L_SalesCreditMemoHeader.SetRange("No.", L_SalesCreditMemoLine."Document No.");
                if L_SalesCreditMemoHeader.FindFirst() then begin
                    L_SalesCreditMemoHeader.CalcFields(Amount);
                    CSVBuffer.InsertEntry(LineNo, 1, L_SalesCreditMemoHeader."Sell-to Customer No.");  // Cust Code
                    CSVBuffer.InsertEntry(LineNo, 2, L_SalesCreditMemoLine."No.");  // Prod Code
                    CSVBuffer.InsertEntry(LineNo, 3, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine.Quantity)), '=', ','));  // Qty
                    CSVBuffer.InsertEntry(LineNo, 4, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine.Amount)), '=', ','));  // Val
                    CSVBuffer.InsertEntry(LineNo, 5, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine."Unit Cost (LCY)")), '=', ','));  // Cst
                    CSVBuffer.InsertEntry(LineNo, 6, FormatDateForCSV(L_SalesCreditMemoHeader."Shipment Date"));  // Del Date
                    cust.Reset();
                    cust.SetRange("No.", L_SalesCreditMemoHeader."Sell-to Customer No.");
                    if cust.FindFirst() then begin
                        CSVBuffer.InsertEntry(LineNo, 7, cust."Territory Code");  // Rep Code
                    end;
                    CSVBuffer.InsertEntry(LineNo, 8, '');  // Terr Man
                    CSVBuffer.InsertEntry(LineNo, 9, '');  // Price Type
                    CSVBuffer.InsertEntry(LineNo, 10, L_SalesCreditMemoHeader."Location Code");  // Supp Dep
                    CSVBuffer.InsertEntry(LineNo, 11, L_SalesCreditMemoHeader."Return Order No.");  // Ord No
                    CSVBuffer.InsertEntry(LineNo, 12, L_SalesCreditMemoHeader."Salesperson Code");  // Op Code
                    CSVBuffer.InsertEntry(LineNo, 13, '');  // Ord Type
                    CSVBuffer.InsertEntry(LineNo, 14, L_SalesCreditMemoHeader."Shipping Agent Code");  // Round
                    CSVBuffer.InsertEntry(LineNo, 15, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine."Unit Price")), '=', ','));  // Pack Price
                    CSVBuffer.InsertEntry(LineNo, 16, L_SalesCreditMemoLine."Item Category Code");  // Prod Group
                    CSVBuffer.InsertEntry(LineNo, 17, '-' + Format(Abs((L_SalesCreditMemoLine."Unit Price" - L_SalesCreditMemoLine."Unit Cost") * L_SalesCreditMemoLine.Quantity)));  // Margin
                    CSVBuffer.InsertEntry(LineNo, 18, CopyStr(Format(L_SalesCreditMemoHeader."Posting Date", 0, '<Month Text>'), 1, 3));  // Period
                    if L_Item.Get(L_SalesCreditMemoLine."No.") then;
                    CSVBuffer.InsertEntry(LineNo, 19, L_Item."Vendor No.");  // Supp Code
                    CSVBuffer.InsertEntry(LineNo, 20, DelChr(Format(L_SalesCreditMemoLine."Net Weight"), '=', ','));  // Weight
                    CSVBuffer.InsertEntry(LineNo, 21, FormatDateForCSV(L_SalesCreditMemoHeader."Document Date"));  // Ord Date
                    CSVBuffer.InsertEntry(LineNo, 22, 'Paid Sale');  // FOC Ind
                    CSVBuffer.InsertEntry(LineNo, 23, '');  // Vehicle Reg
                    CSVBuffer.InsertEntry(LineNo, 24, 'Credit');  // Inv/Cred
                    CSVBuffer.InsertEntry(LineNo, 25, '');  // Cred Reason
                    CSVBuffer.InsertEntry(LineNo, 26, '');  // Drop Seq
                    CSVBuffer.InsertEntry(LineNo, 27, '');  // Comb Disc
                    CSVBuffer.InsertEntry(LineNo, 28, L_SalesCreditMemoHeader."Ship-to Code");  // Del Code
                    CSVBuffer.InsertEntry(LineNo, 29, '');  // Lost Pick
                    CSVBuffer.InsertEntry(LineNo, 30, '');  // Lost Desp
                    CSVBuffer.InsertEntry(LineNo, 31, '');  // Pick Conf Code
                    CSVBuffer.InsertEntry(LineNo, 32, '');  // Order Time
                    CompInfo.Get();
                    CSVBuffer.InsertEntry(LineNo, 33, CompInfo.Name);  // Company
                    CSVBuffer.InsertEntry(LineNo, 34, '');  // Picker Code
                    CSVBuffer.InsertEntry(LineNo, 35, 'C');  // Line Type
                    CSVBuffer.InsertEntry(LineNo, 36, '');  // Volume
                    CSVBuffer.InsertEntry(LineNo, 37, FormatDateForCSV(L_SalesCreditMemoHeader."Posting Date"));  // Inv Date
                    CSVBuffer.InsertEntry(LineNo, 38, DelChr(Format(L_SalesCreditMemoHeader."External Document No."), '=', ','));  // Cust Ord No
                    CSVBuffer.InsertEntry(LineNo, 39, L_SalesCreditMemoHeader."No.");  // Inv No
                    sales_Shipment_Header.Reset();
                    sales_Shipment_Header.SetRange("Order No.", L_SalesCreditMemoHeader."Return Order No.");
                    if sales_Shipment_Header.FindFirst() then begin
                        CSVBuffer.InsertEntry(LineNo, 40, FormatDateForCSV(sales_Shipment_Header."Promised Delivery Date"));  // Promise Date
                    end else begin
                        CSVBuffer.InsertEntry(LineNo, 40, '');  // Promise Date
                    end;
                    CSVBuffer.InsertEntry(LineNo, 41, '');  // Account Year
                    CSVBuffer.InsertEntry(LineNo, 42, '');  // Account Month
                    CSVBuffer.InsertEntry(LineNo, 43, '00/00/00');  // Sell by date
                    CSVBuffer.InsertEntry(LineNo, 44, L_SalesCreditMemoLine."Item Reference No.");  // CustProdCode
                    CSVBuffer.InsertEntry(LineNo, 45, '');  // SalesAd1
                    CSVBuffer.InsertEntry(LineNo, 46, '');  // SalesAd2
                    CSVBuffer.InsertEntry(LineNo, 47, '');  // SalesAd3
                    CSVBuffer.InsertEntry(LineNo, 48, '');  // SalesAd4
                    CSVBuffer.InsertEntry(LineNo, 49, '');  // SalesAd5
                    CSVBuffer.InsertEntry(LineNo, 50, '');  // SalesAd6
                    CSVBuffer.InsertEntry(LineNo, 51, '');  // SalesAnal1
                    CSVBuffer.InsertEntry(LineNo, 52, '');  // SalesAnal2
                    CSVBuffer.InsertEntry(LineNo, 53, '');  // SalesAnal3
                    CSVBuffer.InsertEntry(LineNo, 54, '');  // SalesAnal4
                    CSVBuffer.InsertEntry(LineNo, 55, '');  // SalesAnal5
                    CSVBuffer.InsertEntry(LineNo, 56, '');  // SalesAnal6
                    CSVBuffer.InsertEntry(LineNo, 57, '');  // Job Number
                    CSVBuffer.InsertEntry(LineNo, 58, '');  // Master Ord No
                    CSVBuffer.InsertEntry(LineNo, 59, '');  // Purch Ord No
                    CSVBuffer.InsertEntry(LineNo, 60, Format(L_SalesCreditMemoLine."Line No."));  // Sord Line No
                    CSVBuffer.InsertEntry(LineNo, 61, '');  // Pord Line No
                    CSVBuffer.InsertEntry(LineNo, 62, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine."Line Amount")), '=', ','));  // ActCst
                    CSVBuffer.InsertEntry(LineNo, 63, DelChr((Format(L_SalesCreditMemoLine.Description)), '=', ','));  // Sord Line Desc
                    CSVBuffer.InsertEntry(LineNo, 64, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine.Quantity)), '=', ','));  // Qty Ordered
                    CSVBuffer.InsertEntry(LineNo, 65, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine."Unit Cost (LCY)")), '=', ','));  // Landed Cost
                    CSVBuffer.InsertEntry(LineNo, 66, '-' + DelChr(Format(Abs(L_SalesCreditMemoHeader.Amount)), '=', ','));  // FC Val
                    CSVBuffer.InsertEntry(LineNo, 67, Format(L_SalesCreditMemoHeader."Currency Factor"));  // Exch Rate
                    CSVBuffer.InsertEntry(LineNo, 68, Format(L_SalesCreditMemoHeader."Currency Code"));  // Foreign Curr Code
                    CSVBuffer.InsertEntry(LineNo, 69, '');  // RM Cost
                    CSVBuffer.InsertEntry(LineNo, 70, '');  // Direct Labour
                    CSVBuffer.InsertEntry(LineNo, 71, '');  // Direct OH
                    CSVBuffer.InsertEntry(LineNo, 72, '');  // Indirect OH
                    CSVBuffer.InsertEntry(LineNo, 73, '');  // Finishing Costs
                    CSVBuffer.InsertEntry(LineNo, 74, '');  // Transfer Disc
                    CSVBuffer.InsertEntry(LineNo, 75, '-' + DelChr(Format(Abs(L_SalesCreditMemoLine."Unit Cost")), '=', ','));  // Av Cost Value
                    CSVBuffer.InsertEntry(LineNo, 76, '');
                end;
            until L_SalesCreditMemoLine.Next() = 0;
        end;


        //Export File
        Clear(TempBLOB);
        Clear(Filename);
        Clear(GRNInstream);
        Filename := 'mio47.csv';
        CSVBuffer.SaveDataToBlob(TempBLOB, ',');
        TempBLOB.CreateInStream(GRNInstream);
        //DownloadFromStream(GRNInstream, '', '', '', Filename);
        UploadFileToEDIAzureContainer(GRNInstream, FileName, StartParameter);
    end;

    procedure FormatDateForCSV(MyDate: Date): Text[10];
    var
        DayStr: Text[2];
        MonthStr: Text[2];
        YearStr: Text[4];
    begin
        if MyDate = 0D then
            exit('');
        DayStr := Format(Date2DMY(MyDate, 1));
        MonthStr := Format(Date2DMY(MyDate, 2));
        YearStr := Format(Date2DMY(MyDate, 3));

        if STRLEN(DayStr) = 1 then
            DayStr := '0' + DayStr;
        if STRLEN(MonthStr) = 1 then
            MonthStr := '0' + MonthStr;
        exit(DayStr + '/' + MonthStr + '/' + YearStr);
    end;

    var
        StartParameter: Text;
        RunType: Text;
        Datawarehouse: Label 'Datawarehouse';
        outgoingContainerName: Text;
        OutgoingSasToken: Text;
        StorageAccountName: Text;
        SharedAccessKey: SecretText;
        Windows: Dialog;
        ProgressCount: Integer;
        NoOfRecs: Integer;
        Count: Integer;


}

