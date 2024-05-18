tableextension 90029 "OC Price List Line" extends "Price List Line"
{
    fields
    {
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Unit Price" <> xRec."Unit Price" then begin
                    Rec."Sync Price" := false;
                    Rec.Modify();
                end;
            end;
        }
        field(90000; "Listing Status Setting"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
        }
        field(90001; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(90002; "Sync Price"; Boolean)
        {

        }
    }
}