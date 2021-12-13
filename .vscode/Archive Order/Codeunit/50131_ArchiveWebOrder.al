codeunit 90073 "Archived web Orders"
{

    procedure ArchivedWebOrders()
    var
        InterimSalesHeader: Record "Interim Sales Header";
        InterimSalesLine: Record "Interim Sales Line";
        HandledIncomingHeader: Record "Handled Interim Sales Header";
        HandledIncomingLine: Record "Handled Interim Sales Line";
    begin
        //InterimSalesHeader.SetRange(Status, InterimSalesHeader.Status::Processed);
        //InterimSalesHeader.SetFilter("Sales Order No.", '<>%1', '');
        if InterimSalesHeader.FindSet() then begin
            repeat
                HandledIncomingHeader."No." := InterimSalesHeader."No.";

                InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                //InterimSalesHeader.SetRange("Sales Order No.", InterimSalesHeader."Sales Order No.");
                if InterimSalesLine.FindSet() then begin
                    repeat

                    until InterimSalesLine.Next = 0;

                end;
            Until InterimSalesHeader.Next() = 0;
        end;
        InterimSalesHeader.Mark();
        InterimSalesHeader.Delete(true);
    end;

    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;
}