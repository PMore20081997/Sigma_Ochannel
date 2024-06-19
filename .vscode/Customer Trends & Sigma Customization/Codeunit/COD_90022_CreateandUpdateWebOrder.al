codeunit 90022 "OC Create & Update WebOrder"
{
    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    procedure CreateAndUpdateWebOrder(_CustNumber: Code[100]; _SalesPersonCode: Code[20])
    var
        CustmerTrend: Record CustomerTrends;
        L_ExistSalesHeader: Record "Sales Header";
        L_SalesOrderCard: Page "Sales Order";
        L_SalesH: Record "Sales Header";
        L_SalesLine: Record "Sales Line";
        L_Item: Record Item;
        L_TradPartner: Record "Trade Partner";
    begin
        //Clear Variable++
        Clear(G_InterimHeaderCreated);
        Clear(G_LineNumber);

        //Delete Temp Record++
        Temp_InterimSalesHeader.Reset();
        Temp_InterimSalesHeader.DeleteAll();

        Temp_InterimSalesLine.Reset();
        Temp_InterimSalesLine.DeleteAll();

        //Get TradPartner Code++
        L_TradPartner.Reset();
        L_TradPartner.SetRange("Customer Trend Code", true);
        if L_TradPartner.FindFirst() then;

        //Make it Ready to Process++
        CustmerTrend.Reset();
        CustmerTrend.SetRange("Customer No.", _CustNumber);
        CustmerTrend.SetRange("Salesperson Code", _SalesPersonCode);
        CustmerTrend.SetFilter("Qty. to be added to SO", '<>%1', 0);
        if CustmerTrend.FindSet() then begin
            repeat
                //Create Temp
                CreatTemp_Order(CustmerTrend, L_TradPartner);
            until CustmerTrend.Next() = 0;
        end;

        //Create Web Order++
        Temp_InterimSalesHeader.Reset();
        Temp_InterimSalesLine.Reset();
        CreateWebOrder(Temp_InterimSalesHeader, Temp_InterimSalesLine, L_TradPartner);

        //Delete Customer Trends++
        //if GetLastErrorText() = '' then begin
        CustmerTrend.Reset();
        CustmerTrend.SetRange("Customer No.", _CustNumber);
        CustmerTrend.SetRange("Salesperson Code", _SalesPersonCode);
        if CustmerTrend.FindSet() then
            CustmerTrend.DeleteAll();
        //end;
    end;

    var
        Temp_InterimSalesHeader: Record "Interim Sales Header" temporary; //Dont Remove Temp propert++
        G_InterimHeaderCreated: Boolean;
        Temp_InterimSalesLine: Record "Interim Sales Line" temporary; //Dont Remove Temp propert++
        G_LineNumber: Integer;
        G_WebOrderMgt: Codeunit "Web Order Mgt";


    local procedure CreatTemp_Order(_CustomerTrends: Record CustomerTrends; _TradPartner: Record "Trade Partner")
    var
        NoSeriesManagement: Codeunit "No. Series";
    begin
        #Region Insert data in temp table++++
        G_LineNumber += 10000;

        //Header
        _TradPartner.TestField("Customer trends Order Nos");

        if G_InterimHeaderCreated = false then begin
            Temp_InterimSalesHeader.Init();
            Temp_InterimSalesHeader.Validate("Document Type", Temp_InterimSalesHeader."Document Type"::Order);
            Temp_InterimSalesHeader.Validate("No.", NoSeriesManagement.GetNextNo(_TradPartner."Customer trends Order Nos", TODAY, TRUE));
            Temp_InterimSalesHeader.Validate("Trade Partner Code", _TradPartner.Code);
            Temp_InterimSalesHeader.Validate("Channel Order ID", _TradPartner.Code);
            Temp_InterimSalesHeader.Validate("External Document No.", _TradPartner.Code);
            Temp_InterimSalesHeader.Validate("Sell-to Customer No.", _CustomerTrends."Customer No.");
            Temp_InterimSalesHeader.Validate("Salesperson Code", _CustomerTrends."Salesperson Code");
            Temp_InterimSalesHeader.Validate("File Name", '');
            Temp_InterimSalesHeader.Validate("Location Code", _CustomerTrends."Location Code");
            Temp_InterimSalesHeader.Validate("Order Date", _CustomerTrends."Order Date");
            Temp_InterimSalesHeader.Validate("Shipping Agent Code", _CustomerTrends."Shipping Agent Code");
            Temp_InterimSalesHeader.Validate("Shipping Agent Service Code", _CustomerTrends."Shipping Agent Service Code");
            Temp_InterimSalesHeader.Validate("Weekend Shipping Agent Code", _CustomerTrends."Weekend Shipping Agent Code");
            Temp_InterimSalesHeader.Validate("Weekend Ship Agent Serv Code", _CustomerTrends."Weekend Ship. Agnt. Serv. Code");
            Temp_InterimSalesHeader.Validate("Shipment Date", _CustomerTrends."Delivery Date");
            Temp_InterimSalesHeader.Validate("Ship-to Code", _CustomerTrends."Ship-to Code");
            G_InterimHeaderCreated := Temp_InterimSalesHeader.Insert();
        end;

        //Lines++
        Temp_InterimSalesLine.Reset();
        Temp_InterimSalesLine.SetRange("Document Type", Temp_InterimSalesLine."Document Type"::Order);
        Temp_InterimSalesLine.SetRange("Document No", Temp_InterimSalesHeader."No.");
        Temp_InterimSalesLine.SetRange("Line No.", G_LineNumber);
        if NOT Temp_InterimSalesLine.FindFirst() then begin
            Temp_InterimSalesLine.Init();
            Temp_InterimSalesLine.Validate("Document Type", Temp_InterimSalesLine."Document Type"::Order);
            Temp_InterimSalesLine.Validate("Document No", Temp_InterimSalesHeader."No.");
            Temp_InterimSalesLine.Validate("Line No.", G_LineNumber);
            Temp_InterimSalesLine.Validate(Type, Temp_InterimSalesLine.Type::Item);
            Temp_InterimSalesLine.Validate("Trade Partner Code", Temp_InterimSalesHeader."Trade Partner Code");
            Temp_InterimSalesLine.Validate("Channel Order ID", Temp_InterimSalesHeader."Channel Order ID");
            Temp_InterimSalesLine.Validate("Channel SKU", _CustomerTrends."Item No.");
            Temp_InterimSalesLine.Validate("No.", _CustomerTrends."Item No.");
            Temp_InterimSalesLine.Quantity := _CustomerTrends."Qty. to be added to SO";
            Temp_InterimSalesLine.Insert();
        end;
        #endregion
    end;

    local procedure CreateWebOrder(var P_InterimSalesHeader: Record "Interim Sales Header" temporary; var P_InterimSalesLine: Record "Interim Sales Line" temporary; _TradPartner: Record "Trade Partner")
    var
        NoSeriesManagement: Codeunit "No. Series - Batch";
        BillToCustomer: Record Customer;
        L_OutSTream: OutStream;
        GeneralSetup: record "General Setup - Channels";
        L_TradPartnerCode: Record "Trade Partner";
        L_InterimSalesHeader: Record "Interim Sales Header";
        SellToCustomer: Record Customer;
        L_Date: Record Date;
        L_ShiptoAddress: Record "Ship-to Address";
        WebOrderMgt: Codeunit "Web Order Mgt";
        Update_InterimSalesHeader: Record "Interim Sales Header";
        Update_InterimSalesLine: Record "Interim Sales Line";
    begin
        _TradPartner.TestField("Channel Order No. Series");

        //Insert Header++
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.Init();
        L_InterimSalesHeader.Validate("Document Type", P_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.Validate("No.", NoSeriesManagement.GetNextNo(_TradPartner."Channel Order No. Series", Today, true));
        NoSeriesManagement.SaveState();
        L_InterimSalesHeader.VALIDATE(Status, P_InterimSalesHeader.Status::Accepted);
        L_InterimSalesHeader.Validate("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesHeader.validate("Document Date", WorkDate);
        L_InterimSalesHeader.Validate("Order Date", P_InterimSalesHeader."Order Date");
        L_InterimSalesHeader.Validate("Location Code", P_InterimSalesHeader."Location Code");
        L_InterimSalesHeader.Validate("Shipping Agent Code", P_InterimSalesHeader."Shipping Agent Code");
        L_InterimSalesHeader.Validate("Shipping Agent Service Code", P_InterimSalesHeader."Shipping Agent Service Code");
        L_InterimSalesHeader.Validate("Weekend Ship Agent Serv Code", P_InterimSalesHeader."Weekend Ship Agent Serv Code");
        L_InterimSalesHeader.Validate("Shipment Date", P_InterimSalesHeader."Shipment Date");
        L_InterimSalesHeader.Validate("Ship-to Code", P_InterimSalesHeader."Ship-to Code");

        SellToCustomer.Reset();
        SellToCustomer.SetRange("No.", P_InterimSalesHeader."Sell-to Customer No.");
        if SellToCustomer.FindFirst() then begin
            L_InterimSalesHeader.VALIDATE("Sell-to Customer No.", SellToCustomer."No.");
            L_InterimSalesHeader.VALIDATE(Address, SellToCustomer.Address);
            L_InterimSalesHeader.VALIDATE("Address 2", SellToCustomer."Address 2");
            L_InterimSalesHeader.VALIDATE(City, SellToCustomer.City);
            L_InterimSalesHeader.VALIDATE("Post Code", SellToCustomer."Post Code");
            L_InterimSalesHeader.VALIDATE("Sell to Country", SellToCustomer."Country/Region Code");
            L_InterimSalesHeader.Validate("MultiLine Order No.", P_InterimSalesHeader."MultiLine Order No.");
            L_InterimSalesHeader.Validate("Shipment Method Code", SellToCustomer."Shipment Method Code");
            L_InterimSalesHeader.Validate("Customer Price Group", SellToCustomer."Customer Price Group");

            //Update Shipping Details++
            L_ShiptoAddress.Reset();
            L_ShiptoAddress.SetRange(Code, P_InterimSalesHeader."Ship-to Code");
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

            //Update Billing Details++
            BillToCustomer.Reset();
            BillToCustomer.SetRange("No.", SellToCustomer."Bill-to Customer No.");
            if BillToCustomer.FindFirst() then begin
                L_InterimSalesHeader."Bill-to Customer No." := BillToCustomer."No.";
                L_InterimSalesHeader."Bill- to Name" := BillToCustomer.Name;
                L_InterimSalesHeader."Bill-to County" := P_InterimSalesHeader."Bill-to County";
                L_InterimSalesHeader."Bill-to County" := BillToCustomer.County;
            end;
        end;

        L_InterimSalesHeader."Job Reference" := P_InterimSalesHeader."Job Reference";
        L_InterimSalesHeader."Package Tracking No." := P_InterimSalesHeader."Package Tracking No.";
        L_InterimSalesHeader."Web Shipping Agent" := P_InterimSalesHeader."Web Shipping Agent";
        L_InterimSalesHeader."Web Shipment Method" := P_InterimSalesHeader."Web Shipment Method";
        L_InterimSalesHeader."Payment Method" := P_InterimSalesHeader."Payment Method";
        L_InterimSalesHeader."Currency Code" := P_InterimSalesHeader."Currency Code";
        L_InterimSalesHeader.VALIDATE("Buyer Email", P_InterimSalesHeader."Buyer Email");
        L_InterimSalesHeader."Buyer Name" := P_InterimSalesHeader."Buyer Name";
        L_InterimSalesHeader.VALIDATE("Channel Order ID", P_InterimSalesHeader."Channel Order ID");
        L_InterimSalesHeader.VALIDATE("No. Of Parcels", P_InterimSalesHeader."No. Of Parcels");
        L_InterimSalesHeader."Earliest Delivery date" := P_InterimSalesHeader."Earliest Delivery date";
        L_InterimSalesHeader."Promised Delivery Date" := P_InterimSalesHeader."Promised Delivery Date";
        L_InterimSalesHeader."Order Placed At" := CurrentDateTime;
        L_InterimSalesHeader."Order Created On" := CurrentDateTime;
        L_InterimSalesHeader."User ID" := UserId;
        L_InterimSalesHeader."File Name" := P_InterimSalesHeader."File Name";
        L_InterimSalesHeader."External Document No." := P_InterimSalesHeader."External Document No.";
        L_InterimSalesHeader.Validate("Order Amount", P_InterimSalesHeader."Order Amount");
        L_InterimSalesHeader.Validate("Order Discount Amount", P_InterimSalesHeader."Order Discount Amount");
        L_InterimSalesHeader.Validate("Fullfillment Channel", P_InterimSalesHeader."Fullfillment Channel");
        L_InterimSalesHeader.Validate("Web Customer No.", P_InterimSalesHeader."Web Customer No.");
        L_InterimSalesHeader.Validate("Order Status", P_InterimSalesHeader."Order Status");
        L_InterimSalesHeader.Validate(order_id, P_InterimSalesHeader.order_id);
        L_InterimSalesHeader."Salesperson Code" := P_InterimSalesHeader."Salesperson Code";
        L_InterimSalesHeader."Reason Code" := 'Order Created';
        L_InterimSalesHeader."Reason Message" := 'Accepted';
        L_InterimSalesHeader."Ready to process" := true;
        L_InterimSalesHeader.Insert(True);

        //Insert Line++
        If P_InterimSalesLine.FindSet() then begin
            repeat
                InsertSalesLine(L_InterimSalesHeader, P_InterimSalesLine, _TradPartner)
            until P_InterimSalesLine.Next() = 0;
        end;

        //Update Status, Reason Code, Reason Message on Header and Line++
        // Update_InterimSalesLine.Reset();
        // Update_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
        // Update_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
        // if Update_InterimSalesLine.FindSet() then begin
        //     repeat
        //         Update_InterimSalesLine."Reason Code" := 'Order Line Created';
        //         Update_InterimSalesLine."Reason Message" := 'Successful';
        //         Update_InterimSalesLine.Modify();
        //     until Update_InterimSalesLine.Next() = 0;
        // end;
    end;

    local procedure InsertSalesLine(P_InterimSalesHeader: Record "Interim Sales Header"; P_InterimSalesLine: Record "Interim Sales Line" temporary; P_ChannelPartner: Record "Trade Partner")
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_ItemNo: Code[20];
        Rec_Item: Record Item;
        L_ItemVariant: Record "Item Variant";
        PriceListIntegration: Codeunit "Price List Integration";
        L_TradePartner: Record "Trade Partner";
    begin
        L_TradePartner.Get(P_InterimSalesHeader."Trade Partner Code");

        L_InterimSalesLine.Init();
        L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
        L_InterimSalesLine."Document No" := P_InterimSalesHeader."No.";
        L_InterimSalesLine."Order Date" := P_InterimSalesHeader."Order Date";
        L_InterimSalesLine.Validate("Trade Partner Code", P_InterimSalesHeader."Trade Partner Code");
        L_InterimSalesLine.Validate("ET Access Code", P_InterimSalesHeader."ET Access Code");
        L_InterimSalesLine.Validate("Sell-to Customer No.", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine."Line No." := G_WebOrderMgt.FindLastLineNo(P_InterimSalesHeader);
        L_InterimSalesLine.Type := L_InterimSalesLine.Type::Item;
        L_InterimSalesLine.Validate("Channel Identifier", P_InterimSalesLine."Channel Identifier");
        L_InterimSalesLine."Channel SKU" := P_InterimSalesLine."Channel SKU";
        L_InterimSalesLine."Channel Item Id" := P_InterimSalesLine."Channel Item Id";

        Clear(L_ItemNo);
        L_ItemNo := L_InterimSalesLine."Channel SKU";
        L_InterimSalesLine.Validate("No.", L_ItemNo);

        L_InterimSalesLine.Validate("Customer Price Group", P_InterimSalesHeader."Customer Price Group");
        Rec_Item.Reset();
        if Rec_Item.Get(L_ItemNo) then begin
            L_InterimSalesLine.Description := Rec_Item.Description;
            L_InterimSalesLine."Item Category Code" := Rec_Item."Item Category Code";
        end;

        L_InterimSalesLine.Description2 := P_InterimSalesLine.Description2;
        L_InterimSalesLine."NAV Variant code" := G_WebOrderMgt.GetNavVariantCode(P_InterimSalesLine."Channel SKU", P_ChannelPartner, P_InterimSalesLine."Channel Identifier", P_InterimSalesHeader."Sell-to Customer No.");
        L_InterimSalesLine.Validate(Quantity, P_InterimSalesLine.Quantity);
        L_InterimSalesLine.Validate("Unit of Measure Code", G_WebOrderMgt.FindUOM(L_InterimSalesLine."Channel SKU", P_InterimSalesLine."Channel Identifier", L_InterimSalesLine."Channel SKU"
         , L_InterimSalesLine."No.", L_InterimSalesLine."Sell-to Customer No.", P_ChannelPartner));

        if L_TradePartner."Customer Trend Code" = true then
            L_InterimSalesLine.Validate("Qty. to Deliver", P_InterimSalesLine.Quantity)
        else
            L_InterimSalesLine."Qty. to Deliver" := G_WebOrderMgt.CalculateQtyToDeliver(L_InterimSalesLine);

        L_InterimSalesLine."Channel Price" := P_InterimSalesLine."Unit Price";
        case L_TradePartner."Price Pick From" of
            L_TradePartner."Price Pick From"::"Order Source":
                L_InterimSalesLine.Validate("Unit Price", P_InterimSalesLine."Unit Price");
            L_TradePartner."Price Pick From"::"channel Price":
                G_WebOrderMgt.ItemLinePrice(L_InterimSalesLine, true);
            L_TradePartner."Price Pick From"::"Sales Price":
                PriceListIntegration.CalculateUnitPrice(P_InterimSalesHeader, L_InterimSalesLine);
        end;

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

        L_InterimSalesLine."Reason Code" := 'Order Line Created';
        L_InterimSalesLine."Reason Message" := 'Successful';

        L_InterimSalesLine.Insert(true);
    end;
}