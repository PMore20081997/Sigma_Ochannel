query 90012 "Get Picked Qty Internal Pick"
{

    elements
    {
        dataitem(Warehouse_Shipment_Header; "Warehouse Shipment Header")
        {
            column(Trolley_No; "Trolley No.")
            {
            }
            column(No; "No.")
            {
            }
            dataitem(Warehouse_Shipment_Line; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = Warehouse_Shipment_Header."No.";
                column(Item_No; "Item No.")
                {

                }
                column(Variant_Code; "Variant Code")
                {
                }
                column(Channel_Order_ID; "Channel Order ID")
                {

                }
                column(Sum_Qty_Base; "Qty. Picked (Base)")
                {
                    Method = Sum;
                }

            }
        }
    }
}

