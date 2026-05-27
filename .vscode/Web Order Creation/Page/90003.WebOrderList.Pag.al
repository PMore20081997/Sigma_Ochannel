page 90003 "Web Order List"
{
    ApplicationArea = All;
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
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = all;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = all;
                    Caption = 'Customer Order No.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Caption = 'Status';
                }
                // field("Shipment Date"; Rec."Shipment Date")
                // {
                //     ApplicationArea = All;
                // }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = all;
                }
                field("Document Date"; Rec."Document Date")
                {
                    CaptionML = ENU = 'Document Date', ENG = 'Document Date';
                    ApplicationArea = All;
                }
                field("Order Created On"; rec."Order Created On")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("No. of Items"; rec."No. of Items")
                {
                    ApplicationArea = All;
                    Caption = 'No. of Item Lines';
                }
                field("Total Order Quantity"; Rec."Total Order Quantity")
                {
                    ApplicationArea = All;
                }
                field("Total Order Amount"; Rec."Total Order Amount")
                {
                    ApplicationArea = All;
                }
                field("Total Order Amount Incl. VAT"; Rec."Total Order Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("No of Error"; Rec."No of Error")
                {
                    ApplicationArea = all;
                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = all;
                }
                field("Departure Time"; Rec."Departure Time")
                {
                    ApplicationArea = All;

                }
                field("Total Order"; Rec."Total Order")
                {
                    ApplicationArea = All;
                    Caption = 'Total Order Amount';
                }
                field(Special; Rec.Special)
                {
                    ApplicationArea = All;
                    Caption = 'Special Order';
                }
                field("Consolidated Order"; Rec."Consolidated Order")
                {
                    ApplicationArea = all;
                }
                field("Sales Order Created"; Rec."Sales Order Created")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
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
                begin
                    Clear(R90000);
                    InterimSalesHeader.Reset();
                    CurrPage.SetSelectionFilter(InterimSalesHeader);
                    if InterimSalesHeader.FindSet() then begin
                        R90000.SetTotalNoOfOrders(InterimSalesHeader.Count);
                        R90000.SetTableView(InterimSalesHeader);
                        if Rec."Trade Partner Code" = 'B&Q' then
                            R90000.SetBnQChannel(Rec."Trade Partner Code");
                        R90000.UseRequestPage(true);
                        R90000.Run();
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

            action("Check Exceeded Qty")
            {
                ApplicationArea = All;
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                //Visible = false;

                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    InterimSalesLine: Record "Interim Sales Line";
                    QuotaQuantity: Decimal;
                    CU_SalesQuotaQtyValidation: Codeunit "Web Order Sales Quota New";
                    AvailableInventory: Decimal;
                    CU_WebOrderManagement: Codeunit "Web Order Mgt";
                begin
                    Clear(L_InterimSalesHeader);
                    L_InterimSalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_InterimSalesHeader);

                    if L_InterimSalesHeader.FindSet() then begin
                        repeat
                            InterimSalesLine.Reset();
                            InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                            InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
                            if InterimSalesLine.FindSet() then begin
                                repeat
                                    Clear(AvailableInventory);
                                    AvailableInventory := CU_WebOrderManagement.CalculateQtyToDeliver(InterimSalesLine);
                                    AvailableInventory := AvailableInventory - InterimSalesLine."Qty. to Deliver";
                                    Clear(QuotaQuantity);
                                    if CU_SalesQuotaQtyValidation.CheckExceededQty(InterimSalesLine, L_InterimSalesHeader, QuotaQuantity) <> CU_SalesQuotaQtyValidation.CheckExceededQty(InterimSalesLine, L_InterimSalesHeader, QuotaQuantity) ::"No Entry" then
                                        Message(StrSubstNo('Item No - %1\Line Qty - %2\Available Inv - %3\Quota Quantity - %4', InterimSalesLine."No.", InterimSalesLine.Quantity, AvailableInventory, QuotaQuantity))
                                    else
                                        Message('No Quota Set')
                                until InterimSalesLine.Next() = 0;
                            end;
                        until L_InterimSalesHeader.Next() = 0;
                    end;
                end;
            }

            action("Bulk Delete")
            {
                ApplicationArea = All;
                Ellipsis = true;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    InterimSalesHeader: Record "Interim Sales Header";
                    InterimSalesLine: Record "Interim Sales Line";
                begin
                    if Confirm('Do you really want to delete Selected Orders?') then begin
                        Clear(InterimSalesHeader);
                        InterimSalesHeader := Rec;
                        CurrPage.SetSelectionFilter(InterimSalesHeader);

                        if InterimSalesHeader.FindSet() then begin
                            repeat
                                InterimSalesLine.Reset();
                                InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                InterimSalesLine.SetRange("Document Type", InterimSalesHeader."Document Type");
                                if InterimSalesLine.FindSet() then
                                    InterimSalesLine.DeleteAll(true);
                                InterimSalesHeader.Delete(true);
                            until InterimSalesHeader.Next() = 0;
                        end;
                    end;
                end;
            }

            action(MovetoHandled)
            {
                Caption = 'MovetoHandled';
                Ellipsis = true;
                Image = CompleteLine;
                ApplicationArea = all;
                Visible = true;
                trigger OnAction()
                var
                    ProcessOrder: Codeunit "Process Web Order";
                    ISH: Record "Interim Sales Header";
                begin
                    Clear(ISH);
                    ISH := Rec;
                    CurrPage.SetSelectionFilter(ISH);
                    if ISH.FindSet() then begin
                        repeat
                            ProcessOrder.MovedToHandled(ISH, true);
                        until ISH.Next() = 0;
                    end;
                end;
            }

            action("Force Move to Archive")
            {
                Caption = 'Force Move to Archive';
                Ellipsis = true;
                Image = CompleteLine;
                ApplicationArea = all;
                Visible = true;

                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    L_InterimSalesLine: Record "Interim Sales Line";
                    L_HandledInterimHeader: Record "Handled Interim Sales Header";
                    L_HandledInterimLine: Record "Handled Interim Sales Line";
                    REP_90001: Report "Move Scanned Order to Handled";
                    UserSetup: Record "User Setup";
                begin
                    UserSetup.Reset();
                    if UserSetup.Get(UserId) then begin
                        if UserSetup."Allow to Move Web Orders" = true then begin
                            Clear(L_InterimSalesHeader);
                            L_InterimSalesHeader := Rec;
                            CurrPage.SetSelectionFilter(L_InterimSalesHeader);

                            if L_InterimSalesHeader.FindSet() then begin
                                repeat
                                    L_HandledInterimHeader.Reset();
                                    L_HandledInterimHeader.SetRange("Document Type", L_HandledInterimHeader."Document Type"::Order);
                                    L_HandledInterimHeader.SetRange(L_HandledInterimHeader."No.", L_InterimSalesHeader."No.");
                                    IF not L_HandledInterimHeader.FindFirst() THEN BEGIN
                                        //Move Header
                                        REP_90001.MovingHeaderData(L_InterimSalesHeader);

                                        //Move Lines
                                        L_HandledInterimLine.Reset();
                                        L_HandledInterimLine.Init();
                                        L_InterimSalesLine.Reset();
                                        L_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
                                        L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                                        if L_InterimSalesLine.FindSet() then begin
                                            repeat
                                                L_HandledInterimLine.TransferFields(L_InterimSalesLine);
                                                L_InterimSalesLine.CalcFields("Document Date", "Location Code", "Tracking No.");
                                                L_HandledInterimLine."Tracking No." := L_InterimSalesLine."Tracking No.";
                                                L_HandledInterimLine."Document Date" := L_InterimSalesLine."Document Date";
                                                L_HandledInterimLine."Scanned Date" := L_InterimSalesLine."Scanned Date";
                                                L_HandledInterimLine."Location Code" := L_InterimSalesLine."Location Code";
                                                L_HandledInterimLine.Insert(true);
                                            until L_InterimSalesLine.Next() = 0;
                                        end;

                                        L_InterimSalesHeader."Moved In Handled" := TRUE;
                                        L_InterimSalesHeader.Modify();
                                        L_InterimSalesHeader.Delete(true);
                                        Commit();
                                    END;
                                until L_InterimSalesHeader.Next() = 0;
                            end;

                            Message('Process Completed');
                        end
                        else begin
                            Message('You do not have permission to move orders into archive.');
                        end;
                    end
                end;
            }

            // action("Update Reason Code")
            // {
            //     ApplicationArea = All;
            //     Caption = 'Update Reason Code';
            //     Ellipsis = true;
            //     Image = Delete;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;

            //     trigger OnAction()
            //     var
            //         L_Line: Record "Interim Sales Line";
            //         PartnerErrorLog: Record "Incoming/Outgoing Error Log";
            //         L_OrderLevelResponse: Record "Order Level Response";
            //         L_ProductLevelResponse: Record "Product Level Response";
            //         CustomerRef: Record "Customer Reference";
            //         K: Integer;
            //     begin
            //         Clear(InterimSalesHeader);
            //         CurrPage.SetSelectionFilter(InterimSalesHeader);
            //         if InterimSalesHeader.FindSet() then
            //             repeat
            //                 L_Line.Reset();
            //                 L_Line.SetRange("Document Type", InterimSalesHeader."Document Type");
            //                 L_Line.SetRange("Document No", InterimSalesHeader."No.");
            //                 if L_Line.FindSet() then begin
            //                     repeat
            //                         PartnerErrorLog.RESET;
            //                         PartnerErrorLog.SETRANGE("Document No.", InterimSalesHeader."No.");
            //                         PartnerErrorLog.SetFilter("Item No.", L_Line."No.");
            //                         PartnerErrorLog.SetCurrentKey("Sequence No.");
            //                         PartnerErrorLog.Ascending(true);
            //                         IF PartnerErrorLog.FindFirst() THEN begin
            //                             L_ProductLevelResponse.Reset();
            //                             L_ProductLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
            //                             if L_ProductLevelResponse.FindFirst() then begin
            //                                 if L_ProductLevelResponse."Error Code" = 'SEQ9' then begin
            //                                     L_Line."Reason Code" := L_ProductLevelResponse.Reason;
            //                                     L_Line."Reason Message" := PartnerErrorLog.Attribute + ' ' + L_ProductLevelResponse.Message;
            //                                     L_Line.Modify();
            //                                 end else begin
            //                                     L_Line."Reason Code" := L_ProductLevelResponse.Reason;
            //                                     L_Line."Reason Message" := L_ProductLevelResponse.Message;
            //                                     L_Line.Modify();
            //                                 end;
            //                             end;
            //                         end else begin
            //                             L_Line."Reason Code" := 'Order Line Created';
            //                             L_Line."Reason Message" := 'Successful';
            //                             L_Line.Modify();
            //                         end;
            //                     until L_Line.Next() = 0;
            //                 end;
            //             until InterimSalesHeader.Next() = 0;
            //     end;
            // }

        }
        area(Navigation)
        {
            action(ShowCustomer)
            {
                ApplicationArea = All;
                Caption = 'Show Customer';
                Image = Customer;
                RunObject = Page 21;
                RunPageLink = "No." = FIELD("Sell-to Customer No.");
            }
            action("Web Buffer")
            {
                ApplicationArea = All;
                Image = Navigate;
                RunObject = page "Web Buffer";
                RunPageLink = "Web Document No." = field("No.");
            }
        }

        // area(Creation)
        // {
        //     action("Generate Shipment")
        //     {
        //         Image = Shipment;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedIsBig = true;
        //         PromotedOnly = true;
        //         ApplicationArea = All;
        //         Visible = false;
        //         trigger OnAction()
        //         var
        //             L_InterimSalesHeader: Record "Interim Sales Header";
        //             ShippingRule: Record "Shipping Rule";
        //             Rec_ShippingAgent: Record "Shipping Agent";
        //             ShipmentTracking: Record "Shipment Tracking";
        //             ProcessLabel: Codeunit "Auto Generate Shipment";
        //             L_ChannelPartner: Record "Trade Partner";
        //             SecretSales: Codeunit "B&Q";
        //         begin
        //             Clear(L_InterimSalesHeader);
        //             L_InterimSalesHeader := Rec;
        //             CurrPage.SetSelectionFilter(L_InterimSalesHeader);

        //             L_InterimSalesHeader.SetRange("No of Error", 0);
        //             L_InterimSalesHeader.SetRange(ReservedFlag, true);
        //             if L_InterimSalesHeader.FindSet() then begin
        //                 repeat
        //                     ProcessLabel.GenerateLabel(L_InterimSalesHeader);

        //                     L_ChannelPartner.Reset();
        //                     L_ChannelPartner.SetRange(Code, L_InterimSalesHeader."Trade Partner Code");
        //                     if L_ChannelPartner.FindFirst() then begin
        //                         if L_ChannelPartner."Update Tracking Information" = true then begin
        //                             L_InterimSalesHeader.CalcFields("Tracking No.");
        //                             SecretSales.SendTrackingInformation(L_InterimSalesHeader."Shipping Agent Code", L_InterimSalesHeader."Tracking No.", L_InterimSalesHeader.order_id, L_InterimSalesHeader."Trade Partner Code");
        //                         end;
        //                     end;
        //                 until L_InterimSalesHeader.Next() = 0;
        //                 Message('Generate Shipment Process Completed.Please check Error Text in Order if label not generated.');
        //             end;
        //         end;
        //     }

        //     action(MovetoHandled)
        //     {
        //         Caption = 'MovetoHandled';
        //         Ellipsis = true;
        //         Image = CompleteLine;
        //         ApplicationArea = all;
        //         Visible = false;
        //         trigger OnAction()
        //         var
        //             R80020: Report "Move Scanned Order to Handled";
        //         begin
        //             CLEAR(R80020);
        //             //R80020.SETTABLEVIEW(Rec);
        //             R80020.USEREQUESTPAGE(true);
        //             R80020.RUNMODAL();
        //         end;
        //     }
        //     action("Delivery Note A6")
        //     {
        //         ApplicationArea = All;
        //         Image = Report;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedOnly = true;
        //         Visible = false;

        //         trigger OnAction()
        //         var
        //             ISH: Record "Interim Sales Header";
        //             AddText: Text;
        //         begin
        //             CLEAR(AddText);
        //             InterimSalesHeader := Rec;
        //             CurrPage.SETSELECTIONFILTER(InterimSalesHeader);
        //             IF InterimSalesHeader.FINDSET THEN
        //                 REPEAT
        //                     AddToFilterText(AddText, '|', '', InterimSalesHeader."No.")
        //                 UNTIL InterimSalesHeader.NEXT = 0;

        //             ISH.RESET;
        //             ISH.SETRANGE("Document Type", ISH."Document Type"::Order);
        //             ISH.SETFILTER("No.", AddText);
        //             ISH.SETFILTER("Tracking No.", '<>%1', ' ');
        //             IF ISH.FINDSET THEN BEGIN
        //                 REPORT.RUN(90003, TRUE, FALSE, ISH);
        //             END;
        //         end;
        //     }
        //     // action(ExportOrderAck)
        //     // {
        //     //     ApplicationArea = All;
        //     //     Caption = 'ExportOrderAck';
        //     //     Image = Export;
        //     //     Promoted = true;
        //     //     PromotedCategory = Process;
        //     //     PromotedIsBig = true;
        //     //     PromotedOnly = true;
        //     //     trigger OnAction()
        //     //     var
        //     //     begin
        //     //         OrderAck.OrderAckConvertText(rec."Channel Order ID");
        //     //         CurrPage.Update();
        //     //     end;
        //     // }
        // area(Navigation)
        // {
        //     action("Payment Details")
        //     {
        //         CaptionML = ENG = 'Order Payment Details', ENU = 'Order Payment Details';
        //         ApplicationArea = all;
        //         Image = Payment;
        //         Visible = false;

        //         trigger OnAction()
        //         var
        //             ChannelMedia: Record "Channel Media";
        //             ChannelOrderId: Text;
        //             ChannelOrderId1: Text;
        //             Length: Integer;
        //         begin
        //             CurrPage.SetSelectionFilter(InterimSalesHeader);
        //             if InterimSalesHeader.FindSet then
        //                 repeat
        //                     ChannelOrderId += InterimSalesHeader."Channel Order ID" + '|' + '';
        //                 until InterimSalesHeader.Next = 0;

        //             Length := STRLEN(ChannelOrderId);
        //             ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
        //             ChannelMedia.ShowPaymentDetails(ChannelOrderId1, InterimSalesHeader."Channel Order ID", 0, Rec."Trade Partner Code");
        //         end;

        //     }
        //     action("Direct Printing Label")
        //     {
        //         ApplicationArea = All;
        //         Image = Print;
        //         Caption = 'Label Print';
        //         Visible = false;

        //         trigger OnAction()
        //         var
        //             L_InterimSalesHeader: Record "Interim Sales Header";
        //             WebMgt: Codeunit "Web Order Mgt";
        //             ShippingAgent: Record "Shipping Agent";
        //             L_ShipmentTracking: Record "Shipment Tracking";
        //         begin
        //             //WebMgt.SendDirectPrintRequest(Rec."No.", 90081, Rec."No. Of Parcels");
        //             L_InterimSalesHeader.RESET;
        //             L_InterimSalesHeader.SETRANGE("No.", Rec."No.");
        //             IF L_InterimSalesHeader.FindFirst() THEN BEGIN
        //                 ShippingAgent.Reset();
        //                 ShippingAgent.SetRange(Code, L_InterimSalesHeader."Shipping Agent Code");
        //                 if ShippingAgent.FindFirst() then begin
        //                     if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
        //                         //RAW Printing Option Means it is For DPD EPL Label and PDF labels
        //                         WebMgt.SendDirectPrintRequest(L_InterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
        //                     end;
        //                     if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
        //                         WebMgt.SendDirectPrintRequest(L_InterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
        //                     end;
        //                 end;
        //             END;
        //         end;
        //     }
        //     action(ReOrder)
        //     {
        //         ApplicationArea = Warehouse;
        //         Caption = 'Re-Order';
        //         Image = ReturnOrder;
        //         ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';
        //         Visible = false;

        //         trigger OnAction()
        //         var
        //         begin
        //             WebOrdMngt.CopyOrder(Rec);
        //         end;
        //     }
        //     action("Cancel Order")
        //     {
        //         Image = CancelAllLines;
        //         ApplicationArea = All;
        //         Visible = false;


        //         trigger OnAction()
        //         var
        //             RecInterimSalesLine: Record "Interim Sales Line";
        //             L_InterimSalesLine: Record "Interim Sales Line"; //Prathamesh

        //             InterimSalesHeader: Record "Interim Sales Header";
        //         begin
        //             if Not (Rec.status in [rec.status::Confirmed, rec.status::"In Progress", rec.status::Cancelled]) then
        //                 Error('Order Status must be either Confirmed or In progress.');
        //             Clear(InterimSalesHeader);
        //             CurrPage.SetSelectionFilter(InterimSalesHeader);
        //             if InterimSalesHeader.FindFirst() then
        //                 WebOrdMngt.CancelOrder(InterimSalesHeader);
        //         end;
        //     }
        // }
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
        EnableEliminateSelectedError: Boolean;
        EnableReject: Boolean;
        WebOrdMngt: Codeunit "Web Order Mgt";
        OrderAck: Codeunit "Order Acknowledgement";


    //Abdul+++ 02/10/2021
    LOCAL procedure AddToFilterText(VAR TextVar: Text[250]; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;
    //Abdul---
}