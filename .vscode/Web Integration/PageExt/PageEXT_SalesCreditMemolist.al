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
                begin
                    JobQueueEntry.DeleteAll();
                    JobQueueEntry.Init();
                    JobQueueEntry."Parameter String" := 'EDI;EDICrMemo';
                    JobQueueEntry.Insert();
                    EDIInvoiceCOD.Run(JobQueueEntry);
                end;
            }
        }
    }

    var
        myInt: Integer;
}