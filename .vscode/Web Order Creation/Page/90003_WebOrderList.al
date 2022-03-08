page 90003 "Web Order List"
{
    // version In Use

    ApplicationArea = All;//Basic, Suite, Assembly;
    CaptionML = ENU = 'Web Orders',
                ENG = 'Web Orders';
    CardPageID = "Web Order Header";
    DeleteAllowed = true;
    UsageCategory = Lists;
    Editable = true;
    PageType = List;
    RefreshOnActivate = true;
    ShowFilter = true;
    SourceTable = "Interim Sales Header";
    SourceTableView = WHERE("Document Type" = CONST(Order));
    InsertAllowed = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Old MultiLine Order No."; Rec."Old MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = all;
                }
                field("Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = all;
                    //Caption = 'Tracking No.';
                    CaptionML = ENU = 'Tracking No.', ENG = 'Tracking No.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = all;
                    Caption = 'Status';
                }

                field("Order Date"; Rec."Order Date")
                {

                    ApplicationArea = all;
                }
                // field("Process Date"; Rec."Process Date")
                // {
                //     CaptionML = ENU = 'Process Date', ENG = 'Process Date';
                //     ApplicationArea = All;
                // }
                field("Document Date"; Rec."Document Date")
                {
                    CaptionML = ENU = 'Document Date', ENG = 'Document Date';
                    ApplicationArea = All;
                }
                field("Order Created On"; rec."Order Created On")
                {
                    ApplicationArea = All;
                }
                field("No. of Items"; rec."No. of Items")
                {
                    ApplicationArea = All;
                }
                field("Destination Doc Type"; Rec."Destination Doc Type")
                {

                    ApplicationArea = all;
                }
                field(Rec; Rec."Destination Doc No.")
                {
                    ApplicationArea = all;
                    trigger OnDrillDown()
                    begin
                        OpenDestinationDocument(Rec);
                    end;
                }
                field("No of Error"; Rec."No of Error")
                {
                    ApplicationArea = all;
                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = all;
                }
                field(Remarks; Rec.Remarks)
                {
                    Visible = false;
                    ApplicationArea = all;
                }


            }
        }
    }

    actions
    {
        area(processing)
        {

            action("Eliminate Selected  Error")
            {
                Caption = 'Eliminate Selected  Error';
                Image = ErrorLog;
                Promoted = true;
                PromotedCategory = Process;
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

            action("Process Shipping Rule")
            {
                Caption = 'Process Shipping Rule';
                Image = Track;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false; //07/07/2020
                ApplicationArea = All;

                trigger OnAction()
                begin
                    REPORT.RUN(50100, TRUE, FALSE, InterimSalesHeader);
                    CurrPage.UPDATE(TRUE);
                end;
            }
            action("Payment Details")
            {
                CaptionML = ENG = 'Order Payment Details', ENU = 'Order Payment Details';
                ApplicationArea = all;
                //Promoted = true;
                //PromotedIsBig = true;
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

            action(MovetoHandled)
            {
                Caption = 'MovetoHandled';
                Ellipsis = true;
                Image = CompleteLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;
                trigger OnAction()
                var
                    R80020: Report "Move Scanned Order to Handled";
                begin
                    CLEAR(R80020);
                    //R80020.SETTABLEVIEW(Rec);
                    R80020.USEREQUESTPAGE(true);
                    R80020.RUNMODAL();

                end;
            }
            action(Process)
            {
                Caption = 'Process';
                Ellipsis = true;
                Image = CompleteLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = all;

                trigger OnAction()
                var
                begin
                    REPORT.RUN(90000, TRUE, FALSE, InterimSalesHeader);
                end;



            }

            //CourierIntegration++
            action("Generate Shipment")
            {
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    L_InterimSalesHeader: Record "Interim Sales Header";
                    ShippingRule: Record "Shipping Rule";
                    Rec_ShippingAgent: Record "Shipping Agent";
                    ShipmentTracking: Record "Shipment Tracking";
                begin
                    Clear(L_InterimSalesHeader);
                    L_InterimSalesHeader := Rec;
                    CurrPage.SetSelectionFilter(L_InterimSalesHeader);
                    // L_InterimSalesHeader.SetFilter("Destination Doc Type", '<>%1', L_InterimSalesHeader."Destination Doc Type"::"Internal Pick");
                    L_InterimSalesHeader.SetRange("No of Error", 0);
                    //L_InterimSalesHeader.SetRange("Package Tracking No.", '');
                    if L_InterimSalesHeader.FindSet() then begin
                        repeat
                            ShipmentTracking.Reset();
                            ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                            if not ShipmentTracking.FindFirst() then begin
                                Temp_SalesHeader.DeleteAll();
                                if Rec_ShippingAgent.Get(L_InterimSalesHeader."Shipping Agent Code") then begin
                                    CreateTempSalesHeaderAndLine(L_InterimSalesHeader);
                                end;
                            end;

                        // ShippingRule.Reset();
                        // ShippingRule.SetRange("Channel Code", L_InterimSalesHeader."Trade Partner Code");
                        // if ShippingRule.FindFirst() then begin
                        //     Rec_ShippingAgent.RESET;
                        //     if Rec_ShippingAgent.Get(ShippingRule."Shipping Agent") then begin
                        //         if L_InterimSalesHeader."Trade Partner Code" = Rec_ShippingAgent.Code then begin
                        //             CreateTempSalesHeaderSHOPDIRECT(L_InterimSalesHeader);
                        //         end;
                        //     end;
                        // end;

                        until L_InterimSalesHeader.Next() = 0;
                        Message('Label Generated Successfully');
                    end;
                end;
            }
            //CourierIntegration--

            //  Delete for Handled Incoming message table ++
            // action(WebOrderDelete)
            // {
            //     Promoted = true;
            //     PromotedIsBig = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = all;

            //     trigger Onaction()
            //     var
            //         myInt: Integer;
            //         Handled: Record "Handled Incoming Message";
            //         ISH: Record "Interim Sales Header";
            //         SH: Record "Sales Header";
            //     begin
            //         Clear(Rec."Sales Order No.");
            //         Rec.Modify();
            //         ISH.Reset();
            //         CurrPage.SetSelectionFilter(ISH);
            //         if ISH.FindSet() then begin
            //             repeat
            //                 SH.Reset();
            //                 SH.SetRange("External Document No.", ISH."External Document No.");
            //                 if Sh.FindFirst() then begin
            //                     repeat


            //                         Sh.Delete(true);
            //                         Rec.Delete(True);

            //                     until Sh.Next = 0;
            //                 end else
            //                     Rec.Delete(true);
            //             Until ISH.Next = 0;
            //         End;
            //     End;

            // }
            //Delete for Handled Incoming message table --
            action(DisplayLabel)
            {
                ApplicationArea = All;
                Visible = false; //07/07/2020
                Caption = 'DisplayLabel';
                Image = Process;
                Promoted = true;
                //RunObject = Page Label;
                //RunPageLink = "Agent Shipment No." = FIELD("External Document No.");

                trigger OnAction()
                var
                    myInt: Integer;
                    ISH: Record "Interim Sales Header";
                begin

                    Codeunit.Run(50110, InterimSalesHeader);

                end;

            }
            action("Dispatch Scanning")
            {
                Caption = 'Dispatch Scanning';
                Promoted = true;
                Visible = false;//07/07/2020
                ApplicationArea = All;
                trigger OnAction()
                var
                    myInt: Integer;
                    ISH: Record "Interim Sales Header";
                //DispatchScan: Page "Dispatch Scanning new";
                begin

                    //DispatchScan.Run();
                end;

            }
            action("Delivery Note A6")
            {
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ISH: Record "Interim Sales Header";
                    AddText: Text;
                begin
                    CLEAR(AddText);
                    InterimSalesHeader := Rec;
                    CurrPage.SETSELECTIONFILTER(InterimSalesHeader);
                    IF InterimSalesHeader.FINDSET THEN
                        REPEAT
                            AddToFilterText(AddText, '|', '', InterimSalesHeader."No.")
                        UNTIL InterimSalesHeader.NEXT = 0;

                    ISH.RESET;
                    ISH.SETRANGE("Document Type", ISH."Document Type"::Order);
                    ISH.SETFILTER("No.", AddText);
                    ISH.SETFILTER("Tracking No.", '<>%1', ' ');
                    IF ISH.FINDSET THEN BEGIN
                        REPORT.RUN(90003, TRUE, FALSE, ISH);
                    END;
                end;
            }
            action("Remove Destination Doc. Reference")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    CU90000: Codeunit "Web Order Mgt";
                begin
                    CU90000.RemoveDestinationDocReference(Rec, TRUE);
                end;
            }
        }
    }


    trigger OnInit()
    begin
        EnableReject := FALSE;
        EnableEliminateSelectedError := FALSE
    end;

    trigger OnOpenPage()
    begin
        IF (RecStatus = RecStatus::"In Progress") OR (RecStatus = RecStatus::Error) THEN BEGIN
            EnableReject := TRUE;
            EnableEliminateSelectedError := TRUE;
        END;
    end;


    var
        RecStatus: Option Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled,Error;
        InterimSalesHeader: Record "Interim Sales Header";
        //OrderRead: Codeunit "Process Order File-Innox";
        //AmazonIntegration: Codeunit "Amazon Integration"; //Commented By Pavan 20072020
        Temp_SalesHeader: Record "Sales Header" temporary;
        EnableEliminateSelectedError: Boolean;
        EnableReject: Boolean;
        WebOrdMngt: Codeunit "Web Order Mgt";
        SalesHeader: Record "Sales Header";
        WhseInternalPickHeader: Record "Whse. Internal Pick Header";


    procedure GetStatus(L_Status: Option Confirmed,"In Progress",Processing,"In Picking",Picked,Dispatched,Rejected,Throttled; L_InterimSalesHeader: Record "Interim Sales Header")
    begin
        RecStatus := L_Status;
    end;


    //Abdul+++ 02/10/2021
    LOCAL procedure AddToFilterText(VAR TextVar: Text[250]; Separator: Code[1]; Comparator: Code[2]; Addendum: Code[20])
    begin
        IF TextVar = '' THEN
            TextVar := Comparator + Addendum
        ELSE
            TextVar += Separator + Comparator + Addendum;
    end;
    //Abdul---


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


    // local procedure CreateTempSalesHeaderSHOPDIRECT(P_InterimSalesHeader: Record "Interim Sales Header")
    // var
    //     ShippingAgent: Record "Shipping Agent";
    // begin
    //     Temp_SalesHeader.DeleteAll();
    //     Temp_SalesHeader.Init;
    //     Temp_SalesHeader."Document Type" := P_InterimSalesHeader."Document Type";
    //     Temp_SalesHeader."No." := P_InterimSalesHeader."No.";
    //     Temp_SalesHeader."External Document No." := P_InterimSalesHeader."External Document No.";
    //     Temp_SalesHeader."Order Date" := P_InterimSalesHeader."Document Date";
    //     Temp_SalesHeader."Bill-to Customer No." := CopyStr(P_InterimSalesHeader."Trade Partner Code", 1, 20);
    //     Temp_SalesHeader."Customer Posting Group" := CopyStr(P_InterimSalesHeader."MultiLine Order No.", 1, 20);
    //     Temp_SalesHeader.Insert();

    //     ShippingAgent.Reset();
    //     ShippingAgent.SetRange(Code, P_InterimSalesHeader."Shipping Agent Code");
    //     if ShippingAgent.FindFirst() then begin
    //         Codeunit.Run(ShippingAgent."Procesing Codeunit", Temp_SalesHeader);
    //     end;
    // end;

}

