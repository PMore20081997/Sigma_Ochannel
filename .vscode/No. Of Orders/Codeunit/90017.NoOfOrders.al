codeunit 90017 NoOfOrders
{
    SingleInstance = true;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnAfterCreateShptLineFromSalesLine', '', false, false)]
    local procedure OnAfterCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        WarehouseRequest: Record "Warehouse Request";
    begin
        WarehouseRequest.Reset();
        WarehouseRequest.SetRange("Source No.", SalesHeader."No.");
        WarehouseRequest.SetRange("Source Document", WarehouseRequest."Source Document"::"Sales Order");
        if WarehouseRequest.FindFirst() then begin
            WarehouseRequest."Shipment Created" := True;
            WarehouseRequest.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Warehouse Source Filter", 'OnBeforeSetTableView', '', false, false)]
    local procedure OnBeforeSetTableView(var WarehouseRequest: Record "Warehouse Request"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var PurchaseLine: Record "Purchase Line"; var TransferLine: Record "Transfer Line"; var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; var WarehouseSourceFilter: Record "Warehouse Source Filter"; var PurchaseHeader: Record "Purchase Header")
    begin
        WarehouseRequest.SetFilter("Shipment Created", '%1', false);
        NoOfOrderToProcess := WarehouseSourceFilter."No. Of Orders to Process";
        ServiceCode := WarehouseSourceFilter."Shipping Agent Service Filter";
        AgentCode := WarehouseSourceFilter."Shipping Agent Code Filter";
        CustomerCode := WarehouseSourceFilter."Sell-to Customer No. Filter";
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterSalesHeaderOnAfterGetRecord', '', false, false)]
    local procedure OnAfterSalesHeaderOnAfterGetRecord(SalesHeader: Record "Sales Header"; var SkipRecord: Boolean; var BreakReport: Boolean; var WarehouseRequest: Record "Warehouse Request")
    begin

        if (AgentCode = WarehouseRequest."Shipping Agent Code") and (CustomerCode = SalesHeader."Sell-to Customer No.") then begin
            if (ServiceCode = WarehouseRequest."Shipping Agent Service Code") or (ServiceCode = '') then begin
                if NoOfOrderToProcess <= 0 then
                    BreakReport := true;
                NoOfOrderToProcess -= 1;
            end;
        end;
    end;

    procedure UpdateWarehouseRequestOnDeleteWhseShipmentLines(var WhseShipmentLine: Record "Warehouse Shipment Line"; Created: Boolean)
    var
        WarehouseRequest: Record "Warehouse Request";
    begin
        WarehouseRequest.Reset();
        WarehouseRequest.SetRange(WarehouseRequest."Source No.", WhseShipmentLine."Source No.");
        WarehouseRequest.SetFilter(WarehouseRequest."Shipment Created", '%1', true);
        WarehouseRequest.SetFilter(WarehouseRequest."Completely Handled", '%1', false);
        if WarehouseRequest.FindFirst() then begin
            WarehouseRequest."Shipment Created" := Created;
            WarehouseRequest.modify();
        end;
    end;

    /* [EventSubscriber(ObjectType::Table, Database::"Warehouse Shipment Header", 'OnBeforeWhseShptLineDelete', '', false, false)]
     local procedure OnBeforeWhseShptLineDelete(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
     begin
         UpdateWarehouseRequestOnDeleteWhseShipmentLines(WarehouseShipmentLine, false);
     end;*/



    var
        NoOfOrderToProcess: Integer;
        ServiceCode: code[100];
        AgentCode: code[100];
        CustomerCode: Code[100];
}
