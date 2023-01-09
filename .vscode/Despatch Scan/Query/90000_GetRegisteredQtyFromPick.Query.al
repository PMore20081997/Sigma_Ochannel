query 90002 "Get Registered Qty From Pick"
{

    elements
    {
        dataitem(Registered_Whse_Activity_Hdr; "Registered Whse. Activity Hdr.")
        {
            DataItemTableFilter = Type = FILTER(Pick), "Trolley Closed" = CONST(false);
            column(Trolley_No; "Trolley No.")
            {
            }
            column(Type; Type)
            {
            }
            column(No; "No.")
            {
            }
            dataitem(Registered_Whse_Activity_Line; "Registered Whse. Activity Line")
            {
                DataItemLink = "Activity Type" = Registered_Whse_Activity_Hdr.Type, "No." = Registered_Whse_Activity_Hdr."No.";
                DataItemTableFilter = "Activity Type" = CONST(Pick), "Action Type" = CONST(Place);
                column(Item_No; "Item No.")
                {
                    
                }
                column(Variant_Code;"Variant Code")
                {                    
                }
                column(Bay_No;"Bay No.")
                {

                }   
                column(Sum_Qty_Base; "Qty. (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}

