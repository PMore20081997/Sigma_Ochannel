page 90060 "Apotech Order Header API"
{
    PageType = API;
    SourceTable = "Interim Sales Header";
    APIPublisher = 'Robosol';
    APIGroup = 'Apotechorders';
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
            field(ChannelCode; Rec."Trade Partner Code")
            {
                ApplicationArea = All;
            }
            field(ChannelOrderId; Rec."Channel Order ID")
            {
                ApplicationArea = All;
            }
            field(OrderReferenceNo; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(DocumentType; Rec."Document Type")
            {
                ApplicationArea = All;
            }
            field(ETAccessCode; Rec."ET Access Code")
            {
                ApplicationArea = All;
            }
            field(SelltoCustomerNo; Rec."Sell-to Customer No.")
            {
                ApplicationArea = All;
            }
            // field(CustomerOrderNo; Rec."External Document No.")
            // {
            //     ApplicationArea = All;
            // }
            field(DocumentDate; Rec."Document Date")
            {
                ApplicationArea = All;
            }
            field(ReasonCode; Rec."Reason Code")
            {
                ApplicationArea = ALl;
            }
            field(ReasonMessage; Rec."Reason Message")
            {
                ApplicationArea = All;
            }
            part(lines; "Avibuyer New Order Line")
            {
                EntitySetName = 'lines';
                EntityName = 'line';
                SubPageLink = "Header Id" = field(SystemId);
            }
        }
    }

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
        // NumberSeries: Record "No. Series Line";
        // NextNo: Code[20];
        // NoSeriesSingle: Interface "No. Series - Single";
        NoSeries: Codeunit "No. Series";
    begin
        //Clear(NextNo);
        if ((Rec."Trade Partner Code" <> '') and (Rec."Channel Order ID" <> '')) then begin
            //Duplicate Detection Code
            IsExist := CU_WebOrderManagement.CheckOrderNotExist(Rec."Trade Partner Code", Rec."Channel Order ID");
            if IsExist = false then begin
                Error(StrSubstNo('Order Already Exists With Order Id %1 For Channel Partner %2', Rec."Channel Order ID", Rec."Trade Partner Code"));
            end;

            //Insert Header Record++
            ChannelPartner.Get(Rec."Trade Partner Code");
            ChannelPartner.TestField("Channel Order No. Series");
            if ChannelPartner."PMR Order Issue" = false then begin
                Rec."No." := NoSeriesManagement.GetNextNo(ChannelPartner."Channel Order No. Series", WorkDate(), true);
                NoSeriesManagement.SaveState();
            end else begin
                // Rec."No." := NoSeries.GetNextNo(ChannelPartner."Channel Order No. Series", WorkDate());
                // Sleep(5);
                Rec."No." := Rec."Channel Order ID";
            end;
            // NumberSeries.Reset();
            // NumberSeries.SetRange("Series Code", ChannelPartner."Channel Order No. Series");
            // if NumberSeries.FindFirst() then begin
            //     NumberSeries.LockTable();
            //     NoSeriesSingle := GetImplementation(NumberSeries);
            //     NextNo := NoSeriesSingle.GetNextNo(NumberSeries, WorkDate(), true);
            //     Rec."No." := NextNo;
            //     if NumberSeries."Last No. Used" <> NextNo then
            //         NumberSeries."Last No. Used" := NextNo;
            //     NumberSeries.Modify();
            //     Clear(NumberSeries);
            // end;

            Rec.VALIDATE(Status, Rec.Status::Accepted);
            Rec.Validate("Order Date", WorkDate);
            Rec.Validate("ET Access Code", Rec."ET Access Code");
            L_CustomerRef.Reset();
            L_CustomerRef.SetRange("ET Access Code", Rec."ET Access Code");
            if L_CustomerRef.FindFirst() then
                Rec.Validate("Sell-to Customer No.", L_CustomerRef."Customer No.");

            if (Rec."Sell-to Customer No." <> '') then begin
                Case ChannelPartner."Customer Mapping" OF
                    ChannelPartner."Customer Mapping"::"Default Customer":
                        SellToCustomer.GET(ChannelPartner."Customer No.");
                    ChannelPartner."Customer Mapping"::"Order Customer":
                        SellToCustomer.GET(Rec."Sell-to Customer No.");
                End;
                if ChannelPartner."Customer Mapping" = ChannelPartner."Customer Mapping"::"ET Access Customer" then begin
                    SellToCustomer.Reset();
                    SellToCustomer.SetRange("No.", Rec."Sell-to Customer No.");
                    if SellToCustomer.FindFirst() then;
                end;

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
                Rec.Validate("Shipment Date", CalcDate('<+1D>', WorkDate()));

                // //Update Shipment Date++
                // L_Date.Reset();
                // L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                // L_Date.SetRange(L_Date."Period Start", Today);
                // if L_Date.FindFirst() then begin
                //     if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                //         if Rec."Weekend Ship Agent Serv Code" <> '' then begin
                //             L_ShippingAgentService.Reset();
                //             L_ShippingAgentService.SetRange("Shipping Agent Code", Rec."Weekend Shipping Agent Code");
                //             L_ShippingAgentService.SetRange(Code, Rec."Weekend Ship Agent Serv Code");
                //             if L_ShippingAgentService.FindFirst() then begin
                //                 if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::E then begin
                //                     if DT2Time(CurrentDateTime) < 190000T then
                //                         Rec.Validate("Shipment Date", CalcDate('<+1D>', Today))
                //                     else
                //                         Rec.Validate("Shipment Date", CalcDate('<+3D>', Today));
                //                 end;
                //             end;
                //         end
                //         else begin
                //             L_ShippingAgentService.Reset();
                //             L_ShippingAgentService.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                //             L_ShippingAgentService.SetRange(Code, Rec."Shipping Agent Service Code");
                //             if L_ShippingAgentService.FindFirst() then begin
                //                 if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::A then begin
                //                     if DT2Time(CurrentDateTime) < 170000T then
                //                         Rec.Validate("Shipment Date", CalcDate('<+1D>', Today))
                //                     else
                //                         Rec.Validate("Shipment Date", CalcDate('<+4D>', Today))
                //                 end;
                //                 if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::E then begin
                //                     if DT2Time(CurrentDateTime) < 190000T then
                //                         Rec.Validate("Shipment Date", CalcDate('<+1D>', Today))
                //                     else
                //                         Rec.Validate("Shipment Date", CalcDate('<+4D>', Today))
                //                 end;
                //             end;
                //         end;
                //     end
                //     else begin
                //         L_ShippingAgentService.Reset();
                //         L_ShippingAgentService.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                //         L_ShippingAgentService.SetRange(Code, Rec."Shipping Agent Service Code");
                //         if L_ShippingAgentService.FindFirst() then begin
                //             if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::A then begin
                //                 if DT2Time(CurrentDateTime) < 170000T then
                //                     Rec.Validate("Shipment Date", CalcDate('<+1D>', Today))
                //                 else
                //                     Rec.Validate("Shipment Date", CalcDate('<+2D>', Today))
                //             end;
                //             if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::E then begin
                //                 if DT2Time(CurrentDateTime) < 190000T then
                //                     Rec.Validate("Shipment Date", CalcDate('<+1D>', Today))
                //                 else
                //                     Rec.Validate("Shipment Date", CalcDate('<+2D>', Today))
                //             end;
                //         end;
                //     end;
                // end;

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

                BillToCustomer.Reset();
                BillToCustomer.SetRange("No.", SellToCustomer."Bill-to Customer No.");
                if BillToCustomer.FindFirst() then begin
                    Rec."Bill-to Customer No." := BillToCustomer."No.";
                    Rec."Bill- to Name" := BillToCustomer.Name;
                    Rec."Bill-to County" := BillToCustomer.County;
                end;

                Rec."Customer Price Group" := SellToCustomer."Customer Price Group";
            end;

            Rec."Web Shipment Method" := Rec."Web Shipment Method";
            Rec."Payment Method" := Rec."Payment Method";
            Rec."Currency Code" := Rec."Currency Code";
            Rec."Order Placed At" := CurrentDateTime;
            Rec."Order Created On" := CurrentDateTime;
            Rec."User ID" := UserId;
            Rec."File Name" := 'API';
            Rec.Validate("Order Amount", Rec."Order Amount");
            Rec.Validate("Order Discount Amount", Rec."Order Discount Amount");

            //Check Validation+++
            Sigma_SigConnectHeaderValidations(Rec);
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
    begin
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", Rec."Document Type");
        L_InterimSalesHeader.SetRange("No.", Rec."No.");
        if L_InterimSalesHeader.FindFirst() then begin
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
            L_Line.CalcFields("No of Error");
            L_Line.SetFilter("No of Error", '>%1', 0);
            if L_Line.FindSet() then
                ErrorCount := L_Line.Count;

            if LineCount = ErrorCount then begin
                CU_WebOrderMgmt.Sigma_InsertErrorLog('All product lines rejected', Rec, L_Line, 'SEQ13', true, '');
                L_InterimSalesHeader.status := L_InterimSalesHeader.status::Rejected;
            end;
            #endregion

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

            L_InterimSalesHeader."No. of Items" := CU_WebOrderMgmt.CalculateNoofItems(Rec);
            L_InterimSalesHeader.Modify();
        end;
        Commit();
    end;


    procedure Sigma_SigConnectHeaderValidations(var P_InterimSalesHeader: Record "Interim Sales Header")
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
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN
            L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");
            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
            IF PartnerErrorLog.FindSet() THEN
                PartnerErrorLog.DeleteAll();

            //Response SEQ3++
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
                    If (L_Cust.Blocked = L_Cust.Blocked::All) or (L_Cust.Status = L_Cust.Status::Open) or (L_Cust."QAU Approved" = false) then begin
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
        end;
    end;

    local procedure GetImplementation(var NoSeriesLine: Record "No. Series Line"): Interface "No. Series - Single"
    begin
        exit(NoSeriesLine.Implementation);
    end;

}