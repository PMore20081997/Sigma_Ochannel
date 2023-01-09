pageextension 90007 UserSetupListExt extends "User Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(Control1)
        {

            field("Allow to Auth. Web Order Price"; Rec."Allow to Auth. Web Order Price")
            {
                ApplicationArea = All;
            }
            field("Allow Edit Qty. to ship"; Rec."Allow Edit Qty. to ship")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the user if the user has permission to change Qty. to ship value in Warehouse Shipment Lines.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}