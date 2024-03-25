xmlport 90015 "mio82"
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
    FileName = 'mio82.csv';

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

                textelement("Depot_Code_Header")
                {

                }

                textelement("Grn_No_Header")
                {

                }
                textelement("Pord_Qty_Header")
                {

                }

                textelement("Grn_Qty_Header")
                {

                }

                textelement("Qty_Desc_Header")
                {

                }

                textelement("Pord_Value_Header")
                {

                }

                textelement("Grn_Value_Header")
                {

                }

                textelement("Price_Desc_Header")
                {

                }

                textelement("Grn_Price_Header")
                {

                }

                textelement("Receipt_Date_Header")
                {

                }

                textelement("Due_Date_Header")
                {

                }

                textelement("Weight_Header")
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

                textelement("Return_Qty_Header")
                {

                }

                textelement("Claim_Qty_Header")
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

                textelement("Purch_Ord_No_Header")
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

                textelement("Order_Date_Header")
                {

                }

                textelement("Pord_FC_Value_Header")
                {

                }

                textelement("Pord_Exch_Rate_Header")
                {

                }

                textelement("GRN_Exch_Rate_Header")
                {

                }

                textelement("Foreign_Curr_Code_Header")
                {

                }

                textelement("Pord_Type_Header")
                {

                }

                textelement("PO_Operator_Code_Header")
                {

                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Supp_Code_Header := 'Supp Code';
                    Prod_Code_Header := 'Prod Code';
                    Depot_Code_Header := 'Depot Code';
                    Grn_No_Header := 'Grn No';
                    Pord_Qty_Header := 'Pord Qty';
                    Grn_Qty_Header := 'Grn Qty';
                    Qty_Desc_Header := 'Qty Desc';
                    Pord_Value_Header := 'Pord Value';
                    Grn_Value_Header := 'Grn Value';
                    Price_Desc_Header := 'Price Desc';
                    Grn_Price_Header := 'Grn Price';
                    Receipt_Date_Header := 'Receipt Date';
                    Due_Date_Header := 'Due Date';
                    Weight_Header := 'Weight';
                    Period_Header := 'Period';
                    Days_Late_Header := 'Days Late';
                    Late_Qty_Header := 'Late Qty';
                    Return_Qty_Header := 'Return Qty';
                    Claim_Qty_Header := 'Claim Qty';
                    Company_Header := 'Company';
                    Trans_Anal_6_Header := 'Trans Anal 6';
                    Account_Year_Header := 'Account Year';
                    Account_Month_Header := 'Account Month';
                    Sell_By_Date_Header := 'Sell By Date';
                    Cost_in_Currency_Header := 'Cost in Currency';
                    Purch_Ord_No_Header := 'Purch Ord No';
                    Master_Ord_No_Header := 'Master Ord No';
                    Sales_Ord_No_Header := 'Sales Ord No';
                    Sord_Line_No_Header := 'Sord Line No';
                    Pord_Line_No_Header := 'Pord Line No';
                    Pord_Line_Desc_Header := 'Pord Line Desc';
                    Order_Date_Header := 'Order Date';
                    Pord_FC_Value_Header := 'Pord FC Value';
                    Pord_Exch_Rate_Header := 'Pord Exch Rate';
                    GRN_Exch_Rate_Header := 'GRN Exch Rate';
                    Foreign_Curr_Code_Header := 'Foreign Curr Code';
                    Pord_Type_Header := 'Pord Type';
                    PO_Operator_Code_Header := 'PO Operator Code';
                end;

            }
            tableelement("Purch_Rcpt_Header"; "Purch. Rcpt. Header")
            {

                textelement(Supp_Code)
                {
                }
                textelement(Prod_Code)
                {
                }
                textelement(Depot_Code)
                {
                }
                textelement(Grn_No)
                {
                }
                textelement(Prod_Qty)
                {
                }
                textelement("Grn_Qty")
                {

                }

                textelement("Qty_Desc")
                {

                }

                textelement("Pord_Value")
                {

                }

                textelement("Grn_Value")
                {

                }

                textelement("Price_Desc")
                {

                }

                textelement("Grn_Price")
                {

                }

                textelement("Receipt_Date")
                {

                }

                textelement("Due_Date")
                {

                }

                textelement("Weight")
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

                textelement("Return_Qty")
                {

                }

                textelement("Claim_Qty")
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

                textelement("Purch_Ord_No")
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

                textelement("Order_Date")
                {

                }

                textelement("Pord_FC_Value")
                {

                }

                textelement("Pord_Exch_Rate")
                {

                }

                textelement("GRN_Exch_Rate")
                {

                }

                textelement("Foreign_Curr_Code")
                {

                }

                textelement("Pord_Type")
                {

                }

                textelement("PO_Operator_Code")
                {

                }


                trigger OnAfterGetRecord()
                var
                    L_PurchReceiptLine: Record "Purch. Rcpt. Line";
                begin
                    L_PurchReceiptLine.Get(Purch_Rcpt_Header."No.");
                    Supp_Code := Purch_Rcpt_Header."Buy-from Vendor No.";


                end;





            }
        }
    }
}