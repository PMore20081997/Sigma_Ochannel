tableextension 90096 "Item Variant Ext" extends "Item Variant"
{
    fields
    {
        field(90000; "VAT Prod Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(90001; "Shelf No."; Code[20])
        {
        }
        field(90002; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line"."Qty. to Deliver" where("Document Type" = const(Order), Type = const(Item), "No." = field("Item No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }
}