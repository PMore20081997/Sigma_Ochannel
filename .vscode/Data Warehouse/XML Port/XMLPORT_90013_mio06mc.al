xmlport 90013 "mio06mc"
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
    FileName = 'mio06mc.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Market_Code_Header")
                {
                }
                textelement(Market_Code_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Market_Code_Header := 'Market Code';
                    Market_Code_Desc_Header := 'Market Code Desc';
                    company_Header := 'Company';
                end;

            }
            tableelement("Dimension_Value"; "Dimension Value")
            {
                SourceTableView = WHERE("Dimension Code" = filter('MARKET CODE'));

                textelement(Market_Code)
                {
                }
                textelement(Market_Code_Desc)
                {
                }
                textelement(Company)
                {

                }

                trigger OnAfterGetRecord()
                var

                begin
                    Market_Code := Dimension_Value.Code;
                    Market_Code_Desc := Dimension_Value.Name;
                    Company := '';
                end;
            }
        }
    }
}