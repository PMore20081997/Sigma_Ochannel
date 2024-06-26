codeunit 90025 "Manual/KNAAP SO Process"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        WhseRequest: Record "Warehouse Request";
        L_SalesLine: Record "Sales Line";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
    begin
        //Update Variant Code++
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        if L_SalesHeader.FindSet() then begin
            UdateVariantonSO.UpdateVariantOnSalesOrder(L_SalesHeader);
            Commit();
        end;

        //Release Sales Order
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
        RecRef.GetTable(L_SalesHeader);
        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
        Commit();

        //Create InventoryPick
        L_SalesHeader.Reset();
        L_SalesHeader.CalcFields("Inv. Pick Exist");
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetRange("Inv. Pick Exist", false);
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