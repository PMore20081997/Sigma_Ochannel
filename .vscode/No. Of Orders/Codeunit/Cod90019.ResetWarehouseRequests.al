codeunit 90019 ResetWarehouseRequests
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        RunType := Rec."Parameter String";

        CASE RunType OF
            CleanRequests:
                begin
                    CleanRequestsProcess();
                    MESSAGE('Completed Cleanup');
                end;
        end;
    End;

    local procedure CleanRequestsProcess()
    var
        WarehouseRequestsList: Record "Warehouse Request";
        SalesOrders: Record "Sales Header";
        WarehouseShipmentLines: Record "Warehouse Shipment Line";
        SalesCode: Codeunit "Whse.-Sales Release";
        SaleOrder: Record "Sales Header";
    begin
        SalesOrders.Reset();
        SalesOrders.SetRange("Completely Shipped", false);
        SalesOrders.LoadFields("No.","Document Type");
        if SalesOrders.FindSet() then begin
            repeat
                WarehouseShipmentLines.Reset();
                WarehouseShipmentLines.SetRange("Source Document", WarehouseShipmentLines."Source Document"::"Sales Order");
                WarehouseShipmentLines.SetFilter("Source No.", SalesOrders."No.");

                if WarehouseShipmentLines.IsEmpty then begin
                    // no shipment found now check warehouse request
                    WarehouseRequestsList.SetRange(WarehouseRequestsList."Source Document", WarehouseRequestsList."Source Document"::"Sales Order");
                    WarehouseRequestsList.SetFilter("Source No.", SalesOrders."No.");

                    If WarehouseRequestsList.IsEmpty then begin
                        if SaleOrder.Get(SalesOrders."Document Type",SalesOrders."No.") then
                        SalesCode.Release(SalesOrders);
                    end;
                    if WarehouseRequestsList.FindSet() then begin
                        repeat
                            WarehouseRequestsList."Shipment Created" := false;
                            WarehouseRequestsList.Modify();
                        until WarehouseRequestsList.Next() = 0;
                    end;

                end;

            until SalesOrders.Next() = 0;
        end;

    end;

    var

        RunType: Text;
        CleanRequests: label 'CleanRequests';
}
