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
            action(ExportCurrviaXMLport)
            {
                Caption = 'Export Currency via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cc, false, false);
                end;
            }
            action(ExportConviaXMLport)
            {
                Caption = 'Export Contract Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06con, false, false);
                end;
            }
            action(ExportCrviaXMLport)
            {
                Caption = 'Export Cred Reason via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cr, false, false);
                end;
            }
            action(ExportCuviaXMLport)
            {
                Caption = 'Export cust group via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cu, false, false);
                end;
            }
            action(ExportdpviaXMLport)
            {
                Caption = 'Export Depot Detail via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06dp, false, false);
                end;
            }
            action(ExportpgviaXMLport)
            {
                Caption = 'Export Product group via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06pg, false, false);
                end;
            }
            action(ExportprpviaXMLport)
            {
                Caption = 'Export Rep Code Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06rp, false, false);
                end;
            }
            action(ExportmpviaXMLport)
            {
                Caption = 'Export Territory manager Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06tm, false, false);
                end;
            }
            action(ExportvtviaXMLport)
            {
                Caption = 'Export VAT Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06vt, false, false);
                end;
            }
            action(ExportmcviaXMLport)
            {
                Caption = 'Export Market Code Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06mc, false, false);
                end;
            }
            action(ExportcompanyviaXMLport)
            {
                Caption = 'Export company Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio0617, false, false);
                end;
            }





        }
    }

    var
        myInt: Integer;
}