tableextension 90097 "Sales Line Extended" extends "Sales Line"
{

    fields
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var
                L_SalesHeader: Record "Sales Header";
            begin
                //Only for Sales Order Template+++
                L_SalesHeader.Reset();
                L_SalesHeader.SetRange("Document Type", Rec."Document Type");
                L_SalesHeader.SetRange("No.", Rec."Document No.");
                if L_SalesHeader.FindFirst() then begin
                    if L_SalesHeader."Sheet Name" <> '' then begin
                        if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
                            if Rec.Quantity > G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec) then
                                Error('Quantity should be less than equal to Free Inventory: %1. Order No: %2, Line No: %3, Item No: %4', G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                        end;
                    end;
                end;
            end;
        }

        modify("Variant Code")
        {
            trigger OnAfterValidate()
            var
                L_SalesHeader: Record "Sales Header";
            begin
                //Only for Sales Order Template+++
                L_SalesHeader.Reset();
                L_SalesHeader.SetRange("Document Type", Rec."Document Type");
                L_SalesHeader.SetRange("No.", Rec."Document No.");
                if L_SalesHeader.FindFirst() then begin
                    if L_SalesHeader."Sheet Name" <> '' then begin
                        if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
                            if Rec.Quantity > G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec) then
                                Error('Quantity should be less than equal to Free Inventory: %1. Order No: %2, Line No: %3, Item No: %4', G_CT_Function.Sales_CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                        end;
                    end;
                end;
            end;
        }

        field(90000; "Scanned Date"; DateTime)
        {

        }
        field(90001; "Channel Order ID"; Code[50])
        {
        }
        field(90002; "Channel Code"; Code[20])
        {
        }
        field(90003; "Web Order"; Boolean)
        {

        }
        field(90004; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(90005; "Ship-to Code"; Code[20])
        {
            //FTP Integration
        }
        field(90006; "Temp Web Order No."; Code[2048])
        {
            //FTP Integration
        }


    }
    var
        G_CT_Function: Codeunit "Inventory Calculation";
}