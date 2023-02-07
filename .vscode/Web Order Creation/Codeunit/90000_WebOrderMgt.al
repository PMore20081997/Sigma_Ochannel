
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
    Permissions = tabledata "Registered Whse. Activity Hdr." = RIMD;
    trigger OnRun()
    begin

    end;

    procedure CreateWebOrder(var P_InterimSalesHeader: Record "Interim Sales Header" temporary; var P_InterimSalesLine: Record "Interim Sales Line" temporary; P_ShipmentTracking: Record "Shipment Tracking" temporary; var P_PaymentDetail: Record "Channel Media" temporary)
    //Code to create a web Order and Line based on the data coming from diffrent channel integration code unit
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit NoSeriesManagement;
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
    Begin
        If CheckOrderNotExist(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Channel Order ID") then begin

            ChannelPartner.Get(P_InterimSalesHeader."Trade Partner Code");
            GeneralSetup.Get;
            GeneralSetup.TestField("Web Order Nos");

            L_InterimSalesHeader.INIT;
            L_InterimSalesHeader."Document Type" := L_InterimSalesHeader."Document Type"::Order;
            L_InterimSalesHeader."No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
            L_InterimSalesHeader.VALIDATE(Status, L_InterimSalesHeader.Status::"In Progress");
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
                L_InterimSalesHeader.VALIDATE(Address, SellToCustomer.Address);
                L_InterimSalesHeader.VALIDATE("Address 2", SellToCustomer."Address 2");
                L_InterimSalesHeader.VALIDATE(City, SellToCustomer.City);
                L_InterimSalesHeader.VALIDATE("Post Code", SellToCustomer."Post Code");
                L_InterimSalesHeader.VALIDATE("Sell to Country", SellToCustomer."Country/Region Code");
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
            L_InterimSalesHeader.VALIDATE("Ship-to Phone", P_InterimSalesHeader."Ship-to Phone");
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

            /* Query_OrderAmt.SetRange(Query_OrderAmt.Document_Type, L_InterimSalesHeader."Document Type");
             Query_OrderAmt.SetRange(Query_OrderAmt.Document_No, L_InterimSalesHeader."No.");
             Query_OrderAmt.Open();
             while Query_OrderAmt.Read() do begin
                 L_InterimSalesHeader."Total Order Item Amount" := Query_OrderAmt.Amount_Including_VAT;
                 //L_InterimSalesHeader.Modify();            
             end;

             if L_InterimSalesHeader."Order Discount Amount" <> 0 then begin
                 if L_InterimSalesHeader."Total Order Item Amount" <> 0 then
                     Discountperscent := Round(((L_InterimSalesHeader."Order Discount Amount" / L_InterimSalesHeader."Total Order Item Amount") * 100), 0.01);
                 //Round(((L_InterimSalesHeader."Order Discount Amount" / (L_InterimSalesHeader."Total Order Item Amount" + L_InterimSalesHeader."Order Discount Amount")) * 100), 0.01);
                 L_InterimSalesLine.Reset();
                 L_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
                 L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                 L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                 if L_InterimSalesLine.FindSet() then
                     repeat
                         L_InterimSalesLine."Discount %" := Discountperscent;
                         L_InterimSalesLine.Modify();
                     until L_InterimSalesLine.Next() = 0;
             end;*/


            // Irshad Khan  Modifying shle No. to sorting by Shelf No. in WIP
            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
            L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
            L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
            if L_InterimSalesLine.FindSet() then
                repeat
                    L_InterimSalesHeader."Shelf No." := L_InterimSalesLine."Shelf No.";
                until L_InterimSalesLine.Next() = 0;
            // Irshad Khan

            CreateGLLines(L_InterimSalesHeader);
            //CreateShippment
            //  InsertInShipmentTracking(L_InterimSalesHeader);

            //Channel Media Payment Details Insert Functionality


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
            L_PaymentDetails.SetRange("Payment Method", P_PaymentDetail."Payment Method");
            if L_PaymentDetails.Count > 1 then
                Clear(L_InterimSalesHeader."Payment Method");

            L_InterimSalesHeader."Gift Order Amount" := GetGiftOrderAmount(L_InterimSalesHeader);
            L_InterimSalesHeader."Gift Card" := G_GiftBool;

            if UpdateTrackingNoForOnlyGiftCardGlLines(L_InterimSalesHeader) then begin
                L_InterimSalesHeader."Package Tracking No." := L_InterimSalesHeader."Channel Order ID";
                ShipmentTracking.Reset();
                ShipmentTracking.SetRange("Document Type", ShipmentTracking."Document Type"::Order);
                ShipmentTracking.SetRange("Document No.", P_InterimSalesHeader."No.");
                if not ShipmentTracking.FindFirst() then begin
                    ShipmentTracking.Init();
                    ShipmentTracking."Document Type" := ShipmentTracking."Document Type"::Order;
                    ShipmentTracking."Document No." := L_InterimSalesHeader."No.";
                    ShipmentTracking."Tracking No." := L_InterimSalesHeader."Channel Order ID";
                    ShipmentTracking."Shipping Agent Code" := L_InterimSalesHeader."Shipping Agent Code";
                    ShipmentTracking."Shipping Agent Service Code" := L_InterimSalesHeader."Shipping Agent Service Code";
                    ShipmentTracking."Entry Created" := Today;
                    ShipmentTracking.Insert(true);
                end;
            end;

            L_InterimSalesHeader.Modify();

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
            OrderValidations(L_InterimSalesHeader);

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


    procedure calculateNoofItems(P_InterimSalesHeader: record "Interim Sales Header"): Integer
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

    local procedure FindLastLineNo(P_InterimSalesH: Record "Interim Sales Header"): Integer
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
        ItemCrossReference: Record "Item Reference";
        L_Item: Record Item;
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
            ItemCrossReference.RESET;
            ItemCrossReference.SETRANGE("Reference Type", ItemCrossReference."Reference Type"::Customer);
            ItemCrossReference.SETRANGE("Reference Type No.", P_CustNo);
            ItemCrossReference.SETRANGE("Reference No.", P_CrossRefNo);
            IF ItemCrossReference.FINDFIRST THEN
                EXIT(ItemCrossReference."Item No.");

            // IF L_Item.GET(P_CrossRefNo) THEN
            //     EXIT(L_Item."No.");
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

    procedure WebOrderValidation()
    begin

    end;


    procedure CreateGLLines(P_InterimSalesHeader: Record "Interim Sales Header")
    //Code to create GL lines if applicable
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_ShippingPrice: Decimal;
        L_shippingRule: Record "OCHANNEL Shipping Rule";
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
    //Code to insert sales line
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_ItemNo: Code[20];
        Rec_Item: Record Item;
        L_ItemVariant: Record "Item Variant";
        PriceListIntegration: Codeunit "Price List Integration";
        GeneralSetup: record "General Setup - Channels";
        L_TradePartner: Record "Trade Partner";
        //Paarth D Dave - 8197-1 - Auto Assembly Order boolean ---- Start
        L_ItemCategory: Record "Item Category";
        L_IntrimSalesHeader: Record "Interim Sales Header";
    //Paarth D Dave - 8197-1 - Auto Assembly Order boolean ---- End
    begin
        L_InterimSalesLine.INIT;
        L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
        L_InterimSalesLine."Document No" := P_InterimSalesHeader."No.";
        L_InterimSalesLine."Order Date" := P_InterimSalesHeader."Order Date";
        L_InterimSalesLine.VALIDATE("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesLine.VALIDATE("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine."Line No." := FindLastLineNo(P_InterimSalesHeader);
        L_InterimSalesLine.Type := L_InterimSalesLine.Type::Item;
        L_InterimSalesLine.VALIDATE("Channel Identifier", P_InterimSalesLine."Channel Identifier");
        L_InterimSalesLine."Channel SKU" := P_InterimSalesLine."Channel SKU";
        L_InterimSalesLine."Channel Item Id" := P_InterimSalesLine."Channel Item Id";
        L_ItemNo := FindItemNo(L_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU", L_InterimSalesLine."Sell-to Customer No.", P_ChannelPartner);
        L_InterimSalesLine.Validate("No.", L_ItemNo);
        /*L_InterimSalesLine.Description := P_InterimSalesLine.Description;
        if (L_ItemNo <> '') and (P_InterimSalesLine.Description = '') then begin
            Rec_Item.Reset();
            if Rec_Item.Get(L_ItemNo) then
                L_InterimSalesLine.Description := Rec_Item.Description;
        end;*/
        L_InterimSalesLine.Description2 := P_InterimSalesLine.Description2;
        L_InterimSalesLine."NAV Variant code" := GetNavVariantCode(P_InterimSalesLine."Channel SKU", P_ChannelPartner, P_InterimSalesLine."Channel Identifier", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine.Validate(Quantity, P_InterimSalesLine.Quantity);
        L_InterimSalesLine.Validate("Unit of Measure Code", FindUOM(L_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU"
         , L_InterimSalesLine."No.", L_InterimSalesLine."Sell-to Customer No.", P_ChannelPartner));

        L_InterimSalesLine."Channel Price" := P_InterimSalesLine."Unit Price";
        L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");
        case L_TradePartner."Price Pick From" of
            L_TradePartner."Price Pick From"::"Order Source":
                L_InterimSalesLine.Validate("Unit Price", P_InterimSalesLine."Unit Price");
            L_TradePartner."Price Pick From"::"channel Price":
                ItemLinePrice(L_InterimSalesLine, true);
            L_TradePartner."Price Pick From"::"Sales Price":
                PriceListIntegration.CalculateUnitPrice(P_InterimSalesHeader, L_InterimSalesLine);
        end;
        // If P_ChannelPartner."Use Channel List Price" then
        //     ItemLinePrice(L_InterimSalesLine, true)
        // Else
        // L_InterimSalesLine.Validate("Unit Price", P_InterimSalesLine."Unit Price");
        L_InterimSalesLine."Shipping Price" := P_InterimSalesLine."Shipping Price";
        L_InterimSalesLine."Gift Wrap Price" := P_InterimSalesLine."Gift Wrap Price";
        L_InterimSalesLine.Hazardous := P_InterimSalesLine.Hazardous;
        L_InterimSalesLine.FileName := P_InterimSalesLine.FileName;
        L_InterimSalesLine.Weight := P_InterimSalesLine.Weight;
        L_InterimSalesLine."Channel Order ID" := P_InterimSalesLine."Channel Order ID";//Sofyan
        L_InterimSalesLine."Currency Code" := P_InterimSalesLine."Currency Code";

        //L_InterimSalesLine."Discount %" := P_Discountper; //code for discount

        L_InterimSalesLine."Shipment Date" := P_InterimSalesLine."Shipment Date";
        //L_InterimSalesLine."Discount %" := P_Discountper; code for discount

        //L_InterimSalesLine.Discount := Round(((L_InterimSalesLine.Amount * P_Discountper)/100),0.01);
        L_InterimSalesLine.Discount := P_InterimSalesLine.Discount; //RK 17-05-2022
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
        //Paarth D Dave - 8197-1 - Auto Assembly Order boolean ---- Start
        Rec_Item.Reset();
        Rec_Item.SetRange("No.", L_ItemNo);
        if Rec_Item.FindFirst() then begin
            L_ItemCategory.Reset();
            L_ItemCategory.SetRange("Code", Rec_Item."Item Category Code");
            if L_ItemCategory.FindFirst() then begin
                if L_ItemCategory."Auto Assembly Order" then begin
                    L_InterimSalesLine."Auto Assembly Order" := true;
                    // L_IntrimSalesHeader.Reset();
                    // L_IntrimSalesHeader.SetRange("No.", P_InterimSalesHeader."No.");
                    // if L_IntrimSalesHeader.FindFirst() then begin
                    //     L_IntrimSalesHeader."Assemply Order" := true;
                    //     L_IntrimSalesHeader.Modify();
                    // end;
                end;
            end;
        end;
        //Paarth D Dave - 8197-1 - Auto Assembly Order boolean ---- End

        if P_InterimSalesLine."Gift Card" then
            L_InterimSalesLine."Gift Card" := true;
        L_InterimSalesLine.Insert(true);

    end;



    procedure GetNavVariantCode(ChannelSKU: Text[50]; P_ChannelPartner: Record "Trade Partner"; P_ASINNo: Code[50]; P_CustNo: Code[20]): Code[20]
    var
        ChannelItemListing: Record "Channel Item Listing";
        ItemCrossReference: Record "Item Reference";
    begin
        /* ChannelItemListing.Reset();
         ChannelItemListing.SetRange("Channel SKU", ChannelSKU);
         ChannelItemListing.SetRange("Channel Code", P_ChannelPartner.Code);
         if ChannelItemListing.FindFirst() then begin
             exit(ChannelItemListing."NAV Variant");
         end;*/
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
    begin
        If P_InterimSalesLine.Type <> P_InterimSalesLine.Type::Item then
            exit;

        If P_InterimSalesLine."Item Type" = P_InterimSalesLine."Item Type"::Component then
            exit;

        If L_TradePartner.Get(P_InterimSalesLine."Trade Partner Code") then begin
            If L_TradePartner."Explode Bom" then begin
                IF KitItem.GET(P_InterimSalesLine."No.") THEN;
                KitItem.CALCFIELDS("Assembly BOM");

                IF KitItem."Assembly BOM" = TRUE THEN BEGIN

                    CLEAR(CountRec);
                    CLEAR(NoOfBOMComp);
                    CLEAR(TotalAmount);
                    LineSpacing := 1000;
                    NextLineNo := P_InterimSalesLine."Line No.";
                    FromBOMComp.RESET;
                    FromBOMComp.SETRANGE("Parent Item No.", P_InterimSalesLine."No.");
                    FromBOMComp.FINDSET;
                    NoOfBOMComp := FromBOMComp.COUNT;
                    REPEAT
                        IF FromBOMComp."Quantity per" > 0 THEN BEGIN
                            ToInterimSalesLine.INIT;
                            NextLineNo := NextLineNo + LineSpacing;
                            ToInterimSalesLine."Line No." := NextLineNo;
                            ToInterimSalesLine."Document No" := P_InterimSalesLine."Document No";
                            ToInterimSalesLine."Document Type" := P_InterimSalesLine."Document Type";
                            ToInterimSalesLine."Trade Partner Code" := P_InterimSalesLine."Trade Partner Code";
                            CASE FromBOMComp.Type OF
                                FromBOMComp.Type::" ":
                                    ToInterimSalesLine.Type := ToInterimSalesLine.Type::" ";
                                FromBOMComp.Type::Item:
                                    ToInterimSalesLine.Type := ToInterimSalesLine.Type::Item;
                                FromBOMComp.Type::Resource:
                                    ToInterimSalesLine.Type := ToInterimSalesLine.Type::Resource;
                            END;
                            IF ToInterimSalesLine.Type <> ToInterimSalesLine.Type::" " THEN BEGIN
                                FromBOMComp.TESTFIELD("No.");
                                ToInterimSalesLine.VALIDATE("No.", FromBOMComp."No.");
                                IF ToInterimSalesLine.Type = ToInterimSalesLine.Type::Item THEN BEGIN
                                    BoMItem.GET(FromBOMComp."No.");
                                    ToInterimSalesLine.VALIDATE("Unit of Measure Code", FromBOMComp."Unit of Measure Code");
                                    ToInterimSalesLine.VALIDATE(Quantity, ROUND(P_InterimSalesLine.Quantity * FromBOMComp."Quantity per"));
                                END ELSE
                                    ToInterimSalesLine.VALIDATE(Quantity, P_InterimSalesLine.Quantity * FromBOMComp."Quantity per");

                                ToInterimSalesLine.VALIDATE("Shipment Date", P_InterimSalesLine."Shipment Date");
                                CountRec += 1;
                                IF CountRec = NoOfBOMComp THEN BEGIN
                                    ToInterimSalesLine.Amount := P_InterimSalesLine.Amount - TotalAmount;
                                    ToInterimSalesLine."Amount Including VAT" := ToInterimSalesLine.Amount;
                                    ToInterimSalesLine."Unit Price" := (ToInterimSalesLine.Amount / ToInterimSalesLine.Quantity);
                                END
                                ELSE BEGIN
                                    ComponentAmount := ROUND(P_InterimSalesLine.Amount / NoOfBOMComp, 1, '=');
                                    TotalAmount := TotalAmount + ComponentAmount;
                                    ToInterimSalesLine.Amount := ComponentAmount;
                                    ToInterimSalesLine."Amount Including VAT" := ToInterimSalesLine.Amount;
                                    ToInterimSalesLine."Unit Price" := (ToInterimSalesLine.Amount / ToInterimSalesLine.Quantity);
                                END;

                            END;
                            ToInterimSalesLine.Description := BoMItem.Description;
                            ToInterimSalesLine."Bom Item No." := P_InterimSalesLine."No.";
                            ToInterimSalesLine."Item Type" := ToInterimSalesLine."Item Type"::Component;
                            ToInterimSalesLine."Sell-to Customer No." := P_InterimSalesLine."Sell-to Customer No.";
                            ToInterimSalesLine.INSERT;
                        END;
                    UNTIL FromBOMComp.NEXT = 0;
                    P_InterimSalesLine."Item Type" := P_InterimSalesLine."Item Type"::Assembly;
                    P_InterimSalesLine.MODIFY;
                END ELSE BEGIN
                    P_InterimSalesLine."Item Type" := P_InterimSalesLine."Item Type"::Single;
                    P_InterimSalesLine.MODIFY;
                END;

            end;
        end;

    end;


    procedure CheckOrderNotExist(P_ChannelCode: Code[20]; P_ChannelOrderId: Code[50]): Boolean
    //Code to check if channel order id already exists in interim sales header or Handled interim sales header 
    var
        L_InterimSalesH: Record "Interim Sales Header";
        L_HandeltedInterimSalesH: Record "Handled Interim Sales Header";
    begin
        L_InterimSalesH.RESET;
        L_InterimSalesH.SETRANGE("Trade Partner Code", P_ChannelCode);
        L_InterimSalesH.SETRANGE("Channel Order ID", P_ChannelOrderId);
        IF L_InterimSalesH.FINDFIRST THEN BEGIN
            EXIT(FALSE);
        END;

        L_HandeltedInterimSalesH.RESET;
        L_HandeltedInterimSalesH.SETRANGE("Trade Partner Code", P_ChannelCode);
        L_HandeltedInterimSalesH.SETRANGE("Channel Order ID", P_ChannelOrderId);
        IF L_HandeltedInterimSalesH.FINDFIRST THEN BEGIN
            EXIT(FALSE);
        END;

        EXIT(TRUE);
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
    begin
        IF P_InterimSalesHeader."Document Type" <> P_InterimSalesHeader."Document Type"::Quote THEN BEGIN

            if P_InterimSalesHeader.status in [P_InterimSalesHeader.status::Cancelled, P_InterimSalesHeader.status::Processing] then
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
                    P_InterimSalesHeader."Child Client ID" := L_ShippingRule."Child Client Id";
                    P_InterimSalesHeader."Child Client Name" := L_ShippingRule."Child Client Name";
                    //end;
                    //If Available on Shipping Rule Child Id and Name Get map For Hermes US-8196--

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

                    //If Available on Shipping Rule Child Id and Name Get map For Hermes US-8196++
                    if ((P_InterimSalesHeader."Child Client ID" = '') or (P_InterimSalesHeader."Child Client Name" = '')) then begin
                        GetNavShippingAgentFromWebShipping(P_InterimSalesHeader."Trade Partner Code", P_InterimSalesHeader."Web Shipping Agent", P_InterimSalesHeader."Web Shipment Method", L_shippingRule);
                        P_InterimSalesHeader."Child Client ID" := L_ShippingRule."Child Client Id";
                        P_InterimSalesHeader."Child Client Name" := L_ShippingRule."Child Client Name";
                    end;
                    //If Available on Shipping Rule Child Id and Name Get map For Hermes US-8196--

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
                P_InterimSalesHeader.status := P_InterimSalesHeader.status::Confirmed;
                P_InterimSalesHeader."Total Weight" := CalculateWeight(P_InterimSalesHeader);
                // P_InterimSalesHeader.Modify();
            end Else begin
                P_InterimSalesHeader.status := P_InterimSalesHeader.status::"In Progress";
                P_InterimSalesHeader."Total Weight" := CalculateWeight(P_InterimSalesHeader);
                //P_InterimSalesHeader.Modify();
            end;
            P_InterimSalesHeader.Modify();
            //Paarth D Dave - 8197 - On Status In progress create Assembly Order ---- Start
            P_InterimSalesHeader.CalcFields("Assemply Order", "Pstd. Assembly Order", "Assembly Order Created");
            If (P_InterimSalesHeader."Assemply Order" = true) and (P_InterimSalesHeader."Pstd. Assembly Order" = false) then begin
                CreateAssemblyOrderForCushionItems(P_InterimSalesHeader, L_InterimSalesLine);
            end;
            //Paarth D Dave - 8197 - On Status In progress create Assembly Order ---- End
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
        if P_InterimSalesHeader.status <> P_InterimSalesHeader.status::Confirmed then begin
            P_InterimSalesHeader.Status := P_InterimSalesHeader.Status::Confirmed;
            P_InterimSalesHeader.MODIFY;
        end;
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
                P_InterimSalesLine.Weight := (GetWeightFromItemUoM(P_InterimSalesLine."No.", P_InterimSalesLine."Unit of Measure Code") * P_InterimSalesLine.Quantity);

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

            //Code to Check Available Item Inventory++
            GeneralSetupChannel.Get();
            if GeneralSetupChannel."Allocate Web Orders" = true then begin
                CLEAR(AvailableInventory);
                Clear(LowestQuantity);
                Counter := 0;

                L_ItemCategory.Reset();
                L_ItemCategory.SetRange(Code, L_Item."Item Category Code");
                if L_ItemCategory.FindFirst() then;

                if L_ItemCategory."Auto Assembly Order" = true then begin
                    BOMComponent.Reset();
                    BOMComponent.SetRange("Parent Item No.", P_InterimSalesLine."No.");
                    BOMComponent.SetRange(Type, BOMComponent.Type::Item);
                    if BOMComponent.FindSet() then begin
                        repeat
                            if Rec_Item.Get(BOMComponent."No.") then begin
                                Rec_Item.CalcFields("W/H Inventory");
                                Clear(RequiredQuantity);

                                RequiredQuantity := BOMComponent."Quantity per" * P_InterimSalesLine.Quantity;

                                if RequiredQuantity > Rec_Item."W/H Inventory" then begin
                                    InsertErrorLog('Insufficient Stock for Item ' + BOMComponent."No.", P_InterimSalesHeader);
                                    L_ErrorRecorded := true;
                                end;
                            end;
                        until BOMComponent.Next() = 0;
                    end;

                    P_InterimSalesLine.CALCFIELDS("Location Code");
                    CLEAR(ItemQuery1);
                    ItemQuery1.SETRANGE(ItemQuery1.No, P_InterimSalesLine."No.");
                    ItemQuery1.SETRANGE(ItemQuery1.Location_Filter, P_InterimSalesLine."Location Code");
                    ItemQuery1.SetFilter(ItemQuery1.Bin_Type_Filter, 'PUTPICK|PICK');

                    ItemQuery1.OPEN;
                    IF ItemQuery1.READ THEN begin
                        AvailableInventory := (ItemQuery1.W_H_Inventory) - (ItemQuery1.Qty_on_Sales_Order + ItemQuery1.Qty_on_Web_Order);
                    END;
                    ItemQuery1.CLOSE;

                    if AvailableInventory > 0 then begin
                        if P_InterimSalesLine.Quantity > AvailableInventory then begin //only error if greather than
                            InsertErrorLog('Insufficient Stock for Item ' + P_InterimSalesLine."No.", P_InterimSalesHeader);
                            L_ErrorRecorded := true;
                        end;
                    end
                    else begin
                        InsertErrorLog('Insufficient Stock for Item ' + P_InterimSalesLine."No.", P_InterimSalesHeader);
                        L_ErrorRecorded := true;
                    end;
                end
                else begin
                    P_InterimSalesLine.CALCFIELDS("Location Code");
                    CLEAR(ItemQuery1);
                    ItemQuery1.SETRANGE(ItemQuery1.No, P_InterimSalesLine."No.");
                    ItemQuery1.SETRANGE(ItemQuery1.Location_Filter, P_InterimSalesLine."Location Code");
                    ItemQuery1.SetFilter(ItemQuery1.Bin_Type_Filter, 'PUTPICK|PICK');

                    ItemQuery1.OPEN;
                    IF ItemQuery1.READ THEN begin
                        AvailableInventory := (ItemQuery1.W_H_Inventory) - (ItemQuery1.Qty_on_Sales_Order + ItemQuery1.Qty_on_Web_Order);
                    END;
                    ItemQuery1.CLOSE;

                    if AvailableInventory > 0 then begin
                        if P_InterimSalesLine.Quantity > AvailableInventory then begin
                            InsertErrorLog('Insufficient Stock for Item ' + P_InterimSalesLine."No.", P_InterimSalesHeader);
                            L_ErrorRecorded := true;
                        end;
                    end
                    else begin
                        InsertErrorLog('Insufficient Stock for Item ' + P_InterimSalesLine."No.", P_InterimSalesHeader);
                        L_ErrorRecorded := true;
                    end;
                end;
            end;
            //Code to Check Available Item Inventory--

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

    procedure GetWeightFromItemUoM(P_ItemNo: Code[20]; P_UoM: Code[10]): Decimal
    var
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
    Begin
        L_ItemUnitofMeasure.RESET;
        L_ItemUnitofMeasure.SETRANGE("Item No.", P_ItemNo);
        L_ItemUnitofMeasure.SETRANGE(Code, P_UoM);
        IF L_ItemUnitofMeasure.FINDFIRST THEN
            EXIT(L_ItemUnitofMeasure.Weight / 1000);
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

        RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::"In Progress";
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
                    InterimSalesLine."Order Status" := InterimSalesLine."Order Status"::"In Progress";
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
        P_InterimSalesHeader.Status := P_InterimSalesHeader.Status::Cancelled;
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

        // CLEAR(R80020);
        // R80020.SETTABLEVIEW(P_InterimSalesHeader);
        // R80020.USEREQUESTPAGE(FALSE);
        // R80020.SetChannelpartner(P_InterimSalesHeader."Trade Partner Code");
        // R80020.RUNMODAL();
    end;

    // procedure InsertInShipmentTracking(ISH: Record "Interim Sales Header"; Base64String: BigText)
    procedure InsertInShipmentTracking(ISH: Record "Interim Sales Header")
    var
        ShipmentTrack: Record "Shipment Tracking";
        RecShipmentTracking: Record "Shipment Tracking";
    //  bytearray: Byte;
    // memoryStr: DotNet System.IO.FileStream.'mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089';
    //Ostream: dotnet System .Io
    begin



        ShipmentTrack.INIT;
        ShipmentTrack.VALIDATE("Document Type", ISH."Document Type");
        ShipmentTrack.VALIDATE("Document No.", ISH."No.");
        ShipmentTrack.VALIDATE("Shipping Agent Code", ISH."Shipping Agent Code");
        ShipmentTrack.VALIDATE("Shipping Agent Service Code", ISH."Shipping Agent Service Code");
        ShipmentTrack.VALIDATE(Weight, ISH."Total Weight");
        ShipmentTrack.VALIDATE("Agent Shipment No.", ISH."Package Tracking No.");
        ShipmentTrack.VALIDATE("Tracking No.", ISH."Package Tracking No.");
        IF RecShipmentTracking.FINDLAST THEN
            ShipmentTrack."Entry No." := RecShipmentTracking."Entry No." + 1
        ELSE
            ShipmentTrack."Entry No." := 1;

        // IF (Base64String.LENGTH > 0) THEN BEGIN
        //     bytearray := Convert.FromBase64String(Base64String);
        //     memoryStr := memoryStr.MemoryStream(bytearray);
        //     ShipmentTrack.Label.CREATEOUTSTREAM(Ostream);
        //     memoryStr.WriteTo(Ostream);
        // END;



        ShipmentTrack.INSERT;
    end;

    procedure CreateCustomer() //Shailesh 08032021 Customer Processing
    var
        InterimCustomer: Record "Interim Customer";
        Customer: Record Customer;
        TradePartner: Record "Trade Partner";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
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


    procedure CheckPostingSetups(CustWebNo: Code[20]): Boolean //Shailesh 08032021
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

    procedure UpdateCustomer(No: Code[20]) //Shailesh 08032021
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

    procedure UpdateHandledCustomer(No: Code[20]) //Shailesh 10032021
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

    procedure RemoveDestinationDocReference(P_InterimSalesHeader: Record "Interim Sales Header"; NeedWIPValidation: Boolean)
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
        L_InterimSalesLine.SETRANGE("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);//ak 241120 added filter
        L_InterimSalesLine.SETRANGE("Scanned Date", 0DT);//ak 241120
        IF L_InterimSalesLine.FINDSET THEN
            UnAllocateWebOrderOnDeleteNew(L_InterimSalesLine, TRUE);
    end;

    procedure UnAllocateWebOrderOnDeleteNew(VAR RecInterimSalesLine: Record "Interim Sales Line"; NeedWIPValidation: Boolean)
    var
        L_WIPL: Record "Whse. Internal Pick Line";
        WSHList: Page "Warehouse Shipment List";
        filterText: Text;
        RecInterimSalesHeader: Record "Interim Sales Header";
    begin
        IF RecInterimSalesLine.FINDSET THEN
            REPEAT
                IF NeedWIPValidation THEN BEGIN
                    L_WIPL.RESET;
                    L_WIPL.SETRANGE("No.", RecInterimSalesLine."Destination Doc No.");
                    L_WIPL.SETRANGE("Item No.", RecInterimSalesLine."No.");
                    L_WIPL.SetRange("Variant Code", RecInterimSalesLine."NAV Variant code");
                    IF L_WIPL.FINDFIRST THEN
                        ERROR(STRSUBSTNO('You can not remove internal pick %1 from web order %2 because internal pick is exist in system.', L_WIPL."No.", RecInterimSalesLine."Document No"));

                    IF RecInterimSalesLine."Trolley No." <> '' THEN
                        CheckTrolleyIsClosed(RecInterimSalesLine);
                END;
                CLEAR(RecInterimSalesLine."Destination Doc. Line No");
                CLEAR(RecInterimSalesLine."Destination Doc No.");
                CLEAR(RecInterimSalesLine."Destination Doc Type");
                CLEAR(RecInterimSalesLine."Trolley No.");

                RecInterimSalesLine."Destination Doc Type" := RecInterimSalesLine."Destination Doc Type"::" ";
                RecInterimSalesLine.Reserved := FALSE;

                RecInterimSalesLine.MODIFY;
                // WSHList.AddToFilterText2(filterText, '|', '', RecInterimSalesLine."Document No");code blocked by alok
                if RecInterimSalesHeader.Get(RecInterimSalesLine."Document Type", RecInterimSalesLine."Document No") then
                    RecInterimSalesHeader.Mark(true);
            UNTIL RecInterimSalesLine.NEXT = 0;

        /*RecInterimSalesHeader.RESET;code blocked by alok
        RecInterimSalesHeader.SETRANGE("Document Type", RecInterimSalesLine."Document Type");
        RecInterimSalesHeader.SETFILTER("No.", filterText);*/
        RecInterimSalesHeader.MarkedOnly(true);
        IF RecInterimSalesHeader.FINDSET THEN
            REPEAT
                IF NOT CheckIfLineExistsWithDocNo(RecInterimSalesHeader) THEN BEGIN
                    CLEAR(RecInterimSalesHeader."Destination Doc No.");
                    CLEAR(RecInterimSalesHeader."Destination Doc Type");
                    IF NOT (RecInterimSalesHeader.Status IN [RecInterimSalesHeader.Status::"No Stock", RecInterimSalesHeader.Status::Cancelled]) THEN
                        RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::"In Progress";
                    RecInterimSalesHeader.ReservedFlag := FALSE;
                    RecInterimSalesHeader.MODIFY;
                END;
            UNTIL RecInterimSalesHeader.NEXT = 0;
    end;

    local procedure CheckIfLineExistsWithDocNo(P_InterimSalesHeader: Record "Interim Sales Header"): Boolean
    var
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE("Document Type", P_InterimSalesHeader."Document Type");
        L_InterimSalesLine.SETRANGE("Document No", P_InterimSalesHeader."No.");
        L_InterimSalesLine.SETFILTER("Destination Doc No.", '%1', P_InterimSalesHeader."Destination Doc No.");
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);
        L_InterimSalesLine.SETRANGE("Scanned Date", 0DT);
        IF L_InterimSalesLine.FINDSET THEN
            EXIT(TRUE);

    end;



    local procedure CheckTrolleyIsClosed(P_InterimSalesLine: Record "Interim Sales Line")
    var
        RegisteredWhseActivityHdr: record "Registered Whse. Activity Hdr.";
        RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        RegisteredWhseActivityLine.RESET;
        RegisteredWhseActivityLine.SETRANGE("Activity Type", RegisteredWhseActivityLine."Activity Type"::Pick);
        RegisteredWhseActivityLine.SETRANGE("Source Type", 7334);
        RegisteredWhseActivityLine.SETRANGE("Source No.", P_InterimSalesLine."Destination Doc No.");
        RegisteredWhseActivityLine.SETRANGE("Item No.", P_InterimSalesLine."No.");
        RegisteredWhseActivityLine.SETRANGE("Trolley No.", P_InterimSalesLine."Trolley No.");
        IF RegisteredWhseActivityLine.FINDFIRST THEN BEGIN
            RegisteredWhseActivityHdr.RESET;
            RegisteredWhseActivityHdr.SETRANGE(Type, RegisteredWhseActivityHdr.Type::Pick);
            RegisteredWhseActivityHdr.SETRANGE("No.", RegisteredWhseActivityLine."No.");
            IF RegisteredWhseActivityHdr.FINDFIRST THEN
                IF NOT RegisteredWhseActivityHdr."Trolley Closed" THEN
                    ERROR(STRSUBSTNO('You can not remove internal pick %1 from web order %2 because open trolley exists in system for Registered Pick %3.', P_InterimSalesLine."Destination Doc No.", P_InterimSalesLine."Document No", RegisteredWhseActivityHdr."No."))
        END;

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
    //below code is required to flow Bay no from Whse. Internal pick to warehouse poick
    [EventSubscriber(ObjectType::Table, Database::"Warehouse Activity Line", 'OnAfterTransferFromIntPickLine', '', false, false)]
    local procedure OnAfterTransferFromIntPickLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; WhseInternalPickLine: Record "Whse. Internal Pick Line");
    begin

        WarehouseActivityLine."Bay No." := WhseInternalPickLine."Bay No.";

    end;


    //Below code is to stop warehouse internal pick header deletion after posting a pick
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnBeforeUpdateWhseDocHeader', '', false, false)]
    local procedure OnBeforeUpdateWhseDocHeader(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean);
    var
        WhseInternalPickHeader: record "Whse. Internal Pick Header";
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
    begin
        if ((WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::Pick) AND (WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Place)) AND (WarehouseActivityLine."Source Type" = 7334) then begin
            IsHandled := true;
            WhseInternalPickHeader.Get(WarehouseActivityLine."Whse. Document No.");
            WhseInternalPickLine.Reset();
            WhseInternalPickLine.SetRange("No.", WarehouseActivityLine."Whse. Document No.");
            if WhseInternalPickLine.FindFirst then begin
                WhseInternalPickHeader."Document Status" := WhseInternalPickHeader.GetDocumentStatus(0);
                WhseInternalPickHeader.Modify();
            end;
        end;
    end;

    //Below code is to stop warehouse internal pick Line deletion after posting a pick
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnBeforeUpdateWhseSourceDocLine', '', false, false)]
    local procedure OnBeforeUpdateWhseSourceDocLine(var WarehouseActivityLine: Record "Warehouse Activity Line"; var IsHandled: Boolean);
    var
        WhseInternalPickLine: Record "Whse. Internal Pick Line";
    begin
        if ((WarehouseActivityLine."Activity Type" = WarehouseActivityLine."Activity Type"::Pick) AND (WarehouseActivityLine."Action Type" = WarehouseActivityLine."Action Type"::Place)) AND (WarehouseActivityLine."Source Type" = 7334) then begin
            IsHandled := true;
            begin
                WhseInternalPickLine.Get(WarehouseActivityLine."Whse. Document No.", WarehouseActivityLine."Whse. Document Line No.");
                WhseInternalPickLine."Qty. Picked (Base)" :=
                   WhseInternalPickLine."Qty. Picked (Base)" + WarehouseActivityLine."Qty. to Handle (Base)";
                if WarehouseActivityLine."Qty. per Unit of Measure" = WhseInternalPickLine."Qty. per Unit of Measure" then
                    WhseInternalPickLine."Qty. Picked" :=
                      WhseInternalPickLine."Qty. Picked" + WarehouseActivityLine."Qty. to Handle"
                else
                    WhseInternalPickLine."Qty. Picked" :=
                        Round(
                            WhseInternalPickLine."Qty. Picked" + WarehouseActivityLine."Qty. to Handle (Base)" / WarehouseActivityLine."Qty. per Unit of Measure");
                WhseInternalPickLine.Validate(
                  "Qty. Outstanding", WhseInternalPickLine."Qty. Outstanding" - WarehouseActivityLine."Qty. to Handle");
                WhseInternalPickLine.Status := WhseInternalPickLine.CalcStatusPickLine;
                WhseInternalPickLine.Modify();

            end;
        end;
    end;

    //Irshad 11052022
    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertInterimSalesHeader(var L_InterimSalesHeader: Record "Interim Sales Header")
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
        TempBlobMgmnt: Codeunit "Temp Blob";
        TempInStream: InStream;
        TempOutStream: OutStream;
        TempLabelPDF: Text;
    begin
        Clear(L_Instream);
        Clear(L_PrintText);
        Clear(EPLCommands);
        L_ShipmentTracking.Reset();
        L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
        L_ShipmentTracking.SetRange("Document No.", P_No);
        // if L_ShipmentTracking.FindFirst() then begin
        if L_ShipmentTracking.FindSet() then begin
            repeat
                //if L_ShipmentTracking."RAW Text" <> '' then begin
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
                            //  DirectPrint(IWXPrintNodePrinter.ID, 'Courier Label', penumPrintType::PDF, L_Instrem, 1);// Instream function


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
    local procedure CreateAssemblyOrderForCushionItems(var P_InterimHeader: Record "Interim Sales Header"; var P_InterimLine: Record "Interim Sales Line")
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyHeader2: Record "Assembly Header";
        AseemblyLine: Record "Assembly Line";
        Item: Record Item;
        ItemCategory: Record "Item Category";
        AssemblySetup: Record "Assembly Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        RecItem: Record Item;
    begin
        //Paarth D Dave - 8197-1 - Checking for Duplicate Assembly Order for Web Order  ---- Start
        //P_InterimLine.SetRange(Type, P_InterimLine.Type::Item);
        AssemblySetup.Get();
        If P_InterimLine.FindSet() then begin
            REPEAT
                AssemblyHeader.reset;
                AssemblyHeader.SetFilter("Description 2", '%1', P_InterimHeader."Channel Order ID");
                AssemblyHeader.SetFilter("Item No.", '%1', P_InterimLine."No.");
                AssemblyHeader.SetFilter("Channel Order Line No.", '%1', P_InterimLine."Line No.");
                If Not AssemblyHeader.FindFirst() then begin
                    AssemblyHeader2.Reset; //Paarth D Dave - 8197-1 - Checking for Duplicate Assembly Order for Web Order ---- End
                    Item.Reset();
                    Item.SetRange("No.", P_InterimLine."No.");
                    if Item.FindFirst() then begin
                        ItemCategory.Reset();
                        ItemCategory.SetRange(Code, Item."Item Category Code");
                        if ItemCategory.FindFirst() then begin
                            if ItemCategory."Auto Assembly Order" = true then begin
                                AssemblyHeader2.Init();
                                AssemblyHeader2."No." := NoSeriesManagement.GetNextNo(AssemblySetup."Assembly Order Nos.", Today, true);
                                AssemblyHeader2.Validate("Document Type", AssemblyHeader2."Document Type"::Order);
                                AssemblyHeader2.Validate("Posting Date", Today);
                                AssemblyHeader2.Validate(Status, AssemblyHeader2.Status::Open);
                                AssemblyHeader2.Insert(true);
                                AssemblyHeader2.Validate("Item No.", P_InterimLine."No.");
                                AssemblyHeader2.Validate(Quantity, P_InterimLine.Quantity);
                                AssemblyHeader2."Description 2" := P_InterimLine."Channel Order ID";
                                AssemblyHeader2."Channel Order Line No." := P_InterimLine."Line No.";
                                AssemblyHeader2.Validate(Status, AssemblyHeader2.Status::Open); //Commented Paarth D Dave - 8197 
                                AssemblyHeader2.Modify(true);

                                //Paarth D Dave - 8197-1 - Release through Codeunit ---- Start
                                Codeunit.Run(Codeunit::"Release Assembly Document", AssemblyHeader2);
                                //Paarth D Dave - 8197-1 - Release through Codeunit ---- End  
                            end;
                        end;
                    end;
                end;
            UNTIL P_InterimLine.Next = 0;
        end;
    end;

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
        L_InterimSalesLine.VALIDATE(Quantity, 1);
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

    local procedure UpdateTrackingNoForOnlyGiftCardGlLines(L_InterimSalesHeader: Record "Interim Sales Header"): Boolean
    var
        GiftCard: Boolean;
    begin
        GiftCard := true;
        G_InterimSalesLine.Reset();
        G_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
        if G_InterimSalesLine.FindSet() then begin
            repeat
                if G_InterimSalesLine.Type = G_InterimSalesLine.Type::Item then begin
                    GiftCard := false;
                end;
            until G_InterimSalesLine.Next() = 0;
            exit(GiftCard)
        end;
    end;


    //Irshad++

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeWhseActivHeaderInsert', '', false, false)]
    local procedure OnBeforeWhseActivHeaderInsert(var WarehouseActivityHeader: Record "Warehouse Activity Header")
    begin
        WarehouseActivityHeader."Created Date" := WorkDate();
    end;
    //Irshad++

    //Code to block to create pick for cancel line++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnAfterCreateWhseDocLine', '', false, false)]
    local procedure OnAfterCreateWhseDocLine(var WarehouseActivityLine: Record "Warehouse Activity Line")
    var
        WIPL: Record "Whse. Internal Pick Line";
        WAH: Record "Warehouse Activity Header";
    begin
        if WarehouseActivityLine.FindSet() then
            repeat
                WIPL.Reset();
                WIPL.SetRange("No.", WarehouseActivityLine."Source No.");
                WIPL.SetRange("Line No.", WarehouseActivityLine."Source Line No.");
                if WIPL.FindFirst() then begin
                    if WIPL."Line Status" = WIPL."Line Status"::Cancelled then
                        WarehouseActivityLine.Delete();
                end;
            until WarehouseActivityLine.Next() = 0;
        WAH.Reset();
        WAH.SetRange("No.", WarehouseActivityLine."No.");
        if WAH.FindFirst() then begin
            WAH.CalcFields("No. of Lines");
            if WAH."No. of Lines" = 0 then
                WAH.Delete();
        end;

    end;
    //Code to block to create pick for cancel line--
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnAfterWhseShptLineModify', '', true, true)]
    local procedure OnAfterWhseShptLineModify(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
        WarehouseShipmentLine.Validate("Qty. to Ship", 0);
        WarehouseShipmentLine.Modify();
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


    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Sales-Post", 'OnAfterCopyToTempLines', '', false, false)]
    local procedure OnAfterCopyToTempLines(var TempSalesLine: Record "Sales Line" temporary)
    begin
        if TempSalesLine.FindSet() then
            repeat
                if (TempSalesLine.Type = TempSalesLine.Type::"G/L Account") And (TempSalesLine."Quantity Shipped" < TempSalesLine.Quantity) And (TempSalesLine."Channel Order ID" <> '') then begin
                    TempSalesLine.Validate("Qty. to Ship", TempSalesLine.Quantity - TempSalesLine."Quantity Shipped");
                    TempSalesLine.Modify();
                end;
            until TempSalesLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeCreateActivityFromSalesLine2ShptLine', '', false, false)]
    local procedure OnBeforeCreateActivityFromSalesLine2ShptLine(WhseShptHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    var
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
    begin
        // clEAR(WarehouseShipmentHeader);
        // WarehouseShipmentHeader := WhseShptHeader;
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

    var
        bool: Boolean;
        G_InterimSalesLine: Record "Interim Sales Line";
        G_GiftBool: Boolean;
}