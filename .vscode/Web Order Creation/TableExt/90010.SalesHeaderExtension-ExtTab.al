tableextension 90010 "Sales Header Extension" extends "Sales Header"
{
    fields
    {
        field(90000; "Web Shipment Method"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90001; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(90002; SalesOrderReturnNo; Code[20])
        {
            Caption = 'Sales Order Return No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90003; "Web Order"; Boolean)
        {
        }
        field(90004; "Marged Web Order"; Boolean)
        {
        }
    }


    trigger OnDelete()
    var
        InterimSalesHeader: Record "Interim Sales Header";
        Return_HISH: Record "Handled Interim Sales Header";
        Return_HISL: Record "Handled Interim Sales Line";
    begin
        //DeleteHandledReturnOrder++
        if Rec."Document Type" = Rec."Document Type"::"Return Order" then begin
            Return_HISH.Reset();
            Return_HISH.SetRange("Document Type", Return_HISH."Document Type"::"Return Order");
            Return_HISH.SetRange("External Document No.", Rec."No.");
            if Return_HISH.FindSet() then begin
                repeat
                    Return_HISL.Reset();
                    Return_HISL.SetRange("Document Type", Return_HISL."Document Type"::"Return Order");
                    Return_HISL.SetRange("Document No", Return_HISH."No.");
                    if Return_HISL.FindSet() then begin
                        repeat
                            Return_HISL.Delete(true);
                        until Return_HISL.Next() = 0;
                    end;
                    Return_HISH.Delete(true);
                until Return_HISH.Next() = 0;
            end;
        end;
        //DeleteHandledReturnOrder--
        InterimSalesHeader.Reset();
        InterimSalesHeader.SetRange("Destination Doc Type", InterimSalesHeader."Destination Doc Type"::"Sales Order");
        InterimSalesHeader.SetRange("Destination Doc No.", Rec."No.");
        if InterimSalesHeader.FindFirst() then begin
            InterimSalesHeader."Destination Doc No." := '';
            Clear(InterimSalesHeader."Destination Doc Type");
            InterimSalesHeader.status := InterimSalesHeader.status::Accepted;
            InterimSalesHeader.Modify(true);
        end;
    end;
}