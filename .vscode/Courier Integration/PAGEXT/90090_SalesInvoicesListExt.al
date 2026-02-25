pageextension 90090 SalesInvoicesListExt extends "Sales Invoice List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Processing)
        {
            action(DeleteSelectedInvoices)
            {
                ApplicationArea = All;
                Caption = 'Delete Selected Invoices';
                Image = Delete;
                ToolTip = 'Delete all selected sales invoices. Skips invoices that cannot be deleted.';
                trigger OnAction()
                var
                    deletedCount: Integer;
                    skippedCount: Integer;
                    L_SalesHeader: Record "Sales Header";
                    UserSetup: Record "User Setup";
                begin
                    UserSetup.Reset();
                    if UserSetup.Get(UserId) then begin
                        if UserSetup."Allow to Delete Bulk Invoices" = true then begin
                            Commit();

                            // Limit loop to the current selection on the page
                            L_SalesHeader.Reset();
                            CurrPage.SetSelectionFilter(L_SalesHeader);
                            L_SalesHeader.SetFilter(Status, '%1', L_SalesHeader.Status::Open);
                            L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Invoice);

                            // If nothing selected, inform user
                            if not L_SalesHeader.FindSet() then begin
                                Message('Please select at least one invoice to delete.');
                                exit;
                            end;

                            if not Confirm('Are you sure you want to delete the selected invoice(s)?') then
                                exit;

                            // Iterate selection and attempt to delete each record. If delete fails for
                            // a record it is skipped and the loop continues.
                            repeat
                                // Attempt to delete; if an error occurs, skip this record
                                // (e.g., posted, linked, or permission issues)
                                if L_SalesHeader.Delete(true) then
                                    deletedCount += 1
                                else
                                    skippedCount += 1
                            until L_SalesHeader.Next() = 0;

                            Message('%1 invoice(s) deleted. %2 invoice(s) skipped.', deletedCount, skippedCount);

                        end else
                            Message('You do not have permission to delete bulk sales invoices.');
                    end else
                        Message('You do not have permission to delete bulk sales invoices.');
                end;
            }
        }
    }

}