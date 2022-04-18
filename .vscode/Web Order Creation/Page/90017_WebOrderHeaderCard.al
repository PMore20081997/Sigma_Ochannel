page 90017 "Web Order Header"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = true;
    CaptionML = ENU = 'Web Order',
                ENG = 'Web Order';
    SourceTable = "Interim Sales Header";
    PageType = Document;
    RefreshOnActivate = true;
    DeleteAllowed = true;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;
                field("Document Type"; rec."Document Type")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("No."; rec."No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Channel Order ID"; rec."Channel Order ID")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Sell-to Customer No."; rec."Sell-to Customer No.")
                {
                    Editable = false;
                    Lookup = false;
                    ApplicationArea = all;
                }
                field("Web Customer No."; Rec."Web Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bill- to Name"; rec."Bill- to Name")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(Address; rec.Address)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Address 2"; rec."Address 2")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field(City; rec.City)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Post Code"; rec."Post Code")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("<County>"; rec."Bill-to County")
                {
                    Caption = 'County';
                    ApplicationArea = all;
                }
                field("Order Date"; rec."Order Date")
                {
                    Editable = true;
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Order Placed At"; rec."Order Placed At")
                {
                    Caption = 'Order Placed On';
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Document Date"; Rec."Document Date")
                {
                    CaptionML = ENU = 'Document Date', ENG = 'Document Date';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("External Document No."; rec."External Document No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Deal ID"; rec."Deal ID")
                {
                    ApplicationArea = all;
                }
                field("Fullfillment Channel"; rec."Fullfillment Channel")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Order Type"; rec."Order Type")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Order Amount"; rec."Order Amount")
                {
                    Visible = false;
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Order Discount Amount"; Rec."Order Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Gift Message"; rec."Gift Message")
                {
                    //  Editable = EditGiftMsg; ps
                    MultiLine = true;
                    Visible = false;
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Destination Doc Type"; Rec."Destination Doc Type")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Rec; Rec."Destination Doc No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        OpenDestinationDocument(Rec);
                    end;
                }

                group("Shipping Details")
                {
                    Caption = 'Shipping Details';
                    Editable = true;
                    field("Web Shipment Method"; rec."Web Shipment Method")
                    {
                        Editable = false;
                        Enabled = false;
                        Visible = true;
                        ApplicationArea = all;
                    }
                    field("Shipment Date"; rec."Shipment Date")
                    {
                        ApplicationArea = all;
                    }
                    field("Tracking No."; rec."Tracking No.")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field(Remarks; rec.Remarks)
                    {
                        Caption = 'Shipment Remark';
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field("Total Weight"; rec."Total Weight")
                    {
                        ApplicationArea = all;
                    }
                    field("Pickup Date"; rec."Pickup Date")
                    {
                        ApplicationArea = all;
                        Visible = false;
                    }
                    field("Pickup Time"; rec."Pickup Time")
                    {
                        ApplicationArea = all;
                        Visible = false;
                    }
                    field("No. of Items"; rec."No. of Items")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field("No. Of Parcels"; rec."No. Of Parcels")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field("Location Code"; rec."Location Code")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Name"; rec."Ship-to Name")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Buyer Name"; rec."Buyer Name")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Ship-to Address"; rec."Ship-to Address")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to Address 2"; rec."Ship-to Address 2")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to City"; rec."Ship-to City")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to Post Code"; rec."Ship-to Post Code")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to County"; rec."Ship-to County")
                {
                    ApplicationArea = all;
                }
                field("Ship-to Country/Region Code"; rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = all;
                }
                field("Buyer Email"; rec."Buyer Email")
                {
                    Visible = false;
                    ApplicationArea = all;
                    CaptionML = ENU = 'E-mail', ENG = 'E-mail';
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }
                field("Earliest Delivery date"; rec."Earliest Delivery date")
                {
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Earliest Ship Date"; rec."Earliest Ship Date")
                {
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Shipment Method Code"; rec."Shipment Method Code")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Code"; rec."Shipping Agent Code")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Service Code"; rec."Shipping Agent Service Code")
                {
                    ApplicationArea = all;
                }
            }

            part("Web Header Subform"; "Web order Subpage")
            {
                ApplicationArea = all;
                SubPageLink = "Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.");
                Editable = true;
            }

        }
    }


    actions
    {
        area(processing)
        {
            action("Payment Details")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                Image = Payment;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                Visible = false;

                trigger OnAction()
                var
                    ChannelMedia: Record "Channel Media";

                    ChannelOrderId: Text;
                begin
                    /* PartnerIncomingMessage.RESET;
                     PartnerIncomingMessage.SETRANGE("Transaction No.", Rec."Transaction No.");
                     IF PartnerIncomingMessage.FINDSET THEN
                         ChannelMedia.ShowPaymentDetails(ChannelOrderId, PartnerIncomingMessage."Channel Order ID", 0, PartnerIncomingMessage."Trade Partner Code");
                    */
                end;
            }
            action(DeliveryNote)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delivery Note';
                Image = Print;
                Promoted = true;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                PromotedIsBig = true;
                //The property 'PromotedOnly' can only be set if the property 'Promoted' is set to 'true'
                PromotedOnly = true;


                trigger OnAction()
                var
                    //  CourierIntegration: Codeunit "Courier Integration";// Commented By Pavan 
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    SalesHeader: Record 36;
                    //NewDeliveryNote: Report DelivryNote1;
                    NewDeliveryNote: Report DelivryNote2;
                    ShipmentTracking: Record "Shipment Tracking";
                    InStm: InStream;
                    filename: Text;
                    // SMTPMAIL: Record "SMTP Mail Setup";
                    SMTP: Codeunit "Mail Management";
                begin
                    // if Rec."Trade Partner Code" = 'SHOPDIRECT' then begin
                    //     ShipmentTracking.Reset();
                    //     ShipmentTracking.SetRange("Document No.", Rec."No.");
                    //     if ShipmentTracking.FindFirst() then begin
                    //         ShipmentTracking.CalcFields("A6 Label1");
                    //         ShipmentTracking."A6 Label1".CreateInStream(InStm);
                    //         filename := 'DespatchNote' + '-' + Rec."Channel Order ID" + '.pdf';
                    //         DownloadFromStream(InStm, '', '', '', filename);


                    //     end;
                    // end
                    // else
                    //begin
                    InterimSalesHeader.RESET;
                    InterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF InterimSalesHeader.FINDSET THEN BEGIN
                        CLEAR(NewDeliveryNote);
                        NewDeliveryNote.SETTABLEVIEW(InterimSalesHeader);
                        NewDeliveryNote.RUN;
                    END;
                end;

                //  end;
            }
            action(CN22)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'CN22';
                Ellipsis = true;
                Image = Print;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                //The property 'PromotedOnly' can only be set if the property 'Promoted' is set to 'true'
                //PromotedOnly = true;
                Visible = false;

                trigger OnAction()
                begin

                    /*
                     IF CN22.GetCountryCodeIntegration(Rec) THEN BEGIN
                      CLEAR(CN22);
                      InterimSalesHeader.RESET;
                      InterimSalesHeader.SETRANGE("No.","No.");
                      CN22.SETTABLEVIEW(InterimSalesHeader);
                      CN22.RUNMODAL;
                      END ELSE
                      MESSAGE('Currnet pick is not other than EU.')
                      */

                end;
            }

            action("Authorize price")
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    WebOrdMngt.AuthoriseWebOrderPrice(Rec);
                end;
            }
            action("Remove MultiLine Order Ref. ShopDirect")
            {
                Caption = 'Remove MultiLine Order Ref. ShopDirect';
                Ellipsis = true;
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;
                trigger OnAction()
                begin
                    RemoveMLOrderRef();
                end;
            }
            action(ReOrder)
            {
                ApplicationArea = Warehouse;
                Caption = 'Re-Order';
                Image = ReturnOrder;
                Promoted = true;
                PromotedCategory = Process;
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
                    UpdateDispatchedOnWebOrder: Report "Update Dispatched On Web Order";//Prathamesh
                begin
                    WebOrdMngt.CancelOrder(Rec);

                    //Prathamesh
                    L_InterimSalesLine.Reset();
                    L_InterimSalesLine.SetRange("Document No", Rec."No.");
                    if L_InterimSalesLine.FindSet() then begin
                        repeat
                            L_InterimSalesLine."Line Status" := L_InterimSalesLine."Line Status"::Cancelled;
                            L_InterimSalesLine.Modify(true);
                        until L_InterimSalesLine.Next() = 0;
                    end;
                    //Prathamesh
                end;
            }
            action("Print Lable")
            {
                Image = Print;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(Rec);

                    REPORT.RUN(50057, TRUE, FALSE, Rec);
                    CurrPage.UPDATE(TRUE);
                end;
            }
            action(ShowCustomer)
            {
                ApplicationArea = All;
                Caption = 'Show Customer';
                Image = Customer;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page 21;
                RunPageLink = "No." = FIELD("Sell-to Customer No.");
            }
        }
    }

    var
        //  Delivery_Note: Report "80010"; Ps Not found 
        InterimSalesHeader: Record "Interim Sales Header";
        //   CN22: Report "90105"; Ps Not found 
        //    Delivery_Note2: Report "80011"; Ps not found 

        WebOrdMngt: Codeunit "Web Order Mgt";
        SalesHeader: Record "Sales Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";


    local procedure GetLastTranastionNo(): Integer
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
    end;

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

    local procedure RemoveMLOrderRef()
    var
        _InterimSalesHeader: Record "Interim Sales Header";
    begin
        _InterimSalesHeader.GET(Rec."Document Type", Rec."No.");
        IF (_InterimSalesHeader."MultiLine Order No." <> '') THEN BEGIN
            _InterimSalesHeader."Old MultiLine Order No." := _InterimSalesHeader."MultiLine Order No.";
            CLEAR(_InterimSalesHeader."MultiLine Order No.");
            _InterimSalesHeader.MODIFY();
            CurrPage.UPDATE(FALSE);
        END;
    end;
}

