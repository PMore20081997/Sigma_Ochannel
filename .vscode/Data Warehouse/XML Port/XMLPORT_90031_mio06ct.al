xmlport 90031 "mio06ct"
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
    FileName = 'mio06ct.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Cust_Type_Header")
                {
                }
                textelement(Desc_Header)
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cust_Type_Header := 'Customer Type';
                    Desc_Header := 'Description';

                end;

            }
            tableelement("Dimension_Value"; "Dimension Value")
            {
                SourceTableView = WHERE("Dimension Code" = filter('CUSTOMER TYPE'));


                textelement(Cust_Type)
                {
                }
                textelement(Desc)
                {
                }


                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                begin
                    Cust_Type := Dimension_Value.Code;
                    Desc := Dimension_Value.Name;

                end;
            }
        }
    }
}