pageextension 90091 ItemCardExt extends "Item Card"
{
    layout
    {
        addafter(Inventory)
        {
            field("Production Item"; Rec."Production Item")
            {
                ApplicationArea = all;
                CaptionML = ENU = 'Production Item', ENG = 'Production Item';
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