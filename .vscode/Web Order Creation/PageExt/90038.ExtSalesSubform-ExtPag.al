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