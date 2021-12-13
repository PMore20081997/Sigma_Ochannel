pageextension 90095 "Posted Whse Ship Card" extends "Posted Whse. Shipment"
{
    layout
    {
        addafter("Assignment Time")
        {
            field("Tracking Number"; Rec."Tracking Number")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}