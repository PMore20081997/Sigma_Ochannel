pageextension 90070 "Warehouse Pick List Ext" extends "Warehouse Picks"
{
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
                        IF PickedLine > 0 THEN
                            L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::Picked
                        ELSE
                            IF InpickingLine > 0 THEN
                                L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::"In Picking"
                            ELSE
                                L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::Processing;
                    END ELSE
                        L_InterimSalesHeader.Status := L_InterimSalesHeader.Status::"Partially Scanned";
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