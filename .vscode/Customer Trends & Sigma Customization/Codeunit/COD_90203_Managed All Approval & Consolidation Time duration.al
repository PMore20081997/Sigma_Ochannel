// Below are the approval conditions for the Sales Order:
// 1. Sales Order Approval Required: This will be updated at the time of creation of the sales order (for both IRP and Non-IRP).
// 2. Zero Price Approval: This is a flow field from the sales line, which will be updated at the time of creation of the sales order (for both IRP and Non-IRP).
// 3. Customer Type = M – EXPORT: This will be updated at the time of creation of the sales order (for both IRP and Non-IRP).
// 4. SO Min Order Approval: For Non-IRP orders, this will be updated when the "Update Variant, KNAPP Check & Release" button is clicked on the sales order screen. For IRP orders, it will be updated at the time of releasing the order from the job queue.
// 5. Credit Limit Approval: For Non-IRP orders, this will be updated at the time of creation of the sales order from the sales order screen. For IRP orders, it will be updated at the time of releasing the sales order from the job queue.
// 6. Sales Quota Approval: For Non-IRP orders, this will be updated at the time of creation of the sales order from the sales order screen. For IRP orders, it will be updated at the time of releasing the sales order from the job queue.



codeunit 90203 "Manage Time duration"
{

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
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        L_SalesHeader.SetRange("No.", SalesHeader."No.");
        if L_SalesHeader.FindFirst() then begin
            if L_SalesHeader."Document Type" = L_SalesHeader."Document Type"::Order then begin
                if L_SalesHeader."Web Order" = true then begin
                    //Credit Limit++
                    L_SalesHeader."Credit Limit Approval" := CheckCreditLimit.SalesHeaderCheck(L_SalesHeader);
                    L_SalesHeader.Modify();


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
        #EndRegion Check All Approval Conditions+++++
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





    //FIN-28[08/01/2025]+++++
    [EventSubscriber(ObjectType::Page, PAGE::"Check Credit Limit", OnCalcOverdueBalanceLCYAfterSetFilter, '', false, false)]
    local procedure OnCalcOverdueBalanceLCYAfterSetFilter(var Customer: Record Customer)
    var
        L_SalesAndRecvSetup: Record "Sales & Receivables Setup";
    begin
        L_SalesAndRecvSetup.Get();
        L_SalesAndRecvSetup.TestField("Due Date Buffer");
        Customer.SetRange("Date Filter");
        Customer.SetFilter("Date Filter", '..%1', CalcDate(Format(L_SalesAndRecvSetup."Due Date Buffer"), WorkDate()));
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