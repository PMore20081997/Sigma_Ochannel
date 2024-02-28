pageextension 90018 SalesCreditMemolist extends "Sales Credit Memos"
{
    layout
    {

    }

    actions
    {
        addafter("&Cr. Memo")
        {
            action("EDI File")
            {
                ApplicationArea = All;
                Image = Journal;
                PromotedCategory = Process;
                Promoted = true;

                trigger OnAction()
                var
                    EDIInvoiceCOD: Codeunit "EDI Invoice";
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                    SalesHeader: Record "Sales Header";
                    Customer: Record Customer;
                begin
                    Clear(SalesHeader);
                    SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesHeader);

                    if SalesHeader.FindSet() then begin
                        repeat
                            Clear(Customer);
                            Customer.Reset();
                            if Customer.get(SalesHeader."Sell-to Customer No.") then
                                EDIInvoiceCOD.ProcessEDIFile(SalesHeader, Customer);
                        until SalesHeader.Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}