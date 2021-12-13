query 90099 "Calculate Inventory"
{
    QueryType = Normal;
    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {

            column(Item_No_; "Item No.")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }

        }
    }
}