tableextension 90098 "OC Purchase line" extends "Purchase Line"
{
    fields
    {
        // Add changes to table fields here
        field(90004; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line".Quantity where(Type = const(Item), "No." = field("No."), "Reason Message" = const('Successful|Partial Quantity Delivered'), "Sales Order Created" = const(false)));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}