xmlport 90012 "mio06vt"
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
    FileName = 'mio06vt.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Vat_Code_Header")
                {
                }
                textelement(Vat_Code_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Vat_Code_Header := 'Vat Code';
                    Vat_Code_Desc_Header := 'Vat Code Desc';
                    company_Header := 'Company';


                end;

            }
            tableelement("VAT_Product_Posting_Group"; "VAT Product Posting Group")
            {


                textelement(Vat_Code)
                {
                }
                textelement(Vat_Code_Desc)
                {
                }

                textelement(Company)
                {

                }


                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                begin
                    Vat_Code := "VAT_Product_Posting_Group".Code;
                    Vat_Code_Desc := "VAT_Product_Posting_Group".Description;
                    companyInfo.Get();
                    company := companyInfo.Name;

                end;





            }
        }
    }
}