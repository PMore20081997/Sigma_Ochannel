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
                    Visible = True;

                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Variant Id';
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
                    Visible = false;

                }
                field("NAV Variant"; Rec."NAV Variant")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Channel Title"; Rec."Channel Title")
                {
                    ApplicationArea = All;
                }
                field("Channel Description"; Rec."Channel Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Channel Inventory"; Rec."Channel Inventory")
                {
                    ApplicationArea = All;
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
                    Visible = false;

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
                field("Item Category Code"; Rec."Item Category Code")
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
            action("Item Coupling")
            {
                ApplicationArea = All;
                CaptionML = ENU = '&Manually Couple', ENG = '&Item Coupling';
                RunObject = Page "Item Coupling";
                RunPageView = WHERE(Action = FILTER(<> Updated));
                Promoted = true;
                Image = CoupledItem;
                PromotedCategory = Process;
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
                Promoted = true;
                Image = CoupledOrderList;
                PromotedCategory = Process;

                trigger OnAction()
                VAR
                    TempChannelItemListing: Record "Channel Item Listing";
                    TempChannelListing: Page "Item Coupling";
                begin
                    Rec.UpdateItemNo;
                end;
            }
            action(Edit)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Edit', ENG = 'Edit';
                //RunObject = Page "Channel  Listing";
                RunPageOnRec = false;
                Promoted = true;
                Visible = false;
                PromotedCategory = Process;
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
            action("Update Price Routine")
            {
                ApplicationArea = All;
                CaptionML = ENU = '&Update Price Routine';
                Visible = false;
                //RunObject=Report 80001;
                Image = PriceAdjustment;
                trigger OnAction()
                begin

                end;
            }
            action(Card)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Card', ENG = 'Card';
                Promoted = true;
                PromotedIsBig = false;
                Image = Item;
                PromotedCategory = Process;
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
            action("Eliminate Error")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Eliminate Error', ENG = 'Edit';
                RunPageOnRec = false;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;
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
            action(ChannelInventory)
            {
                ApplicationArea = All;
                Caption = 'Update Channel Inventory';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = UpdateUnitCost;
                trigger onaction()
                var
                    Stock1: Decimal;
                    Stock2: Decimal;
                    ChannelItemListing: Record "Channel Item Listing";
                    TradePartner: Record "Trade Partner";
                    LocationCode: Code[20];
                    InventoryQuery: Query "Calculate Inventory";
                    CalculateQtyOnSO: Query "Qty on SO";
                    CalculateQtyOnPO: Query "Qty on PO";
                    CalculateQtyOnWeb: Query "Qty on Web";
                    L_Inv: Decimal;
                    L_QtyOnSO: Decimal;
                    L_QtyOnPO: Decimal;
                    L_QtyOnWeb: Decimal;
                begin
                    ChannelItemListing.Reset();
                    ChannelItemListing.SetFilter("Item No.", '<>%1', '');
                    if ChannelItemListing.FindFirst() then begin
                        repeat

                            Clear(LocationCode);
                            TradePartner.Reset();
                            TradePartner.SetRange(Code, Rec."Channel Code");
                            if TradePartner.FindFirst() then
                                LocationCode := TradePartner.Location;

                            CLEAR(InventoryQuery);
                            Clear(L_Inv);
                            InventoryQuery.SETRANGE(InventoryQuery.Item_No_, Rec."Item No.");
                            InventoryQuery.SETRANGE(InventoryQuery.Location_Code, LocationCode);
                            InventoryQuery.SETRANGE(InventoryQuery.Variant_Code, Rec."NAV Variant");
                            InventoryQuery.OPEN;
                            WHILE InventoryQuery.READ DO BEGIN
                                L_Inv := InventoryQuery.Quantity;
                            END;
                            InventoryQuery.CLOSE;

                            CLEAR(CalculateQtyOnSO);
                            Clear(L_QtyOnSO);
                            CalculateQtyOnSO.SETRANGE(CalculateQtyOnSO.No_, Rec."Item No.");
                            CalculateQtyOnSO.SETRANGE(CalculateQtyOnSO.Location_Code, LocationCode);
                            CalculateQtyOnSO.SETRANGE(CalculateQtyOnSO.Variant_Code, Rec."NAV Variant");
                            CalculateQtyOnSO.OPEN;
                            WHILE CalculateQtyOnSO.READ DO BEGIN
                                L_QtyOnSO := CalculateQtyOnSO.Outstanding_Qty___Base_;
                            END;
                            CalculateQtyOnSO.CLOSE;

                            CLEAR(CalculateQtyOnPO);
                            Clear(L_QtyOnPO);
                            CalculateQtyOnPO.SETRANGE(CalculateQtyOnPO.No_, Rec."Item No.");
                            CalculateQtyOnPO.SETRANGE(CalculateQtyOnPO.Location_Code, LocationCode);
                            CalculateQtyOnPO.SETRANGE(CalculateQtyOnPO.Variant_Code, Rec."NAV Variant");
                            CalculateQtyOnPO.OPEN;
                            WHILE CalculateQtyOnPO.READ DO BEGIN
                                L_QtyOnPO := CalculateQtyOnPO.Outstanding_Qty___Base_;
                            END;
                            CalculateQtyOnPO.CLOSE;

                            CLEAR(CalculateQtyOnWeb);
                            Clear(L_QtyOnWeb);
                            CalculateQtyOnWeb.SETRANGE(CalculateQtyOnWeb.No_, Rec."Item No.");
                            CalculateQtyOnWeb.SETRANGE(CalculateQtyOnWeb.Location_Code, LocationCode);
                            CalculateQtyOnWeb.SETRANGE(CalculateQtyOnWeb.NAV_Variant_code, Rec."NAV Variant");
                            CalculateQtyOnWeb.OPEN;
                            WHILE CalculateQtyOnWeb.READ DO BEGIN
                                L_QtyOnWeb := CalculateQtyOnWeb.Quantity;
                            END;
                            CalculateQtyOnWeb.CLOSE;

                            Clear(Stock1);
                            Clear(Stock2);
                            Stock1 := L_Inv - L_QtyOnWeb;
                            Stock2 := L_Inv + L_QtyOnPO - L_QtyOnSO - L_QtyOnWeb;
                            if Stock1 > Stock2 then
                                ChannelItemListing."Channel Inventory" := Stock2
                            else
                                ChannelItemListing."Channel Inventory" := Stock1;

                            if ChannelItemListing."Channel Inventory" < 0 then
                                ChannelItemListing."Channel Inventory" := 0;
                            ChannelItemListing.Modify(true);

                        Until ChannelItemListing.Next = 0;
                    end;
                    Message('Sucess ');
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