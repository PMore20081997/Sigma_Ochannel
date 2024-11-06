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
            action("Update Variant, KNAPP Check & Release")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    UdateVariantonSO: Codeunit "Udate Variant on SO";
                    L_SalesHeader: Record "Sales Header";
                    L_SalesLine: Record "Sales Line";
                    NoSeriesManagement: Codeunit "No. Series";
                    Rec_SalesLine: Record "Sales Line";
                    CU_ReleaseSalesDoc: Codeunit "Release Sales Document";
                    KnappOrder: Boolean;
                    ItemList: List of [Text];
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    L_Location: Record Location;
                    MinOrder_Header: Record "Sales Header";
                    L_SumMin: Decimal;
                    L_CheckDecimalQty: Decimal;
                begin
                    Clear(L_SalesHeader);
                    L_SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    if L_SalesHeader.FindFirst() then begin
                        L_SalesHeader.TestField(Status, L_SalesHeader.Status::Open);
                        L_SalesHeader.TestField("Web Order", false);
                        // UdateVariantonSO.UpdateVariantOnSalesOrder(L_SalesHeader);
                        // Commit();
                        UdateVariantonSO.RevalidateVariantOnSalesOrder(L_SalesHeader);
                        Commit();

                        #Region Converting to Knapp Order
                        L_SalesLine.Reset();
                        L_SalesLine.CalcFields("Variant Code mandatory");
                        L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                        L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                        L_SalesLine.SetFilter("Variant Code", '%1', '');
                        L_SalesLine.SetRange("Variant Code mandatory", true);
                        L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
                        L_SalesLine.SetFilter("Location Code", '<>%1', '');
                        if not L_SalesLine.FindFirst() then begin
                            L_SalesHeader.CalcFields(Shipped, "Drop/Special Order", "Special Order");
                            if (L_SalesHeader."Knapp Order" = false) and (L_SalesHeader."Drop/Special Order" = false) and (L_SalesHeader.Shipped = false) and (L_SalesHeader."Special Order" = false) then begin
                                L_SalesLine.Reset();
                                L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                                L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                                L_SalesLine.SetRange("Knapp Line", false);
                                if not L_SalesLine.FindFirst() then begin
                                    KnappOrder := true;
                                    Clear(ItemList);
                                    Rec_SalesLine.Reset();
                                    Rec_SalesLine.SetCurrentKey("No.");
                                    Rec_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                                    Rec_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                                    Rec_SalesLine.SetRange(Type, Rec_SalesLine.Type::Item);
                                    Rec_SalesLine.Ascending(true);
                                    if Rec_SalesLine.FindSet() then begin
                                        Clear(L_CheckDecimalQty);
                                        Rec_SalesLine.CalcSums("Outstanding Quantity");
                                        L_CheckDecimalQty := Rec_SalesLine.Quantity;
                                        if L_CheckDecimalQty MOD 1 = 0 then
                                            KnappOrder := true
                                        else
                                            KnappOrder := false;

                                        //CHeck Others condition+++ 
                                        if KnappOrder = true then begin
                                            repeat
                                                if Rec_SalesLine."Variant Code" = '' then begin
                                                    if not ItemList.Contains(Rec_SalesLine."No.") then begin
                                                        ItemList.Add(Rec_SalesLine."No.");
                                                        KnappOrder := true;
                                                    end
                                                    else begin
                                                        KnappOrder := false;
                                                    end;
                                                end
                                                else begin
                                                    if not ItemList.Contains(Rec_SalesLine."Variant Code") then begin
                                                        ItemList.Add(Rec_SalesLine."Variant Code");
                                                        KnappOrder := true;
                                                    end
                                                    else begin
                                                        KnappOrder := false;
                                                    end;
                                                end;
                                            until Rec_SalesLine.Next() = 0;
                                        end;
                                    end;

                                    if KnappOrder = true then begin
                                        L_SalesHeader."Knapp Order" := true;
                                        L_Location.Reset();
                                        L_Location.SetRange("Knapp Location", true);
                                        if L_Location.FindFirst() then begin
                                            L_SalesHeader."Location Code" := L_Location.Code;
                                        end;

                                        if L_SalesHeader."Posting No." = '' then
                                            L_SalesHeader.Validate("Posting No.", NoSeriesManagement.GetNextNo(L_SalesHeader."Posting No. Series", WorkDate()));
                                        L_SalesHeader.Modify(true);

                                        Rec_SalesLine.Reset();
                                        Rec_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                                        Rec_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                                        Rec_SalesLine.SetRange(Type, Rec_SalesLine.Type::Item);
                                        Rec_SalesLine.SetRange("Knapp Line", true);
                                        if Rec_SalesLine.FindSet() then begin
                                            Rec_SalesLine.ModifyAll("Qty. to Ship", 0);
                                            Rec_SalesLine.ModifyAll("Qty. to Invoice", 0);
                                            Rec_SalesLine.ModifyAll("Location Code", L_SalesHeader."Location Code");
                                        end;
                                        Commit();
                                        Message('This order is successfully converted into knapp order');
                                    end
                                    else begin
                                        Message('This order can not be converted into knapp order as there is a duplicate item entry.');
                                    end;
                                end
                                else begin
                                    Message('This order can not be converted into knapp order as there are non Knapp Lines in it.');
                                end;
                            end
                            else begin
                                Message('This order can not be converted into knapp order as the header part is not satisfying the conditions');
                            end;
                        end;
                        #endregion

                        //Send for Release order if Approval not required
                        L_SalesHeader.CalcFields("Zero Price Approval", Amount, "Sales Quota Approval");
                        if (L_SalesHeader."Zero Price Approval" = false) AND (L_SalesHeader."Sales Quota Approval" = false) AND (L_SalesHeader."SO Approval Required" = false) AND (L_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (L_SalesHeader."SO Min Order Approval Required" = false) AND (L_SalesHeader."Credit Limit Approval" = false) then begin
                            Clear(L_SumMin);
                            MinOrder_Header.Reset();
                            MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                            MinOrder_Header.SetRange("Sell-to Customer No.", L_SalesHeader."Sell-to Customer No.");
                            MinOrder_Header.SetRange("Shipment Date", L_SalesHeader."Shipment Date");
                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                            MinOrder_Header.SetRange("Web Order", false);
                            if MinOrder_Header.FindSet() then begin
                                repeat
                                    MinOrder_Header.CalcFields(Amount);
                                    L_SumMin += MinOrder_Header.Amount;
                                until MinOrder_Header.Next() = 0;
                            end;

                            if L_SalesHeader."Min Order Value" <> 0 then begin
                                if L_SumMin >= L_SalesHeader."Min Order Value" then begin
                                    CU_ReleaseSalesDoc.PerformManualRelease(L_SalesHeader);
                                    Commit();
                                end else begin
                                    L_SalesHeader."SO Min Order Approval Required" := true;
                                    L_SalesHeader.Modify();
                                end;
                            end else begin
                                CU_ReleaseSalesDoc.PerformManualRelease(L_SalesHeader);
                                Commit();
                            end;
                        end else begin
                            if L_SalesHeader."Credit Limit Approval" = true then
                                Message('Credit Limit Approval Required');

                            if L_SalesHeader."SO Min Order Approval Required" = true then
                                Message('SO Min Order Approval Required');

                            if L_SalesHeader."Zero Price Approval" = true then
                                Message('Zero Price Approval Required');

                            if L_SalesHeader."Sales Quota Approval" = true then
                                Message('Sales Quota Approval Required');

                            if L_SalesHeader."SO Approval Required" = true then
                                Message('SO Approval Required');
                        end;


                        // if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(L_SalesHeader) then begin
                        //     if L_SalesHeader.SalesLinesExist() then begin
                        //         ApprovalsMgmt.OnSendSalesDocForApproval(L_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;


                        //CU_ReleaseSalesDoc.PerformManualRelease(L_SalesHeader);
                        //Commit();

                        Message('Process Completed');
                    end;
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