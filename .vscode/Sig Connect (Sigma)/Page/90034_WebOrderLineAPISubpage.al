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
        InventoryStatus: Option Accepted,Rejected;
        TestMessage: Text;
        G_LocationCode: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        MyHeader: Record "Interim Sales Header";
        MyLine: Record "Interim Sales Line";
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ProductLevelResponse: Record "Product Level Response";
    begin
        IsDeepInsert := IsNullGuid(Rec."Header Id");
        if not IsDeepInsert then begin
            MyHeader.GetBySystemId(Rec."Header Id");
            // Rec."Document No" := MyHeader."No.";
            // Rec.VALIDATE("Sell-to Customer No.", MyHeader."Sell-to Customer No.");
            // Rec.VALIDATE("Trade Partner Code", MyHeader."Trade Partner Code");
            // Rec.VALIDATE("Channel Order ID", MyHeader."Channel Order ID");

            // MyLine.SetRange("Document No", Rec."Document No");
            // if MyLine.FindLast() then
            //     Rec."Line No." := MyLine."Line No." + 10000
            // else
            //     Rec."Line No." := 10000;


            //Check Validation+++
            Sigma_LineValidations(MyHeader, Rec);

            //Update Interim header and Interim Line Response Code and Message++
            //Line++
            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", MyHeader."No.");
            //PartnerErrorLog.SetFilter("Item No.", '<>%1', '');
            PartnerErrorLog.SetFilter("Item No.", Rec."No.");
            PartnerErrorLog.SetCurrentKey("Sequence No.");
            PartnerErrorLog.Ascending(true);
            IF PartnerErrorLog.FindFirst() THEN begin
                L_ProductLevelResponse.Reset();
                L_ProductLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                if L_ProductLevelResponse.FindFirst() then begin
                    if L_ProductLevelResponse."Error Code" = 'SEQ13' then begin
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

    trigger OnAfterGetRecord()
    var
        MyHeader: Record "Interim Sales Header";
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        L_InterimSalesHeader: Record "Interim Sales Header";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_OrderLevelResponse: Record "Order Level Response";
        L_ProductLevelResponse: Record "Product Level Response";
        L_InsterimSalesLine: Record "Interim Sales Line";
    begin
        // IsDeepInsert := IsNullGuid(Rec."Header Id");
        // if not IsDeepInsert then begin
        //     MyHeader.GetBySystemId(Rec."Header Id");
        //     //Order Validation Code
        //     CU_WebOrderManagement.OrderValidations(MyHeader);
        // end;
    end;


    procedure Sigma_LineValidations(var P_InterimSalesHeader: Record "Interim Sales Header"; Var _InterimSalesLine: Record "Interim Sales Line")
    var
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ErrorRecorded: Boolean;
        L_Item: Record Item;
        L_TradePartner: Record "Trade Partner";
        TotalItems: Integer;
        ShippingAgent: Record "Shipping Agent";
        Countries: Record "Country/Region";
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
        L_Line: Record "Interim Sales Line";
        L_CheckItemLicense: Codeunit "Check Item License";
        L_AttributeCode: Code[20];
        L_CompanyLicenseError: Text[100];
        L_CustRef: Record "Customer Reference";
        LineCount: Integer;
        ErrorCount: Integer;
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
    begin
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN

            if P_InterimSalesHeader.status in [P_InterimSalesHeader.status::Cancelled, P_InterimSalesHeader.status::Processing] then
                exit;

            L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");

            Clear(L_ErrorRecorded);
            if L_TradePartner."Inbox Type" <> L_TradePartner."Inbox Type"::"File Location" then begin
                if L_ErrorRecorded = false then begin
                    if _InterimSalesLine."No." = '' then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Value for Item no must not be blank', P_InterimSalesHeader, _InterimSalesLine, 'SEQ4', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            if L_TradePartner."Inbox Type" = L_TradePartner."Inbox Type"::"File Location" then begin
                if L_ErrorRecorded = false then begin
                    if L_Item.Get(_InterimSalesLine."No.") then begin
                        if L_Item."WebOrder Status" = L_Item."WebOrder Status"::DISCONTINUED then begin
                            CU_WebOrderManagement.Sigma_InsertErrorLog('Product Discontinued', P_InterimSalesHeader, _InterimSalesLine, 'SEQ10', false, '');
                            L_ErrorRecorded := TRUE;
                        end;
                    end;
                end
            end;

            if L_TradePartner."Inbox Type" = L_TradePartner."Inbox Type"::"File Location" then begin
                if L_ErrorRecorded = false then begin
                    if L_Item.Get(_InterimSalesLine."No.") then begin
                        L_Item.CalcFields(Inventory);
                        if L_Item.Inventory = 0 then begin
                            CU_WebOrderManagement.Sigma_InsertErrorLog('Product out of stock', P_InterimSalesHeader, _InterimSalesLine, 'SEQ11', false, '');
                            L_ErrorRecorded := TRUE;
                        end;
                    end;
                end
            end;

            if L_ErrorRecorded = false then begin
                if not L_Item.Get(_InterimSalesLine."No.") then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Product does not exist', P_InterimSalesHeader, _InterimSalesLine, 'SEQ4', false, '');
                    L_ErrorRecorded := TRUE;
                end
            end;

            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if L_Item.Blocked = true then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Record Locked (stock or depot stock file)', P_InterimSalesHeader, _InterimSalesLine, 'SEQ3', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if L_Item.Blocked = true then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Product is not available', P_InterimSalesHeader, _InterimSalesLine, 'SEQ22', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;
            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if L_Item.Blocked = true then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Product on stop', P_InterimSalesHeader, _InterimSalesLine, 'SEQ23', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if L_Item.Blocked = true then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Product on stop', P_InterimSalesHeader, _InterimSalesLine, 'SEQ29', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            if L_ErrorRecorded = false then begin
                //Check Company License ++
                Clear(L_AttributeCode);
                Clear(L_CompanyLicenseError);
                L_CheckItemLicense.ForIntegration_ValidateLicense(0, P_InterimSalesHeader."Sell-to Customer No.", P_InterimSalesHeader."Customer Posting Group", P_InterimSalesHeader."Ship-to Country/Region Code", P_InterimSalesHeader."Order Date", _InterimSalesLine."No.", P_InterimSalesHeader."Ship-to Post Code", L_CompanyLicenseError, L_AttributeCode);
                if L_CompanyLicenseError <> '' then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog(L_CompanyLicenseError, P_InterimSalesHeader, _InterimSalesLine, 'SEQ13', false, L_AttributeCode);
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;
    end;
}