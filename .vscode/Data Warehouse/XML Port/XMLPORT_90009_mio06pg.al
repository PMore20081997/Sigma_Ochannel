xmlport 90009 "mio06pg"
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
    FileName = 'mio06pg.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Product_Group_Header")
                {
                }
                textelement(Product_Group_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }
                textelement(XXXXXXXX)
                {

                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Product_Group_Header := 'Product Group';
                    Product_Group_Desc_Header := 'Product Group Desc';
                    company_Header := 'Company';
                    XXXXXXXX := 'XXXXXXXX';

                end;

            }
            tableelement("Item_Category"; "Item Category")
            {


                textelement(Product_Group)
                {
                }
                textelement(Product_Group_Desc)
                {
                }
                textelement(Company)
                {

                }
                textelement(XXXXXXXXX)
                {

                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Product_Group := "Item_Category".Code;
                    Product_Group_Desc := "Item_Category".Description;
                    Company := '';
                    XXXXXXXX := 'XXXXXXXXXXXXXXX';

                end;





            }
        }
    }
}
