tableextension 90097 "Sales Line Extended" extends "Sales Line"
{

    fields
    {
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                if (Rec.Quantity <> 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') then begin
                    if Rec.Quantity > TotalAvailableQtyForSaleable(Rec) then
                        Error('Qty. should be less than Free Inventory %1. Order Number: %2, Line Number: %3, Item Number: %4', TotalAvailableQtyForSaleable(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
                end;
            end;
        }

        modify("No.")
        {
            trigger OnAfterValidate()
            var
                L_SalesLine: Record "Sales Line";
            begin
                // L_SalesLine.Reset();
                // L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                // L_SalesLine.SetRange("Document No.", Rec."Document No.");
                // L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                // if L_SalesLine.FindFirst() then begin
                //     if Rec."Channel Order ID" <> L_SalesLine."Channel Order ID" then
                //         Rec."Channel Order ID" := L_SalesLine."Channel Order ID";
                //     Rec."Channel Code" := L_SalesLine."Channel Code";
                // end;
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
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("No."), "Reason Message" = const('Successful'), "Sales Order Created" = const(true)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }

    }


    trigger OnBeforeDelete()
    var
        HISL: Record "Handled Interim Sales Line";
    begin
        if Rec.Type = Rec.Type::Item then begin
            HISL.Reset();
            HISL.SetRange("Document Type", HISL."Document Type"::Order);
            HISL.SetRange(Type, HISL.Type::Item);
            HISL.SetRange(HISL."Document No", Rec."Document No.");
            HISL.SetRange(HISL."No.", Rec."No.");
            if HISL.FindFirst() then begin
                HISL.Delete(true);
            end;
        end;
    end;

    local procedure TotalAvailableQtyForSaleable(_Rec: Record "Sales Line"): Decimal
    var
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
    begin
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory", "Web Orders Qty");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty")
            else
                exit(0)
        else
            exit(0);
    end;
}