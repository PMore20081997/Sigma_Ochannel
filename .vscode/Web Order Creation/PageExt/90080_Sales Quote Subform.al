// pageextension 90080 "OC Sales Quote Subform" extends "Sales Quote Subform"
// {
//     layout
//     {
//         modify(Quantity)
//         {
//             trigger OnAfterValidate()
//             begin
//                 //Ignore Validation From Web Order and Upload From Tempalte+++ 
//                 CurrPage.Update();
//                 if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
//                     if Rec.Quantity > G_CT_Function.SalesQuote_CheckFreeQuantity_OnValidate(Rec) then
//                         Error('Quantity should be less than equal to Free Inventory - %1. Order No: %2, Line No: %3, Item No: %4', G_CT_Function.SalesQuote_CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
//                 end;
//             end;
//         }
//         modify("Variant Code")
//         {
//             trigger OnAfterValidate()
//             begin
//                 //Ignore Validation From Web Order and Upload From Tempalte+++
//                 CurrPage.Update();
//                 if (Rec.Quantity > 0) AND (Rec.Type = Rec.Type::Item) AND (Rec."Purchasing Code" = '') AND ((Rec."Document Type" = Rec."Document Type"::Order) OR (Rec."Document Type" = Rec."Document Type"::Quote)) then begin
//                     if Rec.Quantity > G_CT_Function.SalesQuote_CheckFreeQuantity_OnValidate(Rec) then
//                         Error('Quantity should be less than equal to Free Inventory - %1. Order No: %2, Line No: %3, Item No: %4', G_CT_Function.SalesQuote_CheckFreeQuantity_OnValidate(Rec), Rec."Document No.", Rec."Line No.", Rec."No.");
//                 end;
//             end;
//         }

//         // addafter("Total Allocated on SO")
//         // {
//         //     field("Total Free"; G_CT_Function.Sales_TotalFree(rec))
//         //     {
//         //         Caption = 'Total Free';
//         //         ApplicationArea = All;
//         //         Editable = false;
//         //         DecimalPlaces = 0 : 5;
//         //         ToolTip = 'Total Physical - Total SO Allocated - Web Order Qty';
//         //     }
//         // }
//         // addafter("Allocated on SO")
//         // {
//         //     field("Free"; G_CT_Function.Sales_Free(Rec))
//         //     {
//         //         ApplicationArea = All;
//         //         Editable = false;
//         //         DecimalPlaces = 0 : 5;
//         //         ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
//         //         Caption = 'Free';
//         //     }
//         // }
//     }

//     actions
//     {
//         // Add changes to page actions here
//     }

//     var
//         myInt: Integer;

//         G_CT_Function: Codeunit "Inventory Calculation";
// }