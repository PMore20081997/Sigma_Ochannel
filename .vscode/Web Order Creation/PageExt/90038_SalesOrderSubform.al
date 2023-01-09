pageextension 90038 "Ext Sales Subform" extends "Sales Order Subform"
{
    layout
    {
        modify("Net Weight")
        {
            Visible = true;

            trigger OnAfterValidate()
            begin
                Rec.TestStatusOpen();
            end;
        }
        // modify(Quantity)
        // {
        //     trigger OnAfterValidate()
        //     var
        //         HISL: Record "Handled Interim Sales Line";
        //         LineNo: Integer;
        //     begin
        //         Clear(LineNo);
        //         if Rec.Type = Rec.Type::Item then begin
        //             HISL.Reset();
        //             HISL.SetRange("Document Type", HISL."Document Type"::Order);
        //             HISL.SetRange(Type, HISL.Type::Item);
        //             HISL.SetRange(HISL."Document No", Rec."Document No.");
        //             HISL.SetRange(HISL."No.", Rec."No.");
        //             if NOT HISL.FindFirst() then begin
        //                 HISL.Reset();
        //                 HISL.SetRange("Document Type", HISL."Document Type"::Order);
        //                 HISL.SetRange(HISL."Document No", Rec."Document No.");
        //                 if HISL.FindLast() then
        //                     LineNo := HISL."Line No." + 10000;

        //                 HISL.Init();
        //                 HISL.Validate("Document Type", HISL."Document Type"::Order);
        //                 HISL.Validate("Document No", Rec."Document No.");
        //                 HISL.Validate("Line No.", LineNo);
        //                 HISL.Validate(Type, HISL.Type::Item);
        //                 HISL.Validate("No.", Rec."No.");
        //                 HISL.Validate(Description, Rec.Description);
        //                 HISL.Validate(Quantity, Rec.Quantity);
        //                 HISL.Validate("Unit Price", Rec."Unit Price");
        //                 HISL.Validate(Amount, Rec.Amount);
        //                 HISL.Validate("Amount Including VAT", Rec."Amount Including VAT");
        //                 HISL.Validate("Channel Order ID", Rec."Channel Order ID");
        //                 HISL.Validate("Trade Partner Code", Rec."Channel Code");
        //                 HISL.Insert(true);
        //             end else begin
        //                 HISL.Validate("No.", Rec."No.");
        //                 HISL.Validate(Description, Rec.Description);
        //                 HISL.Validate(Quantity, Rec.Quantity);
        //                 HISL.Validate("Unit Price", Rec."Unit Price");
        //                 HISL.Validate(Amount, Rec.Amount);
        //                 HISL.Validate("Amount Including VAT", Rec."Amount Including VAT");
        //                 HISL.Validate("Channel Order ID", Rec."Channel Order ID");
        //                 HISL.Validate("Trade Partner Code", Rec."Channel Code");
        //                 HISL.Modify(true);
        //             end;
        //         end;
        //     end;
        // }
    }

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
}