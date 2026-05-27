page 90066 "Channel Price List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Channel Price";
    // ModifyAllowed = false;
    // DelayedInsert = false;
    // InsertAllowed = false;
    // Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = All;
                }
                field("License Name"; Rec."License Name")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source Group"; Rec."Source Group")
                {
                    ApplicationArea = All;
                }
                field("Asset Type"; Rec."Asset Type")
                {
                    ApplicationArea = All;
                }
                field("Product No."; Rec."Product No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Variant Code Lookup"; Rec."Variant Code Lookup")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code Lookup"; Rec."Unit of Measure Code Lookup")
                {
                    ApplicationArea = All;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Base Volume"; Rec."Base Volume")
                {
                    ApplicationArea = All;
                }
                field("Cost Unit Thereafter"; Rec."Cost Unit Thereafter")
                {
                    ApplicationArea = All;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Listing Status Setting"; Rec."Listing Status Setting")
                {
                    ApplicationArea = All;
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                }
                field("Sync Price"; Rec."Sync Price")
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
            action("Create Channel Price")
            {
                Caption = 'Create channel price';
                ToolTip = 'Create a new channel price and update all existing prices';
                ApplicationArea = All;
                Image = Insert;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    TradePartner: Record "Trade Partner";
                    VarDefaultVeiw: Text;
                    SelectTradePartner: FilterPageBuilder;
                    TradePartner2: Record "Trade Partner";
                    Create_UpdateChannelPrice: Codeunit "Create & Update Channel Price";
                begin
                    if not Confirm('Do you want to create a new channel price and update all existing prices?', false) then
                        exit;

                    TradePartner.Reset();
                    TradePartner.SetRange("Partner Type", TradePartner."Partner Type"::Channel);
                    TradePartner.SetRange(SyncPrice, true);
                    IF TradePartner.FindSet() THEN BEGIN
                        VarDefaultVeiw := TradePartner.GetView();
                        SelectTradePartner.AddTable('Trade Partner', DATABASE::"Trade Partner");
                        SelectTradePartner.SetView('Trade Partner', VarDefaultVeiw);
                        SelectTradePartner.AddField('Trade Partner', TradePartner.Code, '');
                        IF SelectTradePartner.RunModal = true then begin
                        end;
                        TradePartner2.SetView(SelectTradePartner.GetView('Trade Partner'));
                        IF TradePartner2.GetFilter(Code) = '' then
                            exit;
                        IF TradePartner2.FindSet() then begin
                            repeat
                                Create_UpdateChannelPrice.Create_Update_ChannelPrice(TradePartner2.Code);
                            until TradePartner2.Next() = 0;
                        end;
                    end;
                    Message('Process Completed..');
                end;
            }
            action("Update Channel Price")
            {
                Caption = 'Update channel price';
                ToolTip = 'Update price for selected record';
                ApplicationArea = All;
                Image = Create;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    L_ChannelPrice: Record "Channel Price";
                    Create_UpdateChannelPrice: Codeunit "Create & Update Channel Price";
                    Windows: Dialog;
                    ProgressCount: Integer;
                    NoOfRecs: Integer;
                    Count: Integer;
                begin
                    L_ChannelPrice.Reset();
                    CurrPage.SetSelectionFilter(L_ChannelPrice);
                    if L_ChannelPrice.FindSet() then begin
                        Windows.OPEN('Update in progress' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                        NoOfRecs := L_ChannelPrice.Count;
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

                            //Start Update process+++
                            Create_UpdateChannelPrice.Update_ChannelPrice(L_ChannelPrice);
                        until L_ChannelPrice.Next() = 0;
                    end;
                end;
            }

            action("Open Sales Price Lists")
            {
                ApplicationArea = All;
                Image = Navigate;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Open related sales price list';

                trigger OnAction()
                var
                    PriceListHeader: Record "Price List Header";
                    PagePriceLists: Page "Sales Price Lists";
                begin
                    Clear(PagePriceLists);
                    PriceListHeader.SetRange(Code, Rec."Price List Code");
                    PriceListHeader.SetRange("Price Type", PriceListHeader."Price Type"::Sale);
                    PagePriceLists.SetTableView(PriceListHeader);
                    PagePriceLists.Run();
                end;
            }

            group(Integration)
            {
                action("Sync selected price to LifeRay")
                {
                    ApplicationArea = All;
                    Image = Create;
                    ToolTip = 'Sync selected price to LifeRay';

                    trigger OnAction()
                    var
                        SyncProduct_Inventory: Codeunit "Sync Product/Inv./Cust./Price";
                        Windows: Dialog;
                        ProgressCount: Integer;
                        NoOfRecs: Integer;
                        Count: Integer;
                        L_ChannelPrice: Record "Channel Price";
                    begin
                        L_ChannelPrice.Reset();
                        CurrPage.SetSelectionFilter(L_ChannelPrice);
                        L_ChannelPrice.SetRange("Sync Price", false);
                        L_ChannelPrice.SetRange("Channel Code", 'LIFERAY');
                        if L_ChannelPrice.FindSet() then begin
                            Windows.OPEN('Synchronization in progress with Liferay' + ' @1@@@@@@@@@@@@@\' + 'Please Wait..');
                            NoOfRecs := L_ChannelPrice.Count;
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
                                SyncProduct_Inventory.SyncPriceToLiferay(L_ChannelPrice."Price List Code", L_ChannelPrice."Line No.", L_ChannelPrice."Channel Code");
                            until L_ChannelPrice.Next() = 0;
                        end;
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
                        L_CorrelationIDtracking.SetRange("Document Type", L_CorrelationIDtracking."Document Type"::Price);
                        L_CorrelationIDtracking.SetRange("Document No.", Rec."Price List Code");
                        L_CorrelationIDtracking.SetRange("Document Line No.", Rec."Line No.");
                        L_CorrelationIDtracking.SetRange("Channel Code", Rec."Channel Code");
                        L_CorrelationIDtracking.SetFilter("Sync Date", '>=%1', WorkDate());
                        PageLiferayCorrelationIDTrack.SetTableView(L_CorrelationIDtracking);
                        PageLiferayCorrelationIDTrack.Run();
                    end;
                }
                action("Show Error for Price")
                {
                    Image = ErrorLog;
                    ApplicationArea = All;
                    ToolTip = 'Open error list for price';

                    trigger OnAction()
                    var
                        page_LiferayErrorLog: Page "LifeRay Error Logs";
                        Table_LiferayErrorLog: Record "LifeRay Error Log";
                    begin
                        Clear(page_LiferayErrorLog);
                        Table_LiferayErrorLog.SetRange("Document Type", Table_LiferayErrorLog."Document Type"::Price);
                        Table_LiferayErrorLog.SetFilter("Sync Date", '>=%1', WorkDate());
                        Table_LiferayErrorLog.SetRange("Channel Code", Rec."Channel Code");
                        page_LiferayErrorLog.SetTableView(Table_LiferayErrorLog);
                        page_LiferayErrorLog.Run();
                    end;
                }

            }
        }
    }
}