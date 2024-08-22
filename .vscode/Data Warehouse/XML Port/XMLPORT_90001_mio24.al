xmlport 90001 "mio24"
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
    FileName = 'mio24.csv';

    schema
    {

        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement("Prod_Code_Header")
                {
                }

                textelement("DepotCode_Header")
                {
                }

                textelement("Phys_Stock_Header")
                {
                }

                textelement("Alloc_Stock_Header")
                {
                }

                textelement("Alloc_After_Header")
                {
                }

                textelement("On_Order_Header")
                {
                }

                textelement("Backorder_Header")
                {
                }

                textelement("LG_Date_Header")
                {
                }

                textelement("LG_Number_Header")
                {
                }

                textelement("Company_Header")
                {
                }

                textelement("Pick_Bin_Header")
                {
                }

                textelement("LPP_Cost_Header")
                {
                }

                textelement("Avg_Cost_Header")
                {
                }

                textelement("True_Cost_Header")
                {
                }

                textelement("Min_Stock_Header")
                {
                }

                textelement("LS_Date_Header")
                {
                }

                textelement("Std_Cost_Header")
                {
                }

                textelement("Max_Stock_Header")
                {
                }

                textelement("Average_usage_Header")
                {
                }

                textelement("Average_usage_UOM_Header")
                {
                }

                textelement("Average_usage_period_Header")
                {
                }

                textelement("File_Date_Header")
                {
                }

                textelement("Stock_Holding_Date_Header")
                {
                }
                textelement("Temp_Stop_on_Sales_Header")
                {
                }
                textelement("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                {

                }

                trigger OnAfterGetRecord()
                var


                begin
                    "Prod_Code_Header" := 'Prod Code';

                    "DepotCode_Header" := 'Depot Code';

                    "Phys_Stock_Header" := 'Phys Stock';

                    "Alloc_Stock_Header" := 'Alloc Stock';

                    "Alloc_After_Header" := 'Alloc After';

                    "On_Order_Header" := 'On Order';

                    "Backorder_Header" := 'Backorder';

                    "LG_Date_Header" := 'LG-Date';

                    "LG_Number_Header" := 'LG-Number';

                    "Company_Header" := 'Company';

                    "Pick_Bin_Header" := 'Pick Bin';

                    "LPP_Cost_Header" := 'LPP Cost';

                    "Avg_Cost_Header" := 'Avg Cost';

                    "True_Cost_Header" := 'True Cost';

                    "Min_Stock_Header" := 'Min Stock';

                    "LS_Date_Header" := 'LS-Date';

                    "Std_Cost_Header" := 'Std Cost';

                    "Max_Stock_Header" := 'Max Stock';

                    "Average_usage_Header" := 'Average usage';

                    "Average_usage_UOM_Header" := 'Average usage UOM';

                    "Average_usage_period_Header" := 'Average usage period';

                    "File_Date_Header" := 'File Date';

                    Stock_Holding_Date_Header := 'Stock Holding Date';

                    Temp_Stop_on_Sales_Header := 'Temp Stop on Sales';

                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

                end;

            }


            tableelement("Item_Ledger_Entry"; "Item Ledger Entry")
            {
                //CalcFields = "Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order", Inventory;
                //SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

                textelement("Prod_Code")
                {


                }
                textelement("DepotCode")
                {


                }
                textelement("Phys_Stock")
                {


                }
                textelement("Alloc_Stock")
                {


                }
                textelement("Alloc_After")
                {


                }

                textelement("On_Order")
                {


                }

                textelement("Backorder")
                {


                }
                textelement("LG_Date")
                {


                }
                textelement("LG_Number")
                {


                }
                textelement("Company")
                {


                }
                textelement("Pick_Bin")
                {


                }
                textelement("LPP_Cost")
                {


                }
                textelement("Avg_Cost")
                {


                }
                textelement("True_Cost")
                {


                }
                textelement("Min_Stock")
                {


                }
                textelement("LS_Date")
                {


                }

                textelement("Std_Cost")
                {


                }
                textelement("Max_Stock")
                {


                }
                textelement("Average_usage")
                {


                }
                textelement("Average_usage_UOM")
                {


                }
                textelement("Average_usage_period")
                {


                }
                textelement("File_Date")
                {


                }
                textelement("Stock_Holding_Date")
                {
                }
                textelement("Temp_Stop_on_Sales")
                {
                }




                trigger OnAfterGetRecord()

                var
                    //L_PurchHeader: Record "Purchase Header";
                    L_Item: record "Item";
                    companyInfo: Record "Company Information";

                begin
                    // if Check = true then
                    //     updateheadercaption();
                    if Item_Ledger_Entry."Variant Code" = '' then begin
                        Prod_Code := Item_Ledger_Entry."Item No.";
                    end else
                        Prod_Code := Item_Ledger_Entry."Variant Code";

                    LG_Date := format(Item_Ledger_Entry."Posting Date");
                    LG_Number := format(Item_Ledger_Entry."Document No.");
                    LS_Date := format(Item_Ledger_Entry."Posting Date");
                    DepotCode := Item_Ledger_Entry."Location Code";
                    L_Item.Reset();
                    L_Item.SetRange("No.", Item_Ledger_Entry."Item No.");
                    if L_Item.FindFirst() then begin
                        L_Item.CalcFields("Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order", Inventory);

                        Phys_Stock := format(L_Item.Inventory);
                        Alloc_Stock := Format(L_Item."Qty. on Sales Order" + L_Item."Qty. on Web Order");
                        Alloc_After := '';
                        On_Order := format(L_Item."Qty. on Purch. Order");
                        Backorder := format(L_Item."Qty. on Sales Order");
                        Pick_Bin := '';
                        LPP_Cost := format(L_Item."Last Direct Cost");
                        Avg_Cost := format(L_Item."Unit Cost");
                        True_Cost := '';
                        Min_Stock := format(L_Item."Reorder Point");
                        Std_Cost := '0';
                        Max_Stock := format(L_Item."Maximum Inventory");
                        Average_usage := '';
                        Average_usage_UOM := '';
                        Average_usage_period := '';
                        File_Date := '';
                        Stock_Holding_Date := '';
                        Temp_Stop_on_Sales := Format(L_Item."Sales Blocked");
                    end;
                    companyInfo.Get();
                    Company := companyInfo.Name;


                    //Check := false;
                end;
            }

        }
    }
    // procedure updateheadercaption()
    // begin
    //     Supp_Code := 'Supp Code';
    // end;

    // trigger OnPreXmlPort()
    // var

    // begin
    //     //Check := true;
    //     // updateheadercaption();

    // end;

    // var
    //     Check: Boolean;
}
