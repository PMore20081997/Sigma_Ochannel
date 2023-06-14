query 90075 "Validate Return Order Screen"
{

    elements
    {
       /* dataitem(Handled_Interim_Sales_Header; "Handled Interim Sales Header")
        {
            DataItemTableFilter = "Document Type" = filter("Return Order");
            column(Channel_Order_ID; "Channel Order ID")
            {

            }*/
            dataitem(Handled_Interim_Sales_Line; "Handled Interim Sales Line")
            {
               // DataItemLink = "Document Type" = Handled_Interim_Sales_Header."Document Type", "Document No" = Handled_Interim_Sales_Header."No.";
                DataItemTableFilter = "Document Type" = filter("Return Order");
                column(Channel_Order_ID;"Channel Order ID")
                {

                }
                column(No_; "No.")
                {

                }
                column(NAV_Variant_code; "NAV Variant code")
                {

                }
                column(Quantity; Quantity)
                {
                    Method = Sum;
                }
            //}
        }
    }
}

