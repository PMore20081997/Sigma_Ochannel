
/*
++++++++++++++++++++++++Structured code for license check+++++++++++++++++++++++ CS++++++
Create below functions

Function: CreateWebOrder
Description: Common function to create web order.
Date:08/02/21
CalledFrom: Called from all integration codeunit.

Function: InsertSalesLine
Description: Function to insert sales line.
Date:08/02/21
CalledFrom: CreateWebOrder

Function: FindItemNo
Description: Function to Get Item no based on the setup done on Channel Partner.
Date:08/02/21
CalledFrom: InsertSalesLine

Function: FindUOM
Description: Function to Get UoM based on the setup done on Channel Partner.
Date:08/02/21
CalledFrom: InsertSalesLine

Function: CreateGLLines
Description: Function to create shipping GL line and Gift wrap GL line. For Shipping GL line if amount in 0 in lines then check shipping rule if shipping charge is applicable.
Date:08/02/21
CalledFrom: CreateWebOrder

Function: InsertGLLines
Description: Function to insert GL lines.
Date:08/02/21
CalledFrom: CreateGLLines

Function: ExplodeBOM
Description: Function to create components line in interim sales line table when Assembly BOM item is imported.
Date:08/02/21
CalledFrom: On Insert Trigger of interim sales line table.

Function: CheckOrderNotExist
Description: Code to check if channel order id already exists in interim sales header or Handled interim sales header 
Date:08/02/21
CalledFrom:CreateWebOrder.

Function: OrderValidations
Description: Function to check all the validations.
Date:08/02/21
CalledFrom: CreateWebOrder.

Function: InsertErrorLog
Description: Code to insert error log.
Date:08/02/21
CalledFrom: OrderValidations.

Function: GetNavShippingAgentFromWebShipping
Description: Code to get shipping agent.
Date:08/02/21
CalledFrom: OrderValidations.

Function: ValidateItemSetup
Description: Check Item validation confitions
Date:08/02/21
CalledFrom: OrderValidations.

Function: GetItemNo
Description: Get Item no from the channel item listing and chek validations.
Date:08/02/21
CalledFrom: OrderValidations.

Function: GetWeightFromItemUoM
Description: Get weight from item UoM if it's 0.
Date:08/02/21
CalledFrom: OrderValidations.

Function: ItemLinePrice
Description: Get price form channel item listing based on condition.
Date:08/02/21
CalledFrom: OrderValidations.

++++++++++++++++++++++++Structured code for license check+++++++++++++++++++++++ CS+++++++
*/
codeunit 90000 "Web Order Mgt"
{
    Permissions = tabledata "Registered Whse. Activity Hdr." = RIMD, tabledata "Sales Shipment Header" = RIMD;

    procedure Sigma_CreateWebOrder(var P_InterimSalesHeader: Record "Interim Sales Header" temporary; var P_InterimSalesLine: Record "Interim Sales Line" temporary; P_ShipmentTracking: Record "Shipment Tracking" temporary; var P_PaymentDetail: Record "Channel Media" temporary)
    //Code to create a web Order and Line based on the data coming from diffrent channel integration code unit
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        NoSeriesManagement: Codeunit "No. Series - Batch";
        SellToCustomer: Record Customer;
        ChannelPartner: Record "Trade Partner";
        Discountperscent: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Item: Record Item;
        CountriesRegion: Record "Country/Region";
        L_PaymentDetails: Record "Channel Media";
        ShipmentTracking: Record "Shipment Tracking";
        L_ShiptoAddress: Record "Ship-to Address";
        BillToCustomer: Record Customer;
        L_Date: Record Date;
        L_ShippingAgentService: Record "Shipping Agent Services";
        NoSeries: Codeunit "No. Series";
    Begin
        ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
        ChannelPartner.TestField("Channel Order No. Series");

        //Insert Header+++
        L_InterimSalesHeader.Init();
        L_InterimSalesHeader."Document Type" := L_InterimSalesHeader."Document Type"::Order;
        if ChannelPartner."PMR Order Issue" = false then begin
            L_InterimSalesHeader."No." := NoSeriesManagement.GetNextNo(ChannelPartner."Channel Order No. Series", Today, true);
            NoSeriesManagement.SaveState();
        end else begin
            L_InterimSalesHeader."No." := NoSeries.GetNextNo(ChannelPartner."Channel Order No. Series", WorkDate());
            Sleep(5);
        end;
        L_InterimSalesHeader.Validate(Status, L_InterimSalesHeader.Status::Accepted);
        L_InterimSalesHeader.Validate("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesHeader.Validate("ET Access Code", P_InterimSalesHeader."ET Access Code");
        L_InterimSalesHeader.validate("Document Date", WorkDate);
        L_InterimSalesHeader.Validate("Order Date", WorkDate);

        if (P_InterimSalesHeader."Sell-to Customer No." <> '') then begin
            Case ChannelPartner."Customer Mapping" OF
                ChannelPartner."Customer Mapping"::"Default Customer":
                    SellToCustomer.GET(ChannelPartner."Customer No.");
                ChannelPartner."Customer Mapping"::"Order Customer":
                    SellToCustomer.GET(P_InterimSalesHeader."Sell-to Customer No.");
            End;

            if ChannelPartner."Customer Mapping" = ChannelPartner."Customer Mapping"::"ET Access Customer" then begin
                SellToCustomer.Reset();
                SellToCustomer.SetRange("No.", P_InterimSalesHeader."Sell-to Customer No.");
                if SellToCustomer.FindFirst() then;
            end;

            if SellToCustomer."No." = '' then begin
                L_InterimSalesHeader.Validate("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
                L_InterimSalesHeader.Validate("Location Code", ChannelPartner.Location);
            end else begin
                L_InterimSalesHeader.Validate("Sell-to Customer No.", SellToCustomer."No.");
                L_InterimSalesHeader.Validate(Address, SellToCustomer.Address);
                L_InterimSalesHeader.Validate("Address 2", SellToCustomer."Address 2");
                L_InterimSalesHeader.Validate(City, SellToCustomer.City);
                L_InterimSalesHeader.Validate("Post Code", SellToCustomer."Post Code");
                L_InterimSalesHeader.Validate("Sell to Country", SellToCustomer."Country/Region Code");
                if ChannelPartner.Location <> '' then
                    L_InterimSalesHeader.Validate("Location Code", ChannelPartner.Location)
                else
                    L_InterimSalesHeader.validate("Location Code", SellToCustomer."Location Code");

                L_InterimSalesHeader.Validate("MultiLine Order No.", P_InterimSalesHeader."MultiLine Order No.");
                L_InterimSalesHeader.Validate("Shipment Method Code", SellToCustomer."Shipment Method Code");
                L_InterimSalesHeader.Validate("Shipping Agent Code", SellToCustomer."Shipping Agent Code");
                L_InterimSalesHeader.Validate("Shipping Agent Service Code", SellToCustomer."Shipping Agent Service Code");
                L_InterimSalesHeader.Validate("Weekend Shipping Agent Code", SellToCustomer."Weekend Shipping Agent Code");
                L_InterimSalesHeader.Validate("Weekend Ship Agent Serv Code", SellToCustomer."Weekend Ship. Agnt. Serv. Code");

                //Update Shipment Date++
                L_Date.Reset();
                L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                L_Date.SetRange(L_Date."Period Start", Today);
                if L_Date.FindFirst() then begin
                    if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                        if L_InterimSalesHeader."Weekend Ship Agent Serv Code" <> '' then begin
                            L_ShippingAgentService.Reset();
                            L_ShippingAgentService.SetRange("Shipping Agent Code", L_InterimSalesHeader."Weekend Shipping Agent Code");
                            L_ShippingAgentService.SetRange(Code, L_InterimSalesHeader."Weekend Ship Agent Serv Code");
                            if L_ShippingAgentService.FindFirst() then begin
                                if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::E then begin
                                    if DT2Time(CurrentDateTime) < 190000T then
                                        L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today))
                                    else
                                        L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+3D>', Today));
                                end;
                            end;
                        end
                        else begin
                            L_ShippingAgentService.Reset();
                            L_ShippingAgentService.SetRange("Shipping Agent Code", L_InterimSalesHeader."Shipping Agent Code");
                            L_ShippingAgentService.SetRange(Code, L_InterimSalesHeader."Shipping Agent Service Code");
                            if L_ShippingAgentService.FindFirst() then begin
                                if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::A then begin
                                    if DT2Time(CurrentDateTime) < 170000T then
                                        L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today))
                                    else
                                        L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+4D>', Today))
                                end;
                                if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::E then begin
                                    if DT2Time(CurrentDateTime) < 190000T then
                                        L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today))
                                    else
                                        L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+4D>', Today))
                                end;
                            end;
                        end;
                    end
                    else begin
                        L_ShippingAgentService.Reset();
                        L_ShippingAgentService.SetRange("Shipping Agent Code", L_InterimSalesHeader."Shipping Agent Code");
                        L_ShippingAgentService.SetRange(Code, L_InterimSalesHeader."Shipping Agent Service Code");
                        if L_ShippingAgentService.FindFirst() then begin
                            if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::A then begin
                                if DT2Time(CurrentDateTime) < 170000T then
                                    L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today))
                                else
                                    L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+2D>', Today))
                            end;
                            if L_ShippingAgentService.Shift = L_ShippingAgentService.Shift::E then begin
                                if DT2Time(CurrentDateTime) < 190000T then
                                    L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+1D>', Today))
                                else
                                    L_InterimSalesHeader.Validate("Shipment Date", CalcDate('<+2D>', Today))
                            end;
                        end;
                    end;
                end;
            end;
        end;

        L_ShiptoAddress.Reset();
        L_ShiptoAddress.SetRange(Code, SellToCustomer."Ship-to Code");
        if L_ShiptoAddress.FindFirst() then begin
            L_InterimSalesHeader.Validate("Ship-to Code", L_ShiptoAddress.Code);
            L_InterimSalesHeader.VALIDATE("Ship-to Name", L_ShiptoAddress.Name);
            L_InterimSalesHeader.VALIDATE("Ship-to Address", L_ShiptoAddress.Address);
            L_InterimSalesHeader.VALIDATE("Ship-to Address 2", L_ShiptoAddress."Address 2");
            L_InterimSalesHeader.VALIDATE("Ship-to City", L_ShiptoAddress.City);
            L_InterimSalesHeader.VALIDATE("Ship-to County", L_ShiptoAddress.County);
            L_InterimSalesHeader.VALIDATE("Ship-to Country/Region Code", L_ShiptoAddress."Country/Region Code");
            L_InterimSalesHeader.VALIDATE("Ship-to Post Code", L_ShiptoAddress."Post Code");
            L_InterimSalesHeader.VALIDATE("Ship-to Phone", L_ShiptoAddress."Phone No.");
            L_InterimSalesHeader.VALIDATE("Ship-to Email", L_ShiptoAddress."E-Mail");
            L_InterimSalesHeader."Customer Posting Group" := SellToCustomer."Customer Posting Group";
        end else begin
            L_InterimSalesHeader.VALIDATE("Ship-to Name", SellToCustomer.Name);
            L_InterimSalesHeader.VALIDATE("Ship-to Address", SellToCustomer.Address);
            L_InterimSalesHeader.VALIDATE("Ship-to Address 2", SellToCustomer."Address 2");
            L_InterimSalesHeader.VALIDATE("Ship-to City", SellToCustomer.City);
            L_InterimSalesHeader.VALIDATE("Ship-to County", SellToCustomer.County);
            L_InterimSalesHeader.VALIDATE("Ship-to Country/Region Code", SellToCustomer."Country/Region Code");
            L_InterimSalesHeader.VALIDATE("Ship-to Post Code", SellToCustomer."Post Code");
            L_InterimSalesHeader.VALIDATE("Ship-to Phone", SellToCustomer."Phone No.");
            L_InterimSalesHeader.VALIDATE("Ship-to Email", SellToCustomer."E-Mail");
            L_InterimSalesHeader."Customer Posting Group" := SellToCustomer."Customer Posting Group";
        end;
        L_InterimSalesHeader."Customer Price Group" := SellToCustomer."Customer Price Group";

        BillToCustomer.Reset();
        BillToCustomer.SetRange("No.", SellToCustomer."Bill-to Customer No.");
        if BillToCustomer.FindFirst() then begin
            L_InterimSalesHeader."Bill-to Customer No." := BillToCustomer."No.";
            L_InterimSalesHeader."Bill- to Name" := BillToCustomer.Name;
            L_InterimSalesHeader."Bill-to County" := P_InterimSalesHeader."Bill-to County";
            L_InterimSalesHeader."Bill-to County" := BillToCustomer.County;
        end;

        L_InterimSalesHeader."Web Shipment Method" := P_InterimSalesHeader."Web Shipment Method";
        L_InterimSalesHeader."Payment Method" := P_InterimSalesHeader."Payment Method";
        L_InterimSalesHeader."Currency Code" := P_InterimSalesHeader."Currency Code";
        L_InterimSalesHeader.Validate("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
        L_InterimSalesHeader."Order Placed At" := CurrentDateTime;
        L_InterimSalesHeader."Order Created On" := CurrentDateTime;
        L_InterimSalesHeader."User ID" := UserId;
        L_InterimSalesHeader."File Name" := P_InterimSalesHeader."File Name";
        L_InterimSalesHeader."External Document No." := P_InterimSalesHeader."External Document No.";
        L_InterimSalesHeader.Validate("Order Amount", P_InterimSalesHeader."Order Amount");
        L_InterimSalesHeader.Validate("Order Discount Amount", P_InterimSalesHeader."Order Discount Amount");
        L_InterimSalesHeader.Insert(True);

        //Insert Line++
        If P_InterimSalesLine.FindSet() then begin
            repeat
                InsertSalesLine(L_InterimSalesHeader, P_InterimSalesLine, ChannelPartner, Discountperscent);
            until P_InterimSalesLine.Next() = 0;
        end;

        //Code to Validate order
        Sigma_OrderValidations(L_InterimSalesHeader);
    End;

    procedure CreateWebOrder(var P_InterimSalesHeader: Record "Interim Sales Header" temporary; var P_InterimSalesLine: Record "Interim Sales Line" temporary; P_ShipmentTracking: Record "Shipment Tracking" temporary; var P_PaymentDetail: Record "Channel Media" temporary)
    //Code to create a web Order and Line based on the data coming from diffrent channel integration code unit
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit "No. Series";
        SellToCustomer: Record Customer;
        ChannelPartner: Record "Trade Partner";
        ChannelItemList: Record "Channel Item Listing";
        IsExist: Boolean;
        Discountperscent: Decimal;
        salesLine: record "Sales Line";
        Query_OrderAmt: Query "Get Order item Amount";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Item: Record Item;
        CountriesRegion: Record "Country/Region";
        L_PaymentDetails: Record "Channel Media";
        ShipmentTracking: Record "Shipment Tracking";
        Regex: Codeunit Regex;
    Begin
        If CheckOrderNotExist(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Channel Order ID") then begin

            ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
            GeneralSetup.Get;
            GeneralSetup.TestField("Web Order Nos");

            L_InterimSalesHeader.INIT;
            L_InterimSalesHeader."Document Type" := L_InterimSalesHeader."Document Type"::Order;
            L_InterimSalesHeader."No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
            L_InterimSalesHeader.VALIDATE(Status, L_InterimSalesHeader.Status::Accepted);
            L_InterimSalesHeader.Validate("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
            L_InterimSalesHeader.validate("Document Date", P_InterimSalesHeader."Document Date");
            L_InterimSalesHeader.Validate("Order Date", WorkDate);

            if (P_InterimSalesHeader."Sell-to Customer No." <> '') then begin
                Case ChannelPartner."Customer Mapping" OF
                    ChannelPartner."Customer Mapping"::"Default Customer":
                        SellToCustomer.GET(ChannelPartner."Customer No.");
                    ChannelPartner."Customer Mapping"::"Order Customer":
                        SellToCustomer.GET(P_InterimSalesHeader."Sell-to Customer No.");
                End;
                L_InterimSalesHeader.VALIDATE("Sell-to Customer No.", SellToCustomer."No.");
                if P_InterimSalesHeader."Trade Partner Code" = 'B&Q' then begin
                    L_InterimSalesHeader.VALIDATE(Address, P_InterimSalesHeader.Address);
                    L_InterimSalesHeader.VALIDATE("Address 2", P_InterimSalesHeader."Address 2");
                    L_InterimSalesHeader.VALIDATE(City, P_InterimSalesHeader.City);
                    L_InterimSalesHeader.VALIDATE("Post Code", P_InterimSalesHeader."Post Code");
                    L_InterimSalesHeader.VALIDATE("Sell to Country", P_InterimSalesHeader."Bill-to County");
                end else begin
                    L_InterimSalesHeader.VALIDATE(Address, SellToCustomer.Address);
                    L_InterimSalesHeader.VALIDATE("Address 2", SellToCustomer."Address 2");
                    L_InterimSalesHeader.VALIDATE(City, SellToCustomer.City);
                    L_InterimSalesHeader.VALIDATE("Post Code", SellToCustomer."Post Code");
                    L_InterimSalesHeader.VALIDATE("Sell to Country", SellToCustomer."Country/Region Code");
                end;

                //L_InterimSalesHeader.Validate("Sell to County", SellToCustomer.County);
                if SellToCustomer."Location Code" <> '' then
                    L_InterimSalesHeader.validate("Location Code", SellToCustomer."Location Code")
                else
                    L_InterimSalesHeader.Validate("Location Code", ChannelPartner.Location);
                L_InterimSalesHeader.Validate("MultiLine Order No.", P_InterimSalesHeader."MultiLine Order No.");
            end;


            L_InterimSalesHeader.VALIDATE("Ship-to Name", P_InterimSalesHeader."Ship-to Name");
            L_InterimSalesHeader.VALIDATE("Ship-to Address", P_InterimSalesHeader."Ship-to Address");
            L_InterimSalesHeader.VALIDATE("Ship-to Address 2", P_InterimSalesHeader."Ship-to Address 2");
            L_InterimSalesHeader.VALIDATE("Ship to Address 3", P_InterimSalesHeader."Ship to Address 3");
            L_InterimSalesHeader.VALIDATE("Ship-to City", P_InterimSalesHeader."Ship-to City");
            L_InterimSalesHeader.VALIDATE("Ship-to County", P_InterimSalesHeader."Ship-to County");
            L_InterimSalesHeader.VALIDATE("Ship-to Country/Region Code", P_InterimSalesHeader."Ship-to Country/Region Code");
            L_InterimSalesHeader.VALIDATE("Ship-to Post Code", P_InterimSalesHeader."Ship-to Post Code");
            IF L_InterimSalesHeader."Ship-to Country/Region Code" = '' THEN
                L_InterimSalesHeader.VALIDATE("Ship-to Country/Region Code", SellToCustomer."Country/Region Code");

            if P_InterimSalesHeader."Ship-to Phone" <> '' then begin
                L_InterimSalesHeader.VALIDATE("Ship-to Phone", Regex.Replace(P_InterimSalesHeader."Ship-to Phone", '[^0-9+]', ''));
                //L_InterimSalesHeader.VALIDATE("Ship-to Phone", P_InterimSalesHeader."Ship-to Phone");
            end
            else begin
                L_InterimSalesHeader.Validate("Ship-to Phone", '00000000000');  //US-12629
            end;

            L_InterimSalesHeader.VALIDATE("Ship-to Email", P_InterimSalesHeader."Ship-to Email");

            //8862++
            if P_InterimSalesHeader."Ship-to Country/Region Code" <> '' then begin
                if P_InterimSalesHeader."Ship-to Country/Region Code" = 'GB' then begin
                    L_InterimSalesHeader."Customer Posting Group" := 'DOMESTIC';
                end
                else begin
                    if CountriesRegion.Get(P_InterimSalesHeader."Ship-to Country/Region Code") then begin
                        if CountriesRegion."EU Country/Region Code" <> '' then begin
                            L_InterimSalesHeader."Customer Posting Group" := 'EU';
                        end
                        else begin
                            L_InterimSalesHeader."Customer Posting Group" := 'FOREIGN';
                        end;
                    end;
                end;
            end;
            //8862--

            L_InterimSalesHeader."Bill-to Customer No." := P_InterimSalesHeader."Bill-to Customer No.";
            L_InterimSalesHeader."Bill- to Name" := P_InterimSalesHeader."Bill- to Name";
            L_InterimSalesHeader."Bill-to CompanyName" := P_InterimSalesHeader."Bill-to CompanyName";
            L_InterimSalesHeader."Bill-to County" := P_InterimSalesHeader."Bill-to County";


            L_InterimSalesHeader."Job Reference" := P_InterimSalesHeader."Job Reference";
            L_InterimSalesHeader."Package Tracking No." := P_InterimSalesHeader."Package Tracking No.";
            L_InterimSalesHeader."Web Shipping Agent" := P_InterimSalesHeader."Web Shipping Agent";
            L_InterimSalesHeader."Web Shipment Method" := P_InterimSalesHeader."Web Shipment Method";

            L_InterimSalesHeader."Shipment Method Code" := P_InterimSalesHeader."Shipment Method Code";
            L_InterimSalesHeader."Shipping Agent Code" := P_InterimSalesHeader."Shipping Agent Code";
            L_InterimSalesHeader."Shipping Agent Service Code" := P_InterimSalesHeader."Shipping Agent Service Code";
            L_InterimSalesHeader."Payment Method" := P_InterimSalesHeader."Payment Method";  //Added By Shubham 05082022
            L_InterimSalesHeader."Currency Code" := P_InterimSalesHeader."Currency Code";

            L_InterimSalesHeader.VALIDATE("Buyer Email", P_InterimSalesHeader."Buyer Email");
            L_InterimSalesHeader."Buyer Name" := P_InterimSalesHeader."Buyer Name";
            L_InterimSalesHeader.VALIDATE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
            L_InterimSalesHeader.VALIDATE("No. Of Parcels", P_InterimSalesHeader."No. Of Parcels");
            L_InterimSalesHeader."Earliest Delivery date" := P_InterimSalesHeader."Earliest Delivery date";
            L_InterimSalesHeader."Promised Delivery Date" := P_InterimSalesHeader."Promised Delivery Date";
            L_InterimSalesHeader."Order Placed At" := P_InterimSalesHeader."Order Placed At";
            L_InterimSalesHeader."Order Created On" := CurrentDateTime;
            L_InterimSalesHeader."User ID" := UserId;
            L_InterimSalesHeader."File Name" := P_InterimSalesHeader."File Name";
            L_InterimSalesHeader."External Document No." := P_InterimSalesHeader."External Document No."; //Added By Shubham 06052021
            L_InterimSalesHeader.Validate("Order Amount", P_InterimSalesHeader."Order Amount");  //Added By Shubham 19072021
            L_InterimSalesHeader.Validate("Order Discount Amount", P_InterimSalesHeader."Order Discount Amount");
            L_InterimSalesHeader.Validate("Shipment Date", P_InterimSalesHeader."Shipment Date");
            L_InterimSalesHeader.Validate("Fullfillment Channel", P_InterimSalesHeader."Fullfillment Channel");
            L_InterimSalesHeader.Validate("Web Customer No.", P_InterimSalesHeader."Web Customer No.");
            L_InterimSalesHeader.Validate("Order Status", P_InterimSalesHeader."Order Status");
            L_InterimSalesHeader.Validate(order_id, P_InterimSalesHeader.order_id);
            L_InterimSalesHeader.Insert(True);
            If P_InterimSalesLine.FindFirst() then
                repeat
                    if P_InterimSalesLine."Gift Card" = false then
                        InsertSalesLine(L_InterimSalesHeader, P_InterimSalesLine, ChannelPartner, Discountperscent)
                    else
                        InsertGiftGlLine(P_InterimSalesLine, L_InterimSalesHeader);
                //Paarth D Dave - 8197 - 070922 - Commented here and called in OrderValidations Procedure  
                //CreateAssemblyOrderForCushionItems(L_InterimSalesHeader, P_InterimSalesLine);//Sofyan
                until P_InterimSalesLine.Next() = 0;




            CreateGLLines(L_InterimSalesHeader);


            DeleteRefundPaymentDetails(P_PaymentDetail);
            P_PaymentDetail.Reset();
            if P_PaymentDetail.FindSet() then begin
                repeat
                    IsExist := CheckPaymentDetailsExist(P_PaymentDetail);
                    if IsExist = false then begin
                        InsertInPaymentDetails(L_InterimSalesHeader, P_PaymentDetail);
                    end;
                until P_PaymentDetail.Next() = 0;
            end;

            //Shubham Calculate Total Weight for InterimSalesHeader
            L_InterimSalesHeader."Total Weight" := CalculateWeight(L_InterimSalesHeader);
            L_InterimSalesHeader."No. of Items" := calculateNoofItems(L_InterimSalesHeader);
            L_InterimSalesHeader."Total No. of Items" := CalculateTotalItems(L_InterimSalesHeader);
            //Code to Update Order Amount on Header Level
            if L_InterimSalesHeader."Order Amount" = 0 then begin
                G_InterimSalesLine.Reset();
                G_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
                G_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                if G_InterimSalesLine.FindSet() then begin
                    repeat
                        if G_InterimSalesLine."Amount Including VAT" > 0 then
                            L_InterimSalesHeader."Order Amount" := L_InterimSalesHeader."Order Amount" + G_InterimSalesLine."Amount Including VAT";
                    until G_InterimSalesLine.Next() = 0;
                end;
            end;

            L_PaymentDetails.Reset();
            L_PaymentDetails.SetRange("Channel Code", P_PaymentDetail."Channel Code");
            L_PaymentDetails.SetRange("Channel Order ID", P_PaymentDetail."Channel Order ID");
            //L_PaymentDetails.SetRange("Payment Method", P_PaymentDetail."Payment Method");  //Commented Bug 12050
            if L_PaymentDetails.Count > 1 then
                Clear(L_InterimSalesHeader."Payment Method");

            L_InterimSalesHeader."Gift Order Amount" := GetGiftOrderAmount(L_InterimSalesHeader);
            L_InterimSalesHeader."Gift Card" := G_GiftBool;





            L_InterimSalesHeader.Modify(true);

            //UpdateShippingAgentOnLines++
            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
            L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            if L_InterimSalesLine.FindSet() then
                repeat
                    L_InterimSalesLine."Shipping Agent Code" := L_InterimSalesHeader."Shipping Agent Code";//Sofyan
                    L_InterimSalesLine."Shipping Agent Service Code" := L_InterimSalesHeader."Shipping Agent Service Code";//Sofyan
                    L_InterimSalesLine.Modify(true);
                until L_InterimSalesLine.Next() = 0;
            //UpdateShippingAgentOnLines--

            //Code to Validate order
            Sigma_OrderValidations(L_InterimSalesHeader);

            OnAfterInsertInterimSalesHeader(L_InterimSalesHeader);  //Irshad 11052022
        end;
    End;

    local procedure InsertInPaymentDetails(var P_InterimSalesHeader: Record "Interim Sales Header"; var P_PaymentDetail: Record "Channel Media" temporary)
    var
        L_PaymentDetails: Record "Channel Media";
        L_InterimSalesLine: Record "Interim Sales Line";
        ChannelPartner: Record "Trade Partner";
    begin
        L_PaymentDetails.Init();
        L_PaymentDetails.Validate("Channel Code", P_PaymentDetail."Channel Code");
        L_PaymentDetails.Validate("Channel Order ID", P_PaymentDetail."Channel Order ID");
        L_PaymentDetails.Validate("Web Order No.", P_InterimSalesHeader."No.");
        L_PaymentDetails.Validate(Amount, P_PaymentDetail.Amount);
        L_PaymentDetails.Validate("Transaction ID", P_PaymentDetail."Transaction ID");
        L_PaymentDetails.Validate("Payment Method", P_PaymentDetail."Payment Method");
        L_PaymentDetails.Validate("Transaction Date", P_PaymentDetail."Transaction Date");
        L_PaymentDetails.Validate("Payment Status", P_PaymentDetail."Payment Status");
        L_PaymentDetails.Validate("Gift Card", P_PaymentDetail."Gift Card");
        L_PaymentDetails.Validate("Currency Code", P_InterimSalesHeader."Currency Code");
        L_PaymentDetails.Insert(true);

        // Insert negative GL line for Gift payment 
        if L_PaymentDetails."Gift Card" = true then begin
            ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
            L_InterimSalesLine.INIT;
            L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
            L_InterimSalesLine."Document No" := P_InterimSalesHeader."No.";
            L_InterimSalesLine."Line No." := FindLastLineNo(P_InterimSalesHeader);
            L_InterimSalesLine.Type := L_InterimSalesLine.Type::"G/L Account";
            L_InterimSalesLine.VALIDATE("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
            L_InterimSalesLine.VALIDATE("No.", ChannelPartner."GiftWrap G/L No.");
            L_InterimSalesLine.VALIDATE(Quantity, 1);
            L_InterimSalesLine.VALIDATE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
            L_InterimSalesLine.Validate("Unit Price", -L_PaymentDetails.Amount);
            L_InterimSalesLine.VALIDATE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
            L_InterimSalesLine.Validate("Gift Card", true);
            L_InterimSalesLine.INSERT(TRUE);
        end;
    end;

    local procedure CheckPaymentDetailsExist(var P_PaymentDetail: Record "Channel Media" temporary): Boolean
    var
        L_PaymentDetails: Record "Channel Media";
    begin
        L_PaymentDetails.Reset();
        L_PaymentDetails.SetRange("Channel Code", P_PaymentDetail."Channel Code");
        L_PaymentDetails.SetRange("Channel Order ID", P_PaymentDetail."Channel Order ID");
        L_PaymentDetails.SetRange("Payment Method", P_PaymentDetail."Payment Method");
        L_PaymentDetails.SetRange("Transaction ID", P_PaymentDetail."Transaction ID");
        if L_PaymentDetails.FindFirst() then begin
            exit(true);
        end
        else begin
            exit(false);
        end;
    end;

    procedure CalculateNoofItems(P_InterimSalesHeader: record "Interim Sales Header"): Integer
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.SetRange("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SetFilter("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Component);
        exit(L_InterimSalesLine.Count);
    end;

    procedure CalculateTotalItems(P_InterimSalesHeader: record "Interim Sales Header"): Integer
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        TotalItems: Integer;
    begin
        Clear(TotalItems);
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SetFilter("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Component);
        if L_InterimSalesLine.FindSet() then begin
            repeat
                if L_InterimSalesLine.Quantity > 0 then
                    TotalItems += L_InterimSalesLine.Quantity;
            until L_InterimSalesLine.Next() = 0;
        end;
        exit(TotalItems);
    end;

    procedure CalculateWeight(L_InterimSalesHeader: Record "Interim Sales Header"): Decimal
    var
        TotalWeight: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        Clear(TotalWeight);
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
        if L_InterimSalesLine.FindSet() then begin
            repeat
                TotalWeight := TotalWeight + (L_InterimSalesLine.Weight * L_InterimSalesLine.Quantity);
            until L_InterimSalesLine.Next() = 0;
        end;
        exit(TotalWeight);
    end;

    procedure FindLastLineNo(P_InterimSalesH: Record "Interim Sales Header"): Integer
    //Code to find a last line no in web order
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

    procedure FindItemNo(P_CrossRefNo: Code[20]; P_ASINNo: Code[50]; P_ChannelSKU: Text[50]; P_CustNo: Code[20]; P_ChannelPartner: Record "Trade Partner"): Code[20]
    //Code to Find a item no based on customer cross ref.
    var
        ItemReference: Record "Item Reference";
        ChannelItemList: Record "Channel Item Listing";
    begin
        IF P_ChannelPartner."Order Item By" IN [P_ChannelPartner."Order Item By"::ASIN, P_ChannelPartner."Order Item By"::"Channel SKU"] Then begin
            ChannelItemList.SetRange("Channel Code", P_ChannelPartner.Code);
            CASE P_ChannelPartner."Order Item By" OF
                P_ChannelPartner."Order Item By"::ASIN:
                    ChannelItemList.SetRange("ASIN No", P_ASINNo);
                P_ChannelPartner."Order Item By"::"Channel SKU":
                    ChannelItemList.SetRange("Channel SKU", P_ChannelSKU);
            End;
            IF ChannelItemList.FindFirst() Then
                EXIT(ChannelItemList."Item No.");

        End Else Begin
            if P_ChannelPartner."Inbox Type" = P_ChannelPartner."Inbox Type"::"File Location" then begin
                ItemReference.Reset();
                //ItemReference.SETRANGE("Reference Type", ItemReference."Reference Type"::"Bar Code");
                ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"PIP Code");
                ItemReference.SetRange("Reference No.", P_CrossRefNo);
                IF ItemReference.FindFirst() then
                    exit(ItemReference."Item No.");
            end else begin
                ItemReference.RESET;
                ItemReference.SETRANGE("Reference Type", ItemReference."Reference Type"::Customer);
                ItemReference.SETRANGE("Reference Type No.", P_CustNo);
                ItemReference.SETRANGE("Reference No.", P_CrossRefNo);
                IF ItemReference.FindFirst() then
                    exit(ItemReference."Item No.")
                else
                    exit(P_ChannelSKU);
            end;
        End;
    end;

    procedure FindUOM(P_CrossRefNo: Code[20]; P_ASINNo: Code[50]; P_ChannelSKU: Text[50]; P_ItemNo: Code[20]; P_CustNo: Code[20]; P_ChannelCode: Record "Trade Partner"): Code[20]
    //Code to get UOM 
    var
        L_ChannelItemList: Record "Channel Item Listing";
        ItemCrossReference: Record "Item Reference";
        L_Item: Record Item;
    begin
        IF P_ChannelCode."Order Item By" IN [P_ChannelCode."Order Item By"::ASIN, P_ChannelCode."Order Item By"::"Channel SKU"] Then begin
            L_ChannelItemList.SetRange("Channel Code", P_ChannelCode.Code);
            CASE P_ChannelCode."Order Item By" OF
                P_ChannelCode."Order Item By"::ASIN:
                    L_ChannelItemList.SetRange("ASIN No", P_ASINNo);
                P_ChannelCode."Order Item By"::"Channel SKU":
                    L_ChannelItemList.SetRange("Channel SKU", P_ChannelSKU);
            End;
            IF L_ChannelItemList.FindFirst() Then
                Exit(L_ChannelItemList."Unit of Measure code")
        End Else Begin
            ItemCrossReference.RESET;
            ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::Customer);
            ItemCrossReference.SETRANGE("Reference Type No.", P_CustNo);
            ItemCrossReference.SETRANGE("Reference No.", P_CrossRefNo);
            //  ItemCrossReference.SETRANGE("Block Customer Cross Reference", false);
            IF ItemCrossReference.FINDFIRST THEN
                EXIT(ItemCrossReference."Unit of Measure");
        End;

        If L_Item.Get(P_ItemNo) then
            exit(L_Item."Base Unit of Measure");

    end;

    procedure CreateGLLines(P_InterimSalesHeader: Record "Interim Sales Header")
    //Code to create GL lines if applicable
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_ShippingPrice: Decimal;
        L_shippingRule: Record "Shipping Rule";
        GeneralSetup: Record "General Setup - Channels";
        ChannelPartner: Record "Trade Partner";
    begin
        ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
        GeneralSetup.get;
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        If L_InterimSalesLine.FindSet() then begin
            L_InterimSalesLine.CalcSums("Shipping Price", "Amount Including VAT", "Gift Wrap Price");
            if L_InterimSalesLine."Shipping Price" > 0 then
                L_ShippingPrice := L_InterimSalesLine."Shipping Price";
        end;

        //Insert Shipping GL
        If L_ShippingPrice = 0 then begin
            L_shippingRule.RESET;
            L_shippingRule.SETRANGE("Channel Code", P_InterimSalesHeader."Trade Partner Code");
            L_shippingRule.SETRANGE("Web Shipping Agent", UPPERCASE(P_InterimSalesHeader."Web Shipment Method"));
            L_shippingRule.SETFILTER("Order Value", '<=%1', L_InterimSalesLine."Amount Including VAT");
            IF L_shippingRule.FINDLAST THEN
                L_ShippingPrice := L_shippingRule."Shipping Charge";
        end;

        //Insert Shipping GL
        If L_ShippingPrice > 0 then begin
            if ChannelPartner."Shipping G/L No." <> '' then begin
                InsertGLLines(P_InterimSalesHeader, ChannelPartner."Shipping G/L No.", L_ShippingPrice, 1);
            end
            else begin
                InsertGLLines(P_InterimSalesHeader, GeneralSetup."Shipping G/L No.", L_ShippingPrice, 1);
            end;
        end;

        // Insert Gift Wrap GL
        If L_InterimSalesLine."Gift Wrap Price" > 0 then begin
            if ChannelPartner."GiftWrap G/L No." <> '' then begin
                InsertGLLines(P_InterimSalesHeader, ChannelPartner."GiftWrap G/L No.", L_InterimSalesLine."Gift Wrap Price", 1);
            end
            else begin
                InsertGLLines(P_InterimSalesHeader, GeneralSetup."GiftWrap G/L No.", L_InterimSalesLine."Gift Wrap Price", 1);
            end;
        end;

    end;

    procedure InsertGLLines(P_InterimSalesHeader: Record "Interim Sales Header"; GLCode: Code[20]; ShippingCharge: Decimal; Qty: Decimal)
    //Code to insert GL lines.
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_InterimSalesLine1: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.INIT;
        L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
        L_InterimSalesLine."Document No" := P_InterimSalesHeader."No.";
        L_InterimSalesLine."Line No." := FindLastLineNo(P_InterimSalesHeader);
        L_InterimSalesLine.Type := L_InterimSalesLine.Type::"G/L Account";
        L_InterimSalesLine.VALIDATE("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine.VALIDATE("No.", GLCode);
        L_InterimSalesLine.VALIDATE(Quantity, Qty);
        L_InterimSalesLine.VALIDATE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesLine."Channel Price" := ShippingCharge;
        L_InterimSalesLine.Validate("Unit Price", ShippingCharge);
        L_InterimSalesLine.FileName := P_InterimSalesHeader."File Name";
        L_InterimSalesLine."Channel Order ID" := P_InterimSalesHeader."Channel Order ID";
        L_InterimSalesLine.VALIDATE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
        if P_InterimSalesHeader."Order Discount Amount" = L_InterimSalesLine."Unit Price" then begin
            L_InterimSalesLine."Discount %" := 100;
            L_InterimSalesLine1.Reset();
            L_InterimSalesLine1.SetRange("Document Type", L_InterimSalesLine."Document Type");
            L_InterimSalesLine1.SetRange("Document No", L_InterimSalesLine."Document No");
            L_InterimSalesLine1.SetRange(Type, L_InterimSalesLine1.Type::Item);
            L_InterimSalesLine1.SetFilter("Discount %", '>%1', 0);
            if L_InterimSalesLine1.FindSet() then
                L_InterimSalesLine1.ModifyAll("Discount %", 0, false);
        end;
        L_InterimSalesLine.INSERT(TRUE);
    end;

    procedure InsertSalesLine(P_InterimSalesHeader: Record "Interim Sales Header"; P_InterimSalesLine: Record "Interim Sales Line" temporary; P_ChannelPartner: Record "Trade Partner"; P_Discountper: Decimal)
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_ItemNo: Code[20];
        Rec_Item: Record Item;
        L_ItemVariant: Record "Item Variant";
        PriceListIntegration: Codeunit "Price List Integration";
        L_TradePartner: Record "Trade Partner";
    begin
        L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");

        L_InterimSalesLine.INIT;
        L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
        L_InterimSalesLine."Document No" := P_InterimSalesHeader."No.";
        L_InterimSalesLine."Order Date" := P_InterimSalesHeader."Order Date";
        L_InterimSalesLine.VALIDATE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesLine.Validate("ET Access Code", P_InterimSalesHeader."ET Access Code");
        L_InterimSalesLine.VALIDATE("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine."Line No." := FindLastLineNo(P_InterimSalesHeader);
        L_InterimSalesLine.Type := L_InterimSalesLine.Type::Item;
        L_InterimSalesLine.VALIDATE("Channel Identifier", P_InterimSalesLine."Channel Identifier");
        L_InterimSalesLine."Channel SKU" := P_InterimSalesLine."Channel SKU";
        L_InterimSalesLine."Channel Item Id" := P_InterimSalesLine."Channel Item Id";

        Clear(L_ItemNo);
        if L_TradePartner."Customer Trend Code" = false then begin
            L_ItemNo := FindItemNo(L_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU", L_InterimSalesLine."Sell-to Customer No.", P_ChannelPartner);
            L_InterimSalesLine.Validate("No.", L_ItemNo);
        end else
            L_InterimSalesLine.Validate("No.", L_InterimSalesLine."Channel SKU");

        L_InterimSalesLine.Validate("Customer Price Group", P_InterimSalesHeader."Customer Price Group");
        Rec_Item.Reset();
        if Rec_Item.Get(L_ItemNo) then begin
            L_InterimSalesLine.Description := Rec_Item.Description;
            L_InterimSalesLine."Item Category Code" := Rec_Item."Item Category Code";
        end;

        L_InterimSalesLine.Description2 := P_InterimSalesLine.Description2;
        L_InterimSalesLine."NAV Variant code" := GetNavVariantCode(P_InterimSalesLine."Channel SKU", P_ChannelPartner, P_InterimSalesLine."Channel Identifier", P_InterimSalesHeader."Sell-to Customer No."); //Commneted by Abdul for Performance issue (Not using Variant code on Web Order for Sigma)
        L_InterimSalesLine.Validate(Quantity, P_InterimSalesLine.Quantity);
        L_InterimSalesLine.Validate("Unit of Measure Code", FindUOM(L_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU", L_InterimSalesLine."No.", L_InterimSalesLine."Sell-to Customer No.", P_ChannelPartner)); //Commneted by Abdul for Performance issue ()

        if L_TradePartner."Customer Trend Code" = true then
            L_InterimSalesLine.Validate("Qty. to Deliver", P_InterimSalesLine.Quantity)
        else
            L_InterimSalesLine."Qty. to Deliver" := CalculateQtyToDeliver(L_InterimSalesLine);

        L_InterimSalesLine."Channel Price" := P_InterimSalesLine."Unit Price";
        case L_TradePartner."Price Pick From" of
            L_TradePartner."Price Pick From"::"Order Source":
                L_InterimSalesLine.Validate("Unit Price", P_InterimSalesLine."Unit Price");
            L_TradePartner."Price Pick From"::"channel Price":
                ItemLinePrice(L_InterimSalesLine, true);
            L_TradePartner."Price Pick From"::"Sales Price":
                PriceListIntegration.CalculateUnitPrice(P_InterimSalesHeader, L_InterimSalesLine);
        end;

        L_InterimSalesLine."Shipping Price" := P_InterimSalesLine."Shipping Price";
        L_InterimSalesLine."Gift Wrap Price" := P_InterimSalesLine."Gift Wrap Price";
        L_InterimSalesLine.Hazardous := P_InterimSalesLine.Hazardous;
        L_InterimSalesLine.FileName := P_InterimSalesLine.FileName;
        L_InterimSalesLine.Weight := P_InterimSalesLine.Weight;
        L_InterimSalesLine."Channel Order ID" := P_InterimSalesLine."Channel Order ID";
        L_InterimSalesLine."Currency Code" := P_InterimSalesLine."Currency Code";
        L_InterimSalesLine."Shipment Date" := P_InterimSalesHeader."Shipment Date";
        L_InterimSalesLine.Discount := P_InterimSalesLine.Discount;

        L_ItemVariant.Reset();
        L_ItemVariant.SetRange(Code, L_InterimSalesLine."NAV Variant code");
        L_ItemVariant.SetRange("Item No.", L_ItemNo);
        if L_ItemVariant.FindFirst() then
            L_InterimSalesLine.Validate(Description, L_ItemVariant.Description)
        else begin
            Rec_Item.Reset();
            Rec_Item.SetRange("No.", L_ItemNo);
            if Rec_Item.FindFirst() then
                L_InterimSalesLine.Validate(Description, Rec_Item.Description);
        end;

        L_InterimSalesLine.Insert(true);
    end;

    procedure GetNavVariantCode(ChannelSKU: Text[50]; P_ChannelPartner: Record "Trade Partner"; P_ASINNo: Code[50]; P_CustNo: Code[20]): Code[20]
    var
        ChannelItemListing: Record "Channel Item Listing";
        ItemCrossReference: Record "Item Reference";
    begin

        IF P_ChannelPartner."Order Item By" IN [P_ChannelPartner."Order Item By"::ASIN, P_ChannelPartner."Order Item By"::"Channel SKU"] Then begin
            ChannelItemListing.SetRange("Channel Code", P_ChannelPartner.Code);
            CASE P_ChannelPartner."Order Item By" OF
                P_ChannelPartner."Order Item By"::ASIN:
                    ChannelItemListing.SetRange("ASIN No", P_ASINNo);
                P_ChannelPartner."Order Item By"::"Channel SKU":
                    ChannelItemListing.SetRange("Channel SKU", ChannelSKU);
            End;
            IF ChannelItemListing.FindFirst() Then
                EXIT(ChannelItemListing."NAV Variant");

        End Else Begin
            ItemCrossReference.RESET;
            ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::Customer);
            ItemCrossReference.SETRANGE("Reference Type No.", P_CustNo);
            ItemCrossReference.SETRANGE("Reference No.", ChannelSKU);
            IF ItemCrossReference.FINDFIRST THEN
                EXIT(ItemCrossReference."Variant Code");

            // IF L_Item.GET(P_CrossRefNo) THEN
            //     EXIT(L_Item."No.");
        End;
    end;

    procedure ExplodeBoM(var P_InterimSalesLine: Record "Interim Sales Line")
    //Code to Explode BOM
    var
        L_TradePartner: Record "Trade Partner";
        KitItem: Record Item;
        CountRec: Integer;
        NoOfBOMComp: Decimal;
        TotalAmount: Decimal;
        LineSpacing: Integer;
        NextLineNo: Integer;
        FromBOMComp: Record "BOM Component";
        ToInterimSalesLine: Record "Interim Sales Line";
        ComponentAmount: Decimal;
        BoMItem: Record Item;
        IsHandled: Boolean;
    begin
        OnBeforeExplodeBoM(P_InterimSalesLine, IsHandled);
        if IsHandled then
            exit;

        OnAfterExplodeBoM(P_InterimSalesLine);
    end;

    procedure CheckOrderNotExist(P_ChannelCode: Code[20]; P_ChannelOrderId: Code[250]): Boolean
    //Code to check if channel order id already exists in interim sales header or Handled interim sales header 
    var
        L_InterimSalesH: Record "Interim Sales Header";
        L_HandeltedInterimSalesH: Record "Handled Interim Sales Header";
    begin
        L_InterimSalesH.Reset();
        L_InterimSalesH.SetRange("Trade Partner Code", P_ChannelCode);
        L_InterimSalesH.SetRange("Channel Order ID", P_ChannelOrderId);
        IF L_InterimSalesH.FindFirst() THEN BEGIN
            exit(FALSE);
        END;

        L_HandeltedInterimSalesH.Reset();
        L_HandeltedInterimSalesH.SetRange("Trade Partner Code", P_ChannelCode);
        L_HandeltedInterimSalesH.SetRange("Channel Order ID", P_ChannelOrderId);
        IF L_HandeltedInterimSalesH.FindFirst() THEN BEGIN
            exit(FALSE);
        END;

        exit(TRUE);
    end;

    procedure Sigma_OrderValidations(var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ErrorRecorded: Boolean;
        L_Cust: Record Customer;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Item: Record Item;
        L_TradePartner: Record "Trade Partner";
        TotalItems: Integer;
        L_Line: Record "Interim Sales Line";
        L_CheckItemLicense: Codeunit "Check Item License";
        L_AttributeCode: Code[20];
        L_CompanyLicenseError: Text[250];
        L_CustRef: Record "Customer Reference";
        LineCount: Integer;
        ErrorCount: Integer;
        L_ProductLevelResponse: Record "Product Level Response";
        L_OrderLevelResponse: Record "Order Level Response";
        Rec_InterimLine: Record "Interim Sales Line";
        Duplicate_InterimSalesLine: Record "Interim Sales Line";
        QuotaQuantity: Decimal;
        CU_SalesQuotaQtyValidation: Codeunit "Web Order Sales Quota New";
        ItemBlockedError: Text;
        L_RemainingQty: Decimal;
        L_BilltoCustomer: Code[20];
        L_CheckCreditLimit: Codeunit "Check Crdit/OverDue for IRP";
    begin
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN

            P_InterimSalesHeader.CalcFields("Sales Order Created");
            if P_InterimSalesHeader."Sales Order Created" = true then
                exit;

            L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");
            if L_TradePartner."Customer Trend Code" = true then
                exit;

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
                        Sigma_InsertErrorLog('Unauthorised Electronic Access - Contact Sigma', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ3', true, '');
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
                            Sigma_InsertErrorLog('Cross reference record locked', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ4', true, '');
                            L_ErrorRecorded := TRUE;
                        end;
                    end;
                end;
            end;

            //Response SEQ5++
            CLEAR(L_ErrorRecorded);
            if L_ErrorRecorded = false then begin
                IF P_InterimSalesHeader."Sell-to Customer No." = '' THEN BEGIN
                    Sigma_InsertErrorLog('Value for customer no must not be blank', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ5', true, '');
                    L_ErrorRecorded := TRUE;
                END;
            end;

            if L_ErrorRecorded = false then begin
                L_Cust.Reset();
                IF NOT L_Cust.GET(P_InterimSalesHeader."Sell-to Customer No.") THEN BEGIN
                    Sigma_InsertErrorLog('Customer not on file', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ5', true, '');
                    L_ErrorRecorded := TRUE;
                END;
            end;
            //Response SEQ5--

            //Response SEQ6++
            if L_ErrorRecorded = false then begin
                L_Cust.Reset();
                if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                    If (L_Cust.Blocked = L_Cust.Blocked::All) or (L_Cust.Status = L_Cust.Status::Open) or (L_Cust."QAU Approved" = false) then begin
                        Sigma_InsertErrorLog('Customer locked', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ6', true, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Response SEQ7++
            if L_ErrorRecorded = false then begin
                L_Cust.Reset();
                if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                    If L_Cust.Blocked = L_Cust.Blocked::Ship then begin
                        Sigma_InsertErrorLog('Customer on Stop **', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ7', true, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Response SEQ8++
            if L_ErrorRecorded = false then begin
                L_Cust.Reset();
                if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                    If L_Cust.Blocked = L_Cust.Blocked::Invoice then begin
                        Sigma_InsertErrorLog('Account on Payment Stop - Contact Sigma', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ8', true, '');
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
                //         Sigma_InsertErrorLog(STRSUBSTNO('Customer No %1 is Over Credit Limit***', P_InterimSalesHeader."Sell-to Customer No."), P_InterimSalesHeader, L_InterimSalesLine, 'SEQ9', true, '');
                //         L_ErrorRecorded := TRUE;
                //     end;
                // end;

                L_Cust.Reset();
                if L_Cust.Get(L_BilltoCustomer) then begin
                    if L_CheckCreditLimit.CheckCreditLimitAndOverDue(L_Cust."No.") = true then begin
                        Sigma_InsertErrorLog(STRSUBSTNO('Customer No %1 is Over Credit Limit***', P_InterimSalesHeader."Sell-to Customer No."), P_InterimSalesHeader, L_InterimSalesLine, 'SEQ9', true, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Response SEQ10++
            if L_ErrorRecorded = false then begin
                L_Cust.Reset();
                if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                    if L_Cust."Payment Terms Code" = '0D-COD' then begin
                        Sigma_InsertErrorLog('COD Account *********', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ10', true, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Response SEQ12++
            if L_ErrorRecorded = false then begin
                L_Cust.Reset();
                if L_Cust.Get(P_InterimSalesHeader."Sell-to Customer No.") then begin
                    If (L_Cust."Shipping Agent Code" = '') or (L_Cust."Shipping Agent Service Code" = '') then begin
                        Sigma_InsertErrorLog('Delivery Schedule not assigned, contact Sigma', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ12', true, '');
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            end;

            //Start Line Validations
            Clear(L_ErrorRecorded);
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
            IF L_InterimSalesLine.FINDSET THEN begin
                REPEAT
                    Clear(L_ErrorRecorded);

                    if L_InterimSalesLine."No." = '' then begin
                        L_InterimSalesLine.Validate("No.", FindItemNo(L_InterimSalesLine."Channel SKU", L_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU", L_InterimSalesLine."Sell-to Customer No.", L_TradePartner));
                        L_InterimSalesLine.Validate("Unit of Measure Code", FindUOM(L_InterimSalesLine."Channel SKU", L_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU"
                        , L_InterimSalesLine."No.", L_InterimSalesLine."Sell-to Customer No.", L_TradePartner));
                        if L_InterimSalesLine."No." <> '' then begin
                            L_Item.Reset();
                            if L_Item.Get(L_InterimSalesLine."No.") then begin
                                L_InterimSalesLine.Description := L_Item.Description;
                                L_InterimSalesLine."Item Category Code" := L_Item."Item Category Code";
                            end;
                        end;
                    end;

                    //Response SEQ3++
                    if L_ErrorRecorded = false then begin
                        Clear(ItemBlockedError);
                        if L_Item.Get(L_InterimSalesLine."No.") then begin
                            if (L_Item.Blocked = true) or (L_Item."Sales Blocked" = true) or (L_Item."Ops Sales Blocked" = true) or (L_Item.Status = L_Item.Status::Open) or (L_Item."QAU Approved" = false) then begin
                                ItemBlockedError := CheckItemBlockedError(L_Item);
                                Sigma_InsertErrorLog(ItemBlockedError, P_InterimSalesHeader, L_InterimSalesLine, 'SEQ3', false, '');
                                L_ErrorRecorded := TRUE;
                            end;
                        end;
                    end;

                    //Response SEQ4++
                    if L_ErrorRecorded = false then begin
                        if L_InterimSalesLine."No." = '' then begin
                            Sigma_InsertErrorLog('Value for Item no must not be blank', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ4', false, '');
                            L_ErrorRecorded := TRUE;
                        end;
                    end;

                    if L_ErrorRecorded = false then begin
                        if not L_Item.Get(L_InterimSalesLine."No.") then begin
                            Sigma_InsertErrorLog('Product does not exist', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ4', false, '');
                            L_ErrorRecorded := TRUE;
                        end
                    end;
                    //Response SEQ4--

                    //Response SEQ5 (Duplicate Line) need check++
                    if L_ErrorRecorded = false then begin
                        Duplicate_InterimSalesLine.Reset();
                        Duplicate_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type");
                        Duplicate_InterimSalesLine.SetRange("Document No", L_InterimSalesLine."Document No");
                        Duplicate_InterimSalesLine.SetRange("No.", L_InterimSalesLine."No.");
                        if Duplicate_InterimSalesLine.FindSet() then begin
                            if Duplicate_InterimSalesLine.Count > 1 then begin
                                Sigma_InsertErrorLog('Duplicate product ordered', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ5', false, '');
                                L_ErrorRecorded := TRUE;
                            end;
                        end;
                    end;

                    //Response SEQ7++
                    if L_ErrorRecorded = false then begin
                        if L_Item.Get(L_InterimSalesLine."No.") then begin
                            if L_Item."WebOrder Status" = L_Item."WebOrder Status"::DISCONTINUED then begin
                                Sigma_InsertErrorLog('Product Discontinued', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ7', false, '');
                                L_ErrorRecorded := TRUE;
                            end;
                        end;
                    end;

                    //Check Company License SEQ8++
                    if L_ErrorRecorded = false then begin
                        Clear(L_AttributeCode);
                        Clear(L_CompanyLicenseError);
                        L_CompanyLicenseError := L_CheckItemLicense.ForIntegration_ValidateLicense(0, P_InterimSalesHeader."Sell-to Customer No.", P_InterimSalesHeader."Customer Posting Group", P_InterimSalesHeader."Ship-to Country/Region Code", P_InterimSalesHeader."Order Date", L_InterimSalesLine."No.", P_InterimSalesHeader."Ship-to Post Code", L_AttributeCode);
                        if L_CompanyLicenseError <> '' then begin
                            Sigma_InsertErrorLog(L_CompanyLicenseError, P_InterimSalesHeader, L_InterimSalesLine, 'SEQ8', false, L_AttributeCode);
                            L_ErrorRecorded := TRUE;
                        end;
                    end;

                    //"Temperature Blocked" Response (Using it For Shipping Agent Service Item Restriction SEQ10++
                    if L_ErrorRecorded = false then begin
                        if L_Item.Get(L_InterimSalesLine."No.") then begin
                            if CheckShippingAgentServiceRestriction(L_InterimSalesLine."No.", P_InterimSalesHeader."Shipping Agent Code", P_InterimSalesHeader."Shipping Agent Service Code") then begin
                                Sigma_InsertErrorLog('Temperature blocked', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ10', false, '');
                                L_ErrorRecorded := TRUE;
                            end;
                        end;
                    end;

                    //Response SEQ9 and SEQ11++
                    if L_ErrorRecorded = false then begin
                        if L_Item.Get(L_InterimSalesLine."No.") then begin
                            if CalculateQtyToDeliver(L_InterimSalesLine) = 0 then begin
                                Sigma_InsertErrorLog('Product out of stock', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ9', false, '');
                                L_ErrorRecorded := TRUE;
                            end else begin
                                //SEQ11++
                                Clear(QuotaQuantity);
                                if CU_SalesQuotaQtyValidation.CheckExceededQty(L_InterimSalesLine, P_InterimSalesHeader, QuotaQuantity) <> CU_SalesQuotaQtyValidation.CheckExceededQty(L_InterimSalesLine, P_InterimSalesHeader, QuotaQuantity) ::"No Entry" then begin
                                    if QuotaQuantity < 0 then
                                        QuotaQuantity := 0;
                                    if QuotaQuantity > 0 then begin
                                        if L_InterimSalesLine."Qty. to Deliver" > QuotaQuantity then begin
                                            L_InterimSalesLine."Reason Code" := 'Partial Quantity Delivered';
                                            L_InterimSalesLine."Reason Message" := StrSubstNo('Quota is over %1 qty', L_InterimSalesLine.Quantity - QuotaQuantity);
                                            L_InterimSalesLine."Qty. to Deliver" := QuotaQuantity;
                                            L_InterimSalesLine.Modify();
                                        end;
                                    end else begin
                                        Sigma_InsertErrorLog('Product out of stock because of Quota', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ11', false, '');
                                        //L_ErrorRecorded := TRUE;

                                        //Update Line
                                        L_InterimSalesLine."Reason Code" := 'Partial Quantity Delivered';
                                        L_InterimSalesLine."Reason Message" := StrSubstNo('Quota is over %1 qty', L_InterimSalesLine.Quantity - QuotaQuantity);
                                        L_InterimSalesLine."Qty. to Deliver" := 0;
                                        L_InterimSalesLine.Modify();
                                    end;
                                end else begin
                                    if ((P_InterimSalesHeader."Trade Partner Code" = 'AVIBUYERS') OR (P_InterimSalesHeader."Trade Partner Code" = 'AVIBUYERNEW')) then begin
                                        if L_InterimSalesLine."Qty. to Deliver" <> 0 then
                                            if L_InterimSalesLine."Qty. to Deliver" < L_InterimSalesLine.Quantity then begin
                                                Sigma_InsertErrorLog('Partial Quantity Delivered', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ11', false, '');
                                                L_ErrorRecorded := TRUE;

                                                //Update Line
                                                L_InterimSalesLine."Reason Code" := 'Partial Quantity Delivered';
                                                L_InterimSalesLine."Reason Message" := 'Partial Quantity Delivered';
                                            end;
                                    end;
                                end;
                            end;
                        end;
                    end;

                    L_InterimSalesLine.Modify(true);
                UNTIL L_InterimSalesLine.NEXT = 0;
            end;

            //Response SEQ13++
            Clear(LineCount);
            L_Line.Reset();
            L_Line.SetRange("Document Type", P_InterimSalesHeader."Document Type");
            L_Line.SetRange("Document No", P_InterimSalesHeader."No.");
            L_Line.SetRange(Type, L_Line.Type::Item);
            if L_Line.FindSet() then
                LineCount := L_Line.Count;

            Clear(ErrorCount);
            L_Line.Reset();
            L_Line.SetRange("Document Type", P_InterimSalesHeader."Document Type");
            L_Line.SetRange("Document No", P_InterimSalesHeader."No.");
            L_Line.SetRange(Type, L_Line.Type::Item);
            L_Line.CalcFields("No of Error");
            L_Line.SetFilter("No of Error", '>%1', 0);
            if L_Line.FindSet() then
                ErrorCount := L_Line.Count;

            if LineCount = ErrorCount then begin
                Sigma_InsertErrorLog('All product lines rejected', P_InterimSalesHeader, L_InterimSalesLine, 'SEQ13', true, '');
            end;

            #Region Update Interim header and Interim Line Reason Code and Message++
            L_Line.Reset();
            L_Line.SetRange("Document Type", P_InterimSalesHeader."Document Type");
            L_Line.SetRange("Document No", P_InterimSalesHeader."No.");
            L_Line.SetFilter("Reason Code", '<>%1', UpperCase('Partial Quantity Delivered')); //For Partial Quantity managed at the time of Check error 
            if L_Line.FindSet() then begin
                repeat
                    PartnerErrorLog.RESET;
                    PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
                    PartnerErrorLog.SetFilter("Item No.", L_Line."No.");
                    PartnerErrorLog.SetCurrentKey("Sequence No.");
                    PartnerErrorLog.Ascending(true);
                    IF PartnerErrorLog.FindFirst() THEN begin
                        L_ProductLevelResponse.Reset();
                        L_ProductLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                        if L_ProductLevelResponse.FindFirst() then begin
                            L_Line."Reason Code" := L_ProductLevelResponse.Reason;
                            L_Line."Reason Message" := L_ProductLevelResponse.Message;
                            // if L_ProductLevelResponse."Error Code" = 'SEQ8' then begin
                            //     L_Line."Reason Code" := L_ProductLevelResponse.Reason;
                            //     L_Line."Reason Message" := PartnerErrorLog.Attribute + ' ' + L_ProductLevelResponse.Message;
                            // end else begin
                            //     L_Line."Reason Code" := L_ProductLevelResponse.Reason;
                            //     L_Line."Reason Message" := L_ProductLevelResponse.Message;
                            // end;
                            L_Line."Qty. to Deliver" := 0;
                        end;
                    end else begin
                        L_Line."Reason Code" := 'Order line created';
                        L_Line."Reason Message" := 'Successful';
                    end;
                    L_Line.Modify();
                until L_Line.Next() = 0;
            end;

            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
            PartnerErrorLog.SetFilter("Item No.", '%1', '');
            PartnerErrorLog.SetCurrentKey("Sequence No.");
            PartnerErrorLog.Ascending(true);
            IF PartnerErrorLog.FindFirst() THEN begin
                L_OrderLevelResponse.Reset();
                L_OrderLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                if L_OrderLevelResponse.FindFirst() then begin
                    P_InterimSalesHeader."Reason Code" := L_OrderLevelResponse.Reason;
                    P_InterimSalesHeader."Reason Message" := L_OrderLevelResponse.Message;
                    P_InterimSalesHeader.status := P_InterimSalesHeader.status::Rejected;
                end;
            end else begin
                P_InterimSalesHeader."Reason Code" := 'Order Created';
                P_InterimSalesHeader."Reason Message" := 'Accepted';

                Rec_InterimLine.Reset();
                Rec_InterimLine.SetRange("Document Type", P_InterimSalesHeader."Document Type");
                Rec_InterimLine.SetRange("Document No", P_InterimSalesHeader."No.");
                Rec_InterimLine.SetFilter("Reason Code", '%1|%2', 'Order line created', 'Partial Quantity Delivered');
                if Rec_InterimLine.FindFirst() then begin
                    P_InterimSalesHeader.status := P_InterimSalesHeader.status::Accepted;
                    P_InterimSalesHeader."Ready to process" := true;
                end else begin
                    P_InterimSalesHeader.status := P_InterimSalesHeader.status::Rejected;
                end;
            end;

            P_InterimSalesHeader."No. of Items" := CalculateNoofItems(P_InterimSalesHeader);
            P_InterimSalesHeader.Modify();
            #endregion
        end;
    end;

    procedure CalculateQtyToDeliver(var P_InterimSalesLine: Record "Interim Sales Line"): Decimal
    var
        PhysicalInventory: Decimal;
        L_ItemLedgerEntry: Record "Item Ledger Entry";
        L_SalesLine: Record "Sales Line";
        QtyOnSO: Decimal;
        Query_QtyonWebOrder: Query "Qty on Web";
        QtyonWebOrder: Decimal;
        AvailableInventory: Decimal;
        L_InterimSalesLine: Record "Interim Sales Line";
        L_BinContent: Record "Bin Content"; //Prathamesh++
        L_ExcludeQty: Decimal; //Prathamesh++
    begin
        #Region Physical Inventory from Item Ledger Entry
        Clear(PhysicalInventory);
        CLEAR(L_ItemLedgerEntry);
        L_ItemLedgerEntry.CalcFields("Daily Priority Exist");
        L_ItemLedgerEntry.SETRANGE("Item No.", P_InterimSalesLine."No.");
        L_ItemLedgerEntry.SETRANGE("Saleable Location", true);
        //L_ItemLedgerEntry.SETRANGE("Unit of Measure code", P_InterimSalesLine."Unit of Measure Code");
        L_ItemLedgerEntry.SetRange("Daily Priority Exist", GetVariantSetup(P_InterimSalesLine."No."));
        L_ItemLedgerEntry.SetRange(Open, true);
        if L_ItemLedgerEntry.FindSet() then begin
            L_ItemLedgerEntry.CalcSums("Remaining Quantity");
            PhysicalInventory := L_ItemLedgerEntry."Remaining Quantity";
        end;
        if PhysicalInventory < 0 then
            PhysicalInventory := 0;
        #endregion

        #Region Quantity Allocated on Sales Order
        Clear(QtyOnSO);
        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
        L_SalesLine.SETRANGE("No.", P_InterimSalesLine."No.");
        L_SalesLine.SETRANGE("Saleable Location", true);
        //L_SalesLine.SETRANGE("Unit of Measure Code", P_InterimSalesLine."Unit of Measure Code");
        L_SalesLine.SetFilter("Outstanding Qty. (Base)", '>0');
        L_SalesLine.SetFilter("Shipment Date", '>=%1', WorkDate());
        if L_SalesLine.FindSet() then begin
            L_SalesLine.CalcSums("Outstanding Qty. (Base)");
            QtyOnSO := L_SalesLine."Outstanding Qty. (Base)";
        end;
        if QtyOnSO < 0 then
            QtyOnSO := 0;
        #endregion

        #Region Quantity Allocated on Web Orders
        Clear(L_InterimSalesLine);
        Clear(QtyonWebOrder);
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("No.", P_InterimSalesLine."No.");
        L_InterimSalesLine.SetRange("Sales Order Created", false);
        L_InterimSalesLine.SetRange("Unit of Measure Code", P_InterimSalesLine."Unit of Measure Code");
        L_InterimSalesLine.SetFilter("Reason Code", '%1|%2', 'Order line created', 'PARTIAL QUANTITY DELIVERED');
        L_InterimSalesLine.SetFilter("Document No", '<>%1', P_InterimSalesLine."Document No");
        if L_InterimSalesLine.FindSet() then begin
            L_InterimSalesLine.CalcSums("Qty. to Deliver");
            QtyonWebOrder := L_InterimSalesLine."Qty. to Deliver";
        END;
        if QtyonWebOrder < 0 then
            QtyonWebOrder := 0;
        #endregion

        Clear(AvailableInventory);
        //AvailableInventory := PhysicalInventory - (QtyOnSO + QtyonWebOrder);
        if PhysicalInventory - (QtyOnSO + QtyonWebOrder) > 0 then
            AvailableInventory := Round(PhysicalInventory - (QtyOnSO + QtyonWebOrder), 1, '=');
        if AvailableInventory < 0 then
            AvailableInventory := 0;


        #Region Exclude Quantiy from Receive Bin.
        //Prathamesh++ SBB-291
        Clear(L_ExcludeQty);
        L_BinContent.Reset();
        L_BinContent.SetRange("Item No.", P_InterimSalesLine."No.");
        L_BinContent.SetRange("Saleable Location", true);
        L_BinContent.SetFilter("Quantity (Base)", '>%1', 0);
        L_BinContent.SetFilter("Exclude from free Qty.", '%1', true);
        L_BinContent.SetRange("Daily Priority Exist", GetVariantSetup(P_InterimSalesLine."No."));
        if L_BinContent.FindSet() then begin
            repeat
                L_BinContent.CalcFields("Quantity (Base)");
                L_ExcludeQty += L_BinContent."Quantity (Base)";
            until L_BinContent.Next() = 0;
        end;

        if L_ExcludeQty > 0 then
            AvailableInventory := AvailableInventory - L_ExcludeQty;
        //Prathamesh-- SBB-291
        #endregion

        if AvailableInventory > 0 then begin
            if AvailableInventory < P_InterimSalesLine.Quantity then begin
                exit(AvailableInventory);
            end
            else begin
                exit(P_InterimSalesLine.Quantity);
            end;
        end
        else
            exit(0);
    end;

    procedure OrderValidations(var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_ErrorRecorded: Boolean;
        L_Cust: Record Customer;
        L_ShippingRule: Record "Shipping Rule";
        L_InterimSalesLine: Record "Interim Sales Line";
        Item: Record Item;
        L_TradePartner: Record "Trade Partner";
        TotalItems: Integer;
        ShippingAgent: Record "Shipping Agent";
        Countries: Record "Country/Region";
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_HandledInterimSalesHeader: Record "Handled Interim Sales Header";
    begin
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN

            if P_InterimSalesHeader.status in [P_InterimSalesHeader.status::"SO Created"] then
                exit;

            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
            IF PartnerErrorLog.FindSet() THEN
                PartnerErrorLog.DeleteAll();

            CLEAR(L_ErrorRecorded);

            IF P_InterimSalesHeader."Sell-to Customer No." = '' THEN BEGIN
                InsertErrorLog('Value for customer no must not be blank', P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            END
            ELSE
                IF NOT L_Cust.GET(P_InterimSalesHeader."Sell-to Customer No.") THEN BEGIN
                    InsertErrorLog(STRSUBSTNO('Customer No %1 does not exist', P_InterimSalesHeader."Sell-to Customer No."), P_InterimSalesHeader);
                    L_ErrorRecorded := TRUE;
                END Else begin
                    If L_Cust.Blocked <> L_Cust.Blocked::" " then begin
                        InsertErrorLog(STRSUBSTNO('Customer No %1 is blocked', P_InterimSalesHeader."Sell-to Customer No."), P_InterimSalesHeader);
                        L_ErrorRecorded := TRUE;
                    end;
                end;

            //code to check shipping agent code  
            //ROBONGP
            if P_InterimSalesHeader."Location Code" = '' then begin
                InsertErrorLog('Location must not be blank', P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            end;

            //Code to Check if Order is Repeated or not in System, if Repeated Update Error Message
            L_HandledInterimSalesHeader.RESET;
            L_HandledInterimSalesHeader.SETRANGE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
            L_HandledInterimSalesHeader.SETRANGE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
            IF not L_HandledInterimSalesHeader.FindFirst() THEN BEGIN
                L_InterimSalesHeader.RESET;
                L_InterimSalesHeader.SETRANGE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
                L_InterimSalesHeader.SETRANGE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
                IF L_InterimSalesHeader.FindSet() THEN BEGIN
                    if L_InterimSalesHeader.Count > 1 then begin
                        InsertErrorLog('Order is Repeated For Order No - ' + P_InterimSalesHeader."Channel Order ID", P_InterimSalesHeader);
                        L_ErrorRecorded := TRUE;
                    end;
                end;
            END
            else begin
                InsertErrorLog('Order is Repeated For Order No - ' + P_InterimSalesHeader."Channel Order ID", P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            end;
            //Code to Check if Order is Repeated or not in System, if Repeated Update Error Message

            TotalItems := 0;
            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            if L_InterimSalesLine.FindSet() then begin
                repeat
                    if L_InterimSalesLine.Quantity > 0 then
                        TotalItems += L_InterimSalesLine.Quantity;
                until L_InterimSalesLine.Next() = 0;
            end;

            if L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code") then begin
                if L_TradePartner."Shipping Rule Validation" = L_TradePartner."Shipping Rule Validation"::Both then begin
                    IF (P_InterimSalesHeader."Shipping Agent Code" = '') THEN BEGIN
                        GetNavShippingAgentFromWebShipping(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Web Shipping Agent", P_InterimSalesHeader."Web Shipment Method", L_shippingRule);
                        P_InterimSalesHeader."Shipping Agent Code" := L_shippingRule."Shipping Agent";
                        IF P_InterimSalesHeader."Shipping Agent Code" = '' THEN BEGIN
                            InsertErrorLog('Shipping Agent code must not be blank', P_InterimSalesHeader);
                            L_ErrorRecorded := TRUE;
                        END;
                        // if P_InterimSalesHeader."Shipping Agent Code" = 'ROYALMAIL' then begin
                        //     P_InterimSalesHeader."Package Tracking No." := P_InterimSalesHeader."Channel Order ID";
                        // end;
                    end;
                    if (P_InterimSalesHeader."Shipping Agent Service Code" = '') THEN BEGIN
                        GetNavShippingAgentFromWebShipping(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Web Shipping Agent", P_InterimSalesHeader."Web Shipment Method", L_shippingRule);
                        P_InterimSalesHeader."Shipping Agent Service Code" := L_ShippingRule."Shipping Agent Service";
                        if P_InterimSalesHeader."Shipping Agent Service Code" = '' then begin
                            InsertErrorLog('Shipping Agent Service Code must not be blank', P_InterimSalesHeader);
                            L_ErrorRecorded := TRUE;
                        end;
                    END;

                    //If Available on Shipping Rule Child Id and Name Get map For Hermes US-8196++
                    //if ((P_InterimSalesHeader."Child Client ID" = '') or (P_InterimSalesHeader."Child Client Name" = '')) then begin
                    GetNavShippingAgentFromWebShipping(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Web Shipping Agent", P_InterimSalesHeader."Web Shipment Method", L_shippingRule);


                    //Calculating Number of Parcels For Shipment
                    if P_InterimSalesHeader."No. Of Parcels" = 0 then
                        P_InterimSalesHeader."No. Of Parcels" := GetNumberOfParcels(P_InterimSalesHeader."Shipping Agent Code", P_InterimSalesHeader."Shipping Agent Service Code", P_InterimSalesHeader."Total Weight");
                End;
                if L_TradePartner."Shipping Rule Validation" = L_TradePartner."Shipping Rule Validation"::"Shipping Agent" then begin
                    IF (P_InterimSalesHeader."Shipping Agent Code" = '') THEN BEGIN
                        GetNavShippingAgentFromWebShipping(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Web Shipping Agent", P_InterimSalesHeader."Web Shipment Method", L_shippingRule);
                        P_InterimSalesHeader."Shipping Agent Code" := L_shippingRule."Shipping Agent";
                        IF P_InterimSalesHeader."Shipping Agent Code" = '' THEN BEGIN
                            InsertErrorLog('Shipping Agent code must not be blank', P_InterimSalesHeader);
                            L_ErrorRecorded := TRUE;
                        END;
                        // if P_InterimSalesHeader."Shipping Agent Code" = 'ROYALMAIL' then begin
                        //     P_InterimSalesHeader."Package Tracking No." := P_InterimSalesHeader."Channel Order ID";
                        // end;
                    end;



                    //Calculating Number of Parcels For Shipment
                    if P_InterimSalesHeader."No. Of Parcels" = 0 then
                        P_InterimSalesHeader."No. Of Parcels" := GetNumberOfParcels(P_InterimSalesHeader."Shipping Agent Code", P_InterimSalesHeader."Shipping Agent Service Code", P_InterimSalesHeader."Total Weight");
                end;
            END;

            P_InterimSalesHeader."No. of Items" := calculateNoofItems(P_InterimSalesHeader);
            P_InterimSalesHeader."Total No. of Items" := CalculateTotalItems(P_InterimSalesHeader);

            //8862++
            if P_InterimSalesHeader."Ship-to Country/Region Code" = 'GB' then begin
                IF L_Cust.GET(P_InterimSalesHeader."Sell-to Customer No.") THEN;
                P_InterimSalesHeader."Customer Posting Group" := L_Cust."Customer Posting Group";
            end
            else begin
                if Countries.Get(P_InterimSalesHeader."Ship-to Country/Region Code") then begin
                    if Countries."EU Country/Region Code" <> '' then begin
                        P_InterimSalesHeader."Customer Posting Group" := 'EU';
                    end
                    else begin
                        P_InterimSalesHeader."Customer Posting Group" := 'FOREIGN';
                    end;
                end;
            end;

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
            IF L_InterimSalesLine.FINDSET then begin
                repeat
                    if P_InterimSalesHeader."Ship-to Country/Region Code" = 'GB' then begin
                        IF L_Cust.GET(P_InterimSalesHeader."Sell-to Customer No.") THEN;
                        L_InterimSalesLine.Validate("VAT Bus. Posting Group", L_Cust."VAT Bus. Posting Group");
                    end
                    else begin
                        if Countries.Get(P_InterimSalesHeader."Ship-to Country/Region Code") then begin
                            if Countries."EU Country/Region Code" <> '' then begin
                                L_InterimSalesLine.Validate("VAT Bus. Posting Group", 'EU');
                            end
                            else begin
                                L_InterimSalesLine.Validate("VAT Bus. Posting Group", 'EXPORT');
                            end;
                        end;
                    end;
                    L_InterimSalesLine.Modify(true);
                until L_InterimSalesLine.Next() = 0;
            end;

            P_InterimSalesHeader."Order Amount" := CalculateOrderAmount(P_InterimSalesHeader);
            //8862--


            if (TotalItems < P_InterimSalesHeader."No. Of Parcels") and (TotalItems > 0) then begin
                InsertErrorLog('Number of Parcels cannot be greater than Total no. of Items', P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            end;

            //ROBONGP
            //Start Line Validations

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
            IF L_InterimSalesLine.FINDSET THEN
                REPEAT
                    IF (L_InterimSalesLine.Quantity <= 0) AND (L_InterimSalesLine.Type = L_InterimSalesLine.Type::"G/L Account") THEN
                        InsertErrorLog(STRSUBSTNO('Quantity must be greater than zero'), P_InterimSalesHeader);

                    IF L_InterimSalesLine.Type = L_InterimSalesLine.Type::Item THEN BEGIN
                        IF L_InterimSalesLine."No." <> '' THEN BEGIN
                            ValidateItemSetup(L_InterimSalesLine, L_ErrorRecorded, P_InterimSalesHeader);
                        END
                        ELSE BEGIN
                            GetItemNo(L_InterimSalesLine, P_InterimSalesHeader, L_ErrorRecorded);
                        END;
                    END;

                    IF L_InterimSalesLine.Type in [L_InterimSalesLine.Type::Item, L_InterimSalesLine.Type::"G/L Account"] then begin
                        if (L_InterimSalesLine.Type = L_InterimSalesLine.Type::"G/L Account") and (L_InterimSalesLine."VAT Prod. Posting Group" = '') then
                            L_InterimSalesLine.CalculateVatAmount(L_InterimSalesLine);

                        if L_InterimSalesLine."VAT Prod. Posting Group" = '' then
                            InsertErrorLog(STRSUBSTNO('VAT Prod. Posting Group must not be blank'), P_InterimSalesHeader);

                    end;
                UNTIL L_InterimSalesLine.NEXT = 0;


            If L_ErrorRecorded then begin
                P_InterimSalesHeader.status := P_InterimSalesHeader.status::Rejected;
                P_InterimSalesHeader."Total Weight" := CalculateWeight(P_InterimSalesHeader);

                // P_InterimSalesHeader.Modify();
            end Else begin
                P_InterimSalesHeader.status := P_InterimSalesHeader.status::Accepted;
                P_InterimSalesHeader."Total Weight" := CalculateWeight(P_InterimSalesHeader);

                //P_InterimSalesHeader.Modify();
            end;

            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            L_InterimSalesLine.SetRange(Reserved, false);
            IF not L_InterimSalesLine.FindFirst() THEN begin
                P_InterimSalesHeader.ReservedFlag := true;
            end;

            P_InterimSalesHeader.Modify();

        end;
    end;

    local procedure CalculateOrderAmount(var P_InterimSalesHeader: Record "Interim Sales Header"): Decimal
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        TotalAmount: Decimal;
    begin
        Clear(TotalAmount);
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetFilter("Document No", P_InterimSalesHeader."No.");
        if L_InterimSalesLine.FindSet() then begin
            repeat
                if L_InterimSalesLine."Unit Price" > 0 then
                    TotalAmount += (L_InterimSalesLine.Quantity * L_InterimSalesLine."Unit Price") + L_InterimSalesLine."VAT amount";
            until L_InterimSalesLine.Next() = 0;
        end;
        exit(TotalAmount);
    end;

    procedure InsertErrorLog(P_Text: Text; VAR P_InterimSalesHeader: Record "Interim Sales Header")
    var
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_OrderLevelResponse: Record "Order Level Response";
    begin

        PartnerErrorLog.INIT;
        PartnerErrorLog."Document No." := P_InterimSalesHeader."No.";
        PartnerErrorLog.Date := WORKDATE;

        L_PartnerErrorLog.RESET;
        L_PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
        IF L_PartnerErrorLog.FINDLAST THEN
            PartnerErrorLog."Line No." := L_PartnerErrorLog."Line No." + 10000
        ELSE
            PartnerErrorLog."Line No." := 10000;

        PartnerErrorLog."Error Text" := CopyStr(P_Text, 1, 250);
        PartnerErrorLog.INSERT;
        if P_InterimSalesHeader.status <> P_InterimSalesHeader.status::Rejected then begin
            P_InterimSalesHeader.Status := P_InterimSalesHeader.Status::Rejected;
            P_InterimSalesHeader.MODIFY;
        end;
    end;

    procedure Sigma_InsertErrorLog(P_Text: Text; VAR P_InterimSalesHeader: Record "Interim Sales Header"; P_InterimSalesLine: Record "Interim Sales line"; _ErrorCode: Code[20]; P_Header: Boolean; _AttributeCode: Code[20]);
    var
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_OrderLevelResponse: Record "Order Level Response";
        L_ProductLevelResponse: Record "Product Level Response";
    begin
        PartnerErrorLog.INIT;
        PartnerErrorLog."Document No." := P_InterimSalesHeader."No.";
        PartnerErrorLog.Date := WORKDATE;

        PartnerErrorLog."Error Code" := _ErrorCode;
        if P_Header = false then begin
            If P_InterimSalesLine."No." <> '' then begin
                PartnerErrorLog."Item No." := P_InterimSalesLine."No.";
            end
            else begin
                PartnerErrorLog."Item No." := CopyStr(P_InterimSalesLine."Channel SKU", 1, 20);
            end;
            PartnerErrorLog."PIP Code" := CopyStr(P_InterimSalesLine."Channel SKU", 1, 20);
            PartnerErrorLog.Attribute := _AttributeCode;
            L_ProductLevelResponse.Reset();
            L_ProductLevelResponse.SetRange("Error Code", _ErrorCode);
            if L_ProductLevelResponse.FindFirst() then begin
                PartnerErrorLog."Sequence No." := L_ProductLevelResponse."Entry No.";
            end;
        end else begin
            L_OrderLevelResponse.Reset();
            L_OrderLevelResponse.SetRange("Error Code", _ErrorCode);
            if L_OrderLevelResponse.FindFirst() then begin
                PartnerErrorLog."Sequence No." := L_OrderLevelResponse."Entry No.";
            end;
        end;

        L_PartnerErrorLog.RESET;
        L_PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
        IF L_PartnerErrorLog.FINDLAST THEN
            PartnerErrorLog."Line No." := L_PartnerErrorLog."Line No." + 10000
        ELSE
            PartnerErrorLog."Line No." := 10000;
        PartnerErrorLog."Error Text" := CopyStr(P_Text, 1, 250);
        PartnerErrorLog.INSERT;
        // if P_InterimSalesHeader.status <> P_InterimSalesHeader.status::Confirmed then begin
        //     P_InterimSalesHeader.Status := P_InterimSalesHeader.Status::Confirmed;
        //     P_InterimSalesHeader.MODIFY;
        // end;
    end;

    //Code to Calculate number Of Parcels Required For Shipment Based on Shipping Rule Specific Weight
    local procedure GetNumberOfParcels(ShippingAgentCode: Code[10]; ShippingAgentServiceCode: Code[250]; TotalWeight: Decimal): Integer
    var
        ShippingRule: Record "Shipping Rule";
        NumberofParcels: Integer;
    begin
        if ((ShippingAgentCode <> '') and (ShippingAgentServiceCode <> '')) then begin
            Clear(NumberofParcels);
            NumberofParcels := 0;
            if TotalWeight <> 0 then begin
                ShippingRule.Reset();
                ShippingRule.SetRange("Shipping Agent", ShippingAgentCode);
                ShippingRule.SetRange("Shipping Agent Service", ShippingAgentServiceCode);
                if ShippingRule.FindFirst() then begin
                    if ShippingRule.Weight <> 0 then
                        NumberofParcels := Round(TotalWeight / ShippingRule.Weight, 1, '>');
                end else
                    NumberofParcels := 1;
            end
            else begin
                NumberofParcels := 1;
            end;
        end else
            NumberofParcels := 1;
        exit(NumberofParcels);
    end;

    Procedure GetNavShippingAgentFromWebShipping(P_ChannelCode: Code[20]; P_WebShippingAgent: Text[50]; P_WebSipmentMethod: Code[50]; VAR P_ShippingRule: Record "Shipping Rule")
    begin
        P_ShippingRule.RESET;
        P_ShippingRule.SETCURRENTKEY("Channel Code", "Web Shipping Agent", "Web Shipment Method", Preference);
        P_ShippingRule.SETRANGE("Channel Code", P_ChannelCode);
        IF P_WebShippingAgent <> '' THEN
            P_ShippingRule.SETRANGE("Web Shipping Agent", P_WebShippingAgent);
        IF P_WebSipmentMethod <> '' THEN
            P_ShippingRule.SETRANGE("Web Shipment Method", P_WebSipmentMethod);
        IF P_ShippingRule.FINDFIRST THEN;
    end;

    procedure ValidateItemSetup(var P_InterimSalesLine: Record "Interim Sales Line"; var L_ErrorRecorded: Boolean; var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        ItemCrossRfef: Record "Item Reference";
        L_Item: Record Item;
        L_TradePartner: Record "Trade Partner";
        L_ItemVariant: Record "Item Variant";//Sofyan
        GeneralSetupChannel: Record "General Setup - Channels";
        AvailableInventory: Decimal;
        ItemQuery1: Query ItemQuery;
        BOMComponent: Record "BOM Component";
        LowestQuantity: Decimal;
        Counter: Integer;
        RequiredQuantity: Decimal;
        L_ItemCategory: Record "Item Category";
        Rec_Item: Record Item;
        L_WeightMeasure: Text;
    begin
        If L_Item.Get(P_InterimSalesLine."No.") then begin
            If L_Item.Blocked then begin
                InsertErrorLog(STRSUBSTNO('Item %1 is blocked.', P_InterimSalesLine."No."), P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            end;

            If L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code") then;

            IF P_InterimSalesLine."Unit of Measure Code" = '' then begin
                P_InterimSalesLine.Validate("Unit of Measure Code", FindUOM(P_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", P_InterimSalesLine."Channel SKU"
                        , P_InterimSalesLine."No.", P_InterimSalesLine."Sell-to Customer No.", L_TradePartner));
                IF P_InterimSalesLine."Unit of Measure Code" = '' then begin
                    InsertErrorLog(STRSUBSTNO('Unit of Measure is blank for %1.', P_InterimSalesLine."No."), P_InterimSalesHeader);
                    L_ErrorRecorded := TRUE;
                end;
            end;

            //code to get item variant
            if P_InterimSalesLine."NAV Variant code" = '' then begin
                P_InterimSalesLine.Validate("NAV Variant code", GetNavVariantCode(P_InterimSalesLine."Channel SKU", L_TradePartner, P_InterimSalesLine."Channel Identifier", P_InterimSalesHeader."Sell-to Customer No."));
            end;


            IF L_Item."Sales Unit of Measure" = '' THEN BEGIN
                InsertErrorLog(FORMAT('Unit Of Measure is not defined for SKU ' + P_InterimSalesLine."Channel SKU"), P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            END;

            IF L_Item."Gen. Prod. Posting Group" = '' THEN BEGIN
                InsertErrorLog(FORMAT('Gen. Prod. Posting Group cannot be blank for item ' + P_InterimSalesLine."Channel SKU"), P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            END;

            IF L_Item."Inventory Posting Group" = '' THEN BEGIN
                InsertErrorLog(FORMAT('Inventory Posting Group cannot be blank for item ' + P_InterimSalesLine."Channel SKU"), P_InterimSalesHeader);
                L_ErrorRecorded := TRUE;
            END;

            /* IF L_Item."VAT Prod. Posting Group" = '' THEN BEGIN
                 InsertErrorLog(FORMAT('VAT Prod. Posting Group cannot be blank for item ' + P_InterimSalesLine."Channel SKU"), P_InterimSalesHeader);
                 L_ErrorRecorded := TRUE;
             END;*///Commented by sofyan

            //code to check vat from item variant++
            if P_InterimSalesLine.Type = P_InterimSalesLine.Type::Item then begin
                if P_InterimSalesLine."VAT Prod. Posting Group" = '' then begin
                    /*L_ItemVariant.Reset();
                    L_ItemVariant.SetRange(Code, P_InterimSalesLine."NAV Variant code");
                    L_ItemVariant.SetRange("Item No.", P_InterimSalesLine."No.");
                    if L_ItemVariant.FindFirst() then begin
                        IF L_ItemVariant."VAT Prod Posting Group" = '' THEN BEGIN
                            InsertErrorLog(FORMAT('VAT Prod. Posting Group cannot be blank for item ' + P_InterimSalesLine."Channel SKU"), P_InterimSalesHeader);
                            L_ErrorRecorded := TRUE;
                        END;
                    end;*/
                    P_InterimSalesLine.CalculateVatAmount(P_InterimSalesLine);
                end;
            end;
            //code to check vat from item variant--


            IF P_InterimSalesLine.Weight = 0 THEN BEGIN
                if P_InterimSalesLine."Trade Partner Code" = 'B&Q' then begin
                    L_WeightMeasure := 'kg';
                    P_InterimSalesLine.Weight := GetWeightFromItemUoM(P_InterimSalesLine."No.", P_InterimSalesLine."Unit of Measure Code", L_WeightMeasure);
                end
                else begin
                    L_WeightMeasure := 'g';
                    P_InterimSalesLine.Weight := (GetWeightFromItemUoM(P_InterimSalesLine."No.", P_InterimSalesLine."Unit of Measure Code", L_WeightMeasure) * P_InterimSalesLine.Quantity);
                end;



                if P_InterimSalesLine.Weight = 0 then begin
                    InsertErrorLog(STRSUBSTNO('Weight is not defined on item unit of measure for %1.', P_InterimSalesLine."No."), P_InterimSalesHeader);
                    L_ErrorRecorded := TRUE;
                end;

                P_InterimSalesLine.MODIFY;
            END;

            if P_InterimSalesLine."Gift Wrap" = false then begin
                if Not P_InterimSalesLine."Price Authorised" then begin
                    IF P_InterimSalesLine.Amount = 0 THEN begin
                        ItemLinePrice(P_InterimSalesLine, false);
                        if P_InterimSalesLine."Unit Price" = 0 then Begin
                            InsertErrorLog(STRSUBSTNO('Unit Price is 0 for %1 ', P_InterimSalesLine.RecordId), P_InterimSalesHeader);
                            L_ErrorRecorded := TRUE;
                        End;
                    end;
                end;
            end;



            ItemCrossRfef.RESET;
            ItemCrossRfef.SETRANGE("Reference Type", ItemCrossRfef."Reference Type"::Customer);
            ItemCrossRfef.SETRANGE("Reference Type No.", P_InterimSalesHeader."Sell-to Customer No.");
            ItemCrossRfef.SETRANGE("Reference No.", P_InterimSalesLine."Channel SKU");
            // ItemCrossRfef.SETRANGE("Block Customer Cross Reference", TRUE);
            IF ItemCrossRfef.FINDFIRST THEN BEGIN

            END;
        end ELSE BEGIN
            InsertErrorLog(FORMAT('Item No does not exist ' + P_InterimSalesLine."No."), P_InterimSalesHeader);
            L_ErrorRecorded := TRUE;
        END;
    end;

    procedure GetItemNo(P_InterimSalesLine: Record "Interim Sales Line"; P_InterimSalesHeader: Record "Interim Sales Header"; var L_ErrorRecorded: Boolean)
    var
        L_TradePartner: Record "Trade Partner";
        L_ItemNo: Code[20];
        L_Item: Record Item;
        L_ItemVariantCode: Code[20];
        L_ItemVariant: Record "Item Variant";
        L_UnitofWeight: Text;
    begin
        If L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code") then;

        L_ItemNo := FindItemNo(P_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", P_InterimSalesLine."Channel SKU", P_InterimSalesLine."Sell-to Customer No.", L_TradePartner);
        L_ItemVariantCode := GetNavVariantCode(P_InterimSalesLine."Channel SKU", L_TradePartner, P_InterimSalesLine."Channel Identifier", P_InterimSalesHeader."Sell-to Customer No.");
        IF L_ItemNo = '' THEN BEGIN
            InsertErrorLog(FORMAT('Item not found for SKU ' + P_InterimSalesLine."Channel SKU"), P_InterimSalesHeader);
            L_ErrorRecorded := TRUE;
        END Else begin
            If L_Item.Get(L_ItemNo) then begin
                P_InterimSalesLine.Validate("No.", L_ItemNo);
                P_InterimSalesLine.Validate("NAV Variant code", L_ItemVariantCode);
                ValidateItemSetup(P_InterimSalesLine, L_ErrorRecorded, P_InterimSalesHeader);
                //khan++
                L_ItemVariant.Reset();
                L_ItemVariant.SetRange(Code, L_ItemVariantCode);
                L_ItemVariant.SetRange("Item No.", L_ItemNo);
                if L_ItemVariant.FindFirst() then
                    P_InterimSalesLine.Validate(Description, L_ItemVariant.Description)
                else begin
                    L_Item.Reset();
                    L_Item.SetRange("No.", L_ItemNo);
                    if L_Item.FindFirst() then
                        P_InterimSalesLine.Validate(Description, L_Item.Description);
                end;
                //khan--
            end;
            P_InterimSalesLine.Modify();
        end;
    end;

    procedure GetWeightFromItemUoM(P_ItemNo: Code[20]; P_UoM: Code[10]; P_WeightMeasure: text): Decimal
    var
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
    Begin
        L_ItemUnitofMeasure.RESET;
        L_ItemUnitofMeasure.SETRANGE("Item No.", P_ItemNo);
        L_ItemUnitofMeasure.SETRANGE(Code, P_UoM);
        IF L_ItemUnitofMeasure.FINDFIRST THEN begin
            if P_WeightMeasure = 'g' then
                EXIT(L_ItemUnitofMeasure.Weight / 1000);
            EXIT(L_ItemUnitofMeasure.Weight)
        end;
    End;

    procedure ItemLinePrice(VAR P_InterimSalesLine: Record "Interim Sales Line"; CalledFromInsert: Boolean)
    var
        L_TradePartner: Record "Trade Partner";
        L_ChannelItemListing: Record "Channel Item Listing";

    begin
        IF (P_InterimSalesLine.Amount = 0) AND (P_InterimSalesLine."No." <> '') THEN BEGIN
            IF L_TradePartner."Order Item By" IN [L_TradePartner."Order Item By"::ASIN, L_TradePartner."Order Item By"::"Channel SKU"] Then begin
                L_ChannelItemListing.Reset();
                L_ChannelItemListing.SetRange("Channel Code", L_TradePartner.Code);
                CASE L_TradePartner."Order Item By" OF
                    L_TradePartner."Order Item By"::ASIN:
                        L_ChannelItemListing.SetRange("ASIN No", P_InterimSalesLine."Channel Item Id");
                    L_TradePartner."Order Item By"::"Channel SKU":
                        L_ChannelItemListing.SetRange("Channel SKU", P_InterimSalesLine."Channel SKU");
                End;
                IF L_ChannelItemListing.FindFirst() Then begin
                    // if L_TradePartner."Use Channel List Price" then Begin
                    if L_TradePartner."Price Pick From" = L_TradePartner."Price Pick From"::"channel Price" then Begin
                        case L_TradePartner."Channel List Price" of
                            L_TradePartner."Channel List Price"::"Unit Price":
                                P_InterimSalesLine.Validate("Unit Price", L_ChannelItemListing."Unit Price");
                            L_TradePartner."Channel List Price"::"Special Price":
                                P_InterimSalesLine.Validate("Unit Price", L_ChannelItemListing."Special Price");
                        end;
                        If Not CalledFromInsert then
                            P_InterimSalesLine.Modify();
                    End;
                end;
            End;
        END;
    end;

    Procedure AuthoriseWebOrderPrice(VAR P_InterimSalesHeader: Record "Interim Sales Header")
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_UserSetup: Record "User Setup";
    Begin
        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
        IF L_InterimSalesLine.FINDSET THEN
            repeat
                IF L_UserSetup.GET(USERID) THEN;
                IF L_UserSetup."Allow to Auth. Web Order Price" THEN BEGIN
                    IF L_InterimSalesLine.FINDSET THEN
                        REPEAT
                            IF L_InterimSalesLine."Unit Price" = 0 THEN BEGIN
                                L_InterimSalesLine."Price Authorised" := TRUE;
                                L_InterimSalesLine.MODIFY;
                            END;
                        UNTIL L_InterimSalesLine.NEXT = 0;
                END ELSE
                    ERROR('You do not have permission to authorse price');
            Until L_InterimSalesLine.Next() = 0;
    End;

    procedure CopyOrder(VAR P_ISH: Record "Interim Sales Header")
    var
        L_TradePartner: Record "Trade Partner";
        L_DocNo: Code[20];
        RecInterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        InterimSalesLine: Record "Interim Sales Line";
    begin
        IF L_TradePartner.GET(P_ISH."Trade Partner Code") THEN;

        CLEAR(L_TradePartner);
        RecInterimSalesHeader.INIT;
        RecInterimSalesHeader.TRANSFERFIELDS(P_ISH);
        RecInterimSalesHeader."Document Type" := P_ISH."Document Type";
        IF STRPOS(P_ISH."No.", '-') = 0 THEN
            L_DocNo := P_ISH."No." + '-01'
        ELSE
            L_DocNo := INCSTR(P_ISH."No.");
        RecInterimSalesHeader."No." := L_DocNo;

        RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::Accepted;
        RecInterimSalesHeader."Pickup Date" := TODAY;
        RecInterimSalesHeader."Document Date" := TODAY;
        RecInterimSalesHeader."Channel Order ID" := P_ISH."Channel Order ID";
        RecInterimSalesHeader."External Document No." := P_ISH."External Document No." + 'R';
        CLEAR(RecInterimSalesHeader."Scanned By");
        CLEAR(RecInterimSalesHeader."Destination Doc No.");
        CLEAR(RecInterimSalesHeader."Destination Doc Type");
        CLEAR(RecInterimSalesHeader."Scanned Date");
        CLEAR(RecInterimSalesHeader."Moved In Handled");
        CLEAR(RecInterimSalesHeader.Remarks);
        Clear(RecInterimSalesHeader."Package Tracking No.");
        if RecInterimSalesHeader.INSERT(TRUE) then
            Message('Re-order successfully');

        L_InterimSalesHeader.RESET;
        L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.SETRANGE("No.", L_DocNo);
        IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
            L_InterimSalesLine.RESET;
            L_InterimSalesLine.SETRANGE("Document Type", P_ISH."Document Type");
            L_InterimSalesLine.SETRANGE("Document No", P_ISH."No.");
            IF L_InterimSalesLine.FINDSET THEN
                REPEAT
                    InterimSalesLine.INIT;
                    InterimSalesLine.TRANSFERFIELDS(L_InterimSalesLine);

                    InterimSalesLine."Document Type" := L_InterimSalesHeader."Document Type";
                    InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
                    Clear(InterimSalesLine."Destination Doc. Line No");
                    CLEAR(InterimSalesLine."Destination Doc No.");
                    CLEAR(InterimSalesLine."Destination Doc Type");
                    CLEAR(InterimSalesLine."Scanned Date");
                    CLEAR(InterimSalesLine."Dispatch Scan");
                    CLEAR(InterimSalesLine."Trolley No.");
                    CLEAR(InterimSalesLine."Moved In Handled");
                    Clear(InterimSalesLine."Trolley Closed Quantity");
                    InterimSalesLine."Order Status" := InterimSalesLine."Order Status"::Accepted;
                    InterimSalesLine.Reserved := FALSE;
                    InterimSalesLine.INSERT(TRUE);
                UNTIL L_InterimSalesLine.NEXT = 0;
        END;
    End;

    procedure CancelOrder(var P_InterimSalesHeader: Record "Interim Sales Header")
    var
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        MoveOrdertoHandled: Report "Move Scanned Order to Handled";
        R80020: Report "Move Scanned Order to Handled";
        L_InterimSalesLine: record "Interim Sales Line";
        L_ISH: Record "Interim Sales Header";
    begin
        L_PartnerErrorLog.RESET;
        L_PartnerErrorLog.SETRANGE("Document No.", P_InterimSalesHeader."No.");
        IF L_PartnerErrorLog.FINDFIRST THEN
            REPEAT
                L_PartnerErrorLog.DELETE;
            UNTIL L_PartnerErrorLog.NEXT = 0;
        //P_InterimSalesHeader.Status := P_InterimSalesHeader.Status::Cancelled;
        P_InterimSalesHeader.Modify();

        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        if L_InterimSalesLine.FindSet() then
            repeat
                L_InterimSalesLine."Line Status" := L_InterimSalesLine."Line Status"::Cancelled;
                L_InterimSalesLine.Modify(true);
            until L_InterimSalesLine.Next() = 0;

        //code to move order to handeled
        R80020.SetWindowDialogueAndNoofRec(P_InterimSalesHeader);
        R80020.ProcessData(P_InterimSalesHeader);

        L_ISH.Reset();
        L_ISH.SetRange("No.", P_InterimSalesHeader."No.");
        L_ISH.SetRange("Moved In Handled", true);
        If L_ISH.FindSet() then
            L_ISH.DeleteAll(true);

    end;

    procedure CreateCustomer()
    var
        InterimCustomer: Record "Interim Customer";
        Customer: Record Customer;
        TradePartner: Record "Trade Partner";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesManagement: Codeunit "No. Series";
        ShiptoAddress: Record "Ship-to Address";

    begin
        IF NOT CONFIRM('Do you want to process?', FALSE) THEN
            EXIT;
        InterimCustomer.Reset;
        InterimCustomer.SetRange(Process, true);
        if InterimCustomer.FindSet then begin
            repeat
                TradePartner.Get(InterimCustomer."Channel Code");
                IF CheckPostingSetups(InterimCustomer."No.") then begin
                    if InterimCustomer."Customer No." = '' then begin
                        Customer.Reset;
                        Customer.SetRange("Web Customer No. 2", InterimCustomer."No.");
                        if not Customer.FindFirst then begin
                            Customer.Init;
                            Customer."No." := NoSeriesManagement.GetNextNo(TradePartner."Customer No. Series", WorkDate, true);
                            Customer.Validate(Name, InterimCustomer.Name);
                            Customer.Insert;
                            Customer.VALIDATE(Address, InterimCustomer.Address);
                            Customer.VALIDATE("Address 2", InterimCustomer."Address 2");
                            Customer.VALIDATE(City, InterimCustomer.City);
                            Customer.VALIDATE("Phone No.", InterimCustomer."Phone No");
                            Customer.VALIDATE("Post Code", InterimCustomer."Post Code");
                            Customer.VALIDATE("E-Mail", InterimCustomer."E-Mail");
                            Customer.VALIDATE(Blocked, InterimCustomer.Blocked);
                            Customer.VALIDATE("Customer type 2", Customer."Customer type 2"::Web);
                            Customer.VALIDATE("Web Customer No. 2", InterimCustomer."No.");
                            Customer.VALIDATE("Customer Posting Group", InterimCustomer."Customer Posting Group");
                            Customer.VALIDATE("VAT Bus. Posting Group", InterimCustomer."VAT Bus. Posting Group");
                            Customer.VALIDATE("Gen. Bus. Posting Group", InterimCustomer."Gen. Bus. Posting Group");
                            Customer.VALIDATE("Responsibility Center", InterimCustomer."Responsibility Center");
                            Customer.VALIDATE("Credit Limit (LCY)", InterimCustomer."Credit Limit (LCY)");
                            Customer.VALIDATE("Company Reg. No. 3", InterimCustomer."Company Reg No");
                            Customer.VALIDATE("Country/Region Code", InterimCustomer.Country);
                            Customer.VALIDATE(County, InterimCustomer.County);
                            Customer.MODIFY;
                            ShiptoAddress.Reset;
                            ShiptoAddress.SetRange("Customer No.", Customer."No.");
                            ShiptoAddress.SetRange(Code, '001');
                            if not ShiptoAddress.FindFirst then begin
                                ShiptoAddress.Init;
                                ShiptoAddress.Validate(Code, '002');
                                ShiptoAddress.Validate("Customer No.", Customer."No.");
                                ShiptoAddress.Validate(Name, InterimCustomer."Shipping Contact");
                                ShiptoAddress.Validate(Address, InterimCustomer."Shipping Address");
                                ShiptoAddress.Validate("Address 2", InterimCustomer."Shipping Address 2");
                                ShiptoAddress.Validate(City, InterimCustomer."Shipping City");
                                ShiptoAddress.Validate(County, InterimCustomer."Shipping County");
                                ShiptoAddress.Validate("Post Code", InterimCustomer."Shipping Post Code");
                                ShiptoAddress.Validate("Country/Region Code", InterimCustomer."Shipping Country");
                                ShiptoAddress.Validate(Contact, InterimCustomer."Shipping Phone No.");
                                ShiptoAddress.Insert;
                            end
                            else begin
                                ShiptoAddress.Init;
                                ShiptoAddress.Validate(Code, '001');
                                ShiptoAddress.Validate("Customer No.", Customer."No.");
                                ShiptoAddress.Validate(Name, InterimCustomer."Shipping Contact");
                                ShiptoAddress.Validate(Address, InterimCustomer."Shipping Address");
                                ShiptoAddress.Validate("Address 2", InterimCustomer."Shipping Address 2");
                                ShiptoAddress.Validate(City, InterimCustomer."Shipping City");
                                ShiptoAddress.Validate(County, InterimCustomer."Shipping County");
                                ShiptoAddress.Validate("Post Code", InterimCustomer."Shipping Post Code");
                                ShiptoAddress.Validate("Country/Region Code", InterimCustomer."Shipping Country");
                                ShiptoAddress.Validate(Contact, InterimCustomer."Shipping Phone No.");
                                ShiptoAddress.Insert;
                            end;

                        end;
                    end
                    else begin
                        UpdateCustomer(InterimCustomer."Customer No.");
                    end;
                end;
                UpdateHandledCustomer(InterimCustomer."No.");

            until InterimCustomer.Next = 0;
        end;
        InterimCustomer.MarkedOnly;
        InterimCustomer.DeleteAll;
    end;

    procedure CheckPostingSetups(CustWebNo: Code[20]): Boolean
    var
        InterimCustomer: Record "Interim Customer";
        Customer: Record Customer;
    begin
        Customer.Reset;
        Customer.SetRange("Web Customer No. 2", CustWebNo);
        if Customer.FindFirst then
            exit(true);
        InterimCustomer.Reset;
        InterimCustomer.SetRange("No.", CustWebNo);
        if InterimCustomer.FindFirst then begin
            if not bool then begin
                IF ((InterimCustomer."Gen. Bus. Posting Group" = '') AND (InterimCustomer."VAT Bus. Posting Group" = '') AND (InterimCustomer."Customer Posting Group" = '')) THEN BEGIN
                    IF CONFIRM('Posting setups not inserted are you want to insert default posting setup?', TRUE) THEN BEGIN
                        InterimCustomer."VAT Bus. Posting Group" := 'DOMESTIC';
                        InterimCustomer."Gen. Bus. Posting Group" := 'DOMESTIC';
                        InterimCustomer."Customer Posting Group" := 'DOMESTIC';
                        InterimCustomer.MODIFY;
                        Commit();
                    END
                    ELSE begin

                    end;
                END;
            END;
            IF ((InterimCustomer."Gen. Bus. Posting Group" = '') AND (InterimCustomer."VAT Bus. Posting Group" = '') AND (InterimCustomer."Customer Posting Group" = '')) THEN
                EXIT(FALSE)
            ELSE
                EXIT(TRUE);
        end;

    end;

    procedure UpdateCustomer(No: Code[20])
    var
        Customer: Record Customer;
        InterimCustomer: Record "Interim Customer";
    begin
        Customer.Reset;
        Customer.SetRange("No.", No);
        if Customer.FindFirst then begin
            InterimCustomer.Reset;
            InterimCustomer.SetRange("Customer No.", Customer."No.");
            if InterimCustomer.FindFirst then begin
                Customer.Validate("Web Customer No. 2", InterimCustomer."No.");
                Customer.Validate("Customer type 2", Customer."Customer type 2"::Both);
                Customer.Modify;
            end;
        end;
    end;

    procedure UpdateHandledCustomer(No: Code[20])
    var
        HandledCustomer: Record "Handled Customer";
        InterimCustomer: Record "Interim Customer";
        Customer: Record Customer;
    begin
        InterimCustomer.Reset;
        InterimCustomer.SetRange("No.", No);
        if InterimCustomer.FindFirst then begin
            HandledCustomer.Init;
            HandledCustomer."Web Customer No." := InterimCustomer."No.";
            HandledCustomer."Trade Partner Code" := InterimCustomer."Channel Code";
            if InterimCustomer."Customer No." <> '' then begin
                HandledCustomer."Nav Customer No." := InterimCustomer."Customer No.";
            end
            else begin
                Customer.Reset;
                Customer.SetRange("Web Customer No. 2", InterimCustomer."No.");
                if Customer.FindFirst then begin
                    HandledCustomer."Nav Customer No." := Customer."No.";
                end;

            end;
            HandledCustomer."Posting Date" := WorkDate();
            HandledCustomer."Customer Posting Group" := InterimCustomer."Customer Posting Group";
            HandledCustomer."Gen. Bus. Posting Group" := InterimCustomer."Gen. Bus. Posting Group";
            HandledCustomer."VAT Bus. Posting Group" := InterimCustomer."VAT Bus. Posting Group";
            HandledCustomer.Name := InterimCustomer.Name;
            HandledCustomer.Address := InterimCustomer.Address;
            HandledCustomer."Address 2" := InterimCustomer."Address 2";
            HandledCustomer.City := InterimCustomer.City;
            HandledCustomer."Phone No" := InterimCustomer."Phone No";
            HandledCustomer."Post Code" := InterimCustomer."Post Code";
            HandledCustomer."E-Mail" := InterimCustomer."E-Mail";
            HandledCustomer."Credit Limit (LCY)" := InterimCustomer."Credit Limit (LCY)";
            HandledCustomer."Responsibility Center" := InterimCustomer."Responsibility Center";
            HandledCustomer."Company Name" := InterimCustomer."Company Name";
            HandledCustomer."Company Type" := InterimCustomer."Company Type";
            HandledCustomer."Company Reg No" := InterimCustomer."Company Reg No";
            HandledCustomer."VAT No" := InterimCustomer."VAT No";
            HandledCustomer."Business Type" := InterimCustomer."Business Type";
            HandledCustomer.Website := InterimCustomer.Website;
            HandledCustomer."Address 3" := InterimCustomer."Address 3";
            HandledCustomer.County := InterimCustomer.County;
            HandledCustomer.Country := InterimCustomer.Country;
            HandledCustomer."Shipping Contact" := InterimCustomer."Shipping Contact";
            HandledCustomer."Shipping Address" := InterimCustomer."Shipping Address";
            HandledCustomer."Shipping Address 2" := InterimCustomer."Shipping Address 2";
            HandledCustomer."Shipping Address 3" := InterimCustomer."Shipping Address 3";
            HandledCustomer."Shipping City" := InterimCustomer."Shipping City";
            HandledCustomer."Shipping Phone No." := InterimCustomer."Shipping Phone No.";
            HandledCustomer."Shipping Post Code" := InterimCustomer."Shipping Post Code";
            HandledCustomer."Shipping County" := InterimCustomer."Shipping County";
            HandledCustomer."Shipping Country" := InterimCustomer."Shipping Country";
            HandledCustomer.AccountNo := InterimCustomer.AccountNo;
            HandledCustomer."Job Title" := InterimCustomer."Job Title";
            HandledCustomer."Country Name" := InterimCustomer."Country Name";
            HandledCustomer."Shipping Country Name" := InterimCustomer."Shipping Country Name";
            InterimCustomer.Mark(true);
            HandledCustomer.Insert;
        end;
        InterimCustomer.MarkedOnly(true);
        InterimCustomer.DeleteAll(true);
    end;

    //below function is use to upload any file from BC to azure blob
    procedure UploadFilefromBCTOAzureBlob(P_FileInstream: InStream; P_FileName: Text; P_apiEndPoint: Text; P_containerName: Text; P_sasToken: Text; Showmessage: Boolean)
    var
        fileMgt: Codeunit "File Management";
        L_httpResponse: HttpResponseMessage;
        L_httpHeader: HttpHeaders;
        apiEndPoint: Text;
        containerName: Text;
        filename: Text;
        sasToken: text;
        apiUrl: Text;
        L_httpClient: HttpClient;
        L_httpContent: HttpContent;
        apiattribute: Text;
    begin
        //Upload++
        ClearLastError();
        Clear(L_httpContent);
        Clear(L_httpHeader);
        Clear(apiEndPoint);
        Clear(containerName);
        Clear(filename);
        Clear(sasToken);
        Clear(L_httpClient);
        Clear(L_httpResponse);
        L_httpContent.WriteFrom(P_FileInstream);
        L_httpContent.GetHeaders(L_httpHeader);

        L_httpHeader.Remove('Content-Type');
        L_httpHeader.Add('x-ms-version', '2015-02-21');
        L_httpHeader.Add('x-ms-date', '2015-02-21');
        L_httpHeader.Add('x-ms-blob-type', 'BlockBlob');
        L_httpHeader.Add('Content-Type', 'text/xml');

        apiEndPoint := P_apiEndPoint;
        containerName := P_containerName;
        sasToken := P_sasToken;

        apiUrl := apiEndPoint + '/' + containerName + '/' + P_FileName + sasToken;
        L_httpClient.Put(apiUrl, L_httpContent, L_httpResponse);
        if Showmessage then begin
            if ((L_httpResponse.HttpStatusCode = 200) OR (L_httpResponse.HttpStatusCode = 201)) then
                Message('file uploaded successfully.');
        end;
        //Upload--
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertInterimSalesHeader(var L_InterimSalesHeader: Record "Interim Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExplodeBoM(var P_InterimSalesLine: Record "Interim Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExplodeBoM(var P_InterimSalesLine: Record "Interim Sales Line")
    begin
    end;


    //DirectPrintingLabel++
    procedure SendDirectPrintRequest(P_No: Code[20]; P_ReportID: Integer; PrintType: Text[3])
    var
        L_PrinterSelection: Record "Printer Selection";
        IWXPrintNodePrinter: Record 23044334;
        L_ShipmentTracking: Record "Shipment Tracking";
        penumPrintType: Enum "IWX PrintNode Print Type";
        L_Instream: InStream;
        L_PrintText: Text;
        Base64Convert: Codeunit "Base64 Convert";
        EPLCommands: Text;
    begin
        Clear(L_Instream);
        Clear(L_PrintText);
        Clear(EPLCommands);
        L_ShipmentTracking.Reset();
        L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
        L_ShipmentTracking.SetRange("Document No.", P_No);
        if L_ShipmentTracking.FindSet() then begin
            repeat
                if L_ShipmentTracking.Label.HasValue() then begin
                    L_ShipmentTracking.CalcFields(Label);
                    L_ShipmentTracking.Label.CreateInStream(L_Instream);

                    //Message(EPLCommands);
                    L_PrinterSelection.Reset();
                    L_PrinterSelection.SetRange("Report ID", P_ReportID);
                    L_PrinterSelection.SetRange("User ID", UserId);
                    if L_PrinterSelection.FindFirst() then begin
                        IWXPrintNodePrinter.Reset();
                        IWXPrintNodePrinter.SetRange(Name, L_PrinterSelection."Printer Name");
                        if IWXPrintNodePrinter.FindFirst() then begin
                            if PrintType = 'PDF' then begin
                                DirectPrint(IWXPrintNodePrinter.ID, 'Courier Label', penumPrintType::PDF, L_Instream, 1);// Instream function
                            end;
                            if PrintType = 'RAW' then begin
                                L_Instream.ReadText(L_PrintText);
                                EPLCommands := Base64Convert.FromBase64(L_PrintText);
                                DirectPrint(IWXPrintNodePrinter.ID, 'Courier Label', penumPrintType::RAW, EPLCommands, 1);// RAW Text function
                            end;
                        end;
                    end;
                end;
            until L_ShipmentTracking.Next() = 0;
            Message('Completed');
        end;
    end;

    local procedure DirectPrint(piPrinterID: Integer; psPrintJobTitle: Text; penumPrintType: Enum "IWX PrintNode Print Type"; psPrintJobText: Text;
                                                                                                 piPrintJobQty: Integer)
    var
        L_PrintNodeApiMgt: Codeunit "IWX PrintNode API Mgt.";
    begin
        L_PrintNodeApiMgt.PrintDirect(piPrinterID, psPrintJobTitle, penumPrintType, psPrintJobText, piPrintJobQty);
    end;

    local procedure DirectPrint(piPrinterID: Integer; psPrintJobTitle: Text; penumPrintType: Enum "IWX PrintNode Print Type"; psPrintJobText: InStream;
                                                                                                 piPrintJobQty: Integer)
    var
        L_PrintNodeApiMgt: Codeunit "IWX PrintNode API Mgt.";
    begin
        L_PrintNodeApiMgt.PrintDirect(piPrinterID, psPrintJobTitle, penumPrintType, psPrintJobText, piPrintJobQty);
    end;
    //DirectPrintingLabel--


    local procedure InsertGiftGlLine(var P_InterimSalesLine: Record "Interim Sales Line" temporary; P_InterimSalesHeader: Record "Interim Sales Header")
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        ChannelPartner: Record "Trade Partner";
    begin
        ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesLine.INIT;
        L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
        L_InterimSalesLine."Document No" := P_InterimSalesHeader."No.";
        L_InterimSalesLine."Line No." := FindLastLineNo(P_InterimSalesHeader);
        L_InterimSalesLine.Type := L_InterimSalesLine.Type::"G/L Account";
        L_InterimSalesLine.VALIDATE("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine.VALIDATE("No.", ChannelPartner."GiftWrap G/L No.");
        L_InterimSalesLine.VALIDATE(Quantity, P_InterimSalesLine.Quantity);
        L_InterimSalesLine.VALIDATE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesLine.Validate("Unit Price", P_InterimSalesLine."Unit Price");
        L_InterimSalesLine.VALIDATE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
        L_InterimSalesLine.Validate("Gift Card", true);
        L_InterimSalesLine.INSERT(TRUE);
    end;

    local procedure GetGiftOrderAmount(P_InterimSalesHeader: Record "Interim Sales Header"): Decimal
    var
        ChannelPartner: Record "Trade Partner";
        GiftOderAmount: Decimal;
    begin
        G_GiftBool := false;
        Clear(GiftOderAmount);
        ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
        G_InterimSalesLine.Reset();
        G_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        G_InterimSalesLine.SetRange(Type, G_InterimSalesLine.Type::"G/L Account");
        G_InterimSalesLine.SetRange("No.", ChannelPartner."GiftWrap G/L No.");
        G_InterimSalesLine.SetRange("Gift Card", true);
        if G_InterimSalesLine.FindSet() then
            repeat
                GiftOderAmount += G_InterimSalesLine."Amount Including VAT";
                G_GiftBool := true;
            until G_InterimSalesLine.Next() = 0;
        exit(GiftOderAmount);
    end;

    local procedure DeleteRefundPaymentDetails(var PaymentDetail: Record "Channel Media" temporary)
    var
        TempPaymentDetail: Record "Channel Media" temporary;
    begin
        TempPaymentDetail.DeleteAll();
        if PaymentDetail.FindSet() then
            repeat
                TempPaymentDetail.Init();
                TempPaymentDetail.Copy(PaymentDetail);
                TempPaymentDetail.Insert();
            until PaymentDetail.Next() = 0;

        TempPaymentDetail.Reset();
        TempPaymentDetail.SetFilter("Parent Transaction ID", '<>%1', '');
        if TempPaymentDetail.FindSet() then begin
            repeat
                PaymentDetail.Reset();
                PaymentDetail.SetRange("Transaction ID", TempPaymentDetail."Parent Transaction ID");
                if PaymentDetail.FindFirst() then
                    PaymentDetail.Delete(true);
            until TempPaymentDetail.Next() = 0;

            PaymentDetail.Reset();
            PaymentDetail.SetFilter("Parent Transaction ID", '<>%1', '');
            if PaymentDetail.FindSet() then
                repeat
                    PaymentDetail.Delete();
                until PaymentDetail.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterRegisteredWhseActivHeaderInsert', '', true, true)]
    local procedure OnAfterRegisteredWhseActivHeaderInsert(var RegisteredWhseActivityHdr: Record "Registered Whse. Activity Hdr."; WarehouseActivityHeader: Record "Warehouse Activity Header")
    var
        L_WAL: Record "Warehouse Activity Line";
    begin
        L_WAL.Reset();
        L_WAL.SetRange("Activity Type", L_WAL."Activity Type"::Pick);
        L_WAL.SetRange("Whse. Document Type", L_WAL."Whse. Document Type"::Shipment);
        L_WAL.SetRange("No.", RegisteredWhseActivityHdr."Whse. Activity No.");
        if L_WAL.FindFirst() then begin
            RegisteredWhseActivityHdr.Validate("Trolley No.", L_WAL."Trolley No.");
            RegisteredWhseActivityHdr.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeCreateActivityFromSalesLine2ShptLine', '', false, false)]
    local procedure OnBeforeCreateActivityFromSalesLine2ShptLine(WhseShptHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
    begin
        WarehouseShipmentHeader.Reset();
        WarehouseShipmentHeader.SetRange("No.", WhseShptHeader."No.");
        if WarehouseShipmentHeader.FindFirst() then begin
            IF WarehouseShipmentHeader."Shipping Agent Code" = '' then begin
                WarehouseShipmentHeader.Validate("Shipping Agent Code", SalesLine."Shipping Agent Code");
                WarehouseShipmentHeader.validate("Shipping Agent Service Code", SalesLine."Shipping Agent Service Code");
                WarehouseShipmentHeader.Modify(true);
            end;
        end;
    end;

    #Region Checking Shipping Agent Service Item Restriction++
    procedure CheckShippingAgentServiceRestriction(P_ItemNo: Code[20]; P_ShippingAgentCode: Code[20]; P_ShippingAgentServiceCode: Code[20]): Boolean
    var
        L_RecItemAttValMap: Record "Item Attribute Value Mapping";
        L_ItemAttribute: Record "Item Attribute";
        L_ItemAttributeValue: Record "Item Attribute Value";
        ShippingAgentRestrictItem: Record "Shipping Agent Restrict Item";
    begin
        L_RecItemAttValMap.Reset();
        L_RecItemAttValMap.SetRange("Table ID", 27);
        L_RecItemAttValMap.SetRange("No.", P_ItemNo);
        if L_RecItemAttValMap.FindSet() then begin
            repeat
                L_ItemAttribute.Reset();
                L_ItemAttribute.SetRange(ID, L_RecItemAttValMap."Item Attribute ID");
                if L_ItemAttribute.FindFirst() then begin
                    L_ItemAttributeValue.SetRange("Attribute ID", L_ItemAttribute.ID);
                    L_ItemAttributeValue.SetRange(ID, L_RecItemAttValMap."Item Attribute Value ID");
                    if L_ItemAttributeValue.FindFirst() then begin
                        if L_ItemAttributeValue.Value <> '' then begin
                            ShippingAgentRestrictItem.Reset();
                            ShippingAgentRestrictItem.SetRange("Shipping Agent Code", P_ShippingAgentCode);
                            ShippingAgentRestrictItem.SetRange("Shipping Agent Service Code", P_ShippingAgentServiceCode);
                            ShippingAgentRestrictItem.SetRange("Attribute ID", L_ItemAttribute.ID);
                            ShippingAgentRestrictItem.SetRange("Attribute value ID", L_RecItemAttValMap."Item Attribute Value ID");
                            ShippingAgentRestrictItem.SetRange("QAU Approved", true);
                            if ShippingAgentRestrictItem.FindFirst() then begin
                                //Error('CD and Fridge items are not allowed for Shipping agent service code %1.Item No. %2', _ShippingAgentServiceCode, _ItemNo);
                                exit(true);
                            end;
                        end;
                    end;
                end;
            until L_RecItemAttValMap.Next() = 0;
        end;
        exit(false);
    end;
    #endregion Checking Shipping Agent Service Item Restriction++

    procedure CheckItemBlockedError(var P_Item: Record Item): Text
    var
        ItemBlockedError: Text;
    begin
        Clear(ItemBlockedError);
        if P_Item.Blocked = true then
            exit('Item is Blocked')
        else begin
            if P_Item."Sales Blocked" = true then
                exit('Item is Sales Blocked')
            else begin
                if P_Item."Ops Sales Blocked" = true then
                    exit('Item is Ops Sales Blocked')
                else begin
                    if P_Item.Status = P_Item.Status::Open then
                        exit('Item is in Open Status')
                    else begin
                        if P_Item."QAU Approved" = false then
                            exit('Item is not QAU Approved');
                    end;
                end;
            end;
        end;
    end;

    local procedure GetVariantSetup(_ItemNo: Code[20]): Boolean
    var
        L_ItemVariant: Record "Item Variant";
        L_Item: Record Item;
    begin
        L_Item.Reset();
        L_Item.SetRange("No.", _ItemNo);
        if L_Item.FindFirst() then begin
            if L_Item."Variant Mandatory if Exists" <> L_Item."Variant Mandatory if Exists"::No then begin
                if L_Item."Variant Mandatory if Exists" = L_Item."Variant Mandatory if Exists"::Yes then
                    exit(true)
                else begin
                    L_ItemVariant.Reset();
                    L_ItemVariant.SetRange("Item No.", _ItemNo);
                    if L_ItemVariant.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            end else
                exit(false);
        end;
    end;

    var
        bool: Boolean;
        G_InterimSalesLine: Record "Interim Sales Line";
        G_GiftBool: Boolean;
}