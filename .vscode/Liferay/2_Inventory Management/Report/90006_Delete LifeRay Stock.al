report 90006 "Delete LifeRay Stock"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("LifeRay Stock"; "LifeRay Stock")
        {
            trigger OnPreDataItem()
            begin
                DeleteExpiredRecords();
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(RetentionPeriodField; RetentionPeriod)
                    {
                        ApplicationArea = All;
                        Caption = 'Retention Period';
                        ToolTip = 'Enter retention period as negative value (e.g., -1D for 1 day, -7D for 7 days)';

                        trigger OnValidate()
                        begin
                            ValidateRetentionPeriodDateFormula(RetentionPeriod);
                        end;
                    }
                    field(ChannelCode; ChannelCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Channel Code';
                    }
                }
            }
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            L_DateFilter: DateFormula;
        begin
            Clear(L_DateFilter);
            if CloseAction = CloseAction::OK then begin
                if RetentionPeriod = L_DateFilter then
                    Error('Retention Period should not be blank');

                if ChannelCode = '' then
                    Error('Channel Code should not be blank');
            end;
        end;

    }

    var
        RetentionPeriod: DateFormula;
        ChannelCode: Code[2000];
        FutureDateCalcErr: Label 'The date formula (%1) must result in a date that is at least two days before the current date. For example, to calculate a period for the past week, month, or year, use either -1W, -1M, or -1Y.', Comment = '%1 = a date formula';


    procedure ValidateRetentionPeriodDateFormula(DateFormula: DateFormula)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if Format(DateFormula) <> '' then
            if IsFutureDateFormula(DateFormula) then
                RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(FutureDateCalcErr, DateFormula));
    end;

    local procedure IsFutureDateFormula(DateFormula: DateFormula): Boolean
    begin
        exit(CalcDate(DateFormula, Today()) >= Yesterday());
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Period");
    end;

    local procedure Yesterday(): Date
    begin
        exit(CalcDate('<-1D>', Today()))
    end;

    procedure DeleteExpiredRecords()
    var
        LiferayStock: Record "LifeRay Stock";
        CutoffDate: Date;
    begin
        CutoffDate := CalcDate(RetentionPeriod, WorkDate());

        LiferayStock.Reset();
        LiferayStock.SetFilter("Created On", '<=%1', CutoffDate);
        LiferayStock.SetFilter("Channel Code", ChannelCode);
        if LiferayStock.FindSet() then begin
            if GuiAllowed = true then begin
                if Confirm('Delete %1 records older than %2?', false, LiferayStock.Count(), CutoffDate) then
                    LiferayStock.DeleteAll();
            end else
                LiferayStock.DeleteAll();
        end else begin
            if GuiAllowed = true then
                Error('No records found to delete.');
        end;
    end;
}