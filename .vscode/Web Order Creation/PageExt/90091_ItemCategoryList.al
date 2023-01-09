pageextension 90091 "Ext Item Cat List" extends "Item Categories"
{
    layout
    {
        addafter(Description)
        {
            field("Auto Assembly Order"; Rec."Auto Assembly Order")
            {
                ApplicationArea = All;
            }
        }
    }
}