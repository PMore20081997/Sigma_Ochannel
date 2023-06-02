query 90100 ItemQuery
{

    elements
    {
        dataitem(Item; Item)
        {
            column(No; "No.")
            {
            }
            column(Inventory; Inventory)
            {
            }
            column(Qty_on_Sales_Order; "Qty. on Sales Order")
            {
            }
            column(Qty_on_Web_Order; "Qty. on Web Order")
            {
            }
            column(Qty_on_Web_Resv_Order; "Qty. on Resv Web Order")
            {
            }
            column(W_H_Inventory; "W/H Inventory")
            {
            }
            column(Ship_Bin_Inventory; "Ship Bin Inventory")
            {

            }
            column(Inventory_Qty_; "Inventory Qty.")
            {

            }
            column(Qty__on_Assembly_Order; "Qty. on Assembly Order")
            {

            }
            filter(Location_Filter; "Location Filter")
            {
            }
            /*filter(Bin_Filter; "Bin Filter")
            {
            }*///Block_NIKHIL_User Story 6088: The system will create WIP only for stock availability rather than checking at the Warehouse
            filter(Variant_Filter; "Variant Filter")
            {

            }
            filter(Bin_Type_Filter; "Bin Type Filter")
            {

            }//NIKHIL_User Story 6088: The system will create WIP only for stock availability rather than checking at the Warehouse
        }
    }
}

