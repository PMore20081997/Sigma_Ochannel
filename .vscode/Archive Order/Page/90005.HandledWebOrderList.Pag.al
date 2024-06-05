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

    // actions
    // {
    //     area(processing)
    //     {
    //         action("Direct Printing Label")
    //         {
    //             ApplicationArea = All;
    //             Image = Print;
    //             PromotedCategory = Process;
    //             Promoted = true;
    //             PromotedIsBig = true;
    //             PromotedOnly = true;
    //             Caption = 'Label Print';
    //             Visible = false;

    //             trigger OnAction()
    //             var
    //                 HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    //                 WebMgt: Codeunit "Web Order Mgt";
    //                 ShippingAgent: Record "Shipping Agent";
    //                 L_ShipmentTracking: Record "Shipment Tracking";
    //             begin
    //                 HandledInterimSalesHeader.RESET;
    //                 HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
    //                 IF HandledInterimSalesHeader.FindFirst() THEN BEGIN
    //                     ShippingAgent.Reset();
    //                     ShippingAgent.SetRange(Code, HandledInterimSalesHeader."Shipping Agent Code");
    //                     if ShippingAgent.FindFirst() then begin
    //                         if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
    //                             //RAW Printing Option Means it is For DPD EPL Label and PDF labels
    //                             WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
    //                         end;
    //                         if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
    //                             WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
    //                         end;
    //                     end;
    //                 END;
    //             end;
    //         }
    //         action(DeliveryNoteNew)
    //         {
    //             ApplicationArea = Basic, Suite;
    //             Caption = 'Delivery Note';
    //             Image = Print;
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             PromotedIsBig = true;
    //             PromotedOnly = true;
    //             Visible = false;


    //             trigger OnAction()
    //             var
    //                 HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    //                 NewDeliveryNote: Report "Handled Delivery Note";
    //             begin
    //                 HandledInterimSalesHeader.RESET;
    //                 HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
    //                 IF HandledInterimSalesHeader.FINDSET THEN BEGIN
    //                     CLEAR(NewDeliveryNote);
    //                     NewDeliveryNote.SETTABLEVIEW(HandledInterimSalesHeader);
    //                     NewDeliveryNote.RUN;
    //                 END;
    //             end;
    //         }
    //         action(ReOrder)
    //         {
    //             ApplicationArea = All;
    //             Caption = 'Reorder';
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             PromotedIsBig = true;
    //             PromotedOnly = true;
    //             Visible = false;
    //             trigger OnAction()
    //             var
    //                 RecInterimSalesHeader: Record "Interim Sales Header";
    //                 L_HandledInterimSalesHeader: record "Handled Interim Sales Line";
    //                 DocNo: Code[20];
    //                 L_InterimSalesHeader: record "Interim Sales Header";
    //                 InterimSalesLine: record "Interim Sales Line";
    //             begin
    //                 CLEAR(DocNo);
    //                 RecInterimSalesHeader.INIT;
    //                 //MapHeader(Rec,RecInterimSalesHeader);
    //                 RecInterimSalesHeader.TransferFields(Rec);
    //                 RecInterimSalesHeader."Document Type" := Rec."Document Type";
    //                 RecInterimSalesHeader."Document Type" := Rec."Document Type";
    //                 IF STRPOS(Rec."No.", '-') = 0 THEN
    //                     DocNo := Rec."No." + '-01'
    //                 ELSE
    //                     DocNo := INCSTR(Rec."No.");//+'-01'
    //                 RecInterimSalesHeader."No." := DocNo;
    //                 RecInterimSalesHeader."Package Tracking No." := '';
    //                 RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::"In Progress";
    //                 RecInterimSalesHeader."Order Date" := TODAY;
    //                 RecInterimSalesHeader."Document Date" := TODAY;
    //                 RecInterimSalesHeader."Channel Order ID" := rec."Channel Order ID" + 'R';
    //                 RecInterimSalesHeader."External Document No." := CopyStr(rec."External Document No." + 'R', 1, 20);
    //                 RecInterimSalesHeader.Comments := 'Reorder';
    //                 CLEAR(RecInterimSalesHeader."Scanned By");
    //                 CLEAR(RecInterimSalesHeader."Package Tracking No.");
    //                 CLEAR(RecInterimSalesHeader."Destination Doc No.");
    //                 CLEAR(RecInterimSalesHeader."Destination Doc Type");
    //                 CLEAR(RecInterimSalesHeader."Scanned Date");
    //                 CLEAR(RecInterimSalesHeader."Job Reference");
    //                 RecInterimSalesHeader.INSERT(TRUE);


    //                 L_InterimSalesHeader.RESET;
    //                 L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
    //                 L_InterimSalesHeader.SETRANGE("No.", DocNo);
    //                 IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
    //                     L_HandledInterimSalesHeader.RESET;
    //                     L_HandledInterimSalesHeader.SETRANGE("Document Type", Rec."Document Type");
    //                     L_HandledInterimSalesHeader.SETRANGE("Document No", Rec."No.");
    //                     IF L_HandledInterimSalesHeader.FINDSET THEN
    //                         REPEAT
    //                             InterimSalesLine.INIT;
    //                             InterimSalesLine.TRANSFERFIELDS(L_HandledInterimSalesHeader);
    //                             InterimSalesLine."Document Type" := L_InterimSalesHeader."Document Type";
    //                             InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
    //                             Clear(InterimSalesLine."Destination Doc. Line No");
    //                             CLEAR(InterimSalesLine."Destination Doc No.");
    //                             CLEAR(InterimSalesLine."Destination Doc Type");
    //                             CLEAR(InterimSalesLine."Scanned Date");
    //                             CLEAR(InterimSalesLine."Dispatch Scan");
    //                             CLEAR(InterimSalesLine."Trolley No.");
    //                             CLEAR(InterimSalesLine."Line Status");
    //                             CLEAR(InterimSalesLine."Pick No");
    //                             CLEAR(InterimSalesLine."Picking Status");
    //                             CLEAR(InterimSalesLine."Pick Line No");
    //                             InterimSalesLine.Status := InterimSalesLine.Status::"In Progress";
    //                             InterimSalesLine.Reserved := FALSE;
    //                             InterimSalesLine."Channel Order ID" := L_InterimSalesHeader."Channel Order ID";
    //                             InterimSalesLine.INSERT(TRUE);
    //                         UNTIL L_HandledInterimSalesHeader.NEXT = 0;
    //                     MESSAGE('Order %1 created.', DocNo);
    //                 END;

    //             end;
    //         }
    //         action(Cancel)
    //         {
    //             Caption = 'Cancel';
    //             ApplicationArea = All;
    //             Image = Cancel;
    //             PromotedCategory = Process;
    //             Promoted = true;
    //             PromotedIsBig = true;
    //             PromotedOnly = true;
    //             Visible = false;
    //             trigger OnAction()
    //             var
    //                 L_HISL: Record "Handled Interim Sales Line";
    //             begin

    //                 rec.Status := rec.Status::Cancelled;
    //                 CurrPage.UPDATE;

    //                 //Prathamesh
    //                 L_HISL.Reset();
    //                 L_HISL.SetRange("Document No", Rec."No.");
    //                 if L_HISL.FindSet() then begin
    //                     repeat
    //                         L_HISL."Line Status" := L_HISL."Line Status"::Cancelled;
    //                         L_HISL.Modify(true);
    //                     until L_HISL.Next() = 0;
    //                 end;
    //                 //Prathamesh
    //             end;
    //         }
    //         action("Payment Details")
    //         {
    //             Image = Payment;
    //             ApplicationArea = All;
    //             Visible = true;
    //             Promoted = true;
    //             PromotedIsBig = true;
    //             PromotedCategory = Process;
    //             PromotedOnly = true;
    //             Visible = false;
    //             trigger OnAction()
    //             var
    //                 // ArchivePayment: Record "Archive Payment Detail";
    //                 // PageArchivePayment: Page "Archive Payment Detail";
    //                 ChannelMedia: Record "Channel Media";
    //                 ChannelOrderId: Text;
    //                 ChannelOrderId1: Text;
    //                 Length: Integer;
    //             begin
    //                 /* if Rec."Document Type" = Rec."Document Type"::Order then begin
    //                      ArchivePayment.Reset();
    //                      ArchivePayment.SetRange("Order No.", Rec."Channel Order ID");
    //                      if ArchivePayment.FindFirst() then begin
    //                          Clear(PageArchivePayment);
    //                          PageArchivePayment.SetTableView(ArchivePayment);
    //                          PageArchivePayment.Run();
    //                      end;
    //                  end;*/
    //                 CurrPage.SetSelectionFilter(HandledOrder);
    //                 if HandledOrder.FindSet then
    //                     repeat
    //                         ChannelOrderId += HandledOrder."Channel Order ID" + '|' + '';
    //                     until HandledOrder.Next = 0;

    //                 Length := STRLEN(ChannelOrderId);
    //                 ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
    //                 ChannelMedia.ShowPaymentDetails(ChannelOrderId1, HandledOrder."Channel Order ID", 0, Rec."Trade Partner Code");

    //             end;
    //         }
    //         action("Sales Document")
    //         {
    //             Caption = '&Sales Document';
    //             Image = Document;
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             ApplicationArea = All;
    //             Visible = false;
    //             trigger OnAction()
    //             begin
    //                 /*  IF Rec."Dispatch No." <> '' THEN BEGIN
    //                       SalesShipmentHeader.RESET;
    //                       SalesShipmentHeader.GET(Rec."Dispatch No.");
    //                       IF SalesShipmentHeader.FINDSET THEN BEGIN
    //                           CLEAR(PostedSalesShipment);
    //                           PostedSalesShipment.SETRECORD(SalesShipmentHeader);
    //                           PostedSalesShipment.RUN;
    //                       END;
    //                   END ELSE BEGIN
    //                       SalesHeader.RESET;
    //                       IF SalesHeader.FINDSET THEN BEGIN
    //                           CLEAR(SalesOrder);
    //                           SalesOrder.SETRECORD(SalesHeader);
    //                           SalesOrder.RUN;
    //                       END;
    //                   END;*/
    //             end;
    //         }
    //     }
    // }

    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesOrder: Page "Sales Order";
        PostedSalesShipment: Page "Posted Sales Shipment";
        HandledOrder: Record "Handled Interim Sales Header";
}