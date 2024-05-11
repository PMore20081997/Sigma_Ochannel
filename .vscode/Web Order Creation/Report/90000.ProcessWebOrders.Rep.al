report 90000 "Process Web Orders"
{
    ProcessingOnly = true;
    Permissions = tabledata "Bank Account" = R;

    dataset
    {
        dataitem("Trade Partner"; "Trade Partner")
        {
            // DataItemTableView = WHERE("Blocked" = CONST(No));
            RequestFilterFields = "Code";
            dataitem(InterimSH; "Interim Sales Header")
            {
                CalcFields = "No of Error", "Tracking No.";
                DataItemLink = "Trade Partner Code" = FIELD(Code);
                DataItemTableView = SORTING("Document Type", "No.")
                                    WHERE("Document Type" = FILTER(Order),
                                          "Destination Doc No." = filter(''),
                                           Status = FILTER(Accepted),
                                           "Sales Order Created" = const(false));

                RequestFilterFields = "No.", "Document Date", "Shipping Agent Code", "Shipping Agent Service Code";//"Sell-to Customer No.", "Ship-to Country/Region Code", ; //, "Prime Order", "Premium Order"
                trigger OnAfterGetRecord()
                var
                    CreateOrderErrror: Text;
                    WebOrderMgt: Codeunit "Web Order Mgt";
                    GenSetup: Record "General Setup - Channels";
                begin
                    i := i + 1;
                    COMMIT;
                    CASE "Trade Partner"."Process Order Type" OF
                        "Trade Partner"."Process Order Type"::"Internal Pick":
                            BEGIN
                                if InterimSHTemp.get(InterimSH."Document Type", InterimSH."No.") then //CAS-27945-M1R5J2
                                    ResetFirstOrder(); //CAS-27945-M1R5J2

                                IF FirstOrder THEN BEGIN
                                    CreateWHInvPick.SetParamters(FirstOrder, "Trade Partner"."Process Order Type"::"Internal Pick");
                                    CreateWHInvPick.SetTotalQty(G_TotalQty);
                                    FirstOrder := FALSE;
                                END
                                ELSE begin
                                    CreateWHInvPick.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Internal Pick");
                                    CreateWHInvPick.SetTotalQty(G_TotalQty);
                                end;


                                IF NOT CreateWHInvPick.RUN(InterimSH) THEN BEGIN
                                    CreateOrderErrror := GETLASTERRORTEXT();
                                    InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
                                END ELSE BEGIN
                                    // InsertIntoTempHeader(InterimSH."Sales Order No.");
                                    LastOrderNo := InterimSH."No.";
                                    PickCreated := true;//NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
                                END;
                            END;
                        "Trade Partner"."Process Order Type"::"Single Order":
                            BEGIN
                                GenSetup.Get();
                                if GenSetup."Allocate Web Orders" = true then begin
                                    WebOrderMgt.OrderValidations(InterimSH);
                                    Commit();
                                end;

                                if InterimSH.status = InterimSH.status::Accepted then begin
                                    CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Single Order");
                                    IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
                                        CreateOrderErrror := GETLASTERRORTEXT();
                                        InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
                                        InterimSH.MODIFY();
                                    END ELSE BEGIN
                                        // InsertIntoTempHeader(InterimSH."Sales Order No.");
                                        Commit();
                                        LastOrderNo := InterimSH."No.";
                                        PickCreated := true;//NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
                                    END;
                                end;
                            END;
                        "Trade Partner"."Process Order Type"::"Consolidate Order":
                            BEGIN
                                IF FirstOrder THEN BEGIN
                                    CreateConsollidatedOrder.SetParamters(FirstOrder, "Trade Partner"."Process Order Type"::"Consolidate Order");
                                    FirstOrder := FALSE;
                                END
                                ELSE
                                    CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Consolidate Order");

                                IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
                                    CreateOrderErrror := GETLASTERRORTEXT();
                                    InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
                                    // InterimSH.VALIDATE("Line Action", InterimSH."Line Action"::"No Action");
                                    InterimSH.MODIFY();
                                END ELSE BEGIN
                                    // InsertIntoTempHeader(InterimSH."Sales Order No.");
                                    LastOrderNo := InterimSH."No.";
                                    PickCreated := true;//NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
                                END;

                            END;
                    END;


                    CurrRec += 1;
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);

                    IF NoOfOrders > 0 THEN BEGIN
                        IF i >= NoOfOrders THEN BEGIN
                            //CurrReport.BREAK;
                            COMMIT;
                            Reseti;
                            ResetFirstOrder;
                            //UpdatePreviousOrderLines("Trade Partner");code is blocked by AK as this code is not is use
                        END;
                    END;
                    // InterimsalesHeader.DeleteAll();
                    // if InterimSH."Channel Order ID" <> '' then begin
                    //     InterimsalesHeader."Channel Order ID" += '|' + InterimSH."Channel Order ID";
                    // end;
                end;

                trigger OnPostDataItem()
                var
                    TradePartner: Record "Trade Partner";
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                    OrderAck: Codeunit "Order Acknowledgement";
                begin
                    TradePartner.Reset();
                    TradePartner.SetRange(Code, "Trade Partner".Code);
                    if TradePartner.FindFirst() then
                        if TradePartner."Order Acknowledgement Required" then begin
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartner.Code + ';OrderAcknowledgement';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartner."Order Acknowledgement Codeunit", JobQueueEntry);
                            //OrderAck.OrderAckConvertText(InterimsalesHeader."Channel Order ID");
                            JobQueueEntry.Delete();
                        end;
                end;

                trigger OnPreDataItem()
                var
                    L_ISL: Record "Interim Sales Line";
                    L_OchannelGenSetup: Record "General Setup - Channels";
                    L_Qty: Decimal;
                    CheckQty: Decimal;
                begin
                    L_OchannelGenSetup.Get();
                    if "Trade Partner"."Tracking No Valid. Required" then
                        InterimSH.SetFilter("Tracking No.", '<>%1', '');

                    //IK++
                    // if L_OchannelGenSetup."Allocate Web Orders" then 
                    //     InterimSH.SetRange(ReservedFlag, true);
                    // IK--

                    Window.OPEN('Processing... @1@@@@@@@@@@');
                    if "Trade Partner"."Process Order Type" = "Trade Partner"."Process Order Type"::"Internal Pick" then begin

                        case NoOfItems of

                            NoOfItems::Single:
                                begin
                                    InterimSH.SETFILTER("No. of Items", '%1', 1);
                                    // InterimSH.CalcFields("Shelf No.");       // Irshad
                                    InterimSH.SetCurrentKey("Shelf No.");
                                    InterimSH.SetAscending("Shelf No.", true);
                                    if L_OchannelGenSetup."Allocate Web Orders" = true then
                                        InterimSH.SETFILTER(ReservedFlag, '%1', TRUE);
                                end;

                            NoOfItems::Multiple:

                                begin
                                    InterimSH.SETFILTER("No. of Items", '>%1', 1);
                                    Clear(G_TotalQty);
                                    G_TotalQty := GetTotalQtyInWebOrder(InterimSH);
                                    if L_OchannelGenSetup."Allocate Web Orders" = true then
                                        InterimSH.SETFILTER(ReservedFlag, '%1', TRUE);
                                end;
                        end;
                    end;
                    NoOfRecs := InterimSH.COUNT;

                end;
            }

            trigger OnAfterGetRecord()
            var
                L_InterimHeader: Record "Interim Sales Header";
                GenSetup: Record "General Setup - Channels";
            begin
                Reseti;
                ResetFirstOrder;

                // code for Allocate WebOrder feature ++
                #region we will check the reservation at the time of creating sales order.(code added from line 61 to 65)
                // GenSetup.Get();
                // if GenSetup."Allocate Web Orders" = true then begin
                //     if (("Trade Partner"."Process Order Type" = "Trade Partner"."Process Order Type"::"Internal Pick") OR ("Trade Partner"."Process Order Type" = "Trade Partner"."Process Order Type"::"Single Order")) then begin
                //         Clear(TotalOrderToProcess);
                //         L_InterimHeader.Reset();
                //         L_InterimHeader.CopyFilters(InterimSH);
                //         L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
                //         L_InterimHeader.SetRange("Trade Partner Code", "Trade Partner".Code);
                //         L_InterimHeader.SetRange(status, L_InterimHeader.status::"In Progress");
                //         if NoOfItems = NoOfItems::Multiple then
                //             L_InterimHeader.SETFILTER("No. of Items", '>%1', 1);
                //         if NoOfItems = NoOfItems::Single then
                //             InterimSH.SETFILTER("No. of Items", '%1', 1);
                //         if L_InterimHeader.FindSet() then begin
                //             TotalOrderToProcess := L_InterimHeader.Count;
                //             CreateConsollidatedOrder.AllocateWebOrderWithAvailableQty2(L_InterimHeader, TotalOrderToProcess);
                //         end;
                //     end;
                // end;
                //AllocateWebOrder--
                #endregion
            end;

            trigger OnPreDataItem()
            begin
                PickCreated := false;//NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
                IF G_ChannelCode <> '' THEN
                    "Trade Partner".SETRANGE("Trade Partner".Code, G_ChannelCode);


            end;

            trigger OnPostDataItem()
            begin
                if PickCreated = true then
                    Message('Web Order Processed Successfully');//NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")
            end;

        }

    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Item No"; Itemno)
                {
                    Visible = false;
                    ApplicationArea = all;
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CLEAR(ItemList);
                        RecItem.RESET;
                        RecItem.SETRANGE(Blocked, FALSE);
                        ItemList.SETTABLEVIEW(RecItem);
                        ItemList.LOOKUPMODE(TRUE);
                        //IF ItemList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                        //    Itemno := ItemList.GetSelectionFilter();
                        //END;
                    end;
                }
                field("No Of Orders"; NoOfOrders)
                {
                    ApplicationArea = all;
                    //Visible = false;
                    trigger OnValidate()
                    begin

                    end;
                }
                field("Total No of Orders"; "TotalNoOfOrders")
                {
                    ApplicationArea = All;
                    Caption = 'Total No Of Orders';
                    Editable = false;
                }
                field("No Of Items"; NoOfItems)
                {
                    ApplicationArea = all;
                    Caption = 'No Of Items';
                    //Visible = false;
                }
                field("Use Last Processed order"; UseLastProcessedOrder)
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Use Allocation"; UseAllocationboolean)
                {
                    Visible = false;
                    ApplicationArea = all;
                }
            }
        }

        actions
        {
        }
        trigger OnOpenPage()
        begin
            NoOfItems := NoOfItems::Everything;
            if InterimSH.GetFilter("Trade Partner Code") <> '' then
                if G_BnQChannelCode <> '' then
                    "Trade Partner".SetRange(Code, 'B&Q')
                else
                    "Trade Partner".SetRange(Code, InterimSH.GetFilter("Trade Partner Code"));
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    var
        L_CreateConsolidateSO: Codeunit "Create Consolidate SO";
    begin
        //Only For Sigma process++
        L_CreateConsolidateSO.ClearVariable();
    end;

    trigger OnPostReport()
    var
        L_CreateConsolidateSO: Codeunit "Create Consolidate SO";
    begin
        //Only For Sigma process++
        L_CreateConsolidateSO.ProcessTemporarySalesLinetoSalesOrder();
    end;


    local procedure GetTotalQtyInWebOrder(var P_ISH: Record "Interim Sales Header"): Decimal
    var
        ISL: Record "Interim Sales Line";
        TotalQty: Decimal;
    begin
        Clear(TotalQty);
        if P_ISH.FindSet() then begin
            repeat
                ISL.Reset();
                ISL.SetRange("Document Type", P_ISH."Document Type");
                ISL.SetRange("Document No", P_ISH."No.");
                ISL.SetRange(Type, ISL.Type::Item);
                if ISL.FindSet() then begin
                    repeat
                        TotalQty := TotalQty + ISL.Quantity;
                    until ISL.Next() = 0;
                end;
            until P_ISH.Next() = 0;
            if TotalQty > 0 then
                exit(TotalQty);
        end;
    end;

    procedure SetBnQChannel(P_ChannelCode: Code[20])
    begin
        G_BnQChannelCode := P_ChannelCode;
    end;


    var
        InterimSHGlobal: Record "Interim Sales Header";
        InterimSH2: Record "Interim Sales Header";
        InterimSHTemp: Record "Interim Sales Header" temporary;
        InterimSHTemp2: Record "Interim Sales Header" temporary;
        InterimSL: Record "Interim Sales Line";
        TempSalesHeader: Record "Sales Header" temporary;
        Itemno: Text;
        FirstOrder: Boolean;
        NoOfRecs: Integer;
        Window: Dialog;
        ItemList: Page "Item List";

        NoOfOrders: Integer;
        TotalNoOfOrders: Integer;
        i: Integer;
        CurrRec: Integer;
        NoOfItems: Option Single,Multiple,Everything;
        tcount: Integer;
        PCount: Integer;
        RecItem: Record Item;
        PrimeFilter: Text;
        TotalOrderToProcess: Integer;
        CreateWHInvPick: Codeunit "Process Web Order";
        LastOrderNo: Code[20];
        UseLastProcessedOrder: Boolean;
        UseAllocationboolean: Boolean;
        CreateConsollidatedOrder: Codeunit "Process Web Order";
        G_ChannelCode: Code[20];

        G_BnQChannelCode: Code[20];
        G_TotalQty: Decimal;
        InterimsalesHeader: Record "Interim Sales Header" temporary;
        PickCreated: Boolean; //NIKHIL_18/05/2022 (Bug 6090: Warning message needed "Web Order Process successfully")


    procedure InsertErrorlog(P_Text: Text[250]; var InterimSalesHeader: Record "Interim Sales Header")
    var
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_LineNo: Integer;
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
    begin
        L_PartnerErrorLog.RESET;
        L_PartnerErrorLog.SETRANGE("Document No.", InterimSalesHeader."No.");
        IF L_PartnerErrorLog.FINDLAST THEN
            L_LineNo := L_PartnerErrorLog."Line No." + 10000
        ELSE
            L_LineNo := 10000;

        PartnerErrorLog.INIT;
        PartnerErrorLog."Document No." := InterimSalesHeader."No.";
        PartnerErrorLog.Date := WORKDATE;
        PartnerErrorLog."Line No." := L_LineNo;

        PartnerErrorLog."Error Text" := P_Text;
        PartnerErrorLog.INSERT;
        //InterimSalesHeader."Line Action" := InterimSalesHeader."Line Action"::"No Action";
        InterimSalesHeader.MODIFY;
    end;


    procedure SetNoOfOrders(tempnooforderno: Integer)
    begin
        NoOfOrders := tempnooforderno;
    end;

    procedure SetTotalNoOfOrders(temptotal: Integer)
    begin
        TotalNoOfOrders := temptotal;
    end;

    local procedure Reseti()
    begin
        CLEAR(i);
    end;

    local procedure ResetFirstOrder()
    begin
        FirstOrder := TRUE;
    end;

    local procedure UpdatePreviousOrderLines(TradePartner: Record "Trade Partner") //CS++NEED TO UPDATE FIELDS and code
    var
        RecSalesLine1: Record "Sales Line";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
    begin
        CASE "Trade Partner"."Process Order Type" OF
            "Trade Partner"."Process Order Type"::"Internal Pick":
                BEGIN
                    WhseInternalPickLine.RESET;
                    // WhseInternalPickLine.SETRANGE("Existing Order", FALSE);
                    // WhseInternalPickLine.SETRANGE("Channel Code", TradePartner.Code);
                    IF WhseInternalPickLine.FINDSET THEN
                        REPEAT
                            //       WhseInternalPickLine."Existing Order" := TRUE;
                            WhseInternalPickLine.MODIFY;
                        UNTIL WhseInternalPickLine.NEXT = 0;
                END;
            "Trade Partner"."Process Order Type"::"Single Order", "Trade Partner"."Process Order Type"::"Consolidate Order":
                BEGIN
                    RecSalesLine1.RESET;
                    // RecSalesLine1.SETRANGE("Existing Order", FALSE);
                    //RecSalesLine1.SETRANGE("Shortcut Dimension 1 Code",FALSE);
                    IF RecSalesLine1.FINDSET THEN
                        REPEAT
                        //          RecSalesLine1."Existing Order" := TRUE;
                        //           RecSalesLine1.MODIFY;
                        UNTIL RecSalesLine1.NEXT = 0;
                END;
        END;
    end;

    procedure SetChannelPartner(P_ChannelCode: Code[20])
    begin
        G_ChannelCode := P_ChannelCode;
    end;

    //this function is not in use and moved into codeunit order ackknowladge 
    local procedure ShopdirectOrderAck(ChannelPartner: Record "Trade Partner")
    var
        FileCount: Text;
        Customer: Record Customer;
        InterimSalesHeader: Record "Interim Sales Header";
        TodayDate: Text;
        MultilineorderNoref: Code[250];
        InterimSalesHeader2: Record "Interim Sales Header";
        InterimSalesHeader3: Record "Interim Sales Header";
        xmlElem: XmlElement;
        xmlElem2: XmlElement;
        Tempblob: Codeunit "Temp Blob";
        xmlElem3: XmlElement;
        xmlElem4: XmlElement;
        xmlElem5: XmlElement;
        xmlElem6: XmlElement;
        xmlElem7: XmlElement;
        xmlElem8: XmlElement;
        xmlElem9: XmlElement;
        xmlElem10: XmlElement;
        xmlElem11: XmlElement;
        xmlElem12: XmlElement;
        xmlDoc: XmlDocument;
        xmlDec: XmlDeclaration;
        OutStr: OutStream;
        inStr: InStream;
        fileName: Text;
        L_TradePartner: Record "Trade Partner";
        OrderAck: Codeunit "Order Acknowledgement";
    begin
        /*    Clear(xmlElem);
            Clear(xmlElem2);
            Clear(xmlElem3);
            Clear(xmlElem4);
            Clear(xmlElem5);
            Clear(xmlElem6);
            Clear(xmlElem7);
            Clear(xmlElem8);
            Clear(xmlElem9);
            Clear(xmlElem10);
            Clear(xmlElem11);
            Clear(xmlElem12);
            Clear(xmlDoc);
            Clear(xmlDec);
            Clear(outStr);
            TodayDate := FORMAT(TODAY, 0, '<Month,2>_<Day,2>_<Year4>');
            TodayDate := DELCHR(TodayDate, '=', '/');

            xmlDoc := xmlDocument.Create();
            xmlDec := xmlDeclaration.Create('1.0', 'UTF-8', '');
            xmlDoc.SetDeclaration(xmlDec);

            xmlElem := xmlElement.Create('STATUSES');

            xmlElem2 := XmlElement.Create('SENDERADDRESS');
            xmlElem2.Add(xmlText.Create('R0200'));

            xmlElem3 := XmlElement.Create('DATATYPE');
            xmlElem3.Add(xmlText.Create('30'));

            xmlElem.Add(xmlElem2);
            xmlElem.Add(xmlElem3);




            InterimSalesHeader.RESET;
            InterimSalesHeader.SETFILTER("Trade Partner Code", ChannelPartner.Code);
            InterimSalesHeader.SETRANGE(Status, InterimSalesHeader.Status::Processing);
            InterimSalesHeader.SETRANGE("Order Ack. Exported", FALSE);
            IF InterimSalesHeader.FindSet() THEN begin
                REPEAT

                    xmlElem4 := XmlElement.Create('STATUS');

                    xmlElem5 := XmlElement.Create('DATE');
                    xmlElem5.Add(xmlText.Create(Format(Today)));

                    xmlElem6 := XmlElement.Create('TIME');
                    xmlElem6.Add(xmlText.Create(Format(Time)));

                    xmlElem12 := XmlElement.Create('STATUSCODE');
                    xmlElem12.Add(xmlText.Create('11'));

                    xmlElem4.Add(xmlElem5);
                    xmlElem4.Add(xmlElem6);
                    xmlElem4.Add(xmlElem12);

                    xmlElem7 := XmlElement.Create('ORDER');

                    xmlElem8 := XmlElement.Create('ORDERNUMBER');
                    xmlElem8.Add(xmlText.Create(InterimSalesHeader."Channel Order ID"));

                    xmlElem9 := XmlElement.Create('ORDERDATE');
                    xmlElem9.Add(xmlText.Create(FORMAT(InterimSalesHeader."Order Placed At", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Second,2>')));

                    xmlElem7.Add(xmlElem8);
                    xmlElem7.Add(xmlElem9);

                    xmlElem10 := XmlElement.Create('SUPPLIER');
                    xmlElem7.Add(xmlElem10);

                    xmlElem11 := XmlElement.Create('BUYERREFERENCE');
                    xmlElem11.Add(xmlText.Create(InterimSalesHeader."Web Shipping Agent"));

                    xmlElem10.Add(xmlElem11);

                    xmlElem4.Add(xmlElem7);
                    xmlElem.Add(xmlElem4);

                    IF InterimSalesHeader3.GET(InterimSalesHeader."Document Type", InterimSalesHeader."No.") THEN BEGIN
                        InterimSalesHeader3."Order Ack. Exported" := TRUE;
                        InterimSalesHeader3.MODIFY;
                    END;

                UNTIL InterimSalesHeader.NEXT = 0;


                xmlDoc.Add(xmlElem);


                // Create an outStream from the Blob, notice the encoding.
                TempBlob.CreateOutStream(outStr, TextEncoding::UTF8);

                // Write the contents of the doc to the stream
                xmlDoc.WriteTo(outStr);

                // From the same Blob, that now contains the XML document, create an inStr
                TempBlob.CreateInStream(inStr, TextEncoding::UTF8);

                IF (ChannelPartner."Last Date to Export Order Ack" = 0D) OR (ChannelPartner."Last Date to Export Order Ack" <> TODAY) THEN
                    FileCount := '00'
                ELSE
                    FileCount := INCSTR(ChannelPartner.TariffCode);

                ChannelPartner."Last Date to Export Order Ack" := TODAY;
                ChannelPartner.TariffCode := FileCount;
                ChannelPartner.MODIFY;

                // Save the data of the InStream as a file.
                fileName := ChannelPartner.Code + '.' + 'ASN.' + TodayDate + '.' + FileCount + '.XML';
                OrderAck.UploadFileTOAzureBlob(inStr, fileName, ChannelPartner.Code);
            end;*/
    end;
}

