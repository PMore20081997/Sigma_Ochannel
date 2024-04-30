xmlport 90016 "mio47"
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
    FileName = 'mio47.csv';

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

                textelement("Prod_Code_Header")
                {
                }

                textelement("Qty_Header")
                {
                }

                textelement("Val_Header")
                {
                }

                textelement("Cst_Header")
                {
                }

                textelement("Del_Date_Header")
                {
                }

                textelement("Rep_Code_Header")
                {
                }

                textelement("Terr_Man_Header")
                {
                }

                textelement("Price_Type_Header")
                {
                }

                textelement("Supp_Dep_Header")
                {
                }

                textelement("Ord_No_Header")
                {
                }

                textelement("Op_Code_Header")
                {
                }

                textelement("Ord_Type_Header")
                {
                }

                textelement("Round_Header")
                {
                }

                textelement("Pack_Price_Header")
                {
                }

                textelement("Prod_Group_Header")
                {
                }

                textelement("Margin_Header")
                {
                }

                textelement("Period_Header")
                {
                }

                textelement("Supp_Code_Header")
                {
                }

                textelement("Weight_Header")
                {
                }

                textelement("Ord_Date_Header")
                {
                }

                textelement("FOC_Ind_Header")
                {
                }

                textelement("Vehicle_Reg_Header")
                {
                }

                textelement("Inv_Cred_Header")
                {
                }

                textelement("Cred_Reason_Header")
                {
                }

                textelement("Drop_Seq_Header")
                {
                }

                textelement("Comb_Disc_Header")
                {
                }

                textelement("Del_Code_Header")
                {
                }

                textelement("Lost_Pick_Header")
                {
                }

                textelement("Lost_Desp_Header")
                {
                }

                textelement("Pick_Conf_Code_Header")
                {
                }

                textelement("Order_Time_Header")
                {
                }

                textelement("Company_Header")
                {
                }

                textelement("Picker_Code_Header")
                {
                }

                textelement("Line_Type_Header")
                {
                }

                textelement("Volume_Header")
                {
                }

                textelement("Inv_Date_Header")
                {
                }

                textelement("Cust_Ord_No_Header")
                {
                }

                textelement("Inv_No_Header")
                {
                }

                textelement("Promise_Date_Header")
                {
                }

                textelement("Account_Year_Header")
                {
                }

                textelement("Account_Month_Header")
                {
                }

                textelement("Sell_by_date_Header")
                {
                }

                textelement("CustProdCode_Header")
                {
                }

                textelement("SalesAd1_Header")
                {
                }

                textelement("SalesAd2_Header")
                {
                }

                textelement("SalesAd3_Header")
                {
                }

                textelement("SalesAd4_Header")
                {
                }

                textelement("SalesAd5_Header")
                {
                }

                textelement("SalesAd6_Header")
                {
                }

                textelement("SalesAnal1_Header")
                {
                }

                textelement("SalesAnal2_Header")
                {
                }

                textelement("SalesAnal3_Header")
                {
                }

                textelement("SalesAnal4_Header")
                {
                }

                textelement("SalesAnal5_Header")
                {
                }

                textelement("SalesAnal6_Header")
                {
                }

                textelement("Job_Number_Header")
                {
                }

                textelement("Master_Ord_No_Header")
                {
                }

                textelement("Purch_Ord_No_Header")
                {
                }

                textelement("Sord_Line_No_Header")
                {
                }

                textelement("Pord_Line_No_Header")
                {
                }

                textelement("ActCst_Header")
                {
                }

                textelement("Sord_Line_Desc_Header")
                {
                }

                textelement("Qty_Ordered_Header")
                {
                }

                textelement("Landed_Cost_Header")
                {
                }

                textelement("FC_Val_Header")
                {
                }

                textelement("Exch_Rate_Header")
                {
                }

                textelement("Foreign_Curr_Code_Header")
                {
                }

                textelement("RM_Cost_Header")
                {
                }

                textelement("Direct_Labour_Header")
                {
                }

                textelement("Direct_OH_Header")
                {
                }

                textelement("Indirect_OH_Header")
                {
                }

                textelement("Finishing_Costs_Header")
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Cust_Code_Header := 'Cust Code';
                    Prod_Code_Header := 'Prod Code';
                    Qty_Header := 'Qty';
                    Val_Header := 'Val';
                    Cst_Header := 'Cst';
                    Del_Date_Header := 'Del Date';
                    Rep_Code_Header := 'Rep Code';
                    Terr_Man_Header := 'Terr Man';
                    Price_Type_Header := 'Price Type';
                    Supp_Dep_Header := 'Supp Dep';
                    Ord_No_Header := 'Ord No';
                    Op_Code_Header := 'Op Code';
                    Ord_Type_Header := 'Ord Type';
                    Round_Header := 'Round';
                    Pack_Price_Header := 'Pack Price';
                    Prod_Group_Header := 'Prod Group';
                    Margin_Header := 'Margin';
                    Period_Header := 'Period';
                    Supp_Code_Header := 'Supp Code';
                    Weight_Header := 'Weight';
                    Ord_Date_Header := 'Ord Date';
                    FOC_Ind_Header := 'FOC Ind';
                    Vehicle_Reg_Header := 'Vehicle Reg';
                    Inv_Cred_Header := 'Inv/Cred';
                    Cred_Reason_Header := 'Cred Reason';
                    Drop_Seq_Header := 'Drop Seq';
                    Comb_Disc_Header := 'Comb Disc';
                    Del_Code_Header := 'Del Code';
                    Lost_Pick_Header := 'Lost Pick';
                    Lost_Desp_Header := 'Lost Desp';
                    Pick_Conf_Code_Header := 'Pick Conf Code';
                    Order_Time_Header := 'Order Time';
                    Company_Header := 'Company';
                    Picker_Code_Header := 'Picker Code';
                    Line_Type_Header := 'Line Type';
                    Volume_Header := 'Volume';
                    Inv_Date_Header := 'Inv Date';
                    Cust_Ord_No_Header := 'Cust Ord No';
                    Inv_No_Header := 'Inv No';
                    Promise_Date_Header := 'Promise Date';
                    Account_Year_Header := 'Account Year';
                    Account_Month_Header := 'Account Month';
                    Sell_by_date_Header := 'Sell by date';
                    CustProdCode_Header := 'CustProdCode';
                    SalesAd1_Header := 'SalesAd1';
                    SalesAd2_Header := 'SalesAd2';
                    SalesAd3_Header := 'SalesAd3';
                    SalesAd4_Header := 'SalesAd4';
                    SalesAd5_Header := 'SalesAd5';
                    SalesAd6_Header := 'SalesAd6';
                    SalesAnal1_Header := 'SalesAnal1';
                    SalesAnal2_Header := 'SalesAnal2';
                    SalesAnal3_Header := 'SalesAnal3';
                    SalesAnal4_Header := 'SalesAnal4';
                    SalesAnal5_Header := 'SalesAnal5';
                    SalesAnal6_Header := 'SalesAnal6';
                    Job_Number_Header := 'Job Number';
                    Master_Ord_No_Header := 'Master Ord No';
                    Purch_Ord_No_Header := 'Purch Ord No';
                    Sord_Line_No_Header := 'Sord Line No';
                    Pord_Line_No_Header := 'Pord Line No';
                    ActCst_Header := 'ActCst';
                    Sord_Line_Desc_Header := 'Sord Line Desc';
                    Qty_Ordered_Header := 'Qty Ordered';
                    Landed_Cost_Header := 'Landed Cost';
                    FC_Val_Header := 'FC Val';
                    Exch_Rate_Header := 'Exch Rate';
                    Foreign_Curr_Code_Header := 'Foreign Curr Code';
                    RM_Cost_Header := 'RM Cost';
                    Direct_Labour_Header := 'Direct Labour';
                    Direct_OH_Header := 'Direct OH';
                    Indirect_OH_Header := 'Indirect OH';
                    Finishing_Costs_Header := 'Finishing Costs';

                end;
            }
            tableelement("Sales_Invoice_Header"; "Sales Invoice Header")
            {
                textelement("Cust_Code")
                {
                }

                textelement("Prod_Code")
                {
                }

                textelement("Qty")
                {
                }

                textelement("Val")
                {
                }

                textelement("Cst")
                {
                }

                textelement("Del_Date")
                {
                }

                textelement("Rep_Code")
                {
                }

                textelement("Terr_Man")
                {
                }

                textelement("Price_Type")
                {
                }

                textelement("Supp_Dep")
                {
                }

                textelement("Ord_No")
                {
                }

                textelement("Op_Code")
                {
                }

                textelement("Ord_Type")
                {
                }

                textelement("Round")
                {
                }

                textelement("Pack_Price")
                {
                }

                textelement("Prod_Group")
                {
                }

                textelement("Margin")
                {
                }

                textelement("Period")
                {
                }

                textelement("Supp_Code")
                {
                }

                textelement("Weight")
                {
                }

                textelement("Ord_Date")
                {
                }

                textelement("FOC_Ind")
                {
                }

                textelement("Vehicle_Reg")
                {
                }

                textelement("Inv_Cred")
                {
                }

                textelement("Cred_Reason")
                {
                }

                textelement("Drop_Seq")
                {
                }

                textelement("Comb_Disc")
                {
                }

                textelement("Del_Code")
                {
                }

                textelement("Lost_Pick")
                {
                }

                textelement("Lost_Desp")
                {
                }

                textelement("Pick_Conf_Code")
                {
                }

                textelement("Order_Time")
                {
                }

                textelement("Company")
                {
                }

                textelement("Picker_Code")
                {
                }

                textelement("Line_Type")
                {
                }

                textelement("Volume")
                {
                }

                textelement("Inv_Date")
                {
                }

                textelement("Cust_Ord_No")
                {
                }

                textelement("Inv_No")
                {
                }

                textelement("Promise_Date")
                {
                }

                textelement("Account_Year")
                {
                }

                textelement("Account_Month")
                {
                }

                textelement("Sell_by_date")
                {
                }

                textelement("CustProdCode")
                {
                }

                textelement("SalesAd1")
                {
                }

                textelement("SalesAd2")
                {
                }

                textelement("SalesAd3")
                {
                }

                textelement("SalesAd4")
                {
                }

                textelement("SalesAd5")
                {
                }

                textelement("SalesAd6")
                {
                }

                textelement("SalesAnal1")
                {
                }

                textelement("SalesAnal2")
                {
                }

                textelement("SalesAnal3")
                {
                }

                textelement("SalesAnal4")
                {
                }

                textelement("SalesAnal5")
                {
                }

                textelement("SalesAnal6")
                {
                }

                textelement("Job_Number")
                {
                }

                textelement("Master_Ord_No")
                {
                }

                textelement("Purch_Ord_No")
                {
                }

                textelement("Sord_Line_No")
                {
                }

                textelement("Pord_Line_No")
                {
                }

                textelement("ActCst")
                {
                }

                textelement("Sord_Line_Desc")
                {
                }

                textelement("Qty_Ordered")
                {
                }

                textelement("Landed_Cost")
                {
                }

                textelement("FC_Val")
                {
                }

                textelement("Exch_Rate")
                {
                }

                textelement("Foreign_Curr_Code")
                {
                }

                textelement("RM_Cost")
                {
                }

                textelement("Direct_Labour")
                {
                }

                textelement("Direct_OH")
                {
                }

                textelement("Indirect_OH")
                {
                }

                textelement("Finishing_Costs")
                {
                }

                trigger OnAfterGetRecord()
                var
                    Sales_Invoice_Line: Record "Sales Invoice Line";
                    L_Item: Record Item;
                    Sales_Credit_Memo_Line: Record "Sales Cr.Memo Line";
                    Sales_Credit_Memo_Header: Record "Sales Cr.Memo Header";
                    CompInfo: Record "Company Information";

                begin
                    Cust_Code := Sales_Invoice_Header."Sell-to Customer No.";
                    if Sales_Invoice_Line.Get(Sales_Invoice_Line."Document No.", Sales_Invoice_Header."No.") then;
                    Prod_Code := Sales_Invoice_Line."No.";
                    Qty := format(Sales_Invoice_Line.Quantity);
                    Val := format(Sales_Invoice_Line.Amount);
                    Cst := format(Sales_Invoice_Line."Unit Cost (LCY)");
                    Del_Date := format(Sales_Invoice_Header."Shipment Date");
                    Rep_Code := '';
                    Terr_Man := '';
                    Price_Type := '';
                    Supp_Dep := Sales_Invoice_Header."Location Code";
                    Ord_No := Sales_Invoice_Header."Order No.";
                    Op_Code := Sales_Invoice_Header."Salesperson Code";
                    Ord_Type := '';
                    Round := Sales_Invoice_Header."Shipping Agent Code";
                    Pack_Price := '';
                    Prod_Group := Sales_Invoice_Line."Item Category Code";
                    Margin := Format(Sales_Invoice_Line."Unit Price" - Sales_Invoice_Line."Unit Cost");
                    Period := Format(Sales_Invoice_Header."Posting Date", 0, '<Month Text>');
                    Period := CopyStr(Period, 1, 3);
                    if L_Item.Get(Sales_Invoice_Line."No.") then;
                    Supp_Code := L_Item."Vendor No.";
                    Weight := '';
                    Ord_Date := Format(Sales_Invoice_Header."Order Date");
                    FOC_Ind := '';
                    Vehicle_Reg := '';
                    Inv_Cred := '';
                    if Sales_Credit_Memo_Header.Get(Sales_Invoice_Header."No.") then;
                    Sales_Credit_Memo_Line.Reset();
                    Sales_Credit_Memo_Line.SetRange("Document No.", Sales_Credit_Memo_Header."No.");
                    if Sales_Credit_Memo_Line.FindSet() then begin
                        repeat
                            Cred_Reason := Sales_Credit_Memo_Line."Return Reason Code";
                        until Sales_Credit_Memo_Line.Next() = 0;
                    end;
                    Drop_Seq := '';
                    Comb_Disc := '';
                    Del_Code := Sales_Invoice_Header."Ship-to Code";
                    Lost_Pick := '';
                    Lost_Desp := '';
                    Pick_Conf_Code := '';
                    Order_Time := '';
                    CompInfo.Get();
                    Company := CompInfo.Name;
                    Picker_Code := '';
                    Line_Type := '';
                    Volume := '';
                    Inv_Date := format(Sales_Invoice_Header."Document Date");
                    Cust_Ord_No := Sales_Invoice_Header."External Document No.";
                    Inv_No := Sales_Invoice_Header."No.";
                    Promise_Date := '';
                    Account_Year := '';
                    Account_Month := '';
                    Sell_by_date := '';
                    CustProdCode := Sales_Invoice_Line."Item Reference No.";
                    SalesAd1 := '';
                    SalesAd2 := '';
                    SalesAd3 := '';
                    SalesAd4 := '';
                    SalesAd5 := '';
                    SalesAd6 := '';
                    SalesAnal1 := '';
                    SalesAnal2 := '';
                    SalesAnal3 := '';
                    SalesAnal4 := '';
                    SalesAnal5 := '';
                    SalesAnal6 := '';
                    Job_Number := '';
                    Master_Ord_No := '';
                    Purch_Ord_No := '';
                    Sord_Line_No := '';
                    Pord_Line_No := '';
                    ActCst := '';
                    Sord_Line_Desc := Sales_Invoice_Line.Description;
                    Qty_Ordered := Format(Sales_Invoice_Line.Quantity);
                    Landed_Cost := Format(Sales_Invoice_Line."Unit Cost (LCY)");
                    FC_Val := '';
                    Exch_Rate := Format(Sales_Invoice_Header."Currency Factor");
                    Foreign_Curr_Code := Format(Sales_Invoice_Header."Currency Code");
                    RM_Cost := '';
                    Direct_Labour := '';
                    Direct_OH := '';
                    Indirect_OH := '';
                    Finishing_Costs := '';


                end;
            }
        }
    }
}