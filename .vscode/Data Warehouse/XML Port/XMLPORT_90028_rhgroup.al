// xmlport 90028 "Contract rhgroup"
// {

//     Caption = 'Export File';
//     DefaultFieldsValidation = false;
//     Direction = Export;
//     // FieldSeparator = ',';
//     //FieldDelimiter = '<None>';
//     TableSeparator = '<NewLine>';
//     Format = VariableText;
//     TextEncoding = UTF8;
//     UseRequestPage = false;
//     FileName = 'rhgroup.csv';

//     schema
//     {
//         textelement(Root)
//         {
//             tableelement(Integer; Integer)
//             {
//                 SourceTableView = SORTING(Number) WHERE(Number = CONST(1));

//                 textelement("Product_Code_Header")
//                 {
//                 }
//                 textelement(Discount_Header)
//                 {
//                 }
//                 textelement(Contract_Price_Header)
//                 {
//                 }

//                 trigger OnAfterGetRecord()
//                 var
//                     myInt: Integer;
//                 begin
//                     Product_Code_Header := 'Product Code';
//                     Discount_Header := 'Discount';
//                     Contract_Price_Header := 'Contract Price';
//                 end;

//             }
//             tableelement("Price_List_Line"; "Price List Line")
//             {
//                 SourceTableView = WHERE("Price List Code" = filter('RHGROUP'));

//                 textelement(Product_Code)
//                 {
//                 }
//                 textelement(Discount)
//                 {
//                 }
//                 textelement(Contract_Price)
//                 {

//                 }

//                 trigger OnAfterGetRecord()
//                 var
//                     myInt: Integer;
//                 begin
//                     Product_Code := Price_List_Line."Product No.";
//                     Discount := Format(Price_List_Line."Line Discount %");
//                     Contract_Price := Format(Price_List_Line."Unit Price");
//                 end;
//             }
//         }
//     }
// }