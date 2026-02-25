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
                    Editable = false;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("NAV Variant"; Rec."NAV Variant")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    ApplicationArea = All;
                    Caption = 'Variant Id';
                    Editable = false;
                    Visible = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Pack Size"; Rec."Pack Size")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Inventory"; Rec."Channel Inventory")
                {
                    ApplicationArea = All;
                    Caption = 'Free';
                    Editable = false;
                    ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
                    DecimalPlaces = 0 : 5;
                }
                field("Physical Inventory"; Rec."Physical Inventory")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Physical';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Quantity in saleable locations where the priority exists.';
                }
                field("Allcoated on SO"; Rec."Allcoated on SO")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Allocated on SO.';
                    ToolTip = 'Sum of outstanding SO quantity of saleable locations.';
                    DecimalPlaces = 0 : 5;
                }
                field("Web Orders Qty"; Rec."Web Orders Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Sucessfull Electronic Orders.';
                    DecimalPlaces = 0 : 5;
                }
                field(RRP; Rec.RRP)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    ToolTip = 'Status to show if the Item is Listed in the Portal or not';
                }
                field("Item Sync"; Rec."Item Sync")
                {
                    ApplicationArea = All;
                }
                field("Inventory Synced"; Rec."Inventory Synced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Acknowledgment from Portal that Inventory has synced on their side';
                }
                field("Sales Blocked"; Rec."Sales Blocked")
                {
                    ApplicationArea = All;
                }
                field("Ops Sales Blocked"; Rec."Ops Sales Blocked")
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variant Code Mandatory"; Rec."Variant Code Mandatory")
                {
                    ApplicationArea = All;
                    Editable = false;
                    //Dont remove this field from page because it is used in "Physical" field calculation!!!!!++++
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
                    PhysicalInventory: Decimal;
                    QtyOnSO: Decimal;
                    QtyonWebOrder: Decimal;
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;

                    L_SalesLine: Record "Sales Line";
                    L_ItemLedgerEntry: Record "Item Ledger Entry";
                    L_BinContent: Record "Bin Content";
                    L_ExcludeQty: Decimal;
                    L_warehouseActivityLine: Record "Warehouse Activity Line";
                    _QtyonPick: Decimal;
                begin
                    Clear(QtyOnSO);
                    Clear(QtyonWebOrder);
                    Clear(AvailableInventory);
                    Clear(PhysicalInventory);

                    Windows.OPEN('Update Inventory..' + ' @1@@@@@@@@@@@@@\' + 'Updating..' + ' #3##########' + 'Please Wait..');
                    ChannelItemListing.Reset();
                    ChannelItemListing.SetFilter("Item No.", '<>%1', '');
                    ChannelItemListing.SetRange("Listing Status", ChannelItemListing."Listing Status"::Listed);
                    ChannelItemListing.SetRange(Status, ChannelItemListing.Status::Active);
                    //ChannelItemListing.SetFilter("Date Filter", '>=%1', WorkDate());
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
                                ChannelItemListing.CalcFields("Web Orders Qty", "Variant Code Mandatory");
                                if ChannelItemListing."Item Category Code" <> L_Item."Item Category Code" then
                                    ChannelItemListing."Item Category Code" := L_Item."Item Category Code";

                                //Calculate Physical+++
                                Clear(PhysicalInventory);
                                //PhysicalInventory := ChannelItemListing."Physical Inventory";
                                L_ItemLedgerEntry.Reset();
                                L_ItemLedgerEntry.SetRange("Item No.", ChannelItemListing."Item No.");
                                L_ItemLedgerEntry.SetRange("Saleable Location", true);
                                L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(ChannelItemListing."Item No."));
                                L_ItemLedgerEntry.CalcSums(Quantity);
                                PhysicalInventory := L_ItemLedgerEntry.Quantity;
                                if PhysicalInventory < 0 then
                                    PhysicalInventory := 0;


                                //Calculate "Qty On SO"++++
                                Clear(QtyOnSO);
                                L_SalesLine.Reset();
                                L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                                L_SalesLine.SetRange("No.", ChannelItemListing."Item No.");
                                L_SalesLine.SetRange("Saleable Location", true);
                                L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                                L_SalesLine.CalcSums("Outstanding Qty. (Base)");
                                QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
                                if QtyOnSO < 0 then
                                    QtyOnSO := 0;

                                //Qty on Pick ++ SBB-579
                                Clear(_QtyonPick);
                                L_warehouseActivityLine.Reset();
                                L_warehouseActivityLine.SetRange("Source Document", L_warehouseActivityLine."Source Document"::"Sales Order");
                                L_warehouseActivityLine.SetRange("Item No.", ChannelItemListing."Item No.");
                                L_warehouseActivityLine.SetRange("Saleable Location", true);
                                L_warehouseActivityLine.SetFilter("Shipment Date", '<%1', WorkDate());
                                if L_warehouseActivityLine.FindSet() then begin
                                    L_warehouseActivityLine.CalcSums("Qty. Outstanding (Base)");
                                    _QtyonPick := L_warehouseActivityLine."Qty. Outstanding (Base)";
                                end;
                                if _QtyonPick < 0 then
                                    _QtyonPick := 0;


                                //Get Web Order Qty+++
                                Clear(QtyonWebOrder);
                                QtyonWebOrder := ChannelItemListing."Web Orders Qty";
                                if QtyonWebOrder < 0 then
                                    QtyonWebOrder := 0;

                                //Prathamesh++ SBB-291
                                Clear(L_ExcludeQty);
                                L_BinContent.Reset();
                                L_BinContent.SetRange("Item No.", ChannelItemListing."Item No.");
                                L_BinContent.SetRange("Saleable Location", true);
                                L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
                                L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
                                L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(ChannelItemListing."Item No."));
                                if L_BinContent.FindSet() then begin
                                    repeat
                                        L_BinContent.CalcFields("Quantity (Base)");
                                        L_ExcludeQty += L_BinContent."Quantity (Base)";
                                    until L_BinContent.Next() = 0;
                                end;
                                if L_ExcludeQty < 0 then
                                    L_ExcludeQty := 0;

                                //Calculate Available Qty +++
                                Clear(AvailableInventory);
                                AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder + L_ExcludeQty + _QtyonPick);
                                if AvailableInventory < 0 then
                                    AvailableInventory := 0;

                                if AvailableInventory <> ChannelItemListing."Channel Inventory" then begin
                                    if AvailableInventory > 0 then
                                        ChannelItemListing.Validate("Channel Inventory", AvailableInventory)
                                    else
                                        ChannelItemListing.Validate("Channel Inventory", 0);
                                    ChannelItemListing."Inventory Synced" := false;
                                    ChannelItemListing."Modified On" := CurrentDateTime;
                                end;
                                ChannelItemListing."Sales Blocked" := L_Item."Sales Blocked";
                                ChannelItemListing."Ops Sales Blocked" := L_Item."Ops Sales Blocked";
                            end else begin
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

    local procedure GetVariantSetup(_ItemNo: Code[20]): Boolean
    var
        L_ItemVariant: Record "Item Variant";
        L_Item: Record Item;
    begin
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            if L_Item."Variant Mandatory if Exists" <> L_Item."Variant Mandatory if Exists"::No then begin
                if L_Item."Variant Mandatory if Exists" = L_Item."Variant Mandatory if Exists"::Yes then
                    exit(true)
                else begin
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", _ItemNo);
                    if L_ItemVariant.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            end else
                exit(false);
        end;
    end;
}