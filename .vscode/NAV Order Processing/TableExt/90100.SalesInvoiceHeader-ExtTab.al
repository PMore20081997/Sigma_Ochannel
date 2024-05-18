tableextension 90100 "Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(90000; Export; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Export';
        }
    }
}