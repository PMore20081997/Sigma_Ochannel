pageextension 90092 "Ware Ship Subform" extends "Whse. Shipment Subform"
{
    layout
    {
        modify("Qty. to Ship")
        {
            Editable = true;
        }
        addafter("Qty. per Unit of Measure")
        {
            field("Dispatch Scan"; Rec."Dispatch Scan")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Scanned Date"; Rec."Scanned Date")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
            }
            field("Trolley Closed Quantity"; Rec."Trolley Closed Quantity")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}