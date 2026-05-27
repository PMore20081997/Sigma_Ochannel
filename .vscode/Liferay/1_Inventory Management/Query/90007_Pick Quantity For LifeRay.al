query 90007 "Pick Qty LifeRay"
{
    QueryType = Normal;

    elements
    {
        dataitem(Warehouse_Activity_Line; "Warehouse Activity Line")
        {
            DataItemTableFilter = "Source Document" = filter("Sales Order");


            column(Item_No_; "Item No.")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Location_Code; "Location Code")
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