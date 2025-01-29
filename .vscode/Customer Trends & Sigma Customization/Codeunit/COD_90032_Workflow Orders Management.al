codeunit 90032 "Workflow SO Management"
{
    trigger OnRun()
    begin
        SendtoApproval();
    end;

    var
        myInt: Integer;

    procedure SendtoApproval()
    var
        L_SalesHeader: Record "Sales Header";
        L_CheckQuotaAndCreditLimit: Record "Sales Header";
        CheckCreditLimit: codeunit "Cust-Check Cr. Limit";
        L_SalesLine: Record "Sales Line";
        RecUserSetup: Record "User Setup";
        AllEvent: Codeunit "All Event";
        IsModified: Boolean;
        L_CheckConditipon: Codeunit "Manage Time duration";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                #region Check Credit Limit & Sales Quota for IRP order before releas++++
                Clear(IsModified);
                L_CheckQuotaAndCreditLimit.Reset();
                L_CheckQuotaAndCreditLimit.SetRange("Document Type", L_SalesHeader."Document Type");
                L_CheckQuotaAndCreditLimit.SetRange("No.", L_SalesHeader."No.");
                if L_CheckQuotaAndCreditLimit.FindFirst() then begin
                    if L_CheckQuotaAndCreditLimit."Web Order" = true then begin
                        //Credit Limit++
                        L_CheckQuotaAndCreditLimit."Credit Limit Approval" := CheckCreditLimit.SalesHeaderCheck(L_CheckQuotaAndCreditLimit);
                        IsModified := L_CheckQuotaAndCreditLimit.Modify();


                        //Sales quota Check+++
                        L_SalesLine.Reset();
                        L_SalesLine.SetRange("Document Type", L_CheckQuotaAndCreditLimit."Document Type");
                        L_SalesLine.SetRange("Document No.", L_CheckQuotaAndCreditLimit."No.");
                        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                        if L_SalesLine.FindSet() then begin
                            repeat
                                if L_SalesLine.Quantity > 0 then begin
                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                        IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                                            AllEvent.CheckMaxOrderQty2(L_SalesLine);
                                            IsModified := L_SalesLine.Modify();
                                        END;
                                    END ELSE BEGIN
                                        AllEvent.CheckMaxOrderQty2(L_SalesLine);
                                        IsModified := L_SalesLine.Modify();
                                    END;
                                end;
                            until L_SalesLine.Next() = 0;
                        end;
                    end;
                end;
                if IsModified then
                    Commit();
                #Endregion Check Credit Limit & Sales Quota for IRP order before releas++++

                #Region Send To Approval+++
                if (L_CheckConditipon.CreditLimitCheck(L_SalesHeader) = true) OR (L_CheckConditipon.SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) OR ((L_CheckConditipon.ExportCustomerCheck(L_SalesHeader) = true)) then begin
                    if ApprovalsMgmt.CheckSalesApprovalPossible(L_SalesHeader) then
                        ApprovalsMgmt.OnSendSalesDocForApproval(L_SalesHeader);
                end;
            #EndRegion Send To Approval+++
            until L_SalesHeader.Next() = 0;
        end;
    end;
}