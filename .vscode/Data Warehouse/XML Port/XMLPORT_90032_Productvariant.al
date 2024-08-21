xmlport 90032 "Product variant"
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
    FileName = 'productvariant.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Prod_No_Header")
                {
                }
                textelement(Variant_code_Header)
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Prod_No_Header := 'Prod No';
                    Variant_code_Header := 'Variant code';

                end;

            }
            tableelement("Item_Variant"; "Item Variant")
            {
                //SourceTableView = WHERE("Dimension Code" = filter('CUSTOMER TYPE'));


                textelement(Prod_No)
                {
                }
                textelement(Variant_code)
                {
                }


                trigger OnAfterGetRecord()
                var

                begin
                    Prod_No := Item_Variant."Item No.";
                    Variant_code := Item_Variant.Code;

                end;
            }
        }
    }
}