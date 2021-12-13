query 90003 "Disptach Screen Query"
{
    QueryType = Normal;


    elements
    {
        dataitem(Shipment_Tracking; "Shipment Tracking")
        {
            column(Tracking_No_; "Tracking No.")
            {

            }
            dataitem(Interim_Sales_Header; "Interim Sales Header")
            {
                DataItemLink = "No." = Shipment_Tracking."Document No.";
                column(Channel_Order_ID; "Channel Order ID") { }
            }

        }

    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}