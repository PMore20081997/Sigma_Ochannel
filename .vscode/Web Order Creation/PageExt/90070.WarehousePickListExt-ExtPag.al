pageextension 90070 "Warehouse Pick List Ext" extends "Warehouse Picks"
{
    layout
    {
        addafter("External Document No.")
        {
            field(Comments; Rec.Comments)
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Code"; Rec."Shipping Agent Code")
            {
                ApplicationArea = All;
            }
            field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
            {
                ApplicationArea = All;
            }
            field("No. of Take lines"; Rec."No. of Take lines")
            {
                ApplicationArea = All;
            }
        }
        addafter("No. of Lines")
        {
            field("Total Outstanding Qty"; Rec."Total Outstanding Qty")
            {
                ApplicationArea = All;
            }
        }
    }

}