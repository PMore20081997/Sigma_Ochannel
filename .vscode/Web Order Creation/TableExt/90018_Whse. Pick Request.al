tableextension 90018 "Whse. Pick Request" extends "Whse. Pick Request"
{
    fields
    {
        // Add changes to table fields here
        field(90000; "Channel Order ID"; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Assembly Header"."Description 2" where("No." = field("Document No.")));
        }
    }

    var
        myInt: Integer;
}