xmlport 90029 "productsc File"
{

    Caption = 'Export File';
    DefaultFieldsValidation = false;
    Direction = Export;
    // FieldSeparator = ',';
    //FieldDelimiter = '<None>';
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
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("SIGMA_PRODUCT_CODE_Header")
                {
                }

                textelement("PIP_CODE_Header")
                {
                }

                textelement("PRODUCT_ANALYSIS_GROUP_Header")
                {
                }

                textelement("PRODUCT_ANALYSIS_GROUP_4_Header")
                {
                }

                textelement("PRODUCT_ANALYSIS_GROUP_5_Header")
                {
                }

                textelement("PRODUCT_GROUP_CODE_Header")
                {
                }

                textelement("PRODUCT_GROUP_Header")
                {
                }

                textelement("PRODUCT_DESC_Header")
                {
                }

                textelement("PACK_SIZE_Header")
                {
                }

                textelement("TRADE_PRICE_Header")
                {
                }

                textelement("DISC_Header")
                {
                }

                textelement("INV_PRICE_Header")
                {
                }

                textelement("LIVE_STOCK_Header")
                {
                }

                textelement("RRP_Header")
                {
                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    SIGMA_PRODUCT_CODE_Header := 'SIGMA PRODUCT CODE';
                    PIP_CODE_Header := 'PIP CODE';
                    PRODUCT_ANALYSIS_GROUP_Header := 'PRODUCT ANALYSIS GROUP';
                    PRODUCT_ANALYSIS_GROUP_4_Header := 'PRODUCT ANALYSIS GROUP 4';
                    PRODUCT_ANALYSIS_GROUP_5_Header := 'PRODUCT ANALYSIS GROUP 5';
                    PRODUCT_GROUP_CODE_Header := 'PRODUCT GROUP CODE';
                    PRODUCT_GROUP_Header := 'PRODUCT GROUP';
                    PRODUCT_DESC_Header := 'PRODUCT DESC';
                    PACK_SIZE_Header := 'PACK SIZE';
                    TRADE_PRICE_Header := 'TRADE PRICE';
                    DISC_Header := '%DISC';
                    INV_PRICE_Header := 'INV PRICE';
                    LIVE_STOCK_Header := 'LIVE STOCK';
                    RRP_Header := 'RRP';
                end;

            }
            tableelement(Item; Item)
            {
                CalcFields = Inventory;

                textelement(SIGMA_PRODUCT_CODE)
                {
                }

                textelement(PIP_CODE)
                {
                }

                textelement(PRODUCT_ANALYSIS_GROUP)
                {
                }

                textelement(PRODUCT_ANALYSIS_GROUP_4)
                {
                }

                textelement(PRODUCT_ANALYSIS_GROUP_5)
                {
                }

                textelement(PRODUCT_GROUP_CODE)
                {
                }

                textelement(PRODUCT_GROUP)
                {
                }

                textelement(PRODUCT_DESC)
                {
                }

                textelement(PACK_SIZE)
                {
                }

                textelement(TRADE_PRICE)
                {
                }

                textelement(DISC)
                {
                }

                textelement(INV_PRICE)
                {
                }

                textelement(LIVE_STOCK)
                {
                }

                textelement(RRP)
                {
                }

                trigger OnAfterGetRecord()
                var
                    ItemRef: Record "Item Reference";
                begin
                    SIGMA_PRODUCT_CODE := Item."No.";

                    ItemRef.Reset();
                    ItemRef.SetRange("Item No.", Item."No.");
                    ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"PIP Code");
                    if ItemRef.FindFirst() then begin
                        PIP_CODE := ItemRef."Reference No.";
                    end;
                    PRODUCT_ANALYSIS_GROUP := Item."Child Category";
                    PRODUCT_ANALYSIS_GROUP_4 := Item."No. 2";
                    PRODUCT_ANALYSIS_GROUP_5 := '';
                    PRODUCT_GROUP_CODE := Item."Item Category Code";
                    PRODUCT_GROUP := Item."Parent Category";
                    PRODUCT_DESC := Item.Description;
                    PACK_SIZE := Item."Pack Size";
                    TRADE_PRICE := Format(item."Unit Price");
                    DISC := '0';
                    INV_PRICE := Format(item."Unit Price");
                    LIVE_STOCK := Format(Item.Inventory);
                    RRP := Format(item.RRP);
                end;





            }
        }
    }
}