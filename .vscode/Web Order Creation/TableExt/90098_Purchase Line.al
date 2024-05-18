tableextension 90098 "OC Purchase line" extends "Purchase Line"
{
    fields
    {
        field(90004; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false)));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
    }
}