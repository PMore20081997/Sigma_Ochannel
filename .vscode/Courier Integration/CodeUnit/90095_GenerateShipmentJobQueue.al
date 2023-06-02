codeunit 90095 "Shipment Tracking JobQueue"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        L_InterimSalesHeader: record "Interim Sales Header";
        ShipmentTracking: record "Shipment Tracking";
        ShippingRule: Record "Shipping Rule";
        Rec_ShippingAgent: Record "Shipping Agent";
        L_ChannelPartner: Record "Trade Partner";
        SecretSales: Codeunit "B&Q";
    begin
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("No of Error", 0);
        L_InterimSalesHeader.SetRange(ReservedFlag, true);
        L_InterimSalesHeader.SetFilter("Trade Partner Code", Rec."Parameter String");
        if L_InterimSalesHeader.FindSet() then begin
            repeat
                ShipmentTracking.Reset();

                ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");

                if not ShipmentTracking.FindFirst() then begin

                    Temp_SalesHeader.DeleteAll();

                    if Rec_ShippingAgent.Get(L_InterimSalesHeader."Shipping Agent Code") then begin

                        CreateTempSalesHeaderAndLine(L_InterimSalesHeader);

                        L_ChannelPartner.Reset();

                        L_ChannelPartner.SetRange(Code, L_InterimSalesHeader."Trade Partner Code");

                        if L_ChannelPartner.FindFirst() then begin

                            if L_ChannelPartner."Update Tracking Information" = true then begin

                                L_InterimSalesHeader.CalcFields("Tracking No.");

                                SecretSales.SendTrackingInformation(L_InterimSalesHeader."Shipping Agent Code", L_InterimSalesHeader."Tracking No.", L_InterimSalesHeader."Channel Order ID", L_InterimSalesHeader."Trade Partner Code");
                            end;
                        end;
                    end;
                end;
            until L_InterimSalesHeader.Next() = 0;
        end;
    end;

    procedure CreateTempSalesHeaderAndLine(P_InterimSalesHeader: Record "Interim Sales Header")
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        Item: Record Item;
        Counter: Integer;
        ShippingAgent: Record "Shipping Agent";
        RecordRef: RecordRef;
        L_InterimSalesH: record "Interim Sales Header";
    begin
        Counter := 1;
        L_InterimSalesLine.Reset();
        L_InterimSalesLine.SetRange("Document No", P_InterimSalesHeader."No.");
        L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
        if L_InterimSalesLine.FindSet() then begin
            repeat

                Temp_SalesHeader.Init;
                Temp_SalesHeader."Document Type" := P_InterimSalesHeader."Document Type";

                if Counter > 1 then begin
                    Temp_SalesHeader."No." := P_InterimSalesHeader."No." + Format(Counter);
                end
                else begin
                    Temp_SalesHeader."No." := P_InterimSalesHeader."No.";
                end;

                if P_InterimSalesHeader."Shipment Date" <> 0D then begin
                    if P_InterimSalesHeader."Shipment Date" < Today then begin
                        Temp_SalesHeader."Shipment Date" := DT2Date(CurrentDateTime);
                    end
                    else begin
                        Temp_SalesHeader."Shipment Date" := P_InterimSalesHeader."Shipment Date";
                    end;
                end
                else begin
                    Temp_SalesHeader."Shipment Date" := DT2Date(CurrentDateTime);
                end;

                Temp_SalesHeader."Document Date" := P_InterimSalesHeader."Document Date";

                //Shopdirect
                Temp_SalesHeader."Order Date" := P_InterimSalesHeader."Document Date";
                Temp_SalesHeader."Bill-to Customer No." := CopyStr(P_InterimSalesHeader."Trade Partner Code", 1, 20);
                Temp_SalesHeader."Customer Posting Group" := CopyStr(P_InterimSalesHeader."MultiLine Order No.", 1, 20);

                Temp_SalesHeader."External Document No." := P_InterimSalesHeader."External Document No.";
                Temp_SalesHeader."Applies-to ID" := P_InterimSalesHeader."Channel Order ID";

                Temp_SalesHeader."Shipping Agent Code" := P_InterimSalesHeader."Shipping Agent Code";
                Temp_SalesHeader."Shipping Agent Service Code" := CopyStr(P_InterimSalesHeader."Shipping Agent Service Code", 1, 10);

                Temp_SalesHeader."Ship-to Name" := P_InterimSalesHeader."Ship-to Name";
                Temp_SalesHeader."Ship-to Address" := P_InterimSalesHeader."Ship-to Address";
                Temp_SalesHeader."Ship-to Address 2" := CopyStr(P_InterimSalesHeader."Ship-to Address 2", 1, 35);
                Temp_SalesHeader."Ship-to City" := P_InterimSalesHeader."Ship-to City";
                Temp_SalesHeader."Ship-to Country/Region Code" := P_InterimSalesHeader."Ship-to Country/Region Code";
                Temp_SalesHeader."Ship-to Post Code" := P_InterimSalesHeader."Ship-to Post Code";

                Temp_SalesHeader."Bill-to Name" := P_InterimSalesHeader."Bill- to Name";
                Temp_SalesHeader."Bill-to Address" := P_InterimSalesHeader.Address;
                Temp_SalesHeader."Bill-to Address 2" := CopyStr(P_InterimSalesHeader."Address 2", 1, 50);
                Temp_SalesHeader."Bill-to City" := CopyStr(P_InterimSalesHeader.City, 1, 30);
                Temp_SalesHeader."Bill-to County" := P_InterimSalesHeader."Bill-to County";
                Temp_SalesHeader."Bill-to Post Code" := CopyStr(P_InterimSalesHeader."Post Code", 1, 20);
                Temp_SalesHeader."Bill-to Country/Region Code" := CopyStr(P_InterimSalesHeader."Sell to Country", 1, 10);

                Temp_SalesHeader."VAT Base Discount %" := P_InterimSalesHeader."Order Amount";
                Temp_SalesHeader."Currency Factor" := P_InterimSalesHeader."Total Weight";
                Temp_SalesHeader."Sell-to Phone No." := P_InterimSalesHeader."Ship-to Phone";
                Temp_SalesHeader."Sell-to E-Mail" := P_InterimSalesHeader."Ship-to Email";

                Temp_SalesHeader."Location Code" := P_InterimSalesHeader."Location Code";

                //For Item
                Temp_SalesHeader."Invoice Discount Value" := L_InterimSalesLine.Quantity;  //For Quantity
                Temp_SalesHeader."Prepmt. Posting Description" := L_InterimSalesLine.Description;  //For Item Description
                Temp_SalesHeader."Payment Discount %" := L_InterimSalesLine."Unit Price";  //For UnitPrice
                Temp_SalesHeader."Bill-to Name 2" := L_InterimSalesLine."Channel SKU";  //For SKU

                Item.Reset();
                Item.SetRange("No.", L_InterimSalesLine."No.");
                if Item.FindFirst() then begin
                    Temp_SalesHeader."Payment Method Code" := Item."Country/Region of Origin Code";
                end;

                Temp_SalesHeader.Insert();
                Counter := Counter + 1;
            until L_InterimSalesLine.Next() = 0;



            ShippingAgent.Reset();
            ShippingAgent.SetRange(Code, P_InterimSalesHeader."Shipping Agent Code");
            if ShippingAgent.FindFirst() then begin
                //IF not Codeunit.Run(ShippingAgent."Procesing Codeunit", Temp_SalesHeader) then begin
                IF NOT CallCourierCodeUnit(ShippingAgent."Procesing Codeunit") then begin
                    if L_InterimSalesH.Get(L_InterimSalesLine."Document Type", L_InterimSalesLine."Document No") then begin
                        L_InterimSalesH.Remarks := CopyStr(GetLastErrorText(), 1, 250);
                        //Error(StrSubstNo('in Modify  %1',L_InterimSalesH."No."));                
                        L_InterimSalesH.Modify();
                    end;
                end;

            end;
        end;
    end;

    [TryFunction]
    procedure CallCourierCodeUnit(ObjectId: Integer)
    begin
        Codeunit.Run(ObjectId, Temp_SalesHeader)
    end;

    var
        Temp_SalesHeader: Record "Sales Header" temporary;
}