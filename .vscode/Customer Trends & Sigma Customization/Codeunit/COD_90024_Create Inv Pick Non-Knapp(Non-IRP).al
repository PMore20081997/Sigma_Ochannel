codeunit 90024 "Create InvPick Non-(KNAP&IRP)"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        WhseRequest: Record "Warehouse Request";
        L_Customer: Record Customer;
        L_SplitSalesHeader: Record "Sales Header";
        L_CheckSplitOrder: Report "Check & Split Order";
        L_SalesLine: Record "Sales Line";
    begin
        //Split The Orders(KNAPP OR Non-KNAPP)+++
        Clear(L_CheckSplitOrder);
        L_SalesHeader.CalcFields("Drop/Special Order", "Special Order", "Inv. Pick Exist", Shipped);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        L_SalesHeader.SetRange("Web Order", false);
        L_SalesHeader.SetRange("Drop/Special Order", false);
        L_SalesHeader.SetRange("Special Order", false);
        L_SalesHeader.SetRange("Inv. Pick Exist", false);
        L_SalesHeader.SetRange(Shipped, false);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetRange("Check & Split Order", false);
        L_SalesHeader.SetRange("No.", '9000044326');
        if L_SalesHeader.FindSet() then begin
            repeat
                L_SplitSalesHeader.Reset();
                L_SplitSalesHeader.SetRange("No.", L_SalesHeader."No.");
                L_SplitSalesHeader.SetRange("Document Type", L_SalesHeader."Document Type");
                if L_SplitSalesHeader.FindFirst() then begin
                    L_CheckSplitOrder.SetTableView(L_SplitSalesHeader);
                    L_CheckSplitOrder.UseRequestPage(false);
                    L_CheckSplitOrder.Run();
                end;
            until L_SalesHeader.Next() = 0;
        end;
        Commit();
        Sleep(10);



        //Create Inve Picks++
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.CalcFields(Shipped, "Inv. Pick Exist");
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        //L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-1D', WorkDate()), WorkDate());//Discussed with Team
        L_SalesHeader.SetRange(Shipped, false);
        L_SalesHeader.SetRange("Inv. Pick Exist", false);
        L_SalesHeader.SetRange("Web Order", false);
        L_SalesHeader.SetRange("No.", '9000044326');
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