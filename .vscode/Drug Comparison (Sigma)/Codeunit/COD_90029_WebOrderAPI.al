codeunit 90029 "Web Order API"
{
    trigger OnRun()
    var
        OrderInput: Text;
    begin
        CreateWebOrder(OrderInput);
    end;

    var
        InterimSalesLine: Record "Interim Sales Line" temporary; //Don't Remove temporary property
        InterimSalesHeader: Record "Interim Sales Header" temporary; //Don't Remove temporary property
        ShipmentTracking: Record "Shipment Tracking" temporary; //Don't Remove temporary property
        PaymentDetails: Record "Channel Media" temporary; //Don't Remove temporary property

    procedure CreateWebOrder(orderInput: Text) Response: Text
    var
        OrderObject: JsonObject;
        WebOrdersArray: JsonArray;
        WebOrdersCount: Integer;
        i: Integer;
        WebOrderToken: JsonToken;
        WebOrderObject: JsonObject;
        WebOrderResponse: Text;
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
        ChannelOrderID: Text;
        ChannelCode: Text;
        CustomerNo: Code[20];
        L_Customer: Record Customer;
    begin
        Clear(OrderObject);
        if OrderObject.ReadFrom(OrderInput) then begin
            Clear(Response);
            Clear(WebOrdersArray);
            Clear(WebOrderResponse);

            if OrderObject.Contains('WebOrders') then begin
                WebOrdersArray := GetJsonToken(OrderObject, 'WebOrders').AsArray();
                WebOrdersCount := WebOrdersArray.Count;
                if WebOrdersCount > 0 then begin
                    for i := 0 to WebOrdersCount - 1 do begin
                        InterimSalesHeader.DeleteAll();
                        InterimSalesLine.DeleteAll();
                        ShipmentTracking.DeleteAll();
                        PaymentDetails.DeleteAll();

                        WebOrdersArray.Get(i, WebOrderToken);
                        WebOrderObject := WebOrderToken.AsObject();

                        Clear(ChannelOrderID);
                        if WebOrderObject.Contains('ChannelOrderId') then begin
                            ChannelOrderID := GetJsonvalue(WebOrderObject, 'ChannelOrderId').AsText();
                        end;

                        Clear(ChannelCode);
                        if WebOrderObject.Contains('ChannelCode') then begin
                            ChannelCode := GetJsonvalue(WebOrderObject, 'ChannelCode').AsText();
                        end;

                        Clear(CustomerNo);
                        if WebOrderObject.Contains('SelltoCustomerNo') then begin
                            CustomerNo := GetJsonvalue(WebOrderObject, 'SelltoCustomerNo').AsCode();
                        end;

                        if (ChannelCode <> '') and (ChannelOrderID <> '') then begin
                            if CU_WebOrderMgmt.CheckOrderNotExist(ChannelCode, ChannelOrderID) = true then begin
                                L_Customer.Reset();
                                if L_Customer.Get(CustomerNo) then begin
                                    CreateTempWebOrder(WebOrderObject, ChannelCode, ChannelOrderID, L_Customer, i);
                                    CU_WebOrderMgmt.Sigma_CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmentTracking, PaymentDetails);
                                    Commit();

                                    WebOrderResponse += StrSubstNo('%1,', GenerateOrderResponse(ChannelCode, ChannelOrderID));
                                end
                                else begin
                                    WebOrderResponse += StrSubstNo('%1,', '{"Error":"Customer does not exist"}');
                                end;
                            end
                            else begin
                                WebOrderResponse += StrSubstNo('%1,', GenerateOrderResponse(ChannelCode, ChannelOrderID));
                            end;
                        end;
                    end;
                    if WebOrderResponse <> '' then begin
                        WebOrderResponse := WebOrderResponse.TrimEnd(',');
                        Response := StrSubstNo('{"WebOrders": [%1]}', WebOrderResponse);
                    end;
                end
                else
                    Response := '{"WebOrders": []}';
            end;

            exit(Response);
        end
        else
            Error('Invalid JSON format.');
    end;

    local procedure CreateTempWebOrder(WebOrderObject: JsonObject; ChannelCode: Text; ChannelOrderID: Text; P_Customer: Record Customer; i: Integer): Text
    var
        LinesArray: JsonArray;
        LinesCount: Integer;
        j: Integer;
        LinesToken: JsonToken;
        LinesObject: JsonObject;
    begin
        #Region Insert data in temp table++++
        InterimSalesHeader.Init();
        InterimSalesHeader.Validate("Document Type", InterimSalesHeader."Document Type"::Order);
        InterimSalesHeader.Validate("No.", Format(i + 1));
        InterimSalesHeader.Validate("Trade Partner Code", ChannelCode);
        InterimSalesHeader.Validate("Channel Order ID", ChannelOrderID);
        InterimSalesHeader.Validate("Sell-to Customer No.", P_Customer."No.");
        InterimSalesHeader.Insert();

        //Lines++
        Clear(LinesArray);
        LinesArray := GetJsonToken(WebOrderObject, 'lines').AsArray();

        Clear(LinesCount);
        LinesCount := LinesArray.Count;

        if LinesCount > 0 then begin
            for j := 0 to LinesCount - 1 do begin
                LinesArray.Get(j, LinesToken);
                LinesObject := LinesToken.AsObject();

                InterimSalesLine.Init();
                InterimSalesLine.Validate("Document Type", InterimSalesLine."Document Type"::Order);
                InterimSalesLine.Validate("Document No", InterimSalesHeader."No.");
                InterimSalesLine.Validate("Line No.", j);
                InterimSalesLine.Validate(Type, InterimSalesLine.Type::Item);
                InterimSalesLine.Validate("Trade Partner Code", ChannelCode);
                InterimSalesLine.Validate("Channel Order ID", ChannelOrderID);
                InterimSalesLine.Validate("Channel Item Id", GetJsonvalue(LinesObject, 'ChannelItemId').AsText());
                InterimSalesLine.Validate("Channel SKU", GetJsonvalue(LinesObject, 'No').AsText());
                InterimSalesLine.Quantity := GetJsonvalue(LinesObject, 'Quantity').AsDecimal();
                InterimSalesLine.Insert();
            end;
        end;
        #endregion
    end;

    local procedure GenerateOrderResponse(ChannelCode: Text; ChannelOrderID: Text): Text
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        L_HandledInterimSalesH: Record "Handled Interim Sales Header";
        L_HandledInterimSalesLine: Record "Handled Interim Sales Line";
        OrderResponse: Text;
        ProductResponse: Text;
    begin
        Clear(OrderResponse);
        Clear(ProductResponse);
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.SetRange("Trade Partner Code", ChannelCode);
        L_InterimSalesHeader.SetRange("Channel Order ID", ChannelOrderID);
        if L_InterimSalesHeader.FindFirst() then begin
            L_InterimSalesLine.Reset();
            L_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
            L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
            if L_InterimSalesLine.FindSet() then begin
                repeat
                    ProductResponse += StrSubstNo('{"DocumentNo": "%1","TradePartnerCode": "%2","DocumentType": "Order",' +
                    '"Type": "%3","LineNo": %4,"No": "%5","Description": "%6","ChannelItemId": %7,"Quantity": %8,"Qty_to_Deliver": %9,' +
                    '"ReasonCode": "%10","ReasonMessage": "%11"},', L_InterimSalesLine."Document No", L_InterimSalesHeader."Trade Partner Code",
                    Format(L_InterimSalesLine.Type), L_InterimSalesLine."Line No.", L_InterimSalesLine."No.", L_InterimSalesLine.Description,
                    L_InterimSalesLine."Channel Item Id", L_InterimSalesLine.Quantity, L_InterimSalesLine."Qty. to Deliver",
                    L_InterimSalesLine."Reason Code", L_InterimSalesLine."Reason Message");
                until L_InterimSalesLine.Next() = 0;
            end;
            if ProductResponse <> '' then
                ProductResponse := ProductResponse.TrimEnd(',');

            OrderResponse := StrSubstNo('{"ChannelCode": "%1","ChannelOrderId": "%2","OrderReferenceNo": "%3",' +
            '"DocumentType": "Order","SelltoCustomerNo": "%4","DocumentDate": "%5","ReasonCode": "%6",' +
            '"ReasonMessage": "%7","lines": [%8]}', ChannelCode, ChannelOrderID, L_InterimSalesHeader."No.",
            L_InterimSalesHeader."Sell-to Customer No.", L_InterimSalesHeader."Document Date",
            L_InterimSalesHeader."Reason Code", L_InterimSalesHeader."Reason Message", ProductResponse);
        end
        else begin
            L_HandledInterimSalesH.Reset();
            L_HandledInterimSalesH.SetRange("Document Type", L_HandledInterimSalesH."Document Type"::Order);
            L_HandledInterimSalesH.SetRange("Trade Partner Code", ChannelCode);
            L_HandledInterimSalesH.SetRange("Channel Order ID", ChannelOrderId);
            IF L_HandledInterimSalesH.FindFirst() THEN BEGIN
                L_HandledInterimSalesLine.Reset();
                L_HandledInterimSalesLine.SetRange("Document Type", L_HandledInterimSalesH."Document Type");
                L_HandledInterimSalesLine.SetRange("Document No", L_HandledInterimSalesH."No.");
                if L_HandledInterimSalesLine.FindSet() then begin
                    repeat
                        ProductResponse += StrSubstNo('{"DocumentNo": "%1","TradePartnerCode": "%2","DocumentType": "Order",' +
                        '"Type": "%3","LineNo": %4,"No": "%5","Description": "%6","ChannelItemId": %7,"Quantity": %8,"Qty_to_Deliver": %9,' +
                        '"ReasonCode": "%10","ReasonMessage": "%11"},', L_HandledInterimSalesLine."Document No", L_HandledInterimSalesH."Trade Partner Code",
                        Format(L_HandledInterimSalesLine.Type), L_HandledInterimSalesLine."Line No.", L_HandledInterimSalesLine."No.", L_HandledInterimSalesLine.Description,
                        L_HandledInterimSalesLine."Channel Item Id", L_HandledInterimSalesLine.Quantity, L_HandledInterimSalesLine."Qty. to Deliver",
                        L_HandledInterimSalesLine."Reason Code", L_HandledInterimSalesLine."Reason Message");
                    until L_HandledInterimSalesLine.Next() = 0;
                end;
                if ProductResponse <> '' then
                    ProductResponse := ProductResponse.TrimEnd(',');

                OrderResponse := StrSubstNo('{"ChannelCode": "%1","ChannelOrderId": "%2","OrderReferenceNo": "%3",' +
                '"DocumentType": "Order","SelltoCustomerNo": "%4","DocumentDate": "%5","ReasonCode": "%6",' +
                '"ReasonMessage": "%7","lines": [%8]}', ChannelCode, ChannelOrderID, L_HandledInterimSalesH."No.",
                L_HandledInterimSalesH."Sell-to Customer No.", L_HandledInterimSalesH."Document Date",
                L_HandledInterimSalesH."Reason Code", L_HandledInterimSalesH."Reason Message", ProductResponse);
            END;
        end;

        exit(OrderResponse);
    end;

    procedure GetJsonToken(var JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then;
    end;

    procedure GetJsonvalue(var aJsonObject: JsonObject; TokenKey: text) aJsonValue: JsonValue;
    var
        aJsonToken: JsonToken;
    begin
        if not aJsonObject.Get(TokenKey, aJsonToken) then
            Error('Could not find a token with key %1', TokenKey)
        Else
            aJsonValue := aJsonToken.AsValue();
    end;
}