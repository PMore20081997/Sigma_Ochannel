xmlport 90019 "mio09"
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
    FileName = 'mio09.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement("Del_Cust_Code_Header")
                {
                }

                textelement("Del_Code_Header")
                {
                }

                textelement("Del_Name_Header")
                {
                }

                textelement("Del_Ad1_Header")
                {
                }

                textelement("Del_Ad2_Header")
                {
                }

                textelement("Del_Ad3_Header")
                {
                }

                textelement("Del_Ad4_Header")
                {
                }

                textelement("Del_Contact_Header")
                {
                }

                textelement("Del_Tel_No_Header")
                {
                }

                textelement("Del_Contact_Tel_No_Header")
                {
                }

                textelement("Del_Contact_Mobile_Header")
                {
                }

                textelement("Del_Contact_Email_Header")
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Del_Cust_Code_Header := 'Del Cust Code';
                    Del_Code_Header := 'Del Code';
                    Del_Name_Header := 'Del Name';
                    Del_Ad1_Header := 'Del Ad1';
                    Del_Ad2_Header := 'Del Ad2';
                    Del_Ad3_Header := 'Del Ad3';
                    Del_Ad4_Header := 'Del Ad4';
                    Del_Contact_Header := 'Del Contact';
                    Del_Tel_No_Header := 'Del Tel No';
                    Del_Contact_Tel_No_Header := 'Del Contact Tel No';
                    Del_Contact_Mobile_Header := 'Del Contact Mobile';
                    Del_Contact_Email_Header := 'Del Contact Email';

                end;

            }
            tableelement("Ship-to_Address"; "Ship-to Address")
            {
                textelement("Del_Cust_Code")
                {
                }

                textelement("Del_Code")
                {
                }

                textelement("Del_Name")
                {
                }

                textelement("Del_Ad1")
                {
                }

                textelement("Del_Ad2")
                {
                }

                textelement("Del_Ad3")
                {
                }

                textelement("Del_Ad4")
                {
                }

                textelement("Del_Contact")
                {
                }

                textelement("Del_Tel_No")
                {
                }

                textelement("Del_Contact_Tel_No")
                {
                }

                textelement("Del_Contact_Mobile")
                {
                }

                textelement("Del_Contact_Email")
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Del_Cust_Code := "Ship-to_Address"."Customer No.";
                    Del_Code := "Ship-to_Address".Code;
                    Del_Name := "Ship-to_Address".Name;
                    Del_Ad1 := "Ship-to_Address".Address;
                    Del_Ad2 := "Ship-to_Address"."Address 2";
                    Del_Ad3 := "Ship-to_Address".County;
                    Del_Ad4 := "Ship-to_Address"."Post Code";
                    Del_Contact := "Ship-to_Address".Contact;
                    Del_Tel_No := "Ship-to_Address"."Phone No.";
                    Del_Contact_Tel_No := "Ship-to_Address"."Phone No.";
                    Del_Contact_Mobile := "Ship-to_Address"."Phone No.";
                    Del_Contact_Email := "Ship-to_Address"."E-Mail";

                end;
            }
        }
    }
}