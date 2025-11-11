pageextension 90010 PostedSalesInvoiceListExt extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Knapp Customer")
        {
            field("Web Order"; Rec."Web Order")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Customer Synced"; Rec."Customer Synced")
            {
                ApplicationArea = All;
            }
            field("Route Synced"; Rec."Route Synced")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter(Print)
        {
            action("Sync Job")
            {
                ApplicationArea = All;
                Image = New;

                trigger OnAction()
                var
                    L_SalesInvoiceHeader: Record "Sales Invoice Header";
                    ePODIntegration: Codeunit "POD Father Integration";
                    NoOfSelected: Integer;
                    NoOfSkipped: Integer;
                    PrevFilterGroup: Integer;
                    ProcessConfirmWithSkipQst: Label 'You have selected multiple documents for processing. \Some of the documents cannot sync and will be skipped. (Selected %1, Skipping %2)\\Do you want to continue?', Comment = '%1=integer(number of rows selected) %2=integer(number of rows skipped)';
                    ProcessConfirmQst: Text;
                    ProcessConfirmWithoutSkipQst: Label 'You have selected multiple documents for processing. (Selected %1, Skipping 0)\\Do you want to continue?', Comment = '%1=integer(number of rows selected)';
                    ProcessConfirmWithSkipQst1: Label 'You have selected multiple documents for processing. \Some of the documents cannot sync and will be skipped. (Selected %1, Skipping %2)', Comment = '%1=integer(number of rows selected) %2=integer(number of rows skipped)';
                begin
                    // L_SalesInvoiceHeader.Reset();
                    // CurrPage.SetSelectionFilter(L_SalesInvoiceHeader);
                    // L_SalesInvoiceHeader.SetFilter("ePOD ID", '%1', 0);
                    // L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
                    // L_SalesInvoiceHeader.Ascending(true);
                    // NoOfSelected := L_SalesInvoiceHeader.Count;
                    // if NoOfSelected > 1 then begin
                    //     PrevFilterGroup := L_SalesInvoiceHeader.FilterGroup();
                    //     L_SalesInvoiceHeader.FilterGroup(10);
                    //     L_SalesInvoiceHeader.SetRange("Route Synced", true);
                    //     L_SalesInvoiceHeader.SetRange("Customer Synced", true);
                    //     NoOfSkipped := NoOfSelected - L_SalesInvoiceHeader.Count;
                    //     if (NoOfSkipped > 0) or (NoOfSelected > 0) then begin
                    //         if NoOfSkipped > 0 then
                    //             ProcessConfirmQst := StrSubstNo(ProcessConfirmWithSkipQst, NoOfSelected, NoOfSkipped)
                    //         else
                    //             ProcessConfirmQst := StrSubstNo(ProcessConfirmWithoutSkipQst, NoOfSelected);

                    //         if NoOfSelected = NoOfSkipped then begin
                    //             Message(ProcessConfirmWithSkipQst1, NoOfSelected, NoOfSkipped);
                    //             exit;
                    //         end;
                    //         if not Confirm(StrSubstNo(ProcessConfirmQst, NoOfSelected, NoOfSkipped), true) then
                    //             exit;
                    //     end;
                    // end;
                    // if L_SalesInvoiceHeader.FindSet() then begin
                    //     repeat
                    //         ePODIntegration.Job_OnPODFatherPortal(L_SalesInvoiceHeader."No.", 'EPOD')
                    //     until L_SalesInvoiceHeader.Next() = 0;
                    // end;

                    //Run Process++
                    Clear(ePODIntegration);
                    ePODIntegration.OpenRequestPageForePODjobSync();
                end;
            }
            action("Update Job")
            {
                ApplicationArea = All;
                Image = Change;

                trigger OnAction()
                var
                    L_SalesInvoiceHeader: Record "Sales Invoice Header";
                    ePODIntegration: Codeunit "POD Father Integration";
                    L_Error: Text;
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;
                begin
                    Clear(L_Error);
                    Clear(ProgressCount);
                    Clear(NoOfRecs);
                    CurrPage.SetSelectionFilter(L_SalesInvoiceHeader);
                    L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
                    L_SalesInvoiceHeader.SetFilter("ePOD ID", '>%1', 0);
                    L_SalesInvoiceHeader.Ascending(true);
                    if L_SalesInvoiceHeader.FindSet() then begin
                        Windows.OPEN('Updating Orders..' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                        NoOfRecs := L_SalesInvoiceHeader.Count;
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
                            ePODIntegration.GetJobAndUpdateSalesInvoice(L_SalesInvoiceHeader."No.", 'EPOD', L_Error);
                        until L_SalesInvoiceHeader.Next() = 0;

                        if L_Error <> '' then
                            Message('%1', L_Error)
                        else
                            Message('Process Completed');

                    end;

                end;
            }

            group(EDI)
            {
                Caption = 'EDI';
                Image = Export;
                action("Export EDI File To PC")
                {
                    ApplicationArea = All;
                    Image = Download;
                    trigger OnAction()
                    var
                        EDIInvoiceCOD: Codeunit "EDI File Integration";
                        JobQueueEntry: Record "Job Queue Entry" temporary;
                        SalesinvoiceHeader: Record "Sales Invoice Header";
                        Customer: Record Customer;
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                    begin
                        Clear(SalesinvoiceHeader);
                        CurrPage.SetSelectionFilter(SalesinvoiceHeader);
                        if SalesinvoiceHeader.FindSet() then begin
                            Windows.OPEN('Exporting files..' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := SalesinvoiceHeader.Count;
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
                                if Customer.get(SalesinvoiceHeader."Sell-to Customer No.") then begin
                                    if Customer."EDI Invoice/Credit" = true then begin
                                        EDIInvoiceCOD.ProcessEDIFile(SalesinvoiceHeader, Customer, true);
                                    end else begin
                                        if SalesinvoiceHeader.Count = 1 then
                                            Error('The Customer %1 is not EDI Customer. Document No. %2', Customer."No.", SalesinvoiceHeader."No.");
                                    end;
                                end;
                            until SalesinvoiceHeader.Next() = 0;
                        end;
                    end;
                }

                action("Export EDI File To Container")
                {
                    ApplicationArea = All;
                    Image = Download;
                    trigger OnAction()
                    var
                        EDIInvoiceCOD: Codeunit "EDI File Integration";
                        JobQueueEntry: Record "Job Queue Entry" temporary;
                        SalesinvoiceHeader: Record "Sales Invoice Header";
                        Customer: Record Customer;
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                    begin
                        Clear(SalesinvoiceHeader);
                        CurrPage.SetSelectionFilter(SalesinvoiceHeader);
                        SalesinvoiceHeader.SetRange("EDI Synced", false);
                        if SalesinvoiceHeader.FindSet() then begin
                            Windows.OPEN('Exporting files..' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := SalesinvoiceHeader.Count;
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
                                if Customer.get(SalesinvoiceHeader."Sell-to Customer No.") then begin
                                    if Customer."EDI Invoice/Credit" = true then begin
                                        EDIInvoiceCOD.ProcessEDIFile(SalesinvoiceHeader, Customer, false);
                                    end else begin
                                        if SalesinvoiceHeader.Count = 1 then
                                            Error('The Customer %1 is not EDI Customer. Document No. %2', Customer."No.", SalesinvoiceHeader."No.");
                                    end;
                                end;
                            until SalesinvoiceHeader.Next() = 0;
                        end;
                    end;
                }
            }
        }
    }

    var
        myInt: Integer;
}