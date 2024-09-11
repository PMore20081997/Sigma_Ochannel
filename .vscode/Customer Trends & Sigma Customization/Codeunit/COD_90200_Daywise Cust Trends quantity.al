query 90200 "Daywise Cust Trends Qty Mew"
{

    elements
    {
        dataitem(CustomerTrends; CustomerTrends)
        {
            column(Entry_Number; "Entry Number")
            {
            }
            column(Line_No_; "Line No.")
            {
            }
            column(Customer_No_; "Customer No.")
            {
            }
            column(Ship_to_Code; "Ship-to Code")
            {
            }
            column(Item_No_; "Item No.")
            {

            }
            column(Item_Category_Code; "Item Category Code")
            {

            }
            column(Customer_Price_Group; "Customer Price Group")
            {

            }
            column(Order_Date; "Order Date")
            {
            }
            column(Sum_Quantity; "Qty. to be added to SO")
            {
                Method = Sum;
            }
        }
    }
}

