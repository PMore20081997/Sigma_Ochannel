pageextension 90016 "Inventory Pick List Ext." extends "Inventory Picks"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addafter("Batch Post")
        {
            action("Bulk Delete")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                Image = Delete;
                trigger OnAction()
                var
                    L_WhseActivityHeader: Record "Warehouse Activity Header";
                begin
                    Clear(L_WhseActivityHeader);
                    L_WhseActivityHeader := Rec;
                    CurrPage.SetSelectionFilter(L_WhseActivityHeader);

                    if L_WhseActivityHeader.FindSet() then begin
                        repeat
                            L_WhseActivityHeader.Delete(true);
                            Commit();
                        until L_WhseActivityHeader.Next() = 0;
                    end;
                end;
            }
        }
    }
}