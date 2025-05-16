// Below are the approval conditions for the Sales Order:
// 1. Sales Order Approval Required: This will be updated at the time of creation of the sales order (for both IRP and Non-IRP).
// 2. Zero Price Approval: This is a flow field from the sales line, which will be updated at the time of creation of the sales order (for both IRP and Non-IRP).
// 3. Customer Type = M – EXPORT: This will be updated at the time of creation of the sales order (for both IRP and Non-IRP).
// 4. SO Min Order Approval: For Non-IRP orders, this will be updated when the "Update Variant, KNAPP Check & Release" button is clicked on the sales order screen. For IRP orders, it will be updated at the time of releasing the order from the job queue.
// 5. Credit Limit Approval: For Non-IRP orders, this will be updated at the time of creation of the sales order from the sales order screen. For IRP orders, it will be updated at the time of releasing the sales order from the job queue.
// 6. Sales Quota Approval: For Non-IRP orders, this will be updated at the time of creation of the sales order from the sales order screen. For IRP orders, it will be updated at the time of releasing the sales order from the job queue.



codeunit 90203 "Manage Time duration"
{
    SingleInstance = true;


    var
        G_CalledFromReleaseProcess: Boolean;
        G_OrderNo: Code[20];
        G_DocumentType: Enum "Sales Document Type";

        //Prathamesh++
        CustCheckCreditLimit: Page "Check Credit Limit";
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionTypeTxt: Label 'Check Cr. Limit';
        CreditLimitNotificationMsg: Label 'The customer''s credit limit has been exceeded.';
        OverdueBalanceNotificationMsg: Label 'This customer has an overdue balance.';
        GetDetailsTxt: Label 'Show details';
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        NotificationId: Guid;
    //Prathamesh--

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforePerformManualReleaseProcedure', '', false, false)]
    local procedure OnBeforePerformManualReleaseProcedure(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        L_SalesHeader: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        RecUserSetup: Record "User Setup";
        AllEvent: Codeunit "All Event";
        CheckCreditLimit: codeunit "Cust-Check Cr. Limit";
    begin
        // L_SalesHeader.Reset();
        // L_SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        // L_SalesHeader.SetRange("No.", SalesHeader."No.");
        // if L_SalesHeader.FindFirst() then begin
        //     if L_SalesHeader."Document Type" = L_SalesHeader."Document Type"::Order then begin
        //         if L_SalesHeader."Web Order" = true then begin
        //             //Credit Limit++
        //             L_SalesHeader."Credit Limit Approval" := CheckCreditLimit.SalesHeaderCheck(L_SalesHeader);
        //             L_SalesHeader.Modify();
        //             if L_SalesHeader."Credit Limit Approval" = true then
        //                 IsHandled := true;



        //             //Sales quota Check+++
        //             L_SalesLine.Reset();
        //             L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
        //             L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
        //             L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        //             if L_SalesLine.FindSet() then begin
        //                 repeat
        //                     if L_SalesLine.Quantity > 0 then begin
        //                         IF RecUserSetup.GET(USERID) THEN BEGIN
        //                             IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
        //                                 AllEvent.CheckMaxOrderQty2(L_SalesLine);
        //                                 L_SalesLine.Modify();

        //                                 L_SalesHeader.CalcFields("Sales Quota Approval");
        //                                 if L_SalesHeader."Sales Quota Approval" = true then
        //                                     IsHandled := true;
        //                             END;
        //                         END ELSE BEGIN
        //                             AllEvent.CheckMaxOrderQty2(L_SalesLine);
        //                             L_SalesLine.Modify();

        //                             L_SalesHeader.CalcFields("Sales Quota Approval");
        //                             if L_SalesHeader."Sales Quota Approval" = true then
        //                                 IsHandled := true;
        //                         END;
        //                     end;
        //                 until L_SalesLine.Next() = 0;
        //             end;
        //         end else begin
        //             //Credit Limit++
        //             if L_SalesHeader."Credit Limit Approval" = true then
        //                 IsHandled := true;

        //             //Sales Quota++
        //             L_SalesHeader.CalcFields("Sales Quota Approval");
        //             if L_SalesHeader."Sales Quota Approval" = true then
        //                 IsHandled := true;
        //         end;
        //     end;
        // end;

        //New Code - 13/01/2025++++
        Clear(G_CalledFromReleaseProcess);
        Clear(G_OrderNo);
        Clear(G_DocumentType);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        L_SalesHeader.SetRange("No.", SalesHeader."No.");
        if L_SalesHeader.FindFirst() then begin
            if L_SalesHeader."Document Type" = L_SalesHeader."Document Type"::Order then begin
                if L_SalesHeader."Web Order" = true then begin
                    //Credit Limit++
                    G_CalledFromReleaseProcess := true;
                    G_OrderNo := L_SalesHeader."No.";
                    G_DocumentType := L_SalesHeader."Document Type";

                    if GuiAllowed = true then
                        CheckCreditLimit.SalesHeaderCheck(L_SalesHeader) //Prathamesh++
                    else
                        SalesHeaderCheckNew(L_SalesHeader); //Prathamesh++



                    //Sales quota Check+++
                    L_SalesLine.Reset();
                    L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                    L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                    L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                    if L_SalesLine.FindSet() then begin
                        repeat
                            if L_SalesLine.Quantity > 0 then begin
                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                    IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                                        AllEvent.CheckMaxOrderQty2(L_SalesLine);
                                        L_SalesLine.Modify();
                                    END;
                                END ELSE BEGIN
                                    AllEvent.CheckMaxOrderQty2(L_SalesLine);
                                    L_SalesLine.Modify();
                                END;
                            end;
                        until L_SalesLine.Next() = 0;
                    end;
                end;
            end;
        end;


        #Region Check All Approval Conditions+++++
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        L_SalesHeader.SetRange("No.", SalesHeader."No.");
        if L_SalesHeader.FindFirst() then begin
            if L_SalesHeader."Document Type" = L_SalesHeader."Document Type"::Order then begin
                if (CreditLimitCheck(L_SalesHeader) = false) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = false) AND ((ExportCustomerCheck(L_SalesHeader) = false)) then begin
                    //Need to check if it is required in future++
                end else begin
                    if L_SalesHeader.Hospital = false then begin
                        //Non Hospital orders Check all Approval and Permission before release+++
                        if (CreditLimitCheck(L_SalesHeader) = true) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = false) AND ((ExportCustomerCheck(L_SalesHeader) = false)) then begin
                            RecUserSetup.Reset();
                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                if RecUserSetup."Credit Limit Release" = false then
                                    IsHandled := true;
                            end else
                                IsHandled := true;
                        end else begin
                            if (CreditLimitCheck(L_SalesHeader) = true) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) AND ((ExportCustomerCheck(L_SalesHeader) = false)) then begin
                                RecUserSetup.Reset();
                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                    if RecUserSetup."SO Release spec. (NonExport)" = false then
                                        IsHandled := true;
                                end else
                                    IsHandled := true;
                            end else begin
                                if (CreditLimitCheck(L_SalesHeader) = true) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = false) AND ((ExportCustomerCheck(L_SalesHeader) = true)) then begin
                                    RecUserSetup.Reset();
                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                        if RecUserSetup."SO Release Specialist (Export)" = false then
                                            IsHandled := true;
                                    end else
                                        IsHandled := true;
                                end else begin
                                    if (CreditLimitCheck(L_SalesHeader) = true) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) AND ((ExportCustomerCheck(L_SalesHeader) = true)) then begin
                                        RecUserSetup.Reset();
                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                            if RecUserSetup."SO Release Specialist (Export)" = false then
                                                IsHandled := true;
                                        end else
                                            IsHandled := true;
                                    end else begin
                                        if (CreditLimitCheck(L_SalesHeader) = false) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) AND ((ExportCustomerCheck(L_SalesHeader) = false)) then begin
                                            RecUserSetup.Reset();
                                            IF RecUserSetup.GET(USERID) THEN BEGIN
                                                if RecUserSetup."SO/MOV/Quota/ZeroPrice Release" = false then
                                                    IsHandled := true;
                                            end else
                                                IsHandled := true;
                                        end else begin
                                            if (CreditLimitCheck(L_SalesHeader) = false) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) AND ((ExportCustomerCheck(L_SalesHeader) = true)) then begin
                                                RecUserSetup.Reset();
                                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                                    if RecUserSetup."SO Release Specialist (Export)" = false then
                                                        IsHandled := true;
                                                end else
                                                    IsHandled := true;
                                            end else begin
                                                if (CreditLimitCheck(L_SalesHeader) = false) AND (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = false) AND ((ExportCustomerCheck(L_SalesHeader) = true)) then begin
                                                    RecUserSetup.Reset();
                                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                                        if RecUserSetup."Export Customer Release" = false then
                                                            IsHandled := true;
                                                    end else
                                                        IsHandled := true;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end else begin
                        //For Hospital Order Ignore Credit Limit Approval+++
                        if (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = false) AND ((ExportCustomerCheck(L_SalesHeader) = false)) then begin
                            //Need to check if it is required in future++
                        end else begin
                            if (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) AND ((ExportCustomerCheck(L_SalesHeader) = false)) then begin
                                RecUserSetup.Reset();
                                IF RecUserSetup.GET(USERID) THEN BEGIN
                                    if RecUserSetup."SO/MOV/Quota/ZeroPrice Release" = false then
                                        IsHandled := true;
                                end else
                                    IsHandled := true;
                            end else begin
                                if (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = true) AND ((ExportCustomerCheck(L_SalesHeader) = true)) then begin
                                    RecUserSetup.Reset();
                                    IF RecUserSetup.GET(USERID) THEN BEGIN
                                        if RecUserSetup."SO Release Specialist (Export)" = false then
                                            IsHandled := true;
                                    end else
                                        IsHandled := true;
                                end else begin
                                    if (SOMOVZeroPriceAndQuotaCheck(L_SalesHeader) = false) AND ((ExportCustomerCheck(L_SalesHeader) = true)) then begin
                                        RecUserSetup.Reset();
                                        IF RecUserSetup.GET(USERID) THEN BEGIN
                                            if RecUserSetup."Export Customer Release" = false then
                                                IsHandled := true;
                                        end else
                                            IsHandled := true;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        #EndRegion Check All Approval Conditions+++++
    end;


    //Update Credit Limit and OverDue for IRP order at the time of relaese SO+++
    [EventSubscriber(ObjectType::Page, Page::"Check Credit Limit", OnShowWarningOnBeforeExitValue, '', false, false)]
    local procedure OnShowWarningOnBeforeExitValue(ExitValue: Integer)
    var
        L_SalesHeader: Record "Sales Header";
        CustCheckCrLimit: Codeunit "Cust-Check Cr. Limit";
    begin
        if G_CalledFromReleaseProcess = true then begin
            L_SalesHeader.Reset();
            L_SalesHeader.SetRange("No.", G_OrderNo);
            L_SalesHeader.SetRange("Document Type", G_DocumentType);
            if L_SalesHeader.FindFirst() then begin
                if L_SalesHeader."IRP Order" = true then begin
                    if ExitValue = 1 then begin
                        L_SalesHeader."Credit limit Exceeded" := true;
                        NotificationId := CustCheckCrLimit.GetCreditLimitNotificationId();
                    end else
                        L_SalesHeader."Credit limit Exceeded" := false;

                    if ExitValue = 2 then begin
                        L_SalesHeader."Overdue Balance" := true;
                        NotificationId := CustCheckCrLimit.GetCreditLimitNotificationId();
                    end else
                        L_SalesHeader."Overdue Balance" := false;

                    if ExitValue = 3 then begin
                        L_SalesHeader."Credit limit Exceeded" := true;
                        L_SalesHeader."Overdue Balance" := true;
                        NotificationId := CustCheckCrLimit.GetCreditLimitNotificationId();
                    end;

                    //+++++++
                    if ExitValue <> 0 then begin
                        if (L_SalesHeader."Exempt from Overdue check" = false) AND (L_SalesHeader.Hospital = false) then begin
                            L_SalesHeader."Credit Limit Approval" := true;
                            L_SalesHeader.Modify();
                        end else begin
                            if (L_SalesHeader."Exempt from Overdue check" = true) AND (L_SalesHeader.Hospital = true) then begin
                                L_SalesHeader."Credit Limit Approval" := false;
                                L_SalesHeader.Modify();
                            end else begin
                                if (L_SalesHeader."Exempt from Overdue check" = true) AND (L_SalesHeader.Hospital = false) then begin
                                    if (ExitValue = 1) OR (ExitValue = 3) then begin
                                        L_SalesHeader."Credit Limit Approval" := true;
                                        L_SalesHeader.Modify();
                                    end else begin
                                        L_SalesHeader."Credit Limit Approval" := false;
                                        L_SalesHeader.Modify();
                                    end;
                                end else begin
                                    if (L_SalesHeader."Exempt from Overdue check" = false) AND (L_SalesHeader.Hospital = true) then begin
                                        if (ExitValue = 2) OR (ExitValue = 3) then begin
                                            L_SalesHeader."Credit Limit Approval" := true;
                                            L_SalesHeader.Modify();
                                        end else begin
                                            L_SalesHeader."Credit Limit Approval" := false;
                                            L_SalesHeader.Modify();
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end else begin
                        L_SalesHeader."Credit Limit Approval" := false;
                        L_SalesHeader.Modify();
                    end;
                end;
            end;
        end;

        //CLear Variable++++
        Clear(G_OrderNo);
        Clear(G_DocumentType);
        Clear(G_CalledFromReleaseProcess);
    end;





    //Remove Default Credit limit check at the time consolidation++++
    //We have managed this code on Before Release+++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust-Check Cr. Limit", 'OnBeforeSalesHeaderCheck', '', false, false)]
    local procedure OnBeforeSalesHeaderCheck(var CreditLimitExceeded: Boolean; var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) AND (SalesHeader."Web Order" = true) then begin
            if GuiAllowed = false then begin
                CreditLimitExceeded := false;
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cust-Check Cr. Limit", 'OnBeforeSalesLineCheck', '', false, false)]
    local procedure OnBeforeSalesLineCheck(var CreditLimitExceeded: Boolean; var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        L_SalesHeader: Record "Sales Header";
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("No.", SalesLine."Document No.");
        L_SalesHeader.SetRange("Document Type", SalesLine."Document Type");
        if L_SalesHeader.FindFirst() then begin
            if (SalesLine."Document Type" = SalesLine."Document Type"::Order) AND (L_SalesHeader."Web Order" = true) then begin
                if GuiAllowed = false then begin
                    CreditLimitExceeded := false;
                    IsHandled := true;
                end;
            end;
        end;
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

    //Prathamesh++
    #Region to execute code if GUIAllowed is false(Executing scheduled Job Queue)++++
    local procedure SalesHeaderCheckNew(var SalesHeader: Record "Sales Header") CreditLimitExceeded: Boolean
    var
        AdditionalContextId: Guid;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if SalesHeaderShowWarningAndGetCause(SalesHeader, AdditionalContextId) then
            SalesHeader.CustomerCreditLimitNotExceeded()
        else begin
            CreditLimitExceeded := true;
            SalesHeader.CustomerCreditLimitExceeded(CustCheckCreditLimit.GetNotificationId());
        end;
        // end;
    end;

    local procedure SalesHeaderShowWarningAndGetCause(SalesHeader: Record "Sales Header"; var NotificationContextGuidOut: Guid): Boolean
    var
        Result: Boolean;
    begin
        Result := CustCheckCreditLimit.SalesHeaderShowWarning(SalesHeader);
        NotificationContextGuidOut := NotificationId;
        exit(Result);
    end;
    //Prathamesh--
    #endregion
}