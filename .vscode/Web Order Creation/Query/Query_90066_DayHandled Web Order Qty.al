// query 90066 "DayHandled Web Order Qty"
// {

//     elements
//     {
//         dataitem(QueryElement1000000000; "Handled Interim Sales Header")
//         {
//             column(Document_Type; "Document Type")
//             {
//             }
//             column(Sell_to_Customer_No; "Sell-to Customer No.")
//             {
//             }
//             column(Ship_to_Code; "Ship-to Code")
//             {
//             }
//             column(Order_Date; "Order Date")
//             {
//             }
//             dataitem(QueryElement1000000001; "Handled Interim Sales Line")
//             {
//                 DataItemLink = "Document Type" = "QueryElement1000000000"."Document Type", "Document No" = "QueryElement1000000000"."No.";
//                 DataItemTableFilter = Type = FILTER(Item), "Response Code" = filter(0);
//                 column(No; "No.")
//                 {
//                 }
//                 column(Item_Category_Code; "Item Category Code")
//                 {

//                 }
//                 column(Customer_Price_Group; "Customer Price Group")
//                 {

//                 }
//                 column(Sum_Quantity; Quantity)
//                 {
//                     Method = Sum;
//                 }
//             }
//         }
//     }
// }

