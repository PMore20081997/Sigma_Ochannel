query 90065 "Daywise Web order quantity"
{

    elements
    {
        dataitem(QueryElement1000000000; "Interim Sales Header")
        {
            column(Sales_Order_Created; "Sales Order Created")
            {

            }
            column(Document_Type; "Document Type")
            {
            }
            column(Doc_No; "No.")
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
            dataitem(QueryElement1000000001; "Interim Sales Line")
            {
                DataItemLink = "Document Type" = "QueryElement1000000000"."Document Type", "Document No" = "QueryElement1000000000"."No.";
                DataItemTableFilter = Type = FILTER(Item), "Reason Message" = const('Successful');
                column(No; "No.")
                {
                }
                column(Line_No_; "Line No.")
                {

                }
                column(Item_Category_Code; "Item Category Code")
                {

                }
                column(Customer_Price_Group; "Customer Price Group")
                {

                }
                //Azhar--
                column(Sum_Quantity; "Qty. to Deliver")
                {
                    Method = Sum;
                }
            }
        }
    }


    trigger OnBeforeOpen()
    begin
        CurrQuery.SetFilter(Sales_Order_Created, '%1', false);
    end;
}

