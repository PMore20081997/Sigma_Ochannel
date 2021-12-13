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
    }

    var
        myInt: Integer;
}