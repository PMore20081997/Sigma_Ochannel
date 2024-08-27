codeunit 90066 "Create Consolidate SO"
{
    SingleInstance = true;
    trigger OnRun()
    begin
    end;

    var
        myInt: Integer;
        Temporary_SalesLine: Record "Sales Line" temporary; //Dont Remove Temporary propert+++
        Temporary_SalesLine_ForLoop: Record "Sales Line" temporary; //Dont Remove Temporary propert+++
        G_TemporaryLineNo: Integer;
        G_TemporaryLineNo_ForLoop: Integer;

    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Consolidate Sales +++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    procedure ClearVariable()
    begin
        Temporary_SalesLine.Reset();
        Temporary_SalesLine.DeleteAll();
        Temporary_SalesLine_ForLoop.Reset();
        Temporary_SalesLine_ForLoop.DeleteAll();
        Clear(G_TemporaryLineNo);
        Clear(G_TemporaryLineNo_ForLoop);
        Clear(G_SNo);
    end;

    procedure ProcessTemporaryWebOrdertoSalesOrder(_InterimSH: Record "Interim Sales Header")
    begin
        //Create Temporary Record++
        CreateTemporaryOrder(_InterimSH);
    end;

    local procedure CreateTemporaryOrder(_InterimSH: Record "Interim Sales Header")
    var
        L_InterimSL: Record "Interim Sales Line";
    begin
        L_InterimSL.Reset();
        L_InterimSL.SetRange("Document Type", _InterimSH."Document Type");
        L_InterimSL.SetRange("Document No", _InterimSH."No.");
        L_InterimSL.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
        if L_InterimSL.FindSet() then begin
            repeat
                //Create Lines++
                CreateTemporarySalesLine(L_InterimSL, _InterimSH);

                //Create Lines For Loop++
                CreateTemporarySalesLine_ForLoop(L_InterimSL, _InterimSH);
            until L_InterimSL.Next() = 0;
        end;
    end;

    local procedure CreateTemporarySalesLine(_InterimSalesLine: Record "Interim Sales Line"; _InterimSH: Record "Interim Sales Header")
    var
        L_Item: Record Item;
    begin
        Temporary_SalesLine.Reset();
        Temporary_SalesLine.SetRange("Document Type", _InterimSH."Document Type"::Order);
        Temporary_SalesLine.SetRange("Sell-to Customer No.", _InterimSH."Sell-to Customer No.");
        Temporary_SalesLine.SetRange("Ship-to Code", _InterimSH."Ship-to Code");
        Temporary_SalesLine.SetRange("Shipping Agent Code", _InterimSH."Shipping Agent Code");
        Temporary_SalesLine.SetRange("Shipping Agent Service Code", _InterimSH."Shipping Agent Service Code");
        Temporary_SalesLine.SetRange("Shipment Date", _InterimSH."Shipment Date");
        Temporary_SalesLine.SetRange("No.", _InterimSalesLine."No.");
        Temporary_SalesLine.SetRange("Location Code", _InterimSH."Location Code");
        Temporary_SalesLine.SetRange(Type, Temporary_SalesLine.Type::Item);
        Temporary_SalesLine.SetRange("Changed UnitPrice", _InterimSalesLine."Changed UnitPrice");
        Temporary_SalesLine.SetRange("Unit Price", _InterimSalesLine."Unit Price");
        if Temporary_SalesLine.FindFirst() then begin
            Temporary_SalesLine.Quantity := Temporary_SalesLine.Quantity + _InterimSalesLine."Qty. to Deliver";

            if Temporary_SalesLine."Temp Web Order No." <> '' then
                Temporary_SalesLine."Temp Web Order No." := Temporary_SalesLine."Temp Web Order No." + '|' + _InterimSH."No."
            else
                Temporary_SalesLine."Temp Web Order No." := _InterimSH."No.";


            //Update KNAP Line+++
            if (CheckKnaapCustomer(Temporary_SalesLine."Sell-to Customer No.") = true) AND (CheckKnaapShippingAgentServiceFromInterimSalesHeader(_InterimSH."Shipping Agent Code", _InterimSH."Shipping Agent Service Code") = true) AND (CheckKnaapItem(Temporary_SalesLine."No.") = true) then begin
                L_Item.Reset();
                L_Item.SetRange("No.", Temporary_SalesLine."No.");
                if L_Item.FindFirst() then begin
                    if Temporary_SalesLine.Quantity <= L_Item."Knapp Threshold Quantity" then
                        Temporary_SalesLine."Knapp Line" := true;
                end;
            end;

            Temporary_SalesLine.Modify();
        end else begin
            G_TemporaryLineNo += 10000;
            Temporary_SalesLine.Init();
            Temporary_SalesLine."Document Type" := _InterimSH."Document Type"::Order;
            Temporary_SalesLine.Type := Temporary_SalesLine.Type::Item;
            Temporary_SalesLine."No." := _InterimSalesLine."No.";
            Temporary_SalesLine."Line No." := G_TemporaryLineNo;
            Temporary_SalesLine.Quantity := _InterimSalesLine."Qty. to Deliver";
            Temporary_SalesLine."Sell-to Customer No." := _InterimSH."Sell-to Customer No.";
            Temporary_SalesLine."Ship-to Code" := _InterimSH."Ship-to Code";
            Temporary_SalesLine."Shipping Agent Code" := _InterimSH."Shipping Agent Code";
            Temporary_SalesLine."Shipping Agent Service Code" := _InterimSH."Shipping Agent Service Code";
            Temporary_SalesLine."Shipment Date" := _InterimSH."Shipment Date";
            Temporary_SalesLine."Location Code" := _InterimSH."Location Code";
            Temporary_SalesLine."FA Posting Date" := _InterimSH."Order Date";
            Temporary_SalesLine."Temp Web Order No." := _InterimSH."No.";
            Temporary_SalesLine."Changed UnitPrice" := _InterimSalesLine."Changed UnitPrice";
            Temporary_SalesLine."Unit Price" := _InterimSalesLine."Unit Price";


            //Update KNAP Line+++
            if (CheckKnaapCustomer(Temporary_SalesLine."Sell-to Customer No.") = true) AND (CheckKnaapShippingAgentServiceFromInterimSalesHeader(_InterimSH."Shipping Agent Code", _InterimSH."Shipping Agent Service Code") = true) AND (CheckKnaapItem(Temporary_SalesLine."No.") = true) then begin
                L_Item.Reset();
                L_Item.SetRange("No.", Temporary_SalesLine."No.");
                if L_Item.FindFirst() then begin
                    if Temporary_SalesLine.Quantity <= L_Item."Knapp Threshold Quantity" then
                        Temporary_SalesLine."Knapp Line" := true;
                end;
            end;

            Temporary_SalesLine.Insert();
        end;
    end;

    local procedure CreateTemporarySalesLine_ForLoop(_InterimSalesLine: Record "Interim Sales Line"; _InterimSH: Record "Interim Sales Header")
    var
        L_Item: Record Item;
    begin
        Temporary_SalesLine_ForLoop.Reset();
        Temporary_SalesLine_ForLoop.SetRange("Document Type", _InterimSH."Document Type"::Order);
        Temporary_SalesLine_ForLoop.SetRange("Sell-to Customer No.", _InterimSH."Sell-to Customer No.");
        Temporary_SalesLine_ForLoop.SetRange("Ship-to Code", _InterimSH."Ship-to Code");
        Temporary_SalesLine_ForLoop.SetRange("Shipping Agent Code", _InterimSH."Shipping Agent Code");
        Temporary_SalesLine_ForLoop.SetRange("Shipping Agent Service Code", _InterimSH."Shipping Agent Service Code");
        Temporary_SalesLine_ForLoop.SetRange("Shipment Date", _InterimSH."Shipment Date");
        Temporary_SalesLine_ForLoop.SetRange("No.", _InterimSalesLine."No.");
        Temporary_SalesLine_ForLoop.SetRange("Location Code", _InterimSH."Location Code");
        Temporary_SalesLine_ForLoop.SetRange(Type, Temporary_SalesLine_ForLoop.Type::Item);
        Temporary_SalesLine_ForLoop.SetRange("Changed UnitPrice", _InterimSalesLine."Changed UnitPrice");
        Temporary_SalesLine_ForLoop.SetRange("Unit Price", _InterimSalesLine."Unit Price");
        if Temporary_SalesLine_ForLoop.FindFirst() then begin
            Temporary_SalesLine_ForLoop.Quantity := Temporary_SalesLine_ForLoop.Quantity + _InterimSalesLine."Qty. to Deliver";

            if Temporary_SalesLine_ForLoop."Temp Web Order No." <> '' then
                Temporary_SalesLine_ForLoop."Temp Web Order No." := Temporary_SalesLine_ForLoop."Temp Web Order No." + '|' + _InterimSH."No."
            else
                Temporary_SalesLine_ForLoop."Temp Web Order No." := _InterimSH."No.";

            //Update KNAP Line+++
            if (CheckKnaapCustomer(Temporary_SalesLine_ForLoop."Sell-to Customer No.") = true) AND (CheckKnaapShippingAgentServiceFromInterimSalesHeader(_InterimSH."Shipping Agent Code", _InterimSH."Shipping Agent Service Code") = true) AND (CheckKnaapItem(Temporary_SalesLine_ForLoop."No.") = true) then begin
                L_Item.Reset();
                L_Item.SetRange("No.", Temporary_SalesLine_ForLoop."No.");
                if L_Item.FindFirst() then begin
                    if Temporary_SalesLine_ForLoop.Quantity <= L_Item."Knapp Threshold Quantity" then
                        Temporary_SalesLine_ForLoop."Knapp Line" := true;
                end;
            end;

            Temporary_SalesLine_ForLoop.Modify();
        end else begin
            G_TemporaryLineNo_ForLoop += 10000;
            Temporary_SalesLine_ForLoop.Init();
            Temporary_SalesLine_ForLoop."Document Type" := _InterimSH."Document Type"::Order;
            Temporary_SalesLine_ForLoop.Type := Temporary_SalesLine_ForLoop.Type::Item;
            Temporary_SalesLine_ForLoop."No." := _InterimSalesLine."No.";
            Temporary_SalesLine_ForLoop."Line No." := G_TemporaryLineNo_ForLoop;
            Temporary_SalesLine_ForLoop.Quantity := _InterimSalesLine."Qty. to Deliver";
            Temporary_SalesLine_ForLoop."Sell-to Customer No." := _InterimSH."Sell-to Customer No.";
            Temporary_SalesLine_ForLoop."Ship-to Code" := _InterimSH."Ship-to Code";
            Temporary_SalesLine_ForLoop."Shipping Agent Code" := _InterimSH."Shipping Agent Code";
            Temporary_SalesLine_ForLoop."Shipping Agent Service Code" := _InterimSH."Shipping Agent Service Code";
            Temporary_SalesLine_ForLoop."Shipment Date" := _InterimSH."Shipment Date";
            Temporary_SalesLine_ForLoop."Location Code" := _InterimSH."Location Code";
            Temporary_SalesLine_ForLoop."FA Posting Date" := _InterimSH."Order Date";
            Temporary_SalesLine_ForLoop."Temp Web Order No." := _InterimSH."No.";
            Temporary_SalesLine_ForLoop."Changed UnitPrice" := _InterimSalesLine."Changed UnitPrice";
            Temporary_SalesLine_ForLoop."Unit Price" := _InterimSalesLine."Unit Price";

            //Update KNAP Line+++
            if (CheckKnaapCustomer(Temporary_SalesLine_ForLoop."Sell-to Customer No.") = true) AND (CheckKnaapShippingAgentServiceFromInterimSalesHeader(_InterimSH."Shipping Agent Code", _InterimSH."Shipping Agent Service Code") = true) AND (CheckKnaapItem(Temporary_SalesLine_ForLoop."No.") = true) then begin
                L_Item.Reset();
                L_Item.SetRange("No.", Temporary_SalesLine_ForLoop."No.");
                if L_Item.FindFirst() then begin
                    if Temporary_SalesLine_ForLoop.Quantity <= L_Item."Knapp Threshold Quantity" then
                        Temporary_SalesLine_ForLoop."Knapp Line" := true;
                end;
            end;

            Temporary_SalesLine_ForLoop.Insert();
        end;
    end;


    procedure CheckKnaapShippingAgentServiceFromInterimSalesHeader(_ShippingAgentCode: code[20]; _ShippingAgentServiceCode: Code[20]): Boolean
    var
        L_ShippingAgentService: Record "Shipping Agent Services";
    begin
        if (_ShippingAgentCode <> '') AND (_ShippingAgentServiceCode <> '') then begin
            L_ShippingAgentService.Reset();
            L_ShippingAgentService.SetRange("Shipping Agent Code", _ShippingAgentCode);
            L_ShippingAgentService.SetRange(Code, _ShippingAgentServiceCode);
            if L_ShippingAgentService.FindFirst() then begin
                if L_ShippingAgentService."Knapp Round" = true then
                    exit(true);
            end;
        end;

        exit(false);
    end;


    procedure ProcessTemporarySalesLinetoSalesOrder()
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        //For Manual Order++
        Temporary_SalesLine.Reset();
        Temporary_SalesLine.SetRange("Knapp Line", false);
        if Temporary_SalesLine.FindSet() then begin
            repeat
                Temporary_SalesLine_ForLoop.Reset();
                Temporary_SalesLine_ForLoop.SetRange("Knapp Line", false);
                Temporary_SalesLine_ForLoop.SetRange("Sell-to Customer No.", Temporary_SalesLine."Sell-to Customer No.");
                Temporary_SalesLine_ForLoop.SetRange("Ship-to Code", Temporary_SalesLine."Ship-to Code");
                Temporary_SalesLine_ForLoop.SetRange("Location Code", Temporary_SalesLine."Location Code");
                Temporary_SalesLine_ForLoop.SetRange("Shipment Date", Temporary_SalesLine."Shipment Date");
                Temporary_SalesLine_ForLoop.SetRange("Shipping Agent Code", Temporary_SalesLine."Shipping Agent Code");
                Temporary_SalesLine_ForLoop.SetRange("Shipping Agent Service Code", Temporary_SalesLine."Shipping Agent Service Code");
                Temporary_SalesLine_ForLoop.SetRange("System-Created Entry", false);
                if Temporary_SalesLine_ForLoop.FindSet() then begin
                    //Create Header++
                    CreateSalesHeaderFromTemporary(Temporary_SalesLine);
                    repeat
                        //Create Line++
                        CreateSalesLineFromTemporary(G_SNo, Temporary_SalesLine_ForLoop);

                        //Moved Into Web Buffer Table++
                        InsertIntoTempHeaderFromTemporary(Temporary_SalesLine_ForLoop, G_SNo);

                        Temporary_SalesLine_ForLoop."System-Created Entry" := true;
                        Temporary_SalesLine_ForLoop.Modify();
                    until Temporary_SalesLine_ForLoop.Next() = 0;
                end;
            until Temporary_SalesLine.Next() = 0;
        end;

        //For KNAAP Order+++
        Temporary_SalesLine.Reset();
        Temporary_SalesLine.SetRange("Knapp Line", true);
        if Temporary_SalesLine.FindSet() then begin
            repeat
                Temporary_SalesLine_ForLoop.Reset();
                Temporary_SalesLine_ForLoop.SetRange("Knapp Line", true);
                Temporary_SalesLine_ForLoop.SetRange("Sell-to Customer No.", Temporary_SalesLine."Sell-to Customer No.");
                Temporary_SalesLine_ForLoop.SetRange("Ship-to Code", Temporary_SalesLine."Ship-to Code");
                Temporary_SalesLine_ForLoop.SetRange("Location Code", Temporary_SalesLine."Location Code");
                Temporary_SalesLine_ForLoop.SetRange("Shipment Date", Temporary_SalesLine."Shipment Date");
                Temporary_SalesLine_ForLoop.SetRange("Shipping Agent Code", Temporary_SalesLine."Shipping Agent Code");
                Temporary_SalesLine_ForLoop.SetRange("Shipping Agent Service Code", Temporary_SalesLine."Shipping Agent Service Code");
                Temporary_SalesLine_ForLoop.SetRange("System-Created Entry", false);
                if Temporary_SalesLine_ForLoop.FindSet() then begin
                    //Create Header++
                    CreateSalesHeaderFromTemporary(Temporary_SalesLine);
                    repeat
                        //Create Line++
                        CreateSalesLineFromTemporary(G_SNo, Temporary_SalesLine_ForLoop);

                        //Moved Into Web Buffer Table++
                        InsertIntoTempHeaderFromTemporary(Temporary_SalesLine_ForLoop, G_SNo);

                        Temporary_SalesLine_ForLoop."System-Created Entry" := true;
                        Temporary_SalesLine_ForLoop.Modify();
                    until Temporary_SalesLine_ForLoop.Next() = 0;
                end;
            until Temporary_SalesLine.Next() = 0;
        end;
    end;

    local procedure CreateSalesHeaderFromTemporary(_Temporary_SalesLine: Record "Sales Line" temporary)
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit "No. Series - Batch";
        L_Customer: Record Customer;
        L_GeneralSetupChannels: Record "General Setup - Channels";
    begin
        Clear(G_SNo);
        SalesRecSetup.Get();
        L_GeneralSetupChannels.Get();
        L_GeneralSetupChannels.TestField("Consolidated Sales No. Series");
        InsertedSH.Reset();
        InsertedSH.Init();
        InsertedSH.Validate("Document Type", InsertedSH."Document Type"::Order);
        //InsertedSH.Validate("No.", NoSeriesManagement.GetNextNo(SalesRecSetup."Order Nos.", WORKDATE, TRUE));
        InsertedSH.Validate("No.", NoSeriesManagement.GetNextNo(L_GeneralSetupChannels."Consolidated Sales No. Series", WORKDATE, TRUE));
        NoSeriesManagement.SaveState();
        InsertedSH.Validate("IRP Order", true);
        InsertedSH.Validate("Web Order", true);
        InsertedSH.Validate("Sell-to Customer No.", _Temporary_SalesLine."Sell-to Customer No.");
        InsertedSH.Validate("Posting Date", _Temporary_SalesLine."FA Posting Date");
        InsertedSH.Validate("Order Date", _Temporary_SalesLine."FA Posting Date");
        InsertedSH.Validate("Document Date", _Temporary_SalesLine."FA Posting Date");
        InsertedSH.Validate("Knapp Order", _Temporary_SalesLine."Knapp Line");

        L_Customer.Reset();
        L_Customer.SetRange("No.", _Temporary_SalesLine."Sell-to Customer No.");
        if L_Customer.FindFirst() then begin
            InsertedSH."Knapp Customer" := L_Customer."Knapp Customer";
        end;
        InsertedSH.Insert(true);

        //Update Shipment date and Location++
        InsertedSH.Validate("Shipping Agent Code", _Temporary_SalesLine."Shipping Agent Code");
        InsertedSH.Validate("Shipping Agent Service Code", _Temporary_SalesLine."Shipping Agent Service Code");

        // L_Customer.Reset();
        // L_Customer.SetRange("No.", _Temporary_SalesLine."Sell-to Customer No.");
        // if L_Customer.FindFirst() then begin
        //     InsertedSH.Validate("Weekend Shipping Agent Code", L_Customer."Weekend Shipping Agent Code");
        //     InsertedSH.Validate("Weekend Ship. Agnt. Serv. Code", L_Customer."Weekend Ship. Agnt. Serv. Code");
        // end;

        InsertedSH.Validate("Location Code", _Temporary_SalesLine."Location Code");
        InsertedSH.Validate("Shipment Date", _Temporary_SalesLine."Shipment Date");

        if InsertedSH."Knapp Order" = true then begin
            InsertedSH.Validate("Posting No.", NoSeriesManagement.GetNextNo(InsertedSH."Posting No. Series", WORKDATE, TRUE));
            NoSeriesManagement.SaveState();
        end;

        InsertedSH.Modify();
        G_SalesHeaderCreated := true;
        G_SNo := InsertedSH."No.";
    end;


    local procedure CreateSalesLineFromTemporary(_SalesOrderNo: Code[20]; _Temporary_SalesLine: Record "Sales Line" temporary)
    var
        InsertedSL: Record "Sales Line";
        L_Item: Record Item;
        CU_KnappGenerateDocuments: Codeunit "Knapp Generate Documents";
        L_Location: Record Location;
        L_Zone: Record Zone;
        SalesHeader: Record "Sales Header";
    begin
        // InsertedSL.Reset();
        // InsertedSL.SetRange("Document Type", InsertedSL."Document Type"::Order);
        // InsertedSL.SetRange("Document No.", _SalesOrderNo);
        // InsertedSL.SetRange("No.", _Temporary_SalesLine."No.");
        // InsertedSL.SetRange(Type, InsertedSL.Type::Item);
        // if InsertedSL.FindFirst() then begin
        //     InsertedSL.Validate(Quantity, InsertedSL.Quantity + _Temporary_SalesLine.Quantity);
        //     InsertedSL.Modify(true);
        // end else begin
        //     InsertedSL.Init();
        //     InsertedSL.VALIDATE("Document Type", InsertedSL."Document Type"::Order);
        //     InsertedSL.VALIDATE("Document No.", _SalesOrderNo);
        //     InsertedSL.VALIDATE("Line No.", GetLastLineNo(_SalesOrderNo));
        //     InsertedSL.VALIDATE(Type, InsertedSL.Type::Item);
        //     InsertedSL.VALIDATE("No.", _Temporary_SalesLine."No.");
        //     InsertedSL.VALIDATE(Quantity, _Temporary_SalesLine.Quantity);
        //     InsertedSL.Validate("Location Code", _Temporary_SalesLine."Location Code");
        //     InsertedSL.Validate("Knapp Line", _Temporary_SalesLine."Knapp Line");
        //     L_Item.Reset();
        //     L_Item.SetRange("No.", _Temporary_SalesLine."No.");
        //     if L_Item.FindFirst() then
        //         InsertedSL.Validate("Knapp Item", L_Item."Knapp Item");
        //     InsertedSL.Insert(true);
        // end;

        //New Code++
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("No.", _SalesOrderNo);
        if SalesHeader.FindFirst() then begin
            InsertedSL.Init();
            InsertedSL.VALIDATE("Document Type", InsertedSL."Document Type"::Order);
            InsertedSL.VALIDATE("Document No.", _SalesOrderNo);
            InsertedSL.VALIDATE("Line No.", GetLastLineNo(_SalesOrderNo));
            InsertedSL.VALIDATE(Type, InsertedSL.Type::Item);
            InsertedSL.VALIDATE("No.", _Temporary_SalesLine."No.");
            InsertedSL.VALIDATE(Quantity, _Temporary_SalesLine.Quantity);
            InsertedSL.Validate("Location Code", _Temporary_SalesLine."Location Code");
            InsertedSL.Validate("Knapp Line", _Temporary_SalesLine."Knapp Line");
            L_Item.Reset();
            L_Item.SetRange("No.", _Temporary_SalesLine."No.");
            if L_Item.FindFirst() then
                InsertedSL.Validate("Knapp Item", L_Item."Knapp Item");

            InsertedSL."Changed UnitPrice" := _Temporary_SalesLine."Changed UnitPrice";
            if _Temporary_SalesLine."Changed UnitPrice" = true then
                InsertedSL.Validate("Unit Price", _Temporary_SalesLine."Unit Price");
            InsertedSL.Insert(true);
        end;
    end;


    local procedure InsertIntoTempHeaderFromTemporary(_Temporary_SalesLine_ForLoop: Record "Sales Line" temporary; SalesNo: Code[20])
    var
        TempSalesHeader: Record "Web Buffer";
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetFilter("No.", _Temporary_SalesLine_ForLoop."Temp Web Order No.");
        if L_InterimSalesHeader.FindSet() then begin
            repeat
                TempSalesHeader.RESET;
                TempSalesHeader.SETRANGE("Web Document No.", L_InterimSalesHeader."No.");
                TempSalesHeader.SETRANGE("Sales Document No.", SalesNo);
                IF NOT TempSalesHeader.FINDFIRST THEN BEGIN
                    TempSalesHeader.INIT;
                    TempSalesHeader."Web Document No." := L_InterimSalesHeader."No.";
                    TempSalesHeader."Sales Document No." := SalesNo;
                    TempSalesHeader.INSERT;
                END;
            until L_InterimSalesHeader.Next() = 0;
        end;
    end;
    //--------------------------------------------------------------Consolidate Sales -------------------------------------------------------
    //---------------------------------------------------------------------------------------------------------------------------------------




    procedure SendRequesttoCreateOrders(_InterimSH: Record "Interim Sales Header")
    var
        Tradpartner: Record "Trade Partner";
        L_LastCustomerNo: Code[50];
        L_LastShipToCode: Code[20];
        L_InterimSL: Record "Interim Sales Line";
        L_ExistSalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Released_SalesHeader: Record "Sales Header";
        L_InterimHeader: Record "Interim Sales Header";
        WebOrderMgt: Codeunit "Process Web Order";
        L_SalesLine: Record "Sales Line";
        L_Item: Record Item;
    begin
        if Not CheckSalesHeaderExist_But_InventoryPick_And_PostedInventoryPickNotExist(_InterimSH) then begin
            Clear(G_SalesHeaderCreated);
            Clear(G_SNo);
        end;

        L_InterimSL.Reset();
        L_InterimSL.SetRange("Document Type", _InterimSH."Document Type");
        L_InterimSL.SetRange("Document No", _InterimSH."No.");
        //L_InterimSL.SetFilter("Reason Message", '%1', 'Successful'); //Need to check partialy quantity filter
        if L_InterimSL.FindSet() then begin
            repeat
                if Not G_SalesHeaderCreated then
                    CreateSalesHeader(_InterimSH);

                if G_SNo <> '' then begin
                    L_ExistSalesHeader.Reset();
                    L_ExistSalesHeader.SetRange("No.", G_SNo);
                    L_ExistSalesHeader.SetRange("Document Type", L_ExistSalesHeader."Document Type"::Order);
                    if L_ExistSalesHeader.FindFirst() then begin

                        //This field use for Tracking on SO++
                        if L_ExistSalesHeader."Marged Web Order" = false then begin
                            L_ExistSalesHeader."Marged Web Order" := true;
                            L_ExistSalesHeader.Modify();
                        end;

                        //Create Lines++
                        CreateSalesLine(L_ExistSalesHeader, L_InterimSL);

                    end;
                end else begin
                    //Create Line++    
                    CreateSalesLine(InsertedSH, L_InterimSL);
                end;
            until L_InterimSL.Next() = 0;


            ///////////////////++++++++++++++++++++++++++++++++++
            if G_SNo <> '' then begin
                //Check Threshold Quantity and make KNAPP Line++
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document No.", G_SNo);
                L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                if L_SalesLine.FindSet() then begin
                    repeat
                        L_Item.Reset();
                        L_Item.SetRange("No.", L_SalesLine."No.");
                        L_Item.SetRange("Knapp Item", true);
                        if L_Item.FindFirst() then begin
                            if L_Item."Knapp Threshold Quantity" <> 0 then begin
                                if L_SalesLine.Quantity < L_Item."Knapp Threshold Quantity" then begin
                                    L_SalesLine.Validate("Knapp Line", true);
                                    L_SalesLine.Modify();
                                end
                                else begin
                                    L_SalesLine.Validate("Knapp Line", false);
                                    L_SalesLine.Modify();
                                end;
                            end else begin
                                L_SalesLine.Validate("Knapp Line", true);
                                L_SalesLine.Modify();
                            end;
                        end;
                    until L_SalesLine.Next() = 0;
                end;

                //Moved Into Web Buffer Table++
                L_ExistSalesHeader.Reset();
                L_ExistSalesHeader.SetRange("No.", G_SNo);
                L_ExistSalesHeader.SetRange("Document Type", L_ExistSalesHeader."Document Type"::Order);
                if L_ExistSalesHeader.FindFirst() then
                    InsertIntoTempHeader(_InterimSH."No.", L_ExistSalesHeader."No.");

            end else begin
                //Check Threshold Quantity and make KNAPP Line++
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document No.", InsertedSH."No.");
                L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                if L_SalesLine.FindSet() then begin
                    repeat
                        L_Item.Reset();
                        L_Item.SetRange("No.", L_SalesLine."No.");
                        L_Item.SetRange("Knapp Item", true);
                        if L_Item.FindFirst() then begin
                            if L_Item."Knapp Threshold Quantity" <> 0 then begin
                                if L_SalesLine.Quantity < L_Item."Knapp Threshold Quantity" then begin
                                    L_SalesLine.Validate("Knapp Line", true);
                                    L_SalesLine.Modify();
                                end
                                else begin
                                    L_SalesLine.Validate("Knapp Line", false);
                                    L_SalesLine.Modify();
                                end;
                            end else begin
                                L_SalesLine.Validate("Knapp Line", true);
                                L_SalesLine.Modify();
                            end;
                        end;
                    until L_SalesLine.Next() = 0;
                end;

                //Moved Into Web Buffer Table++
                InsertIntoTempHeader(_InterimSH."No.", InsertedSH."No.");
            end;
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

    local procedure CheckSalesHeaderExist_But_InventoryPick_And_PostedInventoryPickNotExist(_InterimSH: Record "Interim Sales Header"): Boolean
    var
        L_SalesHeader: Record "Sales Header";
    begin
        Clear(G_SNo);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Sell-to Customer No.", _InterimSH."Sell-to Customer No.");
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("Shipment Date", _InterimSH."Shipment Date");
        L_SalesHeader.SetRange("Location Code", _InterimSH."Location Code");
        L_SalesHeader.SetRange("Shipping Agent Code", _InterimSH."Shipping Agent Code");
        L_SalesHeader.SetRange("Shipping Agent Service Code", _InterimSH."Shipping Agent Service Code");
        L_SalesHeader.SetRange("Weekend Ship. Agnt. Serv. Code", _InterimSH."Weekend Ship Agent Serv Code");
        L_SalesHeader.SetRange("IRP Order", true);
        if L_SalesHeader.FindSet() then begin
            repeat
                //Check Inventory Pick is available+
                if not CheckInventoryPick(L_SalesHeader) then begin

                    //Check Posted Inventory Pick is Availabel+
                    if not CheckPostedInventoryPick(L_SalesHeader) then begin
                        G_SalesHeaderCreated := true;
                        G_SNo := L_SalesHeader."No.";
                        exit(true);
                    end;
                end;
            until L_SalesHeader.Next() = 0;

            exit(false);
        end;
    end;

    local procedure CheckInventoryPick(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_WarehouseActivityHeader: Record "Warehouse Activity Header";
    begin
        L_WarehouseActivityHeader.Reset();
        L_WarehouseActivityHeader.SetRange(Type, L_WarehouseActivityHeader.Type::"Invt. Pick");
        L_WarehouseActivityHeader.SetRange("Source Document", L_WarehouseActivityHeader."Source Document"::"Sales Order");
        L_WarehouseActivityHeader.SetRange("Source No.", _SalesHeader."No.");
        if not L_WarehouseActivityHeader.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CheckPostedInventoryPick(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_PostedInvtPickHeader: Record "Posted Invt. Pick Header";
    begin
        L_PostedInvtPickHeader.Reset();
        L_PostedInvtPickHeader.SetRange("Source Document", L_PostedInvtPickHeader."Source Document"::"Sales Order");
        L_PostedInvtPickHeader.SetRange("Source No.", _SalesHeader."No.");
        if not L_PostedInvtPickHeader.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreateSalesHeader(_InterimSalesHeader: Record "Interim Sales Header")
    var
        SalesRecSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit "No. Series";
        L_Customer: Record Customer;
    begin
        SalesRecSetup.Get();
        InsertedSH.Reset();
        InsertedSH.Init();
        InsertedSH.Validate("Document Type", InsertedSH."Document Type"::Order);
        InsertedSH.Validate("No.", NoSeriesManagement.GetNextNo(SalesRecSetup."Order Nos.", WORKDATE, TRUE));
        InsertedSH.Validate("Sell-to Customer No.", _InterimSalesHeader."Sell-to Customer No.");
        InsertedSH.Validate("Posting Date", InsertedSH."Order Date");
        InsertedSH.Validate("Order Date", InsertedSH."Order Date");
        InsertedSH.Validate("Document Date", InsertedSH."Order Date");
        L_Customer.Reset();
        L_Customer.SetRange("No.", _InterimSalesHeader."Sell-to Customer No.");
        if L_Customer.FindFirst() then
            InsertedSH."Knapp Customer" := L_Customer."Knapp Customer";

        InsertedSH.Validate("IRP Order", true);
        InsertedSH.Validate("Web Order", true);
        InsertedSH.Insert(true);

        //Update Shipment date and Location++
        InsertedSH.Validate("Shipping Agent Code", _InterimSalesHeader."Shipping Agent Code");
        InsertedSH.Validate("Shipping Agent Service Code", _InterimSalesHeader."Shipping Agent Service Code");
        InsertedSH.Validate("Weekend Ship. Agnt. Serv. Code", _InterimSalesHeader."Weekend Ship Agent Serv Code");
        InsertedSH.Validate("Location Code", _InterimSalesHeader."Location Code");
        InsertedSH.Validate("Shipment Date", _InterimSalesHeader."Shipment Date");
        InsertedSH.Modify();
        G_SalesHeaderCreated := true;
    end;

    local procedure CreateSalesLine(_SalesHeader: Record "Sales Header"; _InterimSalesLine: Record "Interim Sales Line")
    var
        InsertedSL: Record "Sales Line";
        L_Item: Record Item;
        CU_KnappGenerateDocuments: Codeunit "Knapp Generate Documents";
        L_Location: Record Location;
        L_Zone: Record Zone;
    begin
        InsertedSL.Reset();
        InsertedSL.SetRange("Document Type", InsertedSL."Document Type"::Order);
        InsertedSL.SetRange("Document No.", _SalesHeader."No.");
        InsertedSL.SetRange("No.", _InterimSalesLine."No.");
        InsertedSL.SetRange(Type, InsertedSL.Type::Item);
        InsertedSL.SetRange("Sent to Knapp", false);
        if InsertedSL.FindFirst() then begin
            InsertedSL.Validate(Quantity, InsertedSL.Quantity + _InterimSalesLine."Qty. to Deliver");
            InsertedSL.Modify(true);
        end else begin
            InsertedSL.Init();
            InsertedSL.VALIDATE("Document Type", InsertedSL."Document Type"::Order);
            InsertedSL.VALIDATE("Document No.", _SalesHeader."No.");
            InsertedSL.VALIDATE("Line No.", GetLastLineNo(_SalesHeader."No."));
            InsertedSL.VALIDATE(Type, InsertedSL.Type::Item);
            InsertedSL.VALIDATE("No.", _InterimSalesLine."No.");
            InsertedSL.VALIDATE(Quantity, _InterimSalesLine."Qty. to Deliver");
            L_Item.Reset();
            L_Item.SetRange("No.", _InterimSalesLine."No.");
            if L_Item.FindFirst() then
                InsertedSL.Validate("Knapp Item", L_Item."Knapp Item");

            //We are using one location setup For Purchase and Sales++
            InsertedSL.Validate("Location Code", _SalesHeader."Location Code");


            //Below are the conditions
            //1. If Customer is KNAPP, only then check validations in Sales line level
            //2. If Customer is not KNAPP, then the entire SO will be a Manual Pick. Need to still have a separate Fridge and CD Picks.
            //3. KNAPP Item – If Customer is KNAPP and Item is not KNAPP, then Manual Pick
            //4. KNAPP Route – If Customer is KNAPP and Shipping Agent Service Code is not KNAPP, then Manual Pick
            //5. If Item is KNAPP and below Threshold then send it KNAPP
            //6. If Item is KNAPP and over Threshold, then Manual Pick (SH/Unit1)
            //7. If Item is not KNAPP, then always Manual Pick (SH/Unit1)
            //9. Fridge – Always separate Pick irrespective of KNAPP or Manual Pick
            //10. CD – Always separate Pick irrespective of KNAPP or Manual Pick
            //11. If the qty is above the Threshold on item card, then system has to automatically suggest SH/Unit1 else HDH
            //13. Potentially we don’t have to assign Variants on SO, it has to auto-fill based on the Inventory Pick post

            //Knapp Customer++
            //Knapp Customer++
            if (CheckKnaapCustomer(InsertedSL."Sell-to Customer No.") = true) AND (CheckKnaapShippingAgentService(_SalesHeader) = true) AND (CheckKnaapItem(InsertedSL."No.") = true) then
                InsertedSL.Validate("Knapp Line", true);
            // if (CheckKnaapCustomer(InsertedSL."Sell-to Customer No.") = true) AND (CheckKnaapShippingAgentService(_SalesHeader) = true) then begin
            //     if (CheckKnaapItem(InsertedSL."No.") = true) then begin
            //         //KNAPP
            //         L_Zone.Reset();
            //         L_Zone.SetRange("Knapp Zone", true);
            //         if L_Zone.FindFirst() then begin
            //             InsertedSL.Validate("Bin Code", GetBinCodeFromBincontent(InsertedSL, _SalesHeader, L_Zone));
            //             InsertedSL.Validate("Knapp Line", true);
            //         end else
            //             Error('Knaap Zone is not available in BC. Please create and try again');
            //     end;


            //     //Manual++
            //     if (CheckKnaapItem(InsertedSL."No.") = false) then begin
            //         L_Zone.Reset();
            //         L_Zone.SetRange("Knapp Zone", false);
            //         if L_Zone.FindFirst() then begin
            //             InsertedSL.Validate("Bin Code", GetBinCodeFromBincontent(InsertedSL, _SalesHeader, L_Zone));
            //         end else
            //             Error('Manual Zone is not available in BC. Please create and try again');
            //     end;
            // end else begin
            //     //Manual++
            //     L_Zone.Reset();
            //     L_Zone.SetRange("Knapp Zone", false);
            //     if L_Zone.FindFirst() then begin
            //         InsertedSL.Validate("Bin Code", GetBinCodeFromBincontent(InsertedSL, _SalesHeader, L_Zone));
            //     end else
            //         Error('Manual Zone is not available in BC. Please create and try again');
            // end;
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


    procedure CheckKnaapCustomer(_CustomerNo: Code[20]): Boolean
    var
        L_Customer: Record Customer;
    begin
        if L_Customer.Get(_CustomerNo) then
            if L_Customer."Knapp Customer" = true then
                exit(true);
        exit(false);
    end;

    procedure CheckKnaapItem(_ItemNo: Code[20]): Boolean
    var
        L_Item: Record Item;
    begin
        if L_Item.Get(_ItemNo) then
            if L_Item."Knapp Item" = true then
                exit(true);
        exit(false);
    end;

    procedure CheckKnaapShippingAgentService(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_ShippingAgentService: Record "Shipping Agent Services";
    begin
        if (_SalesHeader."Shipping Agent Code" <> '') AND (_SalesHeader."Shipping Agent Service Code" <> '') then begin
            L_ShippingAgentService.Reset();
            L_ShippingAgentService.SetRange("Shipping Agent Code", _SalesHeader."Shipping Agent Code");
            L_ShippingAgentService.SetRange(Code, _SalesHeader."Shipping Agent Service Code");
            if L_ShippingAgentService.FindFirst() then begin
                if L_ShippingAgentService."Knapp Round" = true then
                    exit(true);
            end;
        end;

        exit(false);
    end;


    local procedure GetBinCodeFromBincontent(_SalesLine: Record "Sales Line"; _SalesHeader: Record "Sales Header"; _Zone: Record Zone): Code[20]
    var
        L_BinContent: Record "Bin Content";
        L_Bin: Record Bin;
        L_Item: Record Item;
    begin
        L_BinContent.Reset();
        L_BinContent.SetRange("Location Code", _SalesHeader."Location Code");
        L_BinContent.SetRange("Zone Code", _Zone.Code);
        L_BinContent.SetRange("Item No.", _SalesLine."No.");
        L_BinContent.SetRange("Unit of Measure Code", _SalesLine."Unit of Measure Code");
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        if L_Item.Get(_SalesLine."No.") then
            if L_Item."Warehouse Class Code" <> '' then
                L_BinContent.SetRange("Warehouse Class Code", L_Item."Warehouse Class Code");
        if L_BinContent.FindFirst() then begin
            if L_BinContent.CalcQtyAvailToTakeUOM() > 0 then begin
                exit(L_BinContent."Bin Code")
            end;
        end else begin
            L_Bin.Reset();
            L_Bin.SetRange("Location Code", _SalesHeader."Location Code");
            L_Bin.SetRange("Zone Code", _Zone.Code);
            L_Bin.SetRange(Empty, false);
            if L_Bin.FindFirst() then begin
                exit(L_Bin.Code)
            end;
        end;
    end;
}