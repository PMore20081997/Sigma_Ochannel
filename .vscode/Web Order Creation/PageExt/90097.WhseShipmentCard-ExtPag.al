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
            field("Trolley No."; Rec."Trolley No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        // addbefore(WhseShptLines)
        // {
        //     field(Comments; Rec.Comments)
        //     {
        //         ApplicationArea = All;
        //         ToolTip = 'Specifies the value of the Comments field.';
        //     }
        // }
    }
}