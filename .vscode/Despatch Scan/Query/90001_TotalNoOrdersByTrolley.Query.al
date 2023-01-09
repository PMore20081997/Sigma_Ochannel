query 90001 "Total No Orders By Trolley"
{

    elements
    {
        dataitem(Warehouse_Shipment_Line; "Warehouse Shipment Line")
        {

            column(Source_No_; "Source No.")
            {
            }
            column(Trolley_No_; "Trolley No.")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
            filter(Scan_Status; "Scan Status")
            {
                ColumnFilter = Scan_Status = FILTER(Parked | " ");
            }
        }
    }
}

