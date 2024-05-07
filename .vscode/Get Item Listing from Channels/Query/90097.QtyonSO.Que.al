query 90097 "Qty on SO"
{
    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = filter(Order), Type = filter(Item);
            column(No; "No.")
            {

            }
            column(Saleable_Location; "Saleable Location")
            {

            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Outstanding_Qty; "Outstanding Quantity")
            {
                Method = Sum;
            }
        }
    }
}