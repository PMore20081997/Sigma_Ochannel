reportextension 90002 "Ext Whse. Shipment Create Pick" extends "Whse.-Shipment - Create Pick"
{
    dataset
    {
        modify("Warehouse Shipment Line")
        {
            trigger OnBeforeAfterGetRecord()
            begin
                // IF ("Warehouse Shipment Line"."Channel Code" <> '') AND (G_TrolleyNo = '') THEN
                //   ERROR('Trolley no must not be blank');
            end;

            trigger OnAfterAfterGetRecord()

            begin
                IF "G_TrolleyNo" <> '' THEN begin
                    UpdateTrolleyNo(G_TrolleyNo, "Warehouse Shipment Line"."No.");
                end
                ELSE begin
                    UpdateTrolleyNo("Warehouse Shipment Line"."No.", "Warehouse Shipment Line"."No.");
                end;


                // If (Format(G_SalesHeader."No.") = Format("Warehouse Shipment Line"."Source No.")) and (G_ShippingRule.Count = 1) then Begin
                If (Format(G_SalesHeader."No.") = Format("Warehouse Shipment Line"."Source No.")) then Begin
                    "Warehouse Shipment Line"."Bay No." := G_BayNo;
                    "Warehouse Shipment Line".Modify();
                end Else
                    // if (Format(G_SalesHeader."No.") <> Format("Warehouse Shipment Line"."Source No.")) and (G_ShippingRule.Count = 1) then begin
                    if ((Format(G_SalesHeader."No.") <> Format("Warehouse Shipment Line"."Source No.")) and (G_ShippingRule."Shipping Agent" <> '')) then begin
                        G_SalesHeader.Reset();
                        G_SalesHeader.SetFilter("No.", "Warehouse Shipment Line"."Source No.");
                        If G_SalesHeader.FindFirst() then;
                        "Warehouse Shipment Line"."Bay No." := IncStr(G_BayNo);
                        "Warehouse Shipment Line".Modify();
                        G_BayNo := IncStr(G_BayNo);
                    End Else begin
                        G_SalesHeader.Reset();
                        G_SalesHeader.SetFilter("No.", "Warehouse Shipment Line"."Source No.");
                        If G_SalesHeader.FindFirst() then begin
                            G_ShippingRule.Reset();
                            G_ShippingRule.SetFilter("Shipping Agent", G_SalesHeader."Shipping Agent Code");
                            G_ShippingRule.SetFilter("Shipping Agent Service", G_SalesHeader."Shipping Agent Service Code");
                            // G_ShippingRule.SetFilter("Web Shipment Method", G_SalesHeader."Web Shipment Method");
                            G_ShippingRule.SetFilter("Channel Code", "Warehouse Shipment Line"."Channel Code");
                            G_ShippingRule.SetFilter("Assign Bay", '%1', true);
                            if G_ShippingRule.FindFirst() then begin
                                "Warehouse Shipment Line"."Bay No." := G_ShippingRule."Starting Bay No. ";
                                "Warehouse Shipment Line".Modify();
                                G_BayNo := G_ShippingRule."Starting Bay No. ";
                            end;
                        end;
                    end;
                if G_TrolleyNo <> '' then begin
                    "Warehouse Shipment Line"."Trolley No." := G_TrolleyNo;
                    "Warehouse Shipment Line".Modify();
                end else begin
                    "Warehouse Shipment Line"."Trolley No." := "Warehouse Shipment Line"."No.";
                    "Warehouse Shipment Line".Modify();
                end;
            end;
        }

    }
    requestpage
    {
        layout
        {
            addafter(PrintDoc)
            {
                field("Trolley No."; G_TrolleyNo)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        TrolleyNoValidations(G_TrolleyNo, "Warehouse Shipment Line"."No.");
                    end;
                }

            }

        }

    }

    local procedure UpdateTrolleyNo(P_TrolleyNo: Code[20]; P_PickNo: Code[20])
    var
        WSH: Record "Warehouse Shipment Header";
    begin
        WSH.Reset();
        WSH.SetRange("No.", P_PickNo);
        if WSH.FindFirst() then begin
            if P_TrolleyNo <> '' then begin
                if WSH."Trolley No." <> P_TrolleyNo then begin
                    WSH.Validate("Trolley No.", P_TrolleyNo);
                    WSH.Modify();
                end;
            end else begin
                if WSH."Trolley No." <> P_TrolleyNo then begin
                    WSH.Validate("Trolley No.", P_PickNo);
                    WSH.Modify();
                end;
            end;
        end;
    end;

    local procedure TrolleyNoValidations(P_TrolleyNo: Text; WarehouseShipmentNo: Code[20])
    var
        L_ISL: Record "Interim Sales Line";
    begin
        L_ISL.RESET;
        L_ISL.SETRANGE("Destination Doc Type", L_ISL."Destination Doc Type"::"Sales Order");
        L_ISL.SETRANGE("Destination Doc No.", WarehouseShipmentNo);
        L_ISL.SETRANGE("Dispatch Scan", FALSE);
        L_ISL.SETRANGE("Scanned Date", 0DT);
        L_ISL.SETFILTER(Status, '<>%1', L_ISL.Status::Cancelled);
        L_ISL.SETFILTER("Trolley No.", '<>%1', '');
        IF L_ISL.FINDSET THEN
            ERROR('You can not create Pick.\There is an open Trolley %1 assoiciated with this Warehouse Shipment %2 ', L_ISL."Trolley No.", L_ISL."Destination Doc No.");

        L_ISL.RESET;
        L_ISL.SETRANGE("Trolley No.", P_TrolleyNo);
        L_ISL.SETRANGE("Dispatch Scan", FALSE);
        L_ISL.SETRANGE("Scanned Date", 0DT);
        L_ISL.CALCFIELDS(Status);
        L_ISL.SETFILTER(Status, '<>%1', L_ISL.Status::Cancelled);
        IF L_ISL.FINDSET THEN
            ERROR('This Trolley no is assoiciated with open web order from Warehouse Shipment %1 ', L_ISL."Destination Doc No.");

    end;



    var
        G_TrolleyNo: Code[20];
        G_SalesHeader: Record "Sales Header";
        G_ShippingRule: Record "Shipping Rule";
        G_BayNo: Code[20];
}