pageextension 90071 "Warehouse Pick Card Ext" extends "Warehouse Pick"
{
    //CourierIntegration++
    layout
    {
        addafter("Sorting Method")
        {
            field("Shipping Agent Code"; Rec."Shipping Agent Code")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("No. of Boxes"; Rec."No. of Boxes")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("Total weight (consignment)"; Rec."Total weight (consignment)")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("SO No."; Rec."SO No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
    //CourierIntegration--
    /* actions
     {
         modify(RegisterPick)
         {
             trigger OnBeforeAction()
             var
                 WAL: Record "Warehouse Activity Line";
                 ISL: Record "Interim Sales Line";
                 ISH: Record "Interim Sales Header";
             begin
                 WAL.Reset();
                 WAL.SetRange("No.", Rec."No.");
                 WAL.SetRange("Activity Type", WAL."Activity Type"::Pick);
                 if WAL.FindSet() then begin
                     repeat
                         ISL.Reset();
                         ISL.SetRange("Document Type", ISL."Document Type"::Order);
                         ISL.SetRange("Destination Doc Type", ISL."Destination Doc Type"::"Internal Pick");
                         ISL.SetRange("Destination Doc No.", WAL."Source No.");
                         ISL.SetRange("Channel Order ID", WAL."Channel Order ID");
                         if ISL.FindFirst() then begin
                             ISL."Picking Status" := ISL."Picking Status"::"In Picking";
                             ISL.Modify(true);
                         end;
                         ISH.Reset();
                         ISH.SetRange("Document Type", ISH."Document Type"::Order);
                         ISH.SetRange("Destination Doc Type", ISH."Destination Doc Type"::"Internal Pick");
                         ISH.SetRange("Destination Doc No.", WAL."Source No.");
                         ISH.SetRange("Channel Order ID", WAL."Channel Order ID");
                         if ISH.FindFirst() then begin
                             ISH.status := ISH.status::"In Picking";
                             ISH.Modify(true);
                         end;
                     until WAL.Next() = 0;
                 end;
             end;

         }
     }*/

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