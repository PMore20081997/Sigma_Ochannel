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
                    //UpdateKnappAndNonKnappVariant();
                end;
        end;
    end;

    var
        KnappOrdersLabel: Label 'KnappOrders';
        NonKnappOrderLabel: Label 'NonKnappOrders';
        KnappNonKnappOrdersLabel: Label 'KnappNonKnappOrders';
        CU_ReleaseSalesDoc: Codeunit "Release Sales Document";
        RecUserSetup: Record "User Setup";
        L_CheckConditipon: Codeunit "Manage Time duration";

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
        L_Customer: Record Customer;
        L_BilltoCustomer: Record Customer;
        CheckCreditLimit: codeunit "Cust-Check Cr. Limit";
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
                        #Region Check All Approval and User Permission before rellease++++
                        // //Send for Release order if Approval not required
                        // Rec_SalesHeader.CalcFields("Zero Price Approval", Amount, "Sales Quota Approval");
                        // if (Rec_SalesHeader."Zero Price Approval" = false) AND (Rec_SalesHeader."Sales Quota Approval" = false) AND (Rec_SalesHeader."SO Approval Required" = false) AND (Rec_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (Rec_SalesHeader."Credit Limit Approval" = false) then begin
                        //     Clear(L_SumMin);
                        //     MinOrder_Header.Reset();
                        //     MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                        //     MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                        //     MinOrder_Header.SetRange("Shipment Date", Rec_SalesHeader."Shipment Date");
                        //     MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                        //     MinOrder_Header.SetRange("Web Order", true);
                        //     if MinOrder_Header.FindSet() then begin
                        //         repeat
                        //             MinOrder_Header.CalcFields(Amount);
                        //             L_SumMin += MinOrder_Header.Amount;
                        //         until MinOrder_Header.Next() = 0;
                        //     end;

                        //     if Rec_SalesHeader."Min Order Value" <> 0 then begin
                        //         if L_SumMin >= Rec_SalesHeader."Min Order Value" then begin
                        //             CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                        //             Commit();
                        //         end else begin
                        //             Rec_SalesHeader."SO Min Order Approval Required" := true;
                        //             Rec_SalesHeader.Modify();
                        //         end;
                        //     end else begin
                        //         CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;

                        // if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(Rec_SalesHeader) then begin
                        //     if Rec_SalesHeader.SalesLinesExist() then begin
                        //         ApprovalsMgmt.OnSendSalesDocForApproval(Rec_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;

                        #Region New Code - 21/01/2025+++++
                        //Update Min Price Field on SO before releas+++
                        if Rec_SalesHeader."Min Order Value" <> 0 then begin
                            Clear(L_SumMin);
                            MinOrder_Header.Reset();
                            MinOrder_Header.SetRange("Document Type", Rec_SalesHeader."Document Type");
                            MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                            MinOrder_Header.SetRange("Shipment Date", Rec_SalesHeader."Shipment Date");
                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                            MinOrder_Header.SetRange("Web Order", true);
                            if MinOrder_Header.FindSet() then begin
                                repeat
                                    MinOrder_Header.CalcFields(Amount);
                                    L_SumMin += MinOrder_Header.Amount;
                                until MinOrder_Header.Next() = 0;

                                if L_SumMin >= Rec_SalesHeader."Min Order Value" then begin
                                    Rec_SalesHeader."SO Min Order Approval Required" := false;
                                    Rec_SalesHeader.Modify();
                                end else begin
                                    Rec_SalesHeader."SO Min Order Approval Required" := true;
                                    Rec_SalesHeader.Modify();
                                end;
                            end;
                        end else begin
                            Rec_SalesHeader."SO Min Order Approval Required" := false;
                            Rec_SalesHeader.Modify();
                        end;

                        if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                            CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                            Commit();
                        end else begin
                            if Rec_SalesHeader.Hospital = true then begin
                                //For Hospital Order Ignore Credit Limit Approval+++
                                if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                    Commit();
                                end else begin
                                    if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                        RecUserSetup.Reset();
                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                            if RecUserSetup."SO/MOV/Quota/ZeroPrice Release" = true then begin
                                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                Commit();
                                            end;
                                        end;
                                    end else begin
                                        if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                            RecUserSetup.Reset();
                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                    Commit();
                                                end;
                                            end;
                                        end else begin
                                            if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                RecUserSetup.Reset();
                                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                                    if RecUserSetup."Export Customer Release" = true then begin
                                                        CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                        Commit();
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end else begin
                                // L_Customer.Reset();
                                // L_Customer.SetRange("No.", Rec_SalesHeader."Sell-to Customer No.");
                                // if L_Customer.FindFirst() then begin
                                //     if L_Customer."Bill-to Customer No." <> '' then begin

                                //         L_BilltoCustomer.Reset();
                                //         L_BilltoCustomer.SetRange("No.", L_Customer."Bill-to Customer No.");
                                //         if L_BilltoCustomer.FindFirst() then begin
                                //             L_BilltoCustomer.CalcFields("Balance (LCY)");
                                //             if L_BilltoCustomer."Balance (LCY)" > L_BilltoCustomer."Credit Limit (LCY)" then
                                //                 Rec_SalesHeader."Credit limit Exceeded" := true;
                                //         end;
                                //     end else begin
                                //         if L_Customer."Balance (LCY)" > L_Customer."Credit Limit (LCY)" then
                                //             Rec_SalesHeader."Credit limit Exceeded" := true;
                                //     end;

                                // end;
                                // Rec_SalesHeader."Overdue Balance" := CheckCreditLimit.SalesHeaderCheck(Rec_SalesHeader);


                                // if ((Rec_SalesHeader."Credit limit Exceeded" = true) or (Rec_SalesHeader."Overdue Balance" = true)) then
                                //     Rec_SalesHeader."Credit Limit Approval" := true;
                                //Non Hospital orders Check all Approval and Permission before release+++
                                if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                    RecUserSetup.Reset();
                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                        if RecUserSetup."Credit Limit Release" = true then begin
                                            CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                            Commit();
                                        end;
                                    end;
                                end else begin
                                    if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                        RecUserSetup.Reset();
                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                            if RecUserSetup."SO Release spec. (NonExport)" = true then begin
                                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                Commit();
                                            end;
                                        end;
                                    end else begin
                                        if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                            RecUserSetup.Reset();
                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                    Commit();
                                                end;
                                            end;
                                        end else begin
                                            if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                RecUserSetup.Reset();
                                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                                    if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                        CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                        Commit();
                                                    end;
                                                end;
                                            end else begin
                                                if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                                    RecUserSetup.Reset();
                                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                                        if RecUserSetup."SO/MOV/Quota/ZeroPrice Release" = true then begin
                                                            CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                            Commit();
                                                        end;
                                                    end;
                                                end else begin
                                                    if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                        RecUserSetup.Reset();
                                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                                            if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                                Commit();
                                                            end;
                                                        end;
                                                    end else begin
                                                        if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                            RecUserSetup.Reset();
                                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                                if RecUserSetup."Export Customer Release" = true then begin
                                                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                                    Commit();
                                                                end;
                                                            end;
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        #EndRegion New Code - 21/01/2025+++++
                        #EndRegion Check All Approval and User Permission before rellease++++
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
        L_Customer: Record Customer;
        L_BilltoCustomer: Record Customer;
        CheckCreditLimit: codeunit "Cust-Check Cr. Limit";
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
                        #Region Check All Approval and User Permission before rellease++++
                        // //Send for Release order if Approval not required
                        // Rec_SalesHeader.CalcFields("Zero Price Approval", Amount, "Sales Quota Approval");
                        // if (Rec_SalesHeader."Zero Price Approval" = false) AND (Rec_SalesHeader."Sales Quota Approval" = false) AND (Rec_SalesHeader."SO Approval Required" = false) AND (Rec_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (Rec_SalesHeader."Credit Limit Approval" = false) then begin
                        //     Clear(L_SumMin);
                        //     MinOrder_Header.Reset();
                        //     MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                        //     MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                        //     MinOrder_Header.SetRange("Shipment Date", Rec_SalesHeader."Shipment Date");
                        //     MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                        //     MinOrder_Header.SetRange("Web Order", true);
                        //     if MinOrder_Header.FindSet() then begin
                        //         repeat
                        //             MinOrder_Header.CalcFields(Amount);
                        //             L_SumMin += MinOrder_Header.Amount;
                        //         until MinOrder_Header.Next() = 0;
                        //     end;

                        //     if Rec_SalesHeader."Min Order Value" <> 0 then begin
                        //         if L_SumMin >= Rec_SalesHeader."Min Order Value" then begin
                        //             CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                        //             Commit();
                        //         end else begin
                        //             Rec_SalesHeader."SO Min Order Approval Required" := true;
                        //             Rec_SalesHeader.Modify();
                        //         end;
                        //     end else begin
                        //         CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;

                        // if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(Rec_SalesHeader) then begin
                        //     if Rec_SalesHeader.SalesLinesExist() then begin
                        //         ApprovalsMgmt.OnSendSalesDocForApproval(Rec_SalesHeader);
                        //         Commit();
                        //     end;
                        // end;

                        #Region New Code - 21/01/2025+++++
                        //Update Min Price Field on SO before releas+++
                        if Rec_SalesHeader."Min Order Value" <> 0 then begin
                            Clear(L_SumMin);
                            MinOrder_Header.Reset();
                            MinOrder_Header.SetRange("Document Type", Rec_SalesHeader."Document Type");
                            MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                            MinOrder_Header.SetRange("Shipment Date", Rec_SalesHeader."Shipment Date");
                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                            MinOrder_Header.SetRange("Web Order", true);
                            if MinOrder_Header.FindSet() then begin
                                repeat
                                    MinOrder_Header.CalcFields(Amount);
                                    L_SumMin += MinOrder_Header.Amount;
                                until MinOrder_Header.Next() = 0;

                                if L_SumMin >= Rec_SalesHeader."Min Order Value" then begin
                                    Rec_SalesHeader."SO Min Order Approval Required" := false;
                                    Rec_SalesHeader.Modify();
                                end else begin
                                    Rec_SalesHeader."SO Min Order Approval Required" := true;
                                    Rec_SalesHeader.Modify();
                                end;
                            end;
                        end else begin
                            Rec_SalesHeader."SO Min Order Approval Required" := false;
                            Rec_SalesHeader.Modify();
                        end;

                        if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                            CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                            Commit();
                        end else begin
                            if Rec_SalesHeader.Hospital = true then begin
                                //For Hospital Order Ignore Credit Limit Approval+++
                                if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                    Commit();
                                end else begin
                                    if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                        RecUserSetup.Reset();
                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                            if RecUserSetup."SO/MOV/Quota/ZeroPrice Release" = true then begin
                                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                Commit();
                                            end;
                                        end;
                                    end else begin
                                        if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                            RecUserSetup.Reset();
                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                    Commit();
                                                end;
                                            end;
                                        end else begin
                                            if (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                RecUserSetup.Reset();
                                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                                    if RecUserSetup."Export Customer Release" = true then begin
                                                        CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                        Commit();
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end else begin
                                //Non Hospital orders Check all Approval and Permission before release+++
                                // L_Customer.Reset();
                                // L_Customer.SetRange("No.", Rec_SalesHeader."Sell-to Customer No.");
                                // if L_Customer.FindFirst() then begin
                                //     if L_Customer."Bill-to Customer No." <> '' then begin

                                //         L_BilltoCustomer.Reset();
                                //         L_BilltoCustomer.SetRange("No.", L_Customer."Bill-to Customer No.");
                                //         if L_BilltoCustomer.FindFirst() then begin
                                //             L_BilltoCustomer.CalcFields("Balance (LCY)");
                                //             if L_BilltoCustomer."Balance (LCY)" > L_BilltoCustomer."Credit Limit (LCY)" then
                                //                 Rec_SalesHeader."Credit limit Exceeded" := true;
                                //         end;
                                //     end else begin
                                //         if L_Customer."Balance (LCY)" > L_Customer."Credit Limit (LCY)" then
                                //             Rec_SalesHeader."Credit limit Exceeded" := true;
                                //     end;

                                // end;
                                // Rec_SalesHeader."Overdue Balance" := CheckCreditLimit.SalesHeaderCheck(Rec_SalesHeader);


                                // if ((Rec_SalesHeader."Credit limit Exceeded" = true) or (Rec_SalesHeader."Overdue Balance" = true)) then
                                //     Rec_SalesHeader."Credit Limit Approval" := true;
                                if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                    RecUserSetup.Reset();
                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                        if RecUserSetup."Credit Limit Release" = true then begin
                                            CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                            Commit();
                                        end;
                                    end;
                                end else begin
                                    if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                        RecUserSetup.Reset();
                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                            if RecUserSetup."SO Release spec. (NonExport)" = true then begin
                                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                Commit();
                                            end;
                                        end;
                                    end else begin
                                        if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                            RecUserSetup.Reset();
                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                    Commit();
                                                end;
                                            end;
                                        end else begin
                                            if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = true) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                RecUserSetup.Reset();
                                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                                    if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                        CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                        Commit();
                                                    end;
                                                end;
                                            end else begin
                                                if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = false)) then begin
                                                    RecUserSetup.Reset();
                                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                                        if RecUserSetup."SO/MOV/Quota/ZeroPrice Release" = true then begin
                                                            CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                            Commit();
                                                        end;
                                                    end;
                                                end else begin
                                                    if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = true) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                        RecUserSetup.Reset();
                                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                                            if RecUserSetup."SO Release Specialist (Export)" = true then begin
                                                                CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                                Commit();
                                                            end;
                                                        end;
                                                    end else begin
                                                        if (L_CheckConditipon.CreditLimitCheck(Rec_SalesHeader) = false) AND (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(Rec_SalesHeader) = false) AND ((L_CheckConditipon.ExportCustomerCheck(Rec_SalesHeader) = true)) then begin
                                                            RecUserSetup.Reset();
                                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                                if RecUserSetup."Export Customer Release" = true then begin
                                                                    CU_ReleaseSalesDoc.PerformManualRelease(Rec_SalesHeader);
                                                                    Commit();
                                                                end;
                                                            end;
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        #EndRegion New Code - 21/01/2025+++++
                        #EndRegion Check All Approval and User Permission before rellease++++
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;

    // local procedure UpdateKnappAndNonKnappVariant()
    // var
    //     L_SalesHeader: Record "Sales Header";
    //     Rec_SalesHeader: Record "Sales Header";
    //     BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
    //     RecRef: RecordRef;
    //     UdateVariantonSO: Codeunit "Udate Variant on SO";
    //     ApprovalMgmt: Codeunit "Approvals Mgmt.";
    //     Counter: Integer;
    // begin
    //     Clear(Counter);
    //     Clear(L_SalesHeader);
    //     L_SalesHeader.Reset();
    //     L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
    //     L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
    //     L_SalesHeader.SetRange("Web Order", true);
    //     L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-3D', WorkDate()), WorkDate());
    //     if L_SalesHeader.FindSet() then begin
    //         repeat
    //             Counter += 1;
    //             Rec_SalesHeader.Reset();
    //             Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
    //             Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
    //             if Rec_SalesHeader.FindFirst() then begin
    //                 //Update Variant Code
    //                 UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
    //                 Commit();

    //                 //Release Sales Order
    //                 if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
    //                     BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
    //                     RecRef.GetTable(Rec_SalesHeader);
    //                     BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
    //                 end;

    //                 //Code to process only 500 Orders then exit the code
    //                 if Counter = 500 then
    //                     exit;
    //             end;
    //         until L_SalesHeader.Next() = 0;
    //     end;
    // end;

    // local procedure CreditLimitCheck(_SalesHeader: Record "Sales Header"): Boolean
    // begin
    //     if _SalesHeader."Credit Limit Approval" = true then
    //         exit(true)
    //     else
    //         exit(false);
    // end;

    // local procedure SOMOVZeroPriceAndQuotaCheck(_SalesHeader: Record "Sales Header"): Boolean
    // begin
    //     _SalesHeader.CalcFields("Zero Price Approval", "Sales Quota Approval");
    //     if (_SalesHeader."SO Approval Required" = true) OR (_SalesHeader."SO Min Order Approval Required" = true) OR (_SalesHeader."Zero Price Approval" = true) OR (_SalesHeader."Sales Quota Approval" = true) then
    //         exit(true)
    //     else
    //         exit(false);
    // end;

    // local procedure ExportCustomerCheck(_SalesHeader: Record "Sales Header"): Boolean
    // var
    //     L_DefaultDimension: Record "Default Dimension";
    // begin
    //     L_DefaultDimension.Reset();
    //     L_DefaultDimension.SetRange("SO Approval Required", true);
    //     L_DefaultDimension.SetRange("Table ID", 18);
    //     L_DefaultDimension.SetRange("No.", _SalesHeader."Sell-to Customer No.");
    //     if L_DefaultDimension.FindSet() then begin
    //         repeat
    //             L_DefaultDimension.CalcFields("Dimension Value Name");
    //             if UpperCase(L_DefaultDimension."Dimension Value Name") = UpperCase(_SalesHeader."Shortcut Dimension 3 Code") then
    //                 exit(true)
    //         until L_DefaultDimension.Next() = 0;
    //     end;

    //     exit(false);
    // end;
}