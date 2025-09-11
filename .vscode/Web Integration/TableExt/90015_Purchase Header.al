tableextension 90015 "OH Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(90015; "EDI Synced"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("EDI File Details".Sync where("Document No" = field("No."), "Document Type" = const(Order)));
            Caption = 'EDI Synced';
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