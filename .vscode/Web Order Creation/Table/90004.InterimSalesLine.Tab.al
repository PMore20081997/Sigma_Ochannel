table 90004 "Interim Sales Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Document Type"; Enum "Web Document Type")
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;

        }
        field(2; "Document No"; Code[20])
        {

            DataClassification = ToBeClassified;

        }
        field(3; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;

        }
        field(4; "No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                L_Item: Record Item;
                L_GLAccount: Record "G/L Account";
            begin
                CASE Type OF
                    Type::Item:
                        BEGIN
                            /* IF L_Item.GET("No.") THEN
                                 "VAT Prod. Posting Group" := L_Item."VAT Prod. Posting Group";*/
                        END;
                    Type::"G/L Account":
                        BEGIN
                            IF L_GLAccount.GET("No.") THEN
                                "VAT Prod. Posting Group" := L_GLAccount."VAT Prod. Posting Group";
                        END;
                END;
            end;

        }
        field(5; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Description"; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(7; "Unit Price"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF (xRec."Unit Price" <> Rec."Unit Price") AND (Rec.Quantity > 0) THEN BEGIN
                    "Channel Price" := "Unit Price";
                    CalculateVatAmount(Rec);
                END;
            end;
        }
        field(8; Quantity; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF (Quantity > 0) THEN begin
                    //"Channel Price" := "Unit Price";
                    CalculateVatAmount(Rec);

                    CalculateBaseQuantity(Rec);
                end;
            end;
        }
        field(9; Amount; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(10; Discount; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(11; "VAT amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(12; Description2; Text[50])
        {
            Editable = false;
            DataClassification = ToBeClassified;

        }
        field(13; "Order Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "VAT Prod. Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var

            begin
                Validate(Quantity);
            end;
        }
        field(17; "Channel Identifier"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(18; "Channel Item Id"; Code[250])
        {
            DataClassification = ToBeClassified;

        }
        field(19; "Channel SKU"; Text[50])
        {
            DataClassification = ToBeClassified;

        }

        field(21; "Shipping Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(22; "Gift Wrap Price"; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(24; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "VAT%"; Text[30])
        {
            DataClassification = ToBeClassified;

        }

        field(27; "Line Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
        }

        field(28; "Discount %"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(29; "Gift Wrap"; Boolean)
        {
            DataClassification = ToBeClassified;

        }
        field(31; "NAV Variant code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Variant Code';

        }
        field(32; "Channel Variant"; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(34; "Units per Parcel"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(35; "Amount Including VAT"; Decimal)
        {
            // Editable = false;
            DataClassification = ToBeClassified;

        }
        field(36; "Currency Code"; Code[10])
        {
            Editable = false;
            TableRelation = Currency;
            DataClassification = ToBeClassified;

        }
        field(37; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;

        }

        field(39; "Shipping Agent Code"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Shipping Agent Code" WHERE("No." = field("Document No")));
            TableRelation = "Shipping Agent";
            AccessByPermission = TableData "Shipping Agent Services" = R;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF xRec."Shipping Agent Code" = "Shipping Agent Code" THEN
                    EXIT;

                "Shipping Agent Service Code" := '';
            end;

        }
        field(40; "Shipping Agent Service Code"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));


        }
        field(41; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DataClassification = ToBeClassified;

        }


        field(45; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;
            ValidateTableRelation = false;

        }
        field(47; "No of Error"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("Incoming/Outgoing Error Log" WHERE("Document No." = field("Document No"), "Item No." = field("No.")));

        }
        field(48; "Order Status"; Option)
        {
            OptionMembers = Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Cancelled,"Ready To Dispatch","No Stock","Partially Scanned";
            FieldClass = FlowField;
            //CalcFormula = Lookup("Interim Sales Header".Status WHERE("No." = field("Document No")));
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
            Editable = false;
        }
        field(50; "VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Validate(Quantity);
                VALIDATE("VAT Prod. Posting Group");
            end;

        }
        field(51; "Tracking No."; Code[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Shipment Tracking"."Tracking No." WHERE("Document Type" = FILTER(Order), "Document No." = field("No.")));


        }
        field(53; "Sell-to Customer No."; Code[20])
        {
            Editable = false;
            trigger OnValidate()
            var
                L_Customer: Record Customer;
            begin
                IF L_Customer.GET("Sell-to Customer No.") THEN
                    "VAT Bus. Posting Group" := L_Customer."VAT Bus. Posting Group";
            end;
        }
        field(54; "Channel Order ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Unit Cost(LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(50011; "Quantity Allocated"; Decimal)
        {
            FieldClass = Normal;
        }
        field(50015; "Allocated Status"; Option)
        {
            Editable = false;
            OptionMembers = "Not Allocated","Fully Allocated","Part Allocated","Ready To Dispatch","In Picking",Picked;
            DataClassification = ToBeClassified;

        }
        field(50026; Hazardous; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(50028; "Destination Doc. Line No"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(50029; Reserved; Boolean)
        {
            DataClassification = ToBeClassified;

        }

        field(50032; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            var
                myInt: Integer;
            begin
                If xRec."Unit of Measure Code" <> Rec."Unit of Measure Code" then
                    CalculateBaseQuantity(Rec);
            end;
        }
        field(50033; "Document Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Document Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));


        }
        field(50034; "Location Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Location Code" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(50036; "Scanned Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(50037; "Quantity(Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50038; "Item Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Single,Assembly,Component;
            OptionCaptionML = ENU = 'Single, Assembly, Component',
                              ENG = 'Single, Assembly, Component';
        }
        field(50039; "BOM Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50041; "Moved In Handled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50042; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Sales Order","Internal Pick";
            OptionCaptionML = ENU = ' ,Sales Order,Internal Pick',
                              ENG = ' ,Sales Order,Internal Pick';
        }
        field(50043; "Destination Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50044; "Trolley No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50045; "Dispatch Scan"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50046; "Price Authorised"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50047; FileName; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50048; "Channel Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(90011; "Pack Description"; Text[50])
        {
            Editable = true;
            // FieldClass = FlowField;
            // CalcFormula = lookup ("Item Unit of Measure"."Pack Description" WHERE("Item No." = field("No."), Code = field("Base Unit of Measure")));
        }
        field(90012; "ABV (%)"; Decimal)
        {

        }
        field(90013; Status; Option)
        {
            Editable = false;
            OptionMembers = Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Cancelled,"Ready To Dispatch","No Stock","Partially Scanned";
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(90014; "Pick No"; Code[20])
        {

        }
        field(90015; "Pick Line No"; Integer)
        {

        }
        field(90016; "Picking Status"; Option)
        {
            OptionMembers = " ","In Picking",Picked;

        }

        field(90018; "Multiline Order"; Boolean)
        {

        }
        field(90019; "Bay No."; Code[20])
        {

        }
        field(90020; "Trolley Closed Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity Handled';
        }
        field(90021; "Shelf No."; Code[20])
        {

        }
        field(90022; "Reserved Qty"; Decimal)
        {

        }
        //US-13166++
        field(90023; "Header Id"; Guid)
        {
            TableRelation = "Interim Sales Header".SystemId;
        }
        //US-13166--
        field(90030; "Gift Card"; Boolean)
        {

        }

        field(90031; order_id; Text[250])
        {

        }

        field(90032; order_line_id; Text[250])
        {

        }
        field(90046; "Reason Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90045; "Reason Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(90049; "ET Access Code"; Code[50])
        {

        }
        field(90050; "Sales Order Created"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Web Buffer" where("Web Document No." = field("Document No")));
        }
        field(90051; "Qty. to Deliver"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(90052; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(70048; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(70049; "Sig Channel Item Id"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(90053; "Variant Code Mandatory"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Item Variant" where("Item No." = field("No.")));
        }
    }

    keys
    {
        key(PK; "Document Type", "Document No", "Line No.")
        {
            Clustered = true;
        }
        key(key2; "Bay No.")
        {

        }
    }

    var
        CUWebOrderMgt: Codeunit "Web Order Mgt";

    trigger OnInsert()
    begin
        CUWebOrderMgt.ExplodeBoM(Rec);
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


    procedure CalculateVatAmount(VAR P_ISL: Record "Interim Sales Line")
    var
        L_ISH: Record "Interim Sales Header";
        L_TradePartner: Record "Trade Partner";
        L_Customer: Record Customer;
        L_Item: Record Item;
        L_GLAccount: Record "G/L Account";
        UnitVatAmount: Decimal;
        L_VatProdPostingSetup: Record "VAT Posting Setup";
        L_ItemVariant: Record "Item Variant";
        Countries: Record "Country/Region";
    begin
        L_ISH.RESET;
        L_ISH.SETRANGE("Document Type", P_ISL."Document Type");
        L_ISH.SETRANGE("No.", P_ISL."Document No");
        IF L_ISH.FINDFIRST THEN;

        L_TradePartner.GET(L_ISH."Trade Partner Code");

        //8862++
        if L_ISH."Ship-to Country/Region Code" = 'GB' then begin
            IF L_Customer.GET(L_ISH."Sell-to Customer No.") THEN;
            P_ISL."VAT Bus. Posting Group" := L_Customer."VAT Bus. Posting Group";
        end
        else begin
            if Countries.Get(L_ISH."Ship-to Country/Region Code") then begin
                if Countries."EU Country/Region Code" <> '' then begin
                    P_ISL."VAT Bus. Posting Group" := 'EU';
                end
                else begin
                    P_ISL."VAT Bus. Posting Group" := 'EXPORT';
                end;
            end;
        end;
        //8862--

        CASE P_ISL.Type OF
            P_ISL.Type::Item:
                BEGIN
                    if L_Item.Get(P_ISL."No.") then begin
                        L_ItemVariant.Reset();
                        L_ItemVariant.SetRange(Code, P_ISL."NAV Variant code");
                        L_ItemVariant.SetRange("Item No.", P_ISL."No.");
                        if L_ItemVariant.FindFirst() then begin
                            IF L_ItemVariant."VAT Prod Posting Group" <> '' THEN
                                P_ISL."VAT Prod. Posting Group" := L_ItemVariant."VAT Prod Posting Group"
                            else
                                P_ISL."VAT Prod. Posting Group" := L_Item."VAT Prod. Posting Group";
                            if L_ItemVariant."Shelf No." <> '' then
                                P_ISL."Shelf No." := L_ItemVariant."Shelf No."
                            else
                                P_ISL."Shelf No." := L_Item."Shelf No.";

                        end else begin
                            P_ISL."VAT Prod. Posting Group" := L_Item."VAT Prod. Posting Group";
                            P_ISL."Shelf No." := L_Item."Shelf No.";
                        end;
                    end;
                END;
            P_ISL.Type::"G/L Account":
                BEGIN
                    IF L_GLAccount.GET(P_ISL."No.") THEN begin
                        P_ISL."VAT Prod. Posting Group" := L_GLAccount."VAT Prod. Posting Group";
                        P_ISL.Description := L_GLAccount.Name;
                    end;
                END;
        END;
        if P_ISL."No." = '' then
            exit;
        CLEAR(UnitVatAmount);
        L_VatProdPostingSetup.RESET;
        IF L_VatProdPostingSetup.GET(P_ISL."VAT Bus. Posting Group", P_ISL."VAT Prod. Posting Group") THEN BEGIN
            if L_VatProdPostingSetup."VAT Calculation Type" = L_VatProdPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
                L_VatProdPostingSetup."VAT %" := 0;  //UnCommented Internal Bug-11752 29/03/2023
            IF L_TradePartner."Prices Including VAT" THEN BEGIN
                P_ISL.Amount := (ROUND(((P_ISL."Channel Price" * P_ISL.Quantity) / ((L_VatProdPostingSetup."VAT %" / 100) + 1)), 0.01, '='));
                P_ISL."Amount Including VAT" := round((P_ISL."Channel Price" * P_ISL.Quantity), 0.01, '=');
                P_ISL."VAT amount" := P_ISL."Amount Including VAT" - P_ISL.Amount;
                IF P_ISL.Quantity > 0 THEN
                    P_ISL."Unit Price" := P_ISL."Channel Price" - (P_ISL."VAT amount" / P_ISL.Quantity);
            END ELSE BEGIN
                P_ISL.Amount := P_ISL."Unit Price" * P_ISL.Quantity;
                P_ISL."Amount Including VAT" := ((ROUND((P_ISL.Amount) * (1 + (L_VatProdPostingSetup."VAT %" / 100)), 0.01)));
                P_ISL."VAT amount" := P_ISL."Amount Including VAT" - P_ISL.Amount;
            END;
        END;
    end;

    procedure CalculateBaseQuantity(VAR P_ISL: Record "Interim Sales Line")
    var
        myInt: Integer;
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitofMeasure.RESET;
        ItemUnitofMeasure.SETRANGE("Item No.", P_ISL."No.");
        ItemUnitofMeasure.SETRANGE(Code, P_ISL."Unit of Measure Code");
        IF ItemUnitofMeasure.FINDFIRST THEN
            P_ISL."Quantity(Base)" := (P_ISL.Quantity * ItemUnitofMeasure."Qty. per Unit of Measure")
        ELSE
            P_ISL."Quantity(Base)" := P_ISL.Quantity;
    end;

}