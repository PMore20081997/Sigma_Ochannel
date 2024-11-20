codeunit 90027 "Create Inv Pick Non-Knapp"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        WhseRequest: Record "Warehouse Request";
        L_Customer: Record Customer;
    begin
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.CalcFields(Shipped);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        //L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());//Discussed with Team
        L_SalesHeader.SetRange(Shipped, false);
        if L_SalesHeader.FindSet() then begin
            repeat
                L_Customer.Reset();
                L_Customer.SetRange("No.", L_SalesHeader."Sell-to Customer No.");
                if L_Customer.FindFirst() then begin
                    if L_Customer.Blocked = L_Customer.Blocked::" " then begin
                        WhseRequest.Reset();
                        WhseRequest.SetCurrentKey("Source Document", "Source No.");
                        WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Order");
                        WhseRequest.SetRange("Source No.", L_SalesHeader."No.");
                        REPORT.RunModal(REPORT::"Create Invt. Pick", false, false, WhseRequest);
                        Commit();
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;
}