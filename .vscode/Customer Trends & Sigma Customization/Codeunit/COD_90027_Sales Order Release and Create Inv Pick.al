// codeunit 90027 "Release & Create Inv Pick"
// {
//     trigger OnRun()
//     var
//         L_SalesHeader: Record "Sales Header";
//         WhseRequest: Record "Warehouse Request";
//     begin
//         //Release Sales Order
//         L_SalesHeader.Reset();
//         L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
//         L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
//         L_SalesHeader.SetRange("Web Order", true);
//         L_SalesHeader.PerformManualRelease(L_SalesHeader);

//         //Create InventoryPick
//         WhseRequest.Reset();
//         WhseRequest.SetCurrentKey("Source Document", "Source No.");
//         WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Order");
//         REPORT.RunModal(REPORT::"Create Invt. Pick", false, false, WhseRequest);
//     end;

//     var
//         myInt: Integer;


// }