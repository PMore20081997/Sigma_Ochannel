query 90006 "PS Lable Query"
{
    QueryType = Normal;

    elements
    {
        dataitem(Polar_Speed_Barcode_Details; "Polar Speed Barcode Details")
        {
            column(Temprature; Temprature)
            {

            }
            filter(Shipment_Date; "Shipment Date")
            {

            }
        }
    }

    var
        myInt: Integer;
}