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
        tes: Page "Posted Purchase Rcpt. Subform";

    procedure CheckCreditLimitAndOverDue(_CustomerNo: Code[20]) CrditAndOverDueExceed: Boolean
    var
        L_CheckCreditLimit: Page "Check Credit Limit";
        L_Customer: Record Customer;
    begin
        Clear(G_CalledFromIRPCreation);
        Clear(G_ExitValue);

        G_CalledFromIRPCreation := true;
        L_CheckCreditLimit.ShowWarning(_CustomerNo, 0, 0, true);
        if G_ExitValue = 0 then
            CrditAndOverDueExceed := false
        else begin
            L_Customer.Reset();
            L_Customer.SetRange("No.", _CustomerNo);
            if L_Customer.FindFirst() then begin
                if (L_Customer."Exempt from Overdue check" = false) AND (L_Customer.Hospital = false) then begin
                    CrditAndOverDueExceed := true;
                end else begin
                    if (L_Customer."Exempt from Overdue check" = true) AND (L_Customer.Hospital = true) then begin
                        CrditAndOverDueExceed := false;
                    end else begin
                        if (L_Customer."Exempt from Overdue check" = true) AND (L_Customer.Hospital = false) then begin
                            //G_ExitValue = 1 means credit limit. G_ExitValue = 3 means credit limit and over due++
                            if (G_ExitValue = 1) OR (G_ExitValue = 3) then begin
                                CrditAndOverDueExceed := true;
                            end else begin
                                CrditAndOverDueExceed := false;
                            end;
                        end else begin
                            if (L_Customer."Exempt from Overdue check" = false) AND (L_Customer.Hospital = true) then begin
                                //G_ExitValue = 2 means over due. G_ExitValue = 3 means credit limit and over due++
                                if (G_ExitValue = 2) OR (G_ExitValue = 3) then begin
                                    CrditAndOverDueExceed := true;
                                end else begin
                                    CrditAndOverDueExceed := false;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
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