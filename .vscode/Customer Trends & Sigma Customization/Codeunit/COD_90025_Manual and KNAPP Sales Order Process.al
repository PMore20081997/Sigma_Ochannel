codeunit 90025 "Manual/KNAAP SO Process"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
    begin
        case Rec."Parameter String" of
            KnappOrdersLabel:
                begin
                    UpdateKnappOrders();
                end;
            NonKnappOrderLabel:
                begin
                    UpdateNonKnappOrders();
                end;
            KnappNonKnappOrdersLabel:
                begin
                    UpdateKnappAndNonKnappVariant();
                end;
        end;
    end;

    var
        KnappOrdersLabel: Label 'KnappOrders';
        NonKnappOrderLabel: Label 'NonKnappOrders';
        KnappNonKnappOrdersLabel: Label 'KnappNonKnappOrders';

    local procedure UpdateKnappOrders()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        Counter: Integer;
    begin
        Clear(Counter);
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetRange("Knapp Order", true);
        L_SalesHeader.SetFilter("Document Date", '%1', WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                Counter += 1;
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Update Variant Code
                    UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    Commit();

                    //Release Sales Order
                    if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                        RecRef.GetTable(Rec_SalesHeader);
                        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
                    end;

                    //Code to process only 500 Orders then exit the code
                    if Counter = 500 then
                        exit;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;

    local procedure UpdateNonKnappOrders()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
    begin
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetFilter("Document Date", '%1', WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Update Variant Code
                    UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    Commit();

                    //Release Sales Order
                    if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                        RecRef.GetTable(Rec_SalesHeader);
                        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
                    end;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;

    local procedure UpdateKnappAndNonKnappVariant()
    var
        L_SalesHeader: Record "Sales Header";
        Rec_SalesHeader: Record "Sales Header";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
        UdateVariantonSO: Codeunit "Udate Variant on SO";
        ApprovalMgmt: Codeunit "Approvals Mgmt.";
        Counter: Integer;
    begin
        Clear(Counter);
        Clear(L_SalesHeader);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetFilter("Document Date", '%1..%2', CalcDate('-3D', WorkDate()), WorkDate());
        if L_SalesHeader.FindSet() then begin
            repeat
                Counter += 1;
                Rec_SalesHeader.Reset();
                Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                if Rec_SalesHeader.FindFirst() then begin
                    //Update Variant Code
                    UdateVariantonSO.UpdateVariantOnSalesOrder(Rec_SalesHeader);
                    Commit();

                    //Release Sales Order
                    if ApprovalMgmt.IsSalesHeaderPendingApproval(Rec_SalesHeader) = false then begin
                        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
                        RecRef.GetTable(Rec_SalesHeader);
                        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
                    end;

                    //Code to process only 500 Orders then exit the code
                    if Counter = 500 then
                        exit;
                end;
            until L_SalesHeader.Next() = 0;
        end;
    end;
}