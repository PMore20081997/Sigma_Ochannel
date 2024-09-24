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
            field("Allow to Move Web Orders"; Rec."Allow to Move Web Orders")
            {
                ApplicationArea = All;
                Caption = 'Allow to Move Web Orders into Handled';
                ToolTip = 'Specifies if user has permission to move web orders into handled orders';
            }
            field("Allow to Delete Bulk SO"; Rec."Allow to Delete Bulk SO")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if user has permission to delete bulk selected sales orders';
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