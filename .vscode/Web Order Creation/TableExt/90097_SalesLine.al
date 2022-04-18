tableextension 90097 "Sales Line Extended" extends "Sales Line"
{
    trigger OnDelete()
    var
        InterimSalesLine: Record "Interim Sales Line";
    begin
        /*InterimSalesLine.Reset();
        InterimSalesLine.SetRange("Destination Doc Type", InterimSalesLine."Destination Doc Type"::"Sales Order");
        InterimSalesLine.SetRange("Destination Doc No.", Rec."Document No.");
        InterimSalesLine.SetRange("Destination Doc. Line No", Rec."Line No.");
        if InterimSalesLine.FindFirst() then begin
            if InterimSalesLine.Status <> InterimSalesLine.Status::Cancelled then
             / Error('Status must be cancelled in Web Order %1 for Item %2, Line No. %3', InterimSalesLine."Document No", InterimSalesLine."No.", InterimSalesLine."Destination Doc. Line No");

        end;*/
    end;



}