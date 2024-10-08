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


            tableelement(TempILE; TempILE)
            {

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
                    L_ILE.SetRange(L_ILE."Item No.", TempILE."Item No.");
                    L_ILE.SetRange(L_ILE."Entry Type", L_ILE."Entry Type"::Purchase);
                    if L_ILE.FindLast() then begin
                        LG_Date := FormatDateForCSV(L_ILE."Posting Date");
                        //LG_Date := format(L_ILE."Posting Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                        LG_Number := format(L_ILE."Document No.");
                    end;
                    L_ILE.Reset();
                    L_ILE.SetRange(L_ILE."Item No.", TempILE."Item No.");
                    L_ILE.SetRange(L_ILE."Entry Type", L_ILE."Entry Type"::Sale);
                    if L_ILE.FindLast() then begin
                        LS_Date := FormatDateForCSV(L_ILE."Posting Date");
                        // LS_Date := format(L_ILE."Posting Date", 0, '<Day,2>/<Month,2>/<Year,4>');
                    end;
                    DepotCode := TempILE."Depot Code";
                    if L_item.Get(TempILE."Item No.") then;
                    L_item.CalcFields("Qty. on Sales Order", "Qty. on Purch. Order", "Qty. on Web Order");
                    if TempILE."Variant Code" = '' then begin
                        Prod_Code := TempILE."Item No.";
                        // Alloc_Stock := Format(L_item."Qty. on Sales Order" + L_item."Qty. on Web Order");
                        // On_Order := format(L_item."Qty. on Purch. Order");
                        // Backorder := format(L_item."Qty. on Sales Order");

                    end else begin
                        Prod_Code := TempILE."Variant Code";
                        // Alloc_Stock := Format(QtyOnSOrder(TempILE) + L_item."Qty. on Web Order");
                        // On_Order := format(QtyOnPOrder(TempILE));
                        // Backorder := format(QtyOnSOrder(TempILE));

                    end;
                    Alloc_Stock := Format(L_item."Qty. on Sales Order" + L_item."Qty. on Web Order");
                    On_Order := format(L_item."Qty. on Purch. Order");
                    Backorder := format(L_item."Qty. on Sales Order");
                    Phys_Stock := format(TempILE."ILE Qty.");
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
        TempILE: Record TempILE;
    begin
        TempILE.Reset();
        IF TempILE.FINDLAST THEN
            exit(TempILE."Entry No." + 1)
        ELSE
            exit(1);
    end;

    trigger OnPreXmlPort()
    var
        TempILE: Record TempILE;
        ILE: Record "Item Ledger Entry";
        ILE2: Record "Item Ledger Entry";
    begin
        TempILE.DeleteAll();
        ILE.Reset();
        if ILE.FindSet() then begin
            repeat
                TempILE.Reset();
                TempILE.SetRange("Item No.", ILE."Item No.");
                TempILE.SetRange("Variant Code", ILE."Variant Code");
                TempILE.SetRange("Depot Code", ILE."Location Code");
                if not TempILE.FindFirst() then begin
                    TempILE.Init();
                    TempILE."Entry No." := getlastentryno();
                    TempILE."Item No." := ILE."Item No.";
                    TempILE."Variant Code" := ILE."Variant Code";
                    TempILE."Depot Code" := ILE."Location Code";
                    ILE2.Reset();
                    ILE2.SetRange("Item No.", ILE."Item No.");
                    ILE2.SetRange("Variant Code", ILE."Variant Code");
                    ILE2.SetRange("Location Code", ILE."Location Code");
                    if ILE2.FindSet() then begin
                        repeat
                            TempILE."ILE Qty." += ILE2.Quantity;
                        until ILE2.Next() = 0;

                    end;

                    TempILE.Insert()
                end;
            until ILE.Next() = 0;
        end;
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

    local procedure QtyOnSOrder(var TempIle: Record TempILE): Decimal
    var
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
    begin
        Clear(QtyOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", TempIle."Item No.");
        L_SalesLine.SetRange("Variant Code", TempIle."Variant Code");
        //L_SalesLine.SETRANGE("Saleable Location", true);
        L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
        // L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;

        if QtyOnSO > 0 then
            exit(QtyOnSO)
        else
            exit(0);
    end;

    local procedure QtyOnPOrder(var TempIle: Record TempILE): Decimal
    var
        L_PurchaseLine: Record "Purchase Line";
        QtyOnPO: Decimal;
    begin
        Clear(QtyOnPO);
        L_PurchaseLine.Reset();
        L_PurchaseLine.SetRange("Document Type", L_PurchaseLine."Document Type"::Order);
        L_PurchaseLine.SetRange(Type, L_PurchaseLine.Type::Item);
        L_PurchaseLine.SETRANGE("No.", TempIle."Item No.");
        L_PurchaseLine.SetRange("Variant Code", TempIle."Variant Code");
        //L_SalesLine.SETRANGE("Saleable Location", true);
        L_PurchaseLine.SetFilter("Outstanding Quantity", '>%1', 0);
        // L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_PurchaseLine.FindSet() then begin
            L_PurchaseLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnPO := L_PurchaseLine."Outstanding Qty. (Base)";
        end;

        if QtyOnPO > 0 then
            exit(QtyOnPO)
        else
            exit(0);
    end;


}
