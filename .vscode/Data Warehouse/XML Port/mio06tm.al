xmlport 90011 "mio06tm"
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
    FileName = 'mio06tm.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("TM_Code_Header")
                {
                }
                textelement(TM_Desc_Header)
                {
                }
                textelement(TM_Group_Header)
                {

                }

                textelement(company_Header)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    TM_Code_Header := 'TM Code';
                    TM_Desc_Header := 'TM Desc';
                    TM_Group_Header := 'TM Group';
                    company_Header := 'Company';


                end;

            }
            tableelement(Territory; Territory)
            {


                textelement(TM_Code)
                {
                }
                textelement(TM_Desc)
                {
                }
                textelement(TM_Group)
                {

                }
                textelement(Company)
                {

                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    TM_Code := Territory.Code;
                    TM_Desc := Territory.Name;
                    TM_Group := 'Territory Manager Group Not Available';
                    Company := '';
                end;





            }
        }
    }
}