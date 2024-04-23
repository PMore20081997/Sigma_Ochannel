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
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {

            }
            column(Saleable_Location; "Saleable Location")
            {

            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}