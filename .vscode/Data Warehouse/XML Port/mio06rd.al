xmlport 90020 "mio06rd"
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
    FileName = 'mio06rd.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Round_Code_Header")
                {
                }
                textelement("Round_Desc_Header")
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Round_Code_Header := 'Cont Code';
                    Round_Desc_Header := 'Cont Name';

                end;

            }
            tableelement("Shipping_Agent_Services"; "Shipping Agent Services")
            {


                textelement(Round_Code)
                {
                }
                textelement(Round_Desc)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Round_Code := Shipping_Agent_Services.Code;
                    Round_Desc := Shipping_Agent_Services.Description;

                end;





            }
        }
    }
}
