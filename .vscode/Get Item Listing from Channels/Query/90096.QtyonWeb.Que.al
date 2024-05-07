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
            column(Sales_Order_Created; "Sales Order Created")
            {

            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {

            }
            column(Reason_Message; "Reason Message")
            {

            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            column(Qty_to_Deliver; "Qty. to Deliver")
            {
                Method = Sum;
            }
        }
    }
}