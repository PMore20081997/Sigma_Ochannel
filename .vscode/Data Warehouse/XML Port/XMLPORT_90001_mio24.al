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


            tableelement(Item; Item)
            {
                CalcFields = "Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order", Inventory;
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
                    L_ILE: record "Item Ledger Entry";
                    companyInfo: Record "Company Information";

                begin
                    // if Check = true then
                    //     updateheadercaption();
                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", Item."No.");
                    L_ILE.SetRange(L_ILE."Entry Type", L_ILE."Entry Type"::Purchase);
                    if L_ILE.FindLast() then begin
                        LG_Date := format(L_ILE."Posting Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                        LG_Number := format(L_ILE."Document No.");
                    end;
                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", Item."No.");
                    L_ILE.SetRange(L_ILE."Entry Type", L_ILE."Entry Type"::Sale);
                    if L_ILE.FindLast() then begin
                        LS_Date := format(L_ILE."Posting Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    end;


                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", Item."No.");
                    if L_ILE.FindSet() then begin
                        repeat
                            DepotCode := L_ILE."Location Code";
                        until L_ILE.Next() = 0;
                    end;

                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", Item."No.");
                    if L_ILE.FindFirst() then begin
                        if L_ILE."Variant Code" = '' then begin
                            Prod_Code := L_ILE."Item No.";
                        end else begin
                            Prod_Code := L_ILE."Variant Code";
                        end;
                    end;



                    Phys_Stock := format(item.Inventory);
                    Alloc_Stock := Format(Item."Qty. on Sales Order" + item."Qty. on Web Order");
                    Alloc_After := '';
                    On_Order := format(Item."Qty. on Purch. Order");
                    Backorder := format(Item."Qty. on Sales Order");
                    companyInfo.Get();
                    Company := companyInfo.Name;
                    Pick_Bin := '';
                    LPP_Cost := format(Item."Last Direct Cost");
                    Avg_Cost := format(Item."Unit Cost");
                    True_Cost := format(Item."Unit List Price");
                    Min_Stock := format(Item."Reorder Point");
                    Std_Cost := '0';
                    Max_Stock := format(Item."Maximum Inventory");
                    Average_usage := '';
                    Average_usage_UOM := '';
                    Average_usage_period := '';
                    File_Date := '';
                    Stock_Holding_Date := '';
                    Temp_Stop_on_Sales := Format(item."Sales Blocked");
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
