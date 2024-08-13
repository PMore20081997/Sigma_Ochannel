xmlport 90021 "mio06cl"
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
    FileName = 'mio06cl.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Cred_Cont_Code_Header")
                {
                }
                textelement(Cred_Cont_Name_Header)
                {
                }
                textelement(Cred_Cont_Area_Header)
                {
                }

                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cred_Cont_Code_Header := 'Cred Cont Code';
                    Cred_Cont_Name_Header := 'Cred Cont Name';
                    Cred_Cont_Area_Header := 'Cred Cont Area';
                    company_Header := 'Company';
                end;

            }
            tableelement("Return_Reason"; "Return Reason")
            {


                textelement(Cred_Cont_Code)
                {
                }
                textelement(Cred_Cont_Name)
                {
                }
                textelement(Cred_Cont_Area)
                {
                }
                textelement(company)
                {
                }

                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                begin
                    Cred_Cont_Code := Return_Reason.Code;
                    Cred_Cont_Name := Return_Reason.Description;
                    Cred_Cont_Area := '';
                    companyInfo.Get();
                    company := companyInfo.Name;
                end;
            }
        }
    }
}
