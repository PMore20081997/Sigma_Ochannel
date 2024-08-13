xmlport 90007 "mio06dp"
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
    FileName = 'mio6ntt.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Depot_Code_Header")
                {
                }
                textelement(Depot_Desc_Header)
                {
                }
                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Depot_Code_Header := 'Depot Code';
                    Depot_Desc_Header := 'Depot Desc';
                    company_Header := 'Company';
                end;

            }
            tableelement(Location; Location)
            {


                textelement(Depot_Code)
                {
                }
                textelement(Depot_Desc)
                {
                }
                textelement(Company)
                {

                }

                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                begin
                    Depot_Code := Location.Code;
                    Depot_Desc := Location.Name;
                    companyInfo.Get();
                    company := companyInfo.Name;
                end;





            }
        }
    }
}