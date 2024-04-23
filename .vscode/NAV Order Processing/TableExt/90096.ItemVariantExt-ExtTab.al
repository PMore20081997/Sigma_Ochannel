tableextension 90096 "Item Variant Ext" extends "Item Variant"
{
    fields
    {
        field(50002; "VAT Prod Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(50003; "Shelf No."; Code[20])
        {

        }
        field(50004; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("Item No."), "Reason Message" = const('Successful'), "Sales Order Created" = const(false)));
            DecimalPlaces = 0 : 5;
            Editable = false;
            //GHST Customization++
        }
    }
}