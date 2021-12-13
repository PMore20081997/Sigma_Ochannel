//CAS-26633-Z8W1Y1.MH

query 90000 "Get ItemQty By BinContent"
{
    QueryType = Normal;

    elements
    {
        dataitem(Bin_Content; "Bin Content")
        {
            column(Item_No_; "Item No.") { }
            column(Variant_Code; "Variant Code") { }
            column(Unit_of_Measure_Code; "Unit of Measure Code") { }
            column(Location_Code; "Location Code") { }
            column(Bin_Code; "Bin Code") { }
            column(Quantity; Quantity) { }
            column(Quantity__Base_; "Quantity (Base)")
            {
                ColumnFilter = Quantity__Base_ = FILTER(<> 0);
                Method = Sum;
            }
            // filter(FilterName; SourceFieldName)
            // {

            // }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}