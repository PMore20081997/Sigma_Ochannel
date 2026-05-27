page 90071 "Liferay WebOrder API Card"
{
    PageType = API;
    SourceTable = "Interim Sales Header";
    APIPublisher = 'Robosol';
    APIGroup = 'LifeRayOrders';
    APIVersion = 'v2.0';
    EntitySetName = 'headers';
    EntityName = 'header';
    DelayedInsert = true;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            field(Id; Rec.SystemId)
            {
                ApplicationArea = All;
            }
            field(channel_code; Rec."Trade Partner Code")
            {
                ApplicationArea = All;
            }
            field(channel_orderid; Rec."Channel Order ID")
            {
                ApplicationArea = All;
            }
            field(order_reference_no; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(document_type; Rec."Document Type")
            {
                ApplicationArea = All;
            }
            field(sell_to_customer_no; Rec."Sell-to Customer No.")
            {
                ApplicationArea = All;
            }
            // field(document_date; Rec."Document Date")
            // {
            //     ApplicationArea = All;
            // }
            field(document_date; DocumentDateText)
            {
                ApplicationArea = All;
                Caption = 'Document Date';
                // This field is used for input from API
                trigger OnValidate()
                var
                    Day: Integer;
                    Month: Integer;
                    Year: Integer;
                    DateParts: List of [Text];
                begin
                    // Parse DD-MM-YYYY
                    if StrLen(DocumentDateText) = 10 then begin
                        DateParts := DocumentDateText.Split('-');
                        if DateParts.Count = 3 then begin
                            Evaluate(Day, DateParts.Get(1));
                            Evaluate(Month, DateParts.Get(2));
                            Evaluate(Year, DateParts.Get(3));
                            Rec."Document Date" := DMY2Date(Day, Month, Year);
                        end;
                    end;
                end;
            }
            field(reason_code; Rec."Reason Code")
            {
                ApplicationArea = All;
            }
            field(reason_message; Rec."Reason Message")
            {
                ApplicationArea = All;
            }
            field(order_total; Rec."Total Order")
            {
                ApplicationArea = All;
            }
            field(consolidated; Rec."Consolidated Order")
            {
                ApplicationArea = All;
            }
            field(special; Rec.Special)
            {
                ApplicationArea = All;
            }

            part(lines; "LifeRay WebOrder Subpage")
            {
                EntitySetName = 'lines';
                EntityName = 'line';
                SubPageLink = "Header Id" = field(SystemId);
            }
        }
    }

    var
        DocumentDateText: Text;
        G_IsPOSTMethod: Boolean;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        IsExist: Boolean;
        ChannelPartner: Record "Trade Partner";
        SellToCustomer: Record Customer;
        L_ShiptoAddress: Record "Ship-to Address";
        BillToCustomer: Record Customer;
        NoSeriesManagement: Codeunit "No. Series - Batch";
        L_Date: Record Date;
        L_CustomerRef: Record "Customer Reference";
        OrderResponse: Text;
        L_ShippingAgentService: Record "Shipping Agent Services";
        L_SalesHeader: Record "Sales Header";
        NoSeries: Codeunit "No. Series";
        L_Shift: Text[20];
    begin
        //OnInsertRecord trigger is not excute at the time of GET Call++
        Clear(G_IsPOSTMethod);
        G_IsPOSTMethod := true;

        //Check mandatory fields++
        Rec.TestField("Trade Partner Code");
        Rec.TestField("Channel Order ID");
        Rec.TestField("Document Type", Rec."Document Type"::Order);

        //Check Duplicate order++
        IsExist := CU_WebOrderManagement.CheckOrderNotExist(Rec."Trade Partner Code", Rec."Channel Order ID");
        if IsExist = false then begin
            Error(StrSubstNo('Order Already Exists With Order Id %1 For Channel Partner %2', Rec."Channel Order ID", Rec."Trade Partner Code"));
        end;

        #Region Process to Insert Header++
        ChannelPartner.Get(Rec."Trade Partner Code");


        Rec."No." := Rec."Channel Order ID";
        Rec.VALIDATE(Status, Rec.Status::Accepted);
        Rec.Validate("Order Date", WorkDate);
        Rec.Validate("ET Access Code", Rec."ET Access Code");

        //Get Customer table++
        SellToCustomer.Reset();
        Case ChannelPartner."Customer Mapping" OF
            ChannelPartner."Customer Mapping"::"Default Customer":
                begin
                    if SellToCustomer.GET(ChannelPartner."Customer No.") then;
                end;
            ChannelPartner."Customer Mapping"::"Order Customer":
                begin
                    if SellToCustomer.GET(Rec."Sell-to Customer No.") then;
                end;
            ChannelPartner."Customer Mapping"::"ET Access Customer":
                begin
                    L_CustomerRef.Reset();
                    L_CustomerRef.SetRange("ET Access Code", Rec."ET Access Code");
                    if L_CustomerRef.FindFirst() then
                        Rec.Validate("Sell-to Customer No.", L_CustomerRef."Customer No.");
                    if SellToCustomer.GET(Rec."Sell-to Customer No.") then;
                end;
        End;

        Rec.VALIDATE(Address, SellToCustomer.Address);
        Rec.VALIDATE("Address 2", SellToCustomer."Address 2");
        Rec.VALIDATE(City, SellToCustomer.City);
        Rec.VALIDATE("Post Code", SellToCustomer."Post Code");
        Rec.VALIDATE("Sell to Country", SellToCustomer."Country/Region Code");
        if ChannelPartner.Location <> '' then
            Rec.Validate("Location Code", ChannelPartner.Location)
        else
            Rec.validate("Location Code", SellToCustomer."Location Code");
        Rec.Validate("MultiLine Order No.", Rec."MultiLine Order No.");
        Rec.Validate("Shipment Method Code", SellToCustomer."Shipment Method Code");
        Rec.Validate("Shipping Agent Code", SellToCustomer."Shipping Agent Code");
        Rec.Validate("Shipping Agent Service Code", SellToCustomer."Shipping Agent Service Code");
        Rec.Validate("Weekend Shipping Agent Code", SellToCustomer."Weekend Shipping Agent Code");
        Rec.Validate("Weekend Ship Agent Serv Code", SellToCustomer."Weekend Ship. Agnt. Serv. Code");

        //Update Shipment Date++
        //Rec.Validate("Shipment Date", CalcDate('<+1D>', WorkDate())); //Shipment logic - checking at the time of consolidation++
        Clear(L_Shift);
        L_Date.Reset();
        L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
        L_Date.SetRange(L_Date."Period Start", WorkDate());
        if L_Date.FindFirst() then begin
            if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin

                //Get Shift
                L_ShippingAgentService.Reset();
                if (SellToCustomer."Weekend Shipping Agent Code" <> '') AND (SellToCustomer."Weekend Ship. Agnt. Serv. Code" <> '') then begin
                    L_ShippingAgentService.SetRange("Shipping Agent Code", SellToCustomer."Weekend Shipping Agent Code");
                    L_ShippingAgentService.SetRange(Code, SellToCustomer."Weekend Ship. Agnt. Serv. Code");
                end else begin
                    L_ShippingAgentService.SetRange("Shipping Agent Code", SellToCustomer."Shipping Agent Code");
                    L_ShippingAgentService.SetRange(Code, SellToCustomer."Shipping Agent Service Code");
                end;
                if L_ShippingAgentService.FindFirst() then
                    L_Shift := Format(L_ShippingAgentService.Shift);


                //E - Shift
                if UpperCase(L_Shift) = UpperCase('E') then begin
                    if (SellToCustomer."Weekend Shipping Agent Code" <> '') AND (SellToCustomer."Weekend Ship. Agnt. Serv. Code" <> '') then
                        //Update Saturday++
                        Rec.Validate("Shipment Date", CalcDate('<+1D>', WorkDate()))
                    else begin
                        //Update Monday
                        Rec.Validate("Shipment Date", CalcDate('<+3D>', WorkDate()));
                    end;
                end;

                //A - Shift
                if UpperCase(L_Shift) = UpperCase('A') then begin
                    //Update Monday
                    Rec.Validate("Shipment Date", CalcDate('<+3D>', WorkDate()));
                end;

                //M - Shift
                //Phase2+++

                //X - Shift
                //Phase2+++
            end else begin
                //As discussed shipment date shoud be next day all condistion++
                Rec.Validate("Shipment Date", CalcDate('<+1D>', WorkDate()))
            end;
        end;

        //Shippig details++
        L_ShiptoAddress.Reset();
        L_ShiptoAddress.SetRange(Code, SellToCustomer."Ship-to Code");
        if L_ShiptoAddress.FindFirst() then begin
            Rec.Validate("Ship-to Code", L_ShiptoAddress.Code);
            Rec.VALIDATE("Ship-to Name", L_ShiptoAddress.Name);
            Rec.VALIDATE("Ship-to Address", L_ShiptoAddress.Address);
            Rec.VALIDATE("Ship-to Address 2", L_ShiptoAddress."Address 2");
            Rec.VALIDATE("Ship-to City", L_ShiptoAddress.City);
            Rec.VALIDATE("Ship-to County", L_ShiptoAddress.County);
            Rec.VALIDATE("Ship-to Country/Region Code", L_ShiptoAddress."Country/Region Code");
            Rec.VALIDATE("Ship-to Post Code", L_ShiptoAddress."Post Code");
            Rec.VALIDATE("Ship-to Phone", L_ShiptoAddress."Phone No.");
            Rec.VALIDATE("Ship-to Email", L_ShiptoAddress."E-Mail");
            Rec."Customer Posting Group" := SellToCustomer."Customer Posting Group";
        end else begin
            Rec.VALIDATE("Ship-to Name", SellToCustomer.Name);
            Rec.VALIDATE("Ship-to Address", SellToCustomer.Address);
            Rec.VALIDATE("Ship-to Address 2", SellToCustomer."Address 2");
            Rec.VALIDATE("Ship-to City", SellToCustomer.City);
            Rec.VALIDATE("Ship-to County", SellToCustomer.County);
            Rec.VALIDATE("Ship-to Country/Region Code", SellToCustomer."Country/Region Code");
            Rec.VALIDATE("Ship-to Post Code", SellToCustomer."Post Code");
            Rec.VALIDATE("Ship-to Phone", SellToCustomer."Phone No.");
            Rec.VALIDATE("Ship-to Email", SellToCustomer."E-Mail");
            Rec."Customer Posting Group" := SellToCustomer."Customer Posting Group";
        end;

        //Update Bill-to Details++
        BillToCustomer.Reset();
        BillToCustomer.SetRange("No.", SellToCustomer."Bill-to Customer No.");
        if BillToCustomer.FindFirst() then begin
            Rec."Bill-to Customer No." := BillToCustomer."No.";
            Rec."Bill- to Name" := BillToCustomer.Name;
            Rec."Bill-to County" := BillToCustomer.County;
        end;
        Rec."Customer Price Group" := SellToCustomer."Customer Price Group";
        Rec."Web Shipment Method" := Rec."Web Shipment Method";
        Rec."Payment Method" := Rec."Payment Method";
        Rec."Currency Code" := Rec."Currency Code";
        Rec."Order Placed At" := CurrentDateTime;
        Rec."Order Created On" := CurrentDateTime;
        Rec."User ID" := UserId;
        Rec."File Name" := 'API';
        Rec.Validate("Order Amount", Rec."Order Amount");
        Rec.Validate("Order Discount Amount", Rec."Order Discount Amount");
        #EndRegion Process to Insert Header++


        //for the consolidated order, we will not do any validation at header level, just set the reason code as 'Order Created' and reason message as 'Accepted', and validate at line level. For non-consolidated order, we will do the header level validation, and if any error found, set the reason code as 'Order Created' and reason message as 'Rejected', and skip line level validation++
        if Rec."Consolidated Order" = false then begin
            //Check Validation+++
            HeaderValidations(Rec);
        end;
    end;

    trigger OnAfterGetRecord()
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Line: Record "Interim Sales Line";
        LineCount: Integer;
        ErrorCount: Integer;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_OrderLevelResponse: Record "Order Level Response";
        L_InterimSalesHeader: Record "Interim Sales Header";
        TempSalesHeader: Record "Web Buffer";
    begin
        //Skip the code in case of GET call from API
        if G_IsPOSTMethod = false then
            exit;

        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", Rec."Document Type");
        L_InterimSalesHeader.SetRange("No.", Rec."No.");
        if L_InterimSalesHeader.FindFirst() then begin
            //for the consolidated order we will not check the header level error
            if L_InterimSalesHeader."Consolidated Order" = false then begin
                #Region All product lines rejected Error SEQ13
                Clear(LineCount);
                L_Line.Reset();
                L_Line.SetRange("Document Type", Rec."Document Type");
                L_Line.SetRange("Document No", Rec."No.");
                L_Line.SetRange(Type, L_Line.Type::Item);
                if L_Line.FindSet() then
                    LineCount := L_Line.Count;

                Clear(ErrorCount);
                L_Line.Reset();
                L_Line.SetRange("Document Type", Rec."Document Type");
                L_Line.SetRange("Document No", Rec."No.");
                L_Line.SetRange(Type, L_Line.Type::Item);
                L_Line.SetFilter("Reason Code", '<>%1&<>%2', 'Order line created', 'Partial Quantity Delivered');
                L_Line.CalcFields("No of Error");
                L_Line.SetFilter("No of Error", '>%1', 0);
                if L_Line.FindSet() then
                    ErrorCount := L_Line.Count;

                if LineCount = ErrorCount then begin
                    CU_WebOrderMgmt.Sigma_InsertErrorLog('All product lines rejected', Rec, L_Line, 'SEQ13', true, '');
                    L_InterimSalesHeader.status := L_InterimSalesHeader.status::Rejected;
                end;
                #endregion  All product lines rejected Error SEQ13

                PartnerErrorLog.Reset();
                PartnerErrorLog.SetRange("Document No.", Rec."No.");
                PartnerErrorLog.SetFilter("Item No.", '%1', '');
                PartnerErrorLog.SetCurrentKey("Sequence No.");
                PartnerErrorLog.Ascending(true);
                IF PartnerErrorLog.FindFirst() THEN begin
                    L_OrderLevelResponse.Reset();
                    L_OrderLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                    if L_OrderLevelResponse.FindFirst() then begin
                        Rec."Reason Code" := L_OrderLevelResponse.Reason;
                        Rec."Reason Message" := L_OrderLevelResponse.Message;
                        L_InterimSalesHeader."Reason Code" := L_OrderLevelResponse.Reason;
                        L_InterimSalesHeader."Reason Message" := L_OrderLevelResponse.Message;
                    end;
                end else begin
                    Rec."Reason Code" := 'Order Created';
                    Rec."Reason Message" := 'Accepted';
                    L_InterimSalesHeader."Reason Code" := 'Order Created';
                    L_InterimSalesHeader."Reason Message" := 'Accepted';
                end;

                if UpperCase(Rec."Reason Message") = UpperCase('Accepted') then begin
                    L_InterimSalesLine.Reset();
                    L_InterimSalesLine.SetRange("Document Type", Rec."Document Type");
                    L_InterimSalesLine.SetRange("Document No", Rec."No.");
                    L_InterimSalesLine.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
                    if L_InterimSalesLine.FindFirst() then begin
                        L_InterimSalesHeader.status := L_InterimSalesHeader.status::Accepted;
                        L_InterimSalesHeader."Ready to process" := true;
                    end else begin
                        L_InterimSalesHeader.status := L_InterimSalesHeader.status::Rejected;
                    end;
                end else begin
                    L_InterimSalesHeader.status := L_InterimSalesHeader.status::Rejected;
                end;

                //This code Moved to CodeUnit 90066 (SingleOrder_ProcessTemporarySalesLinetoSalesOrder)+++
                // //Insert Web Buffer for Normal web Order not for consolidated order as for consolidated order we will create buffer at the time of consolidation++
                // TempSalesHeader.RESET;
                // TempSalesHeader.SETRANGE("Web Document No.", L_InterimSalesHeader."No.");
                // IF NOT TempSalesHeader.FINDFIRST THEN BEGIN
                //     TempSalesHeader.INIT;
                //     TempSalesHeader."Trade Partner Code" := L_InterimSalesHeader."Trade Partner Code";
                //     TempSalesHeader."Web Document No." := L_InterimSalesHeader."No.";
                //     TempSalesHeader."Sales Document No." := 'LifeRayNormalOrder';
                //     TempSalesHeader."Created At" := WorkDate();
                //     TempSalesHeader.INSERT;
                // END;
                //This code Moved to CodeUnit 90066 (SingleOrder_ProcessTemporarySalesLinetoSalesOrder)+++
            end else begin
                Rec."Reason Code" := 'Order Created';
                Rec."Reason Message" := 'Accepted';
                L_InterimSalesHeader."Reason Code" := 'Order Created';
                L_InterimSalesHeader."Reason Message" := 'Accepted';
            end;

            //+++
            L_InterimSalesHeader."No. of Items" := CU_WebOrderMgmt.CalculateNoofItems(Rec);
            L_InterimSalesHeader."Total Order" := CalculateTotalOrderAmount(Rec);
            Rec."Total Order" := L_InterimSalesHeader."Total Order";
            L_InterimSalesHeader.Modify();
        end;

        //Commit++
        Commit();
    end;

    procedure HeaderValidations(var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ErrorRecorded: Boolean;
        L_Cust: Record Customer;
        L_ShippingRule: Record "Shipping Rule";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Item: Record Item;
        L_TradePartner: Record "Trade Partner";
        TotalItems: Integer;
        Countries: Record "Country/Region";
        L_CustRef: Record "Customer Reference";
        LineCount: Integer;
        ErrorCount: Integer;
        CU_WebOrderManagement: Codeunit "Web Order Mgt";
        L_BilltoCustomer: Code[20];
        L_CheckCreditLimit: Codeunit "Check Crdit/OverDue for IRP";
    begin
        //Get Trade Partner++
        L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");


        //Clear Error Log++
        PartnerErrorLog.RESET;
        PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
        IF PartnerErrorLog.FindSet() THEN
            PartnerErrorLog.DeleteAll();


        //Response SEQ3++
        if L_TradePartner."Customer Mapping" = L_TradePartner."Customer Mapping"::"ET Access Customer" then begin
            if L_ErrorRecorded = false then begin
                if L_TradePartner."Inbox Type" = L_TradePartner."Inbox Type"::"File Location" then begin
                    L_CustRef.Reset();
                    L_CustRef.SetRange("Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
                    L_CustRef.SetRange("ET Access Code", P_InterimSalesHeader."ET Access Code");
                    if NOT L_CustRef.FindFirst() then begin
                        CU_WebOrderManagement.Sigma_InsertErrorLog('Unauthorised Electronic Access - Contact Sigma', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ3', true, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Response SEQ4++
            if L_ErrorRecorded = false then begin
                if L_TradePartner."Inbox Type" = L_TradePartner."Inbox Type"::"File Location" then begin
                    L_CustRef.Reset();
                    L_CustRef.SetRange("Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
                    L_CustRef.SetRange("ET Access Code", P_InterimSalesHeader."ET Access Code");
                    if L_CustRef.FindFirst() then begin
                        if L_CustRef.Locked = true then begin
                            CU_WebOrderManagement.Sigma_InsertErrorLog('cross reference record locked', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ4', true, '');
                            L_ErrorRecorded := TRUE;
                        end;
                    end;
                end;
            end;
        end;

        //Response SEQ5++
        CLEAR(L_ErrorRecorded);
        L_InterimSalesLine.RESET;
        if L_ErrorRecorded = false then begin
            IF P_InterimSalesHeader."Sell-to Customer No." = '' THEN BEGIN
                CU_WebOrderManagement.Sigma_InsertErrorLog('Value for customer no must not be blank', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ5', true, '');
                L_ErrorRecorded := TRUE;
            END;
        end;

        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            IF NOT L_Cust.GET(P_InterimSalesHeader."Sell-to Customer No.") THEN BEGIN
                CU_WebOrderManagement.Sigma_InsertErrorLog('Customer not on file', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ5', true, '');
                L_ErrorRecorded := TRUE;
            END;
        end;
        //Response SEQ5--

        //Response SEQ6++
        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                If (L_Cust.Blocked = L_Cust.Blocked::All) or (L_Cust.Status = L_Cust.Status::Open) then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Customer locked', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ6', true, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;

        //Response SEQ7++
        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                If L_Cust.Blocked = L_Cust.Blocked::Ship then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Customer on Stop **', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ7', true, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;

        //Response SEQ8++
        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                If L_Cust.Blocked = L_Cust.Blocked::Invoice then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Account on Payment Stop - Contact Sigma', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ8', true, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;

        //Response SEQ9++
        Clear(L_BilltoCustomer);
        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                if L_Cust."Bill-to Customer No." <> '' then
                    L_BilltoCustomer := L_Cust."Bill-to Customer No."
                else
                    L_BilltoCustomer := L_Cust."No.";
            end;

            // L_Cust.Reset();
            // if L_Cust.Get(L_BilltoCustomer) then begin
            //     L_Cust.CalcFields("Balance (LCY)");
            //     if L_Cust."Balance (LCY)" > L_Cust."Credit Limit (LCY)" then begin
            //         CU_WebOrderManagement.Sigma_InsertErrorLog(STRSUBSTNO('Customer No %1 is Over Credit Limit***', P_InterimSalesHeader."Sell-to Customer No."), P_InterimSalesHeader, L_InterimSalesLine, 'SEQ9', true, '');
            //         L_ErrorRecorded := TRUE;
            //     end;
            // end;

            L_Cust.Reset();
            if L_Cust.Get(L_BilltoCustomer) then begin
                if L_CheckCreditLimit.CheckCreditLimitAndOverDue(L_Cust."No.") = true then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog(STRSUBSTNO('Customer No %1 is Over Credit Limit***', P_InterimSalesHeader."Sell-to Customer No."), P_InterimSalesHeader, L_InterimSalesLine, 'SEQ9', true, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;

        //Response SEQ10++
        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                if L_Cust."Payment Terms Code" = '0D-COD' then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('COD Account *********', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ10', true, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;

        //Response SEQ12++
        if L_ErrorRecorded = false then begin
            L_Cust.Reset();
            if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                If (L_Cust."Shipping Agent Code" = '') or (L_Cust."Shipping Agent Service Code" = '') then begin
                    CU_WebOrderManagement.Sigma_InsertErrorLog('Delivery Schedule not assigned, contact Sigma', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ12', true, '');
                    L_ErrorRecorded := TRUE;
                end;
            end;
        end;

        //SEQ13 - Code avaible in OnAfterGetRecord() trigger++
    end;

    local procedure CalculateTotalOrderAmount(_InterimSalesHeader: Record "Interim Sales Header"): Decimal
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_TotalOrder: Decimal;
    begin
        Clear(L_TotalOrder);
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document Type", _InterimSalesHeader."Document Type");
        L_InterimSalesLine.SetRange("Document No", _InterimSalesHeader."No.");
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        if L_InterimSalesLine.FindSet() then begin
            repeat
                L_TotalOrder += L_InterimSalesLine."Qty. to Deliver" * L_InterimSalesLine."Unit Price";
            until L_InterimSalesLine.Next() = 0;
        end;
        exit(L_TotalOrder);
    end;

}