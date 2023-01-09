query 90091 "Get Order item Amount"
{
    QueryType = Normal;
    
    elements
    {
        dataitem(Interim_Sales_Line; "Interim Sales Line")
        {
            DataItemTableFilter = Type = filter(Item);
            column(Document_Type; "Document Type")
            {
                
            }
            column(Document_No; "Document No")
            {
                
            }
            column(Amount_Including_VAT; "Amount Including VAT")
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