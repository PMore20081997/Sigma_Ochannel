page 90013 "Channel Item Listing Service"
{
    Editable = true;
    //CaptionML = ENU = 'Channel Item Listing';
    UsageCategory = Lists;
    SourceTable = "Channel Item Listing";
    //SourceTableView = SORTING("Channel Code", "Channel SKU", "ASIN No")
    //ORDER(Ascending);
    PageType = List;
    RefreshOnActivate = true;
    ApplicationArea = All;


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
                field("Item No."; REC."Item No.")
                {
                    ApplicationArea = ALL;
                }
                field("Channel Variant"; rec."Channel Variant")
                {
                    ApplicationArea = ALL;
                }
                field(Description; rec.Description)
                {
                    ApplicationArea = ALL;
                }
                field("Pack Size"; rec."Pack Size")
                {
                    ApplicationArea = all;
                }
                field("Trade Price"; rec."Unit Price")
                {
                    ApplicationArea = ALL;
                    Caption = 'Trade Price';
                }
                field("BC Inventory"; rec."Channel Inventory")
                {
                    ApplicationArea = ALL;
                    Caption = 'BC Inventory';
                }
                field("Item Category Code"; rec."Item Category Code")
                {
                    ApplicationArea = ALL;
                }
                field("Inventory Synced"; rec."Inventory Synced")
                {
                    ApplicationArea = ALL;
                }


            }
        }
    }
}