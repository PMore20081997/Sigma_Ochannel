query 90022 "Lot By Item From ILE"
{
    QueryType = Normal;

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Remaining Quantity" = filter(> 0);
            column(Item_No_; "Item No.")
            {

            }
            column(Lot_No_; "Lot No.")
            {

            }
            column(Location_Code; "Location Code")
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