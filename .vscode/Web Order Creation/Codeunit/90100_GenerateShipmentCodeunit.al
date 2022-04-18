codeunit 90100 "Auto Generate Shipment"
{
    var
        Temp_SalesHeader: Record "Sales Header" temporary;
        ISH: Record "Interim Sales Header";

    trigger OnRun()
    begin
        GenerateLabel(ISH);
    end;

    procedure GenerateLabel(P_ISH: Record "Interim Sales Header")
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        Rec_ShippingAgent: Record "Shipping Agent";
        ShipmentTracking: Record "Shipment Tracking";
    begin
        Clear(L_InterimSalesHeader);
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.SetRange("No of Error", 0);
        if P_ISH."No." <> '' then
            L_InterimSalesHeader.SetRange("No.", P_ISH."No.");
        if L_InterimSalesHeader.FindSet() then begin
            repeat
                ShipmentTracking.Reset();
                ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                if not ShipmentTracking.FindFirst() then begin
                    Rec_ShippingAgent.Reset();
                    Rec_ShippingAgent.SetRange(Code, L_InterimSalesHeader."Shipping Agent Code");
                    if Rec_ShippingAgent.FindFirst() then begin
                        CreateTempSalesHeaderAndLine(L_InterimSalesHeader);
                    end;
                end;
            until L_InterimSalesHeader.Next() = 0;
        end;
    end;

    local procedure CreateTempSalesHeaderAndLine(P_InterimSalesHeader: Record "Interim Sales Header")
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        Item: Record Item;
        Counter: Integer;
        ShippingAgent: Record "Shipping Agent";
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
                    Temp_SalesHeader."Applies-to Doc. No." := P_InterimSalesHeader."No.";
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

                Temp_SalesHeader."Shipping Agent Code" := CopyStr(P_InterimSalesHeader."Shipping Agent Code", 1, 10);
                Temp_SalesHeader."Shipping Agent Service Code" := CopyStr(P_InterimSalesHeader."Shipping Agent Service Code", 1, 10);

                Temp_SalesHeader."Ship-to Name" := P_InterimSalesHeader."Ship-to Name";
                Temp_SalesHeader."Ship-to Address" := P_InterimSalesHeader."Ship-to Address";
                Temp_SalesHeader."Ship-to Address 2" := P_InterimSalesHeader."Ship-to Address 2";
                Temp_SalesHeader."Ship-to City" := P_InterimSalesHeader."Ship-to City";
                Temp_SalesHeader."Ship-to Country/Region Code" := CopyStr(P_InterimSalesHeader."Ship-to Country/Region Code", 1, 10);
                Temp_SalesHeader."Ship-to Post Code" := P_InterimSalesHeader."Ship-to Post Code";

                Temp_SalesHeader."VAT Base Discount %" := P_InterimSalesHeader."Order Amount";
                Temp_SalesHeader."Currency Factor" := P_InterimSalesHeader."Total Weight";

                //For Item
                Temp_SalesHeader."Invoice Discount Value" := L_InterimSalesLine.Quantity;  //For Quantity
                Temp_SalesHeader."Prepmt. Posting Description" := L_InterimSalesLine.Description;  //For Item Description
                Temp_SalesHeader."Payment Discount %" := L_InterimSalesLine."Unit Price";  //For UnitPrice
                Temp_SalesHeader."Bill-to Name 2" := L_InterimSalesLine."Channel SKU";  //For SKU

                Item.Reset();
                Item.SetRange("No.", L_InterimSalesLine."Document No");
                if Item.FindFirst() then begin
                    Temp_SalesHeader."Payment Method Code" := Item."Country/Region of Origin Code";
                end;

                Temp_SalesHeader.Insert();
                Counter := Counter + 1;
            until L_InterimSalesLine.Next() = 0;

            ShippingAgent.Reset();
            ShippingAgent.SetRange(Code, P_InterimSalesHeader."Shipping Agent Code");
            if ShippingAgent.FindFirst() then begin
                Codeunit.Run(ShippingAgent."Procesing Codeunit", Temp_SalesHeader);
            end;
        end;
    end;
}