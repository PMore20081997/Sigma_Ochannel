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
                    EDIInvoiceCOD: Codeunit "EDI Invoice";
                    JobQueueEntry: Record "Job Queue Entry" temporary;
                    purchHeader: Record "Purchase Header";
                    vendor: Record Vendor;
                begin
                    Clear(purchHeader);
                    purchHeader := Rec;
                    CurrPage.SetSelectionFilter(purchHeader);

                    if purchHeader.FindSet() then begin
                        repeat
                            Clear(vendor);
                            vendor.Reset();
                            if vendor.get(purchHeader."Buy-from Vendor No.") then
                                EDIInvoiceCOD.ProcessEDIFile1(purchHeader, vendor);
                        until purchHeader.Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}