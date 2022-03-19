tableextension 90011 "Warehouse Ship Line Ext" extends "Warehouse Shipment Line"
{
    fields
    {
        field(90000; "Trolley Bay No."; Code[20])
        {
            Editable = true;
        }
        field(90001; "Dispatch Scan"; Boolean)
        {

        }
        field(90002; "Scanned Date"; DateTime)
        {

        }
        field(90004; "Trolley Closed Quantity"; Decimal)
        {

        }
    }
}