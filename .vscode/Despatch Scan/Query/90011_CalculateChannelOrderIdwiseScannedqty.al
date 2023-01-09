query 90011 "Chan Ord id wise Scanned Qty"
  
{
    Caption = 'Channel Order id wise Scanned Qty';
    QueryType = Normal;
    
    elements
    {
        dataitem(Despatch_Scan_Line; "Despatch Scan Line")
        {
            column(ChannelOrderId; "Channel Order Id")
            {
                
            }
            column(ScannedQuantity; "Scanned Quantity")
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