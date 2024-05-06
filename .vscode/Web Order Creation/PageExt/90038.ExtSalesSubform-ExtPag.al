pageextension 90038 "Ext Sales Subform" extends "Sales Order Subform"
{
    layout
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                //Ignore Validation From Web Order and Upload From Tempalte+++ 
                if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
                    if Rec.Quantity > CheckFreeQuantity_OnValidate(Rec) then
                        Error('Quantity should be less than equal to Free Inventory: %1. Order No: %2, Line No: %3, Item No: %4', CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                end;
            end;
        }
        modify("Variant Code")
        {
            trigger OnAfterValidate()
            begin
                //Ignore Validation From Web Order and Upload From Tempalte+++
                if (Rec.Quantity > 0) AND (Rec."Variant Code" <> '') AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
                    if Rec.Quantity > CheckFreeQuantity_OnValidate(Rec) then
                        Error('Quantity should be less than equal to Free Inventory: %1. Order No: %2, Line No: %3, Item No: %4', CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
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

            field("Total Free"; TotalFree(rec))
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
            field("Free"; Free(Rec))
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

    local procedure TotalFree(_Rec: Record "Sales Line") _TotalFree: Decimal
    begin
        _Rec.CalcFields("Total Physical", "Total Allocated on SO", "Web Orders Qty");
        _TotalFree := _Rec."Total Physical" - (_Rec."Total Allocated on SO" + _Rec."Web Orders Qty");
        if _TotalFree > 0 then
            exit(_TotalFree)
        else
            exit(0);
    end;

    local procedure Free(_Rec: Record "Sales Line") _Free: Decimal
    begin
        _Rec.CalcFields("Allocated on SO", Physical, "Web Orders Qty");
        _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty");
        if _Free > 0 then
            exit(_Free)
        else
            exit(0);
    end;

    local procedure CheckFreeQuantity_OnValidate(_Rec: Record "Sales Line") _Free: Decimal
    var
        L_SalesLine: Record "Sales Line";
        _CurrentLineQty: Decimal;
    begin
        CurrPage.Update();
        Clear(_CurrentLineQty);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", _Rec."Document Type");
        L_SalesLine.SetRange("Document No.", _Rec."Document No.");
        L_SalesLine.SetRange("Line No.", _Rec."Line No.");
        if L_SalesLine.FindFirst() then
            _CurrentLineQty := L_SalesLine.Quantity;

        _Rec.CalcFields("Allocated on SO", Physical, "Web Orders Qty");
        _Free := (_Rec.Physical + _CurrentLineQty) - (_Rec."Allocated on SO" + _Rec."Web Orders Qty");
        if _Free > 0 then
            exit(_Free)
        else
            exit(0);
    end;
}