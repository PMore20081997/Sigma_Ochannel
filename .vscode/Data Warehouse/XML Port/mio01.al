xmlport 90002 "mio01"
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
    FileName = 'mio01.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Customer; Customer)
            {

                //SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Cust_Code")
                {

                }

                textelement("Cust_Name")
                {

                }

                textelement("Address_1")
                {

                }

                textelement("Address_2")
                {

                }

                textelement("Address_3")
                {

                }

                textelement("Postcode")
                {

                }

                textelement("Telephone_No")
                {

                }

                textelement("Fax_Number")
                {

                }

                textelement("Market_Code")
                {

                }

                textelement("Cust_Anal_3")
                {

                }

                textelement("Rep_Code")
                {

                }

                textelement("Terr_Man")
                {

                }

                textelement("Contract_Code_1")
                {

                }

                textelement("Top_Level")
                {

                }

                textelement("Contract_Code_2")
                {

                }

                textelement("Credit_Limit")
                {

                }

                textelement("Terms_Desc")
                {

                }

                textelement("Home_Export")
                {

                }

                textelement("Created_Date")
                {

                }

                textelement("Price_List")
                {

                }

                textelement("Cust_Disc_per")
                {

                }

                textelement("Stop_Ind")
                {

                }

                textelement("Op_Code")
                {

                }

                textelement("Service_Depot")
                {

                }

                textelement("COD_Ind")
                {

                }

                textelement("Bako_Cust_Band")
                {

                }

                textelement("Contract_Code_3")
                {

                }

                textelement("Contract_Code_4")
                {

                }

                textelement("Unit_Number")
                {

                }

                textelement("Sedes_Cust_Code")
                {

                }

                textelement("Nu_Care_Baseline")
                {

                }

                textelement("Closed")
                {

                }

                textelement("Cred_Cont")
                {

                }

                textelement("Default_Round")
                {

                }

                textelement("Cust_Anal_1")
                {

                }

                textelement("Cust_Anal_2")
                {

                }

                textelement("Cust_Anal_4")
                {

                }

                textelement("Cust_Anal_5")
                {

                }

                textelement("Cust_Anal_6")
                {

                }

                textelement("Curr_Code")
                {

                }

                textelement("Date_Last_Paid")
                {

                }

                textelement("Last_Pay_Amount")
                {

                }

                textelement("Email")
                {

                }

                textelement("Contact_")
                {

                }

                textelement("Contact_Tel")
                {

                }

                textelement("Contact_Mobile")
                {

                }

                textelement("Contact_Email")
                {

                }

                textelement("Company")
                {

                }

                textelement("Country_Code")
                {

                }

                textelement("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                {

                    trigger OnBeforePassVariable()
                    begin
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    end;
                }



                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                    contact: Record Contact;
                begin
                    Cust_Code := Customer."No.";
                    Cust_Name := Customer.Name;
                    Address_1 := Customer.Address;
                    Address_2 := Customer."Address 2";
                    Address_3 := '';
                    Postcode := Customer."Post Code";
                    Telephone_No := Customer."Phone No.";
                    Fax_Number := Customer."Fax No.";
                    Market_Code := '';
                    Cust_Anal_3 := '';
                    Rep_Code := Customer."Salesperson Code";
                    Terr_Man := Customer."Territory Code";
                    Contract_Code_1 := Customer."Customer Price Group";
                    Top_Level := '';
                    Contract_Code_2 := Customer."Customer Price Group 2";
                    Credit_Limit := format(Customer."Credit Limit (LCY)");
                    Terms_Desc := Customer."Payment Terms Id";
                    Home_Export := '';
                    Created_Date := format(Customer.SystemCreatedAt);
                    Price_List := '';
                    Cust_Disc_per := '';
                    Stop_Ind := format(Customer.Blocked);
                    Op_Code := '';
                    Service_Depot := Customer."Location Code";
                    COD_Ind := '';
                    Bako_Cust_Band := '';
                    Contract_Code_3 := Customer."Customer Price Group 3";
                    Contract_Code_4 := Customer."Customer Price Group 4";
                    Unit_Number := '';
                    Sedes_Cust_Code := '';
                    Nu_Care_Baseline := '';
                    Closed := format(Customer.Blocked);
                    Cred_Cont := '';
                    Default_Round := Customer."Shipping Agent Service Code";
                    Cust_Anal_1 := '';
                    Cust_Anal_2 := '';
                    Cust_Anal_4 := '';
                    Cust_Anal_5 := '';
                    Cust_Anal_6 := '';
                    Curr_Code := Customer."Currency Code";
                    Date_Last_Paid := '';
                    Last_Pay_Amount := '';
                    Email := Customer."E-Mail";
                    companyInfo.Get();
                    contact.Get(Customer."Primary Contact No.");
                    Contact_ := contact.Name;
                    Contact_Tel := Contact."Phone No.";
                    Contact_Mobile := Contact."Mobile Phone No.";
                    Contact_Email := contact."E-Mail";
                    Company := companyInfo.Name;
                    Country_Code := Customer."Currency Code";

                end;
            }

        }
    }
}