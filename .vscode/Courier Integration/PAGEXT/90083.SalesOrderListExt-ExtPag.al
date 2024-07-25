pageextension 90083 "Sales Order List Ext" extends "Sales Order List"
{
    layout
    {
        addafter(Status)
        {
            field("Web Order"; Rec."Web Order")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter(Release)
        {

            action("Bulk Delete")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                begin
                    Clear(L_SalesHeader);
                    L_SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_SalesHeader);

                    L_SalesHeader.SetRange("Web Order", true);
                    L_SalesHeader.SetRange("Knapp Order", false);
                    L_SalesHeader.SetFilter("Posting No.", '<>%1', '');
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            L_SalesHeader.Delete(true);
                            Commit();
                        until L_SalesHeader.Next() = 0;
                    end;
                end;
            }

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
                    SalesHeader: Record "Sales Header";
                    Customer: Record Customer;
                begin
                    Clear(SalesHeader);
                    SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(SalesHeader);

                    if SalesHeader.FindSet() then begin
                        repeat
                            Clear(Customer);
                            Customer.Reset();
                            if Customer.get(SalesHeader."Sell-to Customer No.") then
                                EDIInvoiceCOD.ProcessEDIFile3(SalesHeader, Customer);
                        until SalesHeader.Next() = 0;
                    end;
                end;
            }
        }
    }
}