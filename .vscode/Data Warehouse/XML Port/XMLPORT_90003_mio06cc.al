xmlport 90003 "mio06cc"
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
    FileName = 'mio06cc.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Curr_Code_Header")
                {
                }
                textelement(Curr_Code_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Curr_Code_Header := 'Curr Code';
                    Curr_Code_Desc_Header := 'Curr Code Desc';
                    company_Header := 'Company';
                end;

            }

            tableelement(Currency; Currency)
            {


                textelement(Curr_Code)
                {
                }
                textelement(Curr_Code_Desc)
                {
                }
                textelement(company)
                {
                }
                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                begin
                    Curr_Code := Currency.Code;
                    Curr_Code_Desc := Currency.Description;
                    companyInfo.Get();
                    company := companyInfo.Name;
                end;





            }
        }
    }
}
