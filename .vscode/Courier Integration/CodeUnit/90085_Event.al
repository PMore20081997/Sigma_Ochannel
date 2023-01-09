codeunit 90085 "Events"
{
    var
        Temp_SalesHeader: Record "Sales Header" temporary;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Post Receipt", 'OnBeforePostSourceDocument', '', true, true)]
    LOCAL procedure OnBeforePostSourceDocument(VAR WhseRcptLine: Record "Warehouse Receipt Line"; PurchaseHeader: Record "Purchase Header"; SalesHeader: Record "Sales Header"; TransferHeader: Record "Transfer Header")
    var
        L_WhseRcptLine: Record "Warehouse Receipt Line";
        ItemLabel: Report "Item label";
        L_Integer: Record Integer;
        I: Integer;
    begin
        Clear(I);
        if WhseRcptLine.FindSet() then begin
            repeat
                L_WhseRcptLine.Reset();
                L_WhseRcptLine.SetRange("No.", WhseRcptLine."No.");
                L_WhseRcptLine.SetRange("Item No.", WhseRcptLine."Item No.");
                if L_WhseRcptLine.FindFirst() then begin
                    for I := 1 to L_WhseRcptLine."No. of Copies" do begin
                        Clear(ItemLabel);
                        ItemLabel.SetTableView(L_WhseRcptLine);
                        ItemLabel.UseRequestPage(false);
                        ItemLabel.Run();
                    end;
                end;
            until WhseRcptLine.Next() = 0;
        end;
    end;




    //InsertShipmentTrackingAndGenerateLabel++
    /* [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Activity-Register", 'OnBeforeCode', '', true, true)]
     local procedure OnBeforeCode(var WarehouseActivityLine: Record "Warehouse Activity Line")
     var
         WareActHeader: Record "Warehouse Activity Header";
         L_ShippingAgent: Record "Shipping Agent";
         ShipmentLabel: Report "Courier Label";
         ShipmentLabel_DHL: Report "Courier Label - DHL";
         L_ShipmentTracking: Record "Shipment Tracking";
         L_ShipmentTracking2: Record "Shipment Tracking";
         L_SalesHeader: Record "Sales Header";
     begin
         //InsertTemp++
         if WarehouseActivityLine.FindSet() then begin
             repeat
                 WareActHeader.Reset();
                 WareActHeader.SetRange("No.", WarehouseActivityLine."No.");
                 WareActHeader.SetRange(Type, WarehouseActivityLine."Activity Type");
                 if WareActHeader.FindFirst() then begin
                     //  if WareActHeader."Shipping Agent Code" <> '' then
                     InsertInTemp(WareActHeader, WarehouseActivityLine, 'LINE', WarehouseActivityLine."Line No.");
                 end;
             until WarehouseActivityLine.Next() = 0;
             WareActHeader.Reset();
             WareActHeader.SetRange("No.", WarehouseActivityLine."No.");
             WareActHeader.SetRange(Type, WarehouseActivityLine."Activity Type");
             if WareActHeader.FindFirst() then begin
                 InsertInTemp(WareActHeader, WarehouseActivityLine, 'HEADER', WarehouseActivityLine."Line No." + 1);

                 L_ShippingAgent.Reset();
                 L_ShippingAgent.SetRange(Code, WareActHeader."Shipping Agent Code");
                 if L_ShippingAgent.FindFirst() then begin
                     if L_ShippingAgent.Code <> '' then
                         Codeunit.Run(L_ShippingAgent."Procesing Codeunit", Temp_SalesHeader);
                 end;
             end;
         end;

         //GenerateLabel++
         WareActHeader.Reset();
         WareActHeader.SetRange("No.", WarehouseActivityLine."No.");
         WareActHeader.SetRange(Type, WarehouseActivityLine."Activity Type");
         if WareActHeader.FindFirst() then begin
             if WareActHeader."Shipping Agent Code" <> '' then begin
                 if WareActHeader."Shipping Agent Code" = 'APC' then begin
                     L_ShipmentTracking.Reset();
                     L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
                     L_ShipmentTracking.SetRange("Document No.", WarehouseActivityLine."Source No.");
                     L_ShipmentTracking.SetRange("Shipping Agent Code", WareActHeader."Shipping Agent Code");
                     if L_ShipmentTracking.FindSet() then begin
                         repeat
                             L_ShipmentTracking2.Reset();
                             L_ShipmentTracking2.SetRange("Shipping Agent Code", L_ShipmentTracking."Shipping Agent Code");
                             L_ShipmentTracking2.SetRange("Document No.", L_ShipmentTracking."Document No.");
                             L_ShipmentTracking2.SetRange("Tracking No.", L_ShipmentTracking."Tracking No.");
                             if L_ShipmentTracking2.FindFirst() then begin
                                 Clear(ShipmentLabel);
                                 ShipmentLabel.SetTableView(L_ShipmentTracking2);
                                 ShipmentLabel.UseRequestPage(false);
                                 ShipmentLabel.Run();
                             end;
                         until L_ShipmentTracking.Next() = 0;
                     end;
                 end else
                     if WareActHeader."Shipping Agent Code" = 'DHL' then begin
                         L_ShipmentTracking.Reset();
                         L_ShipmentTracking.SetRange("Document Type", L_ShipmentTracking."Document Type"::Order);
                         L_ShipmentTracking.SetRange("Document No.", WarehouseActivityLine."Source No.");
                         L_ShipmentTracking.SetRange("Shipping Agent Code", WareActHeader."Shipping Agent Code");
                         if L_ShipmentTracking.FindSet() then begin
                             repeat
                                 L_ShipmentTracking2.Reset();
                                 L_ShipmentTracking2.SetRange("Shipping Agent Code", L_ShipmentTracking."Shipping Agent Code");
                                 L_ShipmentTracking2.SetRange("Document No.", L_ShipmentTracking."Document No.");
                                 L_ShipmentTracking2.SetRange("Tracking No.", L_ShipmentTracking."Tracking No.");
                                 if L_ShipmentTracking2.FindFirst() then begin
                                     Clear(ShipmentLabel_DHL);
                                     ShipmentLabel_DHL.SetTableView(L_ShipmentTracking2);
                                     ShipmentLabel_DHL.UseRequestPage(false);
                                     ShipmentLabel_DHL.Run();
                                 end;
                             until L_ShipmentTracking.Next() = 0;
                         end;
                     end;
             end;
         end;
     end;*///Khan++

    local procedure InsertInTemp(WareActHeader: Record "Warehouse Activity Header"; WareActLine: Record "Warehouse Activity Line"; EntryType: Text[20]; L_No: Integer)
    var
        L_SalesHeader: Record "Sales Header";
        Location: Record Location;
        CompanyInfo: Record "Company Information";

    begin

        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("No.", WareActLine."Source No.");
        if L_SalesHeader.FindFirst() then begin
            Temp_SalesHeader.Init();

            Temp_SalesHeader."Document Type" := L_SalesHeader."Document Type";
            Temp_SalesHeader."No." := Format(L_No);
            Temp_SalesHeader."Shipment Date" := L_SalesHeader."Shipment Date";//CollectionDate
            Temp_SalesHeader."Document Date" := L_SalesHeader."Document Date";//ReadyAt"
            Temp_SalesHeader."Due Date" := L_SalesHeader."Due Date";//ClosedAt":

            Temp_SalesHeader."Shipping Agent Code" := WareActHeader."Shipping Agent Code";
            Temp_SalesHeader."Shipping Agent Service Code" := WareActHeader."Shipping Agent Service Code";//ProductCode:

            if WareActHeader."Location Code" <> '' then begin
                Location.Reset();
                Location.SetRange(Code, WareActHeader."Location Code");
                if Location.FindFirst() then begin
                    Temp_SalesHeader."Sell-to Address" := Location.Address;//AddressLine1:
                    Temp_SalesHeader."Sell-to Address 2" := Location."Address 2";//AddressLine2: 
                    Temp_SalesHeader."Sell-to Post Code" := Location."Post Code";//PostalCode:
                    Temp_SalesHeader."Sell-to City" := Location.City; //City: 
                    Temp_SalesHeader."Sell-to County" := Location.County;//County:
                    Temp_SalesHeader."Sell-to Country/Region Code" := Location."Country/Region Code";//CountryCode:
                    Temp_SalesHeader."Sell-to Contact" := Location.Contact;
                    Temp_SalesHeader."Sell-to Contact No." := Location."Phone No.";
                    Temp_SalesHeader."Sell-to E-Mail" := Location."E-Mail";
                    Temp_SalesHeader."Sell-to Customer Name" := Location.Contact;//CompanyName:
                end;
            end else begin
                CompanyInfo.Get();
                Temp_SalesHeader."Sell-to Address" := CompanyInfo.Address;//AddressLine1:
                Temp_SalesHeader."Sell-to Address 2" := CompanyInfo."Address 2";//AddressLine2: 
                Temp_SalesHeader."Sell-to Post Code" := CompanyInfo."Post Code";//PostalCode:
                Temp_SalesHeader."Sell-to City" := CompanyInfo.City; //City: 
                Temp_SalesHeader."Sell-to County" := CompanyInfo.County;//County:
                Temp_SalesHeader."Sell-to Country/Region Code" := CompanyInfo."Country/Region Code";//CountryCode:
                Temp_SalesHeader."Sell-to Contact" := CompanyInfo."Contact Name";
                Temp_SalesHeader."Sell-to Contact No." := CompanyInfo."Phone No.";
                Temp_SalesHeader."Sell-to E-Mail" := CompanyInfo."E-Mail";
            end;
            if L_SalesHeader."Ship-to Name" <> '' then
                Temp_SalesHeader."Ship-to Name" := L_SalesHeader."Ship-to Name"
            else
                Temp_SalesHeader."Ship-to Name" := L_SalesHeader."Sell-to Customer Name";

            if L_SalesHeader."Ship-to Address" <> '' then
                Temp_SalesHeader."Ship-to Address" := L_SalesHeader."Ship-to Address"
            else
                Temp_SalesHeader."Ship-to Address" := L_SalesHeader."Sell-to Address";

            if L_SalesHeader."Ship-to Address 2" <> '' then
                Temp_SalesHeader."Ship-to Address 2" := L_SalesHeader."Ship-to Address 2"
            else
                Temp_SalesHeader."Ship-to Address 2" := L_SalesHeader."Sell-to Address 2";

            if L_SalesHeader."Ship-to Post Code" <> '' then
                Temp_SalesHeader."Ship-to Post Code" := L_SalesHeader."Ship-to Post Code"
            else
                Temp_SalesHeader."Ship-to Post Code" := L_SalesHeader."Sell-to Post Code";

            if L_SalesHeader."Ship-to City" <> '' then
                Temp_SalesHeader."Ship-to City" := L_SalesHeader."Ship-to City"
            else
                Temp_SalesHeader."Ship-to City" := L_SalesHeader."Sell-to City";

            if L_SalesHeader."Ship-to County" <> '' then
                Temp_SalesHeader."Ship-to County" := L_SalesHeader."Ship-to County"
            else
                Temp_SalesHeader."Ship-to County" := L_SalesHeader."Sell-to County";

            if L_SalesHeader."Ship-to Country/Region Code" <> '' then
                Temp_SalesHeader."Ship-to Country/Region Code" := L_SalesHeader."Ship-to Country/Region Code"
            else
                Temp_SalesHeader."Ship-to Country/Region Code" := L_SalesHeader."Sell-to Country/Region Code";

            if L_SalesHeader."Ship-to Contact" <> '' then
                Temp_SalesHeader."Ship-to Contact" := L_SalesHeader."Sell-to Phone No."
            else
                Temp_SalesHeader."Ship-to Contact" := L_SalesHeader."Sell-to Phone No.";


            Temp_SalesHeader."No. Printed" := WareActHeader."No. of Boxes";//NumberOfPieces":
            Temp_SalesHeader."Invoice Discount Value" := WareActHeader."Total weight (consignment)";//Weight:
            Temp_SalesHeader."Area" := EntryType;
            Temp_SalesHeader."External Document No." := WareActLine."Source No.";
            Temp_SalesHeader.Insert();
        end;
    end;

    local procedure checkifalltrackingscanned(OrderNo: Code[20]): Boolean
    var
        ShipmentTracking: Record "Shipment Tracking";
    begin
        ShipmentTracking.Reset();
        ShipmentTracking.SetRange("Document Type", ShipmentTracking."Document Type"::Order);
        ShipmentTracking.SetRange("Document No.", OrderNo);
        ShipmentTracking.SetRange("Shipment Label Handled", false);
        if ShipmentTracking.FindFirst() then
            exit(false)
        else
            exit(true)
    end;

    local procedure PostShipment(ShipmentTracking: Record "Shipment Tracking"): Boolean
    var
        test: Codeunit 5764;
        WhseShptLine: Record "Warehouse Shipment Line";
    begin
        WhseShptLine.Reset();
        WhseShptLine.SetRange("Source No.", ShipmentTracking."Document No.");
        WhseShptLine.SetRange("Source Document", WhseShptLine."Source Document"::"Sales Order");
        WhseShptLine.SetFilter("Qty. to Ship", '<>%1', 0);
        if WhseShptLine.FindSet() then begin
            CODEUNIT.Run(CODEUNIT::"Whse.-Post Shipment(Yes/No)NEW", WhseShptLine);
            exit(true);
        end;

    end;

    local procedure CheckShipmentChargeApplicable(var P_SalesHeader: Record "Sales Header")
    var
        L_SalesLine: Record "Sales Line";
        L_ShippingAgent: Record "Shipping Agent";
        L_ShippingRule: Record "Shipping Rule";
    begin
        P_SalesHeader.CalcFields("Amount Including VAT");
        //  If P_SalesHeader."Amount Including VAT" < 200 then begin
        L_ShippingAgent.Reset();
        L_ShippingAgent.SetRange(Code, P_SalesHeader."Shipping Agent Code");
        If L_ShippingAgent.FindFirst() then begin
            L_ShippingRule.Reset();
            L_ShippingRule.SetRange("Shipping Agent", P_SalesHeader."Shipping Agent Code");
            L_ShippingRule.SetRange("Shipping Agent Service", P_SalesHeader."Shipping Agent Service Code");
            If L_ShippingRule.FindSet() then begin
                If P_SalesHeader."Amount Including VAT" < L_ShippingRule."Order Value" then begin
                    InsetrShipmentChargeLine(P_SalesHeader, L_ShippingAgent."Shipping G/L No.", L_ShippingRule."Shipping Charge");
                end Else begin
                    DeleteShippingLineIfNotApplicable(P_SalesHeader, L_ShippingAgent."Shipping G/L No.", L_ShippingRule."Shipping Charge");
                end;
            end;
        end;

        //end;
    end;

    procedure InsetrShipmentChargeLine(P_SalesHeader: Record "Sales Header"; P_ShippingGL: code[20]; P_ShippingCharge: Decimal)
    var
        L_SalesLine: Record "Sales Line";
        L_SalesLine1: Record "Sales Line";
    begin
        L_SalesLine1.Reset();
        L_SalesLine1.SetRange("Document Type", P_SalesHeader."Document Type");
        L_SalesLine1.SetRange("Document No.", P_SalesHeader."No.");
        If L_SalesLine1.FindLast() then;

        L_SalesLine.Reset();
        L_SalesLine.SetRange("Document Type", P_SalesHeader."Document Type");
        L_SalesLine.SetRange("Document No.", P_SalesHeader."No.");
        L_SalesLine.SetRange("No.", P_ShippingGL);
        If Not L_SalesLine.FindFirst() then begin
            L_SalesLine.Init();
            L_SalesLine.Validate("Document Type", L_SalesLine."Document Type"::Order);
            L_SalesLine.Validate("Document No.", P_SalesHeader."No.");
            L_SalesLine.Validate("Line No.", L_SalesLine1."Line No." + 10000);
            L_SalesLine.Validate(Type, L_SalesLine.Type::"G/L Account");
            L_SalesLine.Validate("No.", P_ShippingGL);
            L_SalesLine.Validate(Quantity, 1);
            L_SalesLine.Validate("Unit Price", P_ShippingCharge);
            L_SalesLine.Insert();
        end;
    end;

    procedure DeleteShippingLineIfNotApplicable(P_SalesHeader: Record "Sales Header"; P_ShippingGL: code[20]; P_ShippingCharge: Decimal)
    var
        L_SalesLine: Record "Sales Line";
        L_SalesLine1: Record "Sales Line";
    begin
        L_SalesLine1.Reset();
        L_SalesLine1.SetRange("Document Type", P_SalesHeader."Document Type");
        L_SalesLine1.SetRange("Document No.", P_SalesHeader."No.");
        L_SalesLine1.SetRange("No.", P_ShippingGL);
        If L_SalesLine1.FindFirst() then
            L_SalesLine1.Delete(true);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeManualReleaseSalesDoc', '', false, false)]
    local procedure OnBeforeSalesOrderRelease(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    begin
        If SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            CheckShipmentChargeApplicable(SalesHeader);
    end;

    procedure CheckIfGLLineExists(P_SalesHeader: Record "Sales Header"; P_ShippingAgent: Code[20]; P_ShippingAgentService: Code[20])
    var
        L_ShippingAgent: Record "Shipping Agent";
        L_SalesLine: Record "Sales Line";
    begin
        If L_ShippingAgent.Get(P_ShippingAgent) then begin
            L_SalesLine.Reset();
            L_SalesLine.SetRange("Document Type", P_SalesHeader."Document Type");
            L_SalesLine.SetRange("Document No.", P_SalesHeader."No.");
            L_SalesLine.SetRange("No.", L_ShippingAgent."Shipping G/L No.");
            If L_SalesLine.FindFirst() then begin
                Error('Shipping charge line exists. Please delete the line and try again..');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeValidateEvent', 'Shipping Agent Code', false, false)]
    local procedure OnBeforeValidateShippingAgentCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        CheckIfGLLineExists(Rec, xRec."Shipping Agent Code", xRec."Shipping Agent Service Code");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnBeforeValidateEvent', 'Shipping Agent Service Code', false, false)]
    local procedure OnBeforeValidateShippingAgentServiceCode(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        CheckIfGLLineExists(Rec, xRec."Shipping Agent Code", xRec."Shipping Agent Service Code");
    end;
}