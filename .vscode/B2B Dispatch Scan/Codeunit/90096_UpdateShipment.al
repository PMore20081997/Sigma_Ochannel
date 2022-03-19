codeunit 90096 "Update shipment"
{

    Permissions = tabledata "Registered Whse. Activity Hdr." = RIMD;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterRegisteredWhseActivHeaderInsert', '', true, true)]
    local procedure OnAfterRegisteredWhseActivHeaderInsert(var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        L_WAL: Record "Warehouse Activity Line";
    begin
        L_WAL.Reset();
        L_WAL.SetRange("Activity Type", L_WAL."Activity Type"::Pick);
        L_WAL.SetRange("Whse. Document Type", L_WAL."Whse. Document Type"::Shipment);
        L_WAL.SetRange("No.", RegisteredWhseActivityHdr."Whse. Activity No.");
        if L_WAL.FindFirst() then begin
            RegisteredWhseActivityHdr.Validate("Trolley No.", L_WAL."Whse. Document No.");
            RegisteredWhseActivityHdr.Modify();
        end;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterWhseShptLineModify', '', true, true)]
    local procedure OnAfterWhseShptLineModify(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
        WarehouseShipmentLine.Validate("Qty. to Ship", 0);
        WarehouseShipmentLine.Modify();
    end;



}