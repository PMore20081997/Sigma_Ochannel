page 90022 "Item Coupling"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Channel Item Listing";
    CaptionML = ENU = 'Item Coupling', ENG = 'Item Coupling';
    DelayedInsert = true;
    RefreshOnActivate = true;

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
                    CaptionML = ENU = 'Channel SKU', ENG = 'Channel SKU';


                }
                field(ASIN; Rec."ASIN No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    CaptionML = ENU = 'ASIN', ENG = 'ASIN';
                }
                field(EAN; Rec.EAN)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Channel Title"; Rec."Channel Title")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Inventory"; Rec."Channel Inventory")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Action; Rec.Action)
                {
                    ApplicationArea = All;

                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Listing Status"; Rec."Listing STatus")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Modified On"; Rec."Modified On")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Modified By"; Rec."Modified By")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Created On"; Rec."Created On")
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
            action("All Lines")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Update EAN Code';
                Promoted = true;
                Visible = false;
                Image = BarCode;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ItemCrossReference: Record "Item Reference";
                    RecItemCrossReference: Record "Item Reference";
                    CIL: Record "Channel Item Listing" temporary;
                begin
                    CIL.COPY(Rec);
                    CurrPage.SETSELECTIONFILTER(CIL);

                    IF CIL.FINDSET THEN
                        REPEAT
                            //ItemCrossReference.SETRANGE(ItemCrossReference."Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
                            ItemCrossReference.SETRANGE(ItemCrossReference."Item No.", CIL."Item No.");
                            ItemCrossReference.SETRANGE(ItemCrossReference."Reference No.", CIL."ASIN No");
                            IF NOT ItemCrossReference.FINDSET THEN BEGIN
                                RecItemCrossReference.INIT;
                                //RecItemCrossReference.VALIDATE(RecItemCrossReference."Cross-Reference Type",RecItemCrossReference."Cross-Reference Type"::"Bar Code");
                                //ItemCossReference.VALIDATE(ItemCossReference."Cross-Reference Type No.",Rec.EAN);
                                RecItemCrossReference.VALIDATE(RecItemCrossReference."Item No.", CIL."Item No.");
                                RecItemCrossReference.VALIDATE(RecItemCrossReference."Reference No.", CIL."ASIN No");
                                RecItemCrossReference.INSERT;
                            END;
                        UNTIL CIL.NEXT = 0;
                end;
            }

            action("Update All Supplier Prices Lines")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Update All Supplier Prices',
                ENG = 'Update All Supplier Prices';
                Promoted = true;
                Image = UpdateDescription;
                PromotedCategory = Process;
            }

            action("Update New Supplier Prices Lines")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Update New Supplier Prices',
                ENG = 'Update New Supplier Prices';
                Promoted = true;
                Image = UpdateDescription;
                PromotedCategory = Process;
            }
            action("Process Item")
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Process Item',
                ENG = 'Process Item';
                Promoted = true;
                Image = CreateForm;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    RecItem: Record 27;
                    ItemCossReference: Record "Item Reference";
                    ItemTemplate: Record "Item Templ.";
                    Item: Record 27;
                    Count: Integer;
                    ConfigTemplateHeader: Record 8618;
                    NoOfRecords: Integer;
                    Counter: Integer;
                    Window: Dialog;
                    Text005: TextConst ENU = 'Calculating..//';
                    Text006: TextConst ENU = 'Creating item...';
                    UnitPrice: Decimal;
                    CIL: Record "Channel Item Listing";
                    ItemCrossReference: Record "Item Reference";
                    RecItemCrossReference: Record "Item Reference";
                    Text007: TextConst ENU = 'Updating Item...';
                    Item2: Record 27;
                begin
                    // CurrPage.SETSELECTIONFILTER(Rec);
                    CIL.COPY(Rec);
                    CurrPage.SETSELECTIONFILTER(CIL);
                    //UpdateItemNoInRec(CIL);
                    CIL.SETFILTER(CIL."Item No.", '%1', '');
                    CIL.SetFilter("Channel SKU", '<>%1', '');
                    IF CIL.FIND('-') THEN BEGIN
                        //Item.VALIDATE("No.",CIL."Channel SKU");
                        IF ItemTemplate.NewItemFromTemplate(Item) THEN; //BEGIN
                        // RecItem.COPY(Item);
                        // END;
                        Counter := 0;
                        NoOfRecords := 0;
                        Window.OPEN(
                        Text006 + ' @1@@@@@@@@@\' +
                        CIL.FIELDCAPTION(EAN) + ' #3#########');

                        REPEAT
                            //IF Count > 0 THEN BEGIN
                            NoOfRecords := CIL.COUNT;
                            Counter := Counter + 1;

                            Window.UPDATE(1, ROUND(Counter / NoOfRecords * 10000, 1));
                            Window.UPDATE(3, CIL.EAN);
                            IF STRLEN(CIL."Channel SKU") <= 20 THEN BEGIN
                                CLEAR(Item);
                                CLEAR(RecItem);
                                IF NOT Item2.GET(CIL."Channel SKU") THEN BEGIN
                                    IF STRLEN(CIL."Channel SKU") <= 20 THEN
                                        Item.VALIDATE("No.", CIL."Channel SKU")
                                    ELSE BEGIN
                                        Item.VALIDATE("No.", COPYSTR(CIL."Channel SKU", 1, 20));//Pavan
                                    END;
                                    ItemTemplate.InsertItemFromTemplate(ConfigTemplateHeader, Item);
                                    RecItem.COPY(Item);
                                    Title := CIL."Channel Title";
                                    IF (STRLEN(Title) > 50) THEN BEGIN
                                        Rec.Description := COPYSTR(CIL."Channel Title", 1, 50);
                                        Rec."Description 2" := COPYSTR(CIL."Channel Title", 51, 50);
                                    END
                                    ELSE
                                        RecItem.VALIDATE(Description, CIL."Channel Title");

                                    RecItem.MODIFY(TRUE);

                                    ItemCossReference.INIT;
                                    //ItemCossReference.VALIDATE(ItemCossReference."Cross-Reference Type",ItemCossReference."Cross-Reference Type"::"Bar Code");
                                    //ItemCossReference.VALIDATE(ItemCossReference."Cross-Reference Type No.",Rec.EAN);
                                    ItemCossReference.VALIDATE(ItemCossReference."Item No.", RecItem."No.");
                                    ItemCossReference.VALIDATE(ItemCossReference."Reference No.", CIL."ASIN No");
                                    ItemCossReference.INSERT;

                                    CIL.VALIDATE("Item No.", RecItem."No.");
                                    //CIL.VALIDATE("UOM", RecItem."Base Unit of Measure");
                                    CIL.Action := CIL.Action::Updated;
                                    // for magento
                                    IF CIL."Channel Code" = 'MAGENTO' THEN BEGIN
                                        CIL.Status := CIL.Status::Active;
                                        CIL."Listing Status" := CIL."Listing Status"::Listed;
                                    END;
                                    //
                                    //For Prestashop
                                    IF CIL."Channel Code" = 'PRESTA' THEN BEGIN
                                        CIL.Status := CIL.Status::Active;
                                        CIL."Listing Status" := CIL."Listing Status"::Listed;
                                    END;
                                    //
                                    //For EBAY
                                    IF CIL."Channel Code" = 'EBAY' THEN BEGIN
                                        CIL.Status := CIL.Status::Active;
                                        CIL."Listing Status" := CIL."Listing Status"::Listed;
                                    END;

                                    IF CIL."Channel Code" = 'AMAZON' THEN BEGIN
                                        CIL.Status := CIL.Status::Active;
                                        CIL."Listing Status" := CIL."Listing Status"::Listed;
                                    END;
                                    if CIL."Channel Code" = 'DIRECT' then begin
                                        CIL.Status := CIL.Status::Active;
                                        CIL."Listing Status" := CIL."Listing Status"::Listed;
                                    end;


                                    Count += 1;
                                END
                                ELSE
                                    CIL.VALIDATE(Remarks, 'Item already exists with SKU ' + CIL."Channel SKU");
                            END
                            ELSE
                                CIL.VALIDATE(Remarks, 'Length of SKU ' + CIL."Channel SKU" + ' is greater Character limit of 20');
                            CIL.MODIFY;
                        UNTIL CIL.NEXT = 0;
                        Window.CLOSE;
                    END;


                    //CIL1.COPY(Rec);
                    Counter := 0;
                    NoOfRecords := 0;
                    CLEAR(Counter);
                    CIL.SETFILTER(CIL."Item No.", '<>%1', '');
                    IF CIL.FINDSET THEN BEGIN
                        NoOfRecords := CIL.COUNT;
                        Window.OPEN(Text006 + ' @1@@@@@@@@@\' + CIL.FIELDCAPTION("Item No.") + ' #3#########');
                        REPEAT
                            //ItemCrossReference.SETRANGE(ItemCrossReference."Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
                            ItemCrossReference.SETRANGE(ItemCrossReference."Item No.", CIL."Item No.");
                            ItemCrossReference.SETRANGE(ItemCrossReference."Reference No.", CIL."ASIN No");
                            IF NOT ItemCrossReference.FINDSET THEN BEGIN
                                Counter := Counter + 1;
                                Window.UPDATE(1, ROUND(Counter / NoOfRecords * 10000, 1));
                                Window.UPDATE(3, Rec."Item No.");

                                RecItemCrossReference.INIT;
                                RecItemCrossReference.VALIDATE(RecItemCrossReference."Reference Type", RecItemCrossReference."Reference Type"::"Bar Code");
                                //ItemCossReference.VALIDATE(ItemCossReference."Cross-Reference Type No.",Rec.EAN);
                                RecItemCrossReference.VALIDATE(RecItemCrossReference."Item No.", CIL."Item No.");
                                RecItemCrossReference.VALIDATE(RecItemCrossReference."Reference No.", CIL."ASIN No");
                                RecItemCrossReference.INSERT;
                                CIL.VALIDATE(Action, CIL.Action::Updated);
                                // for magento
                                IF CIL."Channel Code" = 'MAGENTO' THEN BEGIN
                                    CIL.Status := CIL.Status::Active;
                                    CIL."Listing Status" := CIL."Listing Status"::Listed;
                                END;
                                //
                                IF CIL."Channel Code" = 'AMAZON' THEN BEGIN
                                    CIL.Status := CIL.Status::Active;
                                    CIL."Listing Status" := CIL."Listing Status"::Listed;
                                END;
                                //For Prestashop
                                IF CIL."Channel Code" = 'PRESTA' THEN BEGIN
                                    CIL.Status := CIL.Status::Active;
                                    CIL."Listing Status" := CIL."Listing Status"::Listed;
                                END;
                                //For EBAY
                                IF CIL."Channel Code" = 'EBAY' THEN BEGIN
                                    CIL.Status := CIL.Status::Active;
                                    CIL."Listing Status" := CIL."Listing Status"::Listed;
                                END;
                                if CIL."Channel Code" = 'DIRECT' then begin
                                    CIL.Status := CIL.Status::Active;
                                    CIL."Listing Status" := CIL."Listing Status"::Listed;
                                end;


                                CIL.MODIFY;
                            END;
                        UNTIL CIL.NEXT = 0;
                        Window.CLOSE;
                    END;
                end;
            }
        }
    }

    var
        ChannelItemListing: Record "Channel Item Listing" temporary;
        ItemCrossReference: Record "Item Reference";
        RecItemCrossReference: Record "Item Reference";
        Counter: Integer;
        NoOfRecords: Integer;
        Window: Dialog;
        Title: Text;
        Description: Text;



    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Text005: TextConst ENU = 'Calculating..//';
        Text006: TextConst ENU = 'Updating Item...';
    begin
        //Rec.COPY(ChannelItemListing);
        //ChannelItemListing.COPY(Rec);
        Rec.SETFILTER(Rec."Item No.", '<>%1', '');
        Rec.SETFILTER(Rec.Action, '<>%1', Rec.Action::Updated);
        IF Rec.FINDFIRST THEN BEGIN
            REPEAT
                //ItemCrossReference.SETRANGE(ItemCrossReference."Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
                ItemCrossReference.SETRANGE(ItemCrossReference."Item No.", Rec."Item No.");
                ItemCrossReference.SETRANGE(ItemCrossReference."Reference No.", Rec."ASIN No");
                Counter := 0;
                NoOfRecords := 0;
                Window.OPEN(Text006 + ' @1@@@@@@@@@\' + Rec.FIELDCAPTION("Item No.") + ' #3#########');
                IF NOT ItemCrossReference.FINDSET THEN BEGIN
                    NoOfRecords := Rec.COUNT;
                    Counter := Counter + 1;
                    Window.UPDATE(1, ROUND(Counter / NoOfRecords * 10000, 1));
                    Window.UPDATE(3, Rec."Item No.");

                    RecItemCrossReference.INIT;
                    //RecItemCrossReference.VALIDATE(RecItemCrossReference."Cross-Reference Type",RecItemCrossReference."Cross-Reference Type"::"Bar Code");
                    //ItemCossReference.VALIDATE(ItemCossReference."Cross-Reference Type No.",Rec.EAN);
                    RecItemCrossReference.VALIDATE(RecItemCrossReference."Item No.", Rec."Item No.");
                    RecItemCrossReference.VALIDATE(RecItemCrossReference."Reference No.", Rec."ASIN No");
                    RecItemCrossReference.INSERT;
                    Rec.VALIDATE(Action, Rec.Action::Updated);
                    Rec.MODIFY;
                END;
            UNTIL Rec.NEXT = 0;
        END;
    End;

    PROCEDURE NewItemsFromTemplate(VAR Item: Record 27; VAR P_ConfigTemplateHeader: Record 8618): Boolean;
    VAR
        ConfigTemplateHeader: Record 8618;
        ConfigTemplates: Page 1340;
        Itemtempalte: Record "Item Templ.";
    BEGIN
        ConfigTemplateHeader.SETRANGE("Table ID", DATABASE::Item);
        ConfigTemplateHeader.SETRANGE(Enabled, TRUE);

        IF ConfigTemplateHeader.COUNT = 1 THEN BEGIN
            ConfigTemplateHeader.FINDFIRST;
            Itemtempalte.InsertItemFromTemplate(ConfigTemplateHeader, Item);
            P_ConfigTemplateHeader := ConfigTemplateHeader;
            EXIT(TRUE);
        END;
    END;
}