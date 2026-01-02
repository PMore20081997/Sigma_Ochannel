report 90003 "Check & Split Order"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;


    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            RequestFilterFields = "No.";
            trigger OnAfterGetRecord()
            var
                SalesHeaderLoop: Record "Sales Header";
                L_KNAPPLine: Record "Sales Line";
                NewSalesHeader: Record "Sales Header";
                L_ReleaseSalesHeader: Record "Sales Header";
                CU_ReleaseSalesDoc: Codeunit "Release Sales Document";
            begin
                if IsSplitRquired("Sales Header") then begin
                    SalesHeaderLoop.Reset();
                    SalesHeaderLoop.SetRange("Document Type", "Sales Header"."Document Type");
                    SalesHeaderLoop.SetRange("No.", "Sales Header"."No.");
                    if SalesHeaderLoop.FindFirst() then begin
                        //Reopen Order+++
                        if SalesHeaderLoop.Status = SalesHeaderLoop.Status::Released then begin
                            CU_ReleaseSalesDoc.PerformManualReopen(SalesHeaderLoop);
                            //SalesHeaderLoop.PerformManualReopen(SalesHeaderLoop);
                        end;


                        #Region Split Process++
                        Clear(NewSalesHeader);
                        NewSalesHeader.Reset();
                        L_KNAPPLine.Reset();
                        L_KNAPPLine.SetRange("Document Type", SalesHeaderLoop."Document Type");
                        L_KNAPPLine.SetRange("Document No.", SalesHeaderLoop."No.");
                        L_KNAPPLine.SetRange(Type, L_KNAPPLine.Type::Item);
                        L_KNAPPLine.SetRange("Knapp Line", true);
                        L_KNAPPLine.SetFilter(Quantity, '>%1', 0);
                        if L_KNAPPLine.FindSet() then begin
                            //Creatr New Header+++
                            CreateNewSH(NewSalesHeader, SalesHeaderLoop);

                            //Create Move Lines to New Header++
                            repeat
                                MoveLinesToNewHeader(NewSalesHeader, L_KNAPPLine)
                            until L_KNAPPLine.Next() = 0;

                            //Delete Lines+++
                            L_KNAPPLine.DeleteAll(true);

                            //Released New Sales Order++
                            CU_ReleaseSalesDoc.PerformManualRelease(NewSalesHeader);
                        end;
                        #EndRegion Split Process++



                        //Released Order++
                        L_ReleaseSalesHeader.Reset();
                        L_ReleaseSalesHeader.SetRange("No.", SalesHeaderLoop."No.");
                        L_ReleaseSalesHeader.SetRange("Document Type", SalesHeaderLoop."Document Type");
                        if L_ReleaseSalesHeader.FindFirst() then begin
                            CU_ReleaseSalesDoc.PerformManualRelease(L_ReleaseSalesHeader);
                        end;
                    end;

                    //Stop process and Update Boolean++
                    SalesHeaderLoop.Reset();
                    SalesHeaderLoop.SetRange("Document Type", "Sales Header"."Document Type");
                    SalesHeaderLoop.SetRange("No.", "Sales Header"."No.");
                    if SalesHeaderLoop.FindFirst() then begin
                        SalesHeaderLoop."Check & Split Order" := true;
                        L_SplitOrder := true;
                        SalesHeaderLoop."Reference Sales Order" := NewSalesHeader."No.";
                        SalesHeaderLoop.Modify();
                        Commit();
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                "Sales Header".CalcFields("Drop/Special Order", "Special Order", "Inv. Pick Exist", Shipped);
                //"Sales Header".SetFilter("Order Date", '%1', OrderDateFilter);
                "Sales Header".SetRange("Document Type", "Sales Header"."Document Type"::Order);
                "Sales Header".SetRange(Status, "Sales Header".Status::Released);
                "Sales Header".SetRange("Web Order", false);
                "Sales Header".SetRange("Drop/Special Order", false);
                "Sales Header".SetRange("Special Order", false);
                "Sales Header".SetRange("Inv. Pick Exist", false);
                "Sales Header".SetRange(Shipped, false);
                "Sales Header".SetRange("Knapp Order", false);
                "Sales Header".SetRange("Check & Split Order", false);
            end;

            trigger OnPostDataItem()
            begin
                if L_SplitOrder = true then
                    Message('Split process completed')
                else
                    Message('Nothing to Split');
            end;

        }
    }

    // requestpage
    // {
    //     AboutTitle = 'Teaching tip title';
    //     AboutText = 'Teaching tip content';
    //     layout
    //     {
    //         area(Content)
    //         {
    //             group(Option)
    //             {
    //                 field(OrderDateFilter; OrderDateFilter)
    //                 {
    //                     Caption = 'Order Date: ';
    //                     ApplicationArea = All;
    //                 }
    //             }
    //         }
    //     }

    //     trigger OnQueryClosePage(CloseAction: Action): Boolean
    //     begin
    //         if CloseAction = CloseAction::OK then begin
    //             if OrderDateFilter = 0D then
    //                 Error('Order Date should not be blank');
    //         end;
    //     end;
    // }

    var
        myInt: Integer;
        OrderDateFilter: Date;

    local procedure IsSplitRquired(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_SalesLine: Record "Sales Line";
        L_LocationCode: Record Location;
    begin
        //If Any Line Marked as TOS++
        L_SalesLine.Reset();
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
        L_SalesLine.SetRange("Document No.", _SalesHeader."No.");
        L_SalesLine.SetFilter("Unable to Pick", '<>%1', '');
        if L_SalesLine.FindFirst() then
            exit(false);

        //Check if location code is saleable++
        L_LocationCode.Reset();
        L_LocationCode.SetRange(Code, _SalesHeader."Location Code");
        if L_LocationCode.FindFirst() then begin
            if L_LocationCode."Saleable Location" = false then
                exit(false);
        end;


        L_SalesLine.Reset();
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
        L_SalesLine.SetRange("Document No.", _SalesHeader."No.");
        L_SalesLine.SetRange("Knapp Line", true);
        if L_SalesLine.FindFirst() then begin
            L_SalesLine.Reset();
            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
            L_SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
            L_SalesLine.SetRange("Document No.", _SalesHeader."No.");
            L_SalesLine.SetRange("Knapp Line", false);
            if L_SalesLine.FindFirst() then
                exit(true)
            else
                exit(false);
        end else
            exit(false);

    end;

    local procedure CreateNewSH(var _NewSalesHeader: Record "Sales Header"; var _ExistingHeader: Record "Sales Header")
    var
        L_Location: Record Location;
        SalesAndRecSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit "No. Series";
    begin
        SalesAndRecSetup.Reset();
        SalesAndRecSetup.Get();


        _NewSalesHeader.Init();
        _NewSalesHeader.TransferFields(_ExistingHeader);
        //_NewSalesHeader.Validate("No.", _NewSalesHeader."No." + '_1');
        _NewSalesHeader.Validate("No.", NoSeriesManagement.GetNextNo(SalesAndRecSetup."Order Nos.", WORKDATE, TRUE));
        _NewSalesHeader.Validate("Knapp Order", true);
        L_Location.Reset();
        L_Location.SetRange("Knapp Location", true);
        if L_Location.FindFirst() then
            _NewSalesHeader.Validate("Location Code", L_Location.Code)
        else
            Error('Knapp Location is missing');
        _NewSalesHeader."Check & Split Order" := true;
        _NewSalesHeader."Reference Sales Order" := _ExistingHeader."No.";
        _NewSalesHeader.Insert(true);

        //After Insert Modify Shipemnt Date++
        _NewSalesHeader.Validate("No. Series", _ExistingHeader."No. Series");
        _NewSalesHeader.Validate("Shipment Date", _ExistingHeader."Shipment Date");
        _NewSalesHeader.Modify();
    end;

    local procedure MoveLinesToNewHeader(_SalesHeader: Record "Sales Header"; _SalesLine: Record "Sales Line")
    var
        L_NewSalesLine: Record "Sales Line";
    begin
        L_NewSalesLine.Init();
        L_NewSalesLine.TransferFields(_SalesLine);
        L_NewSalesLine.Validate("Document No.", _SalesHeader."No.");
        L_NewSalesLine.Validate("Line No.", GetLastLineNo(_SalesHeader."No."));
        L_NewSalesLine.Validate("Location Code", _SalesHeader."Location Code");
        // L_NewSalesLine.VALIDATE("Document Type", _SalesHeader."Document Type");
        // L_NewSalesLine.VALIDATE("Document No.", _SalesHeader."No.");
        // L_NewSalesLine.VALIDATE("Line No.", GetLastLineNo(_SalesHeader."No."));
        // L_NewSalesLine.VALIDATE(Type, L_NewSalesLine.Type::Item);
        // L_NewSalesLine.VALIDATE("No.", _SalesLine."No.");
        // L_NewSalesLine.VALIDATE(Quantity, _SalesLine.Quantity);
        // L_NewSalesLine.Validate("Knapp Line", _SalesLine."Knapp Line");
        // L_NewSalesLine.Validate("Knapp Item", _SalesLine."Knapp Item");
        // if _SalesLine."Variant Code" <> '' then
        //     L_NewSalesLine.Validate("Variant Code", _SalesLine."Variant Code");
        // L_NewSalesLine."Changed UnitPrice" := _SalesLine."Changed UnitPrice";
        // L_NewSalesLine.Validate("Unit Price", _SalesLine."Unit Price");
        L_NewSalesLine.Insert(true);
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


    var
        L_SplitOrder: Boolean;

}