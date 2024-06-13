page 90005 "Handled Web Order List"
{
    CardPageID = "Handle Web Order";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = "Handled Interim Sales Header";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field("ET Access Code"; Rec."ET Access Code")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
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
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = all;
                }
                field("Document Date"; Rec."Document Date")
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
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Re-Order")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = true;
                trigger OnAction()
                var
                    RecInterimSalesHeader: Record "Interim Sales Header";
                    L_HandledInterimSalesLine: record "Handled Interim Sales Line";
                    DocNo: Code[20];
                    L_InterimSalesHeader: record "Interim Sales Header";
                    InterimSalesLine: record "Interim Sales Line";
                    L_Date: Record Date;
                begin
                    Clear(DocNo);
                    RecInterimSalesHeader.Init();
                    RecInterimSalesHeader.TransferFields(Rec);
                    RecInterimSalesHeader."Document Type" := Rec."Document Type";
                    IF StrPos(Rec."No.", '-') = 0 THEN
                        DocNo := Rec."No." + '-01'
                    ELSE
                        DocNo := IncStr(Rec."No.");
                    RecInterimSalesHeader."No." := DocNo;
                    RecInterimSalesHeader.Status := Rec.Status;
                    RecInterimSalesHeader."Order Date" := Today;
                    RecInterimSalesHeader."Document Date" := Today;
                    RecInterimSalesHeader."Order Created On" := CurrentDateTime;
                    RecInterimSalesHeader."Channel Order ID" := Rec."Channel Order ID";
                    RecInterimSalesHeader."External Document No." := Rec."External Document No.";

                    //Update Shipment Date++
                    L_Date.Reset();
                    L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                    L_Date.SetRange(L_Date."Period Start", Today);
                    if L_Date.FindFirst() then begin
                        if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                            if RecInterimSalesHeader."Weekend Ship Agent Serv Code" <> '' then
                                //Update Saturday++
                                RecInterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today))
                            else begin
                                //Update Monday
                                RecInterimSalesHeader.Validate("Shipment Date", CalcDate('<+3D>', Today))
                            end;
                        end else
                            RecInterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today));
                    end;
                    RecInterimSalesHeader.Comments := 'Reorder';
                    RecInterimSalesHeader.Insert(true);

                    L_InterimSalesHeader.Reset();
                    L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
                    L_InterimSalesHeader.SetRange("No.", DocNo);
                    IF L_InterimSalesHeader.FindFirst() then begin
                        L_HandledInterimSalesLine.Reset();
                        L_HandledInterimSalesLine.SetRange("Document Type", Rec."Document Type");
                        L_HandledInterimSalesLine.SetRange("Document No", Rec."No.");
                        IF L_HandledInterimSalesLine.FindSet() then
                            repeat
                                InterimSalesLine.Init();
                                InterimSalesLine.TransferFields(L_HandledInterimSalesLine);
                                InterimSalesLine."Document Type" := L_InterimSalesHeader."Document Type";
                                InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
                                InterimSalesLine.Status := L_HandledInterimSalesLine.Status;
                                InterimSalesLine."Channel Order ID" := L_InterimSalesHeader."Channel Order ID";
                                InterimSalesLine.Insert(true);
                            until L_HandledInterimSalesLine.Next() = 0;
                        Message('Order %1 created.', DocNo);
                    end;
                end;
            }

            // action("Direct Printing Label")
            // {
            //     ApplicationArea = All;
            //     Image = Print;
            //     PromotedCategory = Process;
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     Caption = 'Label Print';
            //     Visible = false;

            //     trigger OnAction()
            //     var
            //         HandledInterimSalesHeader: Record "Handled Interim Sales Header";
            //         WebMgt: Codeunit "Web Order Mgt";
            //         ShippingAgent: Record "Shipping Agent";
            //         L_ShipmentTracking: Record "Shipment Tracking";
            //     begin
            //         HandledInterimSalesHeader.RESET;
            //         HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
            //         IF HandledInterimSalesHeader.FindFirst() THEN BEGIN
            //             ShippingAgent.Reset();
            //             ShippingAgent.SetRange(Code, HandledInterimSalesHeader."Shipping Agent Code");
            //             if ShippingAgent.FindFirst() then begin
            //                 if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
            //                     //RAW Printing Option Means it is For DPD EPL Label and PDF labels
            //                     WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
            //                 end;
            //                 if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
            //                     WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
            //                 end;
            //             end;
            //         END;
            //     end;
            // }
            // action(DeliveryNoteNew)
            // {
            //     ApplicationArea = Basic, Suite;
            //     Caption = 'Delivery Note';
            //     Image = Print;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     Visible = false;


            //     trigger OnAction()
            //     var
            //         HandledInterimSalesHeader: Record "Handled Interim Sales Header";
            //         NewDeliveryNote: Report "Handled Delivery Note";
            //     begin
            //         HandledInterimSalesHeader.RESET;
            //         HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
            //         IF HandledInterimSalesHeader.FINDSET THEN BEGIN
            //             CLEAR(NewDeliveryNote);
            //             NewDeliveryNote.SETTABLEVIEW(HandledInterimSalesHeader);
            //             NewDeliveryNote.RUN;
            //         END;
            //     end;
            // }
            // action(Cancel)
            // {
            //     Caption = 'Cancel';
            //     ApplicationArea = All;
            //     Image = Cancel;
            //     PromotedCategory = Process;
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     Visible = false;
            //     trigger OnAction()
            //     var
            //         L_HISL: Record "Handled Interim Sales Line";
            //     begin

            //         rec.Status := rec.Status::Cancelled;
            //         CurrPage.UPDATE;

            //         //Prathamesh
            //         L_HISL.Reset();
            //         L_HISL.SetRange("Document No", Rec."No.");
            //         if L_HISL.FindSet() then begin
            //             repeat
            //                 L_HISL."Line Status" := L_HISL."Line Status"::Cancelled;
            //                 L_HISL.Modify(true);
            //             until L_HISL.Next() = 0;
            //         end;
            //         //Prathamesh
            //     end;
            // }
            // action("Payment Details")
            // {
            //     Image = Payment;
            //     ApplicationArea = All;
            //     Visible = true;
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     PromotedCategory = Process;
            //     PromotedOnly = true;
            //     Visible = false;
            //     trigger OnAction()
            //     var
            //         // ArchivePayment: Record "Archive Payment Detail";
            //         // PageArchivePayment: Page "Archive Payment Detail";
            //         ChannelMedia: Record "Channel Media";
            //         ChannelOrderId: Text;
            //         ChannelOrderId1: Text;
            //         Length: Integer;
            //     begin
            //         /* if Rec."Document Type" = Rec."Document Type"::Order then begin
            //              ArchivePayment.Reset();
            //              ArchivePayment.SetRange("Order No.", Rec."Channel Order ID");
            //              if ArchivePayment.FindFirst() then begin
            //                  Clear(PageArchivePayment);
            //                  PageArchivePayment.SetTableView(ArchivePayment);
            //                  PageArchivePayment.Run();
            //              end;
            //          end;*/
            //         CurrPage.SetSelectionFilter(HandledOrder);
            //         if HandledOrder.FindSet then
            //             repeat
            //                 ChannelOrderId += HandledOrder."Channel Order ID" + '|' + '';
            //             until HandledOrder.Next = 0;

            //         Length := STRLEN(ChannelOrderId);
            //         ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
            //         ChannelMedia.ShowPaymentDetails(ChannelOrderId1, HandledOrder."Channel Order ID", 0, Rec."Trade Partner Code");

            //     end;
            // }
            // action("Sales Document")
            // {
            //     Caption = '&Sales Document';
            //     Image = Document;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;
            //     Visible = false;
            //     trigger OnAction()
            //     begin
            //         /*  IF Rec."Dispatch No." <> '' THEN BEGIN
            //               SalesShipmentHeader.RESET;
            //               SalesShipmentHeader.GET(Rec."Dispatch No.");
            //               IF SalesShipmentHeader.FINDSET THEN BEGIN
            //                   CLEAR(PostedSalesShipment);
            //                   PostedSalesShipment.SETRECORD(SalesShipmentHeader);
            //                   PostedSalesShipment.RUN;
            //               END;
            //           END ELSE BEGIN
            //               SalesHeader.RESET;
            //               IF SalesHeader.FINDSET THEN BEGIN
            //                   CLEAR(SalesOrder);
            //                   SalesOrder.SETRECORD(SalesHeader);
            //                   SalesOrder.RUN;
            //               END;
            //           END;*/
            //     end;
            // }
        }
    }

    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesOrder: Page "Sales Order";
        PostedSalesShipment: Page "Posted Sales Shipment";
        HandledOrder: Record "Handled Interim Sales Header";
}