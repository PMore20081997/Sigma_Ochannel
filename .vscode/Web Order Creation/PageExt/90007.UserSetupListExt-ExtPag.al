pageextension 90007 "UserSetupListExt" extends "User Setup"
{
    layout
    {
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
                Visible = false;
            }
        }
        addafter("Allowed Quota Manag. for CD")
        {
            field("Allow Edit Order/Product Resp."; Rec."Allow Edit Order/Product Resp.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the user has permission to change the Order or Product Responses for Web Orders.';
            }
        }
    }
}