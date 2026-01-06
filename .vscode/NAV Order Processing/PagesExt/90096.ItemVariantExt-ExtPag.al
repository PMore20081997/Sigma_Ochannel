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
                ToolTip = 'Total Physical - Total Allocated on SO (Shipment date ≥ today) - Tota; Allocated on Picks (Shipment date < today)';
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
                ToolTip = 'Physical - Allocated on SO (Shipment date ≥ today) - Allocated on Picks (Shipment date < today)';
                Caption = 'Free';
            }
        }
    }

    local procedure Physical(_Rec: Record "Item Variant"): Decimal
    var
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        PhysicalInventory: Decimal;

        Query_ILEQuantity: Query "ILE Quantity Query";
    begin
        Clear(PhysicalInventory);
        Clear(Query_ILEQuantity);
        Query_ILEQuantity.SetRange(Item_No_, _Rec."Item No.");
        Query_ILEQuantity.SetRange(Saleable_Location, true);
        Query_ILEQuantity.SetRange(Variant_Code, _Rec.code);
        Query_ILEQuantity.Open();
        while Query_ILEQuantity.Read() do begin
            PhysicalInventory += Query_ILEQuantity.Remaining_Quantity;
        end;
        if PhysicalInventory < 0 then
            PhysicalInventory := 0;
        exit(PhysicalInventory);
    end;

    local procedure QtyOnSOForSaleableLocation(_Rec: Record "Item Variant"): Decimal
    var
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;

        Query_SalesLineQuantity: Query "SalesLine Quantity Query";
    begin
        Clear(QtyOnSO);
        Clear(Query_SalesLineQuantity);
        Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
        Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
        Query_SalesLineQuantity.SetRange(No_, _Rec."Item No.");
        Query_SalesLineQuantity.SetRange(Variant_Code, _Rec.code);
        Query_SalesLineQuantity.SetRange(Saleable_Location, true);
        Query_SalesLineQuantity.SetFilter(Shipment_Date, '>=%1', WorkDate());
        Query_SalesLineQuantity.Open();
        while Query_SalesLineQuantity.Read() do begin
            QtyOnSO += Query_SalesLineQuantity.Outstanding_Qty___Base_;
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;
        exit(QtyOnSO);
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
        _QtyonPick: Decimal;

        Query_ILEQuantity: Query "ILE Quantity Query";
        Query_SalesLineQuantity: Query "SalesLine Quantity Query";
    begin
        //Total Quanity++
        Clear(TotalInventory);
        Clear(Query_ILEQuantity);
        Query_ILEQuantity.SetRange(Item_No_, _Rec."Item No.");
        Query_ILEQuantity.SetRange(Variant_Code, _Rec.code);
        Query_ILEQuantity.Open();
        while Query_ILEQuantity.Read() do begin
            TotalInventory += Query_ILEQuantity.Remaining_Quantity;
        end;
        if TotalInventory < 0 then
            TotalInventory := 0;


        //Total Allocated on SO++
        Clear(QtyOnSO);
        Clear(Query_SalesLineQuantity);
        Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
        Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
        Query_SalesLineQuantity.SetRange(No_, _Rec."Item No.");
        Query_SalesLineQuantity.SetRange(Variant_Code, _Rec.code);
        Query_SalesLineQuantity.Open();
        while Query_SalesLineQuantity.Read() do begin
            QtyOnSO += Query_SalesLineQuantity.Outstanding_Qty___Base_;
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;

        //Exclude Qty Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."Item No.");
        L_BinContent.SetRange("Variant Code", _Rec.Code);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty < 0 then
            L_ExcludeQty := 0;


        //Calculate Total free Qty
        Clear(G_FreeQuantity);
        G_FreeQuantity := TotalInventory - QtyOnSO - L_ExcludeQty;
        if G_FreeQuantity < 0 then
            G_FreeQuantity := 0;
        exit(G_FreeQuantity);
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
        _QtyonPick: Decimal;
        L_warehouseActivityLine: Record "Warehouse Activity Line";


        Query_ILEQuantity: Query "ILE Quantity Query";
        Query_SalesLineQuantity: Query "SalesLine Quantity Query";
        Query_PickQuantity: Query "Pick Quantity Query";
    begin
        //Total Physical quantity++
        Clear(PhysicalInventory);
        Clear(Query_ILEQuantity);
        Query_ILEQuantity.SetRange(Item_No_, _Rec."Item No.");
        Query_ILEQuantity.SetRange(Saleable_Location, true);
        Query_ILEQuantity.SetRange(Variant_Code, _Rec.code);
        Query_ILEQuantity.Open();
        while Query_ILEQuantity.Read() do begin
            PhysicalInventory += Query_ILEQuantity.Remaining_Quantity;
        end;
        if PhysicalInventory < 0 then
            PhysicalInventory := 0;

        //Allocated on SO++
        Clear(QtyOnSO);
        Clear(Query_SalesLineQuantity);
        Query_SalesLineQuantity.SetRange(Document_Type, Query_SalesLineQuantity.Document_Type::Order);
        Query_SalesLineQuantity.SetRange(Type, Query_SalesLineQuantity.Type::Item);
        Query_SalesLineQuantity.SetRange(No_, _Rec."Item No.");
        Query_SalesLineQuantity.SetRange(Variant_Code, _Rec.code);
        Query_SalesLineQuantity.SetRange(Saleable_Location, true);
        Query_SalesLineQuantity.SetFilter(Shipment_Date, '>=%1', WorkDate());
        Query_SalesLineQuantity.Open();
        while Query_SalesLineQuantity.Read() do begin
            QtyOnSO += Query_SalesLineQuantity.Outstanding_Qty___Base_;
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;


        //Qty on Pick item wise++ SBB-579
        Clear(_QtyonPick);
        Clear(Query_PickQuantity);
        Query_PickQuantity.SetRange(Query_PickQuantity.Source_Document, Query_PickQuantity.Source_Document::"Sales Order");
        Query_PickQuantity.SetRange(Query_PickQuantity.Item_No_, _Rec."Item No.");
        Query_PickQuantity.SetRange(Variant_Code, _Rec.Code);
        Query_PickQuantity.SetRange(Query_PickQuantity.Saleable_Location, true);
        Query_PickQuantity.SetFilter(Query_PickQuantity.Shipment_Date, '<%1', WorkDate());
        Query_PickQuantity.Open();
        while Query_PickQuantity.Read() do begin
            _QtyonPick += Query_PickQuantity.Qty__Outstanding__Base_;
        end;
        if _QtyonPick < 0 then
            _QtyonPick := 0;

        //Exclude Qty Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", _Rec."Item No.");
        L_BinContent.SetRange("Variant Code", _Rec.Code);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        L_BinContent.SetRange("Saleable Location", true);
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;
        if L_ExcludeQty < 0 then
            L_ExcludeQty := 0;

        //Calculate Free Qty++
        Clear(G_FreeQuantity);
        G_FreeQuantity := PhysicalInventory - QtyOnSO - _QtyonPick - L_ExcludeQty;
        if G_FreeQuantity < 0 then
            G_FreeQuantity := 0;
        exit(G_FreeQuantity)
    end;
}