xmlport 90004 "mio06con"
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
    FileName = 'mio06con.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Cont_Code_Header")
                {
                }
                textelement(Cont_Name_Header)
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cont_Code_Header := 'Cont Code';
                    Cont_Name_Header := 'Cont Name';

                end;

            }
            tableelement("Price_List_Header"; "Price List Header")
            {


                textelement(Cont_Code)
                {
                }
                textelement(Cont_Name)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cont_Code := Price_List_Header.Code;
                    Cont_Name := Price_List_Header.Description;

                end;





            }
        }
    }
}
