// pageextension 90027 CustStats extends "Customer Statistics FactBox"
// {
//     layout
//     {
//         addafter("No.")
//         {
//             field(Hospital; rec.Hospital)
//             {
//                 ApplicationArea = all;
//                 Caption = 'Exempt from Credit check / Overdue check';
//                 Visible = false;
//             }
//             field("Credit limit Exceeded"; rec."Credit limit Exceeded")
//             {
//                 ApplicationArea = all;
//                 Visible = false;
//             }
//             field("Overdue Balance"; rec."Overdue Balance")
//             {
//                 ApplicationArea = all;
//                 Visible = false;
//             }
//         }
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }

//     var
//         myInt: Integer;
// }