pageextension 90100 "ItemCardExt" extends "Item Card"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("WebOrder Status"; Rec."WebOrder Status")
            {
                ApplicationArea = All;
                Editable = L_CurrPageEditable;
            }
        }
        addafter(Inventory)
        {

            field("Qty. on Web Order"; Rec."Qty. on Web Order")
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Sucessfull Electronic Orders';
            }
        }
        addafter("Vendor No.")
        {
            field("Vendor Name"; Rec."Vendor Name")
            {
                ApplicationArea = All;
                Editable = L_CurrPageEditable;
            }
        }
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