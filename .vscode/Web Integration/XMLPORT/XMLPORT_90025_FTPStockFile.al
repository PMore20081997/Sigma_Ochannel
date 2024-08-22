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
                begin
                    ProductCode := Item."No.";
                    Clear(L_FreeStock);
                    L_FreeStock := Item.Inventory - (Item."Qty. on Sales Order" + Item."Qty. on Web Order");
                    if L_FreeStock > 0 then begin
                        FreeStock := Format(L_FreeStock);
                        if FreeStock.Contains(',') then
                            FreeStock := FreeStock.Replace(',', '');
                    end
                    else
                        FreeStock := '0';
                end;
            }
        }
    }
}