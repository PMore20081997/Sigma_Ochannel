codeunit 90084 "Archive Shipment Tracking"
{
    TableNo = 472;
    trigger OnRun()
    begin
        OchannelSetup.Get();
        ShipmentTracking.Reset();
        ShipmentTracking.SetRange("Document Type", ShipmentTracking."Document Type"::Order);
        ShipmentTracking.SetFilter("Entry Created", '<>%1', 0D);
        ShipmentTracking.SetCurrentKey("Entry Created");
        ShipmentTracking.SetAscending("Entry Created", true);
        if ShipmentTracking.FindFirst() then begin
            ShipmentTracking2.Reset();
            ShipmentTracking2.SetRange("Document Type", ShipmentTracking."Document Type");
            ShipmentTracking2.SetFilter("Entry Created", '%1..%2', ShipmentTracking."Entry Created", CalcDate('<2W>', ShipmentTracking."Entry Created"));
            if ShipmentTracking2.FindSet() then begin
                repeat
                    if OchannelSetup."Delete Shipment Tracking" = true then begin
                        ShipmentTracking2.Delete();
                    end else begin
                        ArchiveShipmentTracking.Init();
                        ArchiveShipmentTracking."Entry No." := ShipmentTracking2."Entry No.";
                        ArchiveShipmentTracking."Document Type" := ShipmentTracking2."Document Type";
                        ArchiveShipmentTracking."Document No." := ShipmentTracking2."Document No.";
                        ArchiveShipmentTracking."Shipping Agent Code" := ShipmentTracking2."Shipping Agent Code";
                        ArchiveShipmentTracking."Shipping Agent Service Code" := ShipmentTracking2."Shipping Agent Service Code";
                        ArchiveShipmentTracking."Agent Shipment No." := ShipmentTracking2."Agent Shipment No.";
                        ArchiveShipmentTracking."Tracking No." := ShipmentTracking2."Tracking No.";
                        ArchiveShipmentTracking.Weight := ShipmentTracking2.Weight;
                        ArchiveShipmentTracking."Shipment Label Handled" := ShipmentTracking2."Shipment Label Handled";
                        ArchiveShipmentTracking."Entry Created" := ShipmentTracking2."Entry Created";
                        ShipmentTracking2.CalcFields(Label, "A6 Label1");
                        ArchiveShipmentTracking.Label := ShipmentTracking2.Label;
                        ArchiveShipmentTracking."A6 Label1" := ShipmentTracking2."A6 Label1";
                        ArchiveShipmentTracking.Insert(true);
                        ShipmentTracking2.Delete();
                    end;
                until ShipmentTracking2.Next() = 0;
            end;
        end;
    end;

    var
        ShipmentTracking: Record "Shipment Tracking";
        ShipmentTracking2: Record "Shipment Tracking";

        ArchiveShipmentTracking: Record "Archive Shipment Tracking";
        OchannelSetup: Record "General Setup - Channels";

}