pageextension 90091 SalesCreditMemosList extends "Sales Credit Memos"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Re&lease")
        {
            action("Bulk Delete Credit Memos")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    UserSetup: Record "User Setup";
                begin
                    UserSetup.Reset();
                    if UserSetup.Get(UserId) then begin
                        if UserSetup."Allow Delete Bulk Credit Memos" = true then begin
                            Clear(L_SalesHeader);
                            L_SalesHeader := Rec;
                            CurrPage.SetSelectionFilter(L_SalesHeader);
                            L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::"Credit Memo");
                            if L_SalesHeader.FindSet() then begin
                                repeat
                                    L_SalesHeader.Delete(true);
                                    Commit();
                                until L_SalesHeader.Next() = 0;
                            end;
                        end else
                            Message('You do not have permission to delete bulk sales credit memos.');
                    end else
                        Message('You do not have permission to delete bulk sales invoices.');
                end;
            }
        }
    }

    var
        myInt: Integer;
}