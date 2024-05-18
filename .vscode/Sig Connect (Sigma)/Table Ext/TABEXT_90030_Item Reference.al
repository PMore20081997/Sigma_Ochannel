tableextension 90030 "OC Item Reference" extends "Item Reference"
{
    fields
    {
        field(90000; "Listing Status Setting"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
            trigger OnValidate()
            var
            begin
                if Rec."Listing Status Setting" = Rec."Listing Status Setting"::Inactive then
                    Rec.Synced := false
                else
                    Rec.Synced := true;
            end;
        }
        field(90001; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(90002; Synced; Boolean)
        {

        }
    }
}