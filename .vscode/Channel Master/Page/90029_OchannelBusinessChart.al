page 90029 "O-Channel Business Chart"
{
    Caption = 'O-Channel Business Chart';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            usercontrol(Pictue; Picture)
            {
                ApplicationArea = All;
                Visible = false;
            }
            field(StatusText; StatusText)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Status Text';
                Editable = false;
                ShowCaption = false;
                ToolTip = 'Specifies the status of the chart.';
            }
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = Basic, Suite;



                trigger AddInReady()
                begin
                    IsChartAddInReady := true;
                    TrailingSalesOrdersMgt.OnOpenPage(TrailingSalesOrdersSetup);
                    UpdateStatus;
                    if IsChartDataReady then
                        UpdateChart;
                end;

                trigger Refresh()
                begin
                    if IsChartAddInReady and IsChartDataReady then begin
                        NeedsUpdate := true;
                        UpdateChart
                    end;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Show)
            {
                Caption = 'Show';
                Image = View;
            }
            group(PeriodLength)
            {
                Caption = 'Period Length';
                Image = Period;
                action(Day)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Day';
                    Enabled = DayEnabled;
                    ToolTip = 'Each stack covers one day.';

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Day);
                        UpdateStatus;
                    end;
                }
                action(Week)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Week';
                    Enabled = WeekEnabled;
                    ToolTip = 'Each stack except for the last stack covers one week. The last stack contains data from the start of the week until the date that is defined by the Show option.';

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Week);
                        UpdateStatus;
                    end;
                }
                action(Month)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Month';
                    Enabled = MonthEnabled;
                    ToolTip = 'Each stack except for the last stack covers one month. The last stack contains data from the start of the month until the date that is defined by the Show option.';

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Month);
                        UpdateStatus;
                    end;
                }
                action(Quarter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quarter';
                    Enabled = QuarterEnabled;
                    ToolTip = 'Each stack except for the last stack covers one quarter. The last stack contains data from the start of the quarter until the date that is defined by the Show option.';

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Quarter);
                        UpdateStatus;
                    end;
                }
                action(Year)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Year';
                    Enabled = YearEnabled;
                    ToolTip = 'Each stack except for the last stack covers one year. The last stack contains data from the start of the year until the date that is defined by the Show option.';

                    trigger OnAction()
                    begin
                        TrailingSalesOrdersSetup.SetPeriodLength(TrailingSalesOrdersSetup."Period Length"::Year);
                        UpdateStatus;
                    end;
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateChart;
        IsChartDataReady := true;

        if not IsChartAddInReady then
            SetActionsEnabled;
    end;

    trigger OnOpenPage()
    begin
        SetActionsEnabled;
    end;

    var
        TrailingSalesOrdersSetup: Record "Trailing Sales Orders Setup";
        OldTrailingSalesOrdersSetup: Record "Trailing Sales Orders Setup";
        TrailingSalesOrdersMgt: Codeunit "Trailing Sales Orders Mgt.";
        StatusText: Text[250];
        NeedsUpdate: Boolean;

        [InDataSet]
        DayEnabled: Boolean;
        [InDataSet]
        WeekEnabled: Boolean;
        [InDataSet]
        MonthEnabled: Boolean;
        [InDataSet]
        QuarterEnabled: Boolean;
        [InDataSet]
        YearEnabled: Boolean;
        IsChartAddInReady: Boolean;
        IsChartDataReady: Boolean;
        InterimWebHeader: Record "Interim Sales Header";

    local procedure UpdateChart()
    begin
        if not NeedsUpdate then
            exit;
        if not IsChartAddInReady then
            exit;
        UpdateData(Rec);
        Rec.Update(CurrPage.BusinessChart);
        UpdateStatus;
        NeedsUpdate := false;
    end;

    local procedure UpdateStatus()
    begin
        NeedsUpdate :=
          NeedsUpdate or
          (OldTrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length") or
          (OldTrailingSalesOrdersSetup."Show Orders" <> TrailingSalesOrdersSetup."Show Orders") or
          (OldTrailingSalesOrdersSetup."Use Work Date as Base" <> TrailingSalesOrdersSetup."Use Work Date as Base") or
          (OldTrailingSalesOrdersSetup."Value to Calculate" <> TrailingSalesOrdersSetup."Value to Calculate") or
          (OldTrailingSalesOrdersSetup."Chart Type" <> TrailingSalesOrdersSetup."Chart Type");

        OldTrailingSalesOrdersSetup := TrailingSalesOrdersSetup;

        if NeedsUpdate then
            StatusText := TrailingSalesOrdersSetup.GetCurrentSelectionText;

        SetActionsEnabled;
    end;



    procedure SetActionsEnabled()
    begin

        DayEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Day) and
          IsChartAddInReady;
        WeekEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Week) and
          IsChartAddInReady;
        MonthEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Month) and
          IsChartAddInReady;
        QuarterEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Quarter) and
          IsChartAddInReady;
        YearEnabled := (TrailingSalesOrdersSetup."Period Length" <> TrailingSalesOrdersSetup."Period Length"::Year) and
          IsChartAddInReady;
    end;

    procedure UpdateData(var BusChartBuf: Record "Business Chart Buffer")
    var
        ChartToStatusMap: array[3] of Integer;
        ToDate: array[5] of Date;
        FromDate: array[5] of Date;
        Value: Decimal;
        TotalValue: Decimal;
        ColumnNo: Integer;
        SalesHeaderStatus: Integer;
    begin
        TrailingSalesOrdersSetup.Get(UserId);
        TrailingSalesOrdersSetup."Value to Calculate" := TrailingSalesOrdersSetup."Value to Calculate"::"No. of Orders";
        with BusChartBuf do begin
            Initialize();
            "Period Length" := TrailingSalesOrdersSetup."Period Length";
            SetPeriodXAxis;

            CreateMap(ChartToStatusMap);
            for SalesHeaderStatus := 1 to ArrayLen(ChartToStatusMap) do begin
                InterimWebHeader.Status := "Interim Document Status".FromInteger(ChartToStatusMap[SalesHeaderStatus]);
                AddDecimalMeasure(Format(InterimWebHeader.Status), InterimWebHeader.Status, "Chart Type"::Column);
            end;

            if CalcPeriods(FromDate, ToDate, BusChartBuf) then begin
                AddPeriods(ToDate[1], ToDate[ArrayLen(ToDate)]);

                for SalesHeaderStatus := 1 to ArrayLen(ChartToStatusMap) do begin
                    TotalValue := 0;
                    for ColumnNo := 1 to ArrayLen(ToDate) do begin
                        Value := GetOrderValue("Interim Document Status".FromInteger(ChartToStatusMap[SalesHeaderStatus]), FromDate[ColumnNo], ToDate[ColumnNo]);
                        if ColumnNo = 1 then
                            TotalValue := Value
                        else
                            TotalValue += Value;
                        SetValueByIndex(SalesHeaderStatus - 1, ColumnNo - 1, TotalValue);
                    end;
                end;
            end;
        end;
    end;

    local procedure CalcPeriods(var FromDate: array[5] of Date; var ToDate: array[5] of Date; var BusChartBuf: Record "Business Chart Buffer"): Boolean
    var
        MaxPeriodNo: Integer;
        i: Integer;
    begin
        MaxPeriodNo := ArrayLen(ToDate);
        ToDate[MaxPeriodNo] := Today;
        if ToDate[MaxPeriodNo] = 0D then
            exit(false);
        for i := MaxPeriodNo downto 1 do begin
            if i > 1 then begin
                FromDate[i] := BusChartBuf.CalcFromDate(ToDate[i]);
                ToDate[i - 1] := FromDate[i] - 1;
            end else
                FromDate[i] := 0D
        end;
        exit(true);
    end;

    procedure CreateMap(var Map: array[3] of Integer)
    var
        InterimHeader: Record "Interim Sales Header";
    begin
        // Map[1] := InterimHeader.Status::Confirmed;
        // Map[2] := InterimHeader.Status::"In Progress";
        // Map[3] := InterimHeader.Status::Processing;
        Map[1] := InterimHeader.Status::Processing;
        Map[2] := InterimHeader.Status::"In Progress";
        Map[3] := InterimHeader.Status::Confirmed;
    end;

    local procedure GetOrderValue(Status: Option; FromDate: Date; ToDate: Date): Decimal
    begin
        if TrailingSalesOrdersSetup."Value to Calculate" = TrailingSalesOrdersSetup."Value to Calculate"::"No. of Orders" then
            exit(GetOrderCount(Status, FromDate, ToDate));
    end;

    local procedure GetOrderCount(Status: Option; FromDate: Date; ToDate: Date): Decimal
    begin
        InterimWebHeader.SetRange("Document Type", InterimWebHeader."Document Type"::Order);
        InterimWebHeader.SetRange(Status, Status);
        // InterimWebHeader.SetRange("Document Date", ToDate);
        InterimWebHeader.SetFilter("Document Date", '%1..%2', FromDate, ToDate);
        exit(InterimWebHeader.Count);
    end;
}

