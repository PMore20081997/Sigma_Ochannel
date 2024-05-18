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

            tableelement(Item; Item)
            {

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


                textelement("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
                {

                    trigger OnBeforePassVariable()
                    begin
                        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    end;
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
                    L_ILE.SetRange("Item No.", Item."No.");
                    if L_ILE.FindLast() then begin
                        LG_Date := format(L_ILE."Posting Date");
                        LG_Number := format(L_ILE."Document No.");
                        LS_Date := format(L_ILE."Posting Date");
                    end;

                    Prod_Code := Item."No.";
                    DepotCode := ''; //location
                    Phys_Stock := format(item.Inventory);
                    Alloc_Stock := '';
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

                    Std_Cost := format(Item."Standard Cost");
                    Max_Stock := format(Item."Maximum Inventory");
                    Average_usage := '';
                    Average_usage_UOM := '';
                    Average_usage_period := '';
                    File_Date := '';

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
