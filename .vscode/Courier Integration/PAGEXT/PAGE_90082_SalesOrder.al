pageextension 90082 "Sales Order Card Ext" extends "Sales Order"
{
    actions
    {
        addafter(Release)
        {
            action(UpdateDate)
            {
                Image = UpdateDescription;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    ShipmentTracking: Record "Shipment Tracking";
                    SalesShipHeader: Record "Sales Shipment Header";
                begin
                    ShipmentTracking.Reset();
                    ShipmentTracking.SetRange("Document Type", ShipmentTracking."Document Type"::Order);
                    ShipmentTracking.SetRange("Entry Created", 0D);
                    if ShipmentTracking.FindSet() then begin
                        repeat
                            SalesShipHeader.Reset();
                            SalesShipHeader.SetRange("Order No.", ShipmentTracking."Document No.");
                            if SalesShipHeader.FindFirst() then begin
                                ShipmentTracking."Entry Created" := SalesShipHeader."Posting Date";
                                ShipmentTracking.Modify();
                            end;
                        until ShipmentTracking.Next() = 0;
                        Message('Completed');
                    end;
                end;

            }
            action(ArchiveShipment)
            {
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    ShipmentTracking: Record "Shipment Tracking";
                    ShipmentTracking2: Record "Shipment Tracking";
                    ArchiveShipmentTracking: Record "Archive Shipment Tracking";
                begin
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
                            until ShipmentTracking2.Next() = 0;
                        end;

                    end;
                end;
            }
            action("Shipment Tracking")
            {
                Image = Track;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_ShipTrack: Record "Shipment Tracking";
                    L_ShipPage: Page "Shipment Tracking";
                begin
                    Clear(L_ShipPage);
                    L_ShipTrack.Reset();
                    L_ShipTrack.SetRange("Document No.", Rec."No.");
                    if L_ShipTrack.FindFirst() then begin
                        L_ShipPage.SetTableView(L_ShipTrack);
                        L_ShipPage.Run();
                    end;
                end;
            }
        }
    }
}