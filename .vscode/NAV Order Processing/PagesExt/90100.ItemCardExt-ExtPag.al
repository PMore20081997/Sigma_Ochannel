pageextension 90100 "ItemCardExt" extends "Item Card"
{
    layout
    {
        addafter(Inventory)
        {

            field("W/H Inventory"; Rec."W/H Inventory")
            {
                DecimalPlaces = 0;
                Caption = 'Available Inventory';
                ApplicationArea = All;
            }
            field("Qty. on Web Order"; Rec."Qty. on Web Order")
            {
                ApplicationArea = All;
            }
        }
        addafter("Vendor No.")
        {
            field("Vendor Name"; Rec."Vendor Name")
            {
                ApplicationArea = All;
            }
        }
    }
}