xmlport 90033 "mio06rc"
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
    FileName = 'mio06rc.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Reason_Code_Header")
                {
                }
                textelement("Reason_Desc_Header")
                {
                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Reason_Code_Header := 'Block Reason Code';
                    Reason_Desc_Header := 'Block Description';

                end;

            }
            tableelement("Cust_Block_Reason_Code"; "Cust. Block Reason Code")
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
                    Round_Code := Cust_Block_Reason_Code.Code;
                    Round_Desc := Cust_Block_Reason_Code.Description;

                end;





            }
        }
    }
}
