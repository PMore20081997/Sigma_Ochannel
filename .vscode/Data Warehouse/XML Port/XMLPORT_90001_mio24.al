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


            tableelement(TempILE1; TempILE1)
            {
                //SourceTableView = where("Item No." = const('ZYPREX2.5'));
                // CalcFields = "Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order", Inventory;
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
                    L_item: Record Item;
                    L_Variant: Record "Item Variant";

                begin
                    // if Check = true then
                    //     updateheadercaption();
                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", TempILE1."Item No.");
                    L_ILE.SetRange(L_ILE."Entry Type", L_ILE."Entry Type"::Purchase);
                    if L_ILE.FindLast() then begin
                        LG_Date := FormatDateForCSV(L_ILE."Posting Date");
                        //LG_Date := format(L_ILE."Posting Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                        LG_Number := format(L_ILE."Document No.");
                    end;
                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", TempILE1."Item No.");
                    L_ILE.SetRange(L_ILE."Entry Type", L_ILE."Entry Type"::Sale);
                    if L_ILE.FindLast() then begin
                        LS_Date := FormatDateForCSV(L_ILE."Posting Date");
                        // LS_Date := format(L_ILE."Posting Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    end;
                    DepotCode := TempILE1."Depot Code";
                    L_item.Reset();
                    L_item.SetRange("No.", TempILE1."Item No.");
                    if L_item.FindFirst() then begin
                        if TempILE1."Variant Code" = '' then begin
                            L_item.SetRange("Location Filter", TempILE1."Depot Code");
                            L_item.CalcFields("Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order");

                            Prod_Code := TempILE1."Item No.";
                            Alloc_Stock := Format(L_item."Qty. on Sales Order" + L_item."Qty. on Web Order");
                            On_Order := Format(L_item."Qty. on Purch. Order");
                            Backorder := format(L_item."Qty. on Sales Order");
                        end else begin
                            L_item.SetRange("Location Filter", TempILE1."Depot Code");
                            L_item.SetRange("Variant Filter", TempILE1."Variant Code");
                            L_item.CalcFields("Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order");
                            Prod_Code := TempILE1."Variant Code";
                            Alloc_Stock := Format(L_item."Qty. on Sales Order" + L_item."Qty. on Web Order");
                            On_Order := Format(L_item."Qty. on Purch. Order");
                            Backorder := format(L_item."Qty. on Sales Order");
                        end;
                    end;
                    // Alloc_Stock := Format(L_item."Qty. on Sales Order" + L_item."Qty. on Web Order");
                    // On_Order := format(L_item."Qty. on Purch. Order");
                    // Backorder := format(L_item."Qty. on Sales Order");
                    Phys_Stock := format(TempILE1."ILE Qty.");
                    LPP_Cost := format(L_item."Last Direct Cost");
                    Avg_Cost := format(L_item."Unit Cost");
                    True_Cost := format(L_item."Unit List Price");
                    Min_Stock := format(L_item."Reorder Point");
                    Max_Stock := format(L_item."Maximum Inventory");
                    Temp_Stop_on_Sales := Format(L_item."Sales Blocked");

                    companyInfo.Get();
                    Company := companyInfo.Name;
                    Pick_Bin := '';
                    Std_Cost := '0';
                    Average_usage := '';
                    Average_usage_UOM := '';
                    Average_usage_period := '';
                    File_Date := '';
                    Stock_Holding_Date := '';
                    Alloc_After := '';
                end;
            }

        }


    }
    local procedure getlastentryno(): Integer
    var
        TempILE1: Record TempILE1;
    begin
        TempILE1.Reset();
        IF TempILE1.FINDLAST THEN
            exit(TempILE1."Entry No." + 1)
        ELSE
            exit(1);
    end;

    trigger OnPreXmlPort()
    var
        ILE: Record "Item Ledger Entry";
        ILE2: Record "Item Ledger Entry";
        TempILE1: Record TempILE1;
        Q_ILE: Query "ILE Oty";
    begin
        TempILE1.DeleteAll();
        Clear(Q_ILE);
        //  Q_ILE.SetRange(Q_ILE.Item_No_, 'ZYPREX2.5');
        Q_ILE.Open();
        while Q_ILE.Read() do begin

            TempILE1.Init();
            TempILE1."Entry No." := getlastentryno();
            TempILE1."Item No." := Q_ILE.Item_No_;
            TempILE1."Variant Code" := Q_ILE.Variant_Code;
            TempILE1."Depot Code" := Q_ILE.Location_Code;

            TempILE1."ILE Qty." := Q_ILE.Remaining_Quantity;
            TempILE1.Insert();

        end;
        // ILE.Reset();
        // ILE.SetCurrentKey("Item No.", "Variant Code", "Location Code");

        // if ILE.FindSet() then
        //     repeat
        //         TempILE1.Reset();
        //         TempILE1.SetRange("Item No.", ILE."Item No.");
        //         TempILE1.SetRange("Variant Code", ILE."Variant Code");
        //         TempILE1.SetRange("Depot Code", ILE."Location Code");

        //         if not TempILE1.FindFirst() then begin
        //             TempILE1.Init();
        //             TempILE1."Entry No." := getlastentryno();
        //             TempILE1."Item No." := ILE."Item No.";
        //             TempILE1."Variant Code" := ILE."Variant Code";
        //             TempILE1."Depot Code" := ILE."Location Code";

        //             ILE2.Reset();
        //             ILE2.SetRange("Item No.", ILE."Item No.");
        //             ILE2.SetRange("Variant Code", ILE."Variant Code");
        //             ILE2.SetRange("Location Code", ILE."Location Code");
        //             ILE2.CalcSums(Quantity);
        //             TempILE1."ILE Qty." := ILE2.Quantity;

        //             TempILE1.Insert();
        //         end;
        //     until ILE.Next() = 0;
    end;


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

    // local procedure QtyOnSOrder(var TempIle1: Record TempILE1): Decimal
    // var
    //     L_SalesLine: Record "Sales Line";
    //     QtyOnSO: Decimal;
    // begin
    //     Clear(QtyOnSO);
    //     L_SalesLine.Reset();

    //     L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
    //     L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
    //     L_SalesLine.SETRANGE("No.", TempILE1."Item No.");
    //     if TempILE1."Variant Code" <> '' then begin
    //         L_SalesLine.SetRange("Variant Code", TempILE1."Variant Code");
    //     end;
    //     L_SalesLine.SetRange("Location Code", TempILE1."Depot Code");
    //     L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
    //     if L_SalesLine.FindSet() then begin
    //         L_SalesLine.CalcSums("Outstanding Qty. (Base)");
    //         QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
    //     end;

    //     if QtyOnSO > 0 then
    //         exit(QtyOnSO)
    //     else
    //         exit(0);
    // end;

    // local procedure QtyOnPOrder(var TempIle1: Record TempILE1): Decimal
    // var
    //     L_PurchaseLine: Record "Purchase Line";
    //     QtyOnPO: Decimal;
    // begin
    //     Clear(QtyOnPO);
    //     L_PurchaseLine.Reset();
    //     L_PurchaseLine.SetRange("Document Type", L_PurchaseLine."Document Type"::Order);
    //     L_PurchaseLine.SetRange(Type, L_PurchaseLine.Type::Item);
    //     L_PurchaseLine.SETRANGE("No.", TempILE1."Item No.");
    //     if TempILE1."Variant Code" <> '' then begin
    //         L_PurchaseLine.SetRange("Variant Code", TempILE1."Variant Code");
    //     end;
    //     L_PurchaseLine.SetRange("Location Code", TempILE1."Depot Code");
    //     L_PurchaseLine.SetFilter("Outstanding Quantity", '>%1', 0);
    //     if L_PurchaseLine.FindSet() then begin
    //         L_PurchaseLine.CalcSums("Outstanding Qty. (Base)");
    //         QtyOnPO := L_PurchaseLine."Outstanding Qty. (Base)";
    //     end;

    //     if QtyOnPO > 0 then
    //         exit(QtyOnPO)
    //     else
    //         exit(0);
    // end;


}

