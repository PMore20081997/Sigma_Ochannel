table 90011 "Channel Item Listing"
{
    fields
    {
        field(1; "Channel Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Trade Partner".Code WHERE("Partner Type" = FILTER("Channel"));
        }
        field(2; "Channel SKU"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "ASIN No"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'No.', ENG = 'No.';
            TableRelation = Item."No.";
            trigger OnValidate()
            var
                Item1: Record 27;
            begin
                Item1.RESET;
                IF Item1.GET("Item No.") THEN BEGIN
                    VALIDATE(Rec."Description 2", Item1."Description 2");
                    VALIDATE(Rec.Description, Item1.Description);
                    VALIDATE(Rec."Channel Unit Price", Item1."Unit Price");
                    VALIDATE(Rec."Unit Price", Item1."Unit Price");
                    Rec.Validate(RRP, Item1.RRP);
                    VALIDATE(Rec."Item Category Code", Item1."Item Category Code");
                    Rec."Sales Blocked" := Item1."Sales Blocked";
                    Rec."Ops Sales Blocked" := Item1."Ops Sales Blocked";
                    Rec."Min Sell Price" := Item1."Min Sell Price";
                END;

                IF Item1.GET("Item No.") THEN
                    Rec."Unit of Measure code" := Item1."Base Unit of Measure";

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
        }
        field(8; "Channel Inventory"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Caption = 'Free Qty.';
            Editable = false;
            trigger OnValidate()
            begin
                #Region Sigconnect only++
                if Rec."Channel Code" = 'SIGCONNECT' then begin
                    IF xRec."Channel Inventory" <> Rec."Channel Inventory" THEN
                        Rec.VALIDATE("Inventory Synced", FALSE);
                end;
                #EndRegion Sigconnect only++
            end;
        }
        field(9; "Channel Description"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Channel Title"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Channel Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
            AutoFormatType = 2;
            CaptionML = ENU = 'Channel Unit Price', ENG = 'Channel Unit Price';
            trigger OnValidate()
            begin
                #Region Sigconnect only++
                if Rec."Channel Code" = 'SIGCONNECT' then begin
                    IF xRec."Channel Unit Price" <> Rec."Channel Unit Price" THEN BEGIN
                        VALIDATE("Price Synced", FALSE);
                    END;
                end;
                #EndRegion Sigconnect only++
            end;
        }
        field(12; "Listing Status"; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Listing Status', ENG = 'Listing Status';
            OptionMembers = "Not Listed",Listed;
            OptionCaptionML = ENU = 'Not Listed,Listed', ENG = 'Not Listed,Listed';
        }
        field(13; "Listing Date"; DateTime)
        {
        }
        field(14; "Created On"; DateTime)
        {
        }
        field(15; "Created By"; Code[20])
        {
        }
        field(16; "Modified On"; DateTime)
        {
        }
        field(17; "Modified By"; Code[20])
        {
        }
        field(18; Status; Option)
        {
            OptionMembers = Inactive,Active;
            OptionCaptionML = ENU = 'Inactive,Active', ENG = 'Inactive,Active';
            trigger OnValidate()
            var
            begin
                if Rec.Status = Rec.Status::Inactive then
                    Rec."Item Sync" := false;

                #Region Sigconnect only++
                if Rec."Channel Code" = 'SIGCONNECT' then begin
                    //SBB-592
                    if Rec.Status <> xRec.Status then
                        Rec."Channel Inventory" := 0;
                end;
                #EndRegion Sigconnect only++
            end;
        }
        field(19; FeedType; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Product,"Product Inventary",Price;
            OptionCaptionML = ENU = 'Product,Product Inventary,Price', ENG = 'Product,Product Inventary,Price';
        }
        field(20; Manufacturer; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(21; Brand; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(22; Remarks; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(23; EAN; Code[20])
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'EAN/UPC/ISBN', ENG = 'EAN/UPC/ISBN';
        }
        field(24; "Feed Submission ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(25; Action; Option)
        {
            DataClassification = ToBeClassified;
            CaptionML = ENU = 'Action', ENG = 'Action';
            OptionMembers = Create,Update,Updated;
            OptionCaptionML = ENU = 'Create,Update,Updated', ENG = 'Create,Update,Updated';
        }
        field(26; RemarksPrice; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Feed Submission ID Price"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Price Synced"; Boolean)
        {
        }
        field(29; "Inventory Synced"; Boolean)
        {
        }
        field(30; SpecialPriceSynced; Boolean)
        {
            InitValue = true;
        }
        field(31; "Item Category Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Category".Code;
        }
        field(32; "Original Inventory"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Description = 'CAS-08801-S8B5M5';
            Editable = false;
        }
        field(33; "Special Price"; Decimal)
        {
            Description = 'CAS-08836-G8V3G1';
        }
        field(34; "Special Price Start Date"; Date)
        {
            Description = 'CAS-08836-G8V3G1';
        }
        field(35; "Special Price End Date"; Date)
        {
            Description = 'CAS-08836-G8V3G1';
        }
        field(36; "Unit Price"; Decimal)
        {
        }
        field(37; "Qty Per Unit of Measure"; Decimal)
        {
            Caption = 'Qty Per Unit of Measure';
        }
        field(38; "NAV Variant"; Code[10])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-10666-T7Q5W8';
            Caption = 'BC Variant';
        }
        field(39; "Channel Variant"; Text[50])
        {
            DataClassification = ToBeClassified;
            Description = 'CAS-10666-T7Q5W8';
        }
        field(40; "Inventory Remark"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Image Url 1"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Pack Size"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(43; RRP; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(44; "Allcoated on SO"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Outstanding Qty. (Base)" where("Document Type" = CONST(Order), Type = CONST(Item), "No." = field("Item No."), "Outstanding Qty. (Base)" = filter(> 0), "Saleable Location" = const(true), "Shipment Date" = field("Date Filter")));
            DecimalPlaces = 0 : 5;
            Caption = 'Allocated on SO.';
            Editable = false;
        }
        field(45; "Web Orders Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Interim Sales Line"."Qty. to Deliver" where("Document Type" = const(Order), Type = const(Item), "No." = field("Item No."), "Reason Code" = filter('Order line created|Partial Quantity Delivered'), "Sales Order Created" = const(false), "Consolidated Order" = const(false)));
            DecimalPlaces = 0 : 5;
        }
        field(46; "Physical Inventory"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."), "Saleable Location" = const(true), "Daily Priority Exist" = field("Variant Code Mandatory")));
            DecimalPlaces = 0 : 5;
            Caption = 'Physical';
            Editable = false;
        }
        field(47; "Variant Code Mandatory"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Item Variant" where("Item No." = field("Item No.")));
        }
        field(48; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(49; "Item Sync"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Sales Blocked"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Ops Sales Blocked"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Lowstock Threshold"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Transaction No."; Integer)
        {

        }
        field(54; "Min Sell Price"; Decimal)
        {

        }
        field(55; "Variant Mandatory if Exists"; Option)
        {
            OptionMembers = Default,No,Yes;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Variant Mandatory if Exists" where("No." = field("Item No.")));
        }
        field(56; "Item SystemModifiedAt"; DateTime)
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item.SystemModifiedAt where("No." = field("Item No.")));
        }
        field(57; "Work Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(58; "Full-Invetory Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("LifeRay Stock" where("Item No." = field("Item No."), "Sync Type" = const(Full), "Created On" = field("Work Date Filter")));
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
        Item: Record Item;


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