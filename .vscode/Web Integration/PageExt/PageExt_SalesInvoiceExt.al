pageextension 90010 SalesInvoiceExt extends "Sales Invoice"
{
    layout
    {

    }

    actions
    {
        addafter("&Invoice")
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
                    JobQueueEntry."Parameter String" := 'EDI;EDICustomer';
                    JobQueueEntry.Insert();
                    EDIInvoiceCOD.Run(JobQueueEntry);
                end;
            }
        }
    }

    var
        myInt: Integer;
}