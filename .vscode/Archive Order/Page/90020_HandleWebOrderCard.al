page 90019 "Handle Web Order"
{
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    SourceTable = "Handled Interim Sales Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;
                field("Document No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("MultiLine Order No."; Rec."MultiLine Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Deal ID"; Rec."Deal ID")
                {
                    ApplicationArea = All;
                }
                field("Fullfillment Channel"; Rec."Fullfillment Channel")
                {
                    ApplicationArea = All;
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ApplicationArea = All;
                }
                field("Order Discount Amount"; Rec."Order Discount Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Discount Amount';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                group("Shipping Details")
                {
                    Caption = 'Shipping Details';

                    field("Web Shipment Method"; Rec."Web Shipment Method")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipment Method Code"; Rec."Shipment Method Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipping Agent Code"; Rec."Shipping Agent Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Shipment Date"; Rec."Shipment Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Tracking No."; Rec."Tracking No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Weight"; Rec."Total Weight")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Shipping)
            {
                Editable = false;
                Caption = 'Shipping';
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Buyer Name"; Rec."Buyer Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }
                field("Buyer Email"; Rec."Buyer Email")
                {
                    ApplicationArea = All;
                }
                field("Earliest Delivery date"; Rec."Earliest Delivery date")
                {
                    ApplicationArea = All;
                }
                field("Earliest Ship Date"; Rec."Earliest Ship Date")
                {
                    ApplicationArea = All;
                }
            }
            part("HanHandle Web Order Subform"; "Handled Web Order Subpage")
            {
                ApplicationArea = All;
                Enabled = true;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "Document No" = FIELD("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Navigate)
            {
                CaptionML = ENU = 'Navigate',
                            ENG = 'Navigate';
                Image = SelectLineToApply;
            }
            action("Sales Document")
            {
                Caption = '&Sales Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;
                ApplicationArea = All;

                trigger OnAction();
                begin
                    /*IF Rec."Dispatch No." <> '' THEN BEGIN
                        SalesShipmentHeader.RESET;
                        //SalesShipmentHeader.GET(Rec."Dispatch No.");
                        IF SalesShipmentHeader.FINDSET THEN BEGIN
                            CLEAR(PostedSalesShipment);
                            PostedSalesShipment.SETRECORD(SalesShipmentHeader);
                            PostedSalesShipment.RUN;
                        END;
                    END ELSE*/
                    BEGIN
                        SalesHeader.RESET;
                        //SalesHeader.SETRANGE(SalesHeader."Web Order No.", Rec."Document No.");
                        IF SalesHeader.FINDSET THEN BEGIN
                            CLEAR(SalesOrder);
                            SalesOrder.SETRECORD(SalesHeader);
                            SalesOrder.RUN;
                        END;
                    END;
                end;
            }
            action(ReOrder)
            {
                ApplicationArea = All;
                Caption = 'Reorder';
                trigger OnAction()
                var
                    RecInterimSalesHeader: Record "Interim Sales Header";
                    L_HandledInterimSalesHeader: record "Handled Interim Sales Line";
                    DocNo: Code[20];
                    L_InterimSalesHeader: record "Interim Sales Header";
                    InterimSalesLine: record "Interim Sales Line";
                begin
                    CLEAR(DocNo);
                    RecInterimSalesHeader.INIT;
                    //MapHeader(Rec,RecInterimSalesHeader);
                    RecInterimSalesHeader.TransferFields(Rec);
                    RecInterimSalesHeader."Document Type" := Rec."Document Type";
                    RecInterimSalesHeader."Document Type" := Rec."Document Type";
                    IF STRPOS(Rec."No.", '-') = 0 THEN
                        DocNo := Rec."No." + '-01'
                    ELSE
                        DocNo := INCSTR(Rec."No.");//+'-01'
                    RecInterimSalesHeader."No." := DocNo;
                    RecInterimSalesHeader."Package Tracking No." := '';
                    RecInterimSalesHeader.Status := RecInterimSalesHeader.Status::"In Progress";
                    RecInterimSalesHeader."Order Date" := TODAY;
                    RecInterimSalesHeader."Document Date" := TODAY;
                    RecInterimSalesHeader."Channel Order ID" := rec."Channel Order ID" + 'R';
                    RecInterimSalesHeader."External Document No." := CopyStr(rec."External Document No." + 'R', 1, 20);
                    RecInterimSalesHeader.Comments := 'Reorder';
                    CLEAR(RecInterimSalesHeader."Scanned By");
                    CLEAR(RecInterimSalesHeader."Package Tracking No.");
                    CLEAR(RecInterimSalesHeader."Destination Doc No.");
                    CLEAR(RecInterimSalesHeader."Destination Doc Type");
                    CLEAR(RecInterimSalesHeader."Scanned Date");
                    CLEAR(RecInterimSalesHeader."Job Reference");
                    RecInterimSalesHeader.INSERT(TRUE);


                    L_InterimSalesHeader.RESET;
                    L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
                    L_InterimSalesHeader.SETRANGE("No.", DocNo);
                    IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
                        L_HandledInterimSalesHeader.RESET;
                        L_HandledInterimSalesHeader.SETRANGE("Document Type", Rec."Document Type");
                        L_HandledInterimSalesHeader.SETRANGE("Document No", Rec."No.");
                        IF L_HandledInterimSalesHeader.FINDSET THEN
                            REPEAT
                                InterimSalesLine.INIT;
                                InterimSalesLine.TRANSFERFIELDS(L_HandledInterimSalesHeader);
                                InterimSalesLine."Document Type" := L_InterimSalesHeader."Document Type";
                                InterimSalesLine."Document No" := L_InterimSalesHeader."No.";
                                Clear(InterimSalesLine."Destination Doc. Line No");
                                CLEAR(InterimSalesLine."Destination Doc No.");
                                CLEAR(InterimSalesLine."Destination Doc Type");
                                CLEAR(InterimSalesLine."Scanned Date");
                                CLEAR(InterimSalesLine."Dispatch Scan");
                                CLEAR(InterimSalesLine."Trolley No.");
                                CLEAR(InterimSalesLine."Line Status");
                                CLEAR(InterimSalesLine."Pick No");
                                CLEAR(InterimSalesLine."Picking Status");
                                CLEAR(InterimSalesLine."Pick Line No");
                                InterimSalesLine.Status := InterimSalesLine.Status::"In Progress";
                                InterimSalesLine.Reserved := FALSE;
                                InterimSalesLine."Channel Order ID" := L_InterimSalesHeader."Channel Order ID";
                                InterimSalesLine.INSERT(TRUE);
                            UNTIL L_HandledInterimSalesHeader.NEXT = 0;
                        MESSAGE('Order %1 created.', DocNo);
                    END;

                end;
            }
            action("Cancel Order")
            {
                ApplicationArea = All;
                Caption = 'Cancel Order';
                Image = Cancel;
                trigger OnAction()
                var
                    L_HISH: Record "Handled Interim Sales Header";
                    L_HISL: Record "Handled Interim Sales Line";
                begin
                    //Prathamesh
                    rec.TESTFIELD("Stock Posted", FALSE);
                    rec.Status := rec.Status::Cancelled;
                    CurrPage.UPDATE;

                    L_HISL.Reset();
                    L_HISL.SetRange("Document No", Rec."No.");
                    if L_HISL.FindSet() then begin
                        repeat
                            L_HISL."Line Status" := L_HISL."Line Status"::Cancelled;
                            L_HISL.Modify(true);
                        until L_HISL.Next() = 0;
                    end;
                    //Prathamesh
                end;

            }

            action("Print Delivery Note")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    L_InterimHeader: Record "Handled Interim Sales Header";
                    SalesHeader: Record 36;
                    NewDeliveryNote: Report 90071;
                    ShipmentTracking: Record "Shipment Tracking";
                    InStm: InStream;
                    filename: Text;
                    SMTP: Codeunit "Mail Management";
                begin

                    if Rec."Trade Partner Code" = 'SHOPDIRECT' then begin
                        ShipmentTracking.Reset();
                        ShipmentTracking.SetRange("Document No.", Rec."No.");
                        if ShipmentTracking.FindFirst() then begin
                            ShipmentTracking.CalcFields("A6 Label1");
                            ShipmentTracking."A6 Label1".CreateInStream(InStm);
                            filename := 'DespatchNote' + '-' + Rec."Channel Order ID" + '.pdf';
                            DownloadFromStream(InStm, '', '', '', filename);

                        end;
                    end
                    else begin
                        L_InterimHeader.RESET;
                        L_InterimHeader.SETRANGE("No.", Rec."No.");
                        IF L_InterimHeader.FINDSET THEN BEGIN
                            CLEAR(NewDeliveryNote);
                            NewDeliveryNote.SETTABLEVIEW(L_InterimHeader);
                            NewDeliveryNote.RUN;
                        END;
                    end;

                end;
            }
            action("Download Delivery Label")
            {
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    R_CourierLabel: Report "Courier Label";
                    L_InterimSalesHeader: Record "Handled Interim Sales Header";
                    L_ShipmentTracking: Record "Shipment Tracking";
                    L_ShipmentTracking2: Record "Shipment Tracking";
                    FileOutStream: OutStream;
                    filename: Text;
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                begin
                    /*Clear(R_CourierLabel);
                    L_ShipmentTracking.Reset();
                    L_ShipmentTracking.SetRange("Document No.", Rec."No.");
                    if L_ShipmentTracking.FindSet() then begin
                        R_CourierLabel.SETTABLEVIEW(L_ShipmentTracking);
                        R_CourierLabel.USEREQUESTPAGE(FALSE);
                        R_CourierLabel.Run();
                    end;*/
                    L_ShipmentTracking.Reset();
                    L_ShipmentTracking.SetRange("Document No.", Rec."No.");
                    L_ShipmentTracking.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                    if L_ShipmentTracking.FindFirst() then begin
                        TempBlob.CREATEOUTSTREAM(FileOutStream);
                        R_CourierLabel.SETTABLEVIEW(L_ShipmentTracking);
                        R_CourierLabel.USEREQUESTPAGE(FALSE);
                        R_CourierLabel.SaveAs('', ReportFormat::Pdf, FileOutStream);
                        FileMgt.BLOBExport(TempBlob, 'Courier Label - ' + Rec."Channel Order ID" + '.pdf', true);
                    end;
                end;
            }
        }
    }

    var
        SalesHeader: Record 36;
        SalesShipmentHeader: Record 110;
        SalesOrder: Page 42;
        PostedSalesShipment: Page 130;

    local procedure MapHeader(var RecInterimSalesHeader: Record "Interim Sales Header");
    begin
        /*RecInterimSalesHeader.VALIDATE("Sell-to Customer No.", HandledIncomingMessage."Sell-to Customer No.");
        RecInterimSalesHeader.VALIDATE("Web Customer No.", HandledIncomingMessage."Web Customer No.");
        RecInterimSalesHeader.VALIDATE(Address, HandledIncomingMessage.Address);
        RecInterimSalesHeader.VALIDATE("Address 2", HandledIncomingMessage."Address 2");
        RecInterimSalesHeader.VALIDATE(City, HandledIncomingMessage.City);
        RecInterimSalesHeader.VALIDATE("Post Code", HandledIncomingMessage."Post Code");
        RecInterimSalesHeader.VALIDATE("Order Date", HandledIncomingMessage."Order Date");
        RecInterimSalesHeader.VALIDATE("Bill-to Customer No.", HandledIncomingMessage."Bill-to Customer No.");
        RecInterimSalesHeader.VALIDATE("Ship-to Name", HandledIncomingMessage."Ship-to Name");
        RecInterimSalesHeader.VALIDATE("Ship-to Address", HandledIncomingMessage."Ship-to Address");
        RecInterimSalesHeader.VALIDATE("Ship-to Address 2", HandledIncomingMessage."Ship-to Address 2");
        RecInterimSalesHeader.VALIDATE("Ship-to City", HandledIncomingMessage."Ship-to City");
        RecInterimSalesHeader.VALIDATE("Ship-to Post Code", HandledIncomingMessage."Ship-to Post Code");
        RecInterimSalesHeader.VALIDATE("Ship-to County", HandledIncomingMessage."Ship-to County");
        RecInterimSalesHeader.VALIDATE("Ship-to Country", HandledIncomingMessage."Ship-to Country");
        RecInterimSalesHeader.VALIDATE("Document Date", HandledIncomingMessage."Document Date");
        RecInterimSalesHeader.VALIDATE("External Document No.", HandledIncomingMessage."External Document No.");
        RecInterimSalesHeader.VALIDATE("Buyer Email", HandledIncomingMessage."Buyer Email");
        RecInterimSalesHeader.VALIDATE("Buyer Name", HandledIncomingMessage."Buyer Name");
        RecInterimSalesHeader.VALIDATE("Earliest Delivery date", HandledIncomingMessage."Earliest Delivery date");
        RecInterimSalesHeader.VALIDATE("Earliest Ship Date", HandledIncomingMessage."Earliest Ship Date");
        RecInterimSalesHeader.VALIDATE("Fullfillment Channel", HandledIncomingMessage."Fullfillment Channel");
        RecInterimSalesHeader.VALIDATE("Order Amount", HandledIncomingMessage."Order Amount");
        RecInterimSalesHeader.VALIDATE("Channel Order ID", HandledIncomingMessage."Channel Order ID");        
        RecInterimSalesHeader.VALIDATE("Shipment Method Code", HandledIncomingMessage."Shipment Method Code");
        RecInterimSalesHeader.VALIDATE("Currency Code", HandledIncomingMessage."Currency Code");
        //   RecInterimSalesHeader.VALIDATE("Ship-tp Phone No.",HandledIncomingMessage."Ship-tp Phone No.");
        RecInterimSalesHeader.VALIDATE("Gift Message", HandledIncomingMessage."Gift Message");
        RecInterimSalesHeader.VALIDATE("Order Placed At", HandledIncomingMessage."Order Placed At");
        RecInterimSalesHeader.VALIDATE("Web Shipment Method", HandledIncomingMessage."Web Shipment Method");
        RecInterimSalesHeader.VALIDATE("Bill- to Name", HandledIncomingMessage."Bill- to Name");
        RecInterimSalesHeader.VALIDATE("Web Shipping Agent", HandledIncomingMessage."Web Shipping Agent");
        RecInterimSalesHeader.VALIDATE("Bill-to CompanyName", HandledIncomingMessage."Bill-to CompanyName");
        RecInterimSalesHeader.VALIDATE("Ship-to CompanyName", HandledIncomingMessage."Ship-to CompanyName");
        RecInterimSalesHeader.VALIDATE("Deal ID", HandledIncomingMessage."Deal ID");
        RecInterimSalesHeader.VALIDATE("Bill-to County", HandledIncomingMessage."Bill-to County");
        RecInterimSalesHeader.VALIDATE(IsLLOrder, HandledIncomingMessage.IsLLOrder);
        RecInterimSalesHeader.VALIDATE("Trade Partner Code", HandledIncomingMessage."Trade Partner Code");
        RecInterimSalesHeader.VALIDATE("Shipping Agent Code", HandledIncomingMessage."Shipping Agent Code");
        RecInterimSalesHeader.VALIDATE("Shipping Agent Service Code", HandledIncomingMessage."Shipping Agent Service Code");
        RecInterimSalesHeader.VALIDATE("Shipment Date", HandledIncomingMessage."Shipment Date");
        RecInterimSalesHeader.VALIDATE("Ship-to Country/Region Code", HandledIncomingMessage."Ship-to Country/Region Code");
        RecInterimSalesHeader.VALIDATE("Shipping Time", HandledIncomingMessage."Shipping Time");
        RecInterimSalesHeader.VALIDATE("Requested Delivery Date", HandledIncomingMessage."Requested Delivery Date");
        RecInterimSalesHeader.VALIDATE("Currency Factor", HandledIncomingMessage."Currency Factor");
        RecInterimSalesHeader.VALIDATE(Comments, HandledIncomingMessage.Comments);
        RecInterimSalesHeader.VALIDATE("Location Code", HandledIncomingMessage."Location Code");
        RecInterimSalesHeader.VALIDATE("Pickup Name", HandledIncomingMessage."Pickup Name");
        RecInterimSalesHeader.VALIDATE("Pickup Address", HandledIncomingMessage."Pickup Address");
        RecInterimSalesHeader.VALIDATE("Pickup Address 2", HandledIncomingMessage."Pickup Address 2");
        RecInterimSalesHeader.VALIDATE("Pickup City", HandledIncomingMessage."Pickup City");
        RecInterimSalesHeader.VALIDATE("Pickup Post Code", HandledIncomingMessage."Pickup Post Code");
        RecInterimSalesHeader.VALIDATE("Pickup County", HandledIncomingMessage."Pickup County");
        RecInterimSalesHeader.VALIDATE("Pickup Country/Region Code", HandledIncomingMessage."Pickup Country/Region Code");
        RecInterimSalesHeader.VALIDATE("Total Weight", HandledIncomingMessage."Total Weight");
        RecInterimSalesHeader.VALIDATE("Pickup Date", HandledIncomingMessage."Pickup Date");
        RecInterimSalesHeader.VALIDATE("Email (Location)", HandledIncomingMessage."Email (Location)");
        RecInterimSalesHeader.VALIDATE("No. Of Parcels", HandledIncomingMessage."No. Of Parcels");
        RecInterimSalesHeader.VALIDATE("Package Tracking No.", HandledIncomingMessage."Package Tracking No.");
        RecInterimSalesHeader.VALIDATE("Job Reference", HandledIncomingMessage."Job Reference");
        RecInterimSalesHeader.VALIDATE("Pickup Time", HandledIncomingMessage."Pickup Time");
        RecInterimSalesHeader.VALIDATE("Cancelled By", HandledIncomingMessage."Cancelled By");
        RecInterimSalesHeader.VALIDATE("Cancelled On", HandledIncomingMessage."Cancelled On");
        RecInterimSalesHeader.VALIDATE("Gift Wrap By", HandledIncomingMessage."Gift Wrap By");
        RecInterimSalesHeader.VALIDATE("Gift Wrap date", HandledIncomingMessage."Gift Wrap date");
        RecInterimSalesHeader.VALIDATE("Order Created On", HandledIncomingMessage."Order Created On");
        RecInterimSalesHeader.VALIDATE("Ship-to Phone", HandledIncomingMessage."Ship-to Phone");
        RecInterimSalesHeader.VALIDATE("Ship-to Email", HandledIncomingMessage."Ship-to Email");
        RecInterimSalesHeader.VALIDATE("No. of Items", HandledIncomingMessage."No. of Items");
        RecInterimSalesHeader.VALIDATE("Deal ID", HandledIncomingMessage."Deal ID");
        RecInterimSalesHeader.VALIDATE("Ship-to Country/Region Code", HandledIncomingMessage."Ship-to Country/Region Code");*/
    end;
}

