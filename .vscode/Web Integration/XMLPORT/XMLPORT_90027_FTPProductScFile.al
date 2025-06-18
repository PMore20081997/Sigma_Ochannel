xmlport 90027 "ProductSC File FTP"
{
    Caption = 'Stock File FTP';
    DefaultFieldsValidation = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;
    FileName = 'productsc.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(SigmaProductCode_Caption)
                {
                }
                textelement(PipCode_Caption)
                {
                }
                textelement(ProductAnalysisGroup_Caption)
                {
                }
                textelement(ProductAnalysisGroup4_Caption)
                {
                }
                textelement(ProductAnalysisGroup5_Caption)
                {
                }
                textelement(ProductGroupCode_Caption)
                {
                }
                textelement(ProductGroup_Caption)
                {
                }
                textelement(ProductDesc_Caption)
                {
                }
                textelement(PackSize_Caption)
                {
                }
                textelement(TradePrice_Caption)
                {
                }
                textelement(PercentDiscount_Caption)
                {
                }
                textelement(InvPrice_Caption)
                {
                }
                textelement(LiveStock_Caption)
                {
                }
                textelement(RRP_Caption)
                {
                }
                trigger OnAfterGetRecord()
                var
                begin
                    SigmaProductCode_Caption := 'SIGMA PRODUCT CODE';
                    PipCode_Caption := 'PIP CODE';
                    ProductAnalysisGroup_Caption := 'PRODUCT ANALYSIS GROUP';
                    ProductAnalysisGroup4_Caption := 'PRODUCT ANALYSIS GROUP 4';
                    ProductAnalysisGroup5_Caption := 'PRODUCT ANALYSIS GROUP 5';
                    ProductGroupCode_Caption := 'PRODUCT GROUP CODE';
                    ProductGroup_Caption := 'PRODUCT GROUP';
                    ProductDesc_Caption := 'PRODUCT DESC';
                    PackSize_Caption := 'PACK SIZE';
                    TradePrice_Caption := 'TRADE PRICE';
                    PercentDiscount_Caption := '% DISC';
                    InvPrice_Caption := 'INV PRICE';
                    LiveStock_Caption := 'LIVE STOCK';
                    RRP_Caption := 'RRP';
                end;
            }
            tableelement(Item; Item)
            {
                SourceTableView = where(Blocked = const(false), Status = filter(Released), "Sales Blocked" = const(false), "Ops Sales Blocked" = const(false));
                CalcFields = Inventory, "Qty. on Sales Order", "Qty. on Web Order", "Parent Category", "Child Category";
                textelement(SigmaProductCode)
                {
                }
                textelement(PipCode)
                {
                }
                textelement(ProductAnalysisGroup)
                {
                }
                textelement(ProductAnalysisGroup4)
                {
                }
                textelement(ProductAnalysisGroup5)
                {
                }
                textelement(ProductGroupCode)
                {
                }
                textelement(ProductGroup)
                {
                }
                textelement(ProductDesc)
                {
                }
                textelement(PackSize)
                {
                }
                textelement(TradePrice)
                {
                }
                textelement(PercentDiscount)
                {
                }
                textelement(InvPrice)
                {
                }
                textelement(LiveStock)
                {
                }
                textelement(RRP)
                {
                }
                trigger OnAfterGetRecord()
                var
                    L_ItemReference: Record "Item Reference";
                    L_LiveStock: Decimal;
                    L_Physical: Decimal;
                    IsVariantMandatory: Boolean;
                    L_Variant: Record "Item Variant";
                    L_SalesLine: Record "Sales Line";
                    L_QtyOnSO: Decimal;
                    G_WebOrderQty: Decimal;
                    L_ItemLedgerEntry: Record "Item Ledger Entry";
                    L_ExcludeQty: Decimal;
                    L_BinContent: Record "Bin Content";
                begin
                    SigmaProductCode := Item."No.";

                    L_ItemReference.Reset();
                    L_ItemReference.SetRange("Reference Type", L_ItemReference."Reference Type"::"PIP Code");
                    L_ItemReference.SetRange("Item No.", Item."No.");
                    if L_ItemReference.FindFirst() then
                        PipCode := L_ItemReference."Reference No.";

                    ProductAnalysisGroup := Item."Parent Category";
                    ProductAnalysisGroup4 := Item."Child Category";
                    ProductAnalysisGroup5 := Item."Item Category Code";
                    ProductGroupCode := '';
                    ProductGroup := '';
                    ProductDesc := Item.Description;
                    PackSize := Item."Pack Size";
                    TradePrice := Format(Item."Unit Price");
                    PercentDiscount := '';
                    InvPrice := Format(Item."Unit Price");

                    Clear(IsVariantMandatory);
                    L_Variant.Reset();
                    L_Variant.SetRange("Item No.", Item."No.");
                    if not L_Variant.IsEmpty then
                        IsVariantMandatory := true
                    else
                        IsVariantMandatory := false;

                    //Calculate Physical Qty++
                    Clear(L_Physical);
                    L_ItemLedgerEntry.Reset();
                    L_ItemLedgerEntry.SetRange("Item No.", Item."No.");
                    L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(Item."No."));
                    //L_ItemLedgerEntry.SetRange("Daily Priority Exist", IsVariantMandatory);
                    L_ItemLedgerEntry.SetRange("Saleable Location", true);
                    L_ItemLedgerEntry.CalcSums(Quantity);
                    L_Physical := L_ItemLedgerEntry.Quantity;
                    if L_Physical < 0 then
                        L_Physical := 0;


                    //Calculate SO qty++
                    Clear(L_QtyOnSO);
                    L_SalesLine.Reset();
                    L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                    L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                    L_SalesLine.SetRange("No.", Item."No.");
                    L_SalesLine.SetRange("Saleable Location", true);
                    L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                    if L_SalesLine.FindSet() then begin
                        L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                        L_QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
                    end;
                    if L_QtyOnSO < 0 then
                        L_QtyOnSO := 0;


                    //Get the Web Order Qty++
                    Clear(G_WebOrderQty);
                    Item.CalcFields("Qty. on Web Order");
                    G_WebOrderQty := Item."Qty. on Web Order";
                    if G_WebOrderQty < 0 then
                        G_WebOrderQty := 0;

                    //Calculate Free Qty+++
                    Clear(L_LiveStock);
                    L_LiveStock := L_Physical - (L_QtyOnSO + G_WebOrderQty);

                    // //New+++SBB-291
                    if L_LiveStock > 0 then begin
                        Clear(L_ExcludeQty);
                        L_BinContent.Reset();
                        L_BinContent.SetRange("Item No.", Item."No.");
                        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
                        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
                        L_BinContent.SetRange("Saleable Location", true);
                        L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(Item."No."));
                        if L_BinContent.FindSet() then begin
                            repeat
                                L_BinContent.CalcFields("Quantity (Base)");
                                L_ExcludeQty += L_BinContent."Quantity (Base)";
                            until L_BinContent.Next() = 0;
                        end;
                        if L_ExcludeQty > 0 then
                            L_LiveStock := L_LiveStock - L_ExcludeQty;
                    end;
                    // //New+++SBB-291

                    if L_LiveStock > 0 then begin
                        LiveStock := Format(L_LiveStock);
                        if LiveStock.Contains(',') then
                            LiveStock := LiveStock.Replace(',', '');
                    end else
                        LiveStock := '0';

                    RRP := Format(Item.RRP);
                    if RRP.Contains(',') then
                        RRP := RRP.Replace(',', '');
                end;
            }
        }
    }

    local procedure GetVariantSetup(_ItemNo: Code[20]): Boolean
    var
        L_ItemVariant: Record "Item Variant";
        L_Item: Record Item;
    begin
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            if L_Item."Variant Mandatory if Exists" <> L_Item."Variant Mandatory if Exists"::No then begin
                if L_Item."Variant Mandatory if Exists" = L_Item."Variant Mandatory if Exists"::Yes then
                    exit(true)
                else begin
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", _ItemNo);
                    if L_ItemVariant.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            end else
                exit(false);
        end;
    end;
}