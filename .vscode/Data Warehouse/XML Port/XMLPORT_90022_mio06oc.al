xmlport 90022 "mio06oc"
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
    FileName = 'mio06oc.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Op_Code_Header")
                {
                }
                textelement(Op_Code_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Op_Code_Header := 'Op Code';
                    Op_Code_Desc_Header := 'Op Code Desc';
                    company_Header := 'Company';
                end;

            }
            tableelement("Dimension_Value"; "Dimension Value")
            {
                SourceTableView = WHERE("Dimension Code" = filter('OPERATOR CODE'));

                textelement(Op_Code)
                {
                }
                textelement(Op_Code_Desc)
                {
                }
                textelement(Company)
                {

                }

                trigger OnAfterGetRecord()
                var

                begin
                    Op_Code := Dimension_Value.Code;
                    Op_Code_Desc := Dimension_Value.Name;
                    Company := '';
                end;
            }
        }
    }
}