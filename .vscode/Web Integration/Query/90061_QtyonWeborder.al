query 90061 QuantityonWebOrder
{
    QueryType = Normal;
    
    elements
    {
        dataitem(InterimSalesLine; "Interim Sales Line")
        {
            DataItemTableFilter =  "Document Type" = filter(Order), Type = const(Item);
            column(No_;"No.")
            {

            }
            column(NAV_Variant_code; "NAV Variant code")
            {
                
            }
            column(Quantity; Quantity)
            {
             Method = sum;   
            }
        }    
    }
    
    var
        myInt: Integer;
    
    trigger OnBeforeOpen()
    begin
        
    end;
}