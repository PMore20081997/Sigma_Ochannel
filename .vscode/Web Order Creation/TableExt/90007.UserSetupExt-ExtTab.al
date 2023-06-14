tableextension 90007 "UserSetupExt" extends "User Setup"
{
    fields
    {
        // Add changes to table fields here
        field(50000; "Allow to Auth. Web Order Price"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90000; "Allow Edit Qty. to ship"; Boolean)
        {
            Caption = 'Edit Qty. to ship';
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}