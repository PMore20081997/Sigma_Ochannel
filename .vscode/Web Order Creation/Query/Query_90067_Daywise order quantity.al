query 90067 "Daywise order quantity Copy"
{

    elements
    {
        dataitem(QueryElement1000000000; 36)
        {
            column(Document_Type; "Document Type")
            {
            }
            column(Sell_to_Customer_No; "Sell-to Customer No.")
            {
            }
            column(Ship_to_Code; "Ship-to Code")
            {
            }
            column(Order_Date; "Order Date")
            {
            }
            dataitem(QueryElement1000000001; 37)
            {
                //DataItemLink= "Document Type"= QueryElement1000000000.doc
                DataItemLink = "Document Type" = "QueryElement1000000000"."Document Type", "Document No." = "QueryElement1000000000"."No.";
                //DataItemTableFilter = Type = FILTER(Item), "Dataplast Order" = filter(false);
                DataItemTableFilter = Type = FILTER(Item);

                column(No; "No.")
                {
                }
                //Azhar++
                column(Item_Category_Code; "Item Category Code")
                {

                }
                column(Customer_Price_Group; "Customer Price Group")
                {

                }
                //Azhar--
                column(Sum_Quantity; "Outstanding Quantity")
                {
                    Method = Sum;
                }
            }
        }
    }
}

