pageextension 90094 "Sales Shipment Card Ext2" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Salesperson Code")
        {
            field("Tracking Number"; Rec."Tracking Number")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}