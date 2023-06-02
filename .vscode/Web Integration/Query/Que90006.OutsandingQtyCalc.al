query 90006 OutsandingQtyCalc
{
    Caption = 'OutsandingQtyCalc';
    QueryType = Normal;

    elements
    {
        dataitem(SalesLine; "Sales Line")
        {

            column(No; "No.")
            {
            }
            column(OutstandingQuantity; "Outstanding Quantity")
            {
                Method = sum;
            }

        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
