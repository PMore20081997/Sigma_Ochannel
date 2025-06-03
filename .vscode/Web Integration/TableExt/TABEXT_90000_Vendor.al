tableextension 90000 VendorExt extends Vendor
{
    fields
    {
        field(90000; "EDI Invoice/Credit"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'EDI Customer/Vendor';
        }
    }
}