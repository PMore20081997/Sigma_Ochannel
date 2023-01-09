query 90010 "Channel Ord id wise picked Qty"
{
    Caption = 'Channel Order id wise Picked Qty';
    QueryType = Normal;

    elements
    {
        dataitem(Warehouse_Shipment_Line; "Warehouse Shipment Line")
        {
            column(ChannelOrderID; "Channel Order ID")
            {

            }
            column(QtyPicked; "Qty. Picked")
            {
                Method = sum;
            }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}