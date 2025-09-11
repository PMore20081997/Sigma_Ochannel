pageextension 90083 "Sales Order List Ext" extends "Sales Order List"
{
    layout
    {
        // addafter(Status)
        // {
        //     field("Web Order"; Rec."Web Order")
        //     {
        //         ApplicationArea = All;
        //     }
        // }
    }

    actions
    {
        addafter(Release)
        {
            action("Bulk Delete")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    UserSetup: Record "User Setup";
                begin
                    Commit();
                    UserSetup.Reset();
                    if UserSetup.Get(UserId) then begin
                        if UserSetup."Allow to Delete Bulk SO" = true then begin
                            Clear(L_SalesHeader);
                            L_SalesHeader := Rec;
                            CurrPage.SetSelectionFilter(L_SalesHeader);

                            if L_SalesHeader.FindSet() then begin
                                repeat
                                    L_SalesHeader.Delete(true);
                                    Commit();
                                until L_SalesHeader.Next() = 0;
                            end;
                        end
                        else begin
                            Message('You do not have permission to delete bulk sales orders.');
                        end;
                    end;
                end;
            }

            action("Ckeck & Split Order")
            {
                Image = Split;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    CheckAndSplitOrder: Report "Check & Split Order";
                    L_SalesHeader: Record "Sales Header";
                begin
                    if not Confirm('Do you want to Split the selected order?', false) then
                        exit;


                    Clear(CheckAndSplitOrder);
                    L_SalesHeader.Reset();
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    if L_SalesHeader.FindSet() then begin
                        CheckAndSplitOrder.SetTableView(L_SalesHeader);
                        CheckAndSplitOrder.Run();
                    end;
                end;
            }

            action("Update Variant, KNAPP Check & Release")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    Rec_SalesHeader: Record "Sales Header";
                    UdateVariantonSO: Codeunit "Udate Variant on SO";
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
                    L_WarehouseActivityHeader: Record "Warehouse Activity Header";
                    IsOrderReleased: Boolean;
                    L_ReleaseSalesHeader: Record "Sales Header";
                    L_CheckDecimalQty: Decimal;
                    RecUserSetup: Record "User Setup";
                    L_CheckConditipon: Codeunit "Manage Time duration";
                    L_ApprovalEntry: Record 454;
                begin
                    Commit();
                    Clear(L_SalesHeader);
                    L_SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    //L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
                    L_SalesHeader.SetRange("Web Order", false);
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            Clear(IsOrderReleased);
                            Rec_SalesHeader.Reset();
                            Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                            Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                            if Rec_SalesHeader.FindFirst() then begin
                                //ReOpen SO if it is released++++
                                if Rec_SalesHeader.Status = Rec_SalesHeader.Status::Released then begin
                                    Rec_SalesHeader.PerformManualReopen(Rec_SalesHeader);
                                    IsOrderReleased := true;
                                end;


                                //Update and Revalidate Variant as per the priority++++
                                // UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                                // Commit();
                                if Rec_SalesHeader."Knapp Order" = true then begin
                                    if Rec_SalesHeader."Sent to Knapp" = false then begin
                                        UdateVariantonSO.RevalidateVariantOnSalesOrder(Rec_SalesHeader);
                                        Commit();
                                    end;
                                end else begin
                                    L_WarehouseActivityHeader.Reset();
                                    L_WarehouseActivityHeader.SetRange("Source Document", L_WarehouseActivityHeader."Source Document"::"Sales Order");
                                    L_WarehouseActivityHeader.SetRange("Source No.", Rec_SalesHeader."No.");
                                    L_WarehouseActivityHeader.SetRange(Type, L_WarehouseActivityHeader.Type::"Invt. Pick");
                                    if not L_WarehouseActivityHeader.FindFirst() then begin
                                        UdateVariantonSO.RevalidateVariantOnSalesOrder(Rec_SalesHeader);
                                        Commit();
                                    end;
                                end;


                                #Region Convert to KNAPP and Release the order++++
                                //Direct send to release if the order is already released++++
                                if IsOrderReleased = true then begin
                                    L_ReleaseSalesHeader.Reset();
                                    L_ReleaseSalesHeader.SetRange("No.", Rec_SalesHeader."No.");
                                    L_ReleaseSalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type");
                                    if L_ReleaseSalesHeader.FindFirst() then begin
                                        CU_ReleaseSalesDoc.PerformManualRelease(L_ReleaseSalesHeader);
                                        Commit();
                                    end;
                                end else begin
                                    //Convert to KNAPP+++
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
                                        Rec_SalesHeader.CalcFields(Shipped, "Drop/Special Order", "Special Order");
                                        if (Rec_SalesHeader."Knapp Order" = false) and (Rec_SalesHeader."Drop/Special Order" = false) and (Rec_SalesHeader.Shipped = false) and (Rec_SalesHeader."Special Order" = false) then begin
                                            L_SalesLine.Reset();
                                            L_SalesLine.SetRange("Document Type", Rec_SalesHeader."Document Type");
                                            L_SalesLine.SetRange("Document No.", Rec_SalesHeader."No.");
                                            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                                            L_SalesLine.SetRange("Knapp Line", false);
                                            if not L_SalesLine.FindFirst() then begin
                                                KnappOrder := true;
                                                Clear(ItemList);
                                                Rec_SalesLine.Reset();
                                                Rec_SalesLine.SetCurrentKey("No.");
                                                Rec_SalesLine.SetRange("Document Type", Rec_SalesHeader."Document Type");
                                                Rec_SalesLine.SetRange("Document No.", Rec_SalesHeader."No.");
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
                                                    Rec_SalesHeader."Knapp Order" := true;
                                                    L_Location.Reset();
                                                    L_Location.SetRange("Knapp Location", true);
                                                    if L_Location.FindFirst() then begin
                                                        Rec_SalesHeader."Location Code" := L_Location.Code;
                                                    end;
                                                    if Rec_SalesHeader."Posting No." = '' then
                                                        Rec_SalesHeader.Validate("Posting No.", NoSeriesManagement.GetNextNo(Rec_SalesHeader."Posting No. Series", WorkDate()));
                                                    Rec_SalesHeader.Modify(true);

                                                    Rec_SalesLine.Reset();
                                                    Rec_SalesLine.SetRange("Document Type", Rec_SalesHeader."Document Type");
                                                    Rec_SalesLine.SetRange("Document No.", Rec_SalesHeader."No.");
                                                    Rec_SalesLine.SetRange(Type, Rec_SalesLine.Type::Item);
                                                    Rec_SalesLine.SetRange("Knapp Line", true);
                                                    if Rec_SalesLine.FindSet() then begin
                                                        Rec_SalesLine.ModifyAll("Qty. to Ship", 0, true);
                                                        Rec_SalesLine.ModifyAll("Qty. to Ship (Base)", 0, true);
                                                        Rec_SalesLine.ModifyAll("Qty. to Invoice", 0, true);
                                                        Rec_SalesLine.ModifyAll("Qty. to Invoice (Base)", 0, true);
                                                        Rec_SalesLine.ModifyAll("Location Code", Rec_SalesHeader."Location Code");
                                                    end;
                                                    Commit();
                                                end;
                                            end;
                                        end;

                                        #Region Check All Approval and User Permission before rellease++++

                                        // if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(Rec_SalesHeader) then begin
                                        //     if Rec_SalesHeader.SalesLinesExist() then begin
                                        //         ApprovalsMgmt.OnSendSalesDocForApproval(Rec_SalesHeader);
                                        //         Commit();
                                        //     end;
                                        // end;

                                        // //Send for Release order if Approval not required
                                        // Rec_SalesHeader.CalcFields("Zero Price Approval", Amount, "Sales Quota Approval");
                                        // if (Rec_SalesHeader."Zero Price Approval" = false) AND (Rec_SalesHeader."Sales Quota Approval" = false) AND (Rec_SalesHeader."SO Approval Required" = false) AND (Rec_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (Rec_SalesHeader."Credit Limit Approval" = false) then begin
                                        //     Clear(L_SumMin);
                                        //     MinOrder_Header.Reset();
                                        //     MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                                        //     MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                                        //     MinOrder_Header.SetRange("Shipment Date", Rec_SalesHeader."Shipment Date");
                                        //     MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                                        //     MinOrder_Header.SetRange("Web Order", false);
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

                                        #Region New Code - 21/01/2025+++++
                                        //Update Min Price Field on SO before releas+++
                                        if Rec_SalesHeader."Min Order Value" <> 0 then begin
                                            Clear(L_SumMin);
                                            MinOrder_Header.Reset();
                                            MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                                            MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                                            MinOrder_Header.SetRange("Shipment Date", Rec_SalesHeader."Shipment Date");
                                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                                            MinOrder_Header.SetRange("Web Order", false);
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

                                        //Update the value before send to Release+++
                                        Commit();

                                        if (L_CheckConditipon.CreditLimitCheck(L_SalesHeader) = true) OR (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) OR (L_CheckConditipon.ExportCustomerCheck(L_SalesHeader) = true) then begin
                                            L_ApprovalEntry.Reset();
                                            L_ApprovalEntry.SetRange("Table ID", 36);
                                            L_ApprovalEntry.SetRange("Document Type", L_ApprovalEntry."Document Type"::Order);
                                            L_ApprovalEntry.SetRange("Document No.", L_SalesHeader."No.");
                                            L_ApprovalEntry.SetRange(Status, L_ApprovalEntry.Status::Rejected);
                                            if not L_ApprovalEntry.FindFirst() then begin
                                                if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(L_SalesHeader) then begin
                                                    if L_SalesHeader.SalesLinesExist() then begin
                                                        ApprovalsMgmt.OnSendSalesDocForApproval(L_SalesHeader);
                                                        Commit();
                                                    end;
                                                end;
                                            end;
                                        end else begin
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
                                        end;
                                        #EndRegion New Code - 21/01/2025+++++
                                        #EndRegion Check All Approval and User Permission before rellease++++
                                    end;
                                    #EndRegion Convert to KNAPP and Release the order++++
                                end;
                            end;
                        until L_SalesHeader.Next() = 0;
                    end;

                    //Final message+++
                    Message('Process Completed..');
                end;
            }

            action("EDI File")
            {
                ApplicationArea = All;
                Image = Journal;
                PromotedCategory = Process;
                Promoted = true;
                Visible = false;

                trigger OnAction()
                var
                    EDIInvoiceCOD: Codeunit "EDI File Integration";
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                    SalesHeader: Record "Sales Header";
                    Customer: Record Customer;
                begin
                    Clear(SalesHeader);
                    SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesHeader);

                    if SalesHeader.FindSet() then begin
                        repeat
                            Clear(Customer);
                            Customer.Reset();
                            if Customer.get(SalesHeader."Sell-to Customer No.") then
                                EDIInvoiceCOD.ProcessEDIFile3(SalesHeader, Customer);
                        until SalesHeader.Next() = 0;
                    end;
                end;
            }
        }
    }


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