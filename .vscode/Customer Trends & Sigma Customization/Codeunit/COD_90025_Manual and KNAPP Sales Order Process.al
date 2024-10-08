codeunit 90025 "Manual/KNAAP SO Process"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
    begin
        case Rec."Parameter String" of
            KnappOrdersLabel:
                begin
                    UpdateKnappOrders();
                end;
            NonKnappOrderLabel:
                begin
                    UpdateNonKnappOrders();
                end;
            KnappNonKnappOrdersLabel:
                begin
                    UpdateKnappAndNonKnappVariant();
                end;
        end;
    end;

    var
        KnappOrdersLabel: Label 'KnappOrders';
        NonKnappOrderLabel: Label 'NonKnappOrders';
        KnappNonKnappOrdersLabel: Label 'KnappNonKnappOrders';
        CU_ReleaseSalesDoc: Codeunit "Release Sales Document";

    local procedure UpdateKnappOrders()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        Counter: Integer;
        GeneralSetupChannel: Record "General Setup - Channels";
        L_SalesLine: Record "Sales Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";

        MinOrder_Header: Record "Sales Header";
        L_SumMin: Decimal;
    begin
        GeneralSetupChannel.Get();
        Clear(Counter);
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetRange("Knapp Order", true);
        L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                Counter += 1;
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Commented by Abdul - 07/10/2024
                    // //Update Variant Code
                    // UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    // Commit();
                    //Commented by Abdul - 07/10/2024

                    //Release Sales Order
                    // if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                    //     BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                    //     RecRef.GetTable(Rec_SalesHeader);
                    //     BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
                    // end;

                    //Release Sales Order through Approval process
                    L_SalesLine.Reset();
                    L_SalesLine.CalcFields("Variant Code mandatory");
                    L_SalesLine.SetRange("Document Type", Rec_SalesHeader."Document Type");
                    L_SalesLine.SetRange("Document No.", Rec_SalesHeader."No.");
                    L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                    L_SalesLine.SetFilter("Variant Code", '%1', '');
                    L_SalesLine.SetRange("Variant Code mandatory", true);
                    L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
                    L_SalesLine.SetFilter("Location Code", '<>%1', '');
                    if not L_SalesLine.FindFirst() then begin
                        //Send for Release order if Approval not required
                        Rec_SalesHeader.CalcFields("Zero Price Approval", "SO Min Order Approval Required", Amount);
                        if (Rec_SalesHeader."Zero Price Approval" = false) AND (Rec_SalesHeader."Sales Quota Approval" = false) AND (Rec_SalesHeader."SO Approval Required" = false) AND (Rec_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (Rec_SalesHeader."Credit Limit Approval" = false) then begin
                            Clear(L_SumMin);
                            MinOrder_Header.Reset();
                            MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                            MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                            MinOrder_Header.SetRange("Document Date", Rec_SalesHeader."Document Date");
                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                            if MinOrder_Header.FindSet() then begin
                                repeat
                                    MinOrder_Header.CalcFields(Amount);
                                    L_SumMin += MinOrder_Header.Amount;
                                until MinOrder_Header.Next() = 0;
                            end;

                            if Rec_SalesHeader."Min Order Value" <> 0 then begin
                                if L_SumMin >= Rec_SalesHeader.Amount then begin
                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                    Commit();
                                end;
                            end else begin
                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                Commit();
                            end;
                        end;

                        // if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(Rec_SalesHeader) then begin
                        //     if Rec_SalesHeader.SalesLinesExist() then begin
                        //         ApprovalsMgmt.OnSendSalesDocForApproval(Rec_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;
                    end;

                    //Code to process only 500 Orders then exit the code
                    if GeneralSetupChannel."Update Variant Counter" > 0 then begin
                        if Counter = GeneralSetupChannel."Update Variant Counter" then
                            exit;
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;

    local procedure UpdateNonKnappOrders()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        L_SalesLine: Record "Sales Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";

        MinOrder_Header: Record "Sales Header";
        L_SumMin: Decimal;
    begin
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Commented by Abdul - 07/10/2024
                    // //Update Variant Code
                    // UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    // Commit();
                    //Commented by Abdul - 07/10/2024

                    //Release Sales Order
                    // if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                    //     BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                    //     RecRef.GetTable(Rec_SalesHeader);
                    //     BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
                    // end;

                    //Release Sales Order through Approval process
                    L_SalesLine.Reset();
                    L_SalesLine.CalcFields("Variant Code mandatory");
                    L_SalesLine.SetRange("Document Type", Rec_SalesHeader."Document Type");
                    L_SalesLine.SetRange("Document No.", Rec_SalesHeader."No.");
                    L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                    L_SalesLine.SetFilter("Variant Code", '%1', '');
                    L_SalesLine.SetRange("Variant Code mandatory", true);
                    L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
                    L_SalesLine.SetFilter("Location Code", '<>%1', '');
                    if not L_SalesLine.FindFirst() then begin
                        //Send for Release order if Approval not required
                        Rec_SalesHeader.CalcFields("Zero Price Approval", "SO Min Order Approval Required", Amount);
                        if (Rec_SalesHeader."Zero Price Approval" = false) AND (Rec_SalesHeader."Sales Quota Approval" = false) AND (Rec_SalesHeader."SO Approval Required" = false) AND (Rec_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (Rec_SalesHeader."Credit Limit Approval" = false) then begin
                            Clear(L_SumMin);
                            MinOrder_Header.Reset();
                            MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                            MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                            MinOrder_Header.SetRange("Document Date", Rec_SalesHeader."Document Date");
                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                            if MinOrder_Header.FindSet() then begin
                                repeat
                                    MinOrder_Header.CalcFields(Amount);
                                    L_SumMin += MinOrder_Header.Amount;
                                until MinOrder_Header.Next() = 0;
                            end;

                            if Rec_SalesHeader."Min Order Value" <> 0 then begin
                                if L_SumMin >= Rec_SalesHeader.Amount then begin
                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                    Commit();
                                end;
                            end else begin
                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                Commit();
                            end;
                        end;
                        // if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(Rec_SalesHeader) then begin
                        //     if Rec_SalesHeader.SalesLinesExist() then begin
                        //         ApprovalsMgmt.OnSendSalesDocForApproval(Rec_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;

    local procedure UpdateKnappAndNonKnappVariant()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        Counter: Integer;
    begin
        Clear(Counter);
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-3D', WorkDate()), WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                Counter += 1;
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Update Variant Code
                    UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    Commit();

                    //Release Sales Order
                    if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                        RecRef.GetTable(Rec_SalesHeader);
                        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
                    end;

                    //Code to process only 500 Orders then exit the code
                    if Counter = 500 then
                        exit;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;
}