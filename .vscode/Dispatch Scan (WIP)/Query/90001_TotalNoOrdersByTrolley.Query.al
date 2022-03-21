query 90001 "Total No Orders By Trolley"
{

    elements
    {
        dataitem(Interim_Sales_Line; "Interim Sales Line")
        {
            DataItemTableFilter = Type = CONST(Item), "Document Type" = CONST(Order), "Item Type" = FILTER(<> Assembly), "Dispatch Scan" = FILTER(false);
            column(Document_No; "Document No")
            {
            }
            column(Trolley_No_; "Trolley No.")
            {
            }
            column(Count_)
            {
                Method = Count;
            }
            filter(Status; "Order Status")
            {
                ColumnFilter = Status = FILTER(Processing | "Partially Scanned");
            }
        }
    }
}

