xmlport 90030 "sigusage File"
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
    FileName = 'sigusage.csv';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                SourceTableView = SORTING(Number) WHERE(Number = CONST(1));
                textelement("Company_Header")
                {
                }

                textelement("Prod_Code_Header")
                {
                }

                textelement("Depot_Code_Header")
                {
                }

                textelement("Usage_1_Header")
                {
                }

                textelement("Usage_2_Header")
                {
                }

                textelement("Usage_3_Header")
                {
                }

                textelement("Usage_4_Header")
                {
                }

                textelement("Usage_5_Header")
                {
                }

                textelement("Usage_6_Header")
                {
                }

                textelement("Usage_7_Header")
                {
                }

                textelement("Usage_8_Header")
                {
                }

                textelement("Usage_9_Header")
                {
                }

                textelement("Usage_10_Header")
                {
                }

                textelement("Usage_11_Header")
                {
                }

                textelement("Usage_12_Header")
                {
                }

                textelement("Usage_13_Header")
                {
                }

                textelement(XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)
                {
                }

                trigger OnAfterGetRecord()
                var
                    myInt: Integer;
                begin
                    Company_Header := 'Company';
                    Prod_Code_Header := 'Prod Code';
                    Depot_Code_Header := 'Depot Code';
                    Usage_1_Header := 'Usage-1';
                    Usage_2_Header := 'Usage-2';
                    Usage_3_Header := 'Usage-3';
                    Usage_4_Header := 'Usage-4';
                    Usage_5_Header := 'Usage-5';
                    Usage_6_Header := 'Usage-6';
                    Usage_7_Header := 'Usage-7';
                    Usage_8_Header := 'Usage-8';
                    Usage_9_Header := 'Usage-9';
                    Usage_10_Header := 'Usage-10';
                    Usage_11_Header := 'Usage-11';
                    Usage_12_Header := 'Usage-12';
                    Usage_13_Header := 'Usage-13';
                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX := XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;
                end;
            }
            tableelement(Item; Item)
            {
                textelement(Company)
                {
                }

                textelement(Prod_Code)
                {
                }

                textelement(Depot_Code)
                {
                }

                textelement(Usage_1)
                {
                }

                textelement(Usage_2)
                {
                }

                textelement(Usage_3)
                {
                }

                textelement(Usage_4)
                {
                }

                textelement(Usage_5)
                {
                }

                textelement(Usage_6)
                {
                }

                textelement(Usage_7)
                {
                }

                textelement(Usage_8)
                {
                }

                textelement(Usage_9)
                {
                }

                textelement(Usage_10)
                {
                }

                textelement(Usage_11)
                {
                }

                textelement(Usage_12)
                {
                }

                textelement(Usage_13)
                {
                }
                trigger OnAfterGetRecord()
                var
                    L_StartDate: Date;
                    L_EndDate: Date;
                    ILE: Record "Item Ledger Entry";
                    companyInfo: Record "Company Information";

                begin

                    companyInfo.Get();
                    Company := companyInfo.Name;
                    Prod_Code := Item."No.";
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    if ILE.FindFirst() then begin
                        Depot_Code := ILE."Location Code";

                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-1M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-1M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_1 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-2M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-2M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_2 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-3M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-3M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_3 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-4M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-4M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_4 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-5M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-5M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_5 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-6M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-6M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_6 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-7M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-7M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_7 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-8M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-8M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_8 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-9M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-9M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_9 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-10M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-10M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_10 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-11M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-11M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_11 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-12M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-12M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_12 := Format(ILE.Quantity);
                    end;

                    Clear(L_StartDate);
                    Clear(L_EndDate);
                    L_StartDate := CalcDate('-CM', CalcDate('-13M', Today));
                    L_EndDate := CalcDate('CM', CalcDate('-13M', Today));
                    ILE.Reset();
                    ILE.SetRange("Item No.", Item."No.");
                    ILE.SetRange("Entry Type", ILE."Entry Type"::Sale);
                    ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
                    if ILE.FindSet() then begin
                        ILE.CalcSums(Quantity);
                        Usage_13 := Format(ILE.Quantity);
                    end;

                end;
            }

        }
    }
}