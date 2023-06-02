tableextension 90004 "Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(50001; "FullFillment Status"; Option)
        {
            OptionMembers = "Not Acknowledged",Acknowledged,Fullfilled,Cancelled,Confirmed;
        }
        field(90000; "Tracking Number"; Text[30])
        {
            Editable = false;
        }
        field(90030; "Scanned Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
