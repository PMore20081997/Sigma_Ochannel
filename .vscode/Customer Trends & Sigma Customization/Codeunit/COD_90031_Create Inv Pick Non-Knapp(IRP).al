codeunit 90031 "Create Inv Pick Non-Knapp(IRP)"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        WhseRequest: Record "Warehouse Request";
        L_Customer: Record Customer;
    begin
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.CalcFields(Shipped, "Inv. Pick Exist");
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        //L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());//Discussed with Team
        L_SalesHeader.SetRange(Shipped, false);
        L_SalesHeader.SetRange("Inv. Pick Exist", false);
        L_SalesHeader.SetRange("Web Order", true);
        if L_SalesHeader.FindSet() then begin
            repeat
                WhseRequest.Reset();
                WhseRequest.SetCurrentKey("Source Document", "Source No.");
                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Order");
                WhseRequest.SetRange("Source No.", L_SalesHeader."No.");
                REPORT.RunModal(REPORT::"Create Invt. Pick", false, false, WhseRequest);
                Commit();
            until L_SalesHeader.Next() = 0;
        end;
    end;
}