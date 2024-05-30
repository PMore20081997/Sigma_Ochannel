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
        // Clear(_ItemVariant);
        // _ItemVariant.Reset();
        // _ItemVariant.SetRange("Item No.", _SalesLine."No.");
        // _ItemVariant.SetFilter(Priority, '<>%1', 0);
        // _ItemVariant.SetCurrentKey(Priority);
        // _ItemVariant.Ascending(true);
        // if _ItemVariant.FindFirst() then;


        //New Code++
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
    begin
        // Clear(L_TotalInventory);
        // Clear(L_TotalRequestedQty);
        // L_ItemVariant.Reset();
        // L_ItemVariant.SetRange("Item No.", _SalesLine."No.");
        // L_ItemVariant.SetRange(Code, _ItemVariant.Code);
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
        L_ItemVariant.SetFilter("Location Filter", _SalesLine."Location Code");
        L_ItemVariant.SetRange(Blocked, false);
        L_ItemVariant.SetRange("Sales Blocked", false);
        L_ItemVariant.SetRange(Code, _ItemVariant.Code);
        if L_ItemVariant.FindSet() then begin
            repeat
                L_ItemVariant.CalcFields("Saleable Inventory", "Qty on SO(Saleable)");
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
}