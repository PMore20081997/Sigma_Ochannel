pageextension 90082 "Sales Order Card Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("_Web Order"; reC."Web Order")
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Web Order';
            }
        }
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
            action("Update Variant On Lines")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    UdateVariantonSO: Codeunit "Udate Variant on SO";
                begin
                    //Check Order Type++
                    Rec.TestField("Web Order", true);

                    //Check Status++
                    Rec.TestField(Status, Rec.Status::Open);

                    //Update Variant Code++
                    UdateVariantonSO.UpdateVariantOnSalesOrder(Rec);
                end;
            }

            action("Web Order")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Image = Navigate;
                Visible = false;

                trigger OnAction()
                var
                    L_WebOrderList: Page "Web Order List";
                    L_InterimSalesHeader: Record "Interim Sales Header";

                    HandledWebOrderList: Page "Handled Web Order List";
                    L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
                begin
                    Clear(L_WebOrderList);
                    L_InterimSalesHeader.Reset();
                    L_InterimSalesHeader.SetFilter("No.", SetWeborderFilter(Rec."No."));
                    if L_InterimSalesHeader.FindSet() then begin
                        L_WebOrderList.SetTableView(L_InterimSalesHeader);
                        L_WebOrderList.Run();
                    end else begin
                        Clear(HandledWebOrderList);
                        L_HandledInterimSalesHeader.Reset();
                        L_HandledInterimSalesHeader.SetFilter("No.", SetHandledWeborderFilter(Rec."No."));
                        if L_HandledInterimSalesHeader.FindSet() then begin
                            HandledWebOrderList.SetTableView(L_HandledInterimSalesHeader);
                            HandledWebOrderList.Run();
                        end;
                    end;
                end;
            }
        }
    }

    local procedure SetWeborderFilter(_SalesOrderNo: Code[20]): Text
    var
        L_WebBuffer: Record "Web Buffer";
        WebOrderNo: Text;
    begin
        Clear(WebOrderNo);
        L_WebBuffer.Reset();
        L_WebBuffer.SetRange("Sales Document No.", _SalesOrderNo);
        L_WebBuffer.SetCurrentKey("Web Document No.");
        L_WebBuffer.Ascending(true);
        if L_WebBuffer.FindSet() then begin
            repeat
                if WebOrderNo <> '' then begin
                    WebOrderNo := WebOrderNo + '|' + L_WebBuffer."Web Document No.";
                end else
                    WebOrderNo := L_WebBuffer."Web Document No.";
            until L_WebBuffer.Next() = 0;
        end;
        exit(WebOrderNo);
    end;

    local procedure SetHandledWeborderFilter(_SalesOrderNo: Code[20]): Text
    var
        L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        HandledWebOrderNo: Text;
    begin
        Clear(HandledWebOrderNo);
        L_HandledInterimSalesHeader.Reset();
        L_HandledInterimSalesHeader.SetRange("Destination Doc No.", _SalesOrderNo);
        L_HandledInterimSalesHeader.SetCurrentKey("No.");
        L_HandledInterimSalesHeader.Ascending(true);
        if L_HandledInterimSalesHeader.FindSet() then begin
            repeat
                if HandledWebOrderNo <> '' then begin
                    HandledWebOrderNo := HandledWebOrderNo + '|' + L_HandledInterimSalesHeader."No.";
                end else
                    HandledWebOrderNo := L_HandledInterimSalesHeader."No.";
            until L_HandledInterimSalesHeader.Next() = 0;
        end;
        exit(HandledWebOrderNo);
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