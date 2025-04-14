//This is only check credit limit and overdue balance at the creation of IRP order++
//Dont use this code unit for any customization++
codeunit 90034 "Check Crdit/OverDue for IRP"
{
    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;
        G_CalledFromIRPCreation: Boolean;
        G_ExitValue: Integer;

    procedure CheckCreditLimitAndOverDue(_CustomerNo: Code[20]) CrditAndOverDueExceed: Boolean
    var
        L_CheckCreditLimit: Page "Check Credit Limit";
    begin
        Clear(G_CalledFromIRPCreation);
        Clear(G_ExitValue);

        G_CalledFromIRPCreation := true;
        L_CheckCreditLimit.ShowWarning(_CustomerNo, 0, 0, true);
        if G_ExitValue = 0 then
            CrditAndOverDueExceed := false
        else
            CrditAndOverDueExceed := true;
    end;


    [EventSubscriber(ObjectType::Page, Page::"Check Credit Limit", OnShowWarningOnBeforeExitValue, '', false, false)]
    local procedure OnShowWarningOnBeforeExitValue(ExitValue: Integer; var Customer: Record Customer)
    begin
        if G_CalledFromIRPCreation = true then begin
            G_ExitValue := ExitValue;
        end;
        //CLear Variable++++
        Clear(G_CalledFromIRPCreation);
    end;
}