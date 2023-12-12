tableextension 90004 "Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {
        field(90001; "Web Shipment Method"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90002; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

    }
}