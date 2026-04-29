xmlport 90037 "mio06wb"
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
    FileName = 'mio06wb.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Web_Doc_Header")
                {
                }
                textelement("Sales_No_Header")
                {
                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Web_Doc_Header := 'Web Document No.';
                    Sales_No_Header := 'Sales Document No.';

                end;
            }
            tableelement("Web_Buffer"; "Web Buffer")
            {
                textelement(Web_Doc)
                {
                }
                textelement(Sales_No)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Web_Doc := Web_Buffer."Web Document No.";
                    Sales_No := Web_Buffer."Sales Document No.";
                end;

                trigger OnPreXmlItem()
                var
                    fromDate: Date;
                begin
                    fromDate := CalcDate('-1D', WorkDate());
                    Web_Buffer.SetRange("Created At", fromDate);
                end;
            }

        }

    }

}
