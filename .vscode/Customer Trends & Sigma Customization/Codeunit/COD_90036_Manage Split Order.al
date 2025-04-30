codeunit 90036 "Manage Split Order"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeUpdateLocationCode, '', false, false)]
    local procedure OnBeforeUpdateLocationCode(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if SalesHeader."Reference Sales Order" <> '' then
            IsHandled := true;
    end;
}