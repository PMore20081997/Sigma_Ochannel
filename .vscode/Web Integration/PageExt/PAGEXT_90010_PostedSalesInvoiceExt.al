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
        }
    }

    actions
    {
        addafter(Print)
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
                    SalesinvoiceHeader: Record "Sales Invoice Header";
                    Customer: Record Customer;
                begin
                    Clear(SalesinvoiceHeader);
                    SalesinvoiceHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesinvoiceHeader);

                    if SalesinvoiceHeader.FindSet() then begin
                        repeat
                            Clear(Customer);
                            Customer.Reset();
                            if Customer.get(SalesinvoiceHeader."Sell-to Customer No.") then begin
                                if Customer."EDI Invoice/Credit" = true then begin
                                    EDIInvoiceCOD.ProcessEDIFile(SalesinvoiceHeader, Customer);
                                end else
                                    Error('The Customer %1 is not EDI Customer/Vendor', Customer."No.");
                            end;
                        until SalesinvoiceHeader.Next() = 0;
                    end;
                end;
            }
            action("Sync Job")
            {
                ApplicationArea = All;
                Image = New;

                trigger OnAction()
                var
                    L_SalesInvoiceHeader: Record "Sales Invoice Header";
                    ePODIntegration: Codeunit "POD Father Integration";
                begin
                    Commit();
                    L_SalesInvoiceHeader.Reset();
                    CurrPage.SetSelectionFilter(L_SalesInvoiceHeader);
                    L_SalesInvoiceHeader.SetFilter("ePOD ID", '%1', 0);
                    L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
                    L_SalesInvoiceHeader.Ascending(true);
                    if L_SalesInvoiceHeader.FindSet() then begin
                        repeat
                            ePODIntegration.Job_OnPODFatherPortal(L_SalesInvoiceHeader."No.", 'EPOD')
                        until L_SalesInvoiceHeader.Next() = 0;
                    end;

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
                begin
                    Commit();
                    L_SalesInvoiceHeader.Reset();
                    CurrPage.SetSelectionFilter(L_SalesInvoiceHeader);
                    L_SalesInvoiceHeader.SetCurrentKey("Shipment Date");
                    L_SalesInvoiceHeader.Ascending(true);
                    if L_SalesInvoiceHeader.FindSet() then begin
                        repeat
                            ePODIntegration.GetJobAndUpdateSalesInvoice(L_SalesInvoiceHeader."No.", 'EPOD')
                        until L_SalesInvoiceHeader.Next() = 0;
                    end;

                end;
            }
        }
    }

    var
        myInt: Integer;
}