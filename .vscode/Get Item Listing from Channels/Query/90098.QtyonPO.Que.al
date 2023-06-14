query 90098 "Qty on PO"
{
    QueryType = Normal;


    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
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