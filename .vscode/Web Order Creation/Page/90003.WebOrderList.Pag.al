page 90003 "Web Order List"
{
    // version In Use

    ApplicationArea = All;//Basic, Suite, Assembly;
    CaptionML = ENU = 'Web Orders',
                ENG = 'Web Orders';
    CardPageID = "Web Order Header";
    DeleteAllowed = false;
    UsageCategory = Lists;
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = true;
    SourceTable = "Interim Sales Header";
    SourceTableView = WHERE("Document Type" = CONST(Order));
    InsertAllowed = false;
    Permissions = tabledata "Bank Account" = R;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = all;
                }
                field("ET Access Code"; Rec."ET Access Code")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Old MultiLine Order No."; Rec."Old MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = all;
                }
                field("Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = all;
                    //Caption = 'Tracking No.';
                    CaptionML = ENU = 'Tracking No.', ENG = 'Tracking No.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Caption = 'Status';
                }
                field("Order Status"; Rec."Order Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Status field.';
                    Visible = false;
                }

                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = all;
                }


                field("Document Date"; Rec."Document Date")
                {
                    CaptionML = ENU = 'Document Date', ENG = 'Document Date';
                    ApplicationArea = All;
                }
                field("Order Discount Amount"; Rec."Order Discount Amount")
                {
                    CaptionML = ENU = 'Order Discount Amount', ENG = 'Order Discount Amount';
                    ApplicationArea = all;
                }

                field("Order Created On"; rec."Order Created On")
                {
                    ApplicationArea = All;
                }
                field("No. of Items"; rec."No. of Items")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Item Lines';
                }
                field("Destination Doc Type"; Rec."Destination Doc Type")
                {

                    ApplicationArea = all;
                    Visible = false;
                }
                field(Rec; Rec."Destination Doc No.")
                {
                    ApplicationArea = all;
                    Visible = false;
                    trigger OnDrillDown()
                    begin
                        OpenDestinationDocument(Rec);
                    end;
                }
                field("No of Error"; Rec."No of Error")
                {
                    ApplicationArea = all;
                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = all;
                }
                field("Sales Order Created"; Rec."Sales Order Created")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = all;
                }
                field(Remarks; Rec.Remarks)
                {
                    Visible = false;
                    ApplicationArea = all;
                }

                field("Gift Card"; Rec."Gift Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Card field.';
                    Visible = false;
                }
                field("Gift Order Amount"; Rec."Gift Order Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Order Amount field.';
                    Visible = false;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Test)
            {
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    L_Codeunit: Codeunit "Get Order Request API";
                begin
                    L_Codeunit.Run();
                end;
            }
            action(BulkDelete)
            {
                ApplicationArea = All;
                Caption = 'Bulk Delete';
                trigger OnAction()
                var
                    InterimSalesHeader: Record "Interim Sales Header";
                    InterimSalesLine: Record "Interim Sales Line";
                begin
                    Clear(InterimSalesHeader);
                    CurrPage.SetSelectionFilter(InterimSalesHeader);
                    if InterimSalesHeader.FindSet() then
                        repeat
                            InterimSalesLine.Reset();
                            InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                            if InterimSalesLine.FindSet() then
                                InterimSalesLine.DeleteAll(true);
                            InterimSalesHeader.Delete(true);
                        until InterimSalesHeader.Next() = 0;
                end;

            }
            action(Process)
            {
                Caption = 'Process';
                Ellipsis = true;
                Image = CompleteLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;

                trigger OnAction()
                var
                    R90000: Report "Process Web Orders";
                    ReportParams: Text;
                begin
                    InterimSalesHeader.CopyFilters(Rec);
                    R90000.SetTotalNoOfOrders(Rec.Count);
                    R90000.SetTableView(InterimSalesHeader);
                    if Rec."Trade Partner Code" = 'B&Q' then
                        R90000.SetBnQChannel(Rec."Trade Partner Code");
                    R90000.UseRequestPage(true);
                    R90000.Run();
                end;
            }
            action("Generate Shipment")
            {
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    ShippingRule: Record "Shipping Rule";
                    Rec_ShippingAgent: Record "Shipping Agent";
                    ShipmentTracking: Record "Shipment Tracking";
                    ProcessLabel: Codeunit "Auto Generate Shipment";
                    L_ChannelPartner: Record "Trade Partner";
                    SecretSales: Codeunit "B&Q";
                begin
                    Clear(L_InterimSalesHeader);
                    L_InterimSalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_InterimSalesHeader);

                    L_InterimSalesHeader.SetRange("No of Error", 0);
                    L_InterimSalesHeader.SetRange(ReservedFlag, true);
                    if L_InterimSalesHeader.FindSet() then begin
                        repeat
                            ProcessLabel.GenerateLabel(L_InterimSalesHeader);

                            L_ChannelPartner.Reset();
                            L_ChannelPartner.SetRange(Code, L_InterimSalesHeader."Trade Partner Code");
                            if L_ChannelPartner.FindFirst() then begin
                                if L_ChannelPartner."Update Tracking Information" = true then begin
                                    L_InterimSalesHeader.CalcFields("Tracking No.");
                                    SecretSales.SendTrackingInformation(L_InterimSalesHeader."Shipping Agent Code", L_InterimSalesHeader."Tracking No.", L_InterimSalesHeader.order_id, L_InterimSalesHeader."Trade Partner Code");
                                end;
                            end;
                        until L_InterimSalesHeader.Next() = 0;
                        Message('Generate Shipment Process Completed.Please check Error Text in Order if label not generated.');
                    end;
                end;
            }

            action("Eliminate Selected  Error")
            {
                Caption = 'Eliminate Selected  Error';
                Image = ErrorLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = all;
                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(InterimSalesHeader);
                    if InterimSalesHeader.FindSet() then begin
                        IF InterimSalesHeader.FIND('-') THEN
                            REPEAT
                                //WebOrdMngt.OrderValidations(InterimSalesHeader);
                                WebOrdMngt.Sigma_OrderValidations(InterimSalesHeader);
                            UNTIL InterimSalesHeader.NEXT = 0;
                    end;
                end;
            }

            action("Process Shipping Rule")
            {
                Caption = 'Process Shipping Rule';
                Image = Track;
                Promoted = true;
                Visible = false; //07/07/2020
                ApplicationArea = All;

                trigger OnAction()
                begin
                    REPORT.RUN(50100, TRUE, FALSE, InterimSalesHeader);
                    CurrPage.UPDATE(TRUE);
                end;
            }


            action(MovetoHandled)
            {
                Caption = 'MovetoHandled';
                Ellipsis = true;
                Image = CompleteLine;
                ApplicationArea = all;
                Visible = false;
                trigger OnAction()
                var
                    R80020: Report "Move Scanned Order to Handled";
                begin
                    CLEAR(R80020);
                    //R80020.SETTABLEVIEW(Rec);
                    R80020.USEREQUESTPAGE(true);
                    R80020.RUNMODAL();

                end;
            }
            action("Dispatch Scanning")
            {
                Caption = 'Dispatch Scanning';
                Promoted = true;
                Visible = false;//07/07/2020
                ApplicationArea = All;
                trigger OnAction()
                var
                    myInt: Integer;
                    ISH: Record "Interim Sales Header";
                //DispatchScan: Page "Dispatch Scanning new";
                begin

                    //DispatchScan.Run();
                end;

            }
            action("Delivery Note A6")
            {
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = false;

                trigger OnAction()
                var
                    ISH: Record "Interim Sales Header";
                    AddText: Text;
                begin
                    CLEAR(AddText);
                    InterimSalesHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(InterimSalesHeader);
                    IF InterimSalesHeader.FINDSET THEN
                        REPEAT
                            AddToFilterText(AddText, '|', '', InterimSalesHeader."No.")
                        UNTIL InterimSalesHeader.NEXT = 0;

                    ISH.RESET;
                    ISH.SETRANGE("Document Type", ISH."Document Type"::Order);
                    ISH.SETFILTER("No.", AddText);
                    ISH.SETFILTER("Tracking No.", '<>%1', ' ');
                    IF ISH.FINDSET THEN BEGIN
                        REPORT.RUN(90003, TRUE, FALSE, ISH);
                    END;
                end;
            }

            // action(ExportOrderAck)
            // {
            //     ApplicationArea = All;
            //     Caption = 'ExportOrderAck';
            //     Image = Export;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     trigger OnAction()
            //     var
            //     begin
            //         OrderAck.OrderAckConvertText(rec."Channel Order ID");
            //         CurrPage.Update();
            //     end;
            // }
            // action(ExportOrderAckCopy)
            // {
            //     ApplicationArea = All;
            //     Caption = 'ExportOrderAckCopy';
            //     Image = Export;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     trigger OnAction()
            //     var
            // InterimSalesHeader: Record "Interim Sales Header";
            //     begin
            // Clear(InterimSalesHeader);
            // InterimSalesHeader := Rec;
            // CurrPage.SetSelectionFilter(InterimSalesHeader);
            // InterimSalesHeader.SETRANGE("Trade Partner Code", 'SHOPDIRECT');
            // if InterimSalesHeader.FindSet() then begin
            //     repeat
            //         OrderAck.OrderAckConvertTextCopy();
            //         Message('%1', InterimSalesHeader."Channel Order ID");
            //     until InterimSalesHeader.Next() = 0;
            //     CurrPage.Update();
            // end;
        }
        area(Navigation)
        {
            action("Payment Details")
            {
                CaptionML = ENG = 'Order Payment Details', ENU = 'Order Payment Details';
                ApplicationArea = all;
                Image = Payment;

                trigger OnAction()
                var
                    ChannelMedia: Record "Channel Media";
                    ChannelOrderId: Text;
                    ChannelOrderId1: Text;
                    Length: Integer;
                begin
                    CurrPage.SetSelectionFilter(InterimSalesHeader);
                    if InterimSalesHeader.FindSet then
                        repeat
                            ChannelOrderId += InterimSalesHeader."Channel Order ID" + '|' + '';
                        until InterimSalesHeader.Next = 0;

                    Length := STRLEN(ChannelOrderId);
                    ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
                    ChannelMedia.ShowPaymentDetails(ChannelOrderId1, InterimSalesHeader."Channel Order ID", 0, Rec."Trade Partner Code");
                end;

            }
            action("Direct Printing Label")
            {
                ApplicationArea = All;
                Image = Print;
                Caption = 'Label Print';

                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    WebMgt: Codeunit "Web Order Mgt";
                    ShippingAgent: Record "Shipping Agent";
                    L_ShipmentTracking: Record "Shipment Tracking";
                begin
                    //WebMgt.SendDirectPrintRequest(Rec."No.", 90081, Rec."No. Of Parcels");
                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF L_InterimSalesHeader.FindFirst() THEN BEGIN
                        ShippingAgent.Reset();
                        ShippingAgent.SetRange(Code, L_InterimSalesHeader."Shipping Agent Code");
                        if ShippingAgent.FindFirst() then begin
                            if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
                                //RAW Printing Option Means it is For DPD EPL Label and PDF labels
                                WebMgt.SendDirectPrintRequest(L_InterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
                            end;
                            if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
                                WebMgt.SendDirectPrintRequest(L_InterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
                            end;
                        end;
                    END;
                end;
            }
            action(DeliveryNoteNew)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delivery Note';
                Image = Print;


                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    NewDeliveryNote: Report "Web Delivery Note";
                begin
                    InterimSalesHeader.RESET;
                    InterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF InterimSalesHeader.FINDSET THEN BEGIN
                        CLEAR(NewDeliveryNote);
                        NewDeliveryNote.SETTABLEVIEW(InterimSalesHeader);
                        NewDeliveryNote.RUN;
                    END;
                end;
            }
            action(ShowCustomer)
            {
                ApplicationArea = All;
                Caption = 'Show Customer';
                Image = Customer;
                RunObject = Page 21;
                RunPageLink = "No." = FIELD("Sell-to Customer No.");
            }
            action(ReOrder)
            {
                ApplicationArea = Warehouse;
                Caption = 'Re-Order';
                Image = ReturnOrder;
                ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';

                trigger OnAction()
                var
                begin
                    WebOrdMngt.CopyOrder(Rec);
                end;
            }
            action("Cancel Order")
            {
                Image = CancelAllLines;
                ApplicationArea = All;


                trigger OnAction()
                var
                    RecInterimSalesLine: Record "Interim Sales Line";
                    L_InterimSalesLine: Record "Interim Sales Line"; //Prathamesh

                    InterimSalesHeader: Record "Interim Sales Header";
                begin
                    if Not (Rec.status in [rec.status::Confirmed, rec.status::"In Progress", rec.status::Cancelled]) then
                        Error('Order Status must be either Confirmed or In progress.');
                    Clear(InterimSalesHeader);
                    CurrPage.SetSelectionFilter(InterimSalesHeader);
                    if InterimSalesHeader.FindFirst() then
                        WebOrdMngt.CancelOrder(InterimSalesHeader);
                end;
            }
        }
    }


    trigger OnInit()
    begin
        EnableReject := FALSE;
        EnableEliminateSelectedError := FALSE
    end;

    trigger OnOpenPage()
    begin
        IF (RecStatus = RecStatus::"In Progress") OR (RecStatus = RecStatus::Error) THEN BEGIN
            EnableReject := TRUE;
            EnableEliminateSelectedError := TRUE;
        END;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Rec."Destination Doc No." <> '' then
            Error('Internal Pick exist. Cannot delete the order');
    end;

    var
        RecStatus: Option Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Error;
        InterimSalesHeader: Record "Interim Sales Header";
        //OrderRead: Codeunit "Process Order File-Innox";
        //AmazonIntegration: Codeunit "Amazon Integration"; //Commented By Pavan 20072020
        HeaderNo: Code[20];
        ShipmentTracking: Record "Shipment Tracking";
        LineNo: Integer;
        Temp_SalesHeader: Record "Sales Header" temporary;
        SalesLine: Record "Sales Line";
        EnableEliminateSelectedError: Boolean;
        EnableReject: Boolean;
        EnableAccept: Boolean;
        WebOrdMngt: Codeunit "Web Order Mgt";
        SalesHeader: Record "Sales Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        OrderAck: Codeunit "Order Acknowledgement";



    procedure GetStatus(L_Status: Option Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled; L_InterimSalesHeader: Record "Interim Sales Header")
    begin
        RecStatus := L_Status;
    end;


    //Abdul+++ 02/10/2021
    LOCAL procedure AddToFilterText(VAR TextVar: Text[250]; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;
    //Abdul---


    local procedure OpenDestinationDocument(InterimSalesHeader: Record "Interim Sales Header")
    begin
        CASE InterimSalesHeader."Destination Doc Type" OF
            InterimSalesHeader."Destination Doc Type"::"Internal Pick":
                BEGIN
                    WhseInternalPickHeader.RESET;
                    WhseInternalPickHeader.SETRANGE("No.", InterimSalesHeader."Destination Doc No.");
                    IF WhseInternalPickHeader.FINDFIRST THEN
                        PAGE.RUN(7357, WhseInternalPickHeader);
                END;
            InterimSalesHeader."Destination Doc Type"::"Sales Order":
                BEGIN
                    SalesHeader.RESET;
                    SalesHeader.SETRANGE("No.", InterimSalesHeader."Destination Doc No.");
                    IF SalesHeader.FINDFIRST THEN
                        PAGE.RUN(42, SalesHeader);
                END;
        END;
    end;



}

