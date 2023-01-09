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
        addbefore(WhseShptLines)
        {
            field(Comments; Rec.Comments)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Comments field.';
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        WhseEmployee: Record "Warehouse Employee";
        WhseShipmentHeader: Record "Warehouse Shipment Header";
    begin
        WhseEmployee.Reset();
        WhseEmployee.SetRange("User ID", UserId);
        WhseEmployee.SetFilter(Default, '%1', true);
        if WhseEmployee.FindFirst() then begin
            Rec."Location Code" := WhseEmployee."Location Code";
            // Rec.Insert(true);
        end;
    end;




}