// query 90008 "Web Order Qty for LifeRay"
// {
//     QueryType = Normal;

//     elements
//     {
//         dataitem(Interim_Sales_Line; "Interim Sales Line")
//         {
//             DataItemTableFilter = "Document Type" = const(Order), Type = const(Item), "Reason Code" = filter('Order line created|Partial Quantity Delivered');
//             column(No_; "No.")
//             {

//             }
//             column(Qty__to_Deliver; "Qty. to Deliver")
//             {
//                 Method = Sum;
//             }
//             filter(SystemCreatedAt; SystemCreatedAt)
//             {

//             }
//             filter(Sales_Order_Created; "Sales Order Created")
//             {

//             }
//             filter(Consolidated_Order; "Consolidated Order")
//             {

//             }
//         }
//     }

//     var
//         myInt: Integer;

//     trigger OnBeforeOpen()
//     begin

//     end;
// }