pageextension 90096 "Item Variant Ext" extends "Item Variants"
{
    layout
    {
        addafter(Description)
        {
            field("VAT Prod. Posting Group"; Rec."VAT Prod Posting Group")
            {
                ApplicationArea = All;
            }
            field("Shelf No."; Rec."Shelf No.")
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {
            field(Priority; Rec.Priority)
            {
                ApplicationArea = All;

            }
        }
        addafter("Purchasing Blocked")
        {
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Sucessfull Electronic Orders';
            }
            field(Inventory; Rec.Inventory)
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Total Physical';
                ToolTip = 'Total Inventory';
                DecimalPlaces = 0 : 5;
            }
            field(Allocated; Rec.Allocated)
            {
                Editable = false;
                ApplicationArea = All;
                ToolTip = 'Sum of Outstanding Qty on SO across ALL Locations';
                DecimalPlaces = 0 : 5;
                Caption = 'Total Allocated on SO';
            }
            field("Total Free"; TotalAvailableQty(rec))
            {
                Caption = 'Total Free';
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Total Physical - Total SO Allocated';
            }
            field(Physical; Physical(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Physical';
                ToolTip = 'Qty available in Saleable location';
                DecimalPlaces = 0 : 5;
            }
            field("Allocated on SO"; QtyOnSOForSaleableLocation(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                Caption = 'Allocated on SO';
                ToolTip = 'Sum of Outstanding SO Qty in Saleable location';
                DecimalPlaces = 0 : 5;
            }
            field("Free"; TotalAvailableQtyForSaleable(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO';
                Caption = 'Free';
            }
        }
    }

    local procedure Physical(_Rec: Record "Item Variant"): Decimal
    var
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        PhysicalInventory: Decimal;
    begin
        Clear(PhysicalInventory);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SETRANGE("Item No.", _Rec."Item No.");
        L_ItemLedgerEntry.SetRange("Variant Code", _Rec.Code);
        L_ItemLedgerEntry.SETRANGE("Saleable Location", true);
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            PhysicalInventory := L_ItemLedgerEntry.Quantity;
        end;

        if PhysicalInventory > 0 then
            exit(PhysicalInventory)
        else
            exit(0);
    end;

    local procedure QtyOnSOForSaleableLocation(_Rec: Record "Item Variant"): Decimal
    var
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
    begin
        Clear(QtyOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", _Rec."Item No.");
        L_SalesLine.SetRange("Variant Code", _Rec.Code);
        L_SalesLine.SETRANGE("Saleable Location", true);
        L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;

        if QtyOnSO > 0 then
            exit(QtyOnSO)
        else
            exit(0);
    end;

    local procedure TotalAvailableQty(_Rec: Record "Item Variant"): Decimal
    var
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        TotalInventory: Decimal;
        L_BinContent: Record "Bin Content"; //Prathamesh++
        L_ExcludeQty: Decimal; //Prathamesh++
        G_FreeQuantity: Decimal; //Prathamesh++
    begin
        Clear(TotalInventory);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SETRANGE("Item No.", _Rec."Item No.");
        L_ItemLedgerEntry.SetRange("Variant Code", _Rec.Code);
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            TotalInventory := L_ItemLedgerEntry.Quantity;
        end;
        if TotalInventory < 0 then
            TotalInventory := 0;


        Clear(QtyOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", _Rec."Item No.");
        L_SalesLine.SetRange("Variant Code", _Rec.Code);
        L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;

        Clear(G_FreeQuantity);
        G_FreeQuantity := TotalInventory - QtyOnSO;

        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."Item No.");
        L_BinContent.SetRange("Variant Code", _Rec.Code);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                //L_ExcludeQty += L_BinContent.CalcQtyAvailToTakeUOM();
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;

        if L_ExcludeQty > 0 then
            G_FreeQuantity := G_FreeQuantity - L_ExcludeQty;

        if G_FreeQuantity > 0 then
            exit(G_FreeQuantity)
        else
            exit(0);


        // //Old Code+++
        // _Rec.CalcFields(Inventory, Allocated, "Web Orders Qty");
        // if (_Rec.Inventory - _Rec.Allocated) > 0 then
        //     exit(_Rec.Inventory - _Rec.Allocated)
        // else
        //     exit(0);
    end;

    local procedure TotalAvailableQtyForSaleable(_Rec: Record "Item Variant"): Decimal
    var
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        PhysicalInventory: Decimal;
        L_BinContent: Record "Bin Content"; //Prathamesh++
        L_ExcludeQty: Decimal; //Prathamesh++
        G_FreeQuantity: Decimal; //Prathamesh++
    begin
        Clear(PhysicalInventory);
        L_ItemLedgerEntry.Reset();
        L_ItemLedgerEntry.SETRANGE("Item No.", _Rec."Item No.");
        L_ItemLedgerEntry.SetRange("Variant Code", _Rec.Code);
        L_ItemLedgerEntry.SETRANGE("Saleable Location", true);
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums(Quantity);
            PhysicalInventory := L_ItemLedgerEntry.Quantity;
        end;
        if PhysicalInventory < 0 then
            PhysicalInventory := 0;

        Clear(QtyOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", _Rec."Item No.");
        L_SalesLine.SetRange("Variant Code", _Rec.Code);
        L_SalesLine.SETRANGE("Saleable Location", true);
        L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;

        Clear(G_FreeQuantity);
        G_FreeQuantity := PhysicalInventory - QtyOnSO;

        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."Item No.");
        L_BinContent.SetRange("Variant Code", _Rec.Code);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                //L_ExcludeQty += L_BinContent.CalcQtyAvailToTakeUOM();
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;

        if L_ExcludeQty > 0 then
            G_FreeQuantity := G_FreeQuantity - L_ExcludeQty;

        if G_FreeQuantity > 0 then
            exit(G_FreeQuantity)
        else
            exit(0);


        // //Old Code+++
        // _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory", "Web Orders Qty");
        // if _Rec."Saleable Inventory" > 0 then
        //     if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)") > 0 then
        //         exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)")
        //     else
        //         exit(0)
        // else
        //     exit(0);
    end;
}