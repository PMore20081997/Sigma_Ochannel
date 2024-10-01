xmlport 90025 "Stock File FTP"
{
    Caption = 'Stock File FTP';
    DefaultFieldsValidation = false;
    Direction = Export;
    TableSeparator = '<NewLine>';
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;
    FileName = 'stock.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(Product_Code)
                {
                }
                textelement(Free_Stock)
                {
                }
                trigger OnAfterGetRecord()
                var
                begin
                    Product_Code := 'Product code';
                    Free_Stock := 'Free Stock';
                end;
            }
            tableelement(Item; Item)
            {
                SourceTableView = where(Blocked = const(false), Status = filter(Released));
                CalcFields = Inventory, "Qty. on Sales Order", "Qty. on Web Order";
                textelement(ProductCode)
                {
                }
                textelement(FreeStock)
                {
                }
                trigger OnAfterGetRecord()
                var
                    L_FreeStock: Decimal;
                    L_ItemLedgerEntry: Record "Item Ledger Entry";
                    L_Physical: Decimal;
                    IsVariantMandatory: Boolean;
                    L_Variant: Record "Item Variant";
                    L_SalesLine: Record "Sales Line";
                    L_QtyOnSO: Decimal;
                    G_WebOrderQty: Decimal;
                begin
                    ProductCode := Item."No.";
                    // Clear(L_FreeStock);
                    // L_FreeStock := Item.Inventory - (Item."Qty. on Sales Order" + Item."Qty. on Web Order");
                    // if L_FreeStock > 0 then begin
                    //     FreeStock := Format(L_FreeStock);
                    //     if FreeStock.Contains(',') then
                    //         FreeStock := FreeStock.Replace(',', '');
                    // end
                    // else
                    //     FreeStock := '0';

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
                    L_ItemLedgerEntry.SetRange("Daily Priority Exist", IsVariantMandatory);
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
                    Clear(L_FreeStock);
                    L_FreeStock := L_Physical - (L_QtyOnSO + G_WebOrderQty);
                    if L_FreeStock > 0 then begin
                        FreeStock := Format(L_FreeStock);
                        if FreeStock.Contains(',') then
                            FreeStock := FreeStock.Replace(',', '');
                    end else
                        FreeStock := '0';
                end;
            }
        }
    }
}