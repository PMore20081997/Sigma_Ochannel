query 90011 "Sales Line Qty Liferay"
{
    QueryType = Normal;

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item);
            column(No_; "No.")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Shipment_Date; "Shipment Date")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Outstanding_Qty___Base_; "Outstanding Qty. (Base)")
            {
                Method = Sum;
            }
        }
    }

    var
        myInt: Integer;
}