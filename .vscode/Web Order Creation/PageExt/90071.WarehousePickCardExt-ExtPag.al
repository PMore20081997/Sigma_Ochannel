pageextension 90071 "Warehouse Pick Card Ext" extends "Warehouse Pick"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Trolley No."; Rec."Trolley No.")
            {
                ApplicationArea = all;
                trigger OnValidate()
                var
                    L_PickLine: Record "Warehouse Activity Line";
                    L_ShipmentLine: Record "Warehouse Shipment Line";
                    L_ShipmentHeader: Record "Warehouse Shipment Header";
                begin
                    L_PickLine.Reset();
                    L_PickLine.SetRange("No.", Rec."No.");
                    if L_PickLine.FindSet() then begin
                        repeat
                            if L_PickLine."Whse. Document Type" = L_PickLine."Whse. Document Type"::Shipment then begin
                                L_PickLine.Validate("Trolley No.", Rec."Trolley No.");
                                L_PickLine.Modify(true);
                                L_ShipmentHeader.Reset();
                                L_ShipmentHeader.SetRange("No.", L_PickLine."Whse. Document No.");
                                if L_ShipmentHeader.FindFirst() then begin
                                    L_ShipmentHeader.Validate("Trolley No.", L_PickLine."Trolley No.");
                                    L_ShipmentHeader.Modify(true);
                                    L_ShipmentLine.Reset();
                                    L_ShipmentLine.SetRange("No.", L_ShipmentHeader."No.");
                                    if L_ShipmentLine.FindSet() then begin
                                        repeat
                                            L_ShipmentLine.Validate("Trolley No.", L_ShipmentHeader."Trolley No.");
                                            L_ShipmentLine.Modify(true);
                                        until L_ShipmentLine.Next() = 0;
                                    end;
                                end;
                            end;
                        until L_PickLine.Next() = 0;
                        Message('Trolley Number Updated Successfully');
                    end;
                end;
            }
            field("No. of Boxes"; Rec."No. of Boxes")
            {
                ApplicationArea = all;
            }
            field("Total weight (consignment)"; Rec."Total weight (consignment)")
            {
                ApplicationArea = all;
            }
            field("SO No."; Rec."SO No.")
            {
                ApplicationArea = All;
                Visible = false;
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

    trigger OnDeleteRecord(): Boolean
    begin
        DeleteWebOrderReference();
        CurrPage.UPDATE;
    end;

    local procedure DeleteWebOrderReference()
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SetRange("Destination Doc Type", L_InterimSalesLine."Destination Doc Type"::"Internal Pick");
        L_InterimSalesLine.SETRANGE("Pick No", Rec."No.");
        L_InterimSalesLine.SETRANGE("Picking Status", L_InterimSalesLine."Picking Status"::"In Picking");
        IF L_InterimSalesLine.FINDFIRST THEN
            REPEAT
                L_InterimSalesLine."Picking Status" := L_InterimSalesLine."Picking Status"::" ";
                CLEAR(L_InterimSalesLine."Pick No");
                CLEAR(L_InterimSalesLine."Pick Line No");
                L_InterimSalesLine.MODIFY;
                AddOrderNotoTempPick(L_InterimSalesLine."Document No");
            UNTIL L_InterimSalesLine.NEXT = 0;

        UpdateStatusWebOrderHeader();
    end;

    LOCAL procedure UpdateStatusWebOrderHeader()
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        PickedLine: Integer;
        InpickingLine: Integer;
        PartialScanned: Integer;
    begin
        IF TempOrderNoPick.FINDSET THEN
            REPEAT
                CLEAR(PickedLine);
                CLEAR(InpickingLine);

                L_InterimSalesHeader.RESET;
                L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
                L_InterimSalesHeader.SETRANGE("No.", TempOrderNoPick."No.");
                IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
                    L_InterimSalesLine.RESET;
                    L_InterimSalesLine.SETRANGE("Document Type", L_InterimSalesHeader."Document Type");
                    L_InterimSalesLine.SETRANGE("Document No", L_InterimSalesHeader."No.");
                    L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
                    L_InterimSalesLine.SETFILTER("Item Type", '%1|%2', L_InterimSalesLine."Item Type"::Component, L_InterimSalesLine."Item Type"::Single);
                    IF L_InterimSalesLine.FINDSET THEN
                        REPEAT
                            CASE L_InterimSalesLine."Picking Status" OF
                                L_InterimSalesLine."Picking Status"::"In Picking":
                                    BEGIN
                                        InpickingLine += 1;
                                    END;
                                L_InterimSalesLine."Picking Status"::Picked:
                                    BEGIN
                                        IF (L_InterimSalesLine."Scanned Date" <> 0DT) AND (L_InterimSalesLine."Dispatch Scan" = FALSE) THEN
                                            PickedLine += 1
                                        ELSE
                                            PartialScanned += 1;
                                    END;
                            END;
                        UNTIL L_InterimSalesLine.NEXT = 0;

                    IF PartialScanned = 0 THEN BEGIN
                        // IF PickedLine > 0 THEN
                        //     L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::Picked
                        // ELSE
                        //     IF InpickingLine > 0 THEN
                        //         L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::"In Picking"
                        //     ELSE
                        //         L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::"SO Created";
                    END;
                    // END ELSE
                    //     L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::"Partially Scanned";
                    L_InterimSalesHeader.MODIFY;

                END;
            UNTIL TempOrderNoPick.NEXT = 0;
    end;

    LOCAL procedure AddOrderNotoTempPick(OrderNo: Code[20])
    begin
        IF NOT TempOrderNoPick.GET(OrderNo) THEN BEGIN
            TempOrderNoPick.INIT;
            TempOrderNoPick."No." := OrderNo;
            TempOrderNoPick.INSERT;
        END;
    end;

    var
        TempOrderNoPick: Record Item temporary;
}