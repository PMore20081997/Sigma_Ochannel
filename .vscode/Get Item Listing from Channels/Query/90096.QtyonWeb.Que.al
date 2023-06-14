query 90096 "Qty on Web"
{

    elements
    {
        dataitem(Interim_Sales_Line; "Interim Sales Line")
        {
            DataItemTableFilter = "Document Type" = filter(Order), Type = filter(Item);
            column(No_; "No.")
            {

            }
            column(NAV_Variant_code; "NAV Variant code")
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

