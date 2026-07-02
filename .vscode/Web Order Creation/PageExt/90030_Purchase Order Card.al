pageextension 90030 PurchaseOrderCardExt extends "Purchase Order"
{
    layout
    {
        modify("Your Reference")
        {
            ShowMandatory = true;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}