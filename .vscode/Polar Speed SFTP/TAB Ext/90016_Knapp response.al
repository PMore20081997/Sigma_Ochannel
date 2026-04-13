tableextension 90016 "OC Knapp Order Response" extends "Knapp Order Response"
{
    fields
    {
        // Add changes to table fields here
        field(90000; "PS Label Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Polar Speed Barcode Details" where("Tote/Order No." = field("Load Unit"), "Order No." = field("Document No.")));
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