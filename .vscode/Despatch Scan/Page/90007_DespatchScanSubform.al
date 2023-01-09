page 90007 "Despatch Scan Subform"
{
    Caption = 'Dispatch Line';
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "Despatch Scan Line";
    InsertAllowed = false;
    // SourceTableView = SORTING("Entry No.") order(ascending);
    //   ORDER(Descending) where("Hide from Despatch Scan" = filter(false));

    layout
    {
        area(content)
        {
            repeater("Group")
            {
                Editable = false;
                Enabled = false;
                field("Trade Partner"; rec."Channel Parter Code")
                {
                    Caption = 'Channel Partner Code';
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Order No"; rec."Order No")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Item No"; rec."Item No.")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Item Desciption"; rec."Item Desciption")
                {
                    Caption = 'Description';
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("BayNo."; rec."Bay No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }

                field(Qty; rec.Quantity)
                {
                    Caption = 'Order Quantity';
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Picked Quantity"; rec."Picked Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Styletext;
                    Caption = 'Total Picked Qty';
                }
                field("Registered Qty."; Rec."Registered Qty.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Styletext;
                    Caption = 'Picked Qty';
                }
                field("Scanned Quantity"; rec."Scanned Quantity")
                {
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Quantity Handeled"; Rec."Trolley closed Quantity")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Scanned; rec.Scanned)
                {
                    Editable = false;
                    QuickEntry = false;
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Channel Order Id"; Rec."Channel Order Id")
                {
                    Caption = 'Channel Order ID';
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }

                field("Line Status"; Rec."Line Status")
                {
                    Caption = 'Status';
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            // action("Update Dispatch on Web Orders")
            // {
            //     Caption = 'Close Trolley';
            //     Image = Shipment;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     var
            //         DespatchLine: Record "Despatch Scan Line";
            //         DespatchHeader: Record "Despatch Scan Header";
            //     begin
            //         DespatchLine.RESET;
            //         DespatchLine.SETRANGE("Trolley No", Rec."Trolley No");
            //         DespatchLine.SetFilter("Line Status", '<>%1', DespatchLine."Line Status"::Cancelled);
            //         IF DespatchLine.FINDSET THEN BEGIN
            //             DespatchHeader.Reset();
            //             DespatchHeader.SetRange("Trolley No", Rec."Trolley No");
            //             DespatchHeader.SetRange("User ID", UserId);
            //             if DespatchHeader.FindSet() then begin
            //                 UpdateDispatchedOnWebOrder2.CheckWebOrderLinesFoUnscannedQty(Rec."Trolley No");
            //                 TrolleyPostAndPrint(Rec."Trolley No", true);
            //                 UpdateDispatchedOnWebOrder.SetCalledFromCLoseTrolly(true); //IK++
            //                 UpdateDispatchedOnWebOrder.UpdateQtyOnWarehouseShipment(DespatchLine, Rec."Trolley No", Rec."Bay No.", DespatchHeader);
            //                 // UpdateDispatchedOnWebOrder.CheckWebOrderLinesFoUnscannedQty(Rec."Trolley No");
            //                 // UpdateDispatchedOnWebOrder.UpdatedDispatchOnWebOrderNew(DespatchLine, Rec."Trolley No", Rec."Bay No.", DespatchHeader);
            //             end;
            //         END;
            //         CurrPage.CLOSE;
            //     end;
            // }
            //Azhar++
            // action("Web Order")
            // {
            //     Image = Open;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;
            //     trigger OnAction()
            //     var
            //         L_InterimSalesHdr: Record "Interim Sales Header";
            //         L_DespScanLine: Record "Despatch Scan Line";
            //         Page_L_InterimSalesCard: Page "Web Order Header";
            //     begin
            //         Clear(L_DespScanLine);
            //         L_DespScanLine := Rec;
            //         CurrPage.SetSelectionFilter(L_DespScanLine);

            //         if L_DespScanLine.FindSet() then begin
            //             if L_DespScanLine.Count = 1 then begin
            //                 Clear(Page_L_InterimSalesCard);
            //                 L_InterimSalesHdr.Reset();
            //                 L_InterimSalesHdr.SetRange("No.", Rec."Order No");
            //                 if L_InterimSalesHdr.FindFirst() then begin
            //                     Page_L_InterimSalesCard.SetTableView(L_InterimSalesHdr);
            //                     Page_L_InterimSalesCard.Run();
            //                 end;
            //             end;
            //         end;
            //     end;
            // }
            //Azhar--
            // action("Cancel Line")
            // {
            //     Image = Cancel;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;
            //     trigger OnAction()
            //     var
            //         L_DespScanLine: Record "Despatch Scan Line";
            //         L_InterimSalesLine: Record "Interim Sales Line";
            //         WSL: Record "Warehouse Shipment Line";
            //         WSH: Record "Warehouse Shipment Header";
            //         SalesHeader: Record "Sales Header";
            //         SalesLine: Record "Sales Line";
            //         WhseRelease: Codeunit "Whse.-Shipment Release";
            //         SalesRelease: Codeunit "Release Sales Document";
            //     begin
            //         Clear(L_DespScanLine);
            //         L_DespScanLine := Rec;
            //         CurrPage.SetSelectionFilter(L_DespScanLine);
            //         if L_DespScanLine.FindSet() then begin
            //             repeat
            //                 L_InterimSalesLine.Reset();
            //                 L_InterimSalesLine.SetRange("Document No", L_DespScanLine."Order No");
            //                 L_InterimSalesLine.SetRange("Line No.", L_DespScanLine."Order Line No.");
            //                 if L_InterimSalesLine.FindFirst() then begin
            //                     UpdateDispatchedOnWebOrder2.CancelSelectedLines(L_InterimSalesLine);
            //                     L_DespScanLine.Validate("Line Status", L_DespScanLine."Line Status"::Cancelled);
            //                     L_DespScanLine.Modify(true);
            //                     WSL.Reset();
            //                     WSL.SetRange("Trolley No.", L_DespScanLine."Trolley No");
            //                     WSL.SetRange("Channel Order ID", L_DespScanLine."Channel Order Id");
            //                     WSL.SetRange("Item No.", L_DespScanLine."Item No.");
            //                     if WSL.FindFirst() then begin
            //                         WSH.Reset();
            //                         if WSH.Get(WSL."No.") then begin
            //                             WhseRelease.Reopen(WSH);
            //                         end;
            //                         SalesHeader.Reset();
            //                         if SalesHeader.get(SalesHeader."Document Type"::Order, WSL."Source No.") then begin
            //                             SalesRelease.Reopen(SalesHeader);
            //                         end;
            //                         SalesLine.Reset();
            //                         SalesLine.SetRange("Document No.", WSL."Source No.");
            //                         SalesLine.SetRange("Line No.", WSL."Source Line No.");
            //                         SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            //                         if SalesLine.FindFirst() then begin
            //                             WSL.Delete();
            //                             if (SalesLine."Quantity Shipped" = 0) and (SalesLine."Quantity Invoiced" = 0) then begin
            //                                 SalesLine.Delete();
            //                             end else begin
            //                                 SalesLine.validate(Quantity, SalesLine."Quantity Shipped");
            //                                 SalesLine.Modify();
            //                             end;
            //                             SalesRelease.ReleaseSalesHeader(SalesHeader, false);
            //                             WhseRelease.Release(WSH);
            //                         end;
            //                     end;
            //                 end;
            //             until L_DespScanLine.Next() = 0;
            //             Message('The selected line is cancelled');
            //         end;
            //     end;
            // }
            // action("Park Order")
            // {
            //     Image = Reserve;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;
            //     Visible = false;
            //     trigger OnAction()
            //     var
            //         L_DespScanLine: Record "Despatch Scan Line";
            //     begin
            //         L_DespScanLine.Reset();
            //         L_DespScanLine.SetRange("Trolley No", Rec."Trolley No");
            //         L_DespScanLine.SetRange("Order No", Rec."Order No");
            //         if L_DespScanLine.FindSet() then begin
            //             repeat
            //                 L_DespScanLine.Delete();
            //             until L_DespScanLine.Next() = 0;
            //             ParkOrders(Rec."Order No", true);
            //             Message('The order is parked');
            //         end;
            //     end;
            // }
            // action("Post & Print")
            // {
            //     Image = PostPrint;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     ApplicationArea = All;
            //     trigger OnAction()
            //     var
            //         DespatchScanLine: Record "Despatch Scan Line";
            //         PartiallyDespatchScanCount: Integer;
            //     begin
            //         Clear(PartiallyDespatchScanCount);
            //         DespatchScanLine.Reset();
            //         DespatchScanLine.SetRange("Trolley No", Rec."Trolley No");
            //         DespatchScanLine.SetRange("Order No", Rec."Order No");
            //         DespatchScanLine.SetFilter("Scanned Quantity", '>%1', 0);
            //         DespatchScanLine.SetFilter("Line Status", '<>%1', DespatchScanLine."Line Status"::Cancelled);
            //         PartiallyDespatchScanCount := DespatchScanLine.Count;

            //         if PartiallyDespatchScanCount > 0 then begin
            //             PrintPartiallyDespatchReport(Rec);
            //             CLoseTrollyForPartiallyScanOrder(Rec);
            //         end;
            //     end;
            // }

        }
    }
    trigger OnAfterGetRecord()
    var
        L_ISH: Record "Interim Sales Header";
    begin
        Rec.SetRange("Trolley No", G_TrolleyNo);
        IF (rec."Trolley No" <> '') AND (rec."Partially Scanned" = TRUE) THEN BEGIN
            Styletext := ChangeStyle(Rec."Trolley No", Rec."Order No")
        END
        ELSE
            Styletext := 'Standard';


    end;

    local procedure ChangeStyle(L_TrolleyNo: Code[20]; L_weborderNo: Code[20]): Text
    var
        L_Despatch: Record "Despatch Scan Line";
        L_InterimSalesLine: Record "Interim Sales Line";
        TotalSalesLines: Integer;
        TotalDespatchLines: Integer;
    begin
        CLEAR(TotalDespatchLines);
        CLEAR(TotalSalesLines);
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Trolley No", L_TrolleyNo);
        // L_Despatch.SETRANGE(Scanned, TRUE);
        L_Despatch.SetRange("Partially Scanned", true);
        L_Despatch.SETRANGE("Order No", L_weborderNo);
        IF L_Despatch.FINDSET THEN
            TotalDespatchLines := L_Despatch.COUNT;

        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("Document No", L_weborderNo);
        L_InterimSalesLine.SETFILTER("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Assembly);
        IF L_InterimSalesLine.FINDSET THEN
            TotalSalesLines := L_InterimSalesLine.COUNT;

        IF TotalDespatchLines = TotalSalesLines THEN
            EXIT('Favorable')
        ELSE
            EXIT('Favorable');
    end;



    var
        Styletext: Text;
        //ChannelOrderId: Text;
        UpdateDispatchedOnWebOrder2: Report "Update Dispatched On Web Order";
        UpdateDispatchedOnWebOrder: Report "Update Dispatched On Shipment";
        G_TrolleyNo: Code[20];

    trigger OnOpenPage()
    begin

        Rec.RESET;
        Rec.SETRANGE("User ID", USERID);
        // rec.SetRange("Hide from Despatch Scan", false);

    end;

    procedure Setfilter(P_TrolleyNo: Code[20]; P_UserID: Code[50])
    var

    begin
        Rec.RESET;
        Rec.ASCENDING(FALSE);
        Rec.SETRANGE("User ID", P_UserID);
        Rec.SetRange("Trolley No", P_TrolleyNo);
        Rec.SetRange(Scanned, true);
        // rec.SetRange("Hide from Despatch Scan", false);
        G_TrolleyNo := P_TrolleyNo;
    end;


    procedure GetDetailsFromHeader()
    var
        DespatchScanLine: Record "Despatch Scan Line";
    begin
        Clear(DespatchScanLine);
        DespatchScanLine := Rec;
        CurrPage.SetSelectionFilter(DespatchScanLine);
        if DespatchScanLine.FindSet() then
            repeat
                if DespatchScanLine."Scanned Quantity" > 0 then begin
                    DespatchScanLine."Scanned Quantity" -= 1;
                    DespatchScanLine.Scanned := false;
                    DespatchScanLine."Partially Scanned" := false;
                    DespatchScanLine.Modify();
                end
            until DespatchScanLine.Next() = 0;

    end;

    procedure PrintPartiallyDespatchReport(P_DespatchScanLine: Record "Despatch Scan Line")
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        G_GeneralSetup: Record "General Setup - Channels";
        G_WorkstationSelectionCodeUnit: Codeunit WorkstationSelection;
        R_DeliveryNote: Report DelivryNoteNew;
        WebOrderMgt: Codeunit "Web Order Mgt";
        FileOutStream: OutStream;
        FileInStream: InStream;
        outputFileName: Text[250];
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        L_ShipmentTracking: Record "Shipment Tracking";
        InStm: InStream;
        filename: Text;
        R_CourierLabel: Report "Courier Label";
    begin
        //if Confirm('Do you want to print the label? ', true) then begin
        G_GeneralSetup.Get();
        if G_GeneralSetup."Despatch Printer Selection" then begin
            G_WorkstationSelectionCodeUnit.UpdateWorkstation();
        end;
        Clear(FileInStream);
        Clear(FileOutStream);
        Clear(outputFileName);
        Clear(TempBlob);
        Clear(FileMgt);
        L_InterimSalesHeader.RESET;
        L_InterimSalesHeader.SETRANGE("No.", P_DespatchScanLine."Order No");
        L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
        IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
            Clear(R_DeliveryNote);
            R_DeliveryNote.SetTableView(L_InterimSalesHeader);
            R_DeliveryNote.UseRequestPage(false);
            R_DeliveryNote.Run();
        end;
        //end;
    end;

    procedure CLoseTrollyForPartiallyScanOrder(P_DespatchScanLine: Record "Despatch Scan Line")
    var
        DespatchHeader: Record "Despatch Scan Header";
        DespatchLine: Record "Despatch Scan Line";
        WebOrderMgt: Codeunit "Web Order Mgt";
        Text001: TextConst ENU = 'Do you want to close the order?',
                          ENG = 'Do you want to close the order?';


    begin
        DespatchLine.RESET;
        DespatchLine.SETRANGE("Trolley No", P_DespatchScanLine."Trolley No");
        DespatchLine.SetRange("Order No", P_DespatchScanLine."Order No");
        IF DespatchLine.FINDSET THEN BEGIN
            DespatchHeader.Reset();
            DespatchHeader.SetRange("Trolley No", P_DespatchScanLine."Trolley No");
            DespatchHeader.SetRange("User ID", UserId);
            if DespatchHeader.FindSet() then begin
                // IF CONFIRM(Text001, TRUE) THEN BEGIN
                OrderPostAndPrint(P_DespatchScanLine."Order No", true);
                UpdateDispatchedOnWebOrder.SetCalledFromCLoseTrolly(false);  // IK++ 
                UpdateDispatchedOnWebOrder.UpdateQtyOnWarehouseShipment(DespatchLine, Rec."Trolley No", Rec."Bay No.", DespatchHeader);
                //UpdateDispatchedOnWebOrder.UpdatedDispatchOnWebOrderNewCloseOrder(DespatchLine, P_DespatchScanLine."Trolley No", P_DespatchScanLine."Bay No.", DespatchHeader);
                // end;
            END;
        end;
    end;


    procedure OrderPostAndPrint(P_OrderNo: Code[20]; PassedBoolean: Boolean)
    var
        L_IntrimSalesLine: Record "Interim Sales Line";
        DesSCan: Record "Despatch Scan Line";
    begin
        L_IntrimSalesLine.Reset();
        L_IntrimSalesLine.SetRange("Document No", P_OrderNo);
        L_IntrimSalesLine.SetRange("Document Type", L_IntrimSalesLine."Document Type"::Order);
        L_IntrimSalesLine.SetRange(Type, L_IntrimSalesLine.Type::Item);
        // L_IntrimSalesLine.SetRange("No.", DesSCan."Item No.");
        // L_IntrimSalesLine.SetRange("Dispatch Scan", false);
        if L_IntrimSalesLine.FindSet() then begin
            repeat
                L_IntrimSalesLine."Partially Post" := PassedBoolean;
                L_IntrimSalesLine.Modify(true);
            until L_IntrimSalesLine.Next() = 0
        end;
    end;

    procedure ParkOrders(P_OrderNo: Code[20]; Parked: Boolean)
    var
        L_IntrimSalesLine: Record "Interim Sales Line";
        L_DespScanLine: Record "Despatch Scan Line";
    begin
        L_IntrimSalesLine.Reset();
        L_IntrimSalesLine.SetRange("Document No", P_OrderNo);
        L_IntrimSalesLine.SetRange("Document Type", L_IntrimSalesLine."Document Type"::Order);
        L_IntrimSalesLine.SetRange(Type, L_IntrimSalesLine.Type::Item);
        if L_IntrimSalesLine.FindSet() then begin
            repeat
                L_IntrimSalesLine.Parked := Parked;
                L_IntrimSalesLine.Modify(true);
            until L_IntrimSalesLine.Next() = 0
        end;
    end;

    procedure TrolleyPostAndPrint(P_TrolleyNo: Code[20]; PassedBoolean: Boolean)
    var
        L_IntrimSalesLine: Record "Interim Sales Line";
    begin

        L_IntrimSalesLine.Reset();
        L_IntrimSalesLine.SetRange("Document No", P_TrolleyNo);
        L_IntrimSalesLine.SetRange("Document Type", L_IntrimSalesLine."Document Type"::Order);
        L_IntrimSalesLine.SetRange(Parked, true);
        if L_IntrimSalesLine.FindFirst() then begin
            Error('');
        end;
        L_IntrimSalesLine.Reset();
        L_IntrimSalesLine.SetRange("Document No", P_TrolleyNo);
        L_IntrimSalesLine.SetRange("Document Type", L_IntrimSalesLine."Document Type"::Order);
        L_IntrimSalesLine.SetRange(Type, L_IntrimSalesLine.Type::Item);
        // L_IntrimSalesLine.SetRange("Dispatch Scan", false);
        if L_IntrimSalesLine.FindSet() then
            repeat
                L_IntrimSalesLine."Partially Post" := PassedBoolean;
                L_IntrimSalesLine.Modify(true);
            until L_IntrimSalesLine.Next() = 0;
    end;

    procedure PostAndPrint()
    var
        DespatchScanLine: Record "Despatch Scan Line";
        PartiallyDespatchScanCount: Integer;
    begin
        Clear(PartiallyDespatchScanCount);
        DespatchScanLine.Reset();
        DespatchScanLine.SetRange("Trolley No", Rec."Trolley No");
        DespatchScanLine.SetRange("Order No", Rec."Order No");
        DespatchScanLine.SetFilter("Scanned Quantity", '>%1', 0);
        DespatchScanLine.SetFilter("Line Status", '<>%1', DespatchScanLine."Line Status"::Cancelled);
        PartiallyDespatchScanCount := DespatchScanLine.Count;

        if PartiallyDespatchScanCount > 0 then begin
            PrintPartiallyDespatchReport(Rec);
            CLoseTrollyForPartiallyScanOrder(Rec);
        end;
    end;


    procedure CloseTrolley()
    var
        DespatchLine: Record "Despatch Scan Line";
        DespatchHeader: Record "Despatch Scan Header";
    begin
        DespatchLine.RESET;
        DespatchLine.SETRANGE("Trolley No", Rec."Trolley No");
        DespatchLine.SetFilter("Line Status", '<>%1', DespatchLine."Line Status"::Cancelled);
        IF DespatchLine.FINDSET THEN BEGIN
            DespatchHeader.Reset();
            DespatchHeader.SetRange("Trolley No", Rec."Trolley No");
            DespatchHeader.SetRange("User ID", UserId);
            if DespatchHeader.FindSet() then begin
                UpdateDispatchedOnWebOrder2.CheckWebOrderLinesFoUnscannedQty(Rec."Trolley No");
                TrolleyPostAndPrint(Rec."Trolley No", true);
                UpdateDispatchedOnWebOrder.SetCalledFromCLoseTrolly(true); //IK++
                UpdateDispatchedOnWebOrder.UpdateQtyOnWarehouseShipment(DespatchLine, Rec."Trolley No", Rec."Bay No.", DespatchHeader);
                // UpdateDispatchedOnWebOrder.CheckWebOrderLinesFoUnscannedQty(Rec."Trolley No");
                // UpdateDispatchedOnWebOrder.UpdatedDispatchOnWebOrderNew(DespatchLine, Rec."Trolley No", Rec."Bay No.", DespatchHeader);
            end;
        END;
        CurrPage.CLOSE;
    end;

    procedure CancelLine()
    var
        L_DespScanLine: Record "Despatch Scan Line";
        L_InterimSalesLine: Record "Interim Sales Line";
        WSL: Record "Warehouse Shipment Line";
        WSH: Record "Warehouse Shipment Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WhseRelease: Codeunit "Whse.-Shipment Release";
        SalesRelease: Codeunit "Release Sales Document";
    begin
        Clear(L_DespScanLine);
        L_DespScanLine := Rec;
        CurrPage.SetSelectionFilter(L_DespScanLine);
        if L_DespScanLine.FindSet() then begin
            repeat
                L_InterimSalesLine.Reset();
                L_InterimSalesLine.SetRange("Document No", L_DespScanLine."Order No");
                L_InterimSalesLine.SetRange("Line No.", L_DespScanLine."Order Line No.");
                if L_InterimSalesLine.FindFirst() then begin
                    UpdateDispatchedOnWebOrder2.CancelSelectedLines(L_InterimSalesLine);
                    L_DespScanLine.Validate("Line Status", L_DespScanLine."Line Status"::Cancelled);
                    L_DespScanLine.Modify(true);
                    WSL.Reset();
                    WSL.SetRange("Trolley No.", L_DespScanLine."Trolley No");
                    WSL.SetRange("Channel Order ID", L_DespScanLine."Channel Order Id");
                    WSL.SetRange("Item No.", L_DespScanLine."Item No.");
                    if WSL.FindFirst() then begin
                        WSH.Reset();
                        if WSH.Get(WSL."No.") then begin
                            WhseRelease.Reopen(WSH);
                        end;
                        SalesHeader.Reset();
                        if SalesHeader.get(SalesHeader."Document Type"::Order, WSL."Source No.") then begin
                            SalesRelease.Reopen(SalesHeader);
                        end;
                        SalesLine.Reset();
                        SalesLine.SetRange("Document No.", WSL."Source No.");
                        SalesLine.SetRange("Line No.", WSL."Source Line No.");
                        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                        if SalesLine.FindFirst() then begin
                            WSL.Delete();
                            if (SalesLine."Quantity Shipped" = 0) and (SalesLine."Quantity Invoiced" = 0) then begin
                                SalesLine.Delete();
                            end else begin
                                SalesLine.validate(Quantity, SalesLine."Quantity Shipped");
                                SalesLine.Modify();
                            end;
                            SalesRelease.ReleaseSalesHeader(SalesHeader, false);
                            WhseRelease.Release(WSH);
                        end;
                    end;
                end;
            until L_DespScanLine.Next() = 0;
            Message('The selected line is cancelled');
        end;
    end;

    procedure OpenWebOrder()
    var
        L_InterimSalesHdr: Record "Interim Sales Header";
        L_DespScanLine: Record "Despatch Scan Line";
        Page_L_InterimSalesCard: Page "Web Order Header";
    begin
        Clear(L_DespScanLine);
        L_DespScanLine := Rec;
        CurrPage.SetSelectionFilter(L_DespScanLine);

        if L_DespScanLine.FindSet() then begin
            if L_DespScanLine.Count = 1 then begin
                Clear(Page_L_InterimSalesCard);
                L_InterimSalesHdr.Reset();
                L_InterimSalesHdr.SetRange("No.", Rec."Order No");
                if L_InterimSalesHdr.FindFirst() then begin
                    Page_L_InterimSalesCard.SetTableView(L_InterimSalesHdr);
                    Page_L_InterimSalesCard.Run();
                end;
            end;
        end;
    end;
}

