report 90000 "Process Web Orders"
{
    ProcessingOnly = true;
    Permissions = tabledata "Bank Account" = R;

    dataset
    {
        dataitem("Trade Partner"; "Trade Partner")
        {
            dataitem(InterimSH; "Interim Sales Header")
            {
                CalcFields = "No of Error", "Tracking No.", "Sales Order Created";
                DataItemLink = "Trade Partner Code" = FIELD(Code);
                DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = FILTER(Order), Status = FILTER(Accepted), "Sales Order Created" = const(false));
                RequestFilterFields = "No.", "Document Date", "Shipping Agent Code", "Shipping Agent Service Code";
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
                                if InterimSHTemp.get(InterimSH."Document Type", InterimSH."No.") then
                                    ResetFirstOrder();

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
                                    LastOrderNo := InterimSH."No.";
                                    PickCreated := true;
                                END;
                            END;
                        "Trade Partner"."Process Order Type"::"Single Order":
                            BEGIN
                                #Region Default Ochannel code Not required in sigma++
                                // GenSetup.Get();
                                // if GenSetup."Allocate Web Orders" = true then begin
                                //     WebOrderMgt.OrderValidations(InterimSH);
                                //     Commit();
                                // end;

                                // if InterimSH.status = InterimSH.status::Accepted then begin
                                //     CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Single Order");
                                //     IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
                                //         CreateOrderErrror := GETLASTERRORTEXT();
                                //         InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
                                //         InterimSH.MODIFY();
                                //     END ELSE BEGIN
                                //         Commit();
                                //         LastOrderNo := InterimSH."No.";
                                //         PickCreated := true;
                                //     END;
                                // end;
                                #EndRegion Default Ochannel code Not required in sigma++

                                CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Single Order");
                                IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
                                    CreateOrderErrror := GETLASTERRORTEXT();
                                    InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
                                    InterimSH.MODIFY();
                                END ELSE BEGIN
                                    Commit();
                                    LastOrderNo := InterimSH."No.";
                                    PickCreated := true;
                                END;
                            END;
                        "Trade Partner"."Process Order Type"::"Consolidate Order":
                            BEGIN
                                IF FirstOrder THEN BEGIN
                                    CreateConsollidatedOrder.SetParamters(FirstOrder, "Trade Partner"."Process Order Type"::"Consolidate Order");
                                    FirstOrder := FALSE;
                                END ELSE
                                    CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Consolidate Order");

                                IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
                                    CreateOrderErrror := GETLASTERRORTEXT();
                                    InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
                                    InterimSH.MODIFY();
                                END ELSE BEGIN
                                    LastOrderNo := InterimSH."No.";
                                    PickCreated := true;
                                END;
                            END;
                    END;

                    //++
                    CurrRec += 1;
                    IF NoOfRecs <= 100 THEN
                        Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1)
                    ELSE
                        IF CurrRec MOD (NoOfRecs DIV 100) = 0 THEN
                            Window.UPDATE(1, (CurrRec / NoOfRecs * 10000) DIV 1);

                    //++
                    IF NoOfOrders > 0 THEN BEGIN
                        IF i >= NoOfOrders THEN BEGIN
                            COMMIT;
                            Reseti;
                            ResetFirstOrder;
                        END;
                    END;
                end;

                trigger OnPostDataItem()
                var
                    TradePartner: Record "Trade Partner";
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                begin
                    #Region Not Required for Sigma++
                    // TradePartner.Reset();
                    // TradePartner.SetRange(Code, "Trade Partner".Code);
                    // if TradePartner.FindFirst() then begin
                    //     if TradePartner."Order Acknowledgement Required" then begin
                    //         JobQueueEntry.Init;
                    //         JobQueueEntry.ID := CreateGuid();
                    //         JobQueueEntry."Parameter String" := TradePartner.Code + ';OrderAcknowledgement';
                    //         JobQueueEntry.Insert;

                    //         Codeunit.Run(TradePartner."Order Acknowledgement Codeunit", JobQueueEntry);
                    //         JobQueueEntry.Delete();
                    //     end;
                    // end;
                    #EndRegion Not Required for Sigma++
                end;

                trigger OnPreDataItem()
                var
                    L_OchannelGenSetup: Record "General Setup - Channels";
                begin
                    //++
                    IF "Trade Partner".Code = 'LIFERAY' then
                        InterimSH.SetRange("Consolidated Order", true);



                    L_OchannelGenSetup.Get();
                    if "Trade Partner"."Tracking No Valid. Required" then
                        InterimSH.SetFilter("Tracking No.", '<>%1', '');
                    Window.OPEN('Processing... @1@@@@@@@@@@');
                    if "Trade Partner"."Process Order Type" = "Trade Partner"."Process Order Type"::"Internal Pick" then begin
                        case NoOfItems of
                            NoOfItems::Single:
                                begin
                                    InterimSH.SETFILTER("No. of Items", '%1', 1);
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
            begin
                //++
                "Trade Partner".TestField(SyncOrder, true);

                //++
                Reseti;
                ResetFirstOrder;

                //++
                Clear(G_ProcessOrderType);
                G_ProcessOrderType := "Trade Partner"."Process Order Type";
            end;

            trigger OnPreDataItem()
            begin
                PickCreated := false;
                IF G_ChannelCode <> '' THEN
                    "Trade Partner".SetFilter("Trade Partner".Code, G_ChannelCode);
                "Trade Partner".SetRange(SyncOrder, true);
            end;

            trigger OnPostDataItem()
            begin
                if PickCreated = true then
                    Message('Web Order Processed Successfully');
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                field(G_ChannelCode; G_ChannelCode)
                {
                    ApplicationArea = all;
                    Caption = 'Channel Code';
                    TableRelation = "Trade Partner".Code;
                }
                field("No Of Orders"; NoOfOrders)
                {
                    ApplicationArea = all;
                    Visible = false;
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

        trigger OnOpenPage()
        begin
            NoOfItems := NoOfItems::Everything;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = CloseAction::OK then begin
                if G_ChannelCode = '' then
                    Error('Channel Code should not be blank');
            end;
        end;

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
        L_SalesReceivablesSetup: Record "Sales & Receivables Setup";
        "Manual/KNAAP SO Process": Codeunit "Manual/KNAAP SO Process";
    begin
        #Region Only For Sigma process++
        if G_ProcessOrderType = G_ProcessOrderType::"Consolidate Order" then
            L_CreateConsolidateSO.ProcessTemporarySalesLinetoSalesOrder();

        if G_ProcessOrderType = G_ProcessOrderType::"Single Order" then
            L_CreateConsolidateSO.SingleOrder_ProcessTemporarySalesLinetoSalesOrder();
        #EndRegion Only For Sigma process++

        #Region Release sales Orders+++
        L_SalesReceivablesSetup.Get();
        if L_SalesReceivablesSetup."Check Release on Consolidation" = true then begin
            "Manual/KNAAP SO Process".UpdateKnappOrders();
            "Manual/KNAAP SO Process".UpdateNonKnappOrders();
        end;
        #EndRegion Release sales Orders+++
    end;

    var
        InterimSHTemp: Record "Interim Sales Header" temporary;
        FirstOrder: Boolean;
        NoOfRecs: Integer;
        Window: Dialog;
        ItemList: Page "Item List";
        NoOfOrders: Integer;
        TotalNoOfOrders: Integer;
        i: Integer;
        CurrRec: Integer;
        NoOfItems: Option Single,Multiple,Everything;
        RecItem: Record Item;
        CreateWHInvPick: Codeunit "Process Web Order";
        LastOrderNo: Code[250];
        UseLastProcessedOrder: Boolean;
        UseAllocationboolean: Boolean;
        CreateConsollidatedOrder: Codeunit "Process Web Order";
        G_ChannelCode: Code[20];
        //G_BnQChannelCode: Code[20];
        G_TotalQty: Decimal;
        PickCreated: Boolean;
        G_ProcessOrderType: Option "Internal Pick","Single Order","Consolidate Order";


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

    procedure SetChannelPartner(P_ChannelCode: Code[20])
    begin
        G_ChannelCode := P_ChannelCode;
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
        //G_BnQChannelCode := P_ChannelCode;
    end;

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
        InterimSalesHeader.MODIFY;
    end;
}

