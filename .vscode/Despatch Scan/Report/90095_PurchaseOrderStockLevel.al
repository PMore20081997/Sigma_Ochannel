report 90095 "PO Stock-Level"
{
    DefaultLayout = RDLC;
    RDLCLayout = './POStockLevel.rdl';

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            column(Logo; CompanyInfo.Picture) { }
            column(TodayFormatted; Format(Today, 0, 4)) { }
            column(Time; Time) { }
            column(ReportCation; ReportCation) { }
            column(No_; "No.") { }
            column(Description; Description) { }
            column(W_H_Inventory; "W/H Inventory") { }
            column(DispatchQty; Abs(DispatchQty)) { }

            trigger OnAfterGetRecord()
            var
                ItemLedgerEntries: Record "Item Ledger Entry";
            begin
                Clear(DispatchQty);
                ItemLedgerEntries.Reset();
                ItemLedgerEntries.SetRange("Entry Type", ItemLedgerEntries."Entry Type"::Sale);
                ItemLedgerEntries.SetRange("Item No.", Item."No.");
                ItemLedgerEntries.SetFilter("Posting Date", 'MONTH');
                if ItemLedgerEntries.FindFirst() then begin
                    repeat
                        DispatchQty += ItemLedgerEntries.Quantity;
                    until ItemLedgerEntries.Next() = 0;
                end

            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    // field(Name; SourceExpression)
                    // {
                    //     ApplicationArea = All;

                    // }
                }
            }
        }
    }


    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        DispatchQty: Decimal;
        CompanyInfo: Record "Company Information";

        ReportCation: Label 'PO Stock-Level';
}