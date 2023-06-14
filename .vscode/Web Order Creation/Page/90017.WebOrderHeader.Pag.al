page 90017 "Web Order Header"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    CaptionML = ENU = 'Web Order',
                ENG = 'Web Order';
    SourceTable = "Interim Sales Header";
    PageType = Document;
    RefreshOnActivate = true;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = true;
                field("Document Type"; rec."Document Type")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("No."; rec."No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Channel Order ID"; rec."Channel Order ID")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Sell-to Customer No."; rec."Sell-to Customer No.")
                {
                    Editable = false;
                    Lookup = false;
                    ApplicationArea = all;
                }
                field("Web Customer No."; Rec."Web Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Bill- to Name"; rec."Bill- to Name")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(Address; rec.Address)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Address 2"; rec."Address 2")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field(City; rec.City)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Post Code"; rec."Post Code")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("<County>"; rec."Bill-to County")
                {
                    Editable = false;
                    Caption = 'County';
                    ApplicationArea = all;
                }
                //8862++
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    TableRelation = "Customer Posting Group".Code;
                }
                //8862--
                field("Order Date"; rec."Order Date")
                {
                    Editable = false;
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Order Placed At"; rec."Order Placed At")
                {
                    Caption = 'Order Placed On';
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Document Date"; Rec."Document Date")
                {
                    CaptionML = ENU = 'Document Date', ENG = 'Document Date';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("External Document No."; rec."External Document No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Deal ID"; rec."Deal ID")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Fullfillment Channel"; rec."Fullfillment Channel")
                {
                    Editable = false;
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Order Type"; rec."Order Type")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Order Amount"; rec."Order Amount")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Order Discount Amount"; Rec."Order Discount Amount")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Gift Order Amount"; Rec."Gift Order Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Order Amount field.';
                    Editable = false;
                }

                field("Gift Message"; rec."Gift Message")
                {
                    //  Editable = EditGiftMsg; ps
                    MultiLine = true;
                    Visible = false;
                    ApplicationArea = all;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Order Status"; Rec."Order Status")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Destination Doc Type"; Rec."Destination Doc Type")
                {
                    ApplicationArea = all;
                    Editable = false;
                    Visible = false;
                }
                field(Rec; Rec."Destination Doc No.")
                {
                    ApplicationArea = all;
                    Visible = false;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        OpenDestinationDocument(Rec);
                    end;
                }

                field("Gift Card"; Rec."Gift Card")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Card field.';
                }


                field(ReservedFlag; Rec.ReservedFlag)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Reserved';
                    ToolTip = 'This will be enable if all the web lines have Reserved Quantity';
                }

                group("Shipping Details")
                {
                    Caption = 'Shipping Details';
                    Editable = true;
                    field("Web Shipment Method"; rec."Web Shipment Method")
                    {
                        Editable = false;
                        Enabled = false;
                        Visible = true;
                        ApplicationArea = all;
                    }
                    field("Shipment Date"; rec."Shipment Date")
                    {
                        ApplicationArea = all;
                    }
                    field("Tracking No."; rec."Package Tracking No.")
                    {
                        ApplicationArea = all;
                        Editable = false;
                        CaptionML = ENU = 'Tracking No.', ENG = 'Tracking No.';
                    }
                    field(Remarks; rec.Remarks)
                    {
                        Caption = 'Shipment Remark';
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field("Total Weight"; rec."Total Weight")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                    field("Pickup Date"; rec."Pickup Date")
                    {
                        ApplicationArea = all;
                        Visible = false;
                    }
                    field("Pickup Time"; rec."Pickup Time")
                    {
                        ApplicationArea = all;
                        Visible = false;
                    }
                    field("No. of Items"; rec."No. of Items")
                    {
                        ApplicationArea = all;
                        Editable = false;
                        Caption = 'No. of Item Lines';
                    }
                    field("Total No. of Items"; Rec."Total No. of Items")
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field("No. Of Parcels"; rec."No. Of Parcels")
                    {
                        ApplicationArea = all;
                        Editable = true;

                        trigger OnValidate()
                        var
                            L_InterimSalesLine: Record "Interim Sales Line";
                            TotalItems: Integer;
                            ShippingAgentService: Record "Shipping Agent Services";
                        begin
                            if ((Rec."No." <> '') and (Rec."No. Of Parcels" <> 0)) then begin
                                TotalItems := 0;
                                L_InterimSalesLine.Reset();
                                L_InterimSalesLine.SetRange("Document No", Rec."No.");
                                L_InterimSalesLine.SetRange(Type, L_InterimSalesLine.Type::Item);
                                if L_InterimSalesLine.FindSet() then begin
                                    repeat
                                        TotalItems += L_InterimSalesLine.Quantity;
                                    until L_InterimSalesLine.Next() = 0;
                                end;

                                if TotalItems < Rec."No. Of Parcels" then begin
                                    Error('Number of Parcels cannot be greater than Total no. of Items');
                                end;

                                if ((Rec."Shipping Agent Code" <> '') and (Rec."Shipping Agent Service Code" <> '') and (Rec."Ship-to Country/Region Code" <> 'GB')) then begin
                                    ShippingAgentService.Reset();
                                    ShippingAgentService.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                                    ShippingAgentService.SetRange(Code, Rec."Shipping Agent Service Code");
                                    if ShippingAgentService.FindFirst() then begin
                                        if Rec."No. Of Parcels" > ShippingAgentService."Max. No. of Parcel" then begin
                                            Error(StrSubstNo('Number of Parcels cannot be greater than %1 for International Orders.', ShippingAgentService."Max. No. of Parcel"));
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    }
                    field("Location Code"; rec."Location Code")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                }
            }
            group(Shipping)
            {
                Caption = 'Shipping';
                field("Ship-to Name"; rec."Ship-to Name")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Buyer Name"; rec."Buyer Name")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Ship-to Address"; rec."Ship-to Address")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to Address 2"; rec."Ship-to Address 2")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to City"; rec."Ship-to City")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to Post Code"; rec."Ship-to Post Code")
                {
                    Editable = true;
                    ApplicationArea = all;
                }
                field("Ship-to County"; rec."Ship-to County")
                {
                    ApplicationArea = all;
                }
                field("Ship-to Country/Region Code"; rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = all;

                    trigger OnValidate()
                    var
                        L_Customer: Record Customer;
                        Countries: Record "Country/Region";
                    begin
                        //8862++
                        if Rec."Ship-to Country/Region Code" = 'GB' then begin
                            IF L_Customer.GET(Rec."Sell-to Customer No.") THEN;
                            Rec."Customer Posting Group" := L_Customer."Customer Posting Group";
                        end
                        else begin
                            if Countries.Get(Rec."Ship-to Country/Region Code") then begin
                                if Countries."EU Country/Region Code" <> '' then begin
                                    Rec."Customer Posting Group" := 'EU';
                                end
                                else begin
                                    Rec."Customer Posting Group" := 'FOREIGN';
                                end;
                            end;
                        end;
                        //8862--
                    end;
                }
                field("Buyer Email"; rec."Buyer Email")
                {
                    Visible = false;
                    ApplicationArea = all;
                    CaptionML = ENU = 'E-mail', ENG = 'E-mail';
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }

                field("Ship-to Phone"; Rec."Ship-to Phone")
                {
                    ApplicationArea = All;
                }

                field("Earliest Delivery date"; rec."Earliest Delivery date")
                {
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Earliest Ship Date"; rec."Earliest Ship Date")
                {
                    Visible = true;
                    ApplicationArea = all;
                }
                field("Shipment Method Code"; rec."Shipment Method Code")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Code"; rec."Shipping Agent Code")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Service Code"; rec."Shipping Agent Service Code")
                {
                    ApplicationArea = all;
                }

            }

            part("Web Header Subform"; "Web order Subpage")
            {
                ApplicationArea = all;
                SubPageLink = "Document Type" = FIELD("Document Type"), "Document No" = FIELD("No.");
                Editable = EditPage;
                UpdatePropagation = Both;
            }

        }
    }


    actions
    {
        area(processing)
        {

            action("Generate Shipment")
            {
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    ShippingRule: Record "Shipping Rule";
                    Rec_ShippingAgent: Record "Shipping Agent";
                    ShipmentTracking: Record "Shipment Tracking";
                    ProcessLabel: Codeunit "Auto Generate Shipment";
                begin
                    Clear(L_InterimSalesHeader);
                    L_InterimSalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_InterimSalesHeader);

                    L_InterimSalesHeader.SetRange("No of Error", 0);
                    L_InterimSalesHeader.SetRange(ReservedFlag, true);
                    if L_InterimSalesHeader.FindSet() then begin
                        repeat
                            ProcessLabel.GenerateLabel(L_InterimSalesHeader);
                        until L_InterimSalesHeader.Next() = 0;
                        Message('Generate Shipment Process Completed.Please check Error Text in Order if label not generated.');
                    end;
                end;
            }
            action("Eliminate Selected  Error")
            {
                Caption = 'Eliminate Selected  Error';
                Image = ErrorLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = all;
                trigger OnAction()
                begin
                    CurrPage.SETSELECTIONFILTER(InterimSalesHeader);
                    if InterimSalesHeader.FindSet() then begin
                        IF InterimSalesHeader.FIND('-') THEN
                            REPEAT
                                WebOrdMngt.OrderValidations(InterimSalesHeader);
                            UNTIL InterimSalesHeader.NEXT = 0;
                    end;
                end;
            }
            action("MarkAsZeroPrice")
            {
                Caption = 'Mark As Zero Price';
                Image = PriceAdjustment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = all;
                trigger OnAction()
                var
                    InterimSalesLine: Record "Interim Sales Line";
                begin
                    InterimSalesLine.Reset();
                    InterimSalesLine.SetRange("Document Type", InterimSalesLine."Document Type"::Order);
                    InterimSalesLine.SetRange("Document No", Rec."No.");
                    if InterimSalesLine.FindSet() then begin
                        InterimSalesLine.ModifyAll("Gift Wrap", true);
                    end;

                end;
            }
            action("Authorize price")
            {
                ApplicationArea = All;
                Visible = false;

                trigger OnAction()
                begin
                    WebOrdMngt.AuthoriseWebOrderPrice(Rec);
                end;
            }
            action("Remove MultiLine Order Ref. ShopDirect")
            {
                Caption = 'Remove MultiLine Order Ref. ShopDirect';
                Ellipsis = true;
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;
                Visible = false;
                trigger OnAction()
                begin
                    RemoveMLOrderRef();
                end;
            }
        }
        area(Navigation)
        {
            action("Payment Details")
            {
                CaptionML = ENG = 'Order Payment Details', ENU = 'Order Payment Details';
                ApplicationArea = all;
                Image = Payment;

                trigger OnAction()
                var
                    ChannelMedia: Record "Channel Media";
                    ChannelOrderId: Text;
                    ChannelOrderId1: Text;
                    Length: Integer;
                begin
                    CurrPage.SetSelectionFilter(InterimSalesHeader);
                    if InterimSalesHeader.FindSet then
                        repeat
                            ChannelOrderId += InterimSalesHeader."Channel Order ID" + '|' + '';
                        until InterimSalesHeader.Next = 0;

                    Length := STRLEN(ChannelOrderId);
                    ChannelOrderId1 := CopyStr(ChannelOrderId, 1, Length - 1);
                    ChannelMedia.ShowPaymentDetails(ChannelOrderId1, InterimSalesHeader."Channel Order ID", 0, Rec."Trade Partner Code");
                end;

            }
            action("Direct Printing Label")
            {
                ApplicationArea = All;
                Image = Print;
                Caption = 'Label Print';

                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    WebMgt: Codeunit "Web Order Mgt";
                    ShippingAgent: Record "Shipping Agent";
                    L_ShipmentTracking: Record "Shipment Tracking";
                begin
                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF L_InterimSalesHeader.FindFirst() THEN BEGIN
                        ShippingAgent.Reset();
                        ShippingAgent.SetRange(Code, L_InterimSalesHeader."Shipping Agent Code");
                        if ShippingAgent.FindFirst() then begin
                            if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
                                //RAW Printing Option Means it is For DPD EPL Label and PDF labels
                                WebMgt.SendDirectPrintRequest(L_InterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
                            end;
                            if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
                                WebMgt.SendDirectPrintRequest(L_InterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
                            end;
                        end;
                    END;
                end;
            }
            action(DeliveryNoteNew)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delivery Note';
                Image = Print;


                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    NewDeliveryNote: Report "Web Delivery Note";
                begin
                    InterimSalesHeader.RESET;
                    InterimSalesHeader.SETRANGE("No.", Rec."No.");
                    IF InterimSalesHeader.FINDSET THEN BEGIN
                        CLEAR(NewDeliveryNote);
                        NewDeliveryNote.SETTABLEVIEW(InterimSalesHeader);
                        NewDeliveryNote.RUN;
                    END;
                end;
            }
            action(ShowCustomer)
            {
                ApplicationArea = All;
                Caption = 'Show Customer';
                Image = Customer;
                RunObject = Page 21;
                RunPageLink = "No." = FIELD("Sell-to Customer No.");
            }
            action(ReOrder)
            {
                ApplicationArea = Warehouse;
                Caption = 'Re-Order';
                Image = ReturnOrder;
                ToolTip = 'Create a warehouse shipment to start a pick a ship process according to an advanced warehouse configuration.';

                trigger OnAction()
                var
                begin
                    WebOrdMngt.CopyOrder(Rec);
                end;
            }
            action("Cancel Order")
            {
                Image = CancelAllLines;
                ApplicationArea = All;


                trigger OnAction()
                var
                    RecInterimSalesLine: Record "Interim Sales Line";
                    L_InterimSalesLine: Record "Interim Sales Line"; //Prathamesh
                    InterimSalesHeader: Record "Interim Sales Header";
                begin
                    if Not (Rec.status in [rec.status::Confirmed, rec.status::"In Progress", rec.status::Cancelled]) then
                        Error('Order Status must be either Confirmed or In progress.');
                    Clear(InterimSalesHeader);
                    CurrPage.SetSelectionFilter(InterimSalesHeader);
                    if InterimSalesHeader.FindFirst() then
                        WebOrdMngt.CancelOrder(InterimSalesHeader);


                end;
            }
        }
    }

    var
        //  Delivery_Note: Report "80010"; Ps Not found 
        InterimSalesHeader: Record "Interim Sales Header";
        //   CN22: Report "90105"; Ps Not found 
        //    Delivery_Note2: Report "80011"; Ps not found 

        WebOrdMngt: Codeunit "Web Order Mgt";
        SalesHeader: Record "Sales Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";
        EditPage: Boolean;


    //Nikhil_31/05/2022_User Story 6536: Web Order edit functionality
    trigger OnOpenPage()
    var
        CU_WebOrderMgmt: Codeunit "Web Order Mgt";
    begin
        if Rec."Destination Doc No." <> '' then
            EditPage := false
        else
            EditPage := true;

        CurrPage.Update(false);
    end;
    //Nikhil_31/05/2022_User Story 6536: Web Order edit functionality

    trigger OnDeleteRecord(): Boolean
    begin
        if Rec."Destination Doc No." <> '' then
            Error('%1 Document exists. Cannot delete the order', Rec."Destination Doc No.");
    end;

    local procedure GetLastTranastionNo(): Integer
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_InterimSalesLine: Record "Interim Sales Line";
    begin
    end;

    local procedure OpenDestinationDocument(InterimSalesHeader: Record "Interim Sales Header")
    begin
        CASE InterimSalesHeader."Destination Doc Type" OF
            InterimSalesHeader."Destination Doc Type"::"Internal Pick":
                BEGIN
                    WhseInternalPickHeader.RESET;
                    WhseInternalPickHeader.SETRANGE("No.", InterimSalesHeader."Destination Doc No.");
                    IF WhseInternalPickHeader.FINDFIRST THEN
                        PAGE.RUN(7357, WhseInternalPickHeader);
                END;
            InterimSalesHeader."Destination Doc Type"::"Sales Order":
                BEGIN
                    SalesHeader.RESET;
                    SalesHeader.SETRANGE("No.", InterimSalesHeader."Destination Doc No.");
                    IF SalesHeader.FINDFIRST THEN
                        PAGE.RUN(42, SalesHeader);
                END;
        END;
    end;

    local procedure RemoveMLOrderRef()
    var
        _InterimSalesHeader: Record "Interim Sales Header";
    begin
        _InterimSalesHeader.GET(Rec."Document Type", Rec."No.");
        IF (_InterimSalesHeader."MultiLine Order No." <> '') THEN BEGIN
            _InterimSalesHeader."Old MultiLine Order No." := _InterimSalesHeader."MultiLine Order No.";
            CLEAR(_InterimSalesHeader."MultiLine Order No.");
            _InterimSalesHeader.MODIFY();
            CurrPage.UPDATE(FALSE);
        END;
    end;
}

