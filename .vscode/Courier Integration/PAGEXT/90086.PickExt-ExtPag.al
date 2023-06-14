/*pageextension 90086 "PickExt" extends "Warehouse Pick"
{
    layout
    {
        addafter("Sorting Method")
        {
            field("Shipping Agent Code"; Rec."Shipping Agent Code")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("No. of Boxes"; Rec."No. of Boxes")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("Total weight (consignment)"; Rec."Total weight (consignment)")
            {
                ApplicationArea = all;
                //Visible = false;
            }
            field("SO No."; Rec."SO No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}*/