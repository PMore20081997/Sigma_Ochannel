codeunit 90021 "DC Sales TOS Lines"
{
    trigger OnRun()
    var
        SalesLineTOS: Record "Sales Line TOS";
        L_WebBuffer: Record "Web Buffer";
        L_SalesLine: Record "Sales Line";
        L_SalesHeader: Record "Sales Header";
        L_WhseActivityLine: Record "Warehouse Activity Line";
        GeneralSetupChannel: Record "General Setup - Channels";
        StartDate: Date;
    begin
        GeneralSetupChannel.Get();
        SalesLineTOS.DeleteAll();
        StartDate := CalculateStartDate(GeneralSetupChannel."No. Of Days");

        L_WebBuffer.Reset();
        L_WebBuffer.SetFilter("Web Document No.", 'DC*');
        L_WebBuffer.SetRange("TOS Checked", false);
        L_WebBuffer.SetFilter("Created At", '%1..', StartDate);
        //L_WebBuffer.SetFilter("Created At", '%1..', GeneralSetupChannel."DC TOS Start Date");
        if L_WebBuffer.FindSet() then begin
            repeat
                L_SalesHeader.Reset();
                L_SalesHeader.CalcFields(Shipped);
                L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
                L_SalesHeader.SetRange("No.", L_WebBuffer."Sales Document No.");
                L_SalesHeader.SetRange(Shipped, true);
                if L_SalesHeader.FindFirst() then begin
                    if L_SalesHeader."Knapp Order" = true then begin
                        L_SalesLine.Reset();
                        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                        L_SalesLine.SetRange("Document No.", L_WebBuffer."Sales Document No.");
                        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                        if L_SalesLine.FindSet() then begin
                            repeat
                                if L_SalesLine.Quantity <> L_SalesLine."Quantity Shipped" then
                                    InsertTempSalesLine(L_SalesLine, L_WebBuffer."Web Document No.");
                            until L_SalesLine.Next() = 0;
                        end;
                    end
                    else begin
                        L_SalesLine.Reset();
                        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                        L_SalesLine.SetRange("Document No.", L_WebBuffer."Sales Document No.");
                        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                        if L_SalesLine.FindSet() then begin
                            repeat
                                L_WhseActivityLine.Reset();
                                L_WhseActivityLine.SetRange("Source Document", L_WhseActivityLine."Source Document"::"Sales Order");
                                L_WhseActivityLine.SetRange("Source No.", L_WebBuffer."Sales Document No.");
                                L_WhseActivityLine.SetRange("Source Line No.", L_SalesLine."Line No.");
                                L_WhseActivityLine.SetRange("Item No.", L_SalesLine."No.");
                                if not L_WhseActivityLine.FindFirst() then
                                    if L_SalesLine.Quantity <> L_SalesLine."Quantity Shipped" then
                                        InsertTempSalesLine(L_SalesLine, L_WebBuffer."Web Document No.");
                            until L_SalesLine.Next() = 0;
                        end;
                    end;
                end;
            until L_WebBuffer.Next() = 0;
        end;
    end;

    local procedure InsertTempSalesLine(P_SalesLine: Record "Sales Line"; P_WebOrderNo: Code[20])
    var
        SalesLineTOS: Record "Sales Line TOS";
        Rec_SalesLineTOS: Record "Sales Line TOS";
    begin
        if GetPipCode(P_SalesLine, P_WebOrderNo) <> '' then begin
            Rec_SalesLineTOS.Reset();
            Rec_SalesLineTOS.SetRange("Sales Order No.", P_SalesLine."Document No.");
            Rec_SalesLineTOS.SetRange("Item No.", P_SalesLine."No.");
            Rec_SalesLineTOS.SetRange("Line No.", P_SalesLine."Line No.");
            if not Rec_SalesLineTOS.FindFirst() then begin
                Clear(SalesLineTOS);
                SalesLineTOS.Init();
                SalesLineTOS."Entry No." := FindLastEntryNo();
                SalesLineTOS."Item No." := P_SalesLine."No.";
                SalesLineTOS."Line No." := P_SalesLine."Line No.";
                SalesLineTOS."PIP Code" := GetPipCode(P_SalesLine, P_WebOrderNo);
                SalesLineTOS."ET Access Code" := GetETAccessCode(P_WebOrderNo);
                SalesLineTOS.Description := P_SalesLine.Description;
                SalesLineTOS.Quantity := P_SalesLine.Quantity;
                SalesLineTOS."Quantity Shipped" := P_SalesLine."Quantity Shipped";
                If P_SalesLine."Quantity Shipped" = 0 then
                    SalesLineTOS.Status := 'TOS'
                else
                    if P_SalesLine.Quantity > P_SalesLine."Quantity Shipped" then
                        SalesLineTOS.Status := 'Partial TOS';
                SalesLineTOS."Web Order No." := P_WebOrderNo;
                SalesLineTOS."Sales Order No." := P_SalesLine."Document No.";
                SalesLineTOS.Insert();
                Commit();
            end;
        end;
    end;

    local procedure FindLastEntryNo(): Integer
    var
        L_SalesLineTOS: Record "Sales Line TOS";
    begin
        L_SalesLineTOS.Reset();
        if L_SalesLineTOS.FindLast() then
            exit(L_SalesLineTOS."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure GetETAccessCode(P_WebOrderNo: Code[20]): Code[50]
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.SetRange("No.", P_WebOrderNo);
        if L_InterimSalesHeader.FindFirst() then begin
            exit(L_InterimSalesHeader."ET Access Code");
        end
        else begin
            L_HandledInterimSalesHeader.Reset();
            L_HandledInterimSalesHeader.SetRange("Document Type", L_HandledInterimSalesHeader."Document Type"::Order);
            L_HandledInterimSalesHeader.SetRange("No.", P_WebOrderNo);
            if L_HandledInterimSalesHeader.FindFirst() then begin
                exit(L_HandledInterimSalesHeader."ET Access Code");
            end;
        end;
    end;

    local procedure GetPipCode(P_SalesLine: Record "Sales Line"; P_WebOrderNo: Code[20]): Text[50]
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_HandledInterimSalesLine: Record "Handled Interim Sales Line";
    begin
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SetRange("Document No", P_WebOrderNo);
        L_InterimSalesLine.SetRange("No.", P_SalesLine."No.");
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        if L_InterimSalesLine.FindFirst() then begin
            exit(L_InterimSalesLine."Channel SKU");
        end
        else begin
            L_HandledInterimSalesLine.Reset();
            L_HandledInterimSalesLine.SetRange("Document Type", L_HandledInterimSalesLine."Document Type"::Order);
            L_HandledInterimSalesLine.SetRange("Document No", P_WebOrderNo);
            L_HandledInterimSalesLine.SetRange(Type, L_HandledInterimSalesLine.Type::Item);
            L_HandledInterimSalesLine.SetRange("No.", P_SalesLine."No.");
            if L_HandledInterimSalesLine.FindFirst() then begin
                exit(L_HandledInterimSalesLine."Channel SKU");
            end;
        end;
    end;

    local procedure CalculateStartDate(InputText: Text): Date
    var
        UnitCode: Text[1];
        NumberText: Text;
        DurationNumber: Integer;
        StartDate: Date;
    begin
        if InputText = '' then
            exit(WorkDate());

        UnitCode := UpperCase(CopyStr(InputText, StrLen(InputText), 1));
        NumberText := CopyStr(InputText, 1, StrLen(InputText) - 1);

        if not Evaluate(DurationNumber, NumberText) then
            Error('Invalid number in "No. of Days": %1', InputText);

        case UnitCode of
            'D':
                StartDate := WorkDate() - DurationNumber;
            'W':
                StartDate := WorkDate() - (DurationNumber * 7);
            'M':
                StartDate := CalcDate('<-' + Format(DurationNumber) + 'M>', WorkDate());
            else
                Error('Invalid unit in "No. of Days": %1. Use D, W, or M.', UnitCode);
        end;

        exit(StartDate);
    end;
}