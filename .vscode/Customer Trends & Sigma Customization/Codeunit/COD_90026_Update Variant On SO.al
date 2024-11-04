//This is CodeUnit Used for Update Varaint On SO++
//GHOST Product Customization++
//DOnt Use For Other Process 
codeunit 90026 "Udate Variant on SO"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure CheckTotalAvailablityQty(_SalesLine: Record "Sales Line"): Decimal
    var
        L_ItemVariant: Record "Item Variant";
        L_TotalInventory: Decimal;
        L_TotalRequestedQty: Decimal;
    begin
        // Clear(L_TotalInventory);
        // Clear(L_TotalRequestedQty);
        // L_ItemVariant.Reset();
        // L_ItemVariant.SetRange("Item No.", _SalesLine."No.");
        // if L_ItemVariant.FindSet() then begin
        //     repeat
        //         L_ItemVariant.CalcFields(Inventory, "Total Requested Quantity");
        //         L_TotalInventory += L_ItemVariant.Inventory;
        //         L_TotalRequestedQty += L_ItemVariant."Total Requested Quantity";
        //     until L_ItemVariant.Next() = 0;
        //     if L_TotalInventory > 0 then
        //         exit(L_TotalInventory - L_TotalRequestedQty)
        //     else
        //         exit(0);
        // end else
        //     exit(0);

        //New Code++
        Clear(L_TotalInventory);
        Clear(L_TotalRequestedQty);
        L_ItemVariant.Reset();
        L_ItemVariant.SetRange("Item No.", _SalesLine."No.");
        L_ItemVariant.SetRange("Location Filter", _SalesLine."Location Code");
        L_ItemVariant.SetRange(Blocked, false);
        L_ItemVariant.SetRange("Sales Blocked", false);
        if L_ItemVariant.FindSet() then begin
            repeat
                L_ItemVariant.CalcFields("Qty on SO(Saleable)", "Saleable Inventory");
                L_TotalInventory += L_ItemVariant."Saleable Inventory";
                L_TotalRequestedQty += L_ItemVariant."Qty on SO(Saleable)";
            until L_ItemVariant.Next() = 0;
            if L_TotalInventory > 0 then
                if (L_TotalInventory - L_TotalRequestedQty) > 0 then
                    exit(L_TotalInventory - L_TotalRequestedQty)
                else
                    exit(0)
            else
                exit(0);
        end else
            exit(0);
    end;


    procedure UpdateAvaibleQty(_SalesLine: Record "Sales Line")
    var
        L_ItemVariant: Record "Item Variant";
    begin
        // L_ItemVariant.Reset();
        // L_ItemVariant.SetRange("Item No.", _SalesLine."No.");
        // if L_ItemVariant.FindSet() then
        //     repeat
        //         L_ItemVariant.CalcFields(Inventory, "Total Requested Quantity");
        //         L_ItemVariant.Quantity := L_ItemVariant.Inventory - L_ItemVariant."Total Requested Quantity";
        //         L_ItemVariant.Modify();
        //     until L_ItemVariant.Next() = 0;

        //New Code++
        L_ItemVariant.Reset();
        L_ItemVariant.SetRange("Item No.", _SalesLine."No.");
        L_ItemVariant.SetFilter("Location Filter", _SalesLine."Location Code");
        L_ItemVariant.SetRange(Blocked, false);
        L_ItemVariant.SetRange("Sales Blocked", false);
        if L_ItemVariant.FindSet() then
            repeat
                L_ItemVariant.CalcFields("Saleable Inventory", "Qty on SO(Saleable)");
                if (L_ItemVariant."Saleable Inventory" - L_ItemVariant."Qty on SO(Saleable)") > 0 then
                    L_ItemVariant.Quantity := L_ItemVariant."Saleable Inventory" - L_ItemVariant."Qty on SO(Saleable)"
                else
                    L_ItemVariant.Quantity := 0;
                L_ItemVariant.Modify();
            until L_ItemVariant.Next() = 0;
    end;

    procedure SetPriorityWithoutZero(_SalesLine: Record "Sales Line"; var _ItemVariant: Record "Item Variant")
    begin
        Clear(_ItemVariant);
        _ItemVariant.Reset();
        _ItemVariant.SetRange("Item No.", _SalesLine."No.");
        _ItemVariant.SetFilter("Location Filter", _SalesLine."Location Code");
        _ItemVariant.SetRange(Blocked, false);
        _ItemVariant.SetRange("Sales Blocked", false);
        _ItemVariant.SetFilter(Priority, '<>%1', 0);
        _ItemVariant.SetCurrentKey(Priority);
        _ItemVariant.Ascending(true);
        if _ItemVariant.FindFirst() then;
    end;


    procedure CheckTotalAvailablityQtyVariantWise(_SalesLine: Record "Sales Line"; _ItemVariant: Record "Item Variant"): Decimal
    var
        L_ItemVariant: Record "Item Variant";
        L_TotalInventory: Decimal;
        L_TotalRequestedQty: Decimal;
        LocationFilter: Text;
        L_Location: Record Location;
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
        PhysicalInventory: Decimal;
        L_ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        Clear(PhysicalInventory);
        L_ItemVariant.Reset();
        L_ItemVariant.SetRange("Item No.", _SalesLine."No.");
        L_ItemVariant.SetRange(Blocked, false);
        L_ItemVariant.SetRange("Sales Blocked", false);
        L_ItemVariant.SetRange(Code, _ItemVariant.Code);
        if L_ItemVariant.FindFirst() then begin
            L_ItemLedgerEntry.Reset();
            L_ItemLedgerEntry.SETRANGE("Item No.", _SalesLine."No.");
            L_ItemLedgerEntry.SetRange("Variant Code", _ItemVariant.Code);
            L_ItemLedgerEntry.SetRange(Open, true);
            _SalesLine.CalcFields("Saleable Location");
            if _SalesLine."Saleable Location" = false then
                L_ItemLedgerEntry.SETRANGE("Location Code", _SalesLine."Location Code")
            else
                L_ItemLedgerEntry.SETRANGE("Saleable Location", true);
            if L_ItemLedgerEntry.FindSet() then begin
                L_ItemLedgerEntry.CalcSums("Remaining Quantity");
                PhysicalInventory := L_ItemLedgerEntry."Remaining Quantity";
            end;
            if PhysicalInventory < 0 then
                PhysicalInventory := 0;


            Clear(QtyOnSO);
            L_SalesLine.Reset();
            L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
            L_SalesLine.SETRANGE("No.", _SalesLine."No.");
            L_SalesLine.SetRange("Variant Code", _ItemVariant.Code);
            L_SalesLine.SETRANGE("Saleable Location", true);
            L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
            L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
            if L_SalesLine.FindSet() then begin
                L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
            end;
            if QtyOnSO < 0 then
                QtyOnSO := 0;

            exit(PhysicalInventory - QtyOnSO);
        end else
            exit(0);
    end;

    procedure CheckTotalAvailablityQtyVariantWiseAtthetimeofcosolidation(_SalesLine: Record "Sales Line"; _ItemVariant: Record "Item Variant"): Decimal
    var
        LocationFilter: Text;
        L_Location: Record Location;
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
        PhysicalInventory: Decimal;
        L_Item: Record Item;
    begin
        //GetSaleable Location++
        Clear(LocationFilter);
        L_Location.Reset();
        L_Location.SetRange("Saleable Location", true);
        if L_Location.FindSet() then begin
            repeat
                if LocationFilter <> '' then
                    LocationFilter := LocationFilter + '|' + L_Location.Code
                else
                    LocationFilter := L_Location.Code;
            until L_Location.Next() = 0;
        end;

        //Get Physical+++
        Clear(PhysicalInventory);
        L_Item.Reset();
        L_Item.SetRange("No.", _SalesLine."No.");
        L_Item.SetRange("Variant Filter", _ItemVariant.Code);
        L_Item.SetFilter("Location Filter", LocationFilter);
        L_Item.CalcFields(Inventory);
        PhysicalInventory := L_Item.Inventory;
        if PhysicalInventory < 0 then
            PhysicalInventory := 0;

        //Get ALlocated SOs++
        Clear(QtyOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", _SalesLine."No.");
        L_SalesLine.SetRange("Variant Code", _ItemVariant.Code);
        L_SalesLine.SETRANGE("Saleable Location", true);
        L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;

        exit(PhysicalInventory - QtyOnSO);
    end;


    procedure SetPriorityWithZeroandHigherQty(_SalesLine: Record "Sales Line"; var _ItemVariant: Record "Item Variant")
    begin
        // Clear(_ItemVariant);
        // _ItemVariant.Reset();
        // _ItemVariant.SetRange("Item No.", _SalesLine."No.");
        // _ItemVariant.SetFilter(Priority, '%1', 0);
        // _ItemVariant.SetFilter(Quantity, '>%1', 0); //Quantity equal to Availble Quantity++
        // _ItemVariant.SetCurrentKey(Quantity);
        // _ItemVariant.Ascending(false);
        // if _ItemVariant.FindFirst() then;

        //New Code++
        Clear(_ItemVariant);
        _ItemVariant.Reset();
        _ItemVariant.SetRange("Item No.", _SalesLine."No.");
        _ItemVariant.SetFilter("Location Filter", _SalesLine."Location Code");
        _ItemVariant.SetRange(Blocked, false);
        _ItemVariant.SetRange("Sales Blocked", false);
        _ItemVariant.SetFilter(Priority, '%1', 0);
        _ItemVariant.SetFilter(Quantity, '>%1', 0); //Quantity equal to Availble Quantity++
        _ItemVariant.SetCurrentKey(Quantity);
        _ItemVariant.Ascending(false);
        if _ItemVariant.FindFirst() then;
    end;


    procedure InsertNewSalesLine(_SalesLine: Record "Sales Line"; _ItemVariant: Record "Item Variant"; _QtytoApply: Decimal): Decimal
    var
        L_SalesLine: Record "Sales Line";
    begin
        L_SalesLine.Init();
        L_SalesLine.Validate("Document Type", _SalesLine."Document Type");
        L_SalesLine.Validate("Document No.", _SalesLine."Document No.");
        L_SalesLine.Validate(Type, _SalesLine.Type);
        L_SalesLine.Validate("Line No.", FindLastLineNo(_SalesLine));
        L_SalesLine.Validate("No.", _SalesLine."No.");
        L_SalesLine.Validate(Quantity, _QtytoApply);
        L_SalesLine.Validate("Original Quantity", _SalesLine.Quantity);
        L_SalesLine.Validate("Location Code", _SalesLine."Location Code");
        L_SalesLine.Validate("Unit Price", _SalesLine."Unit Price");
        L_SalesLine.Validate("Variant Created By", _SalesLine."Line No."); //Original Line Number
        L_SalesLine.Insert();
    end;

    local procedure FindLastLineNo(_SalesLine: Record "Sales Line"): Integer
    var
        L_SalesLine: Record "Sales Line";
    begin
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", _SalesLine."Document Type");
        L_SalesLine.SetRange("Document No.", _SalesLine."Document No.");
        if L_SalesLine.FindLast() then
            exit(L_SalesLine."Line No." + 10000)
        else
            exit(10000);

    end;


    // procedure UpdateVariantOnSalesOrder(Var _SalesHeader: Record "Sales Header")
    // var
    //     L_SalesLine: Record "Sales Line";
    //     L_NewLineRequired: Boolean;
    //     RemQty: Decimal;
    //     CustomeCodeunit: Codeunit "Udate Variant on SO";
    //     L_ItemVariant: Record "Item Variant";
    //     L_Count: Integer;
    //     QtyToApply: Decimal;
    //     Window: Dialog;
    //     Counter: Integer;
    //     Text005: TextConst ENU = 'Updating the Variant Code...\\', ENG = 'Updating the Variant Code...\\';
    //     Text006: TextConst ENU = 'Progress', ENG = 'Progress';
    //     NoOfRecords: Integer;
    //     Count: Integer;
    // begin
    //     if _SalesHeader.IsEmpty then
    //         exit;

    //     //Start Process to Update Variant Code++
    //     Clear(NoOfRecords);
    //     Clear(Counter);
    //     Window.OPEN('Updating the Variant Code...' + ' @1@@@@@@@@@@@@@\' + 'Updating..' + ' #3##########' + 'Please Wait..');

    //     repeat
    //         NoOfRecords := _SalesHeader.Count;
    //         Counter += 1;
    //         IF NoOfRecords <= 100 THEN
    //             Window.UPDATE(1, (Counter / NoOfRecords * 10000) DIV 1)
    //         ELSE
    //             IF Count MOD (NoOfRecords DIV 100) = 0 THEN BEGIN
    //                 Window.UPDATE(1, (Counter / NoOfRecords * 10000) DIV 1)
    //             END;
    //         Window.UPDATE(3, _SalesHeader."No.");

    //         L_SalesLine.Reset();
    //         L_SalesLine.CalcFields("Variant Code mandatory");
    //         L_SalesLine.SetRange("Document Type", _SalesHeader."Document Type");
    //         L_SalesLine.SetRange("Document No.", _SalesHeader."No.");
    //         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
    //         L_SalesLine.SetFilter("Variant Code", '%1', '');
    //         L_SalesLine.SetRange("Variant Code mandatory", true);
    //         L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
    //         L_SalesLine.SetFilter("Location Code", '<>%1', '');
    //         if L_SalesLine.FindSet() then begin
    //             repeat
    //                 Clear(L_NewLineRequired);
    //                 Clear(RemQty);
    //                 //Total required quantity 
    //                 RemQty := L_SalesLine.Quantity;

    //                 //Without Zero and based on priority++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //                 //Set PriorityWithoutZero++
    //                 Clear(L_ItemVariant);
    //                 L_ItemVariant.Reset();
    //                 CustomeCodeunit.SetPriorityWithoutZero(L_SalesLine, L_ItemVariant);
    //                 Clear(L_Count);
    //                 L_Count := L_ItemVariant.Count;

    //                 //Process to update variant code and create new line if required++
    //                 if L_Count > 0 then begin
    //                     while (RemQty > 0) AND (L_Count > 0) do begin
    //                         if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) > 0 then begin
    //                             if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then begin
    //                                 if L_NewLineRequired = false then begin
    //                                     L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                                     L_SalesLine.Validate("Original Quantity", L_SalesLine.Quantity);
    //                                     L_SalesLine.Validate("Variant Created By", L_SalesLine."Line No."); //Original Line Number
    //                                     L_SalesLine.Modify();
    //                                     RemQty := RemQty - L_SalesLine.Quantity;
    //                                 end else begin
    //                                     Clear(QtyToApply);
    //                                     if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                                         QtyToApply := RemQty
    //                                     else
    //                                         QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);

    //                                     CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                                     RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                 end;
    //                             end else begin
    //                                 if L_NewLineRequired = false then begin
    //                                     L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                                     L_SalesLine.Validate(Quantity, CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant));
    //                                     L_SalesLine.Validate("Original Quantity", RemQty);
    //                                     L_SalesLine.Modify();
    //                                     RemQty := RemQty - L_SalesLine.Quantity;
    //                                     L_NewLineRequired := true;
    //                                 end else begin
    //                                     Clear(QtyToApply);
    //                                     if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                                         QtyToApply := RemQty
    //                                     else
    //                                         QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                     CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                                     RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                 end;
    //                             end;
    //                         end;

    //                         L_Count := L_Count - 1;
    //                         L_ItemVariant.Next();
    //                     end;
    //                 end;
    //             until L_SalesLine.Next() = 0;
    //         end;
    //     until _SalesHeader.Next() = 0;
    //     Window.CLOSE;
    // end;


    procedure RevalidateVariantOnSalesOrder(_SalesHeader: Record "Sales Header")
    var
        L_SalesLine: Record "Sales Line";
        RemQty: Decimal;
        CustomeCodeunit: Codeunit "Udate Variant on SO";
        L_ItemVariant: Record "Item Variant";
        L_Count: Integer;
        QtyToApply: Decimal;
        Window: Dialog;
        Counter: Integer;
        Text005: TextConst ENU = 'Updating the Variant Code...\\', ENG = 'Updating the Variant Code...\\';
        Text006: TextConst ENU = 'Progress', ENG = 'Progress';
        NoOfRecords: Integer;
        Count: Integer;
        L_ItemVariantWithFreeQty: Record "Item Variant With Free Qty" temporary;
        L_SalesHeader: Record "Sales Header";
    begin
        // Lock the tables to work on
        L_SalesLine.LockTable();

        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("No.", _SalesHeader."No.");
        L_SalesHeader.SetRange("Document Type", _SalesHeader."Document Type");
        if L_SalesHeader.FindFirst() then begin
            //Start Process to Update Variant Code++
            L_SalesLine.Reset();
            L_SalesLine.CalcFields("Variant Code mandatory");
            L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
            L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
            L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
            L_SalesLine.SetRange("Variant Code mandatory", true);
            L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
            L_SalesLine.SetFilter("Location Code", '<>%1', '');
            if L_SalesLine.FindSet() then begin
                repeat
                    //Delete++
                    L_ItemVariantWithFreeQty.Reset();
                    L_ItemVariantWithFreeQty.DeleteAll();

                    //Total required quantity 
                    Clear(RemQty);
                    RemQty := L_SalesLine.Quantity;

                    //Without Zero and based on priority++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    //Set PriorityWithoutZero++
                    Clear(L_ItemVariant);
                    L_ItemVariant.Reset();
                    CustomeCodeunit.SetPriorityWithoutZero(L_SalesLine, L_ItemVariant);
                    Clear(L_Count);
                    L_Count := L_ItemVariant.Count;

                    //Process to update variant code and create new line if required++
                    if L_Count > 0 then begin
                        while (RemQty > 0) AND (L_Count > 0) do begin
                            L_ItemVariantWithFreeQty.Init();
                            L_ItemVariantWithFreeQty.Priority := L_ItemVariant.Priority;
                            L_ItemVariantWithFreeQty."Item No." := L_ItemVariant."Item No.";
                            L_ItemVariantWithFreeQty."Variant Code" := L_ItemVariant.Code;
                            L_ItemVariantWithFreeQty.Quantity := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
                            if L_ItemVariantWithFreeQty.Quantity > 0 then
                                L_ItemVariantWithFreeQty.Insert();
                            //end;
                            L_Count := L_Count - 1;
                            L_ItemVariant.Next();
                        end;

                        //Update Variant Code++
                        L_ItemVariantWithFreeQty.Reset();
                        L_ItemVariantWithFreeQty.SetRange("Item No.", L_SalesLine."No.");
                        L_ItemVariantWithFreeQty.SetFilter(Quantity, '>=%1', RemQty);
                        L_ItemVariantWithFreeQty.SetCurrentKey(Priority);
                        L_ItemVariantWithFreeQty.Ascending(true);
                        if L_ItemVariantWithFreeQty.FindFirst() then begin
                            if L_SalesLine."Variant Code" <> L_ItemVariantWithFreeQty."Variant Code" then begin
                                L_SalesLine.Validate("Variant Code", L_ItemVariantWithFreeQty."Variant Code");
                                L_SalesLine.Modify();
                            end;
                        end else begin
                            L_ItemVariantWithFreeQty.Reset();
                            L_ItemVariantWithFreeQty.SetRange("Item No.", L_SalesLine."No.");
                            L_ItemVariantWithFreeQty.SetFilter(Quantity, '<%1', RemQty);
                            L_ItemVariantWithFreeQty.SetCurrentKey(Priority);
                            L_ItemVariantWithFreeQty.Ascending(true);
                            if L_ItemVariantWithFreeQty.FindFirst() then begin
                                if L_SalesLine."Variant Code" <> L_ItemVariantWithFreeQty."Variant Code" then begin
                                    L_SalesLine.Validate("Variant Code", L_ItemVariantWithFreeQty."Variant Code");
                                    L_SalesLine.Modify();
                                end;
                            end else begin
                                //If there is no Inventory++++
                                L_ItemVariant.Reset();
                                L_ItemVariant.SetRange("Item No.", L_SalesLine."No.");
                                L_ItemVariant.SetFilter(Priority, '>%1', 0);
                                L_ItemVariant.SetRange("Sales Blocked", false);
                                L_ItemVariant.SetRange(Blocked, false);
                                L_ItemVariant.SetCurrentKey(Priority);
                                L_ItemVariant.Ascending(true);
                                if L_ItemVariant.FindFirst() then begin
                                    if L_SalesLine."Variant Code" <> L_ItemVariant.Code then begin
                                        L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
                                        L_SalesLine.Modify();
                                    end;
                                end;
                            end;
                        end;
                    end else begin
                        //If there is no priority on Item Varaint++
                        //This code added to manage "Release" the order++
                        L_ItemVariant.Reset();
                        L_ItemVariant.SetRange("Item No.", L_SalesLine."No.");
                        L_ItemVariant.SetRange("Sales Blocked", false);
                        L_ItemVariant.SetRange(Blocked, false);
                        if L_ItemVariant.FindFirst() then begin
                            if L_SalesLine."Variant Code" <> L_ItemVariant.Code then begin
                                L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
                                L_SalesLine.Modify();
                            end;
                        end;
                    end;
                until L_SalesLine.Next() = 0;
            end;
            Commit();
        end;
    end;


    //Old Code Backup+++++++++++++++++++
    // action("Update Variant On Lines")
    //         {
    //             ApplicationArea = All;
    //             Image = Insert;
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             trigger OnAction()
    //             var
    //                 L_SalesLine: Record "Sales Line";
    //                 CustomeCodeunit: Codeunit "Udate Variant on SO";
    //                 RemQty: Decimal;
    //                 QtyToApply: Decimal;
    //                 L_ItemVariant: Record "Item Variant";
    //                 L_Count: Integer;
    //                 L_NewLineRequired: Boolean;
    //                 L_Item: Record Item;
    //                 Window: Dialog;
    //                 Counter: Integer;
    //                 Text005: TextConst ENU = 'Updating the Variant Code...\\', ENG = 'Updating the Variant Code...\\';
    //                 Text006: TextConst ENU = 'Progress', ENG = 'Progress';
    //                 NoOfRecords: Integer;

    //                 L_SalesHeader: Record "Sales Header";
    //             begin
    //                 Clear(NoOfRecords);
    //                 Clear(Counter);
    //                 L_SalesHeader.Reset();
    //                 CurrPage.SetSelectionFilter(L_SalesHeader);
    //                 L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
    //                 L_SalesHeader.SetRange("Web Order", true);
    //                 if L_SalesHeader.FindSet() then begin
    //                     NoOfRecords := L_SalesHeader.Count;
    //                     Window.OPEN(Text005 + Text006 + ' @1@@@@@@@@@@@@@\' + L_SalesHeader.FIELDCAPTION("No.") + ' #3##########');
    //                     repeat
    //                         Counter += 1;
    //                         Window.UPDATE(1, ROUND(Counter / NoOfRecords * 10000, 1));
    //                         Window.UPDATE(3, L_SalesHeader."No.");
    //                         L_SalesLine.Reset();
    //                         L_SalesLine.CalcFields("Variant Code mandatory");
    //                         L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
    //                         L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
    //                         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
    //                         L_SalesLine.SetFilter("Variant Code", '%1', '');
    //                         L_SalesLine.SetRange("Variant Code mandatory", true);
    //                         L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
    //                         L_SalesLine.SetFilter("Location Code", '<>%1', '');
    //                         if L_SalesLine.FindSet() then begin
    //                             repeat
    //                                 Clear(L_NewLineRequired);
    //                                 Clear(RemQty);
    //                                 if CustomeCodeunit.CheckTotalAvailablityQty(L_SalesLine) > 0 then begin
    //                                     //Total required quantity 
    //                                     RemQty := L_SalesLine.Quantity;

    //                                     //Update Availbale Qty on Item Variant Table(This is temproray Calculating at run time)
    //                                     CustomeCodeunit.UpdateAvaibleQty(L_SalesLine);

    //                                     //Without Zero and based on priority++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //                                     //Set PriorityWithoutZero++
    //                                     Clear(L_ItemVariant);
    //                                     L_ItemVariant.Reset();
    //                                     CustomeCodeunit.SetPriorityWithoutZero(L_SalesLine, L_ItemVariant);
    //                                     Clear(L_Count);
    //                                     L_Count := L_ItemVariant.Count;

    //                                     //Process to update variant code and create new line if required++
    //                                     if L_Count > 0 then begin
    //                                         while (RemQty > 0) AND (L_Count > 0) do begin
    //                                             if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) > 0 then begin
    //                                                 if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then begin
    //                                                     if L_NewLineRequired = false then begin
    //                                                         L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                                                         L_SalesLine.Validate("Original Quantity", L_SalesLine.Quantity);
    //                                                         L_SalesLine.Validate("Variant Created By", L_SalesLine."Line No."); //Original Line Number
    //                                                         L_SalesLine.Modify();
    //                                                         RemQty := RemQty - L_SalesLine.Quantity;
    //                                                     end else begin
    //                                                         Clear(QtyToApply);
    //                                                         if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                                                             QtyToApply := RemQty
    //                                                         else
    //                                                             QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);

    //                                                         CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                                                         RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                                     end;
    //                                                 end else begin
    //                                                     if L_NewLineRequired = false then begin
    //                                                         L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                                                         L_SalesLine.Validate(Quantity, CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant));
    //                                                         L_SalesLine.Validate("Original Quantity", RemQty);
    //                                                         L_SalesLine.Modify();
    //                                                         RemQty := RemQty - L_SalesLine.Quantity;
    //                                                         L_NewLineRequired := true;
    //                                                     end else begin
    //                                                         Clear(QtyToApply);
    //                                                         if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                                                             QtyToApply := RemQty
    //                                                         else
    //                                                             QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                                         CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                                                         RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                                     end;
    //                                                 end;
    //                                             end;

    //                                             L_Count := L_Count - 1;
    //                                             L_ItemVariant.Next();
    //                                         end;
    //                                     end;
    //                                     //Without Zero and based on priority--------------------------------------------------------------------
    //                                 end;
    //                             until L_SalesLine.Next() = 0;
    //                         end;
    //                     until L_SalesHeader.Next() = 0;
    //                     Window.CLOSE;
    //                 end;
    //             end;
    //         }


    //Card Level++
    // action("Update Variant On Lines")
    //         {
    //             ApplicationArea = All;
    //             Image = Insert;
    //             Promoted = true;
    //             PromotedCategory = Process;
    //             trigger OnAction()
    //             var
    //                 L_SalesLine: Record "Sales Line";
    //                 CustomeCodeunit: Codeunit "Udate Variant on SO";
    //                 RemQty: Decimal;
    //                 QtyToApply: Decimal;
    //                 L_ItemVariant: Record "Item Variant";
    //                 L_Count: Integer;
    //                 L_NewLineRequired: Boolean;
    //                 L_Item: Record Item;
    //                 Window: Dialog;
    //                 Counter: Integer;
    //                 Text005: TextConst ENU = 'Updating the Variant Code...\\', ENG = 'Updating the Variant Code...\\';
    //                 Text006: TextConst ENU = 'Progress', ENG = 'Progress';
    //                 NoOfRecords: Integer;
    //             begin
    //                 //Check Order Type++
    //                 Rec.TestField("Web Order", true);

    //                 //Check Status++
    //                 Rec.TestField(Status, Rec.Status::Open);


    //                 //Start Process to Update Variant Code++
    //                 Clear(NoOfRecords);
    //                 Clear(Counter);
    //                 L_SalesLine.Reset();
    //                 L_SalesLine.SetRange("Document Type", Rec."Document Type");
    //                 L_SalesLine.SetRange("Document No.", Rec."No.");
    //                 L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
    //                 L_SalesLine.SetFilter("Variant Code", '%1', '');
    //                 L_SalesLine.SetRange("Variant Code mandatory", true);
    //                 L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
    //                 L_SalesLine.SetFilter("Location Code", '<>%1', '');
    //                 if L_SalesLine.FindSet() then begin
    //                     NoOfRecords := L_SalesLine.Count;
    //                     Window.OPEN(Text005 + Text006 + ' @1@@@@@@@@@@@@@\' + L_SalesLine.FIELDCAPTION("No.") + ' #3##########');
    //                     repeat
    //                         Counter += 1;
    //                         Window.UPDATE(1, ROUND(Counter / NoOfRecords * 10000, 1));
    //                         Window.UPDATE(3, L_SalesLine."No.");

    //                         Clear(L_NewLineRequired);
    //                         Clear(RemQty);
    //                         if CustomeCodeunit.CheckTotalAvailablityQty(L_SalesLine) > 0 then begin
    //                             //Total required quantity 
    //                             RemQty := L_SalesLine.Quantity;

    //                             //Update Availbale Qty on Item Variant Table(This is temproray Calculating at run time)
    //                             CustomeCodeunit.UpdateAvaibleQty(L_SalesLine);

    //                             //Without Zero and based on priority++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //                             //Set PriorityWithoutZero++
    //                             Clear(L_ItemVariant);
    //                             L_ItemVariant.Reset();
    //                             CustomeCodeunit.SetPriorityWithoutZero(L_SalesLine, L_ItemVariant);
    //                             Clear(L_Count);
    //                             L_Count := L_ItemVariant.Count;

    //                             //Process to update variant code and create new line if required++
    //                             if L_Count > 0 then begin
    //                                 while (RemQty > 0) AND (L_Count > 0) do begin
    //                                     if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) > 0 then begin
    //                                         if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then begin
    //                                             if L_NewLineRequired = false then begin
    //                                                 L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                                                 L_SalesLine.Validate("Original Quantity", L_SalesLine.Quantity);
    //                                                 L_SalesLine.Validate("Variant Created By", L_SalesLine."Line No."); //Original Line Number
    //                                                 L_SalesLine.Modify();
    //                                                 RemQty := RemQty - L_SalesLine.Quantity;
    //                                             end else begin
    //                                                 Clear(QtyToApply);
    //                                                 if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                                                     QtyToApply := RemQty
    //                                                 else
    //                                                     QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);

    //                                                 CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                                                 RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                             end;
    //                                         end else begin
    //                                             if L_NewLineRequired = false then begin
    //                                                 L_SalesLine.Validate(Quantity, CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant));
    //                                                 L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                                                 L_SalesLine.Validate("Original Quantity", RemQty);
    //                                                 L_SalesLine.Modify();
    //                                                 RemQty := RemQty - L_SalesLine.Quantity;
    //                                                 L_NewLineRequired := true;
    //                                             end else begin
    //                                                 Clear(QtyToApply);
    //                                                 if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                                                     QtyToApply := RemQty
    //                                                 else
    //                                                     QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                                 CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                                                 RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                                             end;
    //                                         end;
    //                                     end;

    //                                     L_Count := L_Count - 1;
    //                                     L_ItemVariant.Next();
    //                                 end;
    //                             end;
    //                             //Without Zero and based on priority--------------------------------------------------------------------

    //                             //As Discussed dont need to check Higher Qty process+++++++++++
    //                             // //With Zero and based on priority++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //                             // //Set PriorityWitZero++
    //                             // Clear(L_ItemVariant);
    //                             // L_ItemVariant.Reset();
    //                             // CustomeCodeunit.SetPriorityWithZeroandHigherQty(L_SalesLine, L_ItemVariant);
    //                             // Clear(L_Count);
    //                             // L_Count := L_ItemVariant.Count;

    //                             // //Process to update variant code and create new line if required++
    //                             // if L_Count > 0 then begin
    //                             //     while (RemQty > 0) AND (L_Count > 0) do begin
    //                             //         if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) > 0 then begin
    //                             //             if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then begin
    //                             //                 if L_NewLineRequired = false then begin
    //                             //                     L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                             //                     L_SalesLine.Validate("Original Quantity", RemQty);
    //                             //                     L_SalesLine.Modify();
    //                             //                     RemQty := RemQty - L_SalesLine.Quantity;
    //                             //                 end else begin
    //                             //                     Clear(QtyToApply);
    //                             //                     if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                             //                         QtyToApply := RemQty
    //                             //                     else
    //                             //                         QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);

    //                             //                     CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                             //                     RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                             //                 end;
    //                             //             end else begin
    //                             //                 if L_NewLineRequired = false then begin
    //                             //                     L_SalesLine.Validate(Quantity, CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant));
    //                             //                     L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
    //                             //                     L_SalesLine.Validate("Original Quantity", RemQty);
    //                             //                     L_SalesLine.Modify();
    //                             //                     RemQty := RemQty - L_SalesLine.Quantity;
    //                             //                     L_NewLineRequired := true;
    //                             //                 end else begin
    //                             //                     Clear(QtyToApply);
    //                             //                     if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
    //                             //                         QtyToApply := RemQty
    //                             //                     else
    //                             //                         QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                             //                     CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
    //                             //                     RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
    //                             //                 end;
    //                             //             end;
    //                             //         end;

    //                             //         L_Count := L_Count - 1;
    //                             //         L_ItemVariant.Next();
    //                             //     end;
    //                             // end;
    //                             // //With Zero and based on priority--------------------------------------------------------------------
    //                             //As Discussed dont need to check Higher Qty process+++++++++++
    //                         end else begin
    //                             // if not Confirm(StrSubstNo('Inventory does not exist for item number %1 line number. Click Yes to continue without variant code ', L_SalesLine."No.", L_SalesLine."Line No."), false) then
    //                             //     Error('')
    //                         end;
    //                     until L_SalesLine.Next() = 0;
    //                     Window.CLOSE;
    //                 end;
    //             end;
    //         }
}