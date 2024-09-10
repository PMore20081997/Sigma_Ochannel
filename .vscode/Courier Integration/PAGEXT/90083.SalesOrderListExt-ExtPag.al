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

            action("Update Variant, KNAPP Check & Release")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    UdateVariantonSO: Codeunit "Udate Variant on SO";
                    L_SalesLine: Record "Sales Line";
                    NoSeriesManagement: Codeunit "No. Series";
                    Rec_SalesLine: Record "Sales Line";
                    CU_ReleaseSalesDoc: Codeunit "Release Sales Document";
                begin
                    Clear(L_SalesHeader);
                    L_SalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_SalesHeader);

                    L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
                    L_SalesHeader.SetRange("Web Order", false);
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            UdateVariantonSO.UpdateVariantOnSalesOrder(L_SalesHeader);
                            Commit();

                            L_SalesHeader.CalcFields(Shipped, "Drop/Special Order");
                            if (L_SalesHeader."Knapp Order" = false) and (L_SalesHeader."Drop/Special Order" = false) and (L_SalesHeader.Shipped = false) then begin
                                L_SalesLine.Reset();
                                L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                                L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                                L_SalesLine.SetRange("Knapp Line", false);
                                if not L_SalesLine.FindFirst() then begin
                                    L_SalesHeader."Knapp Order" := true;
                                    if L_SalesHeader."Posting No." = '' then
                                        L_SalesHeader.Validate("Posting No.", NoSeriesManagement.GetNextNo(L_SalesHeader."Posting No. Series", WorkDate()));
                                    L_SalesHeader.Modify(true);

                                    Rec_SalesLine.Reset();
                                    Rec_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                                    Rec_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                                    Rec_SalesLine.SetRange(Type, Rec_SalesLine.Type::Item);
                                    Rec_SalesLine.SetRange("Knapp Line", true);
                                    if Rec_SalesLine.FindSet() then begin
                                        Rec_SalesLine.ModifyAll("Qty. to Ship", 0);
                                    end;
                                    Commit();
                                end;
                            end;

                            CU_ReleaseSalesDoc.PerformManualRelease(L_SalesHeader);
                            Commit();
                        until L_SalesHeader.Next() = 0;
                    end;

                    Message('Process Completed');
                end;
            }

            action("EDI File")
            {
                ApplicationArea = All;
                Image = Journal;
                PromotedCategory = Process;
                Promoted = true;
                Visible = false;

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