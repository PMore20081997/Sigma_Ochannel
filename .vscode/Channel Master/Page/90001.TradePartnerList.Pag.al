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
                    Visible = false;
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
            action("Sync Order")
            {
                ApplicationArea = All;
                Caption = '&Sync Order';
                Enabled = Rec.SyncOrder;
                Image = NewTransferOrder;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
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
                        end else
                            MESSAGE('Please enable the Sync Order feature.');
                    end;
                end;
            }

            action("Sync Shipment")
            {
                ApplicationArea = All;
                Caption = 'Sync Shipment';
                Enabled = Rec.SyncOrder;
                Image = NewTransferOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = false;

                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then begin
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncShipment';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Acknowledgement Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                    end;
                end;
            }

            action("Sync Customer")
            {
                ApplicationArea = All;
                Image = Intercompany;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = Rec.SyncPrice;
                Visible = false;

                trigger OnAction()
                var
                begin
                    if TradePartnerList.FindSet() then begin
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
                end;
            }

            action("Sync Item")
            {
                ApplicationArea = All;
                Caption = 'Sync Item';
                Image = Intercompany;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Enabled = Rec.SyncInventory;
                Visible = false;

                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then begin
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncItem';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                    end;
                end;
            }

            action("Update Inventory")
            {
                ApplicationArea = All;
                Caption = '&Update Inventory';
                Enabled = Rec.SyncInventory;
                Image = ItemGroup;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = false;

                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then begin
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';UpdateInventory';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                    end;
                end;
            }

            action("Update Price")
            {
                ApplicationArea = All;
                Caption = '&Update Price';
                Enabled = Rec.SyncPrice;
                PromotedCategory = Process;
                Image = ItemGroup;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = false;

                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then begin
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';UpdatePrice';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                    end;
                end;
            }

            action("Sync Location")
            {
                Caption = 'Sync Location';
                Image = CreateInteraction;
                ApplicationArea = All;
                Visible = false;
                Enabled = Rec.SyncInventory;
                trigger OnAction()
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';SyncLocation';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;
            }

            action("Import Web Order")
            {
                Caption = 'Import Web Order';
                ApplicationArea = All;
                Image = Import;
                Visible = false;
                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then begin
                        if TradePartnerList.Count = 1 then begin
                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';ImportOrder';
                            JobQueueEntry.Insert;
                            Codeunit.Run(90078, JobQueueEntry);
                            JobQueueEntry.Delete();
                        end else begin
                            exit;
                        end;
                    end;
                end;
            }

            action("Order Acknowledgement")
            {
                Image = OrderPromising;
                Visible = false;
                trigger OnAction()
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            if TradePartnerList."Order Acknowledgement Required" then begin
                                JobQueueEntry.Init;
                                JobQueueEntry.ID := CreateGuid();
                                JobQueueEntry."Parameter String" := TradePartnerList.Code + ';OrderAcknowledgement';
                                JobQueueEntry.Insert;

                                Codeunit.Run(TradePartnerList."Order Acknowledgement Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;
                end;
            }

            action("Export FTP Data Files")
            {
                ApplicationArea = All;
                Image = Inventory;
                Enabled = Rec.SyncInventory;
                Visible = true;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindFirst() then begin
                        JobQueueEntry.Init();
                        JobQueueEntry.ID := CreateGuid();
                        JobQueueEntry."Parameter String" := TradePartnerList.Code + ';ExportDataFiles';
                        JobQueueEntry.Insert();

                        Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                        JobQueueEntry.Delete();
                    end;
                end;
            }

            action("Export Stock Status")
            {
                Image = OrderPromising;
                Visible = false;
                trigger OnAction()
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then
                        repeat
                            if TradePartnerList."Order Acknowledgement Required" then begin
                                JobQueueEntry.Init;
                                JobQueueEntry.ID := CreateGuid();
                                JobQueueEntry."Parameter String" := TradePartnerList.Code + ';StockStatus';
                                JobQueueEntry.Insert;

                                Codeunit.Run(TradePartnerList."Order Acknowledgement Codeunit", JobQueueEntry);
                                JobQueueEntry.Delete();
                            end;
                        until TradePartnerList.Next() = 0;
                end;
            }
        }

        area(Navigation)
        {
            action("Channel Orders")
            {
                Caption = 'Channel Orders';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Visible = true;
                ApplicationArea = All;
                RunObject = page "Web Order List";
                RunPageLink = "Trade Partner Code" = field(code);
            }

            action("Channel Order Lines")
            {
                Caption = 'Channel Order Lines';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Visible = true;
                ApplicationArea = All;
                RunObject = page "Web Order Line List";
                RunPageLink = "Trade Partner Code" = field(code);
            }

            action("Item Cross Reference")
            {
                Caption = 'Item Reference';
                Image = Change;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Visible = true;
                ApplicationArea = All;
                RunObject = Page "Item Reference Entries";
                RunPageView = WHERE("Reference Type" = FILTER(Customer));
                RunPageLink = "Reference Type No." = FIELD("Customer No.");
            }

            action("Handeled Orders")
            {
                Caption = 'Handeled Orders';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Visible = true;
                ApplicationArea = All;
                RunObject = Page "Handled Web Order List";
                RunPageLink = "Trade Partner Code" = FIELD(Code);
            }

            action("Handeled Order Lines")
            {
                Caption = 'Handeled Order Lines';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Visible = true;
                ApplicationArea = All;
                RunObject = Page "Handled Web Order Line";
                RunPageLink = "Trade Partner Code" = FIELD(Code);
            }
            action("Datawarehouse")
            {
                ApplicationArea = All;
                Image = Intercompany;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                // Visible = false;

                trigger OnAction()
                var
                begin
                    Clear(TradePartnerList);
                    CurrPage.SETSELECTIONFILTER(TradePartnerList);
                    if TradePartnerList.FindSet() then begin
                        repeat

                            JobQueueEntry.Init;
                            JobQueueEntry.ID := CreateGuid();
                            JobQueueEntry."Parameter String" := TradePartnerList.Code + ';Datawarehouse';
                            JobQueueEntry.Insert;

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
                            JobQueueEntry.Delete();

                        until TradePartnerList.Next() = 0;
                    end;
                end;
            }
        }
    }

    var
        JobQueueEntry: Record "Job Queue Entry" temporary;
        TradePartnerList: Record "Trade Partner";
}