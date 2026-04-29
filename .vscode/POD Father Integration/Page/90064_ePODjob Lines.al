// page 90064 "ePOD Job Lines"
// {
//     PageType = List;
//     ApplicationArea = All;
//     UsageCategory = Lists;
//     SourceTable = "ePOD Job Line";

//     layout
//     {
//         area(Content)
//         {
//             repeater(GroupName)
//             {
//                 field("Document No."; Rec."Document No.")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field("Line Number"; Rec."Line Number")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field("BC Invoice Number"; Rec."BC Invoice Number")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field("Shipment Date"; Rec."Shipment Date")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field("Shipping Agent Code"; Rec."Shipping Agent Code")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//                 field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//             }
//         }
//         area(Factboxes)
//         {

//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(ActionName)
//             {

//                 trigger OnAction()
//                 begin

//                 end;
//             }
//         }
//     }
// }