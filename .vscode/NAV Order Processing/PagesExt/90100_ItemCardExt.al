pageextension 90100 ItemCardExt extends "Item Card"
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
            field("W/H Inventory"; Rec."W/H Inventory")
            {
                DecimalPlaces = 0;
                Caption = 'Available Inventory';
                ApplicationArea = All;
            }
            field("Qty. on Web Order"; Rec."Qty. on Web Order")
            {
                ApplicationArea = All;
            }
        }
        addafter("Vendor No.")
        {
            field("Vendor Name"; Rec."Vendor Name")
            {
                ApplicationArea = All;
            }
        }
    }
}