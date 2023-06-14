tableextension 90096 "Item Variant Ext" extends "Item Variant"
{
    fields
    {
        field(50002; "VAT Prod Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
        }
        field(50003; "Shelf No."; Code[20])
        {

        }
    }
}