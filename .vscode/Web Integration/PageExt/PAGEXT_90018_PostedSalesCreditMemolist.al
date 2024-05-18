pageextension 90018 SalesCreditMemolist extends "Posted Sales Credit Memos"
{
    layout
    {

    }

    actions
    {
        addafter("&Print")
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
                    SalesCrHeader: Record "Sales Cr.Memo Header";
                    Customer: Record Customer;
                begin
                    Clear(SalesCrHeader);
                    SalesCrHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesCrHeader);

                    if SalesCrHeader.FindSet() then begin
                        repeat
                            Clear(Customer);
                            Customer.Reset();
                            if Customer.get(SalesCrHeader."Sell-to Customer No.") then
                                EDIInvoiceCOD.ProcessEDIFile2(SalesCrHeader, Customer);
                        until SalesCrHeader.Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}