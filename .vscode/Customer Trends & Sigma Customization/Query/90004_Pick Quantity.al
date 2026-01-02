query 90004 "Pick Quantity Query"
{
    QueryType = Normal;

    elements
    {
        dataitem(Warehouse_Activity_Line; "Warehouse Activity Line")
        {
            column(Source_Document; "Source Document")
            {

            }
            column(Item_No_; "Item No.")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Saleable_Location; "Saleable Location")
            {

            }
            column(Shipment_Date; "Shipment Date")
            {

            }
            column(Qty__Outstanding__Base_; "Qty. Outstanding (Base)")
            {
                Method = Sum;
            }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}