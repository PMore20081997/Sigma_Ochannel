pageextension 90020 SalesOrdListExt extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // addafter("&Print")
        // {
        //     action("EDI File 2")
        //     {
        //         ApplicationArea = All;
        //         Image = Journal;
        //         PromotedCategory = Process;
        //         Promoted = true;

        //         trigger OnAction()
        //         var
        //             EDIInvoiceCOD: Codeunit "EDI Invoice";
        //             JobQueueEntry: Record "Job Queue Entry" temporary;
        //             SalesHeader: Record "Sales Header";
        //             customer: Record "Customer";
        //         begin
        //             Clear(SalesHeader);
        //             SalesHeader := Rec;
        //             CurrPage.SetSelectionFilter(SalesHeader);

        //             if SalesHeader.FindSet() then begin
        //                 repeat
        //                     Clear(customer);
        //                     customer.Reset();
        //                     if customer.get(SalesHeader."Buy-from Vendor No.") then
        //                         EDIInvoiceCOD.ProcessEDIFile1(SalesHeader, customer);
        //                 until SalesHeader.Next() = 0;
        //             end;
        //         end;
        //     }
        // }

        addafter(Release)
        {
            //GHST Customization++
            action("Update Variant On Lines")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_SalesLine: Record "Sales Line";
                    CustomeCodeunit: Codeunit "Udate Variant on SO";
                    RemQty: Decimal;
                    QtyToApply: Decimal;
                    L_ItemVariant: Record "Item Variant";
                    L_Count: Integer;
                    L_NewLineRequired: Boolean;
                    L_Item: Record Item;
                    Window: Dialog;
                    Counter: Integer;
                    Text005: TextConst ENU = 'Updating the Variant Code...\\', ENG = 'Updating the Variant Code...\\';
                    Text006: TextConst ENU = 'Progress', ENG = 'Progress';
                    NoOfRecords: Integer;

                    L_SalesHeader: Record "Sales Header";
                begin
                    Clear(NoOfRecords);
                    Clear(Counter);
                    L_SalesHeader.Reset();
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
                    L_SalesHeader.SetRange("Web Order", true);
                    if L_SalesHeader.FindSet() then begin
                        NoOfRecords := L_SalesHeader.Count;
                        Window.OPEN(Text005 + Text006 + ' @1@@@@@@@@@@@@@\' + L_SalesHeader.FIELDCAPTION("No.") + ' #3##########');
                        repeat
                            Counter += 1;
                            Window.UPDATE(1, ROUND(Counter / NoOfRecords * 10000, 1));
                            Window.UPDATE(3, L_SalesHeader."No.");
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
                        Window.CLOSE;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}