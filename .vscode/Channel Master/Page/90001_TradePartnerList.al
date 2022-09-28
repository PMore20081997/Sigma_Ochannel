page 90001 "Trade Partner List"
{
    PageType = List;
    CaptionML = ENU = 'Channel Partner', ENG = 'Channel Partner';
    UsageCategory = Lists;
    SourceTable = "Trade Partner";
    CardPageId = "Trade Partner Card";
    Editable = false;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Related,Reporting,Request Approval,Customer,Page';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; rec.Code)
                {
                    ApplicationArea = all;
                }
                field(Name; rec.Name)
                {
                    ApplicationArea = all;
                }
                field("Inbox Type"; rec."Inbox Type")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Customer Mapping"; rec."Customer Mapping")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Customer No."; rec."Customer No.")
                {
                    ApplicationArea = all;
                }
                field("Customer Name"; rec."Customer Name")
                {
                    ApplicationArea = all;
                }
                field(Blocked; rec.Blocked)
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Partner Type"; rec."Partner Type")
                {
                    ApplicationArea = all;
                }
                field("Sevice/API URL"; rec."Sevice/API URL")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Last Order Acknowledgment"; rec."Last Order Acknowledgment")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Last Order Fullfillment"; rec."Last Order Fullfillment")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Last Product Sync"; rec."Last Product Sync")
                {
                    ApplicationArea = all;
                }
                field("Last Order Sync"; rec."Last Order Sync")
                {
                    ApplicationArea = all;
                }
                field("Last Inventory Sync"; rec."Last Inventory Sync")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("<Sync Price>"; rec.SyncPrice)
                {
                    ApplicationArea = all;
                    Caption = 'Sync Price';
                }
                field("<Sync Inventory>"; rec.SyncInventory)
                {
                    ApplicationArea = all;
                    Caption = 'Sync Inventory';
                }
                field("<Sync Order>"; rec.SyncOrder)
                {
                    ApplicationArea = all;
                    Caption = 'Sync Order';
                }
                field("<Order FullFilment>"; rec.OrderFullFilment)
                {
                    Caption = 'Order FullFilment';
                    ApplicationArea = all;
                }
                field(Location; rec.Location)
                {
                    ApplicationArea = all;
                }
                field("Process Order Type"; rec."Process Order Type")
                {
                    ApplicationArea = all;
                }

            }
        }
    }


    actions
    {
        area(Processing)
        {
            action("Import Items In Channel")
            {
                Caption = 'Import Items In Channel';
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;
                ApplicationArea = All;
            }
            action("Sync Item")
            {
                Caption = 'Sync Item';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                //Enabled = Rec.SyncItem;

                trigger OnAction()
                var
                    ItemChannelCode: Code[10];
                    ChannelCode: Code[10];
                    TradePartner: Record "Trade Partner";
                    CUShopify: Codeunit "Shopify Integration";
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncItem';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;


            }
            action("Sync Order")
            {
                Caption = '&Sync Order';
                Image = NewTransferOrder;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                Enabled = Rec.SyncOrder;

                trigger OnAction()
                var
                    CUAmazon: Codeunit "Amazon Integration";
                    CUSopify: Codeunit "Shopify Integration";
                    CUOnBuy: Codeunit "OnBuy Integration";
                    CUMagento: Codeunit "Magento Integration";
                    CUEbay: Codeunit "Ebay Integration";
                    CUWooCommerce: Codeunit "Woo Commerce";
                    CUB2B: Codeunit "B2B";
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindFirst then begin
                        if TradePartnerList.SyncOrder = true then begin

                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncOrder';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();

                            // TradePartnerList."Last Order Sync" := CREATEDATETIME(WORKDATE, TIME);
                            // TradePartnerList.MODIFY;
                        end else
                            MESSAGE('Please enable the Sync Order feature.');
                    end;
                end;

            }

            action("Update Inventory")
            {
                Caption = '&Update Inventory';
                Image = ItemGroup;
                Promoted = true;
                PromotedCategory = Process;
                Visible = true;
                ApplicationArea = All;
                Enabled = Rec.SyncInventory;
                trigger OnAction()
                var
                    UpdateInventoryChannelCode: Code[10];
                    ChannelCode: code[20];
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';UpdateInventory';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;
            }


            action("Update Price")
            {
                Caption = '&Update Price';
                Image = ItemGroup;
                Promoted = true;
                PromotedCategory = Process;
                Visible = true;
                Enabled = Rec.SyncPrice; //Ps
                ApplicationArea = All;

                trigger OnAction()
                var
                    UpdatePriceChannelCode: Code[10];
                    ChannelCode: code[20];
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';UpdatePrice';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;
            }

            action("Sync Sales Price")
            {
                Caption = 'Sync Sales Price';
                Image = Interaction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    B2BIntegration: Codeunit B2B;
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncSalesPrice';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;

                    // B2BIntegration.SyncSalesPrice();
                    // B2BIntegration.SyncCustomerBasedPrice();
                    // Message('Sync Completed...');
                end;
            }
            action("Update Product")
            {
                Caption = '&Update Product';
                Image = ItemGroup;
                Promoted = true;
                PromotedCategory = Process;
                Visible = true;
                Enabled = Rec.SyncPrice; //Ps
                ApplicationArea = All;

                trigger OnAction()
                var
                    UpdatePriceChannelCode: Code[10];
                    ChannelCode: code[20];
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';UpdateProduct';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;
            }

            action("Sync Shipment")
            {
                Caption = 'Sync Shipment';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;
                Enabled = Rec.SyncOrder;

                trigger OnAction()
                var
                    Channelcode: Code[10];

                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncShipment';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;

            }

            // action("Sync Location")
            // {
            //     Caption = 'Sync Location';
            //     Image = CreateInteraction;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     Visible = false;
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         Channelcode: Code[10];
            //     //LinnWorks: Codeunit "LinnWorks Integration";

            //     begin
            //         Rec.Reset();
            //         CurrPage.SetSelectionFilter(Rec);
            //         If TradePartnerList.Findset() then begin
            //             Channelcode := 'LINNWORKS';//CopyStr(TradePartnerList.Code, 1, 9);
            //             if Channelcode = 'LINNWORKS' then;
            //             //LinnWorks.GetLinnworksLocation();
            //         end;
            //     end;

            // }
            action("Sync Customer")
            {
                Caption = 'Sync Customer';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    myInt: Integer;
                    B2B: Codeunit B2B;
                    TradePartner: Record "Trade Partner";
                    Shopify: Codeunit "Shopify Integration";
                    ChannelCode: Text;
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';CustomerSync';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;

                        until TradePartnerList.Next() = 0;

                end;
            }
            action("Sync Customer Addresses")
            {
                Caption = 'Sync Customer Addresses';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction()
                var
                    myInt: Integer;
                    B2B: Codeunit B2B;
                    TradePartner: Record "Trade Partner";
                    Shopify: Codeunit "Shopify Integration";
                    ChannelCode: Text;
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';CustomerSyncAddress';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;

                        until TradePartnerList.Next() = 0;

                end;
            }
            action("Sync Category")
            {
                Caption = 'Sync Category';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';CategorySync';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;
                end;
            }
            action("Sync Manufacturer")
            {
                Caption = 'Sync Manufacturer';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';ManufacturerSync';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;
                end;
            }
            action("Sync Product VAT Posting Group")
            {
                Caption = 'Sync Product VAT Posting Group';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';VatSync';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;
                end;
            }

            action("Sync Currency Rate")
            {
                Caption = 'Sync Currency Rate';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction()
                var
                begin
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';CurrencySync';
                            JobQueueEntry.Insert;
                            if TradePartnerList."Order Import Codeunit" <> 0 then begin
                                Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;
                end;
            }
            /*
            action("POS Sync items")
            {
                Caption = 'POS Sync Items';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;
                Image = Interaction;
                trigger OnAction()
                var
                    posintegration: Codeunit PosIntegration;
                begin
                    posintegration.syncitems('POS');
                end;

            }
            action("POS Sync Customer")
            {
                Caption = 'POS Sync Customer';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;
                Image = Interaction;
                trigger OnAction()
                var
                    posintegration: Codeunit PosIntegration;
                begin
                    posintegration.SyncCustomer();
                end;

            }
            */
            /*action("POS Sync Company")
            {
                Caption = 'POS Sync Company';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;
                Image = Interaction;
                trigger OnAction()
                var
                    posintegration: Codeunit PosIntegration;
                begin
                    TradePartnerList.Reset();
                    TradePartnerList.SetRange(Code, 'EPOS');
                    if TradePartnerList.FindFirst() then;
                    posintegration.Syncompany(TradePartnerList.Code);
                end;
            }*/
            /*
            action("POS Sync VAT")
            {
                Caption = 'POS Sync VAT';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
                ApplicationArea = All;
                Image = Interaction;
                trigger OnAction()
                var
                    posintegration: Codeunit PosIntegration;
                begin
                    posintegration.SyncVAT();
                end;
            }
            */
        }
        area(Navigation)
        {
            action("Channel Orders")
            {
                Caption = 'Channel Orders';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                Visible = true;

                ApplicationArea = All;
                RunObject = page "Web Order List";
                RunPageLink = "Trade Partner Code" = field(code);

                trigger OnAction()

                var

                begin

                end;

            }
            action("Channel Order Lines")
            {
                Caption = 'Channel Order Lines';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                Visible = true;
                ApplicationArea = All;
                RunObject = page "Web Order Line List";
                RunPageLink = "Trade Partner Code" = field(code);

                trigger OnAction()

                var

                begin

                end;

            }
            action("Web Customers")
            {
                Caption = 'Web Customers';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                Visible = false;
                ApplicationArea = All;
                RunObject = page "Web Customer";
                RunPageLink = "Channel Code" = field(Code);
                trigger OnAction()
                var

                begin

                end;
            }


            action("Item Reference")
            {
                Caption = 'Item Reference';
                Image = Change;
                Promoted = true;
                PromotedCategory = Category4;
                ApplicationArea = All;
                RunObject = Page "Item Reference List";
                RunPageView = WHERE("Reference Type" = FILTER(Customer));
                RunPageLink = "Reference Type No." = FIELD("Customer No.");

                trigger OnAction()

                var

                begin

                end;

            }

            action("Handeled Orders")
            {
                Caption = 'Handeled Orders';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                Visible = true;
                ApplicationArea = All;
                RunObject = Page "Handled Web Order List";
                RunPageLink = "Trade Partner Code" = FIELD(Code);

                trigger OnAction()

                var

                begin

                end;

            }

            action("Handeled Order Lines")
            {
                Caption = 'Handeled Order Lines';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                Visible = true;
                ApplicationArea = All;
                RunObject = Page "Handled Web Order Line";
                RunPageLink = "Trade Partner Code" = FIELD(Code);

                trigger OnAction()

                var

                begin

                end;

            }
        }
        area(Reporting)
        {
            action("Print Manifest")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                Visible = false;
                PromotedCategory = Category5;
                trigger OnAction()
                var
                    L_TradePartner: Record "Trade Partner";
                    PrintManifest: Report "Print Manifest";
                begin
                    CurrPage.SETSELECTIONFILTER(L_TradePartner);
                    //L_TradePartner.SETRANGE(Manifest,FALSE);
                    IF L_TradePartner.FINDFIRST THEN BEGIN
                        PrintManifest.GetChannelCode(L_TradePartner.Code);
                        PrintManifest.RUN();
                    END;
                end;
            }
        }
    }

    var

        JobQueueEntry: Record "Job Queue Entry" temporary;
        TradePartnerList: Record "Trade Partner";
        CodeList: BigText;
        disableSyncorder: Boolean;
        //TestEbayIntegration:Codeunit  Test;
        TradePartner1: Record "Trade Partner";


}