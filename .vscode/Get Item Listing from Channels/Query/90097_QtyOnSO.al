query 90097 "Qty on SO"
{

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = filter(Order), Type = filter(Item);
            column(No_; "No.")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Outstanding_Qty___Base_; "Outstanding Qty. (Base)")
            {
                Method = Sum;
            }

        }
    }
}

