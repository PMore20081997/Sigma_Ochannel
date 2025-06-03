codeunit 90037 GLNValidation
{
    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    var
        Callfrom: Option customer,vendor;

    [EventSubscriber(ObjectType::Table, Database::Customer, OnBeforeValidateEvent, 'GLN', false, false)]
    local procedure CustGLN_OnBeforeValidateEvent()
    begin
        Clear(Callfrom);
        Callfrom := Callfrom::customer;

    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnBeforeValidateEvent, 'GLN', false, false)]
    local procedure VendorGLN_OnBeforeValidateEvent()
    begin
        Clear(Callfrom);
        Callfrom := Callfrom::vendor;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GLN Calculator", OnBeforeIsValidCheckDigit, '', false, false)]
    local procedure OnBeforeIsValidCheckDigit(var IsHandled: Boolean; var IsValid: Boolean; ExpectedSize: Integer; GLNValue: Code[20])
    begin
        if (Callfrom = Callfrom::customer) or (Callfrom = Callfrom::vendor) then begin
            if StrLen(GLNValue) = ExpectedSize then begin
                IsValid := true;
                IsHandled := true;
            end;
        end;
        Clear(Callfrom);
    end;
}