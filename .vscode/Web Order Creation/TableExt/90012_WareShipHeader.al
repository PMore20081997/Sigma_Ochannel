tableextension 90012 "Warehouse Ship Header Ext" extends "Warehouse Shipment Header"
{
    fields
    {
        field(90000; "Trolley Bay No."; Code[20])
        {
            Editable = true;
        }
        field(90001; "Tracking Number"; Text[30])
        {

        }
    }
}