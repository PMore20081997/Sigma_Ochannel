query 90003 "SalesLine Quantity Query"
{
    QueryType = Normal;

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            column(Document_Type; "Document Type")
            {

            }
            column(Document_No_; "Document No.")
            {

            }
            column(Line_No_; "Line No.")
            {

            }
            column(Type; Type)
            {

            }
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
            column(Saleable_Location; "Saleable Location")
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

    trigger OnBeforeOpen()
    begin

    end;
}