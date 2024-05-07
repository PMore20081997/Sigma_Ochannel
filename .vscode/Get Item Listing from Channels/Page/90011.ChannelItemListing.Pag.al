page 90011 "Channel Item Listing"
{
    Editable = true;
    CaptionML = ENU = 'Channel Item Listing';
    UsageCategory = Lists;
    SourceTable = "Channel Item Listing";
    SourceTableView = SORTING("Channel Code", "Channel SKU", "ASIN No") ORDER(Ascending);
    PageType = List;
    RefreshOnActivate = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("ASIN No"; Rec."ASIN No")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'ASIN/Unique ID', ENG = 'ASIN/Unique ID';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Nav Item No', ENG = 'Nav Item No';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("NAV Variant"; Rec."NAV Variant")
                {
                    ApplicationArea = All;
                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    ApplicationArea = All;
                    Caption = 'Variant Id';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Pack Size"; Rec."Pack Size")
                {
                    ApplicationArea = All;
                }
                field("Channel Inventory"; Rec."Channel Inventory")
                {
                    ApplicationArea = All;
                    Caption = 'Free Qty';
                }
                field("Physical Inventory"; Rec."Physical Inventory")
                {
                    ApplicationArea = All;
                }
                field("Allcoated on SO"; Rec."Allcoated on SO")
                {
                    ApplicationArea = All;
                }
                field("Web Orders Qty"; Rec."Web Orders Qty")
                {
                    ApplicationArea = All;
                }
                field(RRP; Rec.RRP)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Listing Status Setting';
                    ToolTip = 'This is a user-editable field to enable/disable BC items in the portal';
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status to show if the Item is Listed in the Portal';
                }
                field("Inventory Synced"; Rec."Inventory Synced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Acknowledgment from Portal that Inventory has synced on their side';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ChannelInventory)
            {
                ApplicationArea = All;
                Caption = 'Update Channel Inventory';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = CalculateInventory;

                trigger OnAction()
                var
                    L_Item: Record Item;
                    AvailableInventory: Decimal;
                    ChannelItemListing: Record "Channel Item Listing";
                    L_ItemLedgerEntry: Record "Item Ledger Entry";
                    PhysicalInventory: Decimal;
                    L_SalesLine: Record "Sales Line";
                    QtyOnSO: Decimal;
                    Query_QtyonWebOrder: Query "Qty on Web";
                    QtyonWebOrder: Decimal;
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;
                begin
                    Windows.OPEN('Update Inventory..' + ' @1@@@@@@@@@@@@@\' + 'Updating..' + ' #3##########' + 'Please Wait..');
                    ChannelItemListing.Reset();
                    ChannelItemListing.SetFilter("Item No.", '<>%1', '');
                    ChannelItemListing.SetRange("Listing Status", ChannelItemListing."Listing Status"::Listed);
                    ChannelItemListing.SetRange(Status, ChannelItemListing.Status::Active);
                    if ChannelItemListing.FindSet() then begin
                        repeat
                            NoOfRecs := ChannelItemListing.Count;
                            ProgressCount += 1;
                            IF NoOfRecs <= 100 THEN
                                Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                            ELSE
                                IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                END;
                            Windows.UPDATE(3, ChannelItemListing."Channel SKU");

                            Clear(L_Item);
                            if L_Item.Get(ChannelItemListing."Item No.") then begin
                                ChannelItemListing.CalcFields("Physical Inventory", "Allcoated on SO", "Web Orders Qty");
                                Clear(AvailableInventory);
                                AvailableInventory := ChannelItemListing."Physical Inventory" - (ChannelItemListing."Allcoated on SO" + ChannelItemListing."Web Orders Qty");

                                if AvailableInventory <> ChannelItemListing."Channel Inventory" then begin
                                    if AvailableInventory > 0 then begin
                                        ChannelItemListing.Validate("Channel Inventory", AvailableInventory);
                                    end
                                    else begin
                                        ChannelItemListing.Validate("Channel Inventory", 0);
                                    end;
                                    ChannelItemListing."Inventory Synced" := false;
                                    ChannelItemListing."Modified On" := CurrentDateTime;
                                end;
                            end
                            else begin
                                ChannelItemListing.Remarks := 'Item Not Found ' + ChannelItemListing."Item No.";
                                ChannelItemListing."Modified On" := CurrentDateTime;
                            end;

                            ChannelItemListing.Modify(true);
                            Commit();
                        Until ChannelItemListing.Next = 0;
                    end;
                    Message('Success');
                end;
            }

            action("Auto Coupling")
            {
                ApplicationArea = All;
                CaptionML = ENU = '&Auto Couple', ENG = 'Auto Coupling';
                Image = CoupledOrderList;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                VAR
                begin
                    Rec.UpdateItemNo;
                end;
            }

            action(Card)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Item Card', ENG = 'Item Card';
                Image = Item;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    ItemCard: Page 30;
                    Item: Record 27;
                begin
                    Item.RESET;
                    Item.SETRANGE("No.", Rec."Item No.");
                    IF Item.FINDFIRST THEN BEGIN
                        ItemCard.SETRECORD(Item);
                        ItemCard.RUN;
                    END ELSE
                        ERROR('Please couple item with NAV item master.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    end;
}