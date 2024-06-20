codeunit 90025 "Manual/KNAAP SO Process"
{
    trigger OnRun()
    var
        L_SalesHeader: Record "Sales Header";
        WhseRequest: Record "Warehouse Request";
        L_SalesLine: Record "Sales Line";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
    begin
        //Update Variant Code++
        UpdateVariantOnSalesOrder();
        Commit();

        //Release Sales Order
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        BatchProcessingMgt.SetProcessingCodeunit(Codeunit::"Sales Manual Release");
        RecRef.GetTable(L_SalesHeader);
        BatchProcessingMgt.BatchProcess(RecRef, Enum::"Error Handling Options"::"Show Notification");
        Commit();

        //Create InventoryPick
        L_SalesHeader.Reset();
        L_SalesHeader.CalcFields("Inv. Pick Exist");
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Released);
        L_SalesHeader.SetRange("Web Order", true);
        L_SalesHeader.SetRange("Knapp Order", false);
        L_SalesHeader.SetRange("Inv. Pick Exist", false);
        if L_SalesHeader.FindSet() then begin
            repeat
                WhseRequest.Reset();
                WhseRequest.SetCurrentKey("Source Document", "Source No.");
                WhseRequest.SetRange("Source Document", WhseRequest."Source Document"::"Sales Order");
                WhseRequest.SetRange("Source No.", L_SalesHeader."No.");
                REPORT.RunModal(REPORT::"Create Invt. Pick", false, false, WhseRequest);
                Commit();
            until L_SalesHeader.Next() = 0;
        end;
    end;

    local procedure UpdateVariantOnSalesOrder()
    var
        L_SalesHeader: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        L_NewLineRequired: Boolean;
        RemQty: Decimal;
        CustomeCodeunit: Codeunit "Udate Variant on SO";
        L_ItemVariant: Record "Item Variant";
        L_Count: Integer;
        QtyToApply: Decimal;
    begin
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Web Order", true);
        if L_SalesHeader.FindSet() then begin
            repeat
                L_SalesLine.Reset();
                L_SalesLine.SetRange("Document Type", L_SalesHeader."Document Type");
                L_SalesLine.SetRange("Document No.", L_SalesHeader."No.");
                L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                L_SalesLine.SetFilter("Variant Code", '%1', '');
                L_SalesLine.SetRange("Variant Code mandatory", true);
                L_SalesLine.SetFilter("Quantity Shipped", '%1', 0);
                L_SalesLine.SetFilter("Location Code", '<>%1', '');
                if L_SalesLine.FindSet() then begin
                    repeat
                        Clear(L_NewLineRequired);
                        Clear(RemQty);
                        if CustomeCodeunit.CheckTotalAvailablityQty(L_SalesLine) > 0 then begin
                            //Total required quantity 
                            RemQty := L_SalesLine.Quantity;

                            //Update Availbale Qty on Item Variant Table(This is temproray Calculating at run time)
                            CustomeCodeunit.UpdateAvaibleQty(L_SalesLine);

                            //Without Zero and based on priority++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            //Set PriorityWithoutZero++
                            Clear(L_ItemVariant);
                            L_ItemVariant.Reset();
                            CustomeCodeunit.SetPriorityWithoutZero(L_SalesLine, L_ItemVariant);
                            Clear(L_Count);
                            L_Count := L_ItemVariant.Count;

                            //Process to update variant code and create new line if required++
                            if L_Count > 0 then begin
                                while (RemQty > 0) AND (L_Count > 0) do begin
                                    if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) > 0 then begin
                                        if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then begin
                                            if L_NewLineRequired = false then begin
                                                L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
                                                L_SalesLine.Validate("Original Quantity", L_SalesLine.Quantity);
                                                L_SalesLine.Validate("Variant Created By", L_SalesLine."Line No."); //Original Line Number
                                                L_SalesLine.Modify();
                                                RemQty := RemQty - L_SalesLine.Quantity;
                                            end else begin
                                                Clear(QtyToApply);
                                                if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
                                                    QtyToApply := RemQty
                                                else
                                                    QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);

                                                CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
                                                RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
                                            end;
                                        end else begin
                                            if L_NewLineRequired = false then begin
                                                L_SalesLine.Validate("Variant Code", L_ItemVariant.Code);
                                                L_SalesLine.Validate(Quantity, CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant));
                                                L_SalesLine.Validate("Original Quantity", RemQty);
                                                L_SalesLine.Modify();
                                                RemQty := RemQty - L_SalesLine.Quantity;
                                                L_NewLineRequired := true;
                                            end else begin
                                                Clear(QtyToApply);
                                                if CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant) >= RemQty then
                                                    QtyToApply := RemQty
                                                else
                                                    QtyToApply := CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
                                                CustomeCodeunit.InsertNewSalesLine(L_SalesLine, L_ItemVariant, QtyToApply);
                                                RemQty := RemQty - CustomeCodeunit.CheckTotalAvailablityQtyVariantWise(L_SalesLine, L_ItemVariant);
                                            end;
                                        end;
                                    end;

                                    L_Count := L_Count - 1;
                                    L_ItemVariant.Next();
                                end;
                            end;
                            //Without Zero and based on priority--------------------------------------------------------------------
                        end;
                    until L_SalesLine.Next() = 0;
                end;
            until L_SalesHeader.Next() = 0;
        end;

    end;
}