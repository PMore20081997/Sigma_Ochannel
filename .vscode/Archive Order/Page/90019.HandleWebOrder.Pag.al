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
                Editable = false;
                field("Document No."; Rec."No.")
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
                field("ET Access Code"; Rec."ET Access Code")
                {
                    Editable = false;
                    ApplicationArea = all;
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
                field("Ship-to Name"; Rec."Ship-to Name")
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
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
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
                    field("Weekend Ship Agent Serv Code"; Rec."Weekend Ship Agent Serv Code")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            part("HanHandle Web Order Subform"; "Handled Web Order Subpage")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.");
            }
        }
    }

    actions
    {
        area(Processing)
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
                    DocNo: Code[250];
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

            //     action("Generate Shipment")
            //     {
            //         Image = Shipment;
            //         ApplicationArea = All;
            //         Promoted = true;
            //         PromotedCategory = Process;
            //         PromotedIsBig = true;
            //         trigger OnAction()
            //         var
            //             L_InterimHeader: Record "Handled Interim Sales Header";
            //             ShippingRule: Record "Shipping Rule";
            //             Rec_ShippingAgent: Record "Shipping Agent";
            //             ShipmentTracking: Record "Shipment Tracking";
            //             ProcessLabel: Codeunit "Generate Shipment";
            //         begin
            //             L_InterimHeader.Reset();
            //             L_InterimHeader.SetRange("Document Type", L_InterimHeader."Document Type"::Order);
            //             L_InterimHeader.SetRange("No.", Rec."No.");
            //             L_InterimHeader.SetRange("No of Error", 0);
            //             if L_InterimHeader.FindFirst() then begin
            //                 ProcessLabel.GenerateLabel(L_InterimHeader);
            //                 Message('Generate Shipment Process Completed.Please check Error Text in Order if label not generated.');
            //             end;
            //         end;
            //     }

            //     action("Payment Details")
            //     {
            //         Image = Payment;
            //         ApplicationArea = All;
            //         trigger OnAction()
            //         var
            //             ChannelMedia: Record "Channel Media";
            //             ChannelOrderId: Text;
            //             ChannelOrderId1: Text;
            //             Length: Integer;
            //         begin
            //             CurrPage.SetSelectionFilter(HandledOrder);
            //             if HandledOrder.FindSet then
            //                 repeat
            //                     ChannelOrderId += HandledOrder."Channel Order ID" + '|' + '';
            //                 until HandledOrder.Next = 0;

            //             Length := STRLEN(ChannelOrderId);
            //             ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
            //             ChannelMedia.ShowPaymentDetails(ChannelOrderId1, HandledOrder."Channel Order ID", 0, Rec."Trade Partner Code");
            //         end;
            //     }
            // }

            // area(Navigation)
            // {
            //     action("Direct Printing Label")
            //     {
            //         ApplicationArea = All;
            //         Image = Print;
            //         Caption = 'Label Print';

            //         trigger OnAction()
            //         var
            //             HandledInterimSalesHeader: Record "Handled Interim Sales Header";
            //             WebMgt: Codeunit "Web Order Mgt";
            //             ShippingAgent: Record "Shipping Agent";
            //             L_ShipmentTracking: Record "Shipment Tracking";
            //         begin
            //             HandledInterimSalesHeader.RESET;
            //             HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
            //             IF HandledInterimSalesHeader.FindFirst() THEN BEGIN
            //                 ShippingAgent.Reset();
            //                 ShippingAgent.SetRange(Code, HandledInterimSalesHeader."Shipping Agent Code");
            //                 if ShippingAgent.FindFirst() then begin
            //                     if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
            //                         //RAW Printing Option Means it is For DPD EPL Label and PDF labels
            //                         WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
            //                     end;
            //                     if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
            //                         WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
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
            //         trigger OnAction()
            //         var
            //             HandledInterimSalesHeader: Record "Handled Interim Sales Header";
            //             NewDeliveryNote: Report "Handled Delivery Note";
            //         begin
            //             HandledInterimSalesHeader.RESET;
            //             HandledInterimSalesHeader.SETRANGE("No.", Rec."No.");
            //             IF HandledInterimSalesHeader.FINDSET THEN BEGIN
            //                 CLEAR(NewDeliveryNote);
            //                 NewDeliveryNote.SETTABLEVIEW(HandledInterimSalesHeader);
            //                 NewDeliveryNote.RUN;
            //             END;
            //         end;
            //     }

            //     action("Sales Document")
            //     {
            //         Caption = '&Sales Document';
            //         Image = Document;
            //         Visible = false;
            //         ApplicationArea = All;
            //         trigger OnAction()
            //         begin
            //             /*  IF Rec."Dispatch No." <> '' THEN BEGIN
            //                   SalesShipmentHeader.RESET;
            //                   SalesShipmentHeader.GET(Rec."Dispatch No.");
            //                   IF SalesShipmentHeader.FINDSET THEN BEGIN
            //                       CLEAR(PostedSalesShipment);
            //                       PostedSalesShipment.SETRECORD(SalesShipmentHeader);
            //                       PostedSalesShipment.RUN;
            //                   END;
            //               END ELSE BEGIN
            //                   SalesHeader.RESET;
            //                   IF SalesHeader.FINDSET THEN BEGIN
            //                       CLEAR(SalesOrder);
            //                       SalesOrder.SETRECORD(SalesHeader);
            //                       SalesOrder.RUN;
            //                   END;
            //               END;*/
            //         end;
            //     }
        }
    }

    var
        SalesHeader: Record 36;
        SalesShipmentHeader: Record 110;
        SalesOrder: Page 42;
        PostedSalesShipment: Page 130;
        HandledOrder: Record "Handled Interim Sales Header";
}