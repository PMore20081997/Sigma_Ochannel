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
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("ChannelItemId"; Rec."Sig Channel Item Id")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec."Quantity")
                {
                    ApplicationArea = All;
                    // trigger OnValidate()
                    // var
                    // begin
                    //     IF (Rec.Quantity > 0) THEN begin
                    //         Rec."Channel Price" := Rec."Unit Price";
                    //         Rec.CalculateVatAmount(Rec);
                    //         Rec.CalculateBaseQuantity(Rec);
                    //     end;
                    // end;
                }
                field("Qty. to Deliver"; Rec."Qty. to Deliver")
                {
                    ApplicationArea = All;
                }
                // field(ChannelSKU; Rec."Channel SKU")
                // {
                //     ApplicationArea = All;
                //     trigger OnValidate()
                //     var
                //         L_Item: Record Item;
                //         L_ItemUOM: Record "Item Unit of Measure";
                //     begin
                //         if Rec."No." = '' then begin
                //             L_Item.Reset();
                //             L_Item.SetRange("No.", Rec."Channel SKU");
                //             if L_Item.FindFirst() then begin
                //                 Rec.Description := L_Item.Description;
                //                 Rec."Unit of Measure Code" := L_Item."Base Unit of Measure";

                //                 L_ItemUOM.Reset();
                //                 L_ItemUOM.SetFilter("Item No.", L_Item."No.");
                //                 L_ItemUOM.SetFilter(Code, L_Item."Base Unit of Measure");
                //                 if L_ItemUOM.FindFirst() then begin
                //                     Rec.Weight := L_ItemUOM.Weight * Rec.Quantity;
                //                 end;
                //             end;
                //         end;
                //     end;
                // }
                field(ReasonCode; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field(ReasonMessage; Rec."Reason Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        IsDeepInsert: Boolean;
        G_LocationCode: Text;
        AvailableInventory: Decimal;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        MyHeader: Record "Interim Sales Header";
        MyLine: Record "Interim Sales Line";
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ProductLevelResponse: Record "Product Level Response";
        L_Item: Record Item;
    begin
        IsDeepInsert := IsNullGuid(Rec."Header Id");
        if not IsDeepInsert then begin
            MyHeader.GetBySystemId(Rec."Header Id");
            Rec."Document No" := MyHeader."No.";
            Rec."Order Date" := MyHeader."Order Date";
            Rec.VALIDATE("Trade Partner Code", MyHeader."Trade Partner Code");
            Rec.Validate("ET Access Code", MyHeader."ET Access Code");
            Rec.VALIDATE("Sell-to Customer No.", MyHeader."Sell-to Customer No.");
            Rec."Line No." := FindLastLineNo(MyHeader);
            Rec.Validate("Customer Price Group", MyHeader."Customer Price Group");
            L_Item.Reset();
            if L_Item.Get(Rec."No.") then begin
                Rec.Description := L_Item.Description;
                Rec."Item Category Code" := L_Item."Item Category Code";
                Rec.Description2 := L_Item."Description 2";
                Rec."Unit of Measure Code" := L_Item."Sales Unit of Measure";
            end;
            //WIll check this code ++
            Rec."Shipment Date" := MyHeader."Shipment Date";

            //Check Validation+++
            Sigma_LineValidations(MyHeader, Rec);

            if AvailableInventory > 0 then begin
                if AvailableInventory < Rec.Quantity then begin
                    Rec."Qty. to Deliver" := AvailableInventory;
                end
                else begin
                    Rec."Qty. to Deliver" := Rec.Quantity;
                end;
            end;

            //Update Interim header and Interim Line Response Code and Message++
            //Line++
            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", MyHeader."No.");
            PartnerErrorLog.SetFilter("Item No.", Rec."No.");
            PartnerErrorLog.SetCurrentKey("Sequence No.");
            PartnerErrorLog.Ascending(true);
            IF PartnerErrorLog.FindFirst() THEN begin
                L_ProductLevelResponse.Reset();
                L_ProductLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                if L_ProductLevelResponse.FindFirst() then begin
                    if L_ProductLevelResponse."Error Code" = 'SEQ9' then begin
                        Rec."Reason Code" := L_ProductLevelResponse.Reason;
                        Rec."Reason Message" := PartnerErrorLog.Attribute + ' ' + L_ProductLevelResponse.Message;
                    end else begin
                        Rec."Reason Code" := L_ProductLevelResponse.Reason;
                        Rec."Reason Message" := L_ProductLevelResponse.Message;
                    end;
                end;
            end else begin
                Rec."Reason Code" := 'Order Line Created';
                Rec."Reason Message" := 'Successful';
            end;

        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        MyHeader: Record "Interim Sales Header";
        L_Item: Record Item;
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        L_InterimSalesHeader: Record "Interim Sales Header";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_OrderLevelResponse: Record "Order Level Response";
        L_ProductLevelResponse: Record "Product Level Response";
    begin
        MyHeader.Reset();
        IsDeepInsert := IsNullGuid(Rec."Header Id");
        if not IsDeepInsert then begin
            MyHeader.GetBySystemId(Rec."Header Id");
            Rec."Document No" := MyHeader."No.";
            Rec.VALIDATE("Sell-to Customer No.", MyHeader."Sell-to Customer No.");
            Rec."Trade Partner Code" := MyHeader."Trade Partner Code";
            Rec."Channel Order ID" := MyHeader."Channel Order ID";
            G_LocationCode := MyHeader."Location Code";
        end;
    end;

    local procedure FindLastLineNo(P_InterimSalesH: Record "Interim Sales Header"): Integer
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesH."No.");
        IF L_InterimSalesLine.FINDLAST THEN
            EXIT(L_InterimSalesLine."Line No." + 10000)
        ELSE
            EXIT(10000);
    end;


    procedure Sigma_LineValidations(var P_InterimSalesHeader: Record "Interim Sales Header"; Var _InterimSalesLine: Record "Interim Sales Line")
    var
        L_ErrorRecorded: Boolean;
        L_Item: Record Item;
        L_TradePartner: Record "Trade Partner";
        L_CheckItemLicense: Codeunit "Check Item License";
        L_AttributeCode: Code[20];
        L_CompanyLicenseError: Text[100];
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        SalesQuotaValidation: Codeunit "Web Order Sales Quota";
        Query_ItemLedgerEntry: Query "Calculate Inventory";
        PhysicalInventory: Decimal;
        Query_QtyonSO: Query "Qty on SO";
        QtyOnSO: Decimal;
        Query_QtyonWebOrder: Query "Qty on Web";
        QtyonWebOrder: Decimal;
        Duplicate_InterimSalesLine: Record "Interim Sales Line";
    begin
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN
            if P_InterimSalesHeader.status in [P_InterimSalesHeader.status::Cancelled, P_InterimSalesHeader.status::Processing] then
                exit;
            L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");

            Clear(L_ErrorRecorded);
            //Response SEQ3++
            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if L_Item.Blocked = true then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Record Locked (stock or depot stock file)', P_InterimSalesHeader, _InterimSalesLine, 'SEQ3', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Response SEQ4++
            if L_ErrorRecorded = false then begin
                if _InterimSalesLine."No." = '' then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Value for Item no must not be blank', P_InterimSalesHeader, _InterimSalesLine, 'SEQ4', false, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
            if L_ErrorRecorded = false then begin
                if not L_Item.Get(_InterimSalesLine."No.") then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Product does not exist', P_InterimSalesHeader, _InterimSalesLine, 'SEQ4', false, '');
                    L_ErrorRecorded := TRUE;
                end
            end;
            //Response SEQ4--

            //Response SEQ5 (Duplicate Line) need check++
            if L_ErrorRecorded = false then begin
                Duplicate_InterimSalesLine.Reset();
                Duplicate_InterimSalesLine.SetRange("Document Type", Duplicate_InterimSalesLine."Document Type"::Order);
                Duplicate_InterimSalesLine.SetRange("Document No", _InterimSalesLine."Document No");
                Duplicate_InterimSalesLine.SetRange("No.", _InterimSalesLine."No.");
                if Duplicate_InterimSalesLine.FindSet() then begin
                    if Duplicate_InterimSalesLine.Count = 1 then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Duplicate product ordered', P_InterimSalesHeader, _InterimSalesLine, 'SEQ5', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            // Item Sales Quota SEQ6++
            if L_ErrorRecorded = false then begin
                if SalesQuotaValidation.CheckExceededQty(_InterimSalesLine, P_InterimSalesHeader) = SalesQuotaValidation.CheckExceededQty(_InterimSalesLine, P_InterimSalesHeader) ::"Exceeded Qty" then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Maximum ordered exceeded', P_InterimSalesHeader, _InterimSalesLine, 'SEQ6', false, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;

            //Response SEQ7++
            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if L_Item."WebOrder Status" = L_Item."WebOrder Status"::DISCONTINUED then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Product Discontinued', P_InterimSalesHeader, _InterimSalesLine, 'SEQ7', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Check Company License SEQ8++
            if L_ErrorRecorded = false then begin
                Clear(L_AttributeCode);
                Clear(L_CompanyLicenseError);
                L_CompanyLicenseError := L_CheckItemLicense.ForIntegration_ValidateLicense(0, P_InterimSalesHeader."Sell-to Customer No.", P_InterimSalesHeader."Customer Posting Group", P_InterimSalesHeader."Ship-to Country/Region Code", P_InterimSalesHeader."Order Date", _InterimSalesLine."No.", P_InterimSalesHeader."Ship-to Post Code", L_AttributeCode);
                if L_CompanyLicenseError <> '' then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog(L_CompanyLicenseError, P_InterimSalesHeader, _InterimSalesLine, 'SEQ8', false, L_AttributeCode);
                    L_ErrorRecorded := TRUE;
                end;
            end;

            //Response SEQ9++
            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    L_Item.CalcFields(Inventory);
                    if L_Item.Inventory = 0 then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Product out of stock', P_InterimSalesHeader, _InterimSalesLine, 'SEQ9', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Check Partial Quantity Ordered Response SEQ11++
            Clear(AvailableInventory);
            if L_ErrorRecorded = false then begin
                #Region Physical Inventory from Item Ledger Entry
                Clear(PhysicalInventory);
                CLEAR(Query_ItemLedgerEntry);
                Query_ItemLedgerEntry.SETRANGE(Query_ItemLedgerEntry.Item_No_, _InterimSalesLine."No.");
                Query_ItemLedgerEntry.SETRANGE(Query_ItemLedgerEntry.Saleable_Location, true);
                Query_ItemLedgerEntry.SETRANGE(Query_ItemLedgerEntry.Unit_of_Measure_Code, _InterimSalesLine."Unit of Measure Code");

                Query_ItemLedgerEntry.OPEN;
                IF Query_ItemLedgerEntry.READ THEN begin
                    PhysicalInventory := Query_ItemLedgerEntry.Quantity;
                END;
                Query_ItemLedgerEntry.CLOSE;
                #endregion

                #Region Quantity Allocated on Sales Order
                Clear(Query_QtyonSO);
                Clear(QtyOnSO);
                Query_QtyonSO.SETRANGE(Query_QtyonSO.No, _InterimSalesLine."No.");
                Query_QtyonSO.SETRANGE(Query_QtyonSO.Saleable_Location, true);
                Query_QtyonSO.SETRANGE(Query_QtyonSO.Unit_of_Measure_Code, _InterimSalesLine."Unit of Measure Code");

                Query_QtyonSO.OPEN;
                IF Query_QtyonSO.READ THEN begin
                    QtyOnSO := Query_QtyonSO.Outstanding_Qty;
                END;
                Query_QtyonSO.CLOSE;
                #endregion

                #Region Quantity Allocated on Web Orders
                Clear(Query_QtyonWebOrder);
                Clear(QtyonWebOrder);
                Query_QtyonWebOrder.SETRANGE(Query_QtyonWebOrder.No_, _InterimSalesLine."No.");

                Query_QtyonWebOrder.OPEN;
                IF Query_QtyonWebOrder.READ THEN begin
                    QtyonWebOrder := Query_QtyonWebOrder.Quantity - _InterimSalesLine.Quantity;
                END;
                Query_QtyonWebOrder.CLOSE;
                #endregion

                AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder);

                if (AvailableInventory > 0) and (AvailableInventory < _InterimSalesLine.Quantity) then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Partial Quantity Delivered', P_InterimSalesHeader, _InterimSalesLine, 'SEQ11', false, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;
    end;
}