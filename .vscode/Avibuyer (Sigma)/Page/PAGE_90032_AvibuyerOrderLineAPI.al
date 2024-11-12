page 90032 "Avibuyer Order Line Subpage"
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
                field(id; Rec.SystemId)
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
                field(PIPCode; PIPCode)
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
                }
                field("Qty. to Deliver"; Rec."Qty. to Deliver")
                {
                    ApplicationArea = All;
                }
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
        PIPCode: Text;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        MyHeader: Record "Interim Sales Header";
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ProductLevelResponse: Record "Product Level Response";
        L_Item: Record Item;
        AvailableInventory: Decimal;
        ItemReference: Record "Item Reference";
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

            Rec."Channel SKU" := CopyStr(PIPCode, 1, 50);
            ItemReference.Reset();
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"PIP Code");
            ItemReference.SetRange("Reference No.", CopyStr(PIPCode, 1, 50));
            IF ItemReference.FindFirst() then
                Rec.Validate("No.", ItemReference."Item No.");

            L_Item.Reset();
            if L_Item.Get(Rec."No.") then begin
                Rec.Description := L_Item.Description;
                Rec."Item Category Code" := L_Item."Item Category Code";
                Rec.Description2 := L_Item."Description 2";
                Rec."Unit of Measure Code" := L_Item."Sales Unit of Measure";
            end;
            Rec."Shipment Date" := MyHeader."Shipment Date";

            //Check Available Qty++
            Clear(AvailableInventory);
            AvailableInventory := CU_WebOrderManagement.CalculateQtyToDeliver(Rec);
            Rec."Qty. to Deliver" := AvailableInventory;

            //Check Validation+++
            Sigma_LineValidations(MyHeader, Rec);

            //Update Interim header and Interim Line Response Code and Message++
            //Line++
            if (UpperCase(Rec."Reason Code") <> UpperCase('Partial Quantity Delivered')) then begin
                PartnerErrorLog.RESET;
                PartnerErrorLog.SETRANGE("Document No.", MyHeader."No.");
                PartnerErrorLog.SetFilter("Item No.", Rec."No.");
                PartnerErrorLog.SetCurrentKey("Sequence No.");
                PartnerErrorLog.Ascending(true);
                IF PartnerErrorLog.FindFirst() THEN begin
                    L_ProductLevelResponse.Reset();
                    L_ProductLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                    if L_ProductLevelResponse.FindFirst() then begin
                        Rec."Reason Code" := L_ProductLevelResponse.Reason;
                        Rec."Reason Message" := L_ProductLevelResponse.Message;
                        Rec."Qty. to Deliver" := 0;
                    end;
                end else begin
                    Rec."Reason Code" := 'Order Line Created';
                    Rec."Reason Message" := 'Successful';
                end;
            end;
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        MyHeader: Record "Interim Sales Header";
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
        L_CompanyLicenseError: Text[250];
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        Duplicate_InterimSalesLine: Record "Interim Sales Line";
        ItemBlockedError: Text;
        QuotaQuantity: Decimal;
        CU_SalesQuotaQtyValidation: Codeunit "Web Order Sales Quota New";
    begin
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN
            L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");

            Clear(L_ErrorRecorded);
            //Response SEQ3++
            if L_ErrorRecorded = false then begin
                Clear(ItemBlockedError);
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if (L_Item.Blocked = true) or (L_Item."Sales Blocked" = true) or (L_Item."Ops Sales Blocked" = true) or (L_Item.Status = L_Item.Status::Open) or (L_Item."QAU Approved" = false) then begin
                        ItemBlockedError := CU_WebOrderManagement.CheckItemBlockedError(L_Item);
                        CU_WebOrderManagement.Sigma_InsertErrorLog(ItemBlockedError, P_InterimSalesHeader, _InterimSalesLine, 'SEQ3', false, '');
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

            //Response SEQ9 and SEQ11++
            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if CU_WebOrderManagement.CalculateQtyToDeliver(_InterimSalesLine) = 0 then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Product out of stock', P_InterimSalesHeader, _InterimSalesLine, 'SEQ9', false, '');
                        L_ErrorRecorded := TRUE;
                    end else begin
                        //SEQ11++
                        Clear(QuotaQuantity);
                        if CU_SalesQuotaQtyValidation.CheckExceededQty(_InterimSalesLine, P_InterimSalesHeader, QuotaQuantity) <> CU_SalesQuotaQtyValidation.CheckExceededQty(_InterimSalesLine, P_InterimSalesHeader, QuotaQuantity) ::"No Entry" then begin
                            if QuotaQuantity < 0 then
                                QuotaQuantity := 0;

                            if QuotaQuantity > 0 then begin
                                if _InterimSalesLine."Qty. to Deliver" > QuotaQuantity then begin
                                    _InterimSalesLine."Reason Code" := 'Partial Quantity Delivered';
                                    _InterimSalesLine."Reason Message" := 'Partial Quantity Delivered';
                                    _InterimSalesLine."Qty. to Deliver" := QuotaQuantity;
                                end;
                            end else begin
                                CU_WebOrderManagement.Sigma_InsertErrorLog('Product out of stock because of Quota', P_InterimSalesHeader, _InterimSalesLine, 'SEQ11', false, '');
                                L_ErrorRecorded := TRUE;

                                //Update Line
                                _InterimSalesLine."Reason Code" := 'Partial Quantity Delivered';
                                _InterimSalesLine."Reason Message" := 'Partial Quantity Delivered';
                                _InterimSalesLine."Qty. to Deliver" := 0;
                            end;
                        end;
                    end;
                end;
            end;

            //"Temperature Blocked" Response (Using it For Shipping Agent Service Item Restriction SEQ10++
            if L_ErrorRecorded = false then begin
                if L_Item.Get(_InterimSalesLine."No.") then begin
                    if CU_WebOrderManagement.CheckShippingAgentServiceRestriction(_InterimSalesLine."No.", P_InterimSalesHeader."Shipping Agent Code", P_InterimSalesHeader."Shipping Agent Service Code") then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Temperature blocked', P_InterimSalesHeader, _InterimSalesLine, 'SEQ10', false, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;
        end;
    end;
}