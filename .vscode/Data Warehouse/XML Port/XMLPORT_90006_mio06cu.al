xmlport 90006 "mio06cu"
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
    FileName = 'mio06cu.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Cust_Code_Header")
                {
                }
                textelement("Cust_Name_Header")
                {
                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cust_Code_Header := 'Cust Code';
                    Cust_Name_Header := 'Cust Name';

                end;
            }
            tableelement("Customer_Price_Group"; "Customer Price Group")
            {


                textelement(Cust_Code)
                {
                }
                textelement(Cust_Name)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cust_Code := "Customer_Price_Group".Code;
                    Cust_Name := "Customer_Price_Group".Description;

                end;





            }
        }
    }
}