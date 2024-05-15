page 90100 "Lot By Item From ILE"
{
    Caption = 'Lot By Item';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 7351;
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Location Code"; Rec."Location Code")
                {

                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                }
                field("Lot No."; Rec."Lot No.")
                {

                }
                field("Qty. (Base)"; Rec."Qty. (Base)")
                {

                }
                field(G_WebOrderQty; G_WebOrderQty)
                {
                    Caption = 'Qty. On Web Order';
                }
                field(G_FreeQuantity; G_FreeQuantity)
                {
                    Caption = 'Free Quantity';
                }

            }
        }
    }

    var
        G_FreeQuantity: Decimal;
        G_WebOrderQty: Decimal;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        FillTempTable;
        EXIT(Rec.FIND(Which));
    end;


    local procedure FillTempTable()
    var
        L_LotByItemFromILE: Query "Lot By Item From ILE";
        L_SalesLine: Record "Sales Line";
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        _Physical: Decimal;
        _AllocatedOnSO: Decimal;
        L_Item: Record Item;
    begin
        Rec.DELETEALL;
        L_LotByItemFromILE.SETRANGE(L_LotByItemFromILE.Item_No_, Rec.GETRANGEMIN("Item No."));
        L_LotByItemFromILE.OPEN;
        WHILE L_LotByItemFromILE.READ DO BEGIN
            Rec.INIT;
            Rec."Location Code" := L_LotByItemFromILE.Location_Code;
            Rec."Item No." := L_LotByItemFromILE.Item_No_;
            Rec."Lot No." := L_LotByItemFromILE.Lot_No_;
            Rec."Qty. (Base)" := L_LotByItemFromILE.Remaining_Quantity;

            IF Rec."Qty. (Base)" <> 0 THEN begin
                Clear(_Physical);
                _Physical := L_LotByItemFromILE.Remaining_Quantity;

                Clear(_AllocatedOnSO);
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                L_SalesLine.SetRange("No.", L_LotByItemFromILE.Item_No_);
                L_SalesLine.SetRange("Location Code", L_LotByItemFromILE.Location_Code);
                L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
                if L_SalesLine.FindSet() then begin
                    L_SalesLine.CalcSums("Outstanding Quantity");
                    _AllocatedOnSO := L_SalesLine."Outstanding Quantity";
                end;

                Clear(G_WebOrderQty);
                if L_Item.Get(L_LotByItemFromILE.Item_No_) then begin
                    L_Item.CalcFields("Qty. on Web Order");
                    G_WebOrderQty := L_Item."Qty. on Web Order";
                end;

                Clear(G_FreeQuantity);
                G_FreeQuantity := _Physical - _AllocatedOnSO;

                Rec.Insert();
            end;

        END;
    end;

}