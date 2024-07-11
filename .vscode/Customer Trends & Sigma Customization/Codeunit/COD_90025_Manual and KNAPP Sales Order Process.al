codeunit 90025 "Manual/KNAAP SO Process"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        WhseRequest: Record "Warehouse Request";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
    begin
        //Update Variant Code++
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        if L_SalesHeader.FindSet() then begin
            repeat
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    Commit();

                    //Release Sales Order
                    if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                        RecRef.GetTable(Rec_SalesHeader);
                        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");

                        //Create InventoryPick
                        Clear(Rec_SalesHeader);
                        Rec_SalesHeader.Reset();
                        Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                        Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                        if Rec_SalesHeader.FindFirst() then begin
                            Rec_SalesHeader.CalcFields("Inv. Pick Exist");
                            if (Rec_SalesHeader."Inv. Pick Exist" = false) and (Rec_SalesHeader.Status = Rec_SalesHeader.Status::Released) and (Rec_SalesHeader."Knapp Order" = false) then begin
                                WhseRequest.Reset();
                                WhseRequest.SetCurrentKey("Source Document", "Source No.");
                                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Order");
                                WhseRequest.SetRange("Source No.", Rec_SalesHeader."No.");
                                REPORT.RunModal(REPORT::"Create Invt. Pick", false, false, WhseRequest);
                                Commit();
                            end;
                        end;
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;
}