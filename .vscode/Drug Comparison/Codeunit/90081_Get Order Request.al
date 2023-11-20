codeunit 90081 "Get Order Request API"
{
    trigger OnRun()
    var
        jsonText: JsonObject;
    begin
        //Input('{"OrderReferenceNo": "Robosol_01","CustomerNo": "121PHAR","Lines": [{"LineNo": "1","ItemNo": "000-0002","Quantity": "1"},{"LineNo": "2","ItemNo": "000-1289","Quantity": "2"}]}');
    end;

    var
        myInt: Integer;
        InterimSalesLine: Record "Interim Sales Line" temporary; //Dont Remove Temporary property
        InterimSalesHeader: Record "Interim Sales Header" temporary; //Dont Remove Temporary property
        ShipmnetTracking: Record "Shipment Tracking" temporary; //Dont Remove Temporary property
        PaymentDetails: Record "Channel Media" temporary; //Dont Remove Temporary property

    procedure Input(jsonText: Text) _Response: Text
    var
        JsonObject: JsonObject;
    begin
        if not JsonObject.ReadFrom(jsonText) then
            Error('Error reading jsonText');

        //Proceed Order request and Genrate response++
        Clear(_Response);
        _Response := ReadeandProceed(JsonObject);
        exit(_Response);



    end;

    local procedure ReadeandProceed(JO: JsonObject) _Response: Text
    var
        //Header++
        L_OrderReferenceNo: Code[20];
        L_CustomerNo: Code[20];

        //Line++
        L_ProductCode: Code[50];
        L_Quantity: Decimal;
        L_LineNo: Integer;

        CUWebOrderMgt: Codeunit "Web Order Mgt";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InsterimSalesLine: Record "Interim Sales Line";
        L_OrderLevelResponse: Record "Order Level Response";

        JsonArrayLine: JsonArray;
        JsonTokenLine: JsonToken;
        JsonObjectLine: JsonObject;
        JsonObject: JsonObject;
        JsonObjectForLine: JsonObject;
    begin
        Clear(L_OrderReferenceNo);
        Clear(L_CustomerNo);
        //Read Header Details++
        L_OrderReferenceNo := GetJsonValue(JO, 'OrderReferenceNo').AsValue().AsCode();
        L_CustomerNo := GetJsonValue(JO, 'CustomerNo').AsValue().AsCode();

        //Read Line Details++
        Clear(JsonArrayLine);
        JsonArrayLine := GetJsonValue(JO, 'Lines').AsArray();
        foreach JsonTokenLine in JsonArrayLine do begin
            JsonObjectLine := JsonTokenLine.AsObject();

            Clear(L_ProductCode);
            Clear(L_Quantity);
            Clear(L_LineNo);

            L_ProductCode := GetJsonValue(JsonObjectLine, 'ItemNo').AsValue().AsCode();
            L_Quantity := GetJsonValue(JsonObjectLine, 'Quantity').AsValue().AsDecimal();
            L_LineNo := GetJsonValue(JsonObjectLine, 'LineNo').AsValue().AsInteger();

            //Create Temporary Web Order to avoid table lock error++
            CreateOrderTemporaryOrder(L_orderReferenceNo, L_CustomerNo, L_ProductCode, L_Quantity, L_LineNo);
        end;

        //Create web order++
        InterimSalesHeader.Reset();
        InterimSalesLine.Reset();
        if InterimSalesHeader.Count > 0 then
            CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);


        //Update Interim header and Interim Line Response Code and Message++
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.SetRange("Channel Order ID", L_OrderReferenceNo);
        if L_InterimSalesHeader.FindFirst() then begin
            //Header++
            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", L_InterimSalesHeader."No.");
            PartnerErrorLog.SetFilter("Item No.", '%1', '');
            PartnerErrorLog.SetCurrentKey("Sequence No.");
            PartnerErrorLog.Ascending(false);
            IF PartnerErrorLog.FindFirst() THEN begin
                L_OrderLevelResponse.Reset();
                L_OrderLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                if L_OrderLevelResponse.FindFirst() then begin
                    L_InterimSalesHeader."Reason Code" := L_OrderLevelResponse.Reason;
                    L_InterimSalesHeader."Reason Message" := L_OrderLevelResponse.Message;
                    L_InterimSalesHeader.Modify();
                end;
            end else begin
                L_InterimSalesHeader."Reason Code" := 'Order Created';
                L_InterimSalesHeader."Reason Message" := 'Accepted';
                L_InterimSalesHeader.Modify();

            end;

            //Line++
            L_InsterimSalesLine.Reset();
            L_InsterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
            L_InsterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
            if L_InsterimSalesLine.FindSet() then begin
                repeat
                    PartnerErrorLog.RESET;
                    PartnerErrorLog.SETRANGE("Document No.", L_InterimSalesHeader."No.");
                    PartnerErrorLog.SetFilter("Item No.", '<>%1', '');
                    PartnerErrorLog.SetCurrentKey("Sequence No.");
                    PartnerErrorLog.Ascending(false);
                    IF PartnerErrorLog.FindFirst() THEN begin
                        L_OrderLevelResponse.Reset();
                        L_OrderLevelResponse.SetRange("Error Code", PartnerErrorLog."Error Code");
                        if L_OrderLevelResponse.FindFirst() then begin
                            L_InsterimSalesLine."Reason Code" := L_OrderLevelResponse.Reason;
                            L_InsterimSalesLine."Reason Message" := L_OrderLevelResponse.Message;
                            L_InsterimSalesLine.Modify();
                        end;
                    end else begin
                        L_InsterimSalesLine."Reason Code" := 'Order Line Created';
                        L_InsterimSalesLine."Reason Message" := 'Successful';
                        L_InsterimSalesLine.Modify();
                    end;
                until L_InsterimSalesLine.Next() = 0;
            end;
        end;


        //Generate Response++
        Clear(_Response);
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
        L_InterimSalesHeader.SetRange("Channel Order ID", L_OrderReferenceNo);
        if L_InterimSalesHeader.FindFirst() then begin
            PartnerErrorLog.Reset();
            PartnerErrorLog.SetRange("Document No.", L_OrderReferenceNo);
            if not PartnerErrorLog.IsEmpty then begin
                //If Error++
            end else begin
                //if no error in order ++

                //Header Response+++
                Clear(JsonObject);
                JsonObject.Add('OrderNo', L_InterimSalesHeader."No.");
                JsonObject.Add('CustomerNo', L_InterimSalesHeader."Sell-to Customer No.");
                JsonObject.Add('OrderResponse', L_InterimSalesHeader."Reason Message");

                //Linse Response++
                Clear(JsonArrayLine);
                //Clear(JsonObjectForLine);
                L_InsterimSalesLine.Reset();
                L_InsterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
                L_InsterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                if L_InsterimSalesLine.FindSet() then begin
                    JsonObject.Add('Lines', JsonArrayLine);
                    repeat
                        Clear(JsonObjectForLine);
                        JsonObjectForLine.Add('LineNo', L_InsterimSalesLine."Line No.");
                        JsonObjectForLine.Add('ItemNo', L_InsterimSalesLine."No.");
                        JsonObjectForLine.Add('Quantity', L_InsterimSalesLine.Quantity);
                        JsonObjectForLine.Add('ProductResponse', 'Test1');
                        JsonArrayLine.Add(JsonObjectForLine);
                    until L_InsterimSalesLine.Next() = 0;
                end;
                JsonObject.WriteTo(_Response);
            end;
        end else begin
            _Response := 'No Order Exist';
            exit(_Response);
        end;
    end;

    local procedure GetJsonValue(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;



    Local procedure CreateOrderTemporaryOrder(_OrderReferenceNo: Text; _CustomerNo: Text; _ItemNo: Code[20]; _Qty: Decimal; _ChannelLineNo: Integer)
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        SellToCustomer: Record Customer;
        CountriesRegion: Record "Country/Region";
        L_Item: Record Item;
        WebOrderMgt: Codeunit "Web Order Mgt";
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";

        L_ShiptoAddress: Record "Ship-to Address";
        //WareningManagemnet: Codeunit "Warning Management";
        BillToCustomer: Record Customer;
        L_TradePartner: Record "Trade Partner";
    begin
        //Insert in Temporary table to avoid table locaking++
        InterimSalesHeader.Reset();
        InterimSalesHeader.SetRange("Document Type", InterimSalesHeader."Document Type"::Order);
        InterimSalesHeader.SetRange("Trade Partner Code", 'DC');
        InterimSalesHeader.SetRange("No.", _OrderReferenceNo);
        if NOT InterimSalesHeader.FindFirst() then begin
            InterimSalesHeader.Init();
            InterimSalesHeader.Validate("Document Type", InterimSalesHeader."Document Type"::Order);
            InterimSalesHeader.Validate("No.", _OrderReferenceNo);
            InterimSalesHeader.Validate("Trade Partner Code", 'DC');
            InterimSalesHeader.Validate("Channel Order ID", _OrderReferenceNo);
            InterimSalesHeader.Validate("Sell-to Customer No.", _CustomerNo);
            InterimSalesHeader.Validate("File Name", 'API');
            InterimSalesHeader.Insert();
        end;
        InterimSalesLine.Reset();
        InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
        InterimSalesLine.SetRange("Trade Partner Code", 'DC');
        InterimSalesLine.SetRange("Document No", InterimSalesHeader."No.");
        //InterimSalesLine.SetRange(Type, InterimSalesLine.Type::Item);
        //InterimSalesLine.SetRange("No.", _Itemno);
        InterimSalesLine.SetRange("Line No.", _ChannelLineNo);
        if NOT InterimSalesLine.FindFirst() then begin
            InterimSalesLine.Init();
            InterimSalesLine.Validate("Document Type", InterimSalesLine."Document Type"::Order);
            InterimSalesLine.Validate("Document No", InterimSalesHeader."No.");
            InterimSalesLine.Validate("Line No.", _ChannelLineNo);
            InterimSalesLine.Validate(Type, InterimSalesLine.Type::Item);
            InterimSalesLine.Validate("Trade Partner Code", 'DC');
            InterimSalesLine.Validate("Channel Order ID", InterimSalesHeader."Channel Order ID");
            InterimSalesLine.Validate("Channel SKU", _ItemNo); //_Item number should be SKU or ACtual Item Number
            InterimSalesLine.Quantity := _Qty;
            InterimSalesLine.Insert();
        end;


    end;
}