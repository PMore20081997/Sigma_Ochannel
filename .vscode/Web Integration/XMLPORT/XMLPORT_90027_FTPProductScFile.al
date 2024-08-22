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
                SourceTableView = where(Blocked = const(false), Status = filter(Released));
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

                    Clear(L_LiveStock);
                    L_LiveStock := Item.Inventory - (Item."Qty. on Sales Order" + Item."Qty. on Web Order");
                    if L_LiveStock > 0 then begin
                        LiveStock := Format(L_LiveStock);
                        if LiveStock.Contains(',') then
                            LiveStock := LiveStock.Replace(',', '');
                    end
                    else
                        LiveStock := '0';

                    RRP := Format(Item.RRP);
                    if RRP.Contains(',') then
                        RRP := RRP.Replace(',', '');
                end;
            }
        }
    }
}