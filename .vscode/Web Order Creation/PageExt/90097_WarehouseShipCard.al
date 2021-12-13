pageextension 90097 "Whse. Shipment Card" extends "Warehouse Shipment"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Tracking Number"; Rec."Tracking Number")
            {
                ApplicationArea = All;
            }
        }
    }
}