page 90019 "Handle Web Order"
{
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    SourceTable = "Handled Interim Sales Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                //Editable = false;
                field("Document No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                //8862++
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                //8862--
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Deal ID"; Rec."Deal ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Fullfillment Channel"; Rec."Fullfillment Channel")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Order Discount Amount"; Rec."Order Discount Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Discount Amount';
                    Editable = false;
                }
                field("Gift Order Amount"; Rec."Gift Order Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Order Amount field.';
                    Editable = false;
                }


                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Order Status"; Rec."Order Status")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    ToolTip = 'Specifies the value of the Gift Card field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                //Paarth D Dave - 8197-4 - Adding Boolean for Assembly Order ---- End
                field("No. Of Parcels"; Rec."No. Of Parcels")
                {
                    ApplicationArea = All;
                }
                group("Shipping Details")
                {
                    Editable = false;
                    Caption = 'Shipping Details';

                    field("Web Shipment Method"; Rec."Web Shipment Method")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipment Method Code"; Rec."Shipment Method Code")
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
                    //US-8196++
                    field("Child Client ID"; Rec."Child Client ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Child Client Name"; Rec."Child Client Name")
                    {
                        ApplicationArea = All;
                    }
                    //US-8196--
                    field("Shipment Date"; Rec."Shipment Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Tracking No."; Rec."Tracking No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Weight"; Rec."Total Weight")
                    {
                        ApplicationArea = All;
                    }
                    field("No. of Items"; Rec."No. of Items")
                    {
                        ApplicationArea = All;
                        Caption = 'No. of Item lines';
                    }
                    field("Total No. of Items"; Rec."Total No. of Items")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Shipping)
            {
                Editable = false;
                Caption = 'Shipping';
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Buyer Name"; Rec."Buyer Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }
                field("Buyer Email"; Rec."Buyer Email")
                {
                    ApplicationArea = All;
                }
                field("Earliest Delivery date"; Rec."Earliest Delivery date")
                {
                    ApplicationArea = All;
                }
                field("Earliest Ship Date"; Rec."Earliest Ship Date")
                {
                    ApplicationArea = All;
                }
            }
            part("HanHandle Web Order Subform"; "Handled Web Order Subpage")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No" = FIELD("No.");
            }
        }
    }

    actions
    {

        area(Processing)
        {
            action("Generate Shipment")
            {
                Image = Shipment;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    L_InterimHeader: Record "Handled Interim Sales Header";
                    ShippingRule: Record "Shipping Rule";
                    Rec_ShippingAgent: Record "Shipping Agent";
                    ShipmentTracking: Record "Shipment Tracking";
                    ProcessLabel: Codeunit "Generate Shipment";
                begin
                    L_InterimHeader.Reset();
                    L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
                    L_InterimHeader.SetRange("No.", Rec."No.");
                    L_InterimHeader.SetRange("No of Error", 0);
                    if L_InterimHeader.FindFirst() then begin
                        ProcessLabel.GenerateLabel(L_InterimHeader);
                        Message('Generate Shipment Process Completed.Please check Error Text in Order if label not generated.');
                    end;
                end;
            }
            action(ReOrder)
            {
                ApplicationArea = All;
                Caption = 'Reorder';
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
        }
        area(Navigation)
        {
            action("Direct Printing Label")
            {
                ApplicationArea = All;
                Image = Print;
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
                Visible = false;
                ApplicationArea = All;
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
        SalesHeader: Record 36;
        SalesShipmentHeader: Record 110;
        SalesOrder: Page 42;
        PostedSalesShipment: Page 130;

    local procedure MapHeader(var RecInterimSalesHeader: Record "Interim Sales Header");
    begin
        /*RecInterimSalesHeader.VALIDATE("Sell-to Customer No.", HandledIncomingMessage."Sell-to Customer No.");
        RecInterimSalesHeader.VALIDATE("Web Customer No.", HandledIncomingMessage."Web Customer No.");
        RecInterimSalesHeader.VALIDATE(Address, HandledIncomingMessage.Address);
        RecInterimSalesHeader.VALIDATE("Address 2", HandledIncomingMessage."Address 2");
        RecInterimSalesHeader.VALIDATE(City, HandledIncomingMessage.City);
        RecInterimSalesHeader.VALIDATE("Post Code", HandledIncomingMessage."Post Code");
        RecInterimSalesHeader.VALIDATE("Order Date", HandledIncomingMessage."Order Date");
        RecInterimSalesHeader.VALIDATE("Bill-to Customer No.", HandledIncomingMessage."Bill-to Customer No.");
        RecInterimSalesHeader.VALIDATE("Ship-to Name", HandledIncomingMessage."Ship-to Name");
        RecInterimSalesHeader.VALIDATE("Ship-to Address", HandledIncomingMessage."Ship-to Address");
        RecInterimSalesHeader.VALIDATE("Ship-to Address 2", HandledIncomingMessage."Ship-to Address 2");
        RecInterimSalesHeader.VALIDATE("Ship-to City", HandledIncomingMessage."Ship-to City");
        RecInterimSalesHeader.VALIDATE("Ship-to Post Code", HandledIncomingMessage."Ship-to Post Code");
        RecInterimSalesHeader.VALIDATE("Ship-to County", HandledIncomingMessage."Ship-to County");
        RecInterimSalesHeader.VALIDATE("Ship-to Country", HandledIncomingMessage."Ship-to Country");
        RecInterimSalesHeader.VALIDATE("Document Date", HandledIncomingMessage."Document Date");
        RecInterimSalesHeader.VALIDATE("External Document No.", HandledIncomingMessage."External Document No.");
        RecInterimSalesHeader.VALIDATE("Buyer Email", HandledIncomingMessage."Buyer Email");
        RecInterimSalesHeader.VALIDATE("Buyer Name", HandledIncomingMessage."Buyer Name");
        RecInterimSalesHeader.VALIDATE("Earliest Delivery date", HandledIncomingMessage."Earliest Delivery date");
        RecInterimSalesHeader.VALIDATE("Earliest Ship Date", HandledIncomingMessage."Earliest Ship Date");
        RecInterimSalesHeader.VALIDATE("Fullfillment Channel", HandledIncomingMessage."Fullfillment Channel");
        RecInterimSalesHeader.VALIDATE("Order Amount", HandledIncomingMessage."Order Amount");
        RecInterimSalesHeader.VALIDATE("Channel Order ID", HandledIncomingMessage."Channel Order ID");        
        RecInterimSalesHeader.VALIDATE("Shipment Method Code", HandledIncomingMessage."Shipment Method Code");
        RecInterimSalesHeader.VALIDATE("Currency Code", HandledIncomingMessage."Currency Code");
        //   RecInterimSalesHeader.VALIDATE("Ship-tp Phone No.",HandledIncomingMessage."Ship-tp Phone No.");
        RecInterimSalesHeader.VALIDATE("Gift Message", HandledIncomingMessage."Gift Message");
        RecInterimSalesHeader.VALIDATE("Order Placed At", HandledIncomingMessage."Order Placed At");
        RecInterimSalesHeader.VALIDATE("Web Shipment Method", HandledIncomingMessage."Web Shipment Method");
        RecInterimSalesHeader.VALIDATE("Bill- to Name", HandledIncomingMessage."Bill- to Name");
        RecInterimSalesHeader.VALIDATE("Web Shipping Agent", HandledIncomingMessage."Web Shipping Agent");
        RecInterimSalesHeader.VALIDATE("Bill-to CompanyName", HandledIncomingMessage."Bill-to CompanyName");
        RecInterimSalesHeader.VALIDATE("Ship-to CompanyName", HandledIncomingMessage."Ship-to CompanyName");
        RecInterimSalesHeader.VALIDATE("Deal ID", HandledIncomingMessage."Deal ID");
        RecInterimSalesHeader.VALIDATE("Bill-to County", HandledIncomingMessage."Bill-to County");
        RecInterimSalesHeader.VALIDATE(IsLLOrder, HandledIncomingMessage.IsLLOrder);
        RecInterimSalesHeader.VALIDATE("Trade Partner Code", HandledIncomingMessage."Trade Partner Code");
        RecInterimSalesHeader.VALIDATE("Shipping Agent Code", HandledIncomingMessage."Shipping Agent Code");
        RecInterimSalesHeader.VALIDATE("Shipping Agent Service Code", HandledIncomingMessage."Shipping Agent Service Code");
        RecInterimSalesHeader.VALIDATE("Shipment Date", HandledIncomingMessage."Shipment Date");
        RecInterimSalesHeader.VALIDATE("Ship-to Country/Region Code", HandledIncomingMessage."Ship-to Country/Region Code");
        RecInterimSalesHeader.VALIDATE("Shipping Time", HandledIncomingMessage."Shipping Time");
        RecInterimSalesHeader.VALIDATE("Requested Delivery Date", HandledIncomingMessage."Requested Delivery Date");
        RecInterimSalesHeader.VALIDATE("Currency Factor", HandledIncomingMessage."Currency Factor");
        RecInterimSalesHeader.VALIDATE(Comments, HandledIncomingMessage.Comments);
        RecInterimSalesHeader.VALIDATE("Location Code", HandledIncomingMessage."Location Code");
        RecInterimSalesHeader.VALIDATE("Pickup Name", HandledIncomingMessage."Pickup Name");
        RecInterimSalesHeader.VALIDATE("Pickup Address", HandledIncomingMessage."Pickup Address");
        RecInterimSalesHeader.VALIDATE("Pickup Address 2", HandledIncomingMessage."Pickup Address 2");
        RecInterimSalesHeader.VALIDATE("Pickup City", HandledIncomingMessage."Pickup City");
        RecInterimSalesHeader.VALIDATE("Pickup Post Code", HandledIncomingMessage."Pickup Post Code");
        RecInterimSalesHeader.VALIDATE("Pickup County", HandledIncomingMessage."Pickup County");
        RecInterimSalesHeader.VALIDATE("Pickup Country/Region Code", HandledIncomingMessage."Pickup Country/Region Code");
        RecInterimSalesHeader.VALIDATE("Total Weight", HandledIncomingMessage."Total Weight");
        RecInterimSalesHeader.VALIDATE("Pickup Date", HandledIncomingMessage."Pickup Date");
        RecInterimSalesHeader.VALIDATE("Email (Location)", HandledIncomingMessage."Email (Location)");
        RecInterimSalesHeader.VALIDATE("No. Of Parcels", HandledIncomingMessage."No. Of Parcels");
        RecInterimSalesHeader.VALIDATE("Package Tracking No.", HandledIncomingMessage."Package Tracking No.");
        RecInterimSalesHeader.VALIDATE("Job Reference", HandledIncomingMessage."Job Reference");
        RecInterimSalesHeader.VALIDATE("Pickup Time", HandledIncomingMessage."Pickup Time");
        RecInterimSalesHeader.VALIDATE("Cancelled By", HandledIncomingMessage."Cancelled By");
        RecInterimSalesHeader.VALIDATE("Cancelled On", HandledIncomingMessage."Cancelled On");
        RecInterimSalesHeader.VALIDATE("Gift Wrap By", HandledIncomingMessage."Gift Wrap By");
        RecInterimSalesHeader.VALIDATE("Gift Wrap date", HandledIncomingMessage."Gift Wrap date");
        RecInterimSalesHeader.VALIDATE("Order Created On", HandledIncomingMessage."Order Created On");
        RecInterimSalesHeader.VALIDATE("Ship-to Phone", HandledIncomingMessage."Ship-to Phone");
        RecInterimSalesHeader.VALIDATE("Ship-to Email", HandledIncomingMessage."Ship-to Email");
        RecInterimSalesHeader.VALIDATE("No. of Items", HandledIncomingMessage."No. of Items");
        RecInterimSalesHeader.VALIDATE("Deal ID", HandledIncomingMessage."Deal ID");
        RecInterimSalesHeader.VALIDATE("Ship-to Country/Region Code", HandledIncomingMessage."Ship-to Country/Region Code");*/
    end;

    var
        HandledOrder: Record "Handled Interim Sales Header";
}

