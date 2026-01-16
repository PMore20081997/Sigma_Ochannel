page 90016 "Trade Partner card"
{
    PageType = Card;
    UsageCategory = Lists;
    SourceTable = "Trade Partner";
    Caption = 'Channel Partner Card';
    PromotedActionCategories = 'New,Process,Report,Related,Reporting,Request Approval,Customer,Page';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Code; rec.Code)
                {
                    ApplicationArea = all;
                }
                field(Name; rec.Name)
                {
                    ApplicationArea = all;
                }
                field(Location; rec.Location)
                {
                    ApplicationArea = all;
                    TableRelation = Location.Code;
                }
                field("Partner Type"; rec."Partner Type")
                {
                    ApplicationArea = all;
                }
                field("Inbox Type"; rec."Inbox Type")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    begin
                        InboxTypeFile := rec."Inbox Type" = rec."Inbox Type"::"File Location";
                        InboxTypeAPI := rec."Inbox Type" = rec."Inbox Type"::"Web service";
                        CurrPage.Update();
                    end;
                }
                field("Customer Mapping"; rec."Customer Mapping")
                {
                    Visible = true;
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
                    ApplicationArea = All;
                }
                field("Process Order Type"; rec."Process Order Type")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                    begin
                        Clear(EnableInvoiceTypeSelection);
                        EnableInvoiceTypeSelection := Rec."Process Order Type" = Rec."Process Order Type"::"Internal Pick";
                    end;
                }
                field(Logo; rec.Logo)
                {
                    ApplicationArea = all;
                }
                field("Prices Including VAT"; rec."Prices Including VAT")
                {
                    ApplicationArea = all;
                }
                field("Invoicing Method"; rec."Invoicing Method")
                {
                    ApplicationArea = all;
                    Editable = EnableInvoiceTypeSelection;
                }
                field("Order Item By"; Rec."Order Item By")
                {
                    ApplicationArea = All;
                }
                field("Order Import Codeunit"; Rec."Order Import Codeunit")
                {
                    Caption = 'Procesing Codeunit';
                    ApplicationArea = All;
                }
                field("Channel Order No. Series"; Rec."Channel Order No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Channel Specific Web Order No. Series';
                }
                field("PMR Order Issue"; Rec."PMR Order Issue")
                {
                    ApplicationArea = All;
                }
                field(PodFather; PodFather)
                {
                    ApplicationArea = All;
                }
                group("Customer trends")
                {
                    field("Customer Trend Code"; Rec."Customer Trend Code")
                    {
                        ApplicationArea = ALl;
                    }
                    field("Customer trends Order Nos"; REc."Customer trends Order Nos")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            group(Container)
            {
                Caption = 'Container Details';
                Editable = NOT InboxTypeAPI;
                field("API Endpoint"; Rec."API Endpoint")
                {
                    ApplicationArea = all;
                }
                field("API Attribute"; Rec."API Attribute")
                {
                    ApplicationArea = all;
                }
                field("Incoming Order Container Name"; Rec."Incoming Order Container Name")
                {
                    ApplicationArea = all;
                }
                field("Incoming Order Container Token"; Rec."Incoming Order Container Token")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Storage Account Name"; Rec."Storage Account Name")
                {
                    ApplicationArea = all;
                }
                field("Shared Access Key"; Rec."Shared Access Key")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Order Acknow. Container Name"; Rec."Order Acknow. Container Name")
                {
                    ApplicationArea = all;
                }
                field("Order Acknow. Container Token"; Rec."Order Acknow. Container Token")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Outgoing Container 2 Name"; Rec."Outgoing Container 2 Name")
                {
                    ApplicationArea = All;
                    Caption = 'Archive Container Name';
                }
                field("Outgoing Container 3 Name"; Rec."Outgoing Container 3 Name")
                {
                    ApplicationArea = All;
                    Caption = 'Master Data Container Name';
                }
            }

            group(Authentication)
            {
                Editable = InboxTypeAPI;
                Caption = 'Authentication';
                field(AccessKeyId; rec.AccessKeyId)
                {
                    ExtendedDatatype = Masked;
                    HideValue = false;
                    ApplicationArea = all;
                }
                field(MarketplaceId; rec.MarketplaceId)
                {
                    HideValue = false;
                    ApplicationArea = all;
                }
                field(MerchantId; rec.MerchantId)
                {
                    ExtendedDatatype = Masked;
                    HideValue = false;
                    ApplicationArea = all;
                }
                field(SecretAccessKey; rec.SecretAccessKey)
                {
                    ExtendedDatatype = Masked;
                    HideValue = false;
                    ApplicationArea = all;
                }
                field("Sevice/API URL"; rec."Sevice/API URL")
                {
                    ApplicationArea = all;
                }
                field(Token; rec.Token)
                {
                    ApplicationArea = all;
                }
                field("ePOD Template ID"; Rec."ePOD Template ID")
                {
                    ApplicationArea = All;
                }
            }

            group("Feature Setup")
            {
                field("<Sync Price>"; rec.SyncPrice)
                {
                    Caption = 'Sync Price';
                    ApplicationArea = all;
                }
                field("<Sync Inventory>"; rec.SyncInventory)
                {
                    Caption = 'Sync Inventory';
                    ApplicationArea = all;
                }
                field("<Sync Order>"; rec.SyncOrder)
                {
                    Caption = 'Sync Order';
                    ApplicationArea = all;
                }
                field("<Order FullFilment>"; rec.OrderFullFilment)
                {
                    Caption = 'Order FullFilment';
                    ApplicationArea = all;
                }
                field("Shipping Rule"; Rec."Shipping Rule Validation")
                {
                    ApplicationArea = all;
                }
                field("Order Acknowledgement Required"; Rec."Order Acknowledgement Required")
                {
                    ApplicationArea = All;
                }
                field(MyField; Rec."Tracking No Valid. Required")
                {
                    ApplicationArea = All;
                }
                field("Update Tracking Information"; Rec."Update Tracking Information")
                {
                    ApplicationArea = All;
                }
                field("Order Acknowledgement Codeunit"; Rec."Order Acknowledgement Codeunit")
                {
                    ApplicationArea = All;
                }
                field("Last Date to Export Order Ack"; Rec."Last Date to Export Order Ack")
                {
                    ApplicationArea = All;
                }
                field(TariffCode; Rec.TariffCode)
                {
                    ApplicationArea = All;
                }
                field("Export Invoice"; Rec."Export Invoice")
                {
                    ApplicationArea = All;
                }
                field("EDI No.Series"; Rec."EDI No.Series")
                {
                    ApplicationArea = All;
                }
                field("Last EDI Invoice No."; Rec."Last EDI Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Price Pick From"; Rec."Price Pick From")
                {
                    ApplicationArea = All;
                }
            }

            group("Posting Set up")
            {
                field("Shipping G/L No."; rec."Shipping G/L No.")
                {
                    ApplicationArea = all;
                }
                field("Positng G/L No."; rec."Positng G/L No.")
                {
                    ApplicationArea = all;
                }
            }


            group(Log)
            {
                Caption = 'Log';
                field("Last Order Sync"; rec."Last Order Sync")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Last Order Acknowledgment"; rec."Last Order Acknowledgment")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Last Order Fullfillment"; rec."Last Order Fullfillment")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Last Product Sync"; rec."Last Product Sync")
                {
                    Editable = true;
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Last Customer Sync"; rec."Last Customer Sync")
                {
                    ApplicationArea = all;
                }
                field("Customer No. Series"; Rec."Customer No. Series")
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

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);
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
                Enabled = Rec.SyncInventory;
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
                Visible = false;
                ApplicationArea = All;
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

            action("Item Reference")
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
        }
    }


    trigger OnAfterGetRecord()
    var
        myInt: Integer;
        ChannelSetup: Record "General Setup - Channels";
    begin
        Clear(EnableInvoiceTypeSelection);
        InboxTypeFile := rec."Inbox Type" = rec."Inbox Type"::"File Location";

        rec.CALCFIELDS(Token);
        IF rec.Token.HASVALUE THEN BEGIN
            rec.Token.CREATEINSTREAM(Instr);
            Instr.READ(TokenText);
        END;

        InboxTypeFile := rec."Inbox Type" = rec."Inbox Type"::"File Location";
        InboxTypeAPI := rec."Inbox Type" = rec."Inbox Type"::"Web service";
        EnableInvoiceTypeSelection := Rec."Process Order Type" = Rec."Process Order Type"::"Internal Pick";
    end;

    var
        InboxTypeFile: Boolean;
        InboxTypeAPI: Boolean;
        TradePartnerList: Record "Trade Partner";
        JobQueueEntry: Record 472;
        TokenText: Text;
        Instr: InStream;
        EnableInvoiceTypeSelection: Boolean;
}