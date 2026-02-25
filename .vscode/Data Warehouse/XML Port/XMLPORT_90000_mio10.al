xmlport 90000 "mio10"
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
    // FileName = 'mio10.csv';

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
                textelement("Prod_Code_Header")
                {


                }
                textelement("DepotCode_Header")
                {


                }
                textelement("PurchOrdNo_Header")
                {


                }
                textelement("PordQty_Header")
                {


                }
                textelement("Pord_Qty_OS_Header")
                {


                }

                textelement("Qty_Desc_Header")
                {


                }

                textelement("Pord_Value_Header")
                {


                }
                textelement("Price_Desc_Header")
                {


                }
                textelement("Pord_List_Header")
                {


                }
                textelement("Pord_Price_Header")
                {


                }
                textelement("Receipt_No_Header")
                {


                }
                textelement("OrderDate_Header")
                {


                }
                textelement("DueDate_Header")
                {


                }
                textelement("Orig_Due_Date_Header")
                {


                }
                textelement("Period_Header")
                {


                }
                textelement("Days_Late_Header")
                {


                }

                textelement("Late_Qty_Header")
                {


                }
                textelement("Company_Header")
                {


                }
                textelement("Trans_Anal_6_Header")
                {


                }
                textelement("Account_Year_Header")
                {


                }
                textelement("Account_Month_Header")
                {


                }
                textelement("Sell_By_Date_Header")
                {


                }

                textelement("Cost_in_Currency_Header")
                {


                }
                textelement("Weight_Header")
                {


                }
                textelement("Pord_Type_Header")
                {


                }
                textelement("State_Code_Header")
                {


                }
                textelement("Master_Ord_No_Header")
                {

                }
                textelement("Sales_Ord_No_Header")
                {


                }
                textelement("Sord_Line_No_Header")
                {


                }
                textelement("Pord_Line_No_Header")
                {


                }
                textelement("Pord_Line_Desc_Header")
                {


                }
                textelement("Exch_Rate_Header")
                {


                }
                textelement("Foreign_Curr_Code_Header")
                {


                }
                textelement("PO_Operator_Code_Header")
                {


                }
                textelement("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                {

                }

                trigger OnAfterGetRecord()
                var


                begin
                    Supp_Code_Header := 'Supp Code';
                    Prod_Code_Header := 'Prod Code';
                    DepotCode_Header := 'Depot Code';
                    PurchOrdNo_Header := 'Purch Ord No';
                    PordQty_Header := 'Pord Qty';
                    Pord_Qty_OS_Header := 'Pord Qty OS';
                    Qty_Desc_Header := 'Qty Desc';
                    Pord_Value_Header := 'Pord Value';
                    Price_Desc_Header := 'Price Desc';
                    Pord_List_Header := 'Pord List';
                    Pord_Price_Header := 'Pord Price';
                    Receipt_No_Header := 'Receipt No';
                    OrderDate_Header := 'Order Date';
                    DueDate_Header := 'Due Date';
                    Orig_Due_Date_Header := 'Orig Due Date';
                    Period_Header := 'Period';
                    Days_Late_Header := 'Days Late';
                    Late_Qty_Header := 'Late Qty';
                    Company_Header := 'Company';
                    Trans_Anal_6_Header := 'Trans Anal 6';
                    Account_Year_Header := 'Account Year';
                    Account_Month_Header := 'Account Month';
                    Sell_By_Date_Header := 'Sell By Date';
                    Cost_in_Currency_Header := 'Cost in Currency';
                    Weight_Header := 'Weight';
                    Pord_Type_Header := 'Pord Type';
                    State_Code_Header := 'State Code';
                    Master_Ord_No_Header := 'Master Ord No';
                    Sales_Ord_No_Header := 'Sales Ord No';
                    Sord_Line_No_Header := 'Sord Line No';
                    Pord_Line_No_Header := 'Pord Line No';
                    Pord_Line_Desc_Header := 'Pord Line Desc';
                    Exch_Rate_Header := 'Exch Rate';
                    Foreign_Curr_Code_Header := 'Foreign Curr Code';
                    PO_Operator_Code_Header := 'PO Operator Code';


                end;

            }
            tableelement("Purchase_Line"; "Purchase Line")
            {

                SourceTableView = WHERE(Type = filter(Item), "Document Type" = filter(order), "No." = filter(<> ''));

                textelement("Supp_Code")
                {



                }
                textelement("Prod_Code")
                {


                }
                textelement("DepotCode")
                {


                }
                textelement("PurchOrdNo")
                {


                }
                textelement("PordQty")
                {


                }
                textelement("Pord_Qty_OS")
                {


                }

                textelement("Qty_Desc")
                {


                }

                textelement("Pord_Value")
                {


                }
                textelement("Price_Desc")
                {


                }
                textelement("Pord_List")
                {


                }
                textelement("Pord_Price")
                {


                }
                textelement("Receipt_No")
                {


                }
                textelement("OrderDate")
                {


                }
                textelement("DueDate")
                {


                }
                textelement("Orig_Due_Date")
                {


                }
                textelement("Period")
                {


                }
                textelement("Days_Late")
                {


                }

                textelement("Late_Qty")
                {


                }
                textelement("Company")
                {


                }
                textelement("Trans_Anal_6")
                {


                }
                textelement("Account_Year")
                {


                }
                textelement("Account_Month")
                {


                }
                textelement("Sell_By_Date")
                {


                }

                textelement("Cost_in_Currency")
                {


                }
                textelement("Weight")
                {


                }
                textelement("Pord_Type")
                {


                }
                textelement("State_Code")
                {


                }
                textelement("Master_Ord_No")
                {

                }
                textelement("Sales_Ord_No")
                {


                }
                textelement("Sord_Line_No")
                {


                }
                textelement("Pord_Line_No")
                {


                }
                textelement("Pord_Line_Desc")
                {


                }
                textelement("Exch_Rate")
                {


                }
                textelement("Foreign_Curr_Code")
                {


                }
                textelement("PO_Operator_Code")
                {


                }

                trigger OnAfterGetRecord()
                var
                    L_PurchHeader: Record "Purchase Header";
                    L_Item: record Item;
                    companyInfo: Record "Company Information";
                    L_PurchRectHeader: Record "Purch. Rcpt. Header";
                    StartDate: Date;
                    EndDate: Date;

                begin
                    GetStartAndEndDates(StartDate, EndDate);

                    // Get header
                    if not L_PurchHeader.Get(Purchase_Line."Document Type", Purchase_Line."Document No.") then
                        CurrXMLport.Skip();

                    if not (DT2Date(L_PurchHeader.SystemCreatedAt) in [StartDate .. EndDate]) then
                        CurrXMLport.Skip();
                    // GetStartAndEndDates(StartDate, EndDate);
                    // Purchase_Line.SetRange("Order Date", StartDate, EndDate);
                    // if Purchase_Line.FindSet() then begin
                    //     repeat
                    //         if L_PurchHeader.Get(Purchase_Line."Document Type", Purchase_Line."Document No.") then;
                    // if (L_PurchHeader."Posting Date" >= StartDate) and (L_PurchHeader."Posting Date" <= EndDate) then begin
                    Supp_Code := L_PurchHeader."Buy-from Vendor No.";
                    if Purchase_Line."Variant Code" = '' then begin
                        Prod_Code := Purchase_Line."No.";
                    end else begin
                        Prod_Code := Purchase_Line."Variant Code";
                    end;
                    DepotCode := L_PurchHeader."Location Code";
                    PurchOrdNo := L_PurchHeader."No.";
                    PordQty := format(Purchase_Line.Quantity);
                    Pord_Qty_OS := format(Purchase_Line."Outstanding Quantity");
                    Qty_Desc := Purchase_Line."Unit of Measure";
                    Pord_Value := format(Purchase_Line."Outstanding Amount");
                    Price_Desc := '';
                    L_Item.Get(Purchase_Line."No.");
                    Pord_List := format(L_Item."Unit Price");
                    Pord_Price := format(Purchase_Line."Direct Unit Cost");
                    Receipt_No := Format(Purchase_Line."Receipt No.");
                    // L_PurchRectHeader.Reset();
                    // L_PurchRectHeader.SetRange("Order No.", Purchase_Line."Document No.");
                    // if L_PurchRectHeader.FindFirst() then begin
                    OrderDate := FormatDateForCSV(L_PurchHeader."Order Date");
                    //OrderDate := format(L_PurchHeader."Order Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    //end;
                    DueDate := FormatDateForCSV(L_PurchHeader."Expected Receipt Date");
                    //DueDate := Format(L_PurchHeader."Expected Receipt Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    Orig_Due_Date := FormatDateForCSV(L_PurchHeader."Order Date");

                    // Orig_Due_Date := Format(L_PurchHeader."Due Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    Period := Format(L_PurchHeader."Order Date", 0, '<Month Text>');
                    Period := CopyStr(Period, 1, 3);
                    Days_Late := '';
                    Late_Qty := '';
                    companyInfo.Get();
                    Company := companyInfo.Name;
                    Trans_Anal_6 := '';
                    Account_Year := Format(Date2DMY(L_PurchHeader."Order Date", 3));
                    Account_Year := CopyStr(Account_Year, 2, 4);
                    Account_Month := Period;
                    Sell_By_Date := '00/00/00';
                    Cost_in_Currency := format(Purchase_Line."Unit Cost (LCY)");
                    Weight := '';
                    Pord_Type := '';
                    State_Code := '';
                    Master_Ord_No := '';
                    Sales_Ord_No := '';
                    Sord_Line_No := '';
                    Pord_Line_No := format(Purchase_Line."Line No.");
                    Pord_Line_Desc := Purchase_Line.Description;
                    Exch_Rate := format(L_PurchHeader."Currency Factor");
                    Foreign_Curr_Code := format(L_PurchHeader."Currency Code");
                    PO_Operator_Code := format(L_PurchHeader."Purchaser Code");
                    //         until Purchase_Line.Next() = 0;
                    // end;
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

    procedure GetStartAndEndDates(var StartDate: Date; var EndDate: Date)
    begin

        EndDate := CalcDate('+CM', WorkDate());
        if Date2DMY(WorkDate(), 1) <= 7 then begin
            StartDate := CalcDate('-CM', CalcDate('-1M', WorkDate()));
        end else begin
            StartDate := CalcDate('<-CM>', WorkDate());
        end;
    end;
}