page 90030 "Web Order Line Subpage"
{
    PageType = ListPart;
    SourceTable = "Interim Sales Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    PopulateAllFields = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(lines)
            {
                field(id; Format(Rec.SystemId, 0, 4).ToLower())
                {
                    ApplicationArea = All;
                }
                field(DocumentNo; Rec."Document No")
                {
                    ApplicationArea = All;
                }
                field(TradePartnerCode; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field(DocumentType; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(headerId; Rec."Header Id")
                {
                    ApplicationArea = All;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                    begin
                        IF (Rec.Quantity > 0) THEN begin
                            Rec."Channel Price" := Rec."Unit Price";
                            Rec.CalculateVatAmount(Rec);
                            Rec.CalculateBaseQuantity(Rec);
                        end;
                    end;
                }
                field(UnitPrice; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                    begin
                        IF (xRec."Unit Price" <> Rec."Unit Price") AND (Rec.Quantity > 0) THEN BEGIN
                            Rec."Channel Price" := Rec."Unit Price";
                            Rec.CalculateVatAmount(Rec);
                        END;
                    end;
                }
                field(UnitWeight; Rec.Weight)
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        L_Item: Record Item;
                        L_ItemUOM: Record "Item Unit of Measure";
                        L_GLAccount: Record "G/L Account";
                    begin
                        if Rec."No." <> '' then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", Rec."No.");
                            if L_Item.FindFirst() then begin
                                Rec.Description := L_Item.Description;
                                Rec."Unit of Measure Code" := L_Item."Base Unit of Measure";

                                if Rec.Weight = 0 then begin
                                    L_ItemUOM.Reset();
                                    L_ItemUOM.SetFilter("Item No.", L_Item."No.");
                                    L_ItemUOM.SetFilter(Code, L_Item."Base Unit of Measure");
                                    if L_ItemUOM.FindFirst() then begin
                                        Rec.Weight := L_ItemUOM.Weight * Rec.Quantity;
                                    end;
                                end;

                                L_Item.SetFilter("Location Filter", G_LocationCode);
                                L_Item.CalcFields(Inventory);
                                if Rec.Quantity > 0 then begin
                                    if Rec.Quantity < L_Item.Inventory then
                                        InventoryStatus := InventoryStatus::Accepted
                                    else
                                        InventoryStatus := InventoryStatus::Rejected;
                                end;
                            end;

                            CASE Rec.Type OF
                                Rec.Type::"G/L Account":
                                    BEGIN
                                        IF L_GLAccount.GET(Rec."No.") THEN
                                            Rec."VAT Prod. Posting Group" := L_GLAccount."VAT Prod. Posting Group";
                                    END;
                            END;
                        end;
                    end;
                }
                field(ChannelSKU; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        L_Item: Record Item;
                        L_ItemUOM: Record "Item Unit of Measure";
                    begin
                        if Rec."No." = '' then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", Rec."Channel SKU");
                            if L_Item.FindFirst() then begin
                                Rec.Description := L_Item.Description;
                                Rec."Unit of Measure Code" := L_Item."Base Unit of Measure";

                                L_ItemUOM.Reset();
                                L_ItemUOM.SetFilter("Item No.", L_Item."No.");
                                L_ItemUOM.SetFilter(Code, L_Item."Base Unit of Measure");
                                if L_ItemUOM.FindFirst() then begin
                                    Rec.Weight := L_ItemUOM.Weight * Rec.Quantity;
                                end;
                            end;
                        end;
                    end;
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                    begin
                        if ((Rec.Discount <> 0) and (Rec.Amount <> 0)) then begin
                            Rec.Amount := Rec.Amount - Rec.Discount;
                        end;
                    end;
                }
                // field(ShippingPrice; Rec."Shipping Price")
                // {
                //     ApplicationArea = All;
                // }
                field(InventoryStatus; InventoryStatus)
                {
                    ApplicationArea = All;
                }
                // field(TestMessage; TestMessage)
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }
    var
        IsDeepInsert: Boolean;
        InventoryStatus: Option Accepted,Rejected;
        TestMessage: Text;
        G_LocationCode: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        MyHeader: Record "Interim Sales Header";
        MyLine: Record "Interim Sales Line";
    begin
        if IsDeepInsert then begin
            MyHeader.GetBySystemId(Rec."Header Id");
            Rec."Document No" := MyHeader."No.";

            MyLine.SetRange("Document No", Rec."Document No");
            if MyLine.FindLast() then
                Rec."Line No." := MyLine."Line No." + 10000
            else
                Rec."Line No." := 10000;
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        MyHeader: Record "Interim Sales Header";
        L_Item: Record Item;
    begin
        IsDeepInsert := IsNullGuid(Rec."Header Id");
        if not IsDeepInsert then begin
            MyHeader.GetBySystemId(Rec."Header Id");
            Rec."Document No" := MyHeader."No.";
            Rec."Trade Partner Code" := MyHeader."Trade Partner Code";
            Rec."Channel Order ID" := MyHeader."Channel Order ID";
            G_LocationCode := MyHeader."Location Code";
        end;
    end;

    trigger OnAfterGetRecord()
    var
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        MyHeader: Record "Interim Sales Header";
    begin
        IsDeepInsert := IsNullGuid(Rec."Header Id");
        if not IsDeepInsert then begin
            MyHeader.GetBySystemId(Rec."Header Id");
            //Order Validation Code
            CU_WebOrderManagement.OrderValidations(MyHeader);
        end;
    end;
}