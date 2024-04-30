page 90011 "Channel Item Listing"
{
    Editable = true;
    CaptionML = ENU = 'Channel Item Listing';
    UsageCategory = Lists;
    SourceTable = "Channel Item Listing";
    SourceTableView = SORTING("Channel Code", "Channel SKU", "ASIN No")
     ORDER(Ascending);
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
                    CaptionML = ENU = 'ASIN/Unique ID',
                           ENG = 'ASIN/Unique ID';
                    Visible = false;

                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Nav Item No',
                           ENG = 'Nav Item No';

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Visible = true;

                }
                field("NAV Variant"; Rec."NAV Variant")
                {
                    ApplicationArea = All;
                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    ApplicationArea = All;
                    //Visible = false;
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
                field("Channel Title"; Rec."Channel Title")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Channel Description"; Rec."Channel Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Channel Inventory"; Rec."Channel Inventory")
                {
                    ApplicationArea = All;
                    Caption = 'BC Inventory';
                    trigger OnValidate()
                    var
                        ItemInv: Record Item;
                    begin

                        IF xRec."Channel Inventory" <> Rec."Channel Inventory" THEN
                            Rec.VALIDATE("Inventory Synced", FALSE);

                    end;

                }

                field("Original Inventory"; Rec."Original Inventory")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(UOM; Rec."Unit of Measure code")
                {
                    Caption = 'Unit of Measure';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(RRP; Rec.RRP)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Image Url 1"; Rec."Image Url 1")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Special Price"; Rec."Special Price")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Special Price Start Date"; Rec."Special Price Start Date")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Special Price End Date"; Rec."Special Price End Date")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;

                }
                field(Action; Rec.Action)
                {
                    ApplicationArea = All;

                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;

                }
                field("Price Synced"; Rec."Price Synced")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(SpecialPriceSynced; Rec.SPecialPriceSynced)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Inventory Synced"; Rec."Inventory Synced")
                {
                    ApplicationArea = All;

                }
                field("Listing Date"; Rec."Listing Date")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    Visible = false;

                }

                field(Manufacturer; Rec.Manufacturer)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(Brand; Rec.Brand)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(EAN; Rec.EAN)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(FeedType; Rec.FeedType)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Feed Type',
                           ENG = 'Feed Type';
                    Visible = false;
                }
                field("Feed Submission ID"; Rec."Feed Submission ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Visible = false;
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
                    Item: Record Item;
                    ItemCategory: Record "Item Category";
                    TradePartner: Record "Trade Partner";
                    ItemQuery: Query ItemQuery;
                    AvailableInventory: Decimal;
                    BOMComponent: Record "BOM Component";
                    Counter: Integer;
                    LowestInventory: Decimal;
                    Rec_Item: Record Item;
                    ChannelItemListing: Record "Channel Item Listing";
                    GeneralSetup: Record "General Setup - Channels";
                begin
                    GeneralSetup.Get();
                    ChannelItemListing.Reset();
                    ChannelItemListing.SetFilter("Item No.", '<>%1', '');
                    //ChannelItemListing.SetFilter("Item No.", 'ILW20008-SAMPLE');
                    if ChannelItemListing.FindSet() then begin
                        repeat
                            if Item.Get(ChannelItemListing."Item No.") then begin
                                if TradePartner.Get(ChannelItemListing."Channel Code") then;

                                ItemCategory.Reset();
                                ItemCategory.SetRange(Code, Item."Item Category Code");
                                if ItemCategory.FindFirst() then;

                                if ItemCategory."Auto Assembly Order" = true then begin
                                    Counter := 0;
                                    Clear(LowestInventory);
                                    BOMComponent.Reset();
                                    BOMComponent.SetRange("Parent Item No.", ChannelItemListing."Item No.");
                                    BOMComponent.SetRange(Type, BOMComponent.Type::Item);
                                    if BOMComponent.FindSet() then begin
                                        repeat
                                            if Rec_Item.Get(BOMComponent."No.") then begin
                                                Clear(AvailableInventory);
                                                CLEAR(ItemQuery);
                                                ItemQuery.SETRANGE(ItemQuery.No, BOMComponent."No.");
                                                ItemQuery.SETRANGE(ItemQuery.Location_Filter, TradePartner.Location);
                                                ItemQuery.SetFilter(ItemQuery.Bin_Type_Filter, 'PUT AWAY|PUTPICK|PICK');

                                                ItemQuery.OPEN;
                                                IF ItemQuery.READ THEN begin
                                                    AvailableInventory := (ItemQuery.Inventory_Qty_) - (ItemQuery.Qty_on_Sales_Order + ItemQuery.Qty_on_Web_Order + ItemQuery.Qty__on_Assembly_Order);
                                                END;
                                                ItemQuery.CLOSE;

                                                if Counter = 0 then begin
                                                    LowestInventory := AvailableInventory;
                                                end
                                                else begin
                                                    if AvailableInventory < LowestInventory then
                                                        LowestInventory := AvailableInventory;
                                                end;
                                                Counter += 1;
                                            end;
                                        until BOMComponent.Next() = 0;
                                    end;

                                    if LowestInventory <> ChannelItemListing."Channel Inventory" then begin
                                        if LowestInventory < 0 then begin
                                            ChannelItemListing.Validate("Channel Inventory", 0);
                                        end
                                        else begin
                                            ChannelItemListing.Validate("Channel Inventory", LowestInventory);
                                        end;
                                        ChannelItemListing."Inventory Synced" := false;
                                        ChannelItemListing."Modified On" := CurrentDateTime;
                                    end;
                                end
                                else begin
                                    Clear(AvailableInventory);
                                    CLEAR(ItemQuery);
                                    ItemQuery.SETRANGE(ItemQuery.No, ChannelItemListing."Item No.");
                                    ItemQuery.SETRANGE(ItemQuery.Location_Filter, TradePartner.Location);
                                    ItemQuery.SetFilter(ItemQuery.Bin_Type_Filter, 'PUT AWAY|PUTPICK|PICK');

                                    ItemQuery.OPEN;
                                    IF ItemQuery.READ THEN begin
                                        AvailableInventory := (ItemQuery.Inventory_Qty_) - (ItemQuery.Qty_on_Sales_Order + ItemQuery.Qty_on_Web_Order);
                                    END;
                                    ItemQuery.CLOSE;

                                    if AvailableInventory <> ChannelItemListing."Channel Inventory" then begin
                                        if AvailableInventory < 0 then begin
                                            ChannelItemListing.Validate("Channel Inventory", 0);
                                        end
                                        else begin
                                            ChannelItemListing.Validate("Channel Inventory", AvailableInventory);
                                        end;
                                        ChannelItemListing."Inventory Synced" := false;
                                        ChannelItemListing."Modified On" := CurrentDateTime;
                                    end;
                                end;

                            end
                            else begin
                                ChannelItemListing.Remarks := 'Item Not Found ' + ChannelItemListing."Item No.";
                                ChannelItemListing."Modified On" := CurrentDateTime;
                            end;

                            ChannelItemListing.Modify(true);

                        Until ChannelItemListing.Next = 0;
                    end;
                    Message('Success');
                end;
            }

            action("Item Coupling")
            {
                ApplicationArea = All;
                CaptionML = ENU = '&Manually Couple', ENG = '&Item Coupling';
                RunObject = Page "Item Coupling";
                RunPageView = WHERE(Action = FILTER(<> Updated));
                Image = CoupledItem;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = false;

                trigger OnAction()
                VAR
                    TempChannelItemListing: Record "Channel Item Listing";
                    TempChannelListing: Page "Item Coupling";
                begin
                    /*  {TempChannelItemListing.FINDSET;
                                    TempChannelListing.SETTABLEVIEW(TempChannelListing);
                                    TempChannelListing.
                                    PAGE.RUNMODAL(80007,TempChannelItemListing);}
                                    {
                                    TempChannelItemListing.RESET;
                                    TempChannelItemListing.SETRANGE("Item No.",'');
                                    TempChannelListing.SETTABLEVIEW(TempChannelItemListing);
                                    TempChannelListing.RUNMODAL;
                                    } */
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
                    TempChannelItemListing: Record "Channel Item Listing";
                    TempChannelListing: Page "Item Coupling";
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

            action("Eliminate Error")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Eliminate Error', ENG = 'Edit';
                RunPageOnRec = false;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    Rec_ChannelItemListing: Record "Channel Item Listing";
                    //ChannelItemList: Page "Channel  Listi;
                    Channelitemlisting: Record "Channel Item Listing";
                begin
                    CurrPage.SETSELECTIONFILTER(Channelitemlisting);
                    IF Channelitemlisting.FINDSET THEN
                        REPEAT
                        BEGIN
                            IF (Channelitemlisting.Remarks <> 'Success') AND (Channelitemlisting."Feed Submission ID" <> '') THEN BEGIN
                                Channelitemlisting.VALIDATE("Feed Submission ID", '');
                                Channelitemlisting.VALIDATE(Remarks, '');
                                Channelitemlisting.VALIDATE("Inventory Synced", FALSE);
                            END;

                            IF (Channelitemlisting.RemarksPrice <> 'Success') AND (Channelitemlisting."Feed Submission ID Price" <> '') THEN BEGIN
                                Channelitemlisting.VALIDATE("Feed Submission ID Price", '');
                                Channelitemlisting.VALIDATE(RemarksPrice, '');
                                Channelitemlisting.VALIDATE("Price Synced", FALSE);
                            END;

                            Channelitemlisting.MODIFY;
                        END;
                        UNTIL Channelitemlisting.NEXT = 0;
                    /* {CLEAR(Rec_ChannelItemListing);
                     Rec_ChannelItemListing.SETRANGE("Item No.",Rec."No.");
                     IF Rec_ChannelItemListing.FINDSET THEN
                       BEGIN
                         PAGE.RUN(80006,Rec_ChannelItemListing);
                         //ChannelItemList.SETTABLEVIEW(Rec_ChannelItemListing);
                         //ChannelItemList.RUN();
                     END ELSE
                       BEGIN
                         Rec_ChannelItemListing.VALIDATE("Item No.",Rec."No.");
                         Rec_ChannelItemListing.INSERT;
                         PAGE.RUN(80006,Rec_ChannelItemListing);
                       END;}*/

                end;
            }
            action("Update Price Routine")
            {
                ApplicationArea = All;
                CaptionML = ENU = '&Update Price Routine';
                //RunObject=Report 80001;
                Image = PriceAdjustment;
                Visible = false;
                trigger OnAction()
                begin

                end;
            }
            action(Edit)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Edit', ENG = 'Edit';
                Visible = false; // Irshad
                //RunObject = Page "Channel  Listing";
                // RunPageOnRec = false;
                // PromotedCategory = Process;
                // Promoted = true;
                // PromotedIsBig = true;
                // PromotedOnly = true;
                trigger OnAction()
                VAR
                    Rec_ChannelItemListing: Record "Channel Item Listing";
                //ChannelItemList: Page "Channel  Listing";
                begin
                    CLEAR(Rec_ChannelItemListing);
                    Rec_ChannelItemListing.SETRANGE("Item No.", Rec."Item No.");
                    IF Rec_ChannelItemListing.FINDSET THEN BEGIN
                        PAGE.RUN(50145, Rec_ChannelItemListing);
                        //ChannelItemList.SETTABLEVIEW(Rec_ChannelItemListing);
                        //ChannelItemList.RUN();
                    END ELSE BEGIN
                        Rec_ChannelItemListing.VALIDATE("Item No.", Rec."Item No.");
                        Rec_ChannelItemListing.INSERT;
                        PAGE.RUN(50145, Rec_ChannelItemListing);
                    END;
                end;
            }
            action("Sync Single Item")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Sync Single Item';
                Visible = false;

                trigger OnAction()
                var
                    TradePartnerCodeList: Record "Trade Partner";
                    AmazonChannels: TextConst ENU = 'AMAZON*';
                    CUShopify: Codeunit "Shopify Integration";
                    CIL: Record "Channel Item Listing";
                begin
                    /*CurrPage.SetSelectionFilter(Rec);
                    CIL.Reset();
                    CIL.Copy(Rec);
                    if CIL.FindSet then begin
                        repeat
                            if (CIL."Listing Status" = CIL."Listing Status"::"Not Listed") then begin
                                CUShopify.CreateProductShopify(CIL);
                            end;
                        until CIL.Next = 0;
                    end;*/

                    /*
                                        IF (Rec."Channel Code" = 'MAGENTO') AND (Rec."Listing Status" = Rec."Listing Status"::"Not Listed") THEN BEGIN
                                            //TestMagentoIntegration.CreateIndividualProduct(Rec);
                                        END;


                                        TradePartnerCodeList.SETFILTER(Code, '%1', AmazonChannels);
                                        IF TradePartnerCodeList.FINDSET THEN
                                            REPEAT
                                            BEGIN
                                                IF Rec."Channel Code" = TradePartnerCodeList.Code THEN BEGIN
                                                    // AmazonIntegration.UpdateProdutOnAmazon(Rec."Channel Code");
                                                END;
                                            END;
                                            UNTIL TradePartnerCodeList.NEXT = 0;
                    */
                end;
            }
        }
    }

    var
        Item: Record Item;
        // AmazonIntegration: Codeunit "Amazon Integration";
        JobQueueEntry: Record "Job Queue Entry";
    //TestMagentoIntegration: Codeunit "Magento Dev Codeunit";
    // PartnerIncomingMessages: Page "Partner Incoming Messages";
    //PrestaShopIntegration : Codeunit 90002;
    //GroupOnIntegration : Codeunit 90001;
    //PrestaShopIntegrationTest : Codeunit 90002;
    //PrestaIntegration : Codeunit 90005;
    //EbayIntegration : Codeunit 80001;


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    BEGIN
        //CurrPage.UPDATE;
    END;


}