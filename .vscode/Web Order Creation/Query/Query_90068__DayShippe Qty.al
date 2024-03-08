query 90068 "DayShippe Qty Copy"
{

    elements
    {
        dataitem(QueryElement1000000000; 110)
        {
            column(Sell_to_Customer_No; "Sell-to Customer No.")
            {
            }
            column(Ship_to_Code; "Ship-to Code")
            {
            }
            column(Order_Date; "Order Date")
            {
            }
            dataitem(QueryElement1000000001; 111)
            {
                DataItemLink = "Document No." = QueryElement1000000000."No.";
                //DataItemTableFilter = Type = FILTER(Item), "Dataplast Order" = filter(false);
                DataItemTableFilter = Type = FILTER(Item);
                column(No; "No.")
                {
                }
                column(Item_Category_Code; "Item Category Code")
                {

                }
                column(Customer_Price_Group; "Customer Price Group")
                {

                }
                column(Sum_Quantity; Quantity)
                {
                    Method = Sum;
                }
            }
        }
    }
}

