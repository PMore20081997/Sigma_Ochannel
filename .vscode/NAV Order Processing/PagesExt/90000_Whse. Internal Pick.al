pageextension 90010 "Ext. Whse. Internal Pick" extends "Whse. Internal Pick"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Trolley No."; Rec."Trolley No.")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addfirst(processing)
        {
            action("Print Delivery Note")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    R_DeliveryNote: Report 90072;
                begin
                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("Destination Doc Type", L_InterimSalesHeader."Destination Doc Type"::"Internal Pick");
                    L_InterimSalesHeader.SETRANGE("Destination Doc No.", Rec."No.");
                    if Rec."Order Line Type" = Rec."Order Line Type"::"Single Line Orders" then begin
                        L_InterimSalesHeader.CalcFields("Shelf No.");
                        L_InterimSalesHeader.SetCurrentKey("Shelf No.");
                        L_InterimSalesHeader.SetAscending("Shelf No.", true);
                    end;
                    IF L_InterimSalesHeader.FindSet() THEN BEGIN
                        Clear(R_DeliveryNote);
                        R_DeliveryNote.SetTableView(L_InterimSalesHeader);
                        R_DeliveryNote.UseRequestPage(false);
                        R_DeliveryNote.Run();
                    END;
                end;
            }
            action("Download Delivery Label")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    R_CourierLabel: Report "Courier Label";
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    L_ShipmentTracking: Record "Shipment Tracking";
                    L_ShipmentTracking2: Record "Shipment Tracking";
                begin
                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("Destination Doc Type", L_InterimSalesHeader."Destination Doc Type"::"Internal Pick");
                    L_InterimSalesHeader.SETRANGE("Destination Doc No.", Rec."No.");
                    IF L_InterimSalesHeader.FindSet() THEN BEGIN
                        repeat
                            L_InterimSalesHeader.Mark(true);
                        until L_InterimSalesHeader.Next() = 0;
                        L_InterimSalesHeader.MarkedOnly(true);
                        if L_InterimSalesHeader.FindSet() then begin
                            repeat
                                L_ShipmentTracking.Reset();
                                L_ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                                L_ShipmentTracking.SetRange("Shipping Agent Code", L_InterimSalesHeader."Shipping Agent Code");
                                if L_ShipmentTracking.FindSet() then begin
                                    repeat
                                        L_ShipmentTracking.Mark(true);
                                    until L_ShipmentTracking.Next() = 0;
                                    L_ShipmentTracking.MarkedOnly(true);
                                    if L_ShipmentTracking.FindSet() then begin
                                        L_ShipmentTracking.CheckForPrint := true;
                                        L_ShipmentTracking.Modify();
                                    end;
                                end;
                            until L_InterimSalesHeader.Next() = 0;
                            L_ShipmentTracking2.Reset();
                            L_ShipmentTracking2.SetRange(CheckForPrint, true);
                            if L_ShipmentTracking2.FindSet() then begin
                                Clear(R_CourierLabel);
                                R_CourierLabel.SETTABLEVIEW(L_ShipmentTracking2);
                                R_CourierLabel.USEREQUESTPAGE(FALSE);
                                R_CourierLabel.Run();
                            end;
                        end;
                        L_ShipmentTracking2.Reset();
                        L_ShipmentTracking2.SetRange(CheckForPrint, true);
                        if L_ShipmentTracking2.FindSet() then begin
                            repeat
                                L_ShipmentTracking2.CheckForPrint := false;
                                L_ShipmentTracking2.Modify();
                            until L_ShipmentTracking2.Next() = 0;
                        end;
                    END;
                end;
            }
        }
        modify(CreatePick)
        {
            trigger OnBeforeAction()
            var
                RegisteredPick: Record "Registered Whse. Activity Hdr.";
            begin
                IF Rec."Trolley No." <> '' THEN BEGIN
                    RegisteredPick.RESET;
                    RegisteredPick.SETRANGE(Type, RegisteredPick.Type::Pick);
                    RegisteredPick.SETRANGE("Trolley No.", Rec."Trolley No.");
                    RegisteredPick.SETRANGE("Trolley Closed", FALSE);
                    IF RegisteredPick.FINDFIRST THEN
                        ERROR('You cannot create pick until previous trolley assigned on internal pick will close.');
                END;
            end;

            /*trigger OnAfterAction()
            var
                WIPL: Record "Whse. Internal Pick Line";
                WAL: Record "Warehouse Activity Line";
                ISH: Record "Interim Sales Header";
                ISL: Record "Interim Sales Line";
            begin
                WIPL.Reset();
                WIPL.SetRange("No.", Rec."No.");
                if WIPL.FindSet() then begin
                    repeat
                        //UpdateStatus++
                        ISH.Reset();
                        ISH.SetRange("Document Type", ISH."Document Type"::Order);
                        ISH.SetRange("Destination Doc Type", ISH."Destination Doc Type"::"Internal Pick");
                        ISH.SetRange("Destination Doc No.", WIPL."No.");
                        ISH.SetRange("Channel Order ID", WIPL."Channel Order ID");
                        if ISH.FindFirst() then begin
                            ISH.Validate(status, ISH.status::"In Picking");
                            ISH.Modify(true);
                        end;
                        //UpdateStatus--
                        WAL.Reset();
                        WAL.SetRange("Source Document", WAL."Source Document"::" ");
                        WAL.SetRange("Source No.", WIPL."No.");
                        WAL.SetRange("Source Line No.", WIPL."Line No.");
                        if WAL.FindSet() then begin
                            repeat
                                WAL."Channel Order ID" := WIPL."Channel Order ID";
                                WAL.Modify();
                            until WAL.Next() = 0;
                        end;
                    until WIPL.Next() = 0;
                end;
                //UpdatePickNo++
                WIPL.Reset();
                WIPL.SetRange("No.", Rec."No.");
                if WIPL.FindSet() then begin
                    repeat
                        WAL.Reset();
                        WAL.SetRange("Source Document", WAL."Source Document"::" ");
                        WAL.SetRange("Source No.", WIPL."No.");
                        WAL.SetRange("Source Line No.", WIPL."Line No.");
                        if WAL.FindFirst() then begin
                            ISL.Reset();
                            ISL.SetRange("Document Type", ISL."Document Type"::Order);
                            ISL.SetRange("Destination Doc Type", ISL."Destination Doc Type"::"Internal Pick");
                            ISL.SetRange("Destination Doc No.", WAL."Source No.");
                            ISL.SetRange("Channel Order ID", WAL."Channel Order ID");
                            if ISL.FindFirst() then begin
                                ISL."Pick No" := WAL."No.";
                                ISL."Pick Line No" := WAL."Line No.";
                                ISL."Picking Status" := ISL."Picking Status"::"In Picking";
                                ISL.Modify(true);
                            end;
                        end;
                    until WIPL.Next() = 0;
                end;
                //UpdatePickNo--
            end;*/
        }//Sofyan
    }
    //Sofyan++
    trigger OnDeleteRecord(): Boolean
    begin
        CreateWHInvPickHeaderWis."OndeleteW/HPick"(Rec);
    end;
    //Sofyan--


    var
        CreateWHInvPickHeaderWis: Codeunit "Process Web Order";
}