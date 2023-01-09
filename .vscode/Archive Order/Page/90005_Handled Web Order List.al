page 90005 "Handled Web Order List"
{
    // version INTE1.0

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
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("<Channel Order ID>"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                    Caption = 'Channel Order ID';
                }

                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                }
                field(MyField; rec."Package Tracking No.")
                {
                    ApplicationArea = All;
                }
                field("Destination Doc Type"; Rec."Destination Doc Type")
                {
                    ApplicationArea = All;
                }
                field("Destination Doc No."; Rec."Destination Doc No.")
                {
                    ApplicationArea = All;
                }
                field(status; Rec.status)
                {
                    ApplicationArea = All;
                }
                field("Order Status"; Rec."Order Status")
                {
                    ApplicationArea = All;
                }

                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field("Scanned Date"; Rec."Scanned Date")
                {
                    ApplicationArea = All;
                }
                field("Scanned By"; Rec."Scanned By")
                {
                    ApplicationArea = All;
                }
                field("Stock Posted"; Rec."Stock Posted")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Financial Entry Posted"; Rec."Financial Entry Posted")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = All;
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ApplicationArea = All;
                }

                field("Order Discount Amount"; Rec."Order Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Gift Order Amount"; Rec."Gift Order Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Order Amount field.';
                }

                field("FullFillment Status"; Rec."FullFillment Status")
                {
                    ApplicationArea = All;
                }
                field("Child Client ID"; Rec."Child Client ID")
                {
                    ApplicationArea = All;
                }
                field("Child Client Name"; Rec."Child Client Name")
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                }
                //Paarth D Dave - 8197-4 - Adding Boolean for Assembly Order ---- Start
                field("Assembly Order Created"; Rec."Assembly Order Created")
                {
                    Editable = false;
                    ApplicationArea = All;
                }

                field("Posted Assembly Order"; Rec."Pstd. Assembly Order")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Posted Assembly Order';
                }

                field("Assemply Order"; Rec."Assemply Order")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Gift Card"; Rec."Gift Card")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Card field.';
                }
                //Paarth D Dave - 8197-4 - Adding Boolean for Assembly Order ---- End

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Direct Printing Label")
            {
                ApplicationArea = All;
                Image = Print;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Caption = 'Label Print';

                trigger OnAction()
                var
                    HandledInterimSalesHeader: Record "Handled Interim Sales Header";
                    WebMgt: Codeunit "Web Order Mgt";
                    ShippingAgent: Record "Shipping Agent";
                    L_ShipmentTracking: Record "Shipment Tracking";
                begin
                    HandledInterimSalesHeader.RESET;
                    HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF HandledInterimSalesHeader.FindFirst() THEN BEGIN
                        ShippingAgent.Reset();
                        ShippingAgent.SetRange(Code, HandledInterimSalesHeader."Shipping Agent Code");
                        if ShippingAgent.FindFirst() then begin
                            if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
                                //RAW Printing Option Means it is For DPD EPL Label and PDF labels
                                WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
                            end;
                            if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
                                WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;


                trigger OnAction()
                var
                    HandledInterimSalesHeader: Record "Handled Interim Sales Header";
                    NewDeliveryNote: Report "Handled Delivery Note";
                begin
                    HandledInterimSalesHeader.RESET;
                    HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF HandledInterimSalesHeader.FINDSET THEN BEGIN
                        CLEAR(NewDeliveryNote);
                        NewDeliveryNote.SETTABLEVIEW(HandledInterimSalesHeader);
                        NewDeliveryNote.RUN;
                    END;
                end;
            }
            action(ReOrder)
            {
                ApplicationArea = All;
                Caption = 'Reorder';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    RecInterimSalesHeader: Record "Interim Sales Header";
                    L_HandledInterimSalesHeader: record "Handled Interim Sales Line";
                    DocNo: Code[20];
                    L_InterimSalesHeader: record "Interim Sales Header";
                    InterimSalesLine: record "Interim Sales Line";
                begin
                    CLEAR(DocNo);
                    RecInterimSalesHeader.INIT;
                    //MapHeader(Rec,RecInterimSalesHeader);
                    RecInterimSalesHeader.TransferFields(Rec);
                    RecInterimSalesHeader."Document Type" := Rec."Document Type";
                    RecInterimSalesHeader."Document Type" := Rec."Document Type";
                    IF STRPOS(Rec."No.", '-') = 0 THEN
                        DocNo := Rec."No." + '-01'
                    ELSE
                        DocNo := INCSTR(Rec."No.");//+'-01'
                    RecInterimSalesHeader."No." := DocNo;
                    RecInterimSalesHeader."Package Tracking No." := '';
                    RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::"In Progress";
                    RecInterimSalesHeader."Order Date" := TODAY;
                    RecInterimSalesHeader."Document Date" := TODAY;
                    RecInterimSalesHeader."Channel Order ID" := rec."Channel Order ID" + 'R';
                    RecInterimSalesHeader."External Document No." := CopyStr(rec."External Document No." + 'R', 1, 20);
                    RecInterimSalesHeader.Comments := 'Reorder';
                    CLEAR(RecInterimSalesHeader."Scanned By");
                    CLEAR(RecInterimSalesHeader."Package Tracking No.");
                    CLEAR(RecInterimSalesHeader."Destination Doc No.");
                    CLEAR(RecInterimSalesHeader."Destination Doc Type");
                    CLEAR(RecInterimSalesHeader."Scanned Date");
                    CLEAR(RecInterimSalesHeader."Job Reference");
                    RecInterimSalesHeader.INSERT(TRUE);


                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
                    L_InterimSalesHeader.SETRANGE("No.", DocNo);
                    IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
                        L_HandledInterimSalesHeader.RESET;
                        L_HandledInterimSalesHeader.SETRANGE("Document Type", Rec."Document Type");
                        L_HandledInterimSalesHeader.SETRANGE("Document No", Rec."No.");
                        IF L_HandledInterimSalesHeader.FINDSET THEN
                            REPEAT
                                InterimSalesLine.INIT;
                                InterimSalesLine.TRANSFERFIELDS(L_HandledInterimSalesHeader);
                                InterimSalesLine."Document Type" := L_InterimSalesHeader."Document Type";
                                InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
                                Clear(InterimSalesLine."Destination Doc. Line No");
                                CLEAR(InterimSalesLine."Destination Doc No.");
                                CLEAR(InterimSalesLine."Destination Doc Type");
                                CLEAR(InterimSalesLine."Scanned Date");
                                CLEAR(InterimSalesLine."Dispatch Scan");
                                CLEAR(InterimSalesLine."Trolley No.");
                                CLEAR(InterimSalesLine."Line Status");
                                CLEAR(InterimSalesLine."Pick No");
                                CLEAR(InterimSalesLine."Picking Status");
                                CLEAR(InterimSalesLine."Pick Line No");
                                InterimSalesLine.Status := InterimSalesLine.Status::"In Progress";
                                InterimSalesLine.Reserved := FALSE;
                                InterimSalesLine."Channel Order ID" := L_InterimSalesHeader."Channel Order ID";
                                InterimSalesLine.INSERT(TRUE);
                            UNTIL L_HandledInterimSalesHeader.NEXT = 0;
                        MESSAGE('Order %1 created.', DocNo);
                    END;

                end;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                ApplicationArea = All;
                Image = Cancel;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    L_HISL: Record "Handled Interim Sales Line";
                begin
                    rec.TESTFIELD("Stock Posted", FALSE);
                    rec.Status := rec.Status::Cancelled;
                    CurrPage.UPDATE;

                    //Prathamesh
                    L_HISL.Reset();
                    L_HISL.SetRange("Document No", Rec."No.");
                    if L_HISL.FindSet() then begin
                        repeat
                            L_HISL."Line Status" := L_HISL."Line Status"::Cancelled;
                            L_HISL.Modify(true);
                        until L_HISL.Next() = 0;
                    end;
                    //Prathamesh
                end;
            }
            action("Payment Details")
            {
                Image = Payment;
                ApplicationArea = All;
                Visible = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    // ArchivePayment: Record "Archive Payment Detail";
                    // PageArchivePayment: Page "Archive Payment Detail";
                    ChannelMedia: Record "Channel Media";
                    ChannelOrderId: Text;
                    ChannelOrderId1: Text;
                    Length: Integer;
                begin
                    /* if Rec."Document Type" = Rec."Document Type"::Order then begin
                         ArchivePayment.Reset();
                         ArchivePayment.SetRange("Order No.", Rec."Channel Order ID");
                         if ArchivePayment.FindFirst() then begin
                             Clear(PageArchivePayment);
                             PageArchivePayment.SetTableView(ArchivePayment);
                             PageArchivePayment.Run();
                         end;
                     end;*/
                    CurrPage.SetSelectionFilter(HandledOrder);
                    if HandledOrder.FindSet then
                        repeat
                            ChannelOrderId += HandledOrder."Channel Order ID" + '|' + '';
                        until HandledOrder.Next = 0;

                    Length := STRLEN(ChannelOrderId);
                    ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
                    ChannelMedia.ShowPaymentDetails(ChannelOrderId1, HandledOrder."Channel Order ID", 0, Rec."Trade Partner Code");

                end;
            }
            action("Eliminate Error")
            {
                Caption = 'Eliminate Error';
                RunPageOnRec = false;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    Rec_ChannelItemListing: Record "Channel Item Listing";
                    ChannelItemList: Page "Channel Item Listing";
                    Channelitemlisting: Record "Channel Item Listing";
                //HandleIncomingMessage: Record "Handled Incoming Message";
                begin
                    // CurrPage.SETSELECTIONFILTER(HandleIncomingMessage);
                    //IF HandleIncomingMessage.FINDSET THEN
                    //  REPEAT
                    BEGIN
                        //IF (HandleIncomingMessage.Remarks <> 'Success') AND (HandleIncomingMessage."Feed Submission ID" <> '') THEN BEGIN
                        //HandleIncomingMessage.VALIDATE("Feed Submission ID", '');
                        //HandleIncomingMessage.VALIDATE(Remarks, '');
                        //END;
                        // HandleIncomingMessage.MODIFY;
                    END;
                    //UNTIL HandleIncomingMessage.NEXT = 0;
                end;
            }

            action("Update Shipping")
            {
                Image = Add;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                begin
                    /*    IF Rec."Channel Order ID" <> '' THEN BEGIN



                            //Rec.CALCFIELDS("Dispatch No.");
                            Rec.SETRANGE("Trade Partner Code", 'MAGENTO');
                            Rec.SETFILTER("Channel Order ID", '<>%1', '');
                            //Rec.SETFILTER("Dispatch No.", '<>%1', '');
                            //Rec.SETRANGE("Nav Order No", '');


                            CLEAR(TradePartnerList);
                            TradePartnerList.SETFILTER(Code, '%1', AMAZON);
                            IF TradePartnerList.FINDFIRST THEN 
                              REPEAT                            
                               IF TradePartnerList.OrderFullFilment THEN BEGIN
                                 IF Rec."Trade Partner Code" = TradePartnerList.Code THEN BEGIN
                                   //     AmazonCodeUnit.OrderFullFillmentAmazon(Rec."Trade Partner Code", Rec); //PS
                                 END;
                               END;
                              UNTIL TradePartnerList.NEXT = 0;
                            //End;


                        END;
                    */
                end;
            }
            action("Sales Document")
            {
                Caption = '&Sales Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                begin
                    /*  IF Rec."Dispatch No." <> '' THEN BEGIN
                          SalesShipmentHeader.RESET;
                          SalesShipmentHeader.GET(Rec."Dispatch No.");
                          IF SalesShipmentHeader.FINDSET THEN BEGIN
                              CLEAR(PostedSalesShipment);
                              PostedSalesShipment.SETRECORD(SalesShipmentHeader);
                              PostedSalesShipment.RUN;
                          END;
                      END ELSE BEGIN
                          SalesHeader.RESET;
                          IF SalesHeader.FINDSET THEN BEGIN
                              CLEAR(SalesOrder);
                              SalesOrder.SETRECORD(SalesHeader);
                              SalesOrder.RUN;
                          END;
                      END;*/
                end;
            }
        }
    }

    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesOrder: Page "Sales Order";
        PostedSalesShipment: Page "Posted Sales Shipment";
        // MagentoOrderFulfillment: Codeunit "Magento Integration-Innox"; //Commented By Pavan 20072020
        TradePartnerList: Record "Trade Partner";
        AMAZON: Label 'AMAZON*';
        HandledOrder: Record "Handled Interim Sales Header";

}

