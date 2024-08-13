xmlport 90010 "mio06rp"
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
    FileName = 'mio06rp.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Rep_Code_Header")
                {
                }
                textelement(Rep_Code_Desc_Header)
                {
                }
                textelement(Rep_Group_Header)
                {

                }

                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Rep_Code_Header := 'Rep Code';
                    Rep_Code_Desc_Header := 'Rep Code Desc';
                    Rep_Group_Header := 'Rep Group';
                    company_Header := 'Company';


                end;

            }
            tableelement("Salesperson_Purchaser"; "Salesperson/Purchaser")
            {


                textelement(Rep_Code)
                {
                }
                textelement(Rep_Code_Desc)
                {
                }
                textelement(Rep_Group)
                {

                }
                textelement(Company)
                {

                }


                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                begin
                    Rep_Code := "Salesperson_Purchaser".Code;
                    Rep_Code_Desc := "Salesperson_Purchaser".Name;
                    Rep_Group := '??';
                    companyInfo.Get();
                    company := companyInfo.Name;

                end;





            }
        }
    }
}