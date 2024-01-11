codeunit 90066 "Create Consolidate SO"
{
    SingleInstance = true;
    trigger OnRun()
    begin
    end;

    var
        myInt: Integer;

    procedure SendRequesttoCreateOrders(_InterimSH: Record "Interim Sales Header")
    var
        Tradpartner: Record "Trade Partner";
        //L_InterimSH: Record "Interim Sales Header";
        L_LastCustomerNo: Code[50];
        L_LastShipToCode: Code[20];
        L_InterimSL: Record "Interim Sales Line";
        L_ExistSalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Released_SalesHeader: Record "Sales Header";
        L_InterimHeader: Record "Interim Sales Header";
        WebOrderMgt: Codeunit "Process Web Order";
    begin
        if Not CheckSalesHeaderExist_But_WarehouseShipmet_And_PostedWarehouseShipmetNotExist(_InterimSH."Sell-to Customer No.", _InterimSH."Ship-to Code") then begin
            Clear(G_SalesHeaderCreated);
            Clear(G_SNo);
        end;

        L_InterimSL.Reset();
        L_InterimSL.SetRange("Document Type", _InterimSH."Document Type");
        L_InterimSL.SetRange("Document No", _InterimSH."No.");
        //L_InterimSL.SetFilter("Response Code", '%1|%2', '0', '3');
        if L_InterimSL.FindSet() then begin
            repeat
                if Not G_SalesHeaderCreated then
                    CreateSalesHeader(_InterimSH);

                if G_SNo <> '' then begin
                    L_ExistSalesHeader.Reset();
                    L_ExistSalesHeader.SetRange("No.", G_SNo);
                    L_ExistSalesHeader.SetRange("Document Type", L_ExistSalesHeader."Document Type"::Order);
                    if L_ExistSalesHeader.FindFirst() then begin
                        //Open Existing Order If Released++
                        if L_ExistSalesHeader.Status = L_ExistSalesHeader.Status::Released then begin
                            ReleaseSalesDoc.PerformManualReopen(L_ExistSalesHeader);
                        end;

                        //Update "Dataplast Order" field on Sales Order++
                        L_ExistSalesHeader."Marged Web Order" := true;
                        L_ExistSalesHeader.Modify();

                        //Create Lines++
                        CreateSalesLine(L_ExistSalesHeader, L_InterimSL);

                    end;
                end else begin
                    //Open Sales Order If released++
                    if InsertedSH.Status = InsertedSH.Status::Released then
                        ReleaseSalesDoc.PerformManualReopen(InsertedSH);

                    //Create Line++    
                    CreateSalesLine(InsertedSH, L_InterimSL);
                end;
            until L_InterimSL.Next() = 0;

            //Released the sales order+++
            if G_SNo <> '' then begin
                Released_SalesHeader.Reset();
                Released_SalesHeader.SetRange("No.", G_SNo);
                Released_SalesHeader.SetRange("Document Type", Released_SalesHeader."Document Type"::Order);
                if Released_SalesHeader.FindFirst() then begin
                    //Release Order++
                    if Released_SalesHeader.Status = Released_SalesHeader.Status::Open then begin
                        ReleaseSalesDoc.PerformManualRelease(Released_SalesHeader);
                    end;

                    //Moved Into Web Buffer Table++
                    InsertIntoTempHeader(_InterimSH."No.", Released_SalesHeader."No.");
                end;
            end else begin
                //Release Order++
                ReleaseSalesDoc.PerformManualRelease(InsertedSH);

                //Moved Into Web Buffer Table++
                InsertIntoTempHeader(_InterimSH."No.", InsertedSH."No.");
            end;
            //Released the sales order---
        end;
    end;

    local procedure InsertIntoTempHeader(WebNo: Code[20]; SalesNo: Code[20])
    var
        TempSalesHeader: Record "Web Buffer";
    begin
        TempSalesHeader.RESET;
        TempSalesHeader.SETRANGE("Web Document No.", WebNo);
        TempSalesHeader.SETRANGE("Sales Document No.", SalesNo);
        IF NOT TempSalesHeader.FINDFIRST THEN BEGIN
            TempSalesHeader.INIT;
            TempSalesHeader."Web Document No." := WebNo;
            TempSalesHeader."Sales Document No." := SalesNo;
            TempSalesHeader.INSERT;
        END;
    end;

    var
        G_SalesHeaderCreated: Boolean;
        G_SNo: Code[20];
        InsertedSH: Record "Sales Header";
        tes: page "Sales Order";

    local procedure CheckSalesHeaderExist_But_WarehouseShipmet_And_PostedWarehouseShipmetNotExist(_SellToCustomerNo: Code[50]; _ShipToCode: Code[20]): Boolean
    var
        L_SalesHeader: Record "Sales Header";
    begin
        Clear(G_SNo);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Sell-to Customer No.", _SellToCustomerNo);
        L_SalesHeader.SetRange("Ship-to Code", _ShipToCode);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        if L_SalesHeader.FindSet() then begin
            repeat
                //Check Pick Is available or not++
                if not CheckWarehouseShipment(L_SalesHeader) then begin

                    //Check Posted Pick is Availabel or not+++
                    if not CheckPostedSalesShipment(L_SalesHeader) then begin
                        G_SalesHeaderCreated := true;
                        G_SNo := L_SalesHeader."No.";
                        exit(true);
                    end;
                end;
            until L_SalesHeader.Next() = 0;

            exit(false);
        end;
    end;

    local procedure CheckWarehouseShipment(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        L_WarehouseShipmentLine.Reset();
        L_WarehouseShipmentLine.SetRange("Source Document", L_WarehouseShipmentLine."Source Document"::"Sales Order");
        L_WarehouseShipmentLine.SetRange("Source No.", _SalesHeader."No.");
        if not L_WarehouseShipmentLine.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CheckPostedSalesShipment(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_PostedSalesShipmentLine: Record "Sales Shipment Line";
    begin
        L_PostedSalesShipmentLine.Reset();
        L_PostedSalesShipmentLine.SetRange("Order No.", _SalesHeader."No.");
        if not L_PostedSalesShipmentLine.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreateSalesHeader(_InterimSalesHeader: Record "Interim Sales Header")
    var
        "S&R": Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        "S&R".Get();
        InsertedSH.Reset();
        InsertedSH.Init();
        InsertedSH.Validate("Document Type", InsertedSH."Document Type"::Order);
        InsertedSH.Validate("No.", NoSeriesManagement.GetNextNo("S&R"."Order Nos.", WORKDATE, TRUE));
        InsertedSH.Validate("Posting Date", WorkDate());
        InsertedSH.Validate("Order Date", _InterimSalesHeader."Document Date");
        InsertedSH.Validate("Location Code", _InterimSalesHeader."Location Code");
        InsertedSH.Validate("Document Date", _InterimSalesHeader."Document Date");
        //InsertedSH."Channel Code" := _InterimSalesHeader."Trade Partner Code"; // 
        InsertedSH."Web Order" := true;
        InsertedSH.Insert();

        InsertedSH.Validate("Sell-to Customer No.", _InterimSalesHeader."Sell-to Customer No.");
        //InsertedSH.Validate("External Document No.", _InterimSalesHeader."No.");
        //If Ship-to Code is blank then system should validate default customer address++++
        if _InterimSalesHeader."Ship-to Code" <> '' then
            InsertedSH.Validate("Ship-to Code", _InterimSalesHeader."Ship-to Code");
        InsertedSH.Modify();
        G_SalesHeaderCreated := true;
    end;

    local procedure CreateSalesLine(_SalesHeader: Record "Sales Header"; _InterimSalesLine: Record "Interim Sales Line")
    var
        InsertedSL: Record "Sales Line";

    begin
        InsertedSL.Reset();
        InsertedSL.SetRange("Document Type", InsertedSL."Document Type"::Order);
        InsertedSL.SetRange("Document No.", _SalesHeader."No.");
        InsertedSL.SetRange("No.", _InterimSalesLine."No.");
        InsertedSL.SetRange(Type, InsertedSL.Type::Item);
        if InsertedSL.FindFirst() then begin
            InsertedSL.Validate("Web Order", true);
            InsertedSL.Validate(Quantity, InsertedSL.Quantity + _InterimSalesLine.Quantity);
            InsertedSL.Modify(true);
            // if _InterimSalesLine."Response Code" = '3' then begin
            //     InsertedSL.Validate(Quantity, InsertedSL.Quantity + _InterimSalesLine."Quantity To Deliver");
            //     InsertedSL.Modify(true);
            // end else begin
            //     InsertedSL.Validate(Quantity, InsertedSL.Quantity + _InterimSalesLine.Quantity);
            //     InsertedSL.Modify(true);
            // end;
        end else begin
            InsertedSL.Reset();
            InsertedSL.Init();
            InsertedSL.VALIDATE("Document Type", InsertedSL."Document Type"::Order);
            InsertedSL.VALIDATE("Document No.", _SalesHeader."No.");
            InsertedSL.VALIDATE("Line No.", GetLastLineNo(_SalesHeader."No."));
            InsertedSL.VALIDATE(Type, _InterimSalesLine.Type);
            InsertedSL.VALIDATE("No.", _InterimSalesLine."No.");
            InsertedSL.VALIDATE(Quantity, _InterimSalesLine.Quantity);
            InsertedSL.Validate("Web Order", true);
            // if _InterimSalesLine."Response Code" = '3' then begin
            //     InsertedSL.VALIDATE(Quantity, _InterimSalesLine."Quantity To Deliver");
            // end else
            //     InsertedSL.VALIDATE(Quantity, _InterimSalesLine.Quantity);
            InsertedSL.Validate("Location Code", _SalesHeader."Location Code");
            InsertedSL.Insert(true);
        end;




    end;

    local procedure GetLastLineNo(HeaderNo: Code[20]): Integer
    var
        L_SalesLine: Record "Sales Line";
    begin
        L_SalesLine.RESET;
        L_SalesLine.SETRANGE("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SETRANGE("Document No.", HeaderNo);
        IF L_SalesLine.FINDLAST THEN
            EXIT(L_SalesLine."Line No." + 10000)
        ELSE
            EXIT(10000);
    end;
}