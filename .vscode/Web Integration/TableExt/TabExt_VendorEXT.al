tableextension 90000 VendorExt extends Vendor
{
    fields
    {
        field(90001; "EDI Invoice/Credit"; Boolean)
        {
            DataClassification = ToBeClassified;
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