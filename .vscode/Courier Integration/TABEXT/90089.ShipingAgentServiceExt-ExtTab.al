tableextension 90089 "Shiping Agent Service Ext." extends "Shipping Agent Services"
{
    fields
    {
        //Added this Field to use while Validating No. of Parcel Field in Web Order
        field(90000; "Max. No. of Parcel"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }
}