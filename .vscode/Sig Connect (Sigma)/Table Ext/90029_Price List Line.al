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