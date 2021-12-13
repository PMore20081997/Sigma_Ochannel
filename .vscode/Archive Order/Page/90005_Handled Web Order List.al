page 90005 "Handled Web Order List"
{
    // version INTE1.0

    CardPageID = "Handle Web Order";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    //ModifyAllowed = false;
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

            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Navigate)
            {
                Caption = 'Navigate';
                Image = SelectLineToApply;
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
            action("Payment Details")
            {
                Image = Payment;
                ApplicationArea = All;
                Visible = true;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ArchivePayment: Record "Archive Payment Detail";
                    PageArchivePayment: Page "Archive Payment Detail";
                begin
                    if Rec."Document Type" = Rec."Document Type"::Order then begin
                        ArchivePayment.Reset();
                        ArchivePayment.SetRange("Order No.", Rec."Channel Order ID");
                        if ArchivePayment.FindFirst() then begin
                            Clear(PageArchivePayment);
                            PageArchivePayment.SetTableView(ArchivePayment);
                            PageArchivePayment.Run();
                        end;
                    end;

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
            action(Cancel)
            {
                Caption = 'Cancel';
                ApplicationArea = All;
                Image = Cancel;
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

}

