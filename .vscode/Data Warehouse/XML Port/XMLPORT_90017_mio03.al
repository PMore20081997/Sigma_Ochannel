xmlport 90017 "mio03"
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
    FileName = 'mio03.csv';

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

                textelement("Prod_Desc_Header")
                {
                }

                textelement("Prod_Group_Header")
                {
                }

                textelement("Prod_Type_Header")
                {
                }

                textelement("AC_1_Header")
                {
                }

                textelement("AC_2_Header")
                {
                }

                textelement("AC_3_Header")
                {
                }

                textelement("Pref_Supp_Header")
                {
                }

                textelement("Vat_Code_Header")
                {
                }

                textelement("AC_4_Header")
                {
                }

                textelement("AC_5_Header")
                {
                }

                textelement("AC_6_Header")
                {
                }

                textelement("Discon_Header")
                {
                }

                textelement("Bako_DS_Scheme_Header")
                {
                }

                textelement("Sedes_Pip_Code_Header")
                {
                }

                textelement("Sedes_AAH_Code_Header")
                {
                }

                textelement("Dept_Code_Header")
                {
                }

                textelement("Temperature_Header")
                {
                }

                textelement("List_Price_Header")
                {
                }

                textelement("List_Curr_Header")
                {
                }

                textelement("Supp_Prod_Header")
                {
                }

                textelement("Pack_Size_Header")
                {
                }

                textelement("Desc_Pack_Header")
                {
                }

                textelement("Spec_Disc_Header")
                {
                }

                textelement("Case_Weight_Header")
                {
                }

                textelement("Case_Volume_Header")
                {
                }

                textelement("Bin_Loc_Header")
                {
                }

                textelement("Own_Brand_Header")
                {
                }

                textelement("Cust_Brand_Header")
                {
                }

                textelement("Sub_Group_1_Header")
                {
                }

                textelement("Sub_Group_2_Header")
                {
                }

                textelement("Sub_Group_3_Header")
                {
                }

                textelement("Sub_Group_4_Header")
                {
                }

                textelement("Sub_Group_5_Header")
                {
                }

                textelement("Sub_Group_6_Header")
                {
                }

                textelement("Additional_1_Header")
                {
                }

                textelement("Additional_2_Header")
                {
                }

                textelement("Additional_3_Header")
                {
                }

                textelement("Additional_4_Header")
                {
                }

                textelement("Additional_5_Header")
                {
                }

                textelement("Additional_6_Header")
                {
                }

                textelement("Last_Purchase_Cost_Header")
                {
                }

                textelement("Standard_Cost_Header")
                {
                }

                textelement("Case_Description_Header")
                {
                }

                textelement("Minimum_Shelf_Life_Header")
                {
                }

                textelement("Measured_Header")
                {
                }

                textelement("Full_Pal_Qty_Header")
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

                textelement("Unit_Weight_Header")
                {
                }

                textelement("Company_Header")
                {
                }

                textelement("Zero_Discount_Header")
                {
                }
                textelement("Operational_Stop_Header")
                {
                }
                textelement("Temp_Stop_on_Sales_Header")
                {
                }
                textelement("Commodity_Code_Header")
                {
                }
                textelement("Average_Cost_Header")
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Prod_Code_Header := 'Prod Code';
                    Prod_Desc_Header := 'Prod Desc';
                    Prod_Group_Header := 'Prod Group';
                    Prod_Type_Header := 'Prod Type';
                    AC_1_Header := 'AC 1';
                    AC_2_Header := 'AC 2';
                    AC_3_Header := 'AC 3';
                    Pref_Supp_Header := 'Pref Supp';
                    Vat_Code_Header := 'Vat Code';
                    AC_4_Header := 'AC 4';
                    AC_5_Header := 'AC 5';
                    AC_6_Header := 'AC 6';
                    Discon_Header := 'Discon';
                    Bako_DS_Scheme_Header := 'Bako DS Scheme';
                    Sedes_Pip_Code_Header := 'Sedes Pip Code';
                    Sedes_AAH_Code_Header := 'Sedes AAH Code';
                    Dept_Code_Header := 'Dept Code';
                    Temperature_Header := 'Temperature';
                    List_Price_Header := 'List Price';
                    List_Curr_Header := 'List Curr';
                    Supp_Prod_Header := 'Supp Prod';
                    Pack_Size_Header := 'Pack Size';
                    Desc_Pack_Header := 'Desc Pack';
                    Spec_Disc_Header := 'Spec Disc';
                    Case_Weight_Header := 'Case Weight';
                    Case_Volume_Header := 'Case Volume';
                    Bin_Loc_Header := 'Bin Loc';
                    Own_Brand_Header := 'Own Brand';
                    Cust_Brand_Header := 'Cust Brand';
                    Sub_Group_1_Header := 'Sub Group 1';
                    Sub_Group_2_Header := 'Sub Group 2';
                    Sub_Group_3_Header := 'Sub Group 3';
                    Sub_Group_4_Header := 'Sub Group 4';
                    Sub_Group_5_Header := 'Sub Group 5';
                    Sub_Group_6_Header := 'Sub Group 6';
                    Additional_1_Header := 'Additional 1';
                    Additional_2_Header := 'Additional 2';
                    Additional_3_Header := 'Additional 3';
                    Additional_4_Header := 'Additional 4';
                    Additional_5_Header := 'Additional 5';
                    Additional_6_Header := 'Additional 6';
                    Last_Purchase_Cost_Header := 'Last Purchase Cost';
                    Standard_Cost_Header := 'Standard Cost';
                    Case_Description_Header := 'Case Description';
                    Minimum_Shelf_Life_Header := 'Minimum Shelf Life';
                    Measured_Header := 'Measured';
                    Full_Pal_Qty_Header := 'Full Pal Qty';
                    Average_usage_Header := 'Average usage';
                    Average_usage_UOM_Header := 'Average usage UOM';
                    Average_usage_period_Header := 'Average usage period';
                    Unit_Weight_Header := 'Unit Weight';
                    Company_Header := 'Company';
                    Zero_Discount_Header := 'Zero Discount';
                    Operational_Stop_Header := 'Operational Stop';
                    Temp_Stop_on_Sales_Header := 'Temp Stop on Sale';
                    Commodity_Code_Header := 'Commodity Code';
                    "Average_Cost_Header" := 'Average Cost';
                end;
            }
            tableelement(Item; Item)
            {
                CalcFields = "Parent Category";

                textelement("Prod_Code")
                {
                }

                textelement("Prod_Desc")
                {
                }

                textelement("Prod_Group")
                {
                }

                textelement("Prod_Type")
                {
                }

                textelement("AC_1")
                {
                }

                textelement("AC_2")
                {
                }

                textelement("AC_3")
                {
                }

                textelement("Pref_Supp")
                {
                }

                textelement("Vat_Code")
                {
                }

                textelement("AC_4")
                {
                }

                textelement("AC_5")
                {
                }

                textelement("AC_6")
                {
                }

                textelement("Discon")
                {
                }

                textelement("Bako_DS_Scheme")
                {
                }

                textelement("Sedes_Pip_Code")
                {
                }

                textelement("Sedes_AAH_Code")
                {
                }

                textelement("Dept_Code")
                {
                }

                textelement("Temperature")
                {
                }

                textelement("List_Price")
                {
                }

                textelement("List_Curr")
                {
                }

                textelement("Supp_Prod")
                {
                }

                textelement("Pack_Size")
                {
                }

                textelement("Desc_Pack")
                {
                }

                textelement("Spec_Disc")
                {
                }

                textelement("Case_Weight")
                {
                }

                textelement("Case_Volume")
                {
                }

                textelement("Bin_Loc")
                {
                }

                textelement("Own_Brand")
                {
                }

                textelement("Cust_Brand")
                {
                }

                textelement("Sub_Group_1")
                {
                }

                textelement("Sub_Group_2")
                {
                }

                textelement("Sub_Group_3")
                {
                }

                textelement("Sub_Group_4")
                {
                }

                textelement("Sub_Group_5")
                {
                }

                textelement("Sub_Group_6")
                {
                }

                textelement("Additional_1")
                {
                }

                textelement("Additional_2")
                {
                }

                textelement("Additional_3")
                {
                }

                textelement("Additional_4")
                {
                }

                textelement("Additional_5")
                {
                }

                textelement("Additional_6")
                {
                }

                textelement("Last_Purchase_Cost")
                {
                }

                textelement("Standard_Cost")
                {
                }

                textelement("Case_Description")
                {
                }

                textelement("Minimum_Shelf_Life")
                {
                }

                textelement("Measured")
                {
                }

                textelement("Full_Pal_Qty")
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

                textelement("Unit_Weight")
                {
                }

                textelement("Company")
                {
                }

                textelement("Zero_Discount")
                {
                }
                textelement("Operational_Stop")
                {
                }
                textelement("Temp_Stop_on_Sales")
                {
                }
                textelement("Commodity_Code")
                {
                }
                textelement("Average_Cost")
                {
                }


                trigger OnAfterGetRecord()
                var
                    compInfo: Record "Company Information";
                    itemRef: Record "Item Reference";
                    binContent: Record "Bin Content";
                    tempRange: Record "Temperature Range";

                begin

                    Prod_Code := Item."No.";
                    Prod_Desc := Item.Description;
                    Prod_Group := Item."Item Category Code";
                    Prod_Type := '';
                    AC_1 := item."Parent Category";
                    AC_2 := '';
                    AC_3 := format(Item."Top Category");
                    Pref_Supp := Item."Vendor No.";
                    Vat_Code := Item."VAT Prod. Posting Group";
                    AC_4 := Item."No. 2";
                    AC_5 := '';
                    AC_6 := '';
                    if Item.Blocked = true then begin
                        Discon := 'Discontinued';
                    end else
                        Discon := 'Live';
                    Bako_DS_Scheme := '';
                    itemRef.Reset();
                    itemRef.SetRange("Item No.", Item."No.");
                    itemRef.SetRange("Reference Type", itemRef."Reference Type"::"PIP Code");
                    if itemRef.FindFirst() then begin
                        Sedes_Pip_Code := itemRef."Reference No.";
                    end;

                    Sedes_AAH_Code := '';
                    Dept_Code := '';
                    tempRange.Reset();
                    tempRange.SetRange(Code, Item.Storage);
                    if tempRange.FindFirst() then begin
                        Temperature := tempRange.Description;
                    end;

                    List_Price := Format(Item."Last Direct Cost");
                    List_Curr := '';
                    Supp_Prod := Item."Vendor Item No.";
                    Pack_Size := Item."Pack Size";
                    Desc_Pack := Item.Description;
                    Spec_Disc := '';
                    Case_Weight := Format(Item."Gross Weight");
                    Case_Volume := '';
                    binContent.Reset();
                    binContent.SetRange("Item No.", Item."No.");
                    binContent.SetFilter(Quantity, '<>%1', 0);
                    if binContent.FindFirst() then begin
                        Bin_Loc := binContent."Bin Code";
                    end;
                    Own_Brand := '';
                    Cust_Brand := '';
                    Sub_Group_1 := '';
                    Sub_Group_2 := '';
                    Sub_Group_3 := '';
                    Sub_Group_4 := '';
                    Sub_Group_5 := '';
                    Sub_Group_6 := '';
                    Additional_1 := '';
                    Additional_2 := '';
                    Additional_3 := '';
                    Additional_4 := '';
                    Additional_5 := '';
                    Additional_6 := '';
                    Last_Purchase_Cost := Format(Item."Last Direct Cost");
                    Standard_Cost := Format(Item."Standard Cost");
                    Case_Description := item."Base Unit of Measure";
                    Minimum_Shelf_Life := '';
                    Measured := '';
                    Full_Pal_Qty := '';
                    Average_usage := '';
                    Average_usage_UOM := '';
                    Average_usage_period := '';
                    Unit_Weight := Format(Item."Net Weight");
                    compInfo.Get();
                    Company := compInfo.Name;
                    Zero_Discount := '';
                    if item."Sales Blocked" = true then begin
                        Operational_Stop := 'Y';
                        Temp_Stop_on_Sales := 'Y';
                    end
                    else begin
                        Operational_Stop := 'N';
                        Temp_Stop_on_Sales := 'N';
                    end;
                    Commodity_Code := '';
                    Average_Cost := Format(Item."Unit Cost");
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
}