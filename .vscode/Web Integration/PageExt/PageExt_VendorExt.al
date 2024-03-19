pageextension 90005 VendorCardExt extends "Vendor Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("EDI Invoice/Credit"; rec."EDI Invoice/Credit")
            {
                ApplicationArea = all;
                Editable = L_CurrPageEditable;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        L_CurrPageEditable: Boolean;

    trigger OnAfterGetRecord()
    var
        L_UserSetup: Record "User Setup";
    begin
        Clear(L_CurrPageEditable);
        if Rec.Status = Rec.Status::Open then begin
            L_CurrPageEditable := true;
        end else begin
            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Edit Master Data" = true then begin
                    if Rec.Status = Rec.Status::Open then
                        L_CurrPageEditable := true
                    else
                        L_CurrPageEditable := false;
                end else
                    L_CurrPageEditable := false;
            end else
                L_CurrPageEditable := false;

        end;
    end;

    trigger OnOpenPage()
    var
        L_UserSetup: Record "User Setup";
    begin
        Clear(L_CurrPageEditable);
        if Rec.Status = Rec.Status::Open then begin
            L_CurrPageEditable := true;
        end else begin
            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Edit Master Data" = true then begin
                    if Rec.Status = Rec.Status::Open then
                        L_CurrPageEditable := true
                    else
                        L_CurrPageEditable := false;
                end else
                    L_CurrPageEditable := false;
            end else
                L_CurrPageEditable := false;

        end;
    end;
}