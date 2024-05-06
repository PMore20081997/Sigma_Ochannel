codeunit 90023 "OC CT Function"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure TotalFree(_Rec: Record CustomerTrends) _TotalFree: Decimal
    begin
        _Rec.CalcFields("Total Physical", "Total Allocated on SO", "Web Orders Qty", "Qty On Customer Trends");
        _TotalFree := _Rec."Total Physical" - (_Rec."Total Allocated on SO" + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");
        if _TotalFree > 0 then
            exit(_TotalFree)
        else
            exit(0);
    end;

    procedure Free(_Rec: Record CustomerTrends) _Free: Decimal
    begin
        _Rec.SetFilter("Date Filter", '%1..%2', CalcDate('-1D', WorkDate()), CalcDate('1D', WorkDate()));
        _Rec.CalcFields(Physical, "Allocated on SO", "Web Orders Qty", "Qty On Customer Trends");
        _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");
        if _Free > 0 then
            Exit(_Free)
        else
            exit(0);
    end;


    procedure Onvalidate_Free(_Rec: Record CustomerTrends) _Free: Decimal
    var
        L_CstomerTrend: Record CustomerTrends;
        _CurrentLineQty: Decimal;
    begin
        Clear(_CurrentLineQty);
        L_CstomerTrend.Reset();
        L_CstomerTrend.SetRange("Salesperson Code", _Rec."Salesperson Code");
        L_CstomerTrend.SetRange("Customer No.", _Rec."Customer No.");
        L_CstomerTrend.SetRange("Entry Number", _Rec."Entry Number");
        if L_CstomerTrend.FindFirst() then
            _CurrentLineQty := L_CstomerTrend."Qty. to be added to SO";

        _Rec.SetFilter("Date Filter", '%1..%2', CalcDate('-1D', WorkDate()), CalcDate('1D', WorkDate()));
        _Rec.CalcFields(Physical, "Allocated on SO", "Web Orders Qty", "Qty On Customer Trends");
        _Free := (_Rec.Physical + _CurrentLineQty) - (_Rec."Allocated on SO" + _Rec."Web Orders Qty" + _Rec."Qty On Customer Trends");
        if _Free > 0 then
            Exit(_Free)
        else
            exit(0);
    end;
}