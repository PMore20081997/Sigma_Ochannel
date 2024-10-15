codeunit 90203 "Manage Time duration"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforePerformManualReleaseProcedure', '', false, false)]
    local procedure OnBeforePerformManualReleaseProcedure(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        L_SalesHeader: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        RecUserSetup: Record "User Setup";
        AllEvent: Codeunit "All Event";
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        L_SalesHeader.SetRange("No.", SalesHeader."No.");
        if L_SalesHeader.FindFirst() then begin
            if L_SalesHeader."Web Order" = true then begin
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
                L_SalesHeader.CalcFields("Sales Quota Approval");
                if L_SalesHeader."Sales Quota Approval" = true then
                    IsHandled := true;
            end;
        end;
    end;
}