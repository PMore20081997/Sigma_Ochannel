tableextension 90029 "OC Price List Line" extends "Price List Line"
{
    fields
    {
        // Add changes to table fields here
        field(90029; "Sync Price"; Boolean)
        {

        }
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
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}