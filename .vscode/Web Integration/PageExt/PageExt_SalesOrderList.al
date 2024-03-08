// pageextension 90006 SalesOrdListExt extends "Sales Order List"
// {
//     layout
//     {
//         // Add changes to page layout here
//     }

//     actions
//     {
//         addafter("&Print")
//         {
//              action("EDI File 2")
//             {
//                 ApplicationArea = All;
//                 Image = Journal;
//                 PromotedCategory = Process;
//                 Promoted = true;

//                 trigger OnAction()
//                 var
//                     EDIInvoiceCOD: Codeunit "EDI Invoice";
//                     JobQueueEntry: Record "Job Queue Entry" temporary;
//                     SalesHeader: Record "Sales Header";
//                     customer: Record "Customer";
//                 begin
//                     Clear(SalesHeader);
//                     SalesHeader := Rec;
//                     CurrPage.SetSelectionFilter(SalesHeader);

//                     if SalesHeader.FindSet() then begin
//                         repeat
//                             Clear(customer);
//                             customer.Reset();
//                             if customer.get(SalesHeader."Buy-from Vendor No.") then
//                                 EDIInvoiceCOD.ProcessEDIFile1(SalesHeader, customer);
//                         until SalesHeader.Next() = 0;
//                     end;
//                 end;
//             }
//         }
//     }

//     var
//         myInt: Integer;
// }