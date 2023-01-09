pageextension 90085 "Posted Whse. Rcpt Card" extends "Registered Pick"
{
    layout
    {
        addafter("Registering Date")
        {
            field("No. of Boxes"; Rec."No. of Boxes")
            {
                ApplicationArea = All;
            }
            field("Total weight (consignment)"; Rec."Total weight (consignment)")
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Code"; Rec."Shipping Agent Code")
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
            {
                ApplicationArea = All;
            }
        }
        addlast(General)
        {
            field("Trolley No."; Rec."Trolley No.")
            {
                ApplicationArea = All;
            }
            field("Trolley Closed"; Rec."Trolley Closed")
            {
                ApplicationArea = All;
            }
            field(SystemCreatedAt; Rec.SystemCreatedAt)
            {
                ApplicationArea = All;
            }
            field(CreateBy; GetUser(Rec.SystemCreatedBy))
            {
                Caption = 'Created By';
                ApplicationArea = All;
            }
        }
        addbefore(WhseActivityLines)
        {
            field(Comments; Rec.Comments)
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }
    actions
    {
        addafter("P&ick")
        {
            action("Print Label")
            {
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Report;
                trigger OnAction()
                var
                    RegWhseActLine: Record "Registered Whse. Activity Line";
                    L_ShipmentTracking: Record "Shipment Tracking";
                    L_ShipmentTracking2: Record "Shipment Tracking";
                    ShipmentLabel: Report "Courier Label";
                    ShipmentLabel2: Report "Courier Label - DHL";
                begin
                    if Rec."Shipping Agent Code" = 'APC' then begin
                        RegWhseActLine.Reset();
                        RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
                        RegWhseActLine.SetRange("No.", Rec."No.");
                        if RegWhseActLine.FindFirst() then begin
                            L_ShipmentTracking.Reset();
                            L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
                            L_ShipmentTracking.SetRange("Document No.", RegWhseActLine."Source No.");
                            L_ShipmentTracking.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                            if L_ShipmentTracking.FindSet() then begin
                                repeat
                                    L_ShipmentTracking2.Reset();
                                    L_ShipmentTracking2.SetRange("Shipping Agent Code", L_ShipmentTracking."Shipping Agent Code");
                                    L_ShipmentTracking2.SetRange("Document No.", L_ShipmentTracking."Document No.");
                                    L_ShipmentTracking2.SetRange("Tracking No.", L_ShipmentTracking."Tracking No.");
                                    if L_ShipmentTracking2.FindFirst() then begin
                                        Clear(ShipmentLabel);
                                        ShipmentLabel.SetTableView(L_ShipmentTracking2);
                                        ShipmentLabel.UseRequestPage(false);
                                        ShipmentLabel.Run();
                                    end;
                                until L_ShipmentTracking.Next() = 0;
                            end;
                        end;
                    end else
                        if Rec."Shipping Agent Code" = 'DHL' then begin
                            RegWhseActLine.Reset();
                            RegWhseActLine.SetRange("Activity Type", RegWhseActLine."Activity Type"::Pick);
                            RegWhseActLine.SetRange("No.", Rec."No.");
                            if RegWhseActLine.FindFirst() then begin
                                L_ShipmentTracking.Reset();
                                L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
                                L_ShipmentTracking.SetRange("Document No.", RegWhseActLine."Source No.");
                                L_ShipmentTracking.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                                if L_ShipmentTracking.FindSet() then begin
                                    repeat
                                        L_ShipmentTracking2.Reset();
                                        L_ShipmentTracking2.SetRange("Shipping Agent Code", L_ShipmentTracking."Shipping Agent Code");
                                        L_ShipmentTracking2.SetRange("Document No.", L_ShipmentTracking."Document No.");
                                        L_ShipmentTracking2.SetRange("Tracking No.", L_ShipmentTracking."Tracking No.");
                                        if L_ShipmentTracking2.FindFirst() then begin
                                            Clear(ShipmentLabel2);
                                            ShipmentLabel2.SetTableView(L_ShipmentTracking2);
                                            ShipmentLabel2.UseRequestPage(false);
                                            ShipmentLabel2.Run();
                                        end;
                                    until L_ShipmentTracking.Next() = 0;
                                end;
                            end;
                        end;


                end;
            }
        }
    }
    procedure GetUser(UserGUID: Guid): Text
    var
        User: Record User;
    begin
        User.Reset();
        User.SetRange("User Security ID", UserGUID);
        if User.FindFirst() then
            exit(User."Full Name");
    end;
}