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
                trigger OnValidate()
                var
                    CIL: Record "Channel Item Listing";
                begin
                    CIL.Reset();
                    CIL.SetFilter("Item No.", '<>%1', '');
                    CIL.SetRange("Item No.", Rec."No.");
                    if CIL.FindFirst() then begin
                        CIL."Inventory Synced" := false;
                        CIL.Modify();
                    end;
                end;
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