xmlport 90014 "mio0617"
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
    FileName = 'mio0617.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Company_Code_Header")
                {
                }
                textelement(Company_Name_Header)
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Company_Code_Header := 'Company Code';
                    Company_Name_Header := 'Company Name';

                end;

            }
            tableelement(Company; Company)
            {


                textelement(Company_Code)
                {
                }
                textelement(Company_Name)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Company_Code := Company.Id;
                    Company_Name := Company."Display Name";
                end;





            }
        }
    }
}