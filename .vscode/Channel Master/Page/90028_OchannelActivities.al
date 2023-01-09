#pragma implicitwith disable
page 90028 "Ochannel Activities"
{
    Caption = 'Ochannel Activites';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";
    Permissions = tabledata "Sales Cue" = rm;


    layout
    {
        area(Content)
        {
            cuegroup("")
            {
                Caption = '';
                field("Orders Received Today"; Rec."Orders Received Today")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Web Order List";
                    Image = none;


                }
                field("Released for Pick Today"; Rec."Released for Pick Today")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Whse. Internal Pick List";
                    Image = none;


                }
                field("In Pick Today"; Rec."In Pick Today")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Warehouse Picks";
                    Image = none;

                }
                field("Picked Today"; Rec."Picked Today")
                {

                    ApplicationArea = All;
                    DrillDownPageId = "Registered Whse. Picks";
                    Image = none;

                }
                field("Shipments Today"; Rec."Shipments Today")
                {

                    ApplicationArea = All;
                    DrillDownPageId = "Handled Web Order List";
                    Image = none;

                }
                field("Returns Today"; Rec."Returns Today")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Sales Return Order List";
                    Image = none;

                }
                field("Total Outstanding"; Rec."Total Outstanding")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Web Order List";
                    Image = none;

                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec."Channel Date Filter" := WorkDate();
        Rec.Modify();
    end;


}
#pragma implicitwith restore
