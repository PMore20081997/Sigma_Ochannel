codeunit 90090 "Shipment Tracking Insertion"
{
    //code to store delivery/Return lable and tracking no into shipment tracking table
    procedure InsertShipmentTracking(Trackingnumber: Text[30]; Base64Label: Text; Base64ReturnLabel: Text; CarrierName: Text[10]; var Temp_SalesHeader: Record "Sales Header" temporary)
    var
        ShipmentTracking: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
        Base64Convert: Codeunit "Base64 Convert";
        OutStm: OutStream;
        OutStm1: OutStream;
    begin
        ShipmentTracking.Init();
        ShipmentTracking.VALIDATE("Document Type", ShipmentTracking."Document Type"::Order);
        if Temp_SalesHeader.FindFirst() then;
        ShipmentTracking.Validate("Document No.", Temp_SalesHeader."No.");

        if CarrierName = '' then begin
            ShipmentTracking.Validate("Shipping Agent Code", Temp_SalesHeader."Shipping Agent Code");
        end
        else begin
            ShipmentTracking.Validate("Shipping Agent Code", CarrierName);
        end;

        ShipmentTracking.VALIDATE("Shipping Agent Service Code", Temp_SalesHeader."Shipping Agent Service Code");
        ShipmentTracking.Validate("Entry Created", Today);

        IF RecShipmentTracking.FINDLAST THEN
            ShipmentTracking."Entry No." := RecShipmentTracking."Entry No." + 1
        ELSE
            ShipmentTracking."Entry No." := 1;

        if Trackingnumber <> '' then begin
            ShipmentTracking.VALIDATE("Tracking No.", TrackingNumber);
        end;

        IF (Base64Label <> '') THEN BEGIN
            ShipmentTracking.CalcFields(Label);
            ShipmentTracking.Label.CreateOutStream(OutStm);
            Base64Convert.FromBase64(Base64Label, OutStm);
        END;

        if (Base64ReturnLabel <> '') then begin
            ShipmentTracking.CalcFields("A6 Label1");
            ShipmentTracking."A6 Label1".CreateOutStream(OutStm1);
            Base64Convert.FromBase64(Base64ReturnLabel, OutStm1);
        end;

        ShipmentTracking.INSERT;
    end;
}