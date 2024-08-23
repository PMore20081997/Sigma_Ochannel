table 90004 "Interim Sales Line"
{
    DataClassification = ToBeClassified;
    LookupPageId = "Web Order Line List";
    DrillDownPageId = "Web Order Line List";

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
            begin
                IF (Quantity > 0) THEN begin
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
        field(14; "VAT Prod. Posting Group"; Code[20])
        {
            TableRelation = "VAT Product Posting Group";
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
            begin
                Validate(Quantity);
            end;
        }
        field(15; "Channel Identifier"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Channel Item Id"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Channel SKU"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Shipping Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Gift Wrap Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Weight; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "VAT%"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Line Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
        }
        field(23; "Discount %"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Gift Wrap"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "NAV Variant code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Variant Code';
        }
        field(26; "Channel Variant"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Units per Parcel"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Amount Including VAT"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Currency Code"; Code[10])
        {
            Editable = false;
            TableRelation = Currency;
            DataClassification = ToBeClassified;
        }
        field(30; "Shipment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Shipping Agent Code"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Shipping Agent Code" WHERE("No." = field("Document No")));
            TableRelation = "Shipping Agent";
            AccessByPermission = TableData "Shipping Agent Services" = R;
            trigger OnValidate()
            begin
                IF xRec."Shipping Agent Code" = "Shipping Agent Code" THEN
                    EXIT;

                "Shipping Agent Service Code" := '';
            end;
        }
        field(32; "Shipping Agent Service Code"; Code[10])
        {
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("Shipping Agent Code"));
        }
        field(33; "Shipping Time"; DateFormula)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            DataClassification = ToBeClassified;
        }
        field(34; "Trade Partner Code"; Code[20])
        {
            TableRelation = "Trade Partner";
            DataClassification = ToBeClassified;
            ValidateTableRelation = false;
        }
        field(35; "No of Error"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("Incoming/Outgoing Error Log" WHERE("Document No." = field("Document No"), "Item No." = field("No.")));
        }
        field(36; "Order Status"; Option)
        {
            OptionMembers = Rejected,Accepted,"SO Created";
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
            Editable = false;
        }
        field(37; "VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Validate(Quantity);
                VALIDATE("VAT Prod. Posting Group");
            end;
        }
        field(38; "Tracking No."; Code[30])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Shipment Tracking"."Tracking No." WHERE("Document Type" = FILTER(Order), "Document No." = field("No.")));
        }
        field(39; "Sell-to Customer No."; Code[20])
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
        field(40; "Channel Order ID"; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Unit Cost(LCY)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(42; "Quantity Allocated"; Decimal)
        {
            FieldClass = Normal;
        }
        field(43; "Allocated Status"; Option)
        {
            Editable = false;
            OptionMembers = "Not Allocated","Fully Allocated","Part Allocated","Ready To Dispatch","In Picking",Picked;
            DataClassification = ToBeClassified;
        }
        field(44; Hazardous; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(45; "Destination Doc. Line No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(46; Reserved; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(47; "Unit of Measure Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = IF (Type = CONST(Item), "No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."));

            trigger OnValidate()
            begin
                If xRec."Unit of Measure Code" <> Rec."Unit of Measure Code" then
                    CalculateBaseQuantity(Rec);
            end;
        }
        field(48; "Document Date"; Date)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Document Date" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(49; "Location Code"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header"."Location Code" WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(50; "Scanned Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(51; "Quantity(Base)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Item Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Single,Assembly,Component;
            OptionCaptionML = ENU = 'Single, Assembly, Component',
                              ENG = 'Single, Assembly, Component';
        }
        field(53; "BOM Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Moved In Handled"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Destination Doc Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Sales Order","Internal Pick";
            OptionCaptionML = ENU = ' ,Sales Order,Internal Pick',
                              ENG = ' ,Sales Order,Internal Pick';
        }
        field(56; "Destination Doc No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Trolley No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(58; "Dispatch Scan"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Price Authorised"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60; FileName; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Channel Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Pack Description"; Text[50])
        {
            Editable = true;
        }
        field(63; "ABV (%)"; Decimal)
        {
        }
        field(64; Status; Option)
        {
            Editable = false;
            OptionMembers = Rejected,Accepted,"SO Created";
            FieldClass = FlowField;
            CalcFormula = Lookup("Interim Sales Header".Status WHERE("Document Type" = FIELD("Document Type"), "No." = FIELD("Document No")));
        }
        field(65; "Pick No"; Code[20])
        {
        }
        field(66; "Pick Line No"; Integer)
        {
        }
        field(67; "Picking Status"; Option)
        {
            OptionMembers = " ","In Picking",Picked;
        }
        field(68; "Multiline Order"; Boolean)
        {
        }
        field(69; "Bay No."; Code[20])
        {
        }
        field(70; "Trolley Closed Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Quantity Handled';
        }
        field(71; "Shelf No."; Code[20])
        {
        }
        field(72; "Reserved Qty"; Decimal)
        {
        }
        field(73; "Header Id"; Guid)
        {
            TableRelation = "Interim Sales Header".SystemId;
        }
        field(74; "Gift Card"; Boolean)
        {
        }
        field(75; order_id; Text[250])
        {
        }
        field(76; order_line_id; Text[250])
        {
        }
        field(77; "Reason Code"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(78; "Reason Message"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(79; "ET Access Code"; Code[50])
        {
        }
        field(80; "Sales Order Created"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Web Buffer" where("Web Document No." = field("Document No")));
        }
        field(81; "Qty. to Deliver"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(82; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(83; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
        field(84; "Sig Channel Item Id"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(85; "Variant Code Mandatory"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Item Variant" where("Item No." = field("No.")));
        }
        field(86; "Changed UnitPrice"; Boolean)
        {
            Editable = false;
            //Customer Trend+++
        }
    }

    keys
    {
        key(PK; "Document Type", "Document No", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Qty. to Deliver";
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