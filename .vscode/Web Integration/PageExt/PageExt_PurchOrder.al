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
        addafter("Co&mments")
        {
            action(ExportPOviaXMLport)
            {
                Caption = 'Export PO via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio10, false, false);
                end;
            }
            action(ExportItemviaXMLport)
            {
                Caption = 'Export Item via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio24, false, false);
                end;
            }
            action(ExportCustviaXMLport)
            {
                Caption = 'Export Customer via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio01, false, false);
                end;
            }
        }
    }

    var
        myInt: Integer;
}