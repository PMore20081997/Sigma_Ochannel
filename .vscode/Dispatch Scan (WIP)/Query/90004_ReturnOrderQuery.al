query 90004 "Return Order Screen Query"
{
    QueryType = Normal;
    elements
    {
        dataitem(Handled_Interim_Sales_Line; "Handled Interim Sales Line")
        {
            DataItemTableFilter = "Document Type" = filter("Return Order"), Type = filter(Item);
            column(Channel_Order_ID; "Channel Order ID")
            {

            }
            column(No_; "No.")
            {

            }
            column(NAV_Variant_code; "NAV Variant code")
            {

            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}