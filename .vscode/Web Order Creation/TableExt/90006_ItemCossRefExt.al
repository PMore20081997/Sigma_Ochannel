tableextension 90006 ItemCrossRefExt extends "Item Reference"
{
    fields
    {
        field(50000; "Block Customer Cross Reference"; Boolean)
        {
            DataClassification = ToBeClassified;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not in use';
        }

        field(50001; "Offer SKU";CODE[20])
        {
            DataClassification = ToBeClassified;
            
        }
    }

    var
        myInt: Integer;
}