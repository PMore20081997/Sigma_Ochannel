pageextension 90080 "OC Sales Quote Subform" extends "Sales Quote Subform"
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
                        Error('Quantity should be less than equal to Free Inventory - %1. Order No: %2, Line No: %3, Item No: %4', CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
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
                        Error('Quantity should be less than equal to Free Inventory - %1. Order No: %2, Line No: %3, Item No: %4', CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                end;
            end;
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

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

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
    begin
        CurrPage.Update();
        _Rec.CalcFields("Allocated on SO", Physical, "Web Orders Qty");
        _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty");
        if _Free > 0 then
            exit(_Free)
        else
            exit(0);
    end;
}