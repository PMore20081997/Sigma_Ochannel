codeunit 90035 "Send SO Approval Jobqueue"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        L_ApprovalEntry: Record 454;
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("IRP Order", true);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange(Shipped, false);
        L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                L_ApprovalEntry.Reset();
                L_ApprovalEntry.SetRange("Table ID", 36);
                L_ApprovalEntry.SetRange("Document Type", L_ApprovalEntry."Document Type"::Order);
                L_ApprovalEntry.SetRange("Document No.", L_SalesHeader."No.");
                L_ApprovalEntry.SetRange(Status, L_ApprovalEntry.Status::Rejected);
                if not L_ApprovalEntry.FindFirst() then begin
                    if (CreditLimitCheck(L_SalesHeader) = true) OR (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) OR (ExportCustomerCheck(L_SalesHeader) = true) then begin
                        if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(L_SalesHeader) then begin
                            if L_SalesHeader.SalesLinesExist() then begin
                                ApprovalsMgmt.OnSendSalesDocForApproval(L_SalesHeader);
                                Commit();
                            end;
                        end;
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;

        // L_SalesHeader.Reset();
        // L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        // L_SalesHeader.SetRange("IRP Order", true);
        // L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        // //L_SalesHeader.SetRange("No.", '0000120475');
        // if L_SalesHeader.FindSet() then begin
        //     repeat
        //         L_SalesLine.Reset();
        //         L_SalesLine.CalcFields("Variant Code mandatory");
        //         L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
        //         L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
        //         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        //         L_SalesLine.SetFilter("Variant Code", '%1', '');
        //         L_SalesLine.SetRange("Variant Code mandatory", true);
        //         L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
        //         L_SalesLine.SetFilter("Location Code", '<>%1', '');
        //         if not L_SalesLine.FindFirst() then begin
        //             //if ApprovalsMgmt.IsSalesHeaderPendingApproval(L_SalesHeader) = false then
        //             if ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(L_SalesHeader) then begin
        //                 if L_SalesHeader.SalesLinesExist() then begin
        //                     ApprovalsMgmt.OnSendSalesDocForApproval(L_SalesHeader);
        //                     Commit();
        //                 end;
        //             end;
        //         end;
        //     until L_SalesHeader.Next() = 0;
        // end;
    end;



    procedure CreditLimitCheck(_SalesHeader: Record "Sales Header"): Boolean
    begin
        if _SalesHeader."Credit Limit Approval" = true then
            exit(true)
        else
            exit(false);
    end;

    procedure SOMOVZeroPriceAndQuotaCheck(_SalesHeader: Record "Sales Header"): Boolean
    begin
        _SalesHeader.CalcFields("Zero Price Approval", "Sales Quota Approval");
        if (_SalesHeader."SO Approval Required" = true) OR (_SalesHeader."SO Min Order Approval Required" = true) OR (_SalesHeader."Zero Price Approval" = true) OR (_SalesHeader."Sales Quota Approval" = true) then
            exit(true)
        else
            exit(false);
    end;

    procedure ExportCustomerCheck(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_DefaultDimension: Record "Default Dimension";
    begin
        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("SO Approval Required", true);
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("No.", _SalesHeader."Sell-to Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                L_DefaultDimension.CalcFields("Dimension Value Name 2");
                if UpperCase(L_DefaultDimension."Dimension Value Name 2") = UpperCase(_SalesHeader."Shortcut Dimension 3 Code") then
                    exit(true)
            until L_DefaultDimension.Next() = 0;
        end;

        exit(false);
    end;
}