codeunit 90067 "Drug Comparison API"
{
    trigger OnRun()
    var
        L_OrderMessage: BigText;
    begin
        // Clear(L_OrderMessage);
        // L_OrderMessage.AddText('<OrderMessage><Header><orderReferenceNo>SO_01</orderReferenceNo><customerNo>107</customerNo></Header><Line><ProductCode>1113596</ProductCode><Quantity>200</Quantity><LineNo>1</LineNo></Line></OrderMessage>');
        // CreateOrder(L_OrderMessage);
    end;

    var
        myInt: Integer;
        G_ErrorRecorded: Boolean;
        G_InterimSalesLine: Record "Interim Sales Line";

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
    begin
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


                //Create Order++
                CreateOrder_Process(L_orderReferenceNo, L_Customer, L_ProductCode, L_OrderQuantity, L_DataPlasLineNo)
            end;


            //Update "Ready to Process" field for job Queue++
            L_InstremSalesHeader.Reset();
            L_InstremSalesHeader.SetRange("Document Type", L_InstremSalesHeader."Document Type"::Order);
            L_InstremSalesHeader.SetRange("No.", L_orderReferenceNo);
            if L_InstremSalesHeader.FindFirst() then begin
                if L_InstremSalesHeader.status = L_InstremSalesHeader.status::"In Progress" then begin
                    L_InstremSalesHeader."Ready to Process" := true;
                    L_InstremSalesHeader.Modify();
                end;
            end;

            //Send Response per order++
            OrderResponse := GenerateResponse(L_orderReferenceNo);

        end;




    end;

    local procedure GenerateResponse(_orderReferenceNo: Code[20]): BigText
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";

    begin

    end;


    Local procedure CreateOrder_Process(OrderReferenceNo: Text; CustomerNo: Text; Itemno: Code[20]; Qty: Decimal; _DataPlastLineNo: Integer)
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
        L_TradePartner: Record "Trade Partner";
        L_ShiptoAddress: Record "Ship-to Address";
        //WareningManagemnet: Codeunit "Warning Management";
        BillToCustomer: Record Customer;
    begin
        L_InterimSalesHeader.Reset();
        //L_InterimSalesHeader.SetRange("External Document No.", OrderReferenceNo);
        L_InterimSalesHeader.SetRange("No.", OrderReferenceNo);
        if not L_InterimSalesHeader.FindFirst() then begin
            //Insert Interim Sales Header+++
            GeneralSetup.Get;
            GeneralSetup.TestField("Web Order Nos");

            L_InterimSalesHeader.INIT;
            L_InterimSalesHeader."Document Type" := L_InterimSalesHeader."Document Type"::Order;
            //L_InterimSalesHeader."No." := NoSeriesManagement.GetNextNo(GeneralSetup."Web Order Nos", TODAY, TRUE);
            L_InterimSalesHeader."No." := OrderReferenceNo;
            L_InterimSalesHeader.Validate("Sell-to Customer No.", CustomerNo);
            L_InterimSalesHeader.VALIDATE(Status, L_InterimSalesHeader.Status::"In Progress");
            L_InterimSalesHeader.Validate("Trade Partner Code", 'DataPlast');
            L_InterimSalesHeader.validate("Document Date", WorkDate());
            L_InterimSalesHeader.Validate("Order Date", WorkDate);
            L_InterimSalesHeader.Validate("Channel Order ID", OrderReferenceNo);

            if (CustomerNo <> '') then begin
                if SellToCustomer.GET(CustomerNo) then begin
                    //Insert Sell-to Customer Details++ 
                    L_InterimSalesHeader.VALIDATE("Sell-to Customer No.", SellToCustomer."No.");
                    L_InterimSalesHeader.VALIDATE(Address, SellToCustomer.Address);
                    L_InterimSalesHeader.VALIDATE("Address 2", SellToCustomer."Address 2");
                    L_InterimSalesHeader.VALIDATE(City, SellToCustomer.City);
                    L_InterimSalesHeader.VALIDATE("Post Code", SellToCustomer."Post Code");
                    L_InterimSalesHeader.VALIDATE("Sell to Country", SellToCustomer."Country/Region Code");
                    //L_InterimSalesHeader.Validate("Sell to County", SellToCustomer.County);
                    if SellToCustomer."Location Code" <> '' then
                        L_InterimSalesHeader.validate("Location Code", SellToCustomer."Location Code")
                    else begin
                        L_TradePartner.Reset();
                        L_TradePartner.SetRange(Code, 'DataPlast');
                        if L_TradePartner.FindFirst() then
                            L_InterimSalesHeader.Validate("Location Code", L_TradePartner.Location);
                    end;
                    //L_InterimSalesHeader.Validate("MultiLine Order No.", P_InterimSalesHeader."MultiLine Order No.");


                    //Insert Ship-to details++
                    //Using Default Customer for dataplast++
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

                    //    //Set Customer Posting Group++
                    //     if SellToCustomer."Country/Region Code" <> '' then begin
                    //         if SellToCustomer."Country/Region Code" = 'GB' then begin
                    //             L_InterimSalesHeader."Customer Posting Group" := 'DOMESTIC';
                    //         end
                    //         else begin
                    //             if CountriesRegion.Get(SellToCustomer."Country/Region Code") then begin
                    //                 if CountriesRegion."EU Country/Region Code" <> '' then begin
                    //                     L_InterimSalesHeader."Customer Posting Group" := 'EU';
                    //                 end
                    //                 else begin
                    //                     L_InterimSalesHeader."Customer Posting Group" := 'FOREIGN';
                    //                 end;
                    //             end;
                    //         end;
                    //     end;

                    if SellToCustomer.Blocked = SellToCustomer.Blocked::All then
                        L_InterimSalesHeader."Customer Blocked" := true;


                    //Insert Bill-to Customer Details++
                    //Using Default Customer for Dataplast++
                    BillToCustomer.Reset();
                    BillToCustomer.SetRange("No.", SellToCustomer."Bill-to Customer No.");
                    if BillToCustomer.FindFirst() then begin
                        L_InterimSalesHeader."Bill-to Customer No." := BillToCustomer."No.";
                        L_InterimSalesHeader."Bill- to Name" := BillToCustomer.Name;
                        //L_InterimSalesHeader."Bill-to CompanyName" := P_InterimSalesHeader."Bill-to CompanyName";
                        L_InterimSalesHeader."Bill-to County" := BillToCustomer.County;

                        if L_InterimSalesHeader."Customer Blocked" = false then begin
                            if BillToCustomer.Blocked = BillToCustomer.Blocked::All then
                                L_InterimSalesHeader."Customer Blocked" := true;
                        end;
                    end;
                end;
            end;

            L_InterimSalesHeader."Order Placed At" := CurrentDateTime;
            L_InterimSalesHeader."Order Created On" := CurrentDateTime;
            L_InterimSalesHeader."User ID" := UserId;
            L_InterimSalesHeader."External Document No." := OrderReferenceNo;
            L_InterimSalesHeader.Insert(true);


            //Insert Interim Sales Line+++
            L_InterimSalesLine.INIT;
            L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
            L_InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
            L_InterimSalesLine."Order Date" := L_InterimSalesHeader."Order Date";
            L_InterimSalesLine.VALIDATE("Trade Partner Code", L_InterimSalesHeader."Trade Partner Code");
            L_InterimSalesLine.VALIDATE("Sell-to Customer No.", L_InterimSalesHeader."Sell-to Customer No.");
            L_InterimSalesLine."Line No." := FindLastLineNo(L_InterimSalesHeader);
            L_InterimSalesLine."Line No. Dataplast" := _DataPlastLineNo;
            L_InterimSalesLine.Type := L_InterimSalesLine.Type::Item;
            L_InterimSalesLine.Validate("No.", Itemno);
            if L_Item.Get(Itemno) then;
            L_InterimSalesLine.Description := L_Item.Description;
            L_InterimSalesLine.Description2 := L_Item."Description 2";
            L_InterimSalesLine."Item Blocked" := L_Item.Blocked;
            //L_InterimSalesLine.Validate(Quantity, Qty);  //Commented UserStory(13500)
            L_InterimSalesLine.Validate(Quantity, Round(Qty, 1, '>')); //Added new

            //Check License Item and Customer combination++
            L_InterimSalesLine."License Not Valid" := WareningManagemnet.Dataplast_CheckValidity(L_InterimSalesHeader."Sell-to Customer No.", Itemno, L_InterimSalesHeader."Ship-to Post Code", 1);

            //Check Restricted Item+++
            L_RestrictItem.Reset();
            L_RestrictItem.SetRange("Source No.", L_InterimSalesHeader."Sell-to Customer No.");
            L_RestrictItem.SetRange("Source Type", L_RestrictItem."Source Type"::Customer);
            L_RestrictItem.SetRange("Item No.", Itemno);
            if not L_RestrictItem.IsEmpty then
                L_InterimSalesLine."Restricted Item" := true;



            L_InterimSalesLine.Insert(true);

            //Insert Error Log+++
            WebOrderMgt.Dataplast_OrderValidations(L_InterimSalesHeader, true);

        end else begin
            //Insert Interim Sales Line+++
            L_InterimSalesLine.INIT;
            L_InterimSalesLine."Document Type" := L_InterimSalesLine."Document Type"::Order;
            L_InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
            L_InterimSalesLine."Order Date" := L_InterimSalesHeader."Order Date";
            L_InterimSalesLine.VALIDATE("Trade Partner Code", L_InterimSalesHeader."Trade Partner Code");
            L_InterimSalesLine.VALIDATE("Sell-to Customer No.", L_InterimSalesHeader."Sell-to Customer No.");
            L_InterimSalesLine."Line No." := FindLastLineNo(L_InterimSalesHeader);
            L_InterimSalesLine."Line No. Dataplast" := _DataPlastLineNo;
            L_InterimSalesLine.Type := L_InterimSalesLine.Type::Item;
            L_InterimSalesLine.Validate("No.", Itemno);
            if L_Item.Get(Itemno) then;
            L_InterimSalesLine.Description := L_Item.Description;
            L_InterimSalesLine.Description2 := L_Item."Description 2";
            L_InterimSalesLine."Item Blocked" := L_Item.Blocked;
            //L_InterimSalesLine.Validate(Quantity, Qty);  //Commented UserStory(13500)
            L_InterimSalesLine.Validate(Quantity, Round(Qty, 1, '>')); //Added new

            //Check License Item and Customer combination++
            L_InterimSalesLine."License Not Valid" := WareningManagemnet.Dataplast_CheckValidity(L_InterimSalesHeader."Sell-to Customer No.", Itemno, L_InterimSalesHeader."Ship-to Post Code", 1);

            //Check Restricted Item+++
            L_RestrictItem.Reset();
            L_RestrictItem.SetRange("Source No.", L_InterimSalesHeader."Sell-to Customer No.");
            L_RestrictItem.SetRange("Source Type", L_RestrictItem."Source Type"::Customer);
            L_RestrictItem.SetRange("Item No.", Itemno);
            if not L_RestrictItem.IsEmpty then
                L_InterimSalesLine."Restricted Item" := true;

            L_InterimSalesLine.Insert(true);


            //Insert Error Log+++
            WebOrderMgt.Dataplast_OrderValidations(L_InterimSalesHeader, false);
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