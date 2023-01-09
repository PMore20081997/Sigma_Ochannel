/*page 90029 "O-Channel Business Chart"
{
    PageType = CardPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Ochannel Graph";

    layout
    {
        area(Content)
        {
            group("")
            {
                usercontrol(Pictue; Picture)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                usercontrol("OchannelUserControl"; "Microsoft.Dynamics.Nav.Client.BusinessChart")
                {
                    ApplicationArea = All;


                    trigger AddInReady()
                    begin
                        if Rec.Get(UserId) then
                            UpdateChart(Rec, Rec."Period Lenth");
                        // IsChartAddInReady := true;
                        // if IsChartDataReady then
                        //     UpdateChart(Rec, Rec."Period Lenth");
                    end;

                    trigger Refresh()
                    begin
                        if Rec.Get(UserId) then
                            UpdateChart(Rec, Rec."Period Lenth");
                        // if IsChartAddInReady and IsChartDataReady then begin
                        //     UpdateChart(Rec, Rec."Period Lenth");
                        // end;
                    end;
                }
            }
        }
    }


    actions
    {
        area(Processing)
        {
            group("Period Lenth")
            {
                action(Day)
                {
                    ApplicationArea = All;
                    image = Filter;
                    trigger OnAction()
                    begin
                        Rec."Period Lenth" := Rec."Period Lenth"::Day;
                        UpdateChart(Rec, Rec."Period Lenth");
                    end;
                }
                action(Week)
                {
                    ApplicationArea = All;
                    image = Filter;
                    trigger OnAction()
                    begin
                        Rec."Period Lenth" := Rec."Period Lenth"::Week;
                        UpdateChart(Rec, Rec."Period Lenth");
                    end;
                }
                action(Month)
                {
                    ApplicationArea = All;
                    image = Filter;
                    trigger OnAction()
                    begin
                        Rec."Period Lenth" := Rec."Period Lenth"::Month;
                        UpdateChart(Rec, Rec."Period Lenth");
                    end;
                }
                action(Quarter)
                {
                    image = Filter;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Rec."Period Lenth" := Rec."Period Lenth"::Quarter;
                        UpdateChart(Rec, Rec."Period Lenth");

                    end;
                }
                action(Year)
                {
                    image = Filter;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Rec."Period Lenth" := Rec."Period Lenth"::Year;
                        // Rec.Modify();
                        UpdateChart(Rec, Rec."Period Lenth");
                    end;
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        // SetActionEnabled();

        if not Rec.Get(UserId) then begin
            Rec.LockTable();
            Rec."User ID" := UserId;
            Rec."Use Work Date As Base" := true;
            Rec."Period Lenth" := Rec."Period Lenth"::Week;
            Rec.Insert();
        end
        else begin
            Rec."Period Lenth" := Rec."Period Lenth"::Week;
            Rec.Modify();
        end;

    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        // UpdateChart(Rec, Rec."Period Lenth");
        // IsChartDataReady := true;

        // if not IsChartDataReady then
        //     SetActionEnabled();
    end;

    var
        "Status Text": Text;
        IsChartDataReady: Boolean;

        IsChartAddInReady: Boolean;
        DayEnabled: Boolean;
        WeekEnabled: Boolean;
        MonthEnabled: Boolean;
        QuarterEnabled: Boolean;
        YearEnabled: Boolean;
        TempBusinessChartBuffer: Record "Business Chart Buffer" temporary;

        PerioLenth: Text;
        CurrentDate: Date;
        tst: Page "Trailing Sales Orders Chart";


    // local procedure SetActionEnabled()
    // begin
    //     DayEnabled := (Rec."Period Lenth" <> Rec."Period Lenth"::Day) and IsChartAddInReady;
    //     WeekEnabled := (Rec."Period Lenth" <> Rec."Period Lenth"::Day) and IsChartAddInReady;
    //     MonthEnabled := (Rec."Period Lenth" <> Rec."Period Lenth"::Day) and IsChartAddInReady;
    //     QuarterEnabled := (Rec."Period Lenth" <> Rec."Period Lenth"::Day) and IsChartAddInReady;
    //     YearEnabled := (Rec."Period Lenth" <> Rec."Period Lenth"::Day) and IsChartAddInReady;
    // end;

    local procedure UpdateChart(var ChartGraph: Record "Ochannel Graph"; PeriodLenth: Option)
    var
        ColumnNO: Integer;
        Calender: Record Date;
        InterimSalesHeader: Record "Interim Sales Header";
        C1: Integer;
        D1: Date;
        D2: Date;
        Inprogress: Integer;
        Processing: Integer;
        Confirmed: Integer;

    begin

        if PeriodLenth = ChartGraph."Period Lenth"::Day then begin
            D1 := Today;
            D2 := Today;
        end;
        if PeriodLenth = ChartGraph."Period Lenth"::Week then begin
            D1 := CalcDate('CW', Today);
            D2 := CalcDate('-CW', Today);
        end;
        if PeriodLenth = ChartGraph."Period Lenth"::Month then begin
            D1 := CalcDate('CM', Today);
            D2 := CalcDate('-CM', Today);
        end;
        if PeriodLenth = ChartGraph."Period Lenth"::Quarter then begin
            D1 := CalcDate('CQ', Today);
            D2 := CalcDate('-CQ', Today);
        end;
        if PeriodLenth = ChartGraph."Period Lenth"::Year then begin
            D1 := CalcDate('CY', Today);
            D2 := CalcDate('-CY', Today);
        end;


        Rec.Get(UserId);

        TempBusinessChartBuffer.Initialize();

        TempBusinessChartBuffer.AddDecimalMeasure('Period', 1, TempBusinessChartBuffer."Chart Type"::StackedColumn);
        // TempBusinessChartBuffer.AddDecimalMeasure('K1', 1, TempBusinessChartBuffer."Chart Type"::StackedColumn);
        // TempBusinessChartBuffer.AddDecimalMeasure('W1', 1, TempBusinessChartBuffer."Chart Type"::StackedColumn);
        TempBusinessChartBuffer.AddDecimalMeasure('In Progress', 1, TempBusinessChartBuffer."Chart Type"::Column);
        TempBusinessChartBuffer.AddDecimalMeasure('Processing', 1, TempBusinessChartBuffer."Chart Type"::Column);
        TempBusinessChartBuffer.AddDecimalMeasure('Confirmed', 1, TempBusinessChartBuffer."Chart Type"::Column);


        TempBusinessChartBuffer.SetXAxis('Status', TempBusinessChartBuffer."Data Type"::String);

        ColumnNO := 0;

        Calender.Reset();
        Calender.SetRange("Period Type", PeriodLenth);
        Calender.SetRange("Period Start", D2, D1);
        if Calender.FindFirst() then begin
            repeat
                // TempBusinessChartBuffer.AddColumn('(' + Format(Calender."Period Start") + '..' + Format(Calender."Period End") + ')');
                TempBusinessChartBuffer.AddColumn('' + Format(Calender."Period Type") + ' (' + Format(Calender."Period Start") + ' To ' + Format(Calender."Period End") + ')');
                InterimSalesHeader.Reset();
                InterimSalesHeader.SetRange("Order Date", Calender."Period Start", Calender."Period End");
                C1 := InterimSalesHeader.Count;
                TempBusinessChartBuffer.SetValue('Period', ColumnNO, C1);


                TempBusinessChartBuffer.AddColumn('In Progress');
                TempBusinessChartBuffer.SetValue('In Progress', 1, GetStatusCount('In Progress', Calender."Period Start", Calender."Period End"));
                TempBusinessChartBuffer.AddColumn('Processing');
                TempBusinessChartBuffer.SetValue('Processing', 2, GetStatusCount('Processing', Calender."Period Start", Calender."Period End"));
                TempBusinessChartBuffer.AddColumn('Confirmed');
                TempBusinessChartBuffer.SetValue('Confirmed', 3, GetStatusCount('Confirmed', Calender."Period Start", Calender."Period End"));
                TempBusinessChartBuffer.Update(CurrPage.OchannelUserControl);
                ColumnNO += 1;
                if ColumnNO = 5 then
                    exit;
            until Calender.Next() = -0;
        end;
    end;

    local procedure GetStatusCount(P_Status: Text; P_StartDate: date; P_endDate: Date): Integer
    var
        InterimSalesHeader: Record "Interim Sales Header";
    begin
        InterimSalesHeader.Reset();
        InterimSalesHeader.SetFilter(status, P_Status);
        InterimSalesHeader.SetRange("Order Date", P_StartDate, P_endDate);
        if InterimSalesHeader.FindSet() then;
        exit(InterimSalesHeader.Count);
    end;

}*/
enum 90029 "Interim Document Status"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; Confirmed) { Caption = 'Confirmed'; }
    value(1; "In Progress") { Caption = 'In Progress'; }
    value(2; "Processing") { Caption = 'Processing'; }
}