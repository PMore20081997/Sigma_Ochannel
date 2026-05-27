page 90011 "Channel Item Listing"
{
    Caption = 'Channel Item Listing';
    UsageCategory = Lists;
    PageType = List;
    SourceTable = "Channel Item Listing";
    RefreshOnActivate = true;
    ApplicationArea = All;
    InsertAllowed = false;
    SourceTableView = SORTING("Channel Code", "Channel SKU", "ASIN No") ORDER(Ascending);

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("ASIN No"; Rec."ASIN No")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'ASIN/Unique ID', ENG = 'ASIN/Unique ID';
                    Editable = false;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'BC Item No', ENG = 'BC Item No';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Item Description';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Item Category Code';
                }
                field("Pack Size"; Rec."Pack Size")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Pack Size';
                }
                field("Lowstock Threshold"; Rec."Lowstock Threshold")
                {
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
                field("Min Sell Price"; Rec."Min Sell Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Blocked"; Rec."Sales Blocked")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ops Sales Blocked"; Rec."Ops Sales Blocked")
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
                    Editable = false;
                }
                field("Item Sync"; Rec."Item Sync")
                {
                    ApplicationArea = All;
                    //Editable = false;
                }
                field("Inventory Synced"; Rec."Inventory Synced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Acknowledgment from Portal that Inventory has synced on their side';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Created Date Time';
                }
                field(SystemCreatedBy; GetUserName(Rec.SystemCreatedBy))
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Created By';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Modified Date Time';
                }
                field(SystemModifiedBy; GetUserName(Rec.SystemModifiedBy))
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Modified By';
                }
                field("Item SystemModifiedAt"; Rec."Item SystemModifiedAt")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Item(Master) Modified Date Time';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Open Item Card")
            {
                ApplicationArea = All;
                Caption = 'Open Item Card';
                ToolTip = 'Open Item Card for selected line';
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

            action("Update Channel Item Listing")
            {
                ApplicationArea = All;
                Caption = 'Update Channel Item Listing for selected line';
                ToolTip = 'Update Channel Item Listing for selected line';
                Image = UpdateDescription;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    L_ChannelItemListing: Record "Channel Item Listing";
                    UpdateChannelItemListing: Codeunit "Update Channel Item Listing";
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;
                begin
                    L_ChannelItemListing.Reset();
                    CurrPage.SetSelectionFilter(L_ChannelItemListing);
                    if L_ChannelItemListing.FindSet() then begin
                        Windows.OPEN('Updating...' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                        NoOfRecs := L_ChannelItemListing.Count;
                        repeat
                            ProgressCount += 1;
                            if NoOfRecs > 0 then begin
                                if NoOfRecs <= 100 then begin
                                    Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                end else begin
                                    IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                    END;
                                end;
                            end;

                            //Start Process++
                            UpdateChannelItemListing.UpdateChannelItemListing(L_ChannelItemListing."Channel Code", L_ChannelItemListing."Item No.");
                        until L_ChannelItemListing.Next() = 0;
                    end;
                end;
            }


            group("LifeRay Integration")
            {
                action("Item Refrence Details")
                {
                    ApplicationArea = All;
                    Caption = 'Item Refrence Details';
                    ToolTip = 'Open Item Reference List';
                    Image = ItemVariant;
                    trigger OnAction()
                    var
                        Page_ItemReferenceList: Page "Channel Item Reference List";
                        Table_ItemReference: Record "Item Reference";
                    begin
                        Clear(Page_ItemReferenceList);
                        Table_ItemReference.Reset();
                        Table_ItemReference.SetRange("Item No.", Rec."Item No.");
                        Table_ItemReference.SetRange("Reference Type", Table_ItemReference."Reference Type"::"PIP Code");
                        Page_ItemReferenceList.SetTableView(Table_ItemReference);
                        Page_ItemReferenceList.Run();
                    end;

                }
                action("Item Variant Details")
                {
                    ApplicationArea = All;
                    Caption = 'Item Variant Details';
                    ToolTip = 'Open Item Variant List';
                    Image = ItemVariant;
                    trigger OnAction()
                    var
                        Page_ItemVariantList: Page "Channel Item Variant List";
                        Table_ItemVariant: Record "Item Variant";
                    begin
                        Clear(Page_ItemVariantList);
                        Table_ItemVariant.Reset();
                        Table_ItemVariant.SetRange("Item No.", Rec."Item No.");
                        Page_ItemVariantList.SetTableView(Table_ItemVariant);
                        Page_ItemVariantList.Run();
                        ;
                    end;

                }
                action("Create Full-Invenory in BC")
                {
                    ApplicationArea = All;
                    Caption = 'Create Full-Inventory in BC';
                    ToolTip = 'Create Full-Inventory in BC.';
                    Image = Create;
                    trigger OnAction()
                    var
                        CreateFull_DetlaInventoryForLifeRay: Codeunit "Create/Update Inv. for LifeRay";
                        L_ChannelItemListing: Record "Channel Item Listing";
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                    begin
                        L_ChannelItemListing.Reset();
                        CurrPage.SetSelectionFilter(L_ChannelItemListing);
                        L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                        if L_ChannelItemListing.FindSet() then begin
                            Windows.OPEN('Synchronization in progress with Liferay' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := L_ChannelItemListing.Count;
                            repeat
                                ProgressCount += 1;
                                if NoOfRecs > 0 then begin
                                    if NoOfRecs <= 100 then begin
                                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                    end else begin
                                        IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                            Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                        END;
                                    end;
                                end;

                                //Process to create Full-Inventory (SameDay)
                                CreateFull_DetlaInventoryForLifeRay.Full_CreateUpdateInventoryforLifeRay(Rec."Item No.", L_ChannelItemListing."Channel Code");
                            until L_ChannelItemListing.Next() = 0;
                        end;
                    end;

                }
                action("Inventory List")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory List';
                    ToolTip = 'Open the inventory list for selcted items (>=WorkDate)';
                    Image = Inventory;
                    trigger OnAction()
                    var
                        Page_LiferayStock: Page "LifeRay Stock List";
                        Table_LiferayStock: Record "LifeRay Stock";
                    begin
                        Clear(Page_LiferayStock);
                        Table_LiferayStock.Reset();
                        Table_LiferayStock.SetRange("Item No.", Rec."Item No.");
                        Table_LiferayStock.SetFilter("Created On", '>=%1', WorkDate());
                        Page_LiferayStock.SetTableView(Table_LiferayStock);
                        Page_LiferayStock.Run();
                    end;
                }
                action("Sync Product to LifeRay")
                {
                    ApplicationArea = All;
                    Image = Create;
                    ToolTip = 'Sync Product to LifeRay';
                    trigger OnAction()
                    var
                        SyncProduct_Inventory: Codeunit "Sync Product/Inv./Cust./Price";
                        L_ChannelItemListing: Record "Channel Item Listing";
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                    begin
                        L_ChannelItemListing.Reset();
                        CurrPage.SetSelectionFilter(L_ChannelItemListing);
                        L_ChannelItemListing.SetRange("Item Sync", false);
                        L_ChannelItemListing.SetRange("Channel Code", 'LIFERAY');
                        if L_ChannelItemListing.FindSet() then begin
                            Windows.OPEN('Synchronization in progress with Liferay' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := L_ChannelItemListing.Count;
                            repeat
                                ProgressCount += 1;
                                if NoOfRecs > 0 then begin
                                    if NoOfRecs <= 100 then begin
                                        Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                    end else begin
                                        IF Count MOD (NoOfRecs DIV 100) = 0 THEN BEGIN
                                            Windows.UPDATE(1, (ProgressCount / NoOfRecs * 10000) DIV 1)
                                        END;
                                    end;
                                end;

                                //Start syncing process+++
                                SyncProduct_Inventory.SyncProductToLiferay(L_ChannelItemListing."Item No.", L_ChannelItemListing."Channel Code");
                            until L_ChannelItemListing.Next() = 0;
                        end else
                            MESSAGE('No Customer to sync for selected record(s).');
                    end;
                }
                action("Corralation-ID Tracking")
                {
                    ApplicationArea = all;
                    Image = Navigate;
                    ToolTip = 'Open Corralation-ID Tracking page for selected line (SyncDate >= WorkDate)';
                    trigger OnAction()
                    var
                        L_CorrelationIDtracking: Record "correlation-id Tracking";
                        PageLiferayCorrelationIDTrack: Page "Liferay Correlation ID Track";
                    begin
                        Clear(PageLiferayCorrelationIDTrack);
                        L_CorrelationIDtracking.Reset();
                        L_CorrelationIDtracking.SetRange("Document Type", L_CorrelationIDtracking."Document Type"::Product);
                        L_CorrelationIDtracking.SetRange("Document No.", Rec."Item No.");
                        L_CorrelationIDtracking.SetRange("Channel Code", Rec."Channel Code");
                        L_CorrelationIDtracking.SetFilter("Sync Date", '>=%1', WorkDate());
                        PageLiferayCorrelationIDTrack.SetTableView(L_CorrelationIDtracking);
                        PageLiferayCorrelationIDTrack.Run();
                    end;
                }

                action("Show Error for Product")
                {
                    Image = ErrorLog;
                    ApplicationArea = All;
                    ToolTip = 'Open Error List for Product';

                    trigger OnAction()
                    var
                        page_LiferayErrorLog: Page "LifeRay Error Logs";
                        Table_LiferayErrorLog: Record "LifeRay Error Log";
                    begin
                        Clear(page_LiferayErrorLog);
                        Table_LiferayErrorLog.SetRange("Document Type", Table_LiferayErrorLog."Document Type"::Product);
                        Table_LiferayErrorLog.SetFilter("Sync Date", '>=%1', WorkDate());
                        Table_LiferayErrorLog.SetRange("Channel Code", Rec."Channel Code");
                        page_LiferayErrorLog.SetTableView(Table_LiferayErrorLog);
                        page_LiferayErrorLog.Run();
                    end;
                }
            }

            group("Sigconnect Integration")
            {
                action(ChannelInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Update Channel Inventory For Sigconnect';
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
                        ChannelItemListing.SetRange("Channel Code", 'SIGCONNECT');
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
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Work Date Filter", WorkDate());
    end;

    procedure GetUserName(UserSecurityId: Code[50]): Text[100]
    var
        Users: Record User;
    begin
        Users.Reset();
        Users.SetRange("User Security ID", UserSecurityId);
        if Users.FindFirst() then
            exit(Users."User Name");
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