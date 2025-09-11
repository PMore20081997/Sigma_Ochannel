tableextension 90006 "OC Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(90006; "EDI Synced"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("EDI File Details".Sync where("Document No" = field("No."), "Document Type" = const("Credit Memo")));
            Caption = 'EDI Synced';
        }
    }

}