codeunit 90039 "Update Channel Customer"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    local procedure CheckAndUpdateWebCustomer()
    var
        L_InterimCustomer: Record "Interim Customer";
        L_Customer: Record Customer;
        L_Modified: Boolean;
    begin
        L_InterimCustomer.Reset();
        if L_InterimCustomer.FindSet() then begin
            repeat
                Clear(L_Modified);
                L_Customer.Reset();
                L_Customer.SetRange("No.", L_InterimCustomer."No.");
                if L_Customer.FindFirst() then begin
                    if L_Customer."Customer Price Group" <> L_InterimCustomer."Customer Price Group 1" then begin
                        L_InterimCustomer."Customer Price Group 1" := L_Customer."Customer Price Group";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 2" <> L_Customer."Customer Price Group 2" then begin
                        L_InterimCustomer."Customer Price Group 2" := L_Customer."Customer Price Group 2";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 3" <> L_Customer."Customer Price Group 3" then begin
                        L_InterimCustomer."Customer Price Group 3" := L_Customer."Customer Price Group 3";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 4" <> L_Customer."Customer Price Group 4" then begin
                        L_InterimCustomer."Customer Price Group 4" := L_Customer."Customer Price Group 4";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 5" <> L_Customer."Customer Price Group 5" then begin
                        L_InterimCustomer."Customer Price Group 5" := L_Customer."Customer Price Group 5";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 6" <> L_Customer."Customer Price Group 6" then begin
                        L_InterimCustomer."Customer Price Group 6" := L_Customer."Customer Price Group 6";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 7" <> L_Customer."Customer Price Group 7" then begin
                        L_InterimCustomer."Customer Price Group 7" := L_Customer."Customer Price Group 7";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 8" <> L_Customer."Customer Price Group 8" then begin
                        L_InterimCustomer."Customer Price Group 8" := L_Customer."Customer Price Group 8";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 9" <> L_Customer."Customer Price Group 9" then begin
                        L_InterimCustomer."Customer Price Group 9" := L_Customer."Customer Price Group 9";
                        L_Modified := true;
                    end;

                    if L_InterimCustomer."Customer Price Group 10" <> L_Customer."Customer Price Group 10" then begin
                        L_InterimCustomer."Customer Price Group 10" := L_Customer."Customer Price Group 10";
                        L_Modified := true;
                    end;

                    if L_Modified then begin
                        L_InterimCustomer."Customer Sync" := false;
                        L_InterimCustomer.Modify();
                    end;
                end;
            until L_InterimCustomer.Next() = 0;
        end;
        Message('Process Completed');
    end;
}