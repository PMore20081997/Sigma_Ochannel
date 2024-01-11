tableextension 90097 "Sales Line Extended" extends "Sales Line"
{

    fields
    {
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
}