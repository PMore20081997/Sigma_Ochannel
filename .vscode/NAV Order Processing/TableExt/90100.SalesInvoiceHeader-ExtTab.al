tableextension 90100 "Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(90000; "Web Shipment Method"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90001; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(90002; SalesOrderReturnNo; Code[20])
        {
            Caption = 'Sales Order Return No.';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(90003; "Web Order"; Boolean)
        {
        }
        field(90004; "Marged Web Order"; Boolean)
        {
        }
        field(90005; Export; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Export';
        }
    }
}