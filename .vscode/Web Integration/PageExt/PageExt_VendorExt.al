pageextension 90005 VendorCardExt extends "Vendor Card"
{
    layout
    {
        addafter(Blocked)
        {
            field("EDI Invoice/Credit"; rec."EDI Invoice/Credit")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}