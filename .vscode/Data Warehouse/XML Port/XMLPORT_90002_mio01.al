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
            tableelement(Integer; Integer)

            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement("Cust_Code_Header")
                {

                }

                textelement("Cust_Name_Header")
                {

                }

                textelement("Address_1_Header")
                {

                }

                textelement("Address_2_Header")
                {

                }

                textelement("Address_3_Header")
                {

                }

                textelement("Postcode_Header")
                {

                }

                textelement("Telephone_No_Header")
                {

                }

                textelement("Fax_Number_Header")
                {

                }

                textelement("Market_Code_Header")
                {

                }

                textelement("Cust_Anal_3_Header")
                {

                }

                textelement("Rep_Code_Header")
                {

                }

                textelement("Terr_Man_Header")
                {

                }

                textelement("Contract_Code_1_Header")
                {

                }

                textelement("Top_Level_Header")
                {

                }

                textelement("Contract_Code_2_Header")
                {

                }

                textelement("Credit_Limit_Header")
                {

                }

                textelement("Terms_Desc_Header")
                {

                }

                textelement("Home_Export_Header")
                {

                }

                textelement("Created_Date_Header")
                {

                }

                textelement("Price_List_Header")
                {

                }

                textelement("Cust_Disc_per_Header")
                {

                }

                textelement("Stop_Ind_Header")
                {

                }

                textelement("Op_Code_Header")
                {

                }

                textelement("Service_Depot_Header")
                {

                }

                textelement("COD_Ind_Header")
                {

                }

                textelement("Bako_Cust_Band_Header")
                {

                }

                textelement("Contract_Code_3_Header")
                {

                }

                textelement("Contract_Code_4_Header")
                {

                }

                textelement("Unit_Number_Header")
                {

                }

                textelement("Sedes_Cust_Code_Header")
                {

                }

                textelement("Nu_Care_Baseline_Header")
                {

                }

                textelement("Closed_Header")
                {

                }

                textelement("Cred_Cont_Header")
                {

                }

                textelement("Default_Round_Header")
                {

                }

                textelement("Cust_Anal_1_Header")
                {

                }

                textelement("Cust_Anal_2_Header")
                {

                }

                textelement("Cust_Anal_4_Header")
                {

                }

                textelement("Cust_Anal_5_Header")
                {

                }

                textelement("Cust_Anal_6_Header")
                {

                }

                textelement("Curr_Code_Header")
                {

                }

                textelement("Date_Last_Paid_Header")
                {

                }

                textelement("Last_Pay_Amount_Header")
                {

                }

                textelement("Email_Header")
                {

                }

                textelement("Contact__Header")
                {

                }

                textelement("Contact_Tel_Header")
                {

                }

                textelement("Contact_Mobile_Header")
                {

                }

                textelement("Contact_Email_Header")
                {

                }

                textelement("Company_Header")
                {

                }

                textelement("Country_Code_Header")
                {

                }
                textelement("Customer_type_Header")
                {

                }

                textelement("Cust_Bako_Band_Ind_Header")
                {

                }

                textelement("Payment_Stop_Header")
                {

                }

                textelement("DD_Marker_Header")
                {

                }

                textelement("Daily_Min_Order_Value_Header")
                {

                }

                textelement("Min_Order_Value_Header")
                {

                }
                textelement("LTD_Name_Header")
                {

                }


                textelement(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)
                {

                }


                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    "Cust_Code_Header" := 'Cust Code';
                    "Cust_Name_Header" := 'Cust Name';
                    "Address_1_Header" := 'Address 1';
                    "Address_2_Header" := 'Address 2';
                    "Address_3_Header" := 'Address 3';
                    "Postcode_Header" := 'Postcode';
                    "Telephone_No_Header" := 'Telephone No';
                    "Fax_Number_Header" := 'Fax Number';
                    "Market_Code_Header" := 'Market Code';
                    "Cust_Anal_3_Header" := 'Cust Anal 3';
                    "Rep_Code_Header" := 'Rep Code';
                    "Terr_Man_Header" := 'Terr Man';
                    "Contract_Code_1_Header" := 'Contract Code 1';
                    "Top_Level_Header" := 'Top Level';
                    "Contract_Code_2_Header" := 'Contract Code 2';
                    "Credit_Limit_Header" := 'Credit Limit';
                    "Terms_Desc_Header" := 'Terms Desc';
                    "Home_Export_Header" := 'Home Export';
                    "Created_Date_Header" := 'Created Date';
                    "Price_List_Header" := 'Price List';
                    "Cust_Disc_per_Header" := 'Cust Disc %';
                    "Stop_Ind_Header" := 'Stop Ind';
                    "Op_Code_Header" := 'Op Code';
                    "Service_Depot_Header" := 'Service Depot';
                    "COD_Ind_Header" := 'COD Ind';
                    "Bako_Cust_Band_Header" := 'Bako Cust Band';
                    "Contract_Code_3_Header" := 'Contract Code 3';
                    "Contract_Code_4_Header" := 'Contract Code 4';
                    "Unit_Number_Header" := 'Unit Number';
                    "Sedes_Cust_Code_Header" := 'Sedes Cust Code';
                    "Nu_Care_Baseline_Header" := 'Nu-Care Baseline';
                    "Closed_Header" := 'Closed';
                    "Cred_Cont_Header" := 'Cred Cont';
                    "Default_Round_Header" := 'Default Round';
                    "Cust_Anal_1_Header" := 'Cust Anal 1';
                    "Cust_Anal_2_Header" := 'Cust Anal 2';
                    "Cust_Anal_4_Header" := 'Cust Anal 4';
                    "Cust_Anal_5_Header" := 'Cust Anal 5';
                    "Cust_Anal_6_Header" := 'Cust Anal 6';
                    "Curr_Code_Header" := 'Curr Code';
                    "Date_Last_Paid_Header" := 'Date Last Paid';
                    "Last_Pay_Amount_Header" := 'Last Pay Amount';
                    "Email_Header" := 'Email';
                    "Contact__Header" := 'Contact';
                    "Contact_Tel_Header" := 'Contact Tel';
                    "Contact_Mobile_Header" := 'Contact Mobile';
                    "Contact_Email_Header" := 'Contact Email';
                    "Company_Header" := 'Company';
                    "Country_Code_Header" := 'Country Code';
                    "Customer_type_Header" := 'Customer_type';
                    "Cust_Bako_Band_Ind_Header" := 'Cust_Bako_Band_Ind';
                    "Payment_Stop_Header" := 'Payment_Stop';
                    "DD_Marker_Header" := 'DD_Marker';
                    "Daily_Min_Order_Value_Header" := 'Daily_Min_Order_Value';
                    "Min_Order_Value_Header" := 'Min_Order_Value';
                    LTD_Name_Header := 'LTD Name';
                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX := XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;

                end;
            }

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
                textelement("Customer_type")
                {

                }

                textelement("Cust_Bako_Band_Ind")
                {

                }

                textelement("Payment_Stop")
                {

                }

                textelement("DD_Marker")
                {

                }

                textelement("Daily_Min_Order_Value")
                {

                }

                textelement("Min_Order_Value")
                {

                }
                textelement("LTD_Name")
                {

                }



                trigger OnAfterGetRecord()
                var
                    companyInfo: Record "Company Information";
                    contact: Record Contact;
                    CustLedger: Record "Cust. Ledger Entry";
                    CustDimension: Record "Default Dimension";

                begin
                    Cust_Code := Customer."No.";
                    Cust_Name := Customer.Name;
                    Address_1 := Customer.Address;
                    Address_2 := Customer."Address 2";
                    Address_3 := Customer.City;
                    Postcode := Customer."Post Code";
                    Telephone_No := Customer."Phone No.";
                    Fax_Number := Customer."Fax No.";
                    Market_Code := '';
                    Cust_Anal_3 := '';
                    Rep_Code := Customer."Territory Code";
                    Terr_Man := Customer."Salesperson Code";
                    Contract_Code_1 := Customer."Customer Price Group";
                    Top_Level := '';
                    Contract_Code_2 := Customer."Customer Price Group 2";
                    Credit_Limit := format(Customer."Credit Limit (LCY)");
                    Terms_Desc := Customer."Payment Terms Code";
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
                    Closed := '';
                    Cred_Cont := '';
                    Default_Round := Customer."Shipping Agent Service Code";
                    Cust_Anal_1 := '';
                    Cust_Anal_2 := '';
                    Cust_Anal_4 := '';
                    Cust_Anal_5 := '';
                    Cust_Anal_6 := '';
                    Curr_Code := Customer."Currency Code";
                    CustLedger.Reset();
                    CustLedger.SetRange("Customer No.", Customer."No.");
                    CustLedger.SetRange("Document Type", CustLedger."Document Type"::Payment);
                    if CustLedger.FindLast() then begin
                        Date_Last_Paid := Format(CustLedger."Posting Date");
                    end;

                    Last_Pay_Amount := '';
                    Email := Customer."E-Mail";
                    companyInfo.Get();
                    if contact.Get(Customer."Primary Contact No.") then begin
                        Contact_ := Contact.Name;
                        Contact_Tel := Contact."Phone No.";
                        Contact_Mobile := Contact."Mobile Phone No.";
                        Contact_Email := contact."E-Mail";
                    end;
                    Company := companyInfo.Name;
                    Country_Code := Customer."Country/Region Code";
                    CustDimension.Reset();
                    CustDimension.SetRange("No.", Customer."No.");
                    CustDimension.SetRange("Dimension Code", 'CUSTOMER TYPE');
                    if CustDimension.FindFirst() then begin
                        "Customer_type" := CustDimension."Dimension Value Code";
                    end;
                    "Cust_Bako_Band_Ind" := '';
                    "Payment_Stop" := '';
                    "DD_Marker" := Customer."Payment Method Code";
                    "Daily_Min_Order_Value" := '';
                    "Min_Order_Value" := Format(Customer."Min Order Value");
                    LTD_Name := Customer."Name 2";

                end;
            }

        }
    }
}