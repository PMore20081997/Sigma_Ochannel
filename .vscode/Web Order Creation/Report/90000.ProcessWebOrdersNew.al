// report 90000 "Process Web Orders"
// {
//     ProcessingOnly = true;

//     dataset
//     {
//         dataitem("Trade Partner"; "Trade Partner")
//         {
//             DataItemTableView = where(SyncOrder = filter(true));
//             dataitem(InterimSH; "Interim Sales Header")
//             {
//                 CalcFields = "No of Error", "Tracking No.", "Sales Order Created";
//                 DataItemLink = "Trade Partner Code" = FIELD(Code);
//                 DataItemTableView = SORTING("Document Type", "No.") WHERE("Document Type" = FILTER(Order), Status = FILTER(Accepted), "Sales Order Created" = const(false));
//                 RequestFilterFields = "No.", "Sell-to Customer No.", "Shipping Agent Code", "Shipping Agent Service Code";
//                 trigger OnAfterGetRecord()
//                 var
//                     CreateOrderErrror: Text;
//                 begin
//                     CASE "Trade Partner"."Process Order Type" OF
//                         "Trade Partner"."Process Order Type"::"Single Order":
//                             BEGIN
//                                 CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Single Order");
//                                 IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
//                                     CreateOrderErrror := GETLASTERRORTEXT();
//                                     InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
//                                     InterimSH.MODIFY();
//                                 END;
//                             END;
//                         "Trade Partner"."Process Order Type"::"Consolidate Order":
//                             BEGIN
//                                 CreateConsollidatedOrder.SetParamters(FALSE, "Trade Partner"."Process Order Type"::"Consolidate Order");
//                                 IF NOT CreateConsollidatedOrder.RUN(InterimSH) THEN BEGIN
//                                     CreateOrderErrror := GETLASTERRORTEXT();
//                                     InsertErrorlog(STRSUBSTNO(CreateOrderErrror, InterimSH."Channel Order ID"), InterimSH);
//                                     InterimSH.MODIFY();
//                                 END;
//                             END;
//                     END;
//                 end;

//                 trigger OnPreDataItem()
//                 var
//                     L_OchannelGenSetup: Record "General Setup - Channels";
//                 begin
//                     //Check for LIFERAY orders++
//                     IF "Trade Partner".Code = 'LIFERAY' then
//                         InterimSH.SetRange("Consolidated Order", true);
//                 end;
//             }

//             trigger OnAfterGetRecord()
//             begin
//                 //++
//                 Clear(G_ProcessOrderType);
//                 G_ProcessOrderType := "Trade Partner"."Process Order Type";
//             end;

//             trigger OnPreDataItem()
//             begin
//                 //Apply Channel Code Filter++
//                 "Trade Partner".SetFilter("Trade Partner".Code, G_ChannelCode);
//             end;
//         }
//     }

//     requestpage
//     {
//         layout
//         {
//             area(Content)
//             {
//                 group("Filters")
//                 {
//                     Caption = 'Filters: ';
//                     field(G_ChannelCode; G_ChannelCode)
//                     {
//                         ApplicationArea = all;
//                         Caption = 'Channel Code';
//                         TableRelation = "Trade Partner".Code;
//                     }
//                     field("Total No of Orders"; "TotalNoOfOrders")
//                     {
//                         ApplicationArea = All;
//                         Caption = 'Total No Of Orders';
//                         Editable = false;
//                     }
//                 }
//             }
//         }

//         trigger OnQueryClosePage(CloseAction: Action): Boolean
//         begin
//             if CloseAction = CloseAction::OK then begin
//                 if G_ChannelCode = '' then
//                     Error('Channel Code should not be blank');
//             end;
//         end;

//     }

//     trigger OnPreReport()
//     var
//         L_CreateConsolidateSO: Codeunit "Create Consolidate SO";
//     begin
//         //Only For Sigma process++
//         L_CreateConsolidateSO.ClearVariable();
//     end;

//     trigger OnPostReport()
//     var
//         L_CreateConsolidateSO: Codeunit "Create Consolidate SO";
//         "Manual/KNAAP SO Process": Codeunit "Manual/KNAAP SO Process";
//         L_SalesReceivablesSetup: Record "Sales & Receivables Setup";
//     begin
//         #Region Only For Sigma process++
//         if G_ProcessOrderType = G_ProcessOrderType::"Consolidate Order" then
//             L_CreateConsolidateSO.ProcessTemporarySalesLinetoSalesOrder();

//         if G_ProcessOrderType = G_ProcessOrderType::"Single Order" then
//             L_CreateConsolidateSO.SingleOrder_ProcessTemporarySalesLinetoSalesOrder();
//         #EndRegion Only For Sigma process++

//         #Region Release sales Orders+++
//         L_SalesReceivablesSetup.Get();
//         if L_SalesReceivablesSetup."Check Release on Consolidation" = true then begin
//             "Manual/KNAAP SO Process".UpdateKnappOrders();
//             "Manual/KNAAP SO Process".UpdateNonKnappOrders();
//         end;
//         #EndRegion Release sales Orders+++
//     end;

//     var
//         TotalNoOfOrders: Integer;
//         CreateConsollidatedOrder: Codeunit "Process Web Order";
//         G_ChannelCode: Code[20];
//         G_ProcessOrderType: Option "Internal Pick","Single Order","Consolidate Order";

//     procedure SetTotalNoOfOrders(temptotal: Integer)
//     begin
//         TotalNoOfOrders := temptotal;
//     end;

//     procedure SetChannelPartner(P_ChannelCode: Code[20])
//     begin
//         G_ChannelCode := P_ChannelCode;
//     end;

//     procedure InsertErrorlog(P_Text: Text[250]; var InterimSalesHeader: Record "Interim Sales Header")
//     var
//         L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
//         L_LineNo: Integer;
//         PartnerErrorLog: Record "Incoming/Outgoing Error Log";
//     begin
//         L_PartnerErrorLog.RESET;
//         L_PartnerErrorLog.SETRANGE("Document No.", InterimSalesHeader."No.");
//         IF L_PartnerErrorLog.FINDLAST THEN
//             L_LineNo := L_PartnerErrorLog."Line No." + 10000
//         ELSE
//             L_LineNo := 10000;

//         PartnerErrorLog.INIT;
//         PartnerErrorLog."Document No." := InterimSalesHeader."No.";
//         PartnerErrorLog.Date := WORKDATE;
//         PartnerErrorLog."Line No." := L_LineNo;
//         PartnerErrorLog."Error Text" := P_Text;
//         PartnerErrorLog.INSERT;
//         InterimSalesHeader.MODIFY;
//     end;
// }

