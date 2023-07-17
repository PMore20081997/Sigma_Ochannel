codeunit 90006 "Courier Integration"
{
    trigger OnRun()
    begin

    end;

    procedure InsertInShipmentTracking(P_WebOrderHeader: Record "Interim Sales Header"; Base64String: BigText)
    var
        ShipmentTracking: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";

    begin
        ShipmentTracking.INIT;
        ShipmentTracking.VALIDATE("Document Type", P_WebOrderHeader."Document Type");
        ShipmentTracking.VALIDATE("Document No.", P_WebOrderHeader."No.");
        ShipmentTracking.VALIDATE("Shipping Agent Code", P_WebOrderHeader."Shipping Agent Code");
        ShipmentTracking.VALIDATE("Shipping Agent Service Code", P_WebOrderHeader."Shipping Agent Service Code");
        ShipmentTracking.VALIDATE(Weight, P_WebOrderHeader."Total Weight");
        ShipmentTracking.VALIDATE("Agent Shipment No.", P_WebOrderHeader."Package Tracking No.");
        ShipmentTracking.VALIDATE("Tracking No.", P_WebOrderHeader."Package Tracking No.");
        IF RecShipmentTracking.FINDLAST THEN
            ShipmentTracking."Entry No." := RecShipmentTracking."Entry No." + 1
        ELSE
            ShipmentTracking."Entry No." := 1;
        if (Base64String.Length > 0) then begin

        end;
        ShipmentTracking.Insert(True);
    end;

    PROCEDURE GetNavShippingAgentFromWebShipping(P_ChannelCode: Code[20]; P_WebShippingAgent: Text[50]; P_WebSipmentMethod: Code[50]; VAR P_ShippingRule: Record "Shipping Rule");
    var
    BEGIN
        P_ShippingRule.RESET;
        P_ShippingRule.SETCURRENTKEY("Channel Code", "Web Shipping Agent", "Web Shipment Method", Preference);
        P_ShippingRule.SETRANGE("Channel Code", P_ChannelCode);
        IF P_WebShippingAgent <> '' THEN
            P_ShippingRule.SETRANGE("Web Shipping Agent", P_WebShippingAgent);
        IF P_WebSipmentMethod <> '' THEN
            P_ShippingRule.SETRANGE("Web Shipment Method", P_WebSipmentMethod);
        IF P_ShippingRule.FINDFIRST THEN;
    END;

    var
        myInt: Integer;
}