pageextension 90017 PurchOrderExt extends "Purchase Order List"
{
    layout
    {

    }

    actions
    {
        addafter("O&rder")
        {
            action("EDI File")
            {
                ApplicationArea = All;
                Image = Journal;
                PromotedCategory = Process;
                Promoted = true;

                trigger OnAction()
                var
                    EDIInvoiceCOD: Codeunit 90081;
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                begin
                    JobQueueEntry.DeleteAll();
                    JobQueueEntry.Init();
                    JobQueueEntry."Parameter String" := 'EDI;EDISupplier';
                    JobQueueEntry.Insert();
                    EDIInvoiceCOD.Run(JobQueueEntry);
                end;
            }
        }
    }

    var
        myInt: Integer;
}