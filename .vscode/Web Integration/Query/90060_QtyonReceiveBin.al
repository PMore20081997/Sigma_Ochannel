query 90060 QuantityOnBin
{
    QueryType = Normal;
    
    elements
    {
        dataitem(WarehouseEntry; "Warehouse Entry")
        {
            column(Item_No; "Item No.")
            {
                
            }
            column(Location_Code; "Location Code")
            {
                
            }
            column(Variant_Code; "Variant Code")
            {
                
            }
            column(Bin_Code; "Bin Code")
            {
                
            }
            column(Quantity; Quantity)
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