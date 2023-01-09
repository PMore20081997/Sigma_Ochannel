table 90011 "Channel Item Listing"
{
    fields
    {
        field(1; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Trade Partner".Code WHERE("Partner Type" = FILTER("Channel"));
            trigger OnValidate()
            begin

            end;
        }
        field(2; "Channel SKU"; Text[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin

            end;
        }
        field(3; "ASIN No"; Code[50])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                /*IF Rec."Channel Code" = 'AMAZON' THEN BEGIN
                    TradePartner.RESET;
                    TradePartner.SETRANGE(Code, Rec."Channel Code");
                    IF TradePartner.FINDSET THEN BEGIN
                        IF TradePartner."Automatic Listing" = TRUE THEN BEGIN
                            Rec.VALIDATE(Status, Rec.Status::Active);
                        END;
                    END;
                END;*/
            end;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'No.', ENG = 'No.';
            TableRelation = Item."No.";
            trigger OnValidate()
            var
                Item1: Record 27;
                itemvendor: Record 99;
                Chancode: Code[20];
                ChannelInventory: Decimal;
            begin
                //IF Rec."Channel Title" = '' THEN BEGIN  //Commented by Shubham12052022
                Item1.RESET;
                IF Item1.GET("Item No.") THEN BEGIN
                    //ChannelInventory := Item1.Inventory - Item1."Qty. on Sales Order";
                    //Validate(Rec."Channel Inventory", ChannelInventory);
                    VALIDATE(Rec."Description 2", Item1."Description 2");
                    VALIDATE(Rec.Description, Item1.Description);
                    //VALIDATE(Rec.UOM, Item1."Base Unit of Measure");
                    VALIDATE(Rec."Channel Unit Price", Item1."Unit Price");
                    VALIDATE(Rec."Unit Price", Item1."Unit Price");
                    // VALIDATE(Rec."Channel Title", Description); commented by pavan 
                    //  VALIDATE("Channel SKU", Item1."No.");
                    //VALIDATE(Rec.Brand, Item1.brand);
                    VALIDATE(Rec."Item Category Code", Item1."Item Category Code");
                END;
                //END;

                SalesPrice.RESET;
                //SalesPrice.SETRANGE(SalesPrice."Item No.", Rec."Item No.");
                //SalesPrice.SETRANGE(SalesPrice."Sales Code", Rec."Channel Code");
                SalesPrice.SETRANGE("Unit of Measure Code", Rec."Unit of Measure code");
                IF SalesPrice.FINDSET THEN BEGIN
                    // VALIDATE(Rec."Channel Unit Price", SalesPrice."Unit Price");
                END;

                itemvendor.RESET;
                itemvendor.SETRANGE("Item No.", Rec."Item No.");
                //itemvendor.SETRANGE(Default, TRUE);
                IF itemvendor.FINDFIRST THEN BEGIN
                    Item1.CALCFIELDS(Inventory, "Qty. on Sales Order");
                    //VALIDATE("Channel Inventory", (Item1.Inventory + itemvendor."Available Stock" - Item1."Qty. on Sales Order"));
                END;
                IF "Item No." <> '' THEN
                    VALIDATE(Rec.Action, Rec.Action::Update)
                ELSE
                    VALIDATE(Rec.Action, Rec.Action::Create);

                IF Item1.GET("Item No.") THEN
                    Rec."Unit of Measure code" := Item1."Base Unit of Measure";

                SalesPrice.RESET;
                //SalesPrice.SETRANGE(SalesPrice."Item No.", Rec."Item No.");
                //SalesPrice.SETRANGE(SalesPrice."Sales Code", Rec."Channel Code");
                SalesPrice.SETRANGE("Unit of Measure Code", Rec."Unit of Measure code");
                IF SalesPrice.FINDSET THEN BEGIN
                    VALIDATE(Rec."Unit Price", SalesPrice."Unit Price");
                END;

                itemvendor.RESET;
                itemvendor.SETRANGE("Item No.", Rec."Item No.");
                //itemvendor.SETRANGE(Default, TRUE);
                IF itemvendor.FINDFIRST THEN BEGIN
                    Item1.CALCFIELDS(Inventory, "Qty. on Sales Order");
                    //VALIDATE("Channel Inventory", (Item1.Inventory + itemvendor."Available Stock" - Item1."Qty. on Sales Order"));
                END;
                IF "Item No." <> '' THEN
                    VALIDATE(Rec.Action, Rec.Action::Update)
                ELSE
                    VALIDATE(Rec.Action, Rec.Action::Create);
            end;
        }
        field(5; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Description', ENG = 'Description';
        }
        field(6; "Description 2"; Text[50])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Description 2', ENG = 'Description 2';
        }
        field(7; "Unit of Measure code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Unit of Measure";
            ValidateTableRelation = false;
            CaptionML = ENU = 'Unit of Measure Code', ENG = 'Unit of Measure Code';
            // ObsoleteState = Removed;
            trigger OnValidate()
            var
                UnitOfMeasure: Record 204;
            begin
            end;
        }
        field(10; "Channel Inventory"; Decimal)
        {

        }

        field(11; "Channel Description"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(12; "Channel Title"; Text[250])
        {
            DataClassification = ToBeClassified;

        }
        field(13; "Channel Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
            AutoFormatType = 2;
            CaptionML = ENU = 'Channel Unit Price', ENG = 'Channel Unit Price';
            trigger OnValidate()
            begin
                CalculateMargin;
                //MODIFY;
                IF xRec."Channel Unit Price" <> Rec."Channel Unit Price" THEN BEGIN
                    VALIDATE("Price Synced", FALSE);
                END;
            end;
        }
        field(14; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Listing Status', ENG = 'Listing Status';
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(15; "Listing Date"; DateTime)
        {

        }
        field(16; "Created On"; DateTime)
        {

        }
        field(17; "Created By"; Code[20])
        {

        }
        field(18; "Modified On"; DateTime)
        {

        }
        field(19; "Modified By"; Code[20])
        {

        }
        field(20; Status; Option)
        {
            CaptionML = ENU = 'Status', ENG = 'Status';
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
            trigger OnLookup()
            begin
                IF Rec."Listing Status" = Rec."Listing Status"::Listed THEN
                    ERROR('Unable to change status of this Record..Item already Listed on Channel');
            end;
        }

        field(22; FeedType; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Product,"Product Inventary",Price;
            OptionCaptionML = ENU = 'Product,Product Inventary,Price', ENG = 'Product,Product Inventary,Price';
        }
        field(25; Manufacturer; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(26; Brand; Code[20])
        {
            DataClassification = ToBeClassified;

        }

        field(31; Remarks; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(32; EAN; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'EAN/UPC/ISBN', ENG = 'EAN/UPC/ISBN';
        }
        field(33; "Feed Submission ID"; Code[30])
        {
            DataClassification = ToBeClassified;

        }
        field(34; Action; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Action', ENG = 'Action';
            OptionMembers = Create,Update,Updated;
            OptionCaptionML = ENU = 'Create,Update,Updated', ENG = 'Create,Update,Updated';
        }
        field(35; RemarksPrice; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(36; "Feed Submission ID Price"; Code[30])
        {
            DataClassification = ToBeClassified;

        }

        field(42; "Nav Item Inventory"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No.")));
            //"Location Code" = FIELD("Location Filter"),
            //"Variant Code" = FIELD("Variant Filter"),
            //"Lot No." = FIELD("Lot No. Filter")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            CaptionML = ENU = 'Nav Item Inventory', ENG = 'Nav Item Inventory';
        }
        field(45; "Price Synced"; Boolean)
        {

        }
        field(46; "Inventory Synced"; Boolean)
        {

        }
        field(47; SpecialPriceSynced; Boolean)
        {
            InitValue = true;
        }
        field(48; "Item Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Category".Code;
        }
        field(49; "Show_Prod_On_Homepage"; Boolean)
        {

        }
        field(51; "Original Inventory"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Description = 'CAS-08801-S8B5M5';
            Editable = false;
        }
        field(52; "Special Price"; Decimal)
        {
            Description = 'CAS-08836-G8V3G1';
        }
        field(53; "Special Price Start Date"; Date)
        {
            Description = 'CAS-08836-G8V3G1';
        }
        field(54; "Special Price End Date"; Date)
        {
            Description = 'CAS-08836-G8V3G1';
        }
        field(55; "Unit Price"; Decimal)
        {

        }
        field(56; "Unit List Price"; Decimal)
        {

        }
        field(57; "Qty Per Unit of Measure"; Decimal)
        {
            Caption = 'Qty Per Unit of Measure';
        }
        field(50001; "NAV Variant"; Code[10])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-10666-T7Q5W8';
        }
        field(50002; "Channel Variant"; Text[50])  //Shubham Changed From Code[10] to Text[50] 11052021
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-10666-T7Q5W8';
        }
        field(50010; "Inventory Remark"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50011; "Image Url 1"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(50012; "Image Url 2"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(50013; "Product Name"; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50014; "Feed SubmissionID Inventory"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50015; "Feed SubmissionID Image"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50016; "Remarks Image Upload"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50017; "Feed SubmissionID Price"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50018; Featured; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50019; "Short Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50020; "Long Description"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(50021; "EComm Category"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50022; "Channel Category ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50023; "Channel category name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50024; "Channel brand ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50025; "Channel brand name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50026; "Meta description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50027; Slug; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50028; "Long Description 2"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(50029; "Channel Category Long Name"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50030; "Title Tag"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(50100; Volume; Decimal)
        {
            CaptionML = ENU = 'Volume (ml)', ENG = 'Volume (ml)';
        }
        field(50101; Size; Code[20])
        {
        }
        field(50102; "Pack"; Decimal)
        {
            DecimalPlaces = 0 : 0;
            trigger OnValidate()
            var
                myInt: Integer;
            begin

            end;
        }
        field(50103; "Pack Description"; Text[50])
        {
            Editable = true;
            // FieldClass = FlowField;
            // CalcFormula = lookup ("Item Unit of Measure"."Pack Description" WHERE("Item No." = field("No."), Code = field("Base Unit of Measure")));
        }
        field(50104; "ABV (%)"; Decimal)
        {

        }

    }
    keys
    {
        key(PK; "Channel Code", "Channel SKU", "ASIN No", "Channel Variant")
        {
            Clustered = true;
        }
    }

    var
        Rec1: Record "Channel Item Listing";
        SalesPrice: Record "Price List Line";
        TradePartner: Record "Trade Partner";
        Item: Record Item;


    PROCEDURE CalculateMargin();
    VAR
        unitprice: Decimal;
    BEGIN
        IF (("Special Price Start Date" <= WORKDATE) OR ("Special Price End Date" = 0D)) AND (("Special Price End Date" >= WORKDATE) OR ("Special Price End Date" = 0D)) THEN BEGIN
            IF "Special Price" > 0 THEN
                unitprice := "Special Price"
            ELSE BEGIN
                IF "Channel Unit Price" <> 0 THEN
                    unitprice := "Channel Unit Price";
            END;
        END ELSE BEGIN
            IF "Channel Unit Price" <> 0 THEN
                unitprice := "Channel Unit Price";
        END;
        //Margin := SalesPrice.UpdateMarginPrice("Item No.", unitprice);
    END;

    procedure UpdateItemNo()
    var
        CIL: Record "Channel Item Listing";
        Window: Dialog;
        NoOfRecs: Integer;
        T_Item: Text;
    begin
        CIL.RESET;
        CIL.SETRANGE("Item No.", '');
        Window.OPEN('Update Item Coupling....' + ' @1@@@@@@@@@@@@@\' + CIL.FIELDCAPTION("Channel SKU") + ' #3##########');
        IF CIL.FINDSET THEN BEGIN
            REPEAT
                NoOfRecs := CIL.COUNT;
                CLEAR(T_Item);
                // T_Item := GetItemNoCoupling(CIL."Channel SKU", CIL.EAN, CIL."Channel Code");
                T_Item := ProcessCouplingItemNo(CIL."Channel SKU", CIL."ASIN No");
                IF T_Item <> '' THEN BEGIN
                    CIL.VALIDATE("Item No.", T_Item);
                    CIL.VALIDATE(Action, CIL.Action::Updated);
                    CIL.VALIDATE("Listing Status", CIL."Listing Status"::Listed);
                    CIL.VALIDATE(Status, CIL.Status::Active);
                    CIL.MODIFY;
                END;
            UNTIL CIL.NEXT = 0;
        END;
    end;

    procedure ProcessCouplingItemNo(P_SKU: Text; P_ASIN: Text): Code[20]
    var
        ItemNo: Code[20];
    BEGIN
        Item.RESET;
        if P_SKU <> '' then begin
            IF STRLEN(P_SKU) <= 20 THEN BEGIN
                CLEAR(ItemNo);
                ItemNo := CheckAvaliableItem_sku(P_SKU);
                if (ItemNo = '') then begin
                    ItemNo := CheckAvaliableItem_ASIN(P_ASIN);
                end;
                IF ItemNo <> '' THEN
                    EXIT(ItemNo);
            END;
        end;
    END;

    local procedure CheckAvaliableItem_sku(VAR TxtItem: Text): Code[20]
    var

    begin
        if TxtItem <> '' then begin
            IF STRLEN(TxtItem) <= 20 THEN BEGIN
                Item.RESET;
                Item.SETRANGE("No.", TxtItem);
                IF Item.FINDSET THEN
                    EXIT(Item."No.");

                Item.RESET;
                Item.SETRANGE("No. 2", TxtItem);
                IF Item.FINDSET THEN
                    EXIT(Item."No. 2");

                Item.RESET;
                Item.SETRANGE("Common Item No.", TxtItem);
                IF Item.FINDSET THEN
                    EXIT(Item."Common Item No.");
            END;
        end;
    end;

    local procedure CheckAvaliableItem_ASIN(VAR TxtItem: Text): Code[20]
    var
        ItemCrossReference: Record "Item Reference";
    BEGIN
        if TxtItem <> '' then begin
            IF STRLEN(TxtItem) <= 20 THEN BEGIN
                Item.RESET;
                Item.SETRANGE(GTIN, TxtItem);
                IF Item.FINDSET THEN
                    EXIT(Item."No.");
            END;

            ItemCrossReference.RESET;
            ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::"Bar Code");
            ItemCrossReference.SETRANGE("Reference No.", TxtItem);
            IF ItemCrossReference.FINDSET THEN
                EXIT(ItemCrossReference."Item No.");
        end;
    END;

    procedure GetItemNoCoupling(P_SKU: Text; P_EAN: Text; ChannelCode: Code[20]): Code[20]
    var

        ItemNo: Code[20];
    begin
        Item.RESET;

        IF STRLEN(P_SKU) <= 20 THEN BEGIN

            CLEAR(ItemNo);
            ItemNo := GetAvailableItem(P_SKU, ChannelCode);

            IF ItemNo <> '' THEN
                EXIT(ItemNo);
        END;

        // IF ChannelCode <> 'MAGENTO' THEN BEGIN
        //     IF P_EAN <> '' THEN BEGIN
        //         CLEAR(ItemNo);
        //         ItemNo := GetAvailableItem(P_EAN, ChannelCode);
        //         IF ItemNo <> '' THEN
        //             EXIT(ItemNo);
        //     END;

        // END;

    end;

    local procedure GetAvailableItem(VAR TxtItem: Text; ChannelCode: Code[20]): Code[20]
    var
        ItemCrossReference: Record "Item Reference";

    begin
        IF STRLEN(TxtItem) <= 20 THEN BEGIN
            Item.RESET;
            Item.SETRANGE("No.", TxtItem);
            IF Item.FINDSET THEN
                EXIT(Item."No.");


            /*Item.RESET;
            Item.SETRANGE(EAN, TxtItem);
            IF Item.FINDSET THEN
                EXIT(Item."No.");

            Item.RESET;
            Item.SETRANGE(UPC, TxtItem);
            IF Item.FINDSET THEN
                EXIT(Item."No.");*/

            // IF STRLEN(TxtItem) <= 14 THEN BEGIN
            //     Item.RESET;
            //     Item.SETRANGE(GTIN, TxtItem);
            //     IF Item.FINDSET THEN
            //         EXIT(Item."No.");
            // END;


            ItemCrossReference.RESET;
            ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::"Bar Code");
            ItemCrossReference.SETRANGE("Reference No.", TxtItem);
            IF ItemCrossReference.FINDSET THEN
                EXIT(ItemCrossReference."Item No.");
        END;
    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


}