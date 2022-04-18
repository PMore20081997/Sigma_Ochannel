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
                    //Visible = false;

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
                    //Visible = false;
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

            }

            group("File Setup")
            {
                Editable = InboxTypeFile;
                Visible = false;
                field("Inbox Details"; rec."Incoming Order File Path")
                {
                    ApplicationArea = all;
                    Editable = InboxTypeFile;
                }
                field("Archived Inbox Details"; rec."Arch. Incoming Order File Path")
                {
                    ApplicationArea = all;
                    Editable = InboxTypeFile;
                }
            }
            //Sofyan++
            group(Conatiner)
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
                field("Incoming Orders Conatiner Name"; Rec."Incoming Orders Conatiner Name")
                {
                    ApplicationArea = all;

                }
                field("Incoming Orders Token"; Rec."Incoming Orders Token")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Status Conatiner Name"; Rec."Status Conatiner Name")
                {
                    ApplicationArea = all;
                }
                field("Status Token"; Rec."Status Token")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Order Acknow. Conatiner Name"; Rec."Order Acknow. Conatiner Name")
                {
                    ApplicationArea = all;
                }
                field("Order Acknow. Token"; Rec."Order Acknow. Token")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Outgoing Container 2 Name"; rec."Outgoing Container 2 Name")
                {
                    ApplicationArea = All;
                }
                field("Outgoing Container 2 Token"; rec."Outgoing Container 2 Token")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("Outgoing Container 3 Name"; rec."Outgoing Container 3 Name")
                {
                    ApplicationArea = All;
                }
                field("Outgoing Container 3 Token"; rec."Outgoing Container 3 Token")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
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

                    trigger OnDrillDown()
                    begin
                        // CALCFIELDS(Token);
                        // Token.CREATEINSTREAM(Instr);
                        // BinaryReader := BinaryReader.BinaryReader(Instr,Encoding.UTF8);
                        // IF NOT ISNULL(BinaryReader) THEN BEGIN   //read value from BLOB field
                        //   IF BinaryReader.BaseStream.Length > 0 THEN
                        //     MyText := BinaryReader.ReadString;
                        //   //MESSAGE('%1',MyText);
                        //   BinaryReader.Close;
                        // END;

                        // CLEAR(InputLongTextTest);
                        // InputLongTextTest.SetText(MyText);
                        // IF InputLongTextTest.RUNMODAL = ACTION::OK THEN BEGIN
                        //   NewText := InputLongTextTest.GetText;
                        //   IF NewText <> MyText THEN BEGIN     //write value to BLOB field
                        //     CLEAR(Token);
                        //     Token.CREATEOUTSTREAM(OutStr);
                        //     BinaryWriter := BinaryWriter.BinaryWriter(OutStr,Encoding.UTF8);
                        //     BinaryWriter.Write(NewText);
                        //     BinaryWriter.Close;
                        //     MODIFY;
                        //   END;
                        // END;
                    end;
                }
                field("<Token>"; TokenText)
                {
                    Caption = 'Token';
                    MultiLine = true;
                    Visible = false;
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin


                    end;
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
                field("Print Return Note"; Rec."Print Return Note")
                {
                    ApplicationArea = All;
                    Editable = Flag;
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
                field("Send Email To Customer"; Rec."Send Email To Customer")
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
                field("GiftWrap G/L No."; rec."GiftWrap G/L No.")
                {
                    ApplicationArea = all;
                }
                field("Positng G/L No."; rec."Positng G/L No.")
                {
                    ApplicationArea = all;
                }

                field("Maximum Inventory"; rec."Maximum Inventory")
                {
                    ApplicationArea = all;
                }
                field("Minimum Inventory"; rec."Minimum Inventory")
                {
                    ApplicationArea = all;
                }
                //CAS-27945-M1R5J2.MH -->
                field("Post auto payment"; Rec."Post auto payment")
                {
                    ApplicationArea = All;
                }
                field("Bank Account Code"; Rec."Bank Account Code")
                {
                    ApplicationArea = All;
                }
                //CAS-27945-M1R5J2.MH <--
            }

            group("FTP Connection")
            {
                Visible = false;
                field("FTP Archive File Path"; rec."FTP Archive File Path")
                {
                    ApplicationArea = All;
                }

                field("FTP Incoming File Path"; rec."FTP Incoming File Path")
                {
                    ApplicationArea = All;
                }
                field("FTP IP Address"; rec."FTP IP Address")
                {
                    ApplicationArea = All;
                }
                field("FTP Outgoing File path1"; rec."FTP Outgoing File path1")
                {
                    ApplicationArea = All;
                }
                field("FTP Outgoing File path2"; rec."FTP Outgoing File path2")
                {
                    ApplicationArea = All;
                }
                field("FTP User ID"; rec."FTP User ID")
                {
                    ApplicationArea = All;
                }
                field("FTP Password"; rec."FTP Password")
                {
                    ApplicationArea = All;
                }
                field("FTP Upload user ID"; rec."FTP Upload user ID")
                {
                    ApplicationArea = All;
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
                    WooCommerce: Codeunit "Woo Commerce";
                    TradePartner: Record "Trade Partner";
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

                            /*  If TradePartnerList.Code = 'AMAZON' then
                                CUAmazon.ListOrders(TradePartnerList.Code, '')
                            Else
                                If TradePartnerList.Code = 'SHOPIFY' then
                                    CUSopify.GetShopifyOrder(TradePartnerList.Code)
                                else
                                    if TradePartnerList.Code = 'ONBUY' then
                                        CUOnBuy.GetOnBuyOrders(TradePartnerList.Code)
                                    else
                                        if TradePartnerList.Code = 'MAGENTO' then
                                            CUMagento.GetMagentoOrders(TradePartnerList.Code)
                                        else
                                            if TradePartnerList.Code = 'EBAY' then
                                                CUEbay.GetEbayOrders(TradePartnerList.Code)
                                            else
                                                if TradePartnerList.Code = 'WOOCOMMERC' then
                                                    CUWooCommerce.ListOrders(TradePartnerList.Code)
                                                else
                                                    if TradePartnerList.Code = 'B2B' then
                                                        CUB2B.GetOrders(TradePartnerList.Code);*/
                            TradePartnerList."Last Order Sync" := CREATEDATETIME(WORKDATE, TIME);
                            TradePartnerList.MODIFY;
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
                begin
                    // IF TradePartnerList.Code = 'B2B' THEN BEGIN
                    //     //   NopPriceUpdate.UpdatePrice();Ps
                    //     TradePartnerList."Last Inventory Sync" := CREATEDATETIME(WORKDATE, TIME);
                    //     TradePartnerList.MODIFY
                    // END;

                    // CLEAR(TradePartnerList);
                    // CurrPage.SETSELECTIONFILTER(TradePartnerList);

                    // IF TradePartnerList.FINDSET THEN REPEAT    //For Handling Multiple Tradepartner
                    //                                            //IF TradePartnerList.FINDFIRST THEN
                    //     BEGIN
                    //         UpdatePriceChannelCode := COPYSTR(TradePartnerList.Code, 1, 6);
                    //         //MESSAGE(FORMAT(UpdatePriceChannelCode));
                    //         IF UpdatePriceChannelCode = 'AMAZON' THEN BEGIN
                    //             AmazonIntegration.SetParameter(TradePartnerList.Code, 'Price', TradePartnerList.Domain);
                    //             AmazonIntegration.RUN(JobQueueEntry);
                    //             TradePartnerList."Last Order Sync" := CREATEDATETIME(WORKDATE, TIME);
                    //             TradePartnerList.MODIFY;
                    //         END;



                    //     END;
                    //     UNTIL TradePartnerList.NEXT = 0;




                end;
            }

            action("Sync Shipment")
            {
                Caption = 'Sync Shipment';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;
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

                            Codeunit.Run(TradePartnerList."Order Import Codeunit", JobQueueEntry);//NG_need_to_check
                            JobQueueEntry.Delete();
                        until TradePartnerList.Next() = 0;
                end;

            }
            action("Sync Location")
            {
                Caption = 'Sync Location';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Channelcode: Code[10];
                //LinnWorks: Codeunit "LinnWorks Integration";

                begin
                    Rec.Reset();
                    CurrPage.SetSelectionFilter(Rec);
                    If TradePartnerList.Findset() then begin
                        Channelcode := 'LINNWORKS';//CopyStr(TradePartnerList.Code, 1, 9);
                        if Channelcode = 'LINNWORKS' then;
                        //LinnWorks.GetLinnworksLocation();
                    end;
                end;

            }
            action("Sync Customer")
            {
                ApplicationArea = All;
                Image = Customer;
                trigger OnAction()
                var
                    myInt: Integer;
                    B2B: Codeunit B2B;
                    TradePartner: Record "Trade Partner";
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

            action("Item Cross Reference")
            {
                Caption = 'Item Cross Reference';
                Image = Change;
                Promoted = true;
                PromotedCategory = Category4;
                Visible = true;
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
            action("&Channel Browse Node")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Channel Browse Node';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin


                end;
            }
            action("&Channel Attribute Attributes")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Channel Attribute Attributes';
                Image = Category;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
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


    trigger OnAfterGetRecord()
    var
        myInt: Integer;
        ChannelSetup: Record "General Setup - Channels";
    begin
        Clear(EnableInvoiceTypeSelection);
        InboxTypeFile := rec."Inbox Type" = rec."Inbox Type"::"File Location";
        //Ranjit 11062018
        // InStr | InStream
        rec.CALCFIELDS(Token);
        IF rec.Token.HASVALUE THEN BEGIN
            rec.Token.CREATEINSTREAM(Instr);
            Instr.READ(TokenText);
        END;

        InboxTypeFile := rec."Inbox Type" = rec."Inbox Type"::"File Location";
        InboxTypeAPI := rec."Inbox Type" = rec."Inbox Type"::"Web service";
        EnableInvoiceTypeSelection := Rec."Process Order Type" = Rec."Process Order Type"::"Internal Pick";

        ChannelSetup.Get();
        if ChannelSetup."Print Return Note" = false then
            Flag := false
        else
            Flag := true;
    end;

    var
        InboxTypeFile: Boolean;
        InboxTypeAPI: Boolean;
        TradePartnerList: Record "Trade Partner";
        JobQueueEntry: Record 472;
        TokenText: Text;
        Instr: InStream;
        MyText: Text[1000];
        NewText: Text[1000];
        OutStr: OutStream;

        EnableInvoiceTypeSelection: Boolean;
        Flag: Boolean;
}