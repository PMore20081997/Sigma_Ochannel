// xmlport 90000 "mio10"
// {

//     Format = VariableText;
//     Direction = Export;
//     TextEncoding = UTF8;
//     UseRequestPage = false;
//     FileName = 'mio10.csv';
//     TableSeparator = '<NewLine>';
//     schema
//     {
//         textelement(Root)
//         {
//             tableelement(Integer; Integer)
//             {

//                 SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
//                 textelement("Supp_Code")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Supp_Code" := 'Supp Code';
//                     end;
//                 }
//                 textelement("Prod_Code")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Prod_Code" := 'Prod Code';
//                     end;
//                 }
//                 textelement("PurchOrdNo")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "PurchOrdNo" := 'Purch Ord No';
//                     end;
//                 }
//                 // textelement("DepotCode")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "DepotCode" := 'Depot Code';
//                 //     end;
//                 // }
//                 textelement("PordQty")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "PordQty" := 'Pord Qty';
//                     end;
//                 }
//                 textelement("Pord_Qty_OS")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Pord_Qty_OS" := 'Pord Qty OS';
//                     end;
//                 }

//                 textelement("Qty_Desc")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Qty_Desc" := 'Qty Desc';
//                     end;
//                 }

//                 textelement("Pord_Value")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Pord_Value" := 'Pord Value';
//                     end;
//                 }
//                 //  textelement("Price_Desc")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Price_Desc" := 'Price Desc';
//                 //     end;
//                 // }
//                 textelement("Pord_List")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Pord_List" := 'Pord List';
//                     end;
//                 }
//                 textelement("Pord_Price")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Pord_Price" := 'Pord Price';
//                     end;
//                 }
//                 //  textelement("Receipt_No")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Receipt_No" := 'Receipt No';
//                 //     end;
//                 // }
//                 textelement("OrderDate")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "OrderDate" := 'Order Date';
//                     end;
//                 }
//                 textelement("DueDate")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "DueDate" := 'Due Date';
//                     end;
//                 }
//                 textelement("Orig_Due_Date")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Orig_Due_Date" := 'Orig Due Date';
//                     end;
//                 }
//                 // textelement("Period")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Period" := 'Period';
//                 //     end;
//                 // }
//                 // textelement("Days_Late")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Days_Late" := 'Days Late';
//                 //     end;
//                 // }

//                 // textelement("Late_Qty")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Late_Qty" := 'Late Qty';
//                 //     end;
//                 // }
//                 textelement("Company")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Company" := 'Company';
//                     end;
//                 }
//                 //  textelement("Trans_Anal_6")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Trans_Anal_6" := 'Trans Anal 6';
//                 //     end;
//                 // }
//                 // textelement("Account_Year")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Account_Year" := 'Trans Anal 6';
//                 //     end;
//                 // }
//                 // textelement("Account_Month")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Account_Month" := 'Account Month';
//                 //     end;
//                 // }
//                 // textelement("Sell_By_Date")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Sell_By_Date" := 'Sell By Date';
//                 //     end;
//                 // }

//                 textelement("Cost_in_Currency")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Cost_in_Currency" := 'Cost in Currency';
//                     end;
//                 }
//                 //  textelement("Weight")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Weight" := 'Weight';
//                 //     end;
//                 // }
//                 //  textelement("Pord_Type")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Pord_Type" := 'Pord Type';
//                 //     end;
//                 // }
//                 //  textelement("State_Code")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "State_Code" := 'State Code';
//                 //     end;
//                 // }
//                 //  textelement("Master_Ord_No")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Master_Ord_No" := 'Master Ord No';
//                 //     end;
//                 // }
//                 //  textelement("Sales_Ord_No")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Sales_Ord_No" := 'Sales Ord No';
//                 //     end;
//                 // }
//                 //  textelement("Sord_Line_No")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Sord_Line_No" := 'Sord Line No';
//                 //     end;
//                 // }
//                 textelement("Pord_Line_No")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Pord_Line_No" := 'Pord Line No';
//                     end;
//                 }
//                 //  textelement("Pord_Line_Desc")
//                 // {

//                 //     trigger OnBeforePassVariable()
//                 //     begin
//                 //         "Pord_Line_Desc" := 'Pord_Line_Desc';
//                 //     end;
//                 // }
//                 textelement("Exch_Rate")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Exch_Rate" := 'Exch Rate';
//                     end;
//                 }
//                 textelement("Foreign_Curr_Code")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "Foreign_Curr_Code" := 'Foreign Curr Code';
//                     end;
//                 }
//                 textelement("PO_Operator_Code")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "PO_Operator_Code" := 'PO Operator Code';
//                     end;
//                 }
//                 textelement("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
//                 {

//                     trigger OnBeforePassVariable()
//                     begin
//                         "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
//                     end;
//                 }







//             }
//             tableelement("Purchase_Header"; "Purchase Header")
//             {
//                 //XmlName = 'Item';
//                 RequestFilterFields = "No.";

//                 tableelement("Purchase_Line"; "Purchase Line")
//                 {
//                     LinkTable = Purchase_Header;
//                     LinkFields = "Document No." = field("No.");

//                     tableelement(Item; Item)
//                     {
//                         LinkTable = Purchase_Line;
//                         LinkFields = "No." = field("No.");

//                         tableelement("Company_Information"; "Company Information")
//                         {
//                             fieldelement(Supp_Code; Purchase_Header."Buy-from Vendor No.")
//                             {
//                             }
//                             fieldelement(Prod_Code; Purchase_Line."No.")
//                             {

//                             }
//                             fieldelement(PurchOrdNo; Purchase_Header."No.")
//                             {

//                             }
//                             //  fieldelement()
//                             // {

//                             // }

//                             fieldelement(PordQty; Purchase_Line.Quantity)
//                             {

//                             }
//                             fieldelement("Pord_Qty_OS"; Purchase_Line."Outstanding Quantity")
//                             {

//                             }
//                             fieldelement(Qty_Desc; Purchase_Line."Unit of Measure")
//                             {

//                             }
//                             fieldelement(Pord_Value; Purchase_Line."Outstanding Amount")
//                             {

//                             }
//                             // fieldelement(Price_Desc; Purchase_Line.)
//                             // {

//                             // }
//                             fieldelement(Pord_List; Item."Unit List Price")
//                             {

//                             }
//                             fieldelement(Pord_Price; Purchase_Line."Direct Unit Cost")
//                             {

//                             }
//                             //  fieldelement(Receipt_No; )
//                             // {

//                             // }
//                             fieldelement(OrderDate; Purchase_Header."Order Date")
//                             {

//                             }
//                             fieldelement(DueDate; Purchase_Header."Due Date")
//                             {

//                             }
//                             fieldelement(Orig_Due_Date; Purchase_Header."Due Date")
//                             {


//                             }
//                             // fieldelement(Period; Purchase_Header."Due Date")
//                             // {

//                             // }
//                             // fieldelement(Days_Late; )
//                             // {

//                             // }
//                             // fieldelement(Late_Qty; )
//                             // {

//                             // }
//                             fieldelement(Company; Company_Information.Name)
//                             {
//                                 // trigger OnBeforePassField()
//                                 // begin
//                                 //     CompanyInfo.Get();
//                                 // end;
//                             }
//                             // fieldelement(Trans_Anal_6; )
//                             // {

//                             // }
//                             // fieldelement(Account_Year; )
//                             // {

//                             // }
//                             // fieldelement(Account_Month; )
//                             // {

//                             // }
//                             // fieldelement(Sell_By_Date; )
//                             // {

//                             // }
//                             fieldelement(Cost_in_Currency; Purchase_Line."Unit Cost (LCY)")
//                             {


//                             }
//                             // fieldelement(Weight; )
//                             // {


//                             // }

//                             // fieldelement(Pord_Type; )
//                             // {


//                             // }

//                             // fieldelement(State_Code; )
//                             // {


//                             // }

//                             // fieldelement(Master_Ord_No; )
//                             // {


//                             // }

//                             // fieldelement(Sales_Ord_No; )
//                             // {


//                             // }

//                             // fieldelement(Sord_Line_No; )
//                             // {


//                             // }
//                             fieldelement(Pord_Line_No; Purchase_Line."Line No.")
//                             {


//                             }
//                             //  fieldelement(Pord_Line_Desc; )
//                             // {


//                             // }
//                             //  fieldelement(Exch_Rate; )
//                             // {


//                             // }
//                             //  fieldelement(Foreign_Curr_Code; )
//                             // {


//                             // }
//                             //  fieldelement(PO_Operator_Code; )
//                             // {


//                             // }











//                         }

//                     }



//                 }

//             }

//         }

//     }
//     var
//         CompanyInfo: Record "Company Information";
// }
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
    FileName = 'mio10.csv';

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

                begin

                    L_PurchHeader.Get(Purchase_Line."Document Type", Purchase_Line."Document No.");
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
                    OrderDate := Format(L_PurchHeader."Order Date");
                    //OrderDate := format(L_PurchHeader."Order Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    //end;
                    DueDate := Format(L_PurchHeader."Expected Receipt Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    Orig_Due_Date := Format(L_PurchHeader."Due Date", 0, '<Day,2>/<Month,2>/<Year,4>');
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

                end;

            }

        }
    }
}