xmlport 90018 "mio06su"
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
    FileName = 'mio06su.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement("Supp_Code_Header")
                {
                }

                textelement("Supp_Name_Header")
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

                textelement("Post_Code_Header")
                {
                }

                textelement("Contact_Header")
                {
                }

                textelement("Tel_No_Header")
                {
                }

                textelement("Stop_Ind_Header")
                {
                }

                textelement("Buyer_Code_Header")
                {
                }

                textelement("Curr_Code_Header")
                {
                }

                textelement("Group_Code_Header")
                {
                }

                textelement("Category_Header")
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

                textelement("Contact_Telephone_Header")
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

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Supp_Code_Header := 'Supp Code';
                    Supp_Name_Header := 'Supp Name';
                    Address_1_Header := 'Address 1';
                    Address_2_Header := 'Address 2';
                    Address_3_Header := 'Address 3';
                    Post_Code_Header := 'Post Code';
                    Contact_Header := 'Contact';
                    Tel_No_Header := 'Tel No';
                    Stop_Ind_Header := 'Stop Ind';
                    Buyer_Code_Header := 'Buyer Code';
                    Curr_Code_Header := 'Curr Code';
                    Group_Code_Header := 'Group Code';
                    Category_Header := 'Category';
                    Date_Last_Paid_Header := 'Date Last Paid';
                    Last_Pay_Amount_Header := 'Last Pay Amount';
                    Email_Header := 'Email';
                    Contact_Telephone_Header := 'Contact Telephone';
                    Contact_Mobile_Header := 'Contact Mobile';
                    Contact_Email_Header := 'Contact Email';
                    Company_Header := 'Company';

                end;
            }
            tableelement(Vendor; Vendor)
            {
                textelement("Supp_Code")
                {
                }

                textelement("Supp_Name")
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

                textelement("Post_Code")
                {
                }

                textelement("Contact")
                {
                }

                textelement("Tel_No")
                {
                }

                textelement("Stop_Ind")
                {
                }

                textelement("Buyer_Code")
                {
                }

                textelement("Curr_Code")
                {
                }

                textelement("Group_Code")
                {
                }

                textelement("Category")
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

                textelement("Contact_Telephone")
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

                trigger OnAfterGetRecord()
                var
                    vendorLedgerEntry: Record "Vendor Ledger Entry";
                    companyInfo: Record "Company Information";
                begin
                    Supp_Code := Vendor."No.";
                    Supp_Name := Vendor.Name;
                    Address_1 := Vendor.Address;
                    Address_2 := Vendor."Address 2";
                    Address_3 := Vendor.County;
                    Post_Code := Vendor."Post Code";
                    Contact := Vendor."Primary Contact No.";
                    Tel_No := Vendor."Phone No.";
                    Stop_Ind := Format(Vendor.Blocked);
                    Buyer_Code := Vendor."Purchaser Code";
                    Curr_Code := Vendor."Currency Code";
                    Group_Code := '';
                    Category := '';
                    vendorLedgerEntry.Reset();
                    vendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
                    if vendorLedgerEntry.FindLast() then begin
                        Date_Last_Paid := FormatDateForCSV(vendorLedgerEntry."Document Date");
                        // Date_Last_Paid := Format(vendorLedgerEntry."Document Date");
                        Last_Pay_Amount := Format(vendorLedgerEntry.Amount);
                    end;
                    Email := Vendor."E-Mail";
                    Contact_Telephone := '';
                    Contact_Mobile := '';
                    Contact_Email := '';
                    companyInfo.Get();
                    Company := companyInfo.Name;
                end;

            }



        }
    }
    procedure FormatDateForCSV(MyDate: Date): Text[10];
    var
        DayStr: Text[2];
        MonthStr: Text[2];
        YearStr: Text[4];
    begin
        if MyDate = 0D then
            exit('');
        DayStr := Format(Date2DMY(MyDate, 1));
        MonthStr := Format(Date2DMY(MyDate, 2));
        YearStr := Format(Date2DMY(MyDate, 3));

        if STRLEN(DayStr) = 1 then
            DayStr := '0' + DayStr;
        if STRLEN(MonthStr) = 1 then
            MonthStr := '0' + MonthStr;
        exit(DayStr + '/' + MonthStr + '/' + YearStr);
    end;
}