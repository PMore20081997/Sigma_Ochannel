tableextension 90012 "Warehouse Ship Header Ext" extends "Warehouse Shipment Header"
{
    fields
    {
        field(90000; "Trolley No."; Code[20])
        {
        }
        field(90001; "Tracking Number"; Text[30])
        {
        }
        field(90002; Remarks; Text[2048])
        {
        }
        field(90004; "Pick Remarks"; Text[250])
        {
        }
    }
}