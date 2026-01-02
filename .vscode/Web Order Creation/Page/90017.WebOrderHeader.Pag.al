page 90017 "Web Order Header"
{
    ApplicationArea = All;
    UsageCategory = Administration;
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
                field("No."; rec."No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Channel Order ID"; rec."Channel Order ID")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Sell-to Customer No."; rec."Sell-to Customer No.")
                {
                    Editable = false;
                    Lookup = false;
                    ApplicationArea = all;
                }
                field("ET Access Code"; Rec."ET Access Code")
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
                    Editable = false;
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
                    Editable = false;
                    Caption = 'County';
                    ApplicationArea = all;
                }
                field("Order Date"; rec."Order Date")
                {
                    Editable = false;
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
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                // field("Shipment Date"; Rec."Shipment Date")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reason Message"; Rec."Reason Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(Shipping)
            {
                Editable = false;
                Caption = 'Shipping';
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name"; rec."Ship-to Name")
                {
                    Editable = true;
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

                    trigger OnValidate()
                    var
                        L_Customer: Record Customer;
                        Countries: Record "Country/Region";
                    begin
                        //8862++
                        if Rec."Ship-to Country/Region Code" = 'GB' then begin
                            IF L_Customer.GET(Rec."Sell-to Customer No.") THEN;
                            Rec."Customer Posting Group" := L_Customer."Customer Posting Group";
                        end
                        else begin
                            if Countries.Get(Rec."Ship-to Country/Region Code") then begin
                                if Countries."EU Country/Region Code" <> '' then begin
                                    Rec."Customer Posting Group" := 'EU';
                                end
                                else begin
                                    Rec."Customer Posting Group" := 'FOREIGN';
                                end;
                            end;
                        end;
                        //8862--
                    end;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Phone"; Rec."Ship-to Phone")
                {
                    ApplicationArea = All;
                }
                group("Shipment Method")
                {
                    Editable = false;
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
                    field("Weekend Shipping Agent Code"; Rec."Weekend Shipping Agent Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Weekend Ship Agent Serv Code"; Rec."Weekend Ship Agent Serv Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Departure Time"; Rec."Departure Time")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            part("Web Header Subform"; "Web order Subpage")
            {
                ApplicationArea = all;
                SubPageLink = "Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.");
                Editable = EditPage;
                UpdatePropagation = Both;
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
                        IF InterimSalesHeader.FIND('-') then begin
                            repeat
                                WebOrdMngt.Sigma_OrderValidations(InterimSalesHeader);
                            until InterimSalesHeader.NEXT = 0;
                        end;
                    end;
                end;
            }
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


        // area(processing)
        // {
        //     action("Generate Shipment")
        //     {
        //         Image = Shipment;
        //         Promoted = true;
        //         PromotedCategory = Process;
        //         PromotedOnly = true;
        //         PromotedIsBig = true;
        //         ApplicationArea = All;
        //         Visible = false;
        //         trigger OnAction()
        //         var
        //             L_InterimSalesHeader: Record "Interim Sales Header";
        //             ShippingRule: Record "Shipping Rule";
        //             Rec_ShippingAgent: Record "Shipping Agent";
        //             ShipmentTracking: Record "Shipment Tracking";
        //             ProcessLabel: Codeunit "Auto Generate Shipment";
        //         begin
        //             Clear(L_InterimSalesHeader);
        //             L_InterimSalesHeader := Rec;
        //             CurrPage.SetSelectionFilter(L_InterimSalesHeader);

        //             L_InterimSalesHeader.SetRange("No of Error", 0);
        //             L_InterimSalesHeader.SetRange(ReservedFlag, true);
        //             if L_InterimSalesHeader.FindSet() then begin
        //                 repeat
        //                     ProcessLabel.GenerateLabel(L_InterimSalesHeader);
        //                 until L_InterimSalesHeader.Next() = 0;
        //                 Message('Generate Shipment Process Completed.Please check Error Text in Order if label not generated.');
        //             end;
        //         end;
        //     }
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
        //     action(DeliveryNoteNew)
        //     {
        //         ApplicationArea = Basic, Suite;
        //         Caption = 'Delivery Note';
        //         Image = Print;
        //         Visible = false;

        //         trigger OnAction()
        //         var
        //             L_InterimSalesHeader: Record "Interim Sales Header";
        //             NewDeliveryNote: Report "Web Delivery Note";
        //         begin
        //             InterimSalesHeader.RESET;
        //             InterimSalesHeader.SETRANGE("No.", Rec."No.");
        //             IF InterimSalesHeader.FINDSET THEN BEGIN
        //                 CLEAR(NewDeliveryNote);
        //                 NewDeliveryNote.SETTABLEVIEW(InterimSalesHeader);
        //                 NewDeliveryNote.RUN;
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

    var
        InterimSalesHeader: Record "Interim Sales Header";
        WebOrdMngt: Codeunit "Web Order Mgt";
        SalesHeader: Record "Sales Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        EditPage: Boolean;


    trigger OnOpenPage()
    var
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
    begin
        if Rec."Destination Doc No." <> '' then
            EditPage := false
        else
            EditPage := true;

        CurrPage.Update(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if Rec."Destination Doc No." <> '' then
            Error('%1 Document exists. Cannot delete the order', Rec."Destination Doc No.");
    end;
}