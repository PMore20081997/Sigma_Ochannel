pageextension 90020 "OC Posted Sales Invoice Card" extends "Posted Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Web Order"; Rec."Web Order")
            {
                ApplicationArea = All;
                Editable = false;
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