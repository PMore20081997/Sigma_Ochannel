tableextension 90007 UserSetupExt extends "User Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Allow to Auth. Web Order Price"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}