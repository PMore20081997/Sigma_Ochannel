query 90076 "Validate Interim Sales Return"
{
    QueryType = Normal;
    
    elements
    {
        dataitem(Interim_Sales_Return; "Interim Sales Return")
        {
            column(Web_Order_No; "Web Order No.")
            {
                
            }
            column(Item_No; "Item No.")
            {
                
            }
            column(Variant_Code; "Variant Code")
            {
    
            }
            column(Quantity_to_Return; "Quantity to Return")
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