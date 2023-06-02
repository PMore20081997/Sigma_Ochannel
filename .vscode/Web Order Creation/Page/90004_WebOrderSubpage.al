#pragma implicitwith disable
page 90004 "Web order Subpage"
{
    PageType = ListPart;
    //ApplicationArea = All;
    //UsageCategory = Administration;
    SourceTable = "Interim Sales Line";
    CaptionML = ENU = 'Web order Subpage', ENG = 'Web order Subpage';
    ModifyAllowed = true;
    // LinksAllowed = false;
    // DelayedInsert = true;
    AutoSplitKey = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field("Document No"; Rec."Document No")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        L_InterimSalesLine: Record "Interim Sales Line";
                        L_InterimSalesHeader: Record "Interim Sales Header";
                    begin
                        if Rec.Type = Rec.Type::Item then begin
                            L_InterimSalesLine.Reset();
                            L_InterimSalesLine.SetFilter(Type, '%1', L_InterimSalesLine.Type::Item);
                            L_InterimSalesLine.SetFilter("Document No", Rec."Document No");
                            if L_InterimSalesLine.FindSet() then begin
                                L_InterimSalesHeader.Reset();
                                L_InterimSalesHeader.SetFilter("No.", Rec."Document No");
                                if L_InterimSalesHeader.FindFirst() then begin
                                    L_InterimSalesHeader."No. of Items" := L_InterimSalesLine.Count + 1;
                                    L_InterimSalesHeader.Modify();
                                end;
                            end;
                        end;
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    TableRelation = IF (Type = CONST("G/L Account")) "G/L Account"."No." where(Blocked = CONST(false))
                    ELSE
                    IF (Type = CONST(Resource)) Resource."No."
                    ELSE
                    IF (Type = CONST(Item)) Item."No." where(Blocked = const(false));

                    trigger OnValidate()
                    var
                        L_Item: Record Item;
                        L_ItemUOM: Record "Item Unit of Measure";
                        L_InterimSalesHeader: Record "Interim Sales Header";
                        GLAccount: Record "G/L Account";
                        Resource: Record Resource;
                        L_InterimSalesLine: Record "Interim Sales Line";
                        TotalWeight: Decimal;
                        TotalQuantity: Integer;
                        TotalAmount: Decimal;
                        Amount: Decimal;
                    begin
                        if Rec."No." <> '' then begin
                            if Rec.Type = Rec.Type::Item then begin
                                if L_Item.Get(Rec."No.") then begin
                                    Rec.Description := L_Item.Description;
                                    Rec."Unit of Measure Code" := L_Item."Base Unit of Measure";
                                    Rec."Channel SKU" := L_Item."No.";

                                    L_ItemUOM.Reset();
                                    L_ItemUOM.SetFilter("Item No.", Rec."No.");
                                    L_ItemUOM.SetFilter(Code, L_Item."Base Unit of Measure");
                                    if L_ItemUOM.FindFirst() then begin
                                        Rec.Weight := L_ItemUOM.Weight;
                                    end;
                                end;
                            end;
                            if Rec.Type = Rec.Type::"G/L Account" then begin
                                if GLAccount.Get(Rec."No.") then begin
                                    Rec.Description := GLAccount.Name;
                                end;
                            end;
                            if Rec.Type = Rec.Type::Resource then begin
                                if Resource.Get(Rec."No.") then begin
                                    Rec.Description := Resource.Name;
                                end;
                            end;

                            L_InterimSalesHeader.Reset();
                            L_InterimSalesHeader.SetFilter("No.", Rec."Document No");
                            if L_InterimSalesHeader.FindFirst() then begin
                                Clear(TotalWeight);
                                Clear(TotalQuantity);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            TotalWeight := TotalWeight + (Rec.Weight * Rec.Quantity);
                                        end
                                        else begin
                                            TotalWeight := TotalWeight + (L_InterimSalesLine.Weight * L_InterimSalesLine.Quantity);
                                        end;

                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            TotalQuantity += Rec.Quantity;
                                        end
                                        else begin
                                            TotalQuantity += L_InterimSalesLine.Quantity;
                                        end;
                                    until L_InterimSalesLine.Next() = 0;
                                end;

                                Clear(TotalAmount);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        Clear(Amount);
                                        if L_InterimSalesLine."Unit Price" > 0 then begin
                                            if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                                Amount := (L_InterimSalesLine."Unit Price" * Rec.Quantity) + L_InterimSalesLine."VAT amount";
                                            end
                                            else begin
                                                Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + L_InterimSalesLine."VAT amount";
                                            end;
                                        end;
                                        TotalAmount += Amount;
                                    until L_InterimSalesLine.Next() = 0;
                                end;

                                Rec."Channel Order ID" := L_InterimSalesHeader."Channel Order ID";

                                L_InterimSalesHeader."Order Amount" := TotalAmount;
                                L_InterimSalesHeader."Total Weight" := TotalWeight;
                                L_InterimSalesHeader."Total No. of Items" := TotalQuantity;
                                L_InterimSalesHeader.Modify();
                            end;
                        end;

                        CurrPage.Update();
                    end;
                }
                field("Shelf No."; Rec."Shelf No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    Editable = true;
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        ISH: Record "Interim Sales Header";
                    begin
                        ISH.Reset();
                        ISH.SetRange("No.", Rec."Document No");
                        ISH.SetRange("Document Type", Rec."Document Type");
                        if ISH.FindFirst() then begin
                            if Rec."Trade Partner Code" = '' then begin
                                Rec.Validate("Trade Partner Code", ISH."Trade Partner Code");
                                Rec.Validate("Channel Order ID", ISH."Channel Order ID");
                            end;
                        end;
                    end;
                }

                field(Description2; Rec.Description2)
                {
                    Editable = true;
                    Visible = false;
                    ApplicationArea = All;
                }

                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        InterimSalesHeader: Record "Interim Sales Header";
                        L_InterimSalesLine: Record "Interim Sales Line";
                        TotalWeight: Decimal;
                        TotalQuantity: Integer;
                        TotalAmount: Decimal;
                        Amount: Decimal;
                    begin
                        if Rec."Document No" <> '' then begin
                            InterimSalesHeader.Reset();
                            InterimSalesHeader.SetFilter("No.", Rec."Document No");
                            if InterimSalesHeader.FindFirst() then begin
                                Clear(TotalWeight);
                                Clear(TotalQuantity);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            TotalWeight := TotalWeight + (Rec.Weight * Rec.Quantity);
                                        end
                                        else begin
                                            TotalWeight := TotalWeight + (L_InterimSalesLine.Weight * L_InterimSalesLine.Quantity);
                                        end;

                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            TotalQuantity += Rec.Quantity;
                                        end
                                        else begin
                                            TotalQuantity += L_InterimSalesLine.Quantity;
                                        end;
                                    until L_InterimSalesLine.Next() = 0;
                                end;

                                Clear(TotalAmount);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        Clear(Amount);

                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            if Rec."Unit Price" > 0 then
                                                Amount := (Rec."Unit Price" * Rec.Quantity) + Rec."VAT amount";
                                        end
                                        else begin
                                            if L_InterimSalesLine."Unit Price" > 0 then
                                                Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + L_InterimSalesLine."VAT amount";
                                        end;
                                        TotalAmount += Amount;
                                    until L_InterimSalesLine.Next() = 0;
                                end;

                                InterimSalesHeader."Order Amount" := TotalAmount;
                                InterimSalesHeader."Total Weight" := TotalWeight;
                                InterimSalesHeader."Total No. of Items" := TotalQuantity;
                                InterimSalesHeader.Modify();
                            end;
                        end;

                        CurrPage.Update();
                    end;
                    // Editable = false;  // Irshad 13052022
                }
                field("Reserved Qty"; Rec."Reserved Qty")
                {
                    ApplicationArea = ALl;
                    Editable = false;
                    Visible = true;
                }
                field(Reserved; Rec.Reserved)
                {
                    ApplicationArea = All;
                    Visible = true;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Channel Price"; Rec."Channel Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    Caption = 'Unit Price Ex. VAT';
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 4;

                    trigger OnValidate()
                    var
                        InterimSalesHeader: Record "Interim Sales Header";
                        L_InterimSalesLine: Record "Interim Sales Line";
                        TotalAmount: Decimal;
                        Amount: Decimal;
                    begin
                        if Rec."Document No" <> '' then begin
                            InterimSalesHeader.Reset();
                            InterimSalesHeader.SetFilter("No.", Rec."Document No");
                            if InterimSalesHeader.FindFirst() then begin
                                Clear(TotalAmount);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        Clear(Amount);
                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            if Rec."Unit Price" > 0 then
                                                Amount := (Rec."Unit Price" * L_InterimSalesLine.Quantity) + Rec."VAT amount";
                                        end
                                        else begin
                                            if L_InterimSalesLine."Unit Price" > 0 then
                                                Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + L_InterimSalesLine."VAT amount";
                                        end;
                                        TotalAmount += Amount;
                                    until L_InterimSalesLine.Next() = 0;
                                end;
                                InterimSalesHeader."Order Amount" := TotalAmount;
                                InterimSalesHeader.Modify();
                            end;
                        end;
                    end;
                }
                field("Quantity Handeled"; Rec."Trolley closed Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Shipping Price"; Rec."Shipping Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gift Wrap Price"; Rec."Gift Wrap Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gift Card"; Rec."Gift Card")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        InterimSalesHeader: Record "Interim Sales Header";
                        L_InterimSalesLine: Record "Interim Sales Line";
                        TotalWeight: Decimal;
                    begin
                        if Rec.Weight <> 0 then begin
                            if Rec."Document No" <> '' then begin
                                InterimSalesHeader.Reset();
                                InterimSalesHeader.SetFilter("No.", Rec."Document No");
                                if InterimSalesHeader.FindFirst() then begin
                                    Clear(TotalWeight);
                                    L_InterimSalesLine.Reset();
                                    L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                                    L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                    L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                    if L_InterimSalesLine.FindSet() then begin
                                        repeat
                                            if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                                TotalWeight := TotalWeight + (Rec.Weight * L_InterimSalesLine.Quantity);
                                            end
                                            else begin
                                                TotalWeight := TotalWeight + (L_InterimSalesLine.Weight * L_InterimSalesLine.Quantity);
                                            end;
                                        until L_InterimSalesLine.Next() = 0;
                                    end;
                                    InterimSalesHeader."Total Weight" := TotalWeight;
                                    InterimSalesHeader.Modify();
                                end;
                            end;
                        end;
                        CurrPage.Update();
                    end;
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                    Caption = 'Line Discount Inc VAT';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT amount"; Rec."VAT amount")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        InterimSalesHeader: Record "Interim Sales Header";
                        TotalAmount: Decimal;
                        Amount: Decimal;
                        L_InterimSalesLine: Record "Interim Sales Line";
                        VATDifference: Decimal;
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        GeneralLedgerSetup.Get();
                        Clear(VATDifference);
                        if xRec."VAT amount" > Rec."VAT amount" then begin
                            VATDifference := xRec."VAT amount" - Rec."VAT amount";
                        end
                        else begin
                            VATDifference := Rec."VAT amount" - xRec."VAT amount";
                        end;

                        if (VATDifference > GeneralLedgerSetup."Max. VAT Difference Allowed") then begin
                            Error(StrSubstNo('VAT Difference must not exceed Max. VAT Difference Allowed = %1', GeneralLedgerSetup."Max. VAT Difference Allowed"));
                        end;

                        if Rec."Document No" <> '' then begin
                            InterimSalesHeader.Reset();
                            InterimSalesHeader.SetFilter("No.", Rec."Document No");
                            if InterimSalesHeader.FindFirst() then begin
                                Clear(TotalAmount);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        Clear(Amount);
                                        if L_InterimSalesLine."Unit Price" > 0 then begin
                                            if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                                Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + Rec."VAT amount";
                                            end
                                            else begin
                                                Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + L_InterimSalesLine."VAT amount";
                                            end;
                                        end;
                                        TotalAmount += Amount;
                                    until L_InterimSalesLine.Next() = 0;
                                end;
                                InterimSalesHeader."Order Amount" := TotalAmount;
                                InterimSalesHeader.Modify();
                            end;
                        end;
                        CurrPage.Update();
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                }
                field("NAV Variant code"; Rec."NAV Variant code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                }
                field("Gift Wrap"; Rec."Gift Wrap")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Enabled = true;
                    CaptionML = ENU = 'Zero Price', ENG = 'Zero Price';
                }
                field("Channel Identifier"; Rec."Channel Identifier")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Channel Item Id"; Rec."Channel Item Id")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Trolley No."; rec."Trolley No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Bay No."; Rec."Bay No.")
                {
                    ApplicationArea = All;
                    //Editable = false;
                    Visible = false;
                }
                field("Scanned Date"; rec."Scanned Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                //Paarth D Dave - 8197 - Assembly Order ---- Start
                field("Assembly Order No."; Rec."Assembly Order No.")
                {
                    Editable = false;
                    ApplicationArea = ALl;
                }
                field("Posted Ass. Order No "; Rec."Pstd. Ass. Order No ")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Posted Ass. Order No.';
                }
                field("Assembly Order"; Rec."Auto Assembly Order")
                {
                    Editable = false;
                    Caption = 'Assembly Order';
                    ApplicationArea = All;
                }
                //Paarth D Dave - 8197 - Assembly Order ---- End

                //8862++
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    var
                        L_VatProdPostingSetup: Record "VAT Posting Setup";
                        L_TradePartner: Record "Trade Partner";
                        InterimSalesHeader: Record "Interim Sales Header";
                        TotalAmount: Decimal;
                        L_InterimSalesLine: Record "Interim Sales Line";
                        Amount: Decimal;
                    begin
                        if Rec."Document No" <> '' then begin
                            InterimSalesHeader.Reset();
                            InterimSalesHeader.SetFilter("No.", Rec."Document No");
                            if InterimSalesHeader.FindFirst() then begin
                                Clear(TotalAmount);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        Clear(Amount);
                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            Amount := (Rec."Unit Price" * Rec.Quantity) + Rec."VAT amount";
                                        end
                                        else begin
                                            Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + L_InterimSalesLine."VAT amount";
                                        end;
                                        TotalAmount += Amount;
                                    until L_InterimSalesLine.Next() = 0;
                                end;
                                InterimSalesHeader."Order Amount" := TotalAmount;
                                InterimSalesHeader.Modify();
                            end;
                        end;
                        CurrPage.Update();
                    end;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    var
                        L_VatProdPostingSetup: Record "VAT Posting Setup";
                        L_TradePartner: Record "Trade Partner";
                        InterimSalesHeader: Record "Interim Sales Header";
                        TotalAmount: Decimal;
                        L_InterimSalesLine: Record "Interim Sales Line";
                        Amount: Decimal;
                    begin
                        if Rec."Document No" <> '' then begin
                            InterimSalesHeader.Reset();
                            InterimSalesHeader.SetFilter("No.", Rec."Document No");
                            if InterimSalesHeader.FindFirst() then begin
                                Clear(TotalAmount);
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
                                L_InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        Clear(Amount);
                                        if L_InterimSalesLine."Line No." = Rec."Line No." then begin
                                            if Rec."Unit Price" > 0 then
                                                Amount := (Rec."Unit Price" * Rec.Quantity) + Rec."VAT amount";
                                        end
                                        else begin
                                            if L_InterimSalesLine."Unit Price" > 0 then
                                                Amount := (L_InterimSalesLine."Unit Price" * L_InterimSalesLine.Quantity) + L_InterimSalesLine."VAT amount";
                                        end;
                                        TotalAmount += Amount;
                                    until L_InterimSalesLine.Next() = 0;
                                end;
                                InterimSalesHeader."Order Amount" := TotalAmount;
                                InterimSalesHeader.Modify();
                            end;
                        end;
                        CurrPage.Update();
                    end;
                }
                //8862--
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Cancel Selected Lines")
            {
                ApplicationArea = All;
                Image = Cancel;
                trigger OnAction()
                var
                    L_InterimSalesLine: Record "Interim Sales Line";
                    UpdateDispatchedOnWebOrder: Report "Update Dispatched On Web Order";
                    L_InterimSalesHeader: Record "Interim Sales Header";
                begin
                    L_InterimSalesHeader.Get(Rec."Document Type", rec."Document No");
                    if NOT (L_InterimSalesHeader.status IN [L_InterimSalesHeader.status::"Partially Scanned", L_InterimSalesHeader.status::Processing, L_InterimSalesHeader.status::Cancelled]) then
                        Error('Line can cancel only when order status is Partially Scanned or Processing or Cancelled');
                    Clear(L_InterimSalesLine);
                    L_InterimSalesLine := Rec;
                    CurrPage.SETSELECTIONFILTER(L_InterimSalesLine);
                    UpdateDispatchedOnWebOrder.CancelSelectedLines(L_InterimSalesLine);
                end;
            }
        }
    }


    //8862++
    trigger OnDeleteRecord(): Boolean
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        InterimSalesLine: Record "Interim Sales Line";
        L_InterimSalesHeader: Record "Interim Sales Header";
        WebOrderMgmt: Codeunit "Web Order Mgt";
        TotalAmount: Decimal;
        Amount: Decimal;
        TotalWeight: Decimal;
    begin
        if Rec.Type = Rec.Type::Item then begin
            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetFilter(Type, '%1', L_InterimSalesLine.Type::Item);
            L_InterimSalesLine.SetFilter("Document No", Rec."Document No");
            if L_InterimSalesLine.FindSet() then begin
                L_InterimSalesHeader.Reset();
                L_InterimSalesHeader.SetFilter("No.", Rec."Document No");
                if L_InterimSalesHeader.FindFirst() then begin
                    L_InterimSalesHeader."No. of Items" := L_InterimSalesLine.Count - 1;
                    L_InterimSalesHeader."Total No. of Items" := WebOrderMgmt.CalculateTotalItems(L_InterimSalesHeader) - Rec.Quantity;

                    Clear(TotalAmount);
                    InterimSalesLine.Reset();
                    InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
                    InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                    if InterimSalesLine.FindSet() then begin
                        repeat
                            if L_InterimSalesLine."Unit Price" > 0 then
                                if InterimSalesLine."Line No." <> Rec."Line No." then
                                    TotalAmount += (InterimSalesLine."Unit Price" * InterimSalesLine.Quantity) + InterimSalesLine."VAT amount";
                        until InterimSalesLine.Next() = 0;
                    end;

                    L_InterimSalesHeader."Order Amount" := TotalAmount;

                    Clear(TotalWeight);
                    TotalWeight := WebOrderMgmt.CalculateWeight(L_InterimSalesHeader) - (Rec.Quantity * Rec.Weight);
                    L_InterimSalesHeader."Total Weight" := TotalWeight;
                    L_InterimSalesHeader.Modify();
                end;
            end;
        end;
    end;
    //8862--
}

#pragma implicitwith restore

