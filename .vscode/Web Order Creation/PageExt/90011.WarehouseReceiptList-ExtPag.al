pageextension 90011 "Warehouse Receipt List" extends "Warehouse Receipts"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {
            field(ExpetedReceiptDate; ExpetedReceiptDate)
            {
                Caption = 'Expected Receipt Date';
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


    trigger OnAfterGetRecord()
    var
        L_WareReceiptLine: Record "Warehouse Receipt Line";
    begin
        Clear(ExpetedReceiptDate);
        L_WareReceiptLine.Reset();
        L_WareReceiptLine.SetRange("No.", Rec."No.");
        if L_WareReceiptLine.FindFirst() then begin
            ExpetedReceiptDate := L_WareReceiptLine."Due Date";
        end;
    end;

    var
        ExpetedReceiptDate: Date;
}