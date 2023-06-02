pageextension 90016 ItemReferenceExt extends "Item References"
{
    layout
    {
        addafter("Item No.")
        {
            field("Offer SKU"; Rec."Offer SKU")
            {
                ApplicationArea = All;
            }

        }

    }

}
