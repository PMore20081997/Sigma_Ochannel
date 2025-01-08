codeunit 90203 "Manage Time duration"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;



    //Sales Quota Check only for Web Order = true++
    //For web Order = false Sales quota managed at the time of insert quantity on SO line++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforePerformManualReleaseProcedure', '', false, false)]
    local procedure OnBeforePerformManualReleaseProcedure(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        L_SalesHeader: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        RecUserSetup: Record "User Setup";
        AllEvent: Codeunit "All Event";
        CheckCreditLimit: codeunit "Cust-Check Cr. Limit";
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        L_SalesHeader.SetRange("No.", SalesHeader."No.");
        if L_SalesHeader.FindFirst() then begin
            if L_SalesHeader."Document Type" = L_SalesHeader."Document Type"::Order then begin
                if L_SalesHeader."Web Order" = true then begin
                    //Credit Limit++
                    L_SalesHeader."Credit Limit Approval" := CheckCreditLimit.SalesHeaderCheck(L_SalesHeader);
                    L_SalesHeader.Modify();
                    if L_SalesHeader."Credit Limit Approval" = true then
                        IsHandled := true;



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

                                        L_SalesHeader.CalcFields("Sales Quota Approval");
                                        if L_SalesHeader."Sales Quota Approval" = true then
                                            IsHandled := true;
                                    END;
                                END ELSE BEGIN
                                    AllEvent.CheckMaxOrderQty2(L_SalesLine);
                                    L_SalesLine.Modify();

                                    L_SalesHeader.CalcFields("Sales Quota Approval");
                                    if L_SalesHeader."Sales Quota Approval" = true then
                                        IsHandled := true;
                                END;
                            end;
                        until L_SalesLine.Next() = 0;
                    end;
                end else begin
                    //Credit Limit++
                    if L_SalesHeader."Credit Limit Approval" = true then
                        IsHandled := true;

                    //Sales Quota++
                    L_SalesHeader.CalcFields("Sales Quota Approval");
                    if L_SalesHeader."Sales Quota Approval" = true then
                        IsHandled := true;
                end;
            end;
        end;
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
}