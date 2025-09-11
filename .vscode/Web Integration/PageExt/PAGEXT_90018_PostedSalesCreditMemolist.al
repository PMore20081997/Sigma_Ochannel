pageextension 90018 SalesCreditMemolist extends "Posted Sales Credit Memos"
{
    layout
    {

    }

    actions
    {
        addafter("&Print")
        {
            action("Download EDI File")
            {
                ApplicationArea = All;
                Image = Download;
                PromotedCategory = Process;
                Promoted = true;

                trigger OnAction()
                var
                    EDIInvoiceCOD: Codeunit "EDI File Integration";
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                    SalesCrHeader: Record "Sales Cr.Memo Header";
                    Customer: Record Customer;
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;
                begin
                    Clear(SalesCrHeader);
                    CurrPage.SetSelectionFilter(SalesCrHeader);
                    if SalesCrHeader.FindSet() then begin
                        Windows.OPEN('Syncing Orders..' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                        NoOfRecs := SalesCrHeader.Count;
                        repeat
                            ProgressCount += 1;
                            if NoOfRecs > 0 then begin
                                if NoOfRecs <= 100 then begin
                                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                end else begin
                                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                    END;
                                end;
                            end;

                            //Run Process++
                            Clear(Customer);
                            Customer.Reset();
                            if Customer.get(SalesCrHeader."Sell-to Customer No.") then begin
                                if Customer."EDI Invoice/Credit" = true then begin
                                    EDIInvoiceCOD.ProcessEDIFile2(SalesCrHeader, Customer, true);
                                end else begin
                                    if SalesCrHeader.Count = 1 then
                                        Error('The Customer %1 is not EDI Customer. Document No. %2', Customer."No.", SalesCrHeader."No.");
                                end;
                            end;
                        until SalesCrHeader.Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}