page 90013 "Channel Item Listing Service"
{
    Editable = true;
    UsageCategory = Lists;
    SourceTable = "Channel Item Listing";
    PageType = List;
    RefreshOnActivate = true;
    ApplicationArea = All;
    SourceTableView = where("Channel Code" = filter('SIGCONNECT'));


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Channel Code"; rec."Channel Code")
                {
                    ApplicationArea = ALL;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("ASIN No"; Rec."ASIN No")
                {
                    ApplicationArea = All;
                }
                field("Listing Status Setting"; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                }
                field("Item Sync"; Rec."Item Sync")
                {
                    ApplicationArea = All;
                }
                field("BC Item No."; Rec."Item No.")
                {
                    ApplicationArea = ALL;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = ALL;
                }
                field("BC Variant Code"; Rec."NAV Variant")
                {
                    ApplicationArea = ALL;
                }
                field(RRP; Rec.RRP)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Item Category Code"; rec."Item Category Code")
                {
                    ApplicationArea = ALL;
                }
                field("Pack Size"; rec."Pack Size")
                {
                    ApplicationArea = all;
                }
                field("Free Qty"; rec."Channel Inventory")
                {
                    ApplicationArea = ALL;
                }
                field("Inventory Synced"; Rec."Inventory Synced")
                {
                    ApplicationArea = ALL;
                }
                field("Sales Blocked"; Rec."Sales Blocked")
                {
                    ApplicationArea = All;
                }
                field("Ops Sales Blocked"; Rec."Ops Sales Blocked")
                {
                    ApplicationArea = All;
                }
                field("Last Modified By"; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                }
                field("Last Modified At"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}