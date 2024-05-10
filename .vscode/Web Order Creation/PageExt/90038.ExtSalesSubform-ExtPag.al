pageextension 90038 "Ext Sales Subform" extends "Sales Order Subform"
{
    layout
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                //Ignore Validation From Web Order and Upload From Tempalte+++ 
                CurrPage.Update();
                if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
                    if Rec.Quantity > G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec) then
                        Error('Quantity should be less than equal to Free Inventory: %1. Order No: %2, Line No: %3, Item No: %4', G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                end;
            end;
        }
        modify("Variant Code")
        {
            trigger OnAfterValidate()
            begin
                //Ignore Validation From Web Order and Upload From Tempalte+++
                CurrPage.Update();
                if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
                    if Rec.Quantity > G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec) then
                        Error('Quantity should be less than equal to Free Inventory: %1. Order No: %2, Line No: %3, Item No: %4', G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                end;
            end;
        }

        addbefore("Total Allocated on SO")
        {
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Sucessfull Electronic Orders';
            }
        }
        addafter("Total Allocated on SO")
        {

            field("Total Free"; G_CT_Function.Sales_TotalFree(rec))
            {
                Caption = 'Total Free';
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Total Physical - Total SO Allocated - Web Order Qty';
            }
        }
        addafter("Allocated on SO")
        {
            field("Free"; G_CT_Function.Sales_Free(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
                Caption = 'Free';
            }
        }
    }
    local procedure SetWeborderFilter(_SalesOrderNo: Code[20]): Text
    var
        L_WebBuffer: Record "Web Buffer";
        WebOrderNo: Text;
    begin
        Clear(WebOrderNo);
        L_WebBuffer.Reset();
        L_WebBuffer.SetRange("Sales Document No.", _SalesOrderNo);
        L_WebBuffer.SetCurrentKey("Web Document No.");
        L_WebBuffer.Ascending(true);
        if L_WebBuffer.FindSet() then begin
            repeat
                if WebOrderNo <> '' then begin
                    WebOrderNo := WebOrderNo + '|' + L_WebBuffer."Web Document No.";
                end else
                    WebOrderNo := L_WebBuffer."Web Document No.";
            until L_WebBuffer.Next() = 0;
        end;
        exit(WebOrderNo);

    end;

    trigger OnDeleteRecord(): Boolean
    var
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        SalesOrderPage: Page "Sales Order";
    begin
        HandledInterimSalesLine.Reset();
        HandledInterimSalesLine.SetRange("Document No", Rec."Document No.");
        HandledInterimSalesLine.SetRange("Line No.", Rec."Line No.");
        if HandledInterimSalesLine.FindFirst() then begin
            HandledInterimSalesLine.Delete(true);
            SalesOrderPage.UpdateHandledInterimSalesHeader(Rec);
        end;
    end;

    var
        G_CT_Function: Codeunit "Inventory Calculation";

}