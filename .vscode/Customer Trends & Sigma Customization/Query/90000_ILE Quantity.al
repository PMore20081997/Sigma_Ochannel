query 90000 "ILE Quantity Query"
{
    QueryType = Normal;

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {

            column(Item_No_; "Item No.")
            {

            }
            column(Variant_Code; "Variant Code")
            {

            }
            column(Location_Code; "Location Code")
            {

            }
            column(Daily_Priority_Exist; "Daily Priority Exist")
            {

            }
            column(Saleable_Location; "Saleable Location")
            {

            }
            column(Remaining_Quantity; "Remaining Quantity")
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