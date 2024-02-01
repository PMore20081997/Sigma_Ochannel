pageextension 90100 "ItemCardExt" extends "Item Card"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("WebOrder Status"; "WebOrder Status")
            {
                ApplicationArea = All;
                Editable = L_CurrPageEditable;
            }
        }
        addafter(Inventory)
        {

            field("W/H Inventory"; Rec."W/H Inventory")
            {
                DecimalPlaces = 0;
                Caption = 'Available Inventory';
                ApplicationArea = All;
                Editable = L_CurrPageEditable;
            }
            field("Qty. on Web Order"; Rec."Qty. on Web Order")
            {
                ApplicationArea = All;
                Editable = L_CurrPageEditable;
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
        L_EditableQUAApproved: Boolean;
        L_CurrPageEditable: Boolean;

    trigger OnAfterGetRecord()
    var
        L_UserSetup: Record "User Setup";


    begin
        Clear(L_CurrPageEditable);
        Clear(L_EditableQUAApproved);
        if Rec.Status = Rec.Status::Open then begin
            L_CurrPageEditable := true;
            L_EditableQUAApproved := true;
        end else begin
            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Edit Master Data" = true then
                    L_CurrPageEditable := true
                else
                    L_CurrPageEditable := false;
            end else
                L_CurrPageEditable := false;


            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Edit Master Data QAU Approved" = true then
                    L_EditableQUAApproved := true
                else
                    L_EditableQUAApproved := false;
            end else
                L_EditableQUAApproved := false;
        end;
    end;

    trigger OnOpenPage()
    var
        L_UserSetup: Record "User Setup";

    begin
        Clear(L_CurrPageEditable);
        Clear(L_EditableQUAApproved);
        if Rec.Status = Rec.Status::Open then begin
            L_CurrPageEditable := true;
            L_EditableQUAApproved := true;
        end else begin
            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Edit Master Data" = true then
                    L_CurrPageEditable := true
                else
                    L_CurrPageEditable := false;
            end else
                L_CurrPageEditable := false;


            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Edit Master Data QAU Approved" = true then
                    L_EditableQUAApproved := true
                else
                    L_EditableQUAApproved := false;
            end else
                L_EditableQUAApproved := false;
        end;
    end;
}