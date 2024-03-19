xmlport 90008 "mio06cr"
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
    FileName = 'mio06cr.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Credit_Reason_Header")
                {
                }
                textelement(Reason_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Credit_Reason_Header := 'Credit Reason';
                    Reason_Desc_Header := 'Reason Desc';
                    company_Header := 'Company';
                end;

            }
            tableelement("Return_Reason"; "Return Reason")
            {


                textelement(Credit_Reason)
                {
                }
                textelement(Reason_Desc)
                {
                }
                textelement(company)
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Credit_Reason := Return_Reason.Code;
                    Reason_Desc := Return_Reason.Description;
                    company := '';
                end;





            }
        }
    }
}
