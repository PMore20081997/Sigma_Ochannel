pageextension 90082 "Sales Order Card Ext" extends "Sales Order"
{
    layout
    {
        modify("Customer Posting Group")
        {
            Editable = true;
        }
        modify("VAT Reporting Date")
        {
            Editable = false;
        }
        modify("Posting Date")
        {
            Editable = false;
        }
        modify("Order Date")
        {
            Editable = false;
        }
        modify("Document Date")
        {
            Editable = false;
        }
    }

    actions
    {
        addafter(Release)
        {
            action(UpdateDate)
            {
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    ShipmentTracking: Record "Shipment Tracking";
                    SalesShipHeader: Record "Sales Shipment Header";
                begin
                    ShipmentTracking.Reset();
                    ShipmentTracking.SetRange("Document Type", ShipmentTracking."Document Type"::Order);
                    ShipmentTracking.SetRange("Entry Created", 0D);
                    if ShipmentTracking.FindSet() then begin
                        repeat
                            SalesShipHeader.Reset();
                            SalesShipHeader.SetRange("Order No.", ShipmentTracking."Document No.");
                            if SalesShipHeader.FindFirst() then begin
                                ShipmentTracking."Entry Created" := SalesShipHeader."Posting Date";
                                ShipmentTracking.Modify();
                            end;
                        until ShipmentTracking.Next() = 0;
                        Message('Completed');
                    end;
                end;

            }
            action(ArchiveShipment)
            {
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    ShipmentTracking: Record "Shipment Tracking";
                    ShipmentTracking2: Record "Shipment Tracking";
                    ArchiveShipmentTracking: Record "Archive Shipment Tracking";
                begin
                    ShipmentTracking.Reset();
                    ShipmentTracking.SetRange("Document Type", ShipmentTracking."Document Type"::Order);
                    ShipmentTracking.SetFilter("Entry Created", '<>%1', 0D);
                    ShipmentTracking.SetCurrentKey("Entry Created");
                    ShipmentTracking.SetAscending("Entry Created", true);
                    if ShipmentTracking.FindFirst() then begin
                        ShipmentTracking2.Reset();
                        ShipmentTracking2.SetRange("Document Type", ShipmentTracking."Document Type");
                        ShipmentTracking2.SetFilter("Entry Created", '%1..%2', ShipmentTracking."Entry Created", CalcDate('<2W>', ShipmentTracking."Entry Created"));
                        if ShipmentTracking2.FindSet() then begin
                            repeat
                                ArchiveShipmentTracking.Init();
                                ArchiveShipmentTracking."Entry No." := ShipmentTracking2."Entry No.";
                                ArchiveShipmentTracking."Document Type" := ShipmentTracking2."Document Type";
                                ArchiveShipmentTracking."Document No." := ShipmentTracking2."Document No.";
                                ArchiveShipmentTracking."Shipping Agent Code" := ShipmentTracking2."Shipping Agent Code";
                                ArchiveShipmentTracking."Shipping Agent Service Code" := ShipmentTracking2."Shipping Agent Service Code";
                                ArchiveShipmentTracking."Agent Shipment No." := ShipmentTracking2."Agent Shipment No.";
                                ArchiveShipmentTracking."Tracking No." := ShipmentTracking2."Tracking No.";
                                ArchiveShipmentTracking.Weight := ShipmentTracking2.Weight;
                                ArchiveShipmentTracking."Shipment Label Handled" := ShipmentTracking2."Shipment Label Handled";
                                ArchiveShipmentTracking."Entry Created" := ShipmentTracking2."Entry Created";
                                ShipmentTracking2.CalcFields(Label, "A6 Label1");
                                ArchiveShipmentTracking.Label := ShipmentTracking2.Label;
                                ArchiveShipmentTracking."A6 Label1" := ShipmentTracking2."A6 Label1";
                                ArchiveShipmentTracking.Insert(true);
                                ShipmentTracking2.Delete();
                            until ShipmentTracking2.Next() = 0;
                        end;

                    end;
                end;
            }
            action("Shipment Tracking")
            {
                Image = Track;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_ShipTrack: Record "Shipment Tracking";
                    L_ShipPage: Page "Shipment Tracking";
                begin
                    Clear(L_ShipPage);
                    L_ShipTrack.Reset();
                    L_ShipTrack.SetRange("Document No.", Rec."No.");
                    if L_ShipTrack.FindFirst() then begin
                        L_ShipPage.SetTableView(L_ShipTrack);
                        L_ShipPage.Run();
                    end;
                end;
            }
            action("Web Order")
            {
                ApplicationArea = All;
                Image = Web;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    InterimSalesHeader: Record "Interim Sales Header";
                    HandledInterimSalesHeader: Record "Handled Interim Sales Header";
                    P_WebOrder: Page "Web Order Header";
                    P_HnadledWebOrder: Page "Handle Web Order";
                    SalesLine: Record "Sales Line";
                begin
                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetRange("Document No.", Rec."No.");
                    if SalesLine.FindFirst() then begin
                        InterimSalesHeader.Reset();
                        InterimSalesHeader.SetRange("Document Type", InterimSalesHeader."Document Type"::Order);
                        InterimSalesHeader.SetRange("Channel Order ID", SalesLine."Channel Order ID");
                        if InterimSalesHeader.FindFirst() then begin
                            Clear(P_WebOrder);
                            P_WebOrder.SetRecord(InterimSalesHeader);
                            P_WebOrder.Run();
                        end
                        else begin
                            HandledInterimSalesHeader.Reset();
                            HandledInterimSalesHeader.SetRange("Channel Order ID", SalesLine."Channel Order ID");
                            if HandledInterimSalesHeader.FindFirst() then begin
                                Clear(P_HnadledWebOrder);
                                P_HnadledWebOrder.SetRecord(HandledInterimSalesHeader);
                                P_HnadledWebOrder.Run();
                            end;
                        end;
                    end;
                end;
            }
        }

        modify(Release)
        {
            trigger OnAfterAction()
            var
                HandledInterimSalesHeader: Record "Handled Interim Sales Header";
            begin
                HandledInterimSalesHeader.Reset();
                HandledInterimSalesHeader.SetRange("No.", Rec."No.");
                if HandledInterimSalesHeader.FindFirst() then begin
                    if HandledInterimSalesHeader.status = HandledInterimSalesHeader.status::Processing then
                        UpdateHandledWebOrder(Rec);
                end;
            end;
        }
    }

    local procedure UpdateHandledWebOrder(Rec: Record "Sales Header")
    var
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        SalesLine: Record "Sales Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateHandledWebOrder(IsHandled);
        if IsHandled then
            exit;

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", Rec."No.");
        if SalesLine.FindSet() then begin
            repeat
                UpdateHandledInterimSalesLine(SalesLine);
            until SalesLine.Next() = 0;
            UpdateHandledInterimSalesHeader(SalesLine);
        end;
        OnAfterUpdateHandledWebOrder();
    end;

    local procedure UpdateHandledInterimSalesLine(var SalesLine: Record "Sales Line")
    var
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateHandledInterimSalesLine(SalesLine, IsHandled);
        if IsHandled then
            exit;

        HandledInterimSalesLine.Reset();
        HandledInterimSalesLine.SetRange("Document Type", HandledInterimSalesLine."Document Type"::Order);
        HandledInterimSalesLine.SetRange("Document No", SalesLine."Document No.");
        HandledInterimSalesLine.SetRange("Line No.", SalesLine."Line No.");
        if HandledInterimSalesLine.FindFirst() then
            ModifyAndInsertHandledInetrimSalesLine(HandledInterimSalesLine, SalesLine, false)
        else
            ModifyAndInsertHandledInetrimSalesLine(HandledInterimSalesLine, SalesLine, True);

        OnAfterUpdateHandledInterimSalesLine(SalesLine);
    end;

    local procedure ModifyAndInsertHandledInetrimSalesLine(Var HandledInterimSalesLine: Record "Handled Interim Sales Line"; var SalesLine: Record "Sales Line"; arg: Boolean)
    var
        ChannelItemListing: Record "Channel Item Listing";
    begin
        if arg then begin
            HandledInterimSalesLine.Init();
            HandledInterimSalesLine."Document Type" := SalesLine."Document Type"::Order;
            HandledInterimSalesLine."Document No" := SalesLine."Document No.";
            HandledInterimSalesLine."Line No." := SalesLine."Line No.";
        end;
        HandledInterimSalesLine.Type := SalesLine.Type;
        HandledInterimSalesLine."No." := SalesLine."No.";
        HandledInterimSalesLine.Description := SalesLine.Description;
        if HandledInterimSalesLine.Type = HandledInterimSalesLine.Type::Item then
            HandledInterimSalesLine."Channel SKU" := GetChannelSKU(SalesLine."No.");
        HandledInterimSalesLine."Location Code" := SalesLine."Location Code";
        HandledInterimSalesLine.Quantity := SalesLine.Quantity;
        HandledInterimSalesLine."Unit Price" := SalesLine."Unit Price";
        HandledInterimSalesLine."Channel Price" := SalesLine."Unit Price";
        HandledInterimSalesLine.Amount := SalesLine.Amount;
        HandledInterimSalesLine."Amount Including VAT" := SalesLine."Amount Including VAT";
        HandledInterimSalesLine."VAT amount" := SalesLine."Amount Including VAT" - SalesLine.Amount;
        HandledInterimSalesLine.Discount := SalesLine."Line Discount Amount";
        HandledInterimSalesLine."Discount %" := SalesLine."Line Discount %";
        HandledInterimSalesLine."VAT Bus. Posting Group" := SalesLine."VAT Bus. Posting Group";
        HandledInterimSalesLine."VAT Prod. Posting Group" := SalesLine."VAT Prod. Posting Group";
        HandledInterimSalesLine."Channel Order ID" := SalesLine."Channel Order ID";
        HandledInterimSalesLine."Trade Partner Code" := SalesLine."Channel Code";
        HandledInterimSalesLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
        HandledInterimSalesLine.Weight := SalesLine."Net Weight";
        if arg then
            HandledInterimSalesLine.Insert(true)
        else
            HandledInterimSalesLine.Modify(true);
    end;

    local procedure GetChannelSKU(No: Code[20]): Text[50]
    var
        ChannelItemListing: Record "Channel Item Listing";
    begin
        ChannelItemListing.Reset();
        ChannelItemListing.SetRange("Item No.", No);
        if ChannelItemListing.FindFirst() then
            exit(ChannelItemListing."Channel SKU");
    end;


    procedure UpdateHandledInterimSalesHeader(SalesLine: Record "Sales Line")
    var
        HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        OrderAmount: Decimal;
        OrderDiscountAmount: Decimal;
        TotalWeight: Decimal;
        TotalNoOfItem: Integer;
        NoOfItems: Integer;
        GiftOrderAmount: Decimal;
        L_SalesHeader: Record "Sales Header";
    begin
        Clear(OrderAmount);
        Clear(OrderDiscountAmount);
        Clear(TotalWeight);
        Clear(TotalNoOfItem);
        Clear(NoOfItems);
        Clear(GiftOrderAmount);
        HandledInterimSalesHeader.Reset();
        HandledInterimSalesHeader.SetRange("No.", SalesLine."Document No.");
        if HandledInterimSalesHeader.FindFirst() then begin
            HandledInterimSalesLine.Reset();
            HandledInterimSalesLine.SetRange("Document No", HandledInterimSalesHeader."No.");
            if HandledInterimSalesLine.FindSet() then
                repeat
                    if HandledInterimSalesLine."Amount Including VAT" > 0 then
                        OrderAmount += HandledInterimSalesLine."Amount Including VAT";
                    OrderDiscountAmount += HandledInterimSalesLine.Discount;
                    TotalWeight += HandledInterimSalesLine.Weight * HandledInterimSalesLine.Quantity;

                    if HandledInterimSalesLine.Type = HandledInterimSalesLine.Type::Item then begin
                        TotalNoOfItem += HandledInterimSalesLine.Quantity;
                        NoOfItems += 1;
                    end;
                    if (HandledInterimSalesLine.Type = HandledInterimSalesLine.Type::"G/L Account") And (HandledInterimSalesLine."Gift Card" = true) then begin
                        GiftOrderAmount += HandledInterimSalesLine."Amount Including VAT";
                    end;
                // TotalNoOfItem += 1;
                until HandledInterimSalesLine.Next() = 0;

            HandledInterimSalesHeader."Order Amount" := OrderAmount;

            L_SalesHeader.Reset();
            L_SalesHeader.SetRange("No.", SalesLine."Document No.");
            if L_SalesHeader.FindFirst() then begin
                L_SalesHeader.CalcFields("Invoice Discount Amount");
            end;

            HandledInterimSalesHeader."Order Discount Amount" := OrderDiscountAmount + L_SalesHeader."Invoice Discount Amount";
            HandledInterimSalesHeader."Total No. of Items" := TotalNoOfItem;
            HandledInterimSalesHeader."No. of Items" := NoOfItems;
            HandledInterimSalesHeader."Total Weight" := TotalWeight;
            HandledInterimSalesHeader."Gift Order Amount" := GiftOrderAmount;
            HandledInterimSalesHeader.Modify(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateHandledWebOrder(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateHandledWebOrder()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateHandledInterimSalesLine(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateHandledInterimSalesLine(var SalesLine: Record "Sales Line")
    begin
    end;
}