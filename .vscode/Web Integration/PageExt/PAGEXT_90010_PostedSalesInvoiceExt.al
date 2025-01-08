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
                            if Customer.get(SalesinvoiceHeader."Sell-to Customer No.") then
                                EDIInvoiceCOD.ProcessEDIFile(SalesinvoiceHeader, Customer);
                        until SalesinvoiceHeader.Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}