codeunit 90067 "Drug Comparison API"
{
    trigger OnRun()
    var
        L_OrderMessage: BigText;
    begin
        // Clear(L_OrderMessage);
        // L_OrderMessage.AddText('<OrderMessage><Header><orderReferenceNo>DC01</orderReferenceNo><customerNo>121PHAR</customerNo></Header><Line><ProductCode>000-0002</ProductCode><Quantity>1</Quantity><LineNo>1</LineNo></Line></OrderMessage>');
        // CreateOrder(L_OrderMessage);
    end;

    var
        myInt: Integer;
        G_ErrorRecorded: Boolean;
        InterimSalesLine: Record "Interim Sales Line" temporary; //Dont Remove Temporary property
        InterimSalesHeader: Record "Interim Sales Header" temporary; //Dont Remove Temporary property
        ShipmnetTracking: Record "Shipment Tracking" temporary; //Dont Remove Temporary property
        PaymentDetails: Record "Channel Media" temporary; //Dont Remove Temporary property




    //For demo++

    // Procedure _CreateOrder(OrderRequest: BigText) OrderResponse: BigText
    // var
    //     L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
    //     XmlRequestDoc: XmlDocument;
    //     Root: XmlElement;
    //     MainNode: XmlNodeList;
    //     Node: XmlNode;
    //     e: XmlElement;
    //     L_orderReferenceNo: Code[20];
    //     L_Customer: Code[20];
    //     L_ProductCode: Code[50];
    //     L_OrderQuantity: Decimal;
    //     L_DataPlasLineNo: Integer;

    //     L_InstremSalesHeader: Record "Interim Sales Header";
    //     L_InterimSalesLine: Record "Interim Sales Line";
    //     CUWebOrderMgt: Codeunit "Web Order Mgt";

    //     L_OrderMessage: BigText;
    // begin
    //     Clear(L_OrderMessage);
    //     L_OrderMessage.AddText('<OrderMessage><Header><orderReferenceNo>DC01</orderReferenceNo><customerNo>121PHAR</customerNo></Header><Line><ProductCode>000-0002</ProductCode><Quantity>1</Quantity><LineNo>1</LineNo></Line></OrderMessage>');

    //     Clear(XmlRequestDoc);
    //     Clear(G_ErrorRecorded);
    //     // OrderCreated.AddText(OrderRequest);
    //     // exit(OrderCreated);
    //     // //Send Response++
    //     // L_PartnerErrorLog.RESET;
    //     // L_PartnerErrorLog.SETRANGE("Document No.", L_orderReferenceNo);
    //     // IF L_PartnerErrorLog.FindSet() THEN begin
    //     //     OrderCreated := false;
    //     // end else begin
    //     //     OrderCreated := true;
    //     // end;
    //     // exit(OrderCreated);

    //     // Load the MessageIn into the XML variable
    //     Clear(XmlRequestDoc);
    //     XmlDocument.ReadFrom(Format(L_OrderMessage), XmlRequestDoc);
    //     Evaluate(OrderResponse, Format(XmlRequestDoc));

    //     // //Check If Empty Node++
    //     // if DocIsNull(XmlRequestDoc) then
    //     //     exit(false);

    //     // //Read Header Node++
    //     // Clear(Root);
    //     // Clear(MainNode);
    //     // Clear(Node);
    //     // Clear(e);
    //     // XmlRequestDoc.GetRoot(Root);
    //     // MainNode := Root.GetChildElements('Header');
    //     // foreach Node in MainNode do begin
    //     //     Clear(L_orderReferenceNo);
    //     //     Clear(L_Customer);
    //     //     e := Node.AsXmlElement();
    //     //     L_orderReferenceNo := GetText(e, 'orderReferenceNo');
    //     //     L_Customer := GetText(e, 'customerNo');

    //     //     //Read Line Node++
    //     //     Clear(Root);
    //     //     Clear(MainNode);
    //     //     Clear(Node);
    //     //     Clear(e);
    //     //     XmlRequestDoc.GetRoot(Root);
    //     //     MainNode := Root.GetChildElements('Line');
    //     //     foreach Node in MainNode do begin
    //     //         Clear(L_OrderQuantity);
    //     //         Clear(L_ProductCode);
    //     //         Clear(L_DataPlasLineNo);
    //     //         e := Node.AsXmlElement();

    //     //         Evaluate(L_OrderQuantity, GetText(e, 'Quantity'));
    //     //         L_ProductCode := GetText(e, 'ProductCode');
    //     //         Evaluate(L_DataPlasLineNo, GetText(e, 'LineNo'));


    //     //         //Create Temporary Order to avoid table lock error++
    //     //         CreateOrderTemporaryOrder(L_orderReferenceNo, L_Customer, L_ProductCode, L_OrderQuantity, L_DataPlasLineNo)
    //     //     end;


    //     //     // //Update "Ready to Process" field for job Queue++
    //     //     // L_InstremSalesHeader.Reset();
    //     //     // L_InstremSalesHeader.SetRange("Document Type", L_InstremSalesHeader."Document Type"::Order);
    //     //     // L_InstremSalesHeader.SetRange("No.", L_orderReferenceNo);
    //     //     // if L_InstremSalesHeader.FindFirst() then begin
    //     //     //     if L_InstremSalesHeader.status = L_InstremSalesHeader.status::"In Progress" then begin
    //     //     //         L_InstremSalesHeader."Ready to Process" := true;
    //     //     //         L_InstremSalesHeader.Modify();
    //     //     //     end;
    //     //     // end;

    //     //     //Create web order++
    //     //     InterimSalesHeader.Reset();
    //     //     InterimSalesLine.Reset();
    //     //     if InterimSalesHeader.Count > 0 then
    //     //         CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

    //     //     //Send Response per order++
    //     //     OrderResponse := GenerateResponse(L_orderReferenceNo);

    // end;

    //Description+++
    //This function accept single order++
    //we cannot read multiple order at single time because we have to send response order wise++

    Procedure CreateOrder(OrderRequest: BigText) OrderResponse: BigText
    var
        L_PartnerErrorLog: Record "Incoming/Outgoing Error Log";
        XmlRequestDoc: XmlDocument;
        Root: XmlElement;
        MainNode: XmlNodeList;
        Node: XmlNode;
        e: XmlElement;
        L_orderReferenceNo: Code[20];
        L_Customer: Code[20];
        L_ProductCode: Code[50];
        L_OrderQuantity: Decimal;
        L_DataPlasLineNo: Integer;

        L_InstremSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        CUWebOrderMgt: Codeunit "Web Order Mgt";
    begin
        InterimSalesHeader.DeleteAll();
        InterimSalesLine.DeleteAll();

        Clear(XmlRequestDoc);
        Clear(G_ErrorRecorded);
        // OrderCreated.AddText(OrderRequest);
        // exit(OrderCreated);
        // //Send Response++
        // L_PartnerErrorLog.RESET;
        // L_PartnerErrorLog.SETRANGE("Document No.", L_orderReferenceNo);
        // IF L_PartnerErrorLog.FindSet() THEN begin
        //     OrderCreated := false;
        // end else begin
        //     OrderCreated := true;
        // end;
        // exit(OrderCreated);

        // Load the MessageIn into the XML variable
        XmlDocument.ReadFrom(Format(OrderRequest), XmlRequestDoc);

        // //Check If Empty Node++
        // if DocIsNull(XmlRequestDoc) then
        //     exit(false);

        //Read Header Node++
        Clear(Root);
        Clear(MainNode);
        Clear(Node);
        Clear(e);
        XmlRequestDoc.GetRoot(Root);
        MainNode := Root.GetChildElements('Header');
        foreach Node in MainNode do begin
            Clear(L_orderReferenceNo);
            Clear(L_Customer);
            e := Node.AsXmlElement();
            L_orderReferenceNo := GetText(e, 'orderReferenceNo');
            L_Customer := GetText(e, 'customerNo');

            //Read Line Node++
            Clear(Root);
            Clear(MainNode);
            Clear(Node);
            Clear(e);
            XmlRequestDoc.GetRoot(Root);
            MainNode := Root.GetChildElements('Line');
            foreach Node in MainNode do begin
                Clear(L_OrderQuantity);
                Clear(L_ProductCode);
                Clear(L_DataPlasLineNo);
                e := Node.AsXmlElement();

                Evaluate(L_OrderQuantity, GetText(e, 'Quantity'));
                L_ProductCode := GetText(e, 'ProductCode');
                Evaluate(L_DataPlasLineNo, GetText(e, 'LineNo'));


                //Create Temporary Order to avoid table lock error++
                CreateOrderTemporaryOrder(L_orderReferenceNo, L_Customer, L_ProductCode, L_OrderQuantity, L_DataPlasLineNo)
            end;


            // //Update "Ready to Process" field for job Queue++
            // L_InstremSalesHeader.Reset();
            // L_InstremSalesHeader.SetRange("Document Type", L_InstremSalesHeader."Document Type"::Order);
            // L_InstremSalesHeader.SetRange("No.", L_orderReferenceNo);
            // if L_InstremSalesHeader.FindFirst() then begin
            //     if L_InstremSalesHeader.status = L_InstremSalesHeader.status::"In Progress" then begin
            //         L_InstremSalesHeader."Ready to Process" := true;
            //         L_InstremSalesHeader.Modify();
            //     end;
            // end;

            //Create web order++
            InterimSalesHeader.Reset();
            InterimSalesLine.Reset();
            if InterimSalesHeader.Count > 0 then
                CUWebOrderMgt.CreateWebOrder(InterimSalesHeader, InterimSalesLine, ShipmnetTracking, PaymentDetails);

            //Send Response per order++
            OrderResponse := GenerateResponse(L_orderReferenceNo);

        end;
    end;

    local procedure GenerateResponse(_orderReferenceNo: Code[20]) _OrderResponse: BigText
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        PartnerErrorLog: Record "Incoming/Outgoing Error Log";
    begin
        Clear(_OrderResponse);
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("No.", _orderReferenceNo);
        if L_InterimSalesHeader.IsEmpty then
            exit(_OrderResponse);

        //Check and Create responce++
        L_InterimSalesHeader.Reset();
        L_InterimSalesHeader.SetRange("No.", _orderReferenceNo);
        L_InterimSalesHeader.SetRange("Document Type", L_InterimSalesHeader."Document Type"::Order);
        if L_InterimSalesHeader.FindFirst() then begin
            PartnerErrorLog.RESET;
            PartnerErrorLog.SETRANGE("Document No.", _orderReferenceNo);
            IF not PartnerErrorLog.IsEmpty() THEN begin
            end else begin
                //If no Error logs++
                //Generate Header Response++


                // //Genrate Line Response++
                // L_InterimSalesLine.Reset();
                // L_InterimSalesLine.SetRange("Document No", L_InterimSalesHeader."No.");
                // L_InterimSalesLine.SetRange("Document Type", L_InterimSalesHeader."Document Type");
                // if L_InterimSalesLine.FindSet() then

            end;
        end;
    end;


    Local procedure CreateOrderTemporaryOrder(_OrderReferenceNo: Text; _CustomerNo: Text; _ItemNo: Code[20]; _Qty: Decimal; _ChannelLineNo: Integer)
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
        GeneralSetup: record "General Setup - Channels";
        NoSeriesManagement: Codeunit "No. Series";
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


    procedure DocIsNull(var _XmlDoc: XmlDocument): Boolean
    var
        NodesList: XmlNodeList;
    begin

        NodesList := _XmlDoc.GetDescendantElements();
        exit(NodesList.Count() = 0);
    end;

    procedure GetText(_e: XmlElement; Name: Text): Text
    var
        FieldNode: XmlNode;
    begin
        foreach FieldNode in _e.GetChildElements(Name) do
            exit(FieldNode.AsXmlElement().InnerText);
    end;
}