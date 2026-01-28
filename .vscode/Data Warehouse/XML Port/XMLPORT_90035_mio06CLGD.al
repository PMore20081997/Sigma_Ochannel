xmlport 90035 mio06CLGD
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
    FileName = 'mio06clgd.csv';

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

                textelement("License_Header")
                {

                }
                textelement("LicenseCode_Header")
                {

                }

                textelement("GrantDate_Header")
                {

                }

                textelement("QAU_Header")
                {

                }
                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    "Cust_Code_Header" := 'Customer No.';
                    License_Header := 'License No.';
                    LicenseCode_Header := 'License Code';
                    GrantDate_Header := 'Grant Date';
                    QAU_Header := 'QAU Approval flag';
                end;
            }
            tableelement("Company_License_Header"; "Company License Header")
            {

                SourceTableView = WHERE("Company Type" = filter(Customer));

                textelement("Cust_Code")
                {

                }

                textelement("License_No")
                {

                }
                textelement("License_Code")
                {

                }

                textelement("Grant_Date")
                {

                }

                textelement("QAU_Approval")
                {

                }
                trigger OnAfterGetRecord()
                var
                    Customer: Record Customer;

                begin
                    Cust_Code := Company_License_Header."Company No.";
                    License_No := Company_License_Header."License No.";
                    License_Code := Company_License_Header."License Code";
                    Grant_Date := FormatDateForCSV(Company_License_Header."Grant Date");

                    Customer.Reset();
                    Customer.SetRange("No.", Company_License_Header."Company No.");
                    if Customer.FindFirst() then begin
                        QAU_Approval := Format(Customer."QAU Approved");
                    end;

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

    var
        myInt: Integer;
}