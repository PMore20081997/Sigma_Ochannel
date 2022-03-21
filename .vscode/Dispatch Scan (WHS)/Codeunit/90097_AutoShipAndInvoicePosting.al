codeunit 90097 "Auto Ship And Invoice Posting"
{
    Permissions = tabledata "Warehouse Shipment Header" = RIMD;

    trigger OnRun()
    begin
        ClearRemarks();
        AutoPostShipInvoice();
    end;

    local procedure AutoPostShipInvoice()
    var
        L_WareShipmentLine: Record "Warehouse Shipment Line";
    begin
        G_WareShipment.Reset();
        G_WareShipment.SetFilter(Remarks, '', '');
        if G_WareShipment.FindSet() then begin
            repeat
                L_WareShipmentLine.Reset();
                L_WareShipmentLine.SetRange("No.", G_WareShipment."No.");
                L_WareShipmentLine.SetFilter("Qty. to Ship", '>%1', 0);
                if L_WareShipmentLine.FindSet() then begin
                    Commit();
                    if CODEUNIT.Run(CODEUNIT::"Whse.-Post Shipment", L_WareShipmentLine) = true then begin
                    end else begin
                        Commit();
                        if G_WareShipment.Remarks = '' then begin
                            G_WareShipment.Remarks := GetLastErrorText();
                            G_WareShipment.Modify(true);
                        end;
                    end;
                end;
            until G_WareShipment.Next() = 0;
        end;
    end;



    var
        G_WareShipment: Record "Warehouse Shipment Header";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Shipment (Yes/No)", 'OnBeforeConfirmWhseShipmentPost', '', true, true)]
    local procedure OnBeforeConfirmWhseShipmentPost(var WhseShptLine: Record "Warehouse Shipment Line"; var HideDialog: Boolean; var Invoice: Boolean; var IsPosted: Boolean; var Selection: Integer)
    begin
        Selection := 2;
    end;

    local procedure ClearRemarks()
    begin
        G_WareShipment.Reset();
        G_WareShipment.SetRange(Remarks, '<>%1', '');
        if G_WareShipment.FindSet() then begin
            repeat
                G_WareShipment.Validate(Remarks, '');
                G_WareShipment.Modify(true);
            until G_WareShipment.Next() = 0;
        end;
    end;
}