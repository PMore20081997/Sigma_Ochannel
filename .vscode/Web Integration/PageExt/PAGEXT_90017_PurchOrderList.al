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
            action(ExportPOviaXMLport1)
            {
                Caption = 'Export PO via XMLport';
                Promoted = true;
                Visible = false;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio10, false, false);
                end;
            }
            action(ExportItemviaXMLport2)
            {
                Caption = 'Export Item via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio24, false, false);
                end;
            }
            action(ExportCustviaXMLport3)
            {
                Caption = 'Export Customer via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio01, false, false);
                end;
            }
            action(ExportCurrviaXMLport4)
            {
                Caption = 'Export Currency via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cc, false, false);
                end;
            }
            action(ExportConviaXMLport5)
            {
                Caption = 'Export Contract Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06con, false, false);
                end;
            }
            action(ExportCrviaXMLport6)
            {
                Caption = 'Export Cred Reason via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cr, false, false);
                end;
            }
            action(ExportCuviaXMLport7)
            {
                Caption = 'Export cust group via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cu, false, false);
                end;
            }
            action(ExportdpviaXMLport8)
            {
                Caption = 'Export Depot Detail via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06dp, false, false);
                end;
            }
            action(ExportpgviaXMLport9)
            {
                Caption = 'Export Product group via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06pg, false, false);
                end;
            }
            action(ExportprpviaXMLport10)
            {
                Caption = 'Export Rep Code Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06rp, false, false);
                end;
            }
            action(ExportmpviaXMLport11)
            {
                Caption = 'Export Territory manager Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06tm, false, false);
                end;
            }
            action(ExportvtviaXMLport12)
            {
                Caption = 'Export VAT Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06vt, false, false);
                end;
            }
            action(ExportmcviaXMLport13)
            {
                Caption = 'Export Market Code Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06mc, false, false);
                end;
            }
            action(ExportcompanyviaXMLport14)
            {
                Caption = 'Export company Details via XMLport';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio0617, false, false);
                end;
            }
            action(Test15)
            {
                Caption = 'Test15';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio82, false, false);
                end;
            }
            action(Test151)
            {
                Caption = 'Test151';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio86, false, false);
                end;
            }
            action(Test16)
            {
                Caption = 'Test16';
                Promoted = true;
                Visible = false;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio03, false, false);
                end;
            }
            action(Test17)
            {
                Caption = 'Test17';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06cl, false, false);
                end;
            }
            action(Test18)
            {
                Caption = 'Test18';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06oc, false, false);
                end;
            }
            action(Test19)
            {
                Caption = 'Test19';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06rd, false, false);
                end;
            }
            action(Test20)
            {
                Caption = 'Test20';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06su, false, false);
                end;
            }
            action(Test21)
            {
                Caption = 'Test21';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio47, false, false);
                end;
            }
            action(Test22)
            {
                Caption = 'Test22';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio09, false, false);
                end;
            }
            action(Test23)
            {
                Caption = 'Test23';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"Contract Price Lists", false, false);
                end;
            }
            action(Test24)
            {
                Caption = 'Test24';
                Promoted = true;
                PromotedCategory = Process;
                Image = Export;
                Visible = false;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"productsc File", false, false);
                end;
            }

            action(Test28)
            {
                Caption = 'Test28';
                Promoted = true;
                Visible = false;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"sigusage File", false, false);
                end;
            }
            action(Test29)
            {
                Caption = 'Test29';
                Promoted = true;
                Visible = false;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::mio06ct, false, false);
                end;
            }
            action(Test30)
            {
                Caption = 'Test30';
                Promoted = true;
                Visible = false;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"Product variant", false, false);
                end;
            }
            action(Test31)
            {
                Caption = 'Test31';
                Promoted = true;
                /// Visible = false;
                PromotedCategory = Process;
                Image = Export;
                ApplicationArea = All;
                trigger OnAction()
                var
                    CreateCsv: Codeunit "Datawarehouse-WebDezign";
                begin
                    CreateCsv.CreateGRN();
                end;
            }

        }
    }

    var
        myInt: Integer;
}