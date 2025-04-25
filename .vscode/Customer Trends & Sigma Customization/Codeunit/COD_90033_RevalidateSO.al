codeunit 90033 "Revalidate Sales Order"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        L_SalesLine: Record "Sales Line";
        NoSeriesManagement: Codeunit "No. Series";
        Rec_SalesLine: Record "Sales Line";
        CU_ReleaseSalesDoc: Codeunit "Release Sales Document";
        KnappOrder: Boolean;
        ItemList: List of [Text];
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        L_Location: Record Location;

        MinOrder_Header: Record "Sales Header";
        L_SumMin: Decimal;
        L_RequiredRelease: Boolean;
        L_ReleaseSalesHeader: Record "Sales Header";
    begin
        Commit();
        L_SalesHeader.Reset();
        L_SalesHeader.CalcFields("Sent to Knapp");
        L_SalesHeader.SetRange("Knapp Order", true);
        L_SalesHeader.SetFilter("Shipment Date", '%1..%2', CalcDate('-1D', WorkDate()), 20990101D);
        L_SalesHeader.SetRange("Sent to Knapp", false);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetFilter(Status, '%1|%2', L_SalesHeader.Status::Open, L_SalesHeader.Status::Released);
        if L_SalesHeader.FindSet() then begin
            repeat
                Clear(L_RequiredRelease);
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type");
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Open SO
                    if Rec_SalesHeader.Status = Rec_SalesHeader.Status::Released then begin
                        Rec_SalesHeader.PerformManualReopen(Rec_SalesHeader);
                        L_RequiredRelease := true;
                    end;

                    //Revalidate Variant++
                    UdateVariantonSO.RevalidateVariantOnSalesOrder(Rec_SalesHeader);

                    //Send for Release order if Approval not required
                    if L_RequiredRelease = true then begin
                        L_ReleaseSalesHeader.Reset();
                        L_ReleaseSalesHeader.SetRange("No.", Rec_SalesHeader."No.");
                        L_ReleaseSalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type");
                        if L_ReleaseSalesHeader.FindFirst() then begin
                            CU_ReleaseSalesDoc.PerformManualRelease(L_ReleaseSalesHeader);
                            Commit();
                        end;
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
        Message('Process Completed');
    end;
}