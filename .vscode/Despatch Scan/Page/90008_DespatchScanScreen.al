page 90008 "Despatch Scan Screen"
{
    Caption = 'Despatch Scan';
    DeleteAllowed = true;
    PageType = Card;
    SourceTable = "Despatch Scan Header";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    Editable = true;


    layout
    {
        area(content)
        {
            group("Option")
            {
                field(G_ScanText; G_ScanText)
                {
                    Editable = false;
                    QuickEntry = false;
                    ShowCaption = false;
                    ApplicationArea = All;

                }

                field(G_Scan; G_Scan)
                {
                    Caption = 'SCAN';
                    ApplicationArea = All;
                    QuickEntry = true;
                    ShowCaption = false;

                    trigger OnValidate()
                    var
                        G_Dialog: Dialog;
                    begin
                        if ((G_ScanText = 'SCAN TROLLEY NO.') AND (V_TrolleyNo = '')) then
                            G_Count := 1;
                        /*if ((G_ScanText = 'SCAN BAY NO.') AND (IsBayNoEditable = true)) then
                            G_Count := 2;*///block bay no feature
                        if ((G_ScanText = 'SCAN ITEM BARCODE') AND (V_TrolleyNo <> '')) then
                            G_Count := 3;
                        if G_Count = 1 then begin
                            V_TrolleyNo := G_Scan;
                            CheckTrollyNo(V_TrolleyNo);
                            TrolleyEditable := FALSE;
                            G_ItemNoEditable := TRUE;
                            FindtotalWeborders(V_TrolleyNo);
                            //IsBayNoEditable := checkifBayNoRequired(V_TrolleyNo);//block bay no feature
                            G_ItemNoEditable := not IsBayNoEditable;
                            if Not IsBayNoEditable then
                                FillPickedItemsForTrolley(V_TrolleyNo, '');

                            CheckTrolleyisalreadyscanned(V_TrolleyNo);

                            CurrPage.UPDATE;
                            rec."Trolley No" := V_TrolleyNo;
                            rec.Modify();
                            G_TrolleyScanned := true;
                            if IsBayNoEditable = true then
                                G_ScanText := 'SCAN BAY NO.'
                            else
                                G_ScanText := 'SCAN ITEM BARCODE';
                            G_Scan := '';
                        end;

                        if G_Count = 3 then begin
                            CurrPage."Despatch Scan Int. Pick".Page.Update();
                            G_ItemNo := G_Scan;
                            IF V_TrolleyNo = '' THEN
                                ERROR('Please Scan Trolley No.');

                            ValidateScannedQty(V_TrolleyNo, G_BayNo, G_ItemNo);
                            Rec.Reset();
                            Rec.SetRange("User ID", UserId);
                            Rec.SetRange("Trolley No", V_TrolleyNo);
                            IF NOT Rec.FINDFIRST THEN
                                FindWebOrder
                            ELSE
                                UpdateLine(G_DespatchScanLine."Order No");
                            CLEAR(G_ItemNo);
                            CurrPage.UPDATE(FALSE);
                            CurrPage."Despatch Scan Subform".Page.Setfilter(V_TrolleyNo, UserId);///****
                            G_DespatchScanLine.Reset();
                            G_DespatchScanLine.SetRange("Trolley No", V_TrolleyNo);
                            G_DespatchScanLine.SetRange(Scanned, true);
                            if G_DespatchScanLine.FindSet() then
                                CurrPage."Despatch Scan Subform".Page.Setfilter(V_TrolleyNo, UserId);
                            //SLEEP(2000);
                            // CheckTrolleyScanCompleted(V_TrolleyNo, G_BayNo); IK++ calling in UpdateLine Function
                            CurrPage.UPDATE(FALSE);
                            G_BarcodeScan := true;
                            if V_TrolleyNo = '' then
                                G_ScanText := 'SCAN TROLLEY NO.'
                            else
                                if (V_TrolleyNo <> '') and (G_TotalNoofBayinTrolley > 0) then
                                    G_ScanText := 'SCAN BAY NO.'
                                ELSE
                                    G_ScanText := 'SCAN ITEM BARCODE';
                            G_Scan := '';
                            G_TrolleyScanned := false;
                            G_BayScanned := false;
                            G_BarcodeScan := false;
                        end;
                        CurrPage.Update();
                    end;
                }
                field("Trolley No."; V_TrolleyNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                    QuickEntry = false;
                    trigger OnValidate()
                    begin
                        CheckTrollyNo(V_TrolleyNo);
                        TrolleyEditable := FALSE;
                        G_ItemNoEditable := TRUE;
                        FindtotalWeborders(V_TrolleyNo);
                        IsBayNoEditable := checkifBayNoRequired(V_TrolleyNo);
                        G_ItemNoEditable := not IsBayNoEditable;
                        if Not IsBayNoEditable then
                            FillPickedItemsForTrolley(V_TrolleyNo, '');

                        CheckTrolleyisalreadyscanned(V_TrolleyNo);

                        CurrPage.UPDATE;
                    end;
                }
                field(G_TotalWebOrders; G_TotalWebOrders)
                {
                    Caption = 'Total No. Of Orders';
                    Enabled = false;
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Dispatch Order-Wise"; Rec."Dispatch Order-Wise")
                {
                    ApplicationArea = All;
                    Visible = false;
                    QuickEntry = false;
                }
                field("Bay No."; G_BayNo)
                {
                    Caption = 'Bay No.';
                    ApplicationArea = All;
                    // Editable = IsBayNoEditable;
                    Visible = false;
                    QuickEntry = false;
                    trigger OnValidate()
                    begin
                        FillPickedItemsForTrolley(V_TrolleyNo, G_BayNo);
                        IsBayNoEditable := false;
                        G_ItemNoEditable := true;
                    end;
                }
                field(G_ItemNo; G_ItemNo)
                {
                    Caption = 'Scan Item Barcode';
                    ApplicationArea = All;
                    Visible = false;
                    QuickEntry = false;
                    trigger OnValidate()
                    begin

                        IF V_TrolleyNo = '' THEN
                            ERROR('Please Scan Trolley No.');

                        ValidateScannedQty(V_TrolleyNo, G_BayNo, G_ItemNo);
                        Rec.Reset();
                        Rec.SetRange("User ID", UserId);
                        Rec.SetRange("Trolley No", V_TrolleyNo);
                        IF NOT Rec.FINDFIRST THEN
                            FindWebOrder
                        ELSE
                            UpdateLine(G_DespatchScanLine."Order No");
                        CLEAR(G_ItemNo);
                        CurrPage.UPDATE(FALSE);
                        G_DespatchScanLine.Reset();
                        G_DespatchScanLine.SetRange("Trolley No", V_TrolleyNo);
                        G_DespatchScanLine.SetRange(Scanned, true);
                        if G_DespatchScanLine.FindSet() then
                            CurrPage."Despatch Scan Subform".Page.Setfilter(V_TrolleyNo, UserId);
                        SLEEP(1000);
                        CheckTrolleyScanCompleted(V_TrolleyNo, G_BayNo);
                        CurrPage.UPDATE(FALSE);

                    end;
                }
                field(G_TotalNoofIteminBay; G_TotalNoofBayinTrolley)
                {
                    ApplicationArea = All;
                    Caption = 'Total No of Bay in Trolley';
                    Enabled = false;
                    Visible = false;
                    QuickEntry = false;
                }

            }

            part("Despatch Scan Subform"; "Despatch Scan Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Trolley No" = field("Trolley No");
                SubPageView = sorting(Scanned, "Entry No.", "Trolley No");
            }
            part("Despatch Scan Int. Pick"; "Despatch Scan Int. Pick")
            {
                ApplicationArea = All;
                SubPageLink = "Trolley No." = field("Trolley No");

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Close Trolley")
            {
                Caption = 'Close Trolley';
                Image = Shipment;
                ApplicationArea = All;

                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;


                trigger OnAction()
                var
                begin
                    CurrPage."Despatch Scan Subform".Page.CloseTrolley();
                end;
            }
            action("Remove Scanned Entries")
            {

                Image = RemoveLine;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                var
                    L_Despatch: Record "Despatch Scan Line";
                begin
                    CurrPage."Despatch Scan Subform".Page.GetDetailsFromHeader();
                    CurrPage.Update(true);
                end;
            }
            action("Cancel Line")
            {
                Image = Cancel;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;

                trigger OnAction()
                var
                begin
                    CurrPage."Despatch Scan Subform".Page.CancelLine();
                end;
            }
            action("Park Order")
            {
                Image = Archive;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                var
                    L_DespScanLine: Record "Despatch Scan Line";
                begin
                    L_DespScanLine.Reset();
                    L_DespScanLine.SetRange("Trolley No", V_TrolleyNo);
                    if L_DespScanLine.FindSet() then begin
                        CurrPage."Despatch Scan Subform".Page.ParkOrders(L_DespScanLine."Order No", true);
                        L_DespScanLine.DeleteAll();
                        CurrPage."Despatch Scan Int. Pick".Page.Update();
                        // Message('The order is parked');
                    end;
                end;
            }
            action("Post & Print")
            {
                Image = PostPrint;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;

                trigger OnAction()
                var
                    DespatchScanLine: Record "Despatch Scan Line";
                    PartiallyDespatchScanCount: Integer;
                begin
                    CurrPage."Despatch Scan Subform".Page.PostAndPrint();
                    CurrPage."Despatch Scan Int. Pick".Page.Update();
                end;
            }
            action("Web Order")
            {
                Image = Open;
                ApplicationArea = All;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                var
                begin
                    CurrPage."Despatch Scan Subform".Page.OpenWebOrder();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Despatch: Record "Despatch Scan Header";
        L_Despatch2: Record "Despatch Scan Line";
    begin

        L_Despatch.Reset();
        L_Despatch.SetRange("Entry No.", 0);
        if L_Despatch.FindFirst() then
            L_Despatch.Delete();

        L_Despatch.Reset();
        L_Despatch.CalcFields("Line exist");
        L_Despatch.SetRange("Line exist", false);
        L_Despatch.SETRANGE("User ID", USERID);
        if L_Despatch.FindSet() then
            L_Despatch.DeleteAll();

        Clear(G_Count);
        G_TrolleyScanned := false;
        G_BayScanned := false;
        G_BarcodeScan := false;
        CLEAR(V_TrolleyNo);
        L_Despatch.RESET;
        L_Despatch.Ascending(false);
        L_Despatch.SETRANGE("User ID", USERID);
        //L_Despatch.SETRANGE(Scanned, FALSE); code bloked by ak
        IF L_Despatch.FINDFIRST THEN BEGIN
            L_Despatch2.RESET;
            L_Despatch2.SETRANGE("User ID", USERID);
            //L_Despatch2.SETRANGE("Order No", L_Despatch."Order No");
            L_Despatch2.SETRANGE("Trolley No", L_Despatch."Trolley No");
            if L_Despatch2.FindSet() then begin
                V_TrolleyNo := L_Despatch."Trolley No";
                G_BayNo := L_Despatch."Bay No.";
            end;
            IsBayNoEditable := checkifBayNoRequired(V_TrolleyNo);
            if G_BayNo <> '' then
                IsBayNoEditable := false;

            if V_TrolleyNo <> '' then begin
                FindtotalWeborders(V_TrolleyNo);
                FillPickedItemsForTrolley(V_TrolleyNo, G_BayNo);
                CurrPage."Despatch Scan Subform".Page.Setfilter(V_TrolleyNo, UserId);
                rec.SetRange("Trolley No", V_TrolleyNo);
            end;
        END
        ELSE BEGIN
            L_Despatch.Reset();
            if L_Despatch.FindLast() then begin
                L_Despatch.Init();
                L_Despatch."Entry No." := L_Despatch."Entry No." + 1;
                L_Despatch."User ID" := UserId;
                L_Despatch."Trolley No" := 'DespatchScan';
                L_Despatch.Insert(true);
            end
            else begin
                L_Despatch.Init();
                L_Despatch."Entry No." := 1;
                L_Despatch."User ID" := UserId;
                L_Despatch."Trolley No" := 'DespatchScan';
                L_Despatch.Insert(true);

            end;
        END;

        if V_TrolleyNo = '' then
            G_ScanText := 'SCAN TROLLEY NO.'
        else
            G_ScanText := 'SCAN ITEM BARCODE';
        CurrPage.UPDATE(false);

        IF V_TrolleyNo = '' THEN BEGIN
            TrolleyEditable := TRUE;
            G_ItemNoEditable := FALSE;
        END ELSE BEGIN
            TrolleyEditable := FALSE;
            if IsBayNoEditable then
                G_ItemNoEditable := false
            else
                G_ItemNoEditable := TRUE;
        END;
    end;

    trigger OnClosePage()
    var
        L_Despatch: Record "Despatch Scan Header";
    begin
        //if V_TrolleyNo = '' then begin
        L_Despatch.Reset();
        L_Despatch.SETRANGE("User ID", USERID);
        L_Despatch.SetFilter("Trolley No", '%1', '');
        if L_Despatch.FindFirst() then
            L_Despatch.Delete();
        //  end;
    end;




    var
        G_WorkstationSelectionCodeUnit: Codeunit WorkstationSelection;
        G_Scan: Code[20];
        G_ItemNo: Code[20];

        V_TrolleyNo: Code[20];
        [InDataSet]
        TrolleyEditable: Boolean;
        [InDataSet]
        G_ItemNoEditable: Boolean;
        UpdateDispatchedOnWebOrder: Report "Update Dispatched On Web Order";
        Styletext: Text;
        G_TotalWebOrders: Text;
        ChannelOrderId: Text;
        TempPickedStock: Record "Lot Bin Buffer" temporary;
        Query50016: Query "Get Registered Qty From Pick";
        Text001: Label 'Some of the items in Trolley %1 are already scanned by %2. Do you want to load scanned line with your id?';
        G_BayNo: Code[10];
        IsBayNoEditable: Boolean;
        G_TotalNoofIteminBay: Integer;
        G_TotalNoofBayinTrolley: Integer;
        G_DespatchScanLine: Record "Despatch Scan Line";
        G_EntryNo: Integer;
        G_TrolleyScanned: Boolean;
        G_BayScanned: Boolean;
        G_BarcodeScan: Boolean;
        G_ScanText: Code[250];
        G_Count: Integer;
        G_GeneralSetup: Record "General Setup - Channels";

    local procedure FindWebOrder()
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Despatch: Record "Despatch Scan Line";
    begin

        L_InterimSalesLine.RESET;
        //L_InterimSalesLine.SetCurrentKey("Bay No.");
        L_InterimSalesLine.SETRANGE("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("No.", FindItem(G_ItemNo, 1));
        if FindItem(G_ItemNo, 2) <> '' then
            L_InterimSalesLine.SETRANGE("NAV Variant code", FindItem(G_ItemNo, 2));
        L_InterimSalesLine.SETRANGE("Trolley No.", V_TrolleyNo);
        if G_BayNo <> '' then
            L_InterimSalesLine.SetRange("Bay No.", G_BayNo);
        L_InterimSalesLine.SETFILTER("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Assembly);//Chandan
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);
        L_InterimSalesLine.SETFILTER("Order Status", '%1|%2', L_InterimSalesLine."Order Status"::Processing, L_InterimSalesLine."Order Status"::"Partially Scanned");//ak 291220
        L_InterimSalesLine.SETRANGE("Line Status", L_InterimSalesLine."Line Status"::" ");//ak 291220
        IF L_InterimSalesLine.FINDFIRST THEN BEGIN
            L_Despatch.RESET;
            L_Despatch.SETRANGE("Document Type", L_InterimSalesLine."Document Type");
            L_Despatch.SETRANGE("Order No", L_InterimSalesLine."Document No");
            IF NOT L_Despatch.FINDFIRST THEN BEGIN
                InsertLineIntoDespatchTable(L_InterimSalesLine."Document No"); //g_order = 
            END
            ELSE BEGIN
                InsertLineIntoDespatchTable(FindNextWebOrder);
            END;
        END;
    end;

    local procedure InsertLineIntoDespatchTable(L_WebDocNo: Code[20])
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Despatch: Record "Despatch Scan Line";
        L_DespatchH: Record "Despatch Scan Header";
        i: Integer;
        WarehouseShipmentLine: record "Warehouse Shipment Line";
        RegisteredWhseActivityLine: Record "Registered Whse. Activity Line";
    begin
        CLEAR(i);//ak 051220
        L_InterimSalesLine.RESET;
        //L_InterimSalesLine.SetCurrentKey("Bay No.");
        L_InterimSalesLine.SETRANGE("Document No", L_WebDocNo);
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETFILTER("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Assembly);
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);//ak 221120 line which is already scanned should not populate in dispatch scan screen
        L_InterimSalesLine.SETFILTER("Order Status", '%1|%2', L_InterimSalesLine."Order Status"::Processing, L_InterimSalesLine."Order Status"::"Partially Scanned");//ak 291220
        L_InterimSalesLine.SETRANGE("Line Status", L_InterimSalesLine."Line Status"::" ");//ak 291220
        //IF L_InterimSalesLine.FINDSET THEN
        if L_InterimSalesLine.FindFirst() THEN
            REPEAT
                CheckifExistingOrderfullyscanned(L_InterimSalesLine);
                L_Despatch.INIT;
                L_Despatch."Entry No." := FindLastEntryNo;
                L_Despatch."Channel Parter Code" := L_InterimSalesLine."Trade Partner Code";
                L_Despatch."Document Type" := L_InterimSalesLine."Document Type";
                L_Despatch."Order No" := L_InterimSalesLine."Document No";
                L_Despatch."Item No." := L_InterimSalesLine."No.";
                L_Despatch."Variant Code" := L_InterimSalesLine."NAV Variant code";
                L_Despatch."Order Line No." := L_InterimSalesLine."Line No.";
                IF STRLEN(L_InterimSalesLine.Description) > 50 THEN
                    L_Despatch."Item Desciption" := COPYSTR(L_InterimSalesLine.Description, 1, 50)
                ELSE
                    L_Despatch."Item Desciption" := L_InterimSalesLine.Description;
                L_Despatch.Quantity := L_InterimSalesLine.Quantity;
                L_Despatch."Trolley closed Quantity" += L_InterimSalesLine."Trolley Closed Quantity";
                IF ((FindItem(G_ItemNo, 1) = L_InterimSalesLine."No.") AND (FindItem(G_ItemNo, 2) = L_InterimSalesLine."NAV Variant code")) AND (i = 0) THEN BEGIN //ak 051220 code added to filter sale item more than one in order
                    L_Despatch."Scanned Quantity" += 1;
                    i += 1;
                END;

                IF L_Despatch.Quantity = (L_Despatch."Scanned Quantity" + L_Despatch."Trolley closed Quantity") THEN BEGIN
                    L_Despatch.Scanned := TRUE;
                    L_Despatch."Scan Date Time" := CURRENTDATETIME;
                END ELSE
                    L_Despatch.Scanned := FALSE;//Previous Code Commented by Chandan++170620
                L_Despatch."User ID" := USERID;
                L_Despatch."Trolley No" := V_TrolleyNo;

                WarehouseShipmentLine.Reset();
                WarehouseShipmentLine.SetRange("Source No.", L_InterimSalesLine."Destination Doc No.");
                WarehouseShipmentLine.SetRange("Source Line No.", L_InterimSalesLine."Destination Doc. Line No");
                if WarehouseShipmentLine.FindFirst() then begin

                    L_Despatch."Picked Quantity" := WarehouseShipmentLine."Qty. Picked";

                    if L_InterimSalesLine."Trolley Closed Quantity" = 0 then begin
                        RegisteredWhseActivityLine.Reset();
                        RegisteredWhseActivityLine.SetRange("Source No.", WarehouseShipmentLine."Source No.");
                        RegisteredWhseActivityLine.SetRange("Channel Order ID", WarehouseShipmentLine."Channel Order ID");
                        RegisteredWhseActivityLine.SetRange("Item No.", WarehouseShipmentLine."Item No.");
                        RegisteredWhseActivityLine.SetRange("Action Type", RegisteredWhseActivityLine."Action Type"::Place);
                        if RegisteredWhseActivityLine.FindSet() then
                            repeat
                                L_Despatch."Registered Qty." := L_Despatch."Registered Qty." + RegisteredWhseActivityLine.Quantity;
                            until RegisteredWhseActivityLine.Next() = 0;
                    end else begin
                        L_Despatch."Registered Qty." := L_Despatch."Picked Quantity" - L_InterimSalesLine."Trolley Closed Quantity";
                        if L_Despatch."Scanned Quantity" > L_Despatch."Registered Qty." then
                            L_Despatch."Scanned Quantity" := L_Despatch."Registered Qty.";
                    end;


                end;


                if L_Despatch."Scanned Quantity" = L_Despatch."Registered Qty." then
                    L_Despatch."Partially Scanned" := true
                else
                    L_Despatch."Partially Scanned" := false;
                // Irshad--


                L_Despatch."Channel Parter Code" := L_InterimSalesLine."Trade Partner Code";
                L_Despatch."Channel Order Id" := L_InterimSalesLine."Channel Order ID";
                if L_Despatch."Registered Qty." > 0 then
                    L_Despatch.INSERT;
                Clear(G_EntryNo);
                L_DespatchH.Reset();
                L_DespatchH.SetRange("Trolley No", V_TrolleyNo);
                if L_DespatchH.IsEmpty then begin
                    Rec.Reset();
                    if Rec.FindLast() then
                        G_EntryNo := Rec."Entry No." + 1
                    else
                        G_EntryNo := 1;
                    Rec.Init();
                    Rec."Entry No." := G_EntryNo;
                    Rec."Trolley No" := V_TrolleyNo;
                    Rec."Bay No." := G_BayNo;
                    Rec."Item No." := L_Despatch."Item No.";
                    Rec."User ID" := UserId;
                    IF L_Despatch.Quantity = (L_Despatch."Scanned Quantity" + L_Despatch."Trolley closed Quantity") THEN
                        Rec.Scanned := TRUE
                    ELSE
                        Rec.Scanned := FALSE;
                    Rec."Order No" := L_InterimSalesLine."Document No";
                    Rec.Insert();
                end;
                Commit();
                //Manage this in Partial Print functionality++
                //PrintDispatchReport(V_TrolleyNo, L_Despatch."Order No");//Start_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
                CheckOrderPartiallyScann(L_Despatch);  // Irshad
                                                       //  L_InterimSalesLine.Validate("Sacnned Qty", L_Despatch."Scanned Quantity");
                                                       //  L_InterimSalesLine.Modify(true);
            UNTIL L_InterimSalesLine.NEXT = 0;
        CurrPage.UPDATE(FALSE);
    end;

    //code to check if exsiting despatch line are fully scanned with respeact to picked quantity 
    local procedure CheckifExistingOrderfullyscanned(P_InterimSalesLine: Record "Interim Sales Line")
    var
        L_despatchLine: record "Despatch Scan Line";
        Q90010: Query 90010;
        Q90011: Query 90011;
        TotalPickedQty: decimal;
        TotalScannedQty: decimal;
    begin
        L_despatchLine.Reset();
        L_despatchLine.SetFilter("Channel Order Id", '<>%1', P_InterimSalesLine."Channel Order ID");
        L_despatchLine.SetRange("Hide from Despatch Scan", false);
        L_despatchLine.SetFilter("Line Status", '<>%1', L_despatchLine."Line Status"::Cancelled);
        If L_despatchLine.FindFirst() then begin
            Clear(Q90010);
            Clear(TotalPickedQty);
            Clear(TotalScannedQty);

            Q90010.SetRange(ChannelOrderID, L_despatchLine."Channel Order Id");
            Q90010.OPEN;
            WHILE Q90010.READ DO BEGIN
                TotalPickedQty := Q90010.QtyPicked;
            end;
            Q90010.Close();

            Q90011.SetRange(ChannelOrderID, L_despatchLine."Channel Order Id");
            Q90011.OPEN;
            WHILE Q90011.READ DO BEGIN
                TotalScannedQty := Q90011.ScannedQuantity;
            end;
            Q90011.Close();
            if TotalPickedQty = TotalScannedQty then begin
                L_despatchLine.ModifyAll("Hide from Despatch Scan", true);
            end;
        end;
    end;

    local procedure FindLastEntryNo(): Integer
    var
        L_Despatch: Record "Despatch Scan Line";
    begin
        L_Despatch.RESET;
        IF L_Despatch.FINDLAST THEN
            EXIT(L_Despatch."Entry No." + 1)
        ELSE
            EXIT(1);
    end;

    local procedure UpdateLine(L_WebDocNo: Code[20])
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Despatch: Record "Despatch Scan Line";
        //DispatchPickReport: Report "Despatch Scan Line";//NG_no_need
        L_InterimSalesHeader: Record "Interim Sales Header";
    begin
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Document Type", L_Despatch."Document Type"::Order);
        L_Despatch.SETRANGE("Item No.", FindItem(G_ItemNo, 1));
        if FindItem(G_ItemNo, 2) <> '' then
            L_Despatch.SETRANGE("Variant Code", FindItem(G_ItemNo, 2));
        L_Despatch.SETRANGE("Trolley No", V_TrolleyNo);
        if G_BayNo <> '' then
            L_Despatch.SetRange("Bay No.", G_BayNo);
        L_Despatch.SetRange(Scanned, false);
        L_Despatch.SETRANGE("Partially Scanned", FALSE);//SK
        L_Despatch.SetFilter("Line Status", '<>%1', L_Despatch."Line Status"::Cancelled);
        IF L_Despatch.FINDFIRST THEN BEGIN
            IF L_Despatch."Registered Qty." <> L_Despatch."Scanned Quantity" then begin
                ValidateRegisteredScannedQty(V_TrolleyNo, G_BayNo, G_ItemNo, L_Despatch."Channel Order Id", L_Despatch."Order No");  // Irshad
                L_Despatch."Scanned Quantity" += 1;
                IF (L_Despatch.Quantity = L_Despatch."Scanned Quantity" + L_Despatch."Trolley closed Quantity") THEN BEGIN //or (L_Despatch."Registered Qty." = L_Despatch."Scanned Quantity")  //Filter Added to check Partial Qty. for complete scan
                    L_Despatch.Scanned := TRUE;
                    L_Despatch."Scan Date Time" := CURRENTDATETIME;
                END;//Previous Code

                // Irshad++
                if L_Despatch."Scanned Quantity" = L_Despatch."Registered Qty." then
                    L_Despatch."Partially Scanned" := true
                else
                    L_Despatch."Partially Scanned" := false;
                //Irshad--
                L_Despatch.MODIFY;
                // UpdateScannedQtyInWebOrder(L_Despatch);
                CheckTrolleyScanCompleted(V_TrolleyNo, G_BayNo);
                CheckOrderPartiallyScann(L_Despatch);

                //CurrPage.UPDATE(FALSE);
                //Manage this in Partial Print functionality++  
                //PrintDispatchReport(V_TrolleyNo, L_Despatch."Order No");//Start_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
                //PrintPick(L_WebDocNo);
                // CreateJobQueue(L_WebDocNo);
                // rec.GET(L_Despatch."Entry No.");//Chadan++030720//Causing Issue

            END ELSE BEGIN
                // InsertLineIntoDespatchTable(FindNextWebOrder);
                // Message('PLease post & print the order');
            END
        END ELSE begin
            CheckForSingleOrderDespatch();
            InsertLineIntoDespatchTable(FindNextWebOrder);
        end;
    end;

    local procedure FindNextWebOrder(): Code[20]
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Despatch: Record "Despatch Scan Line";
        TEXT0001: Label 'The scanned Item: \ does not belong to the Trolley or \the Order is Parked or \the Order is Posted  ';
    begin
        L_InterimSalesLine.RESET;
        //L_InterimSalesLine.SetCurrentKey("Bay No.");
        L_InterimSalesLine.SETRANGE("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("No.", FindItem(G_ItemNo, 1));
        if FindItem(G_ItemNo, 2) <> '' then
            L_InterimSalesLine.SETRANGE("NAV Variant code", FindItem(G_ItemNo, 2));
        L_InterimSalesLine.SETRANGE("Trolley No.", V_TrolleyNo);
        if G_BayNo <> '' then
            L_InterimSalesLine.SetRange("Bay No.", G_BayNo);
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);
        L_InterimSalesLine.SetRange("Partially Post", FALSE);
        L_InterimSalesLine.SetRange(Parked, false);
        IF L_InterimSalesLine.FINDSET THEN
            REPEAT
                L_Despatch.RESET;
                L_Despatch.SETRANGE("Order No", L_InterimSalesLine."Document No");
                IF NOT L_Despatch.FINDFIRST THEN
                    EXIT(L_InterimSalesLine."Document No");
            UNTIL L_InterimSalesLine.NEXT = 0;
        Message(TEXT0001);
    end;


    procedure FindItem(P_Item: Code[20]; i: integer): Code[20]
    var
        L_ItemBarcode: Record "Item Reference";
        L_ItemNo: Record Item;
    begin
        L_ItemBarcode.RESET;
        L_ItemBarcode.SETRANGE("Reference Type", L_ItemBarcode."Reference Type"::"Bar Code");
        L_ItemBarcode.SETRANGE("Reference No.", P_Item);
        IF L_ItemBarcode.FINDFIRST THEN
            if i = 1 then
                EXIT(L_ItemBarcode."Item No.")
            else
                EXIT(L_ItemBarcode."Variant Code");

        L_ItemNo.RESET;
        L_ItemNo.SETRANGE("No.", P_Item);
        IF L_ItemNo.FINDFIRST THEN
            EXIT(L_ItemNo."No.");

        ERROR('Item not find');
    end;

    local procedure CheckTrollyNo(P_Trolly: Code[20]): Boolean
    var
        L_WhseActivityLine: Record "Warehouse Activity Line";
        WarShipmentHeader: Record "Warehouse Shipment Header";
    begin
        WarShipmentHeader.Reset();
        WarShipmentHeader.SetRange("Trolley No.", P_Trolly);
        if not WarShipmentHeader.FindSet() then begin
            Error('Trolley does not exist');
        end;

        L_WhseActivityLine.RESET;
        L_WhseActivityLine.SETRANGE("Activity Type", L_WhseActivityLine."Activity Type"::Pick);
        L_WhseActivityLine.SETRANGE("Trolley No.", V_TrolleyNo);
        IF NOT L_WhseActivityLine.ISEMPTY THEN
            ERROR(STRSUBSTNO('Trolley %1 is in picking', V_TrolleyNo));
    end;

    local procedure CheckTrolleyScanCompleted(P_TrolleyNo: Code[20]; P_BayNo: Code[20])
    var
        RecInterimSalesLine: Record "Interim Sales Line";
        RecDespatch: Record "Despatch Scan Line";
        OrderLnneCount: Integer;
        DespatchCount: Integer;
        NewDeliveryNote: Report DelivryNote1;
        messagetext: Text;
        Text001: TextConst ENU = 'All items in this %1 are scanned..\\ Do you want to close %1?',
                          ENG = 'All items in this %1 are scanned..\\ Do you want to close %1?';
        UpdateDispatchedOnShipment: Report "Update Dispatched On Shipment";

    begin
        CLEAR(OrderLnneCount);
        CLEAR(DespatchCount);
        RecInterimSalesLine.RESET;
        RecInterimSalesLine.SETRANGE(Type, RecInterimSalesLine.Type::Item);
        RecInterimSalesLine.SETRANGE("Trolley No.", P_TrolleyNo);
        if P_BayNo <> '' then
            RecInterimSalesLine.SetRange("Bay No.", P_BayNo);
        RecInterimSalesLine.SETFILTER("Item Type", '<>%1', RecInterimSalesLine."Item Type"::Assembly);
        //ak 011220 ++
        RecInterimSalesLine.SETRANGE("Dispatch Scan", FALSE);
        RecInterimSalesLine.SETRANGE("Scanned Date", 0DT);
        RecInterimSalesLine.SetRange("Partially Post", false);
        // RecInterimSalesLine.SetRange(Parked, false);
        //ak 011220 --
        RecInterimSalesLine.SetFilter("Line Status", '<>%1', RecInterimSalesLine."Line Status"::Cancelled);//Sofyan
        IF RecInterimSalesLine.FINDSET THEN
            OrderLnneCount := RecInterimSalesLine.COUNT;

        RecDespatch.RESET;
        RecDespatch.SETRANGE("Trolley No", P_TrolleyNo);
        if P_BayNo <> '' then
            RecDespatch.SetRange("Bay No.", P_BayNo);
        RecDespatch.SETRANGE(Scanned, TRUE);
        if RecDespatch.FindSet() then
            DespatchCount := RecDespatch.COUNT;

        if OrderLnneCount > 0 then begin
            IF DespatchCount = OrderLnneCount THEN BEGIN
                CurrPage."Despatch Scan Subform".Page.PrintPartiallyDespatchReport(RecDespatch);
                //IF CONFIRM('All items in this trolley are scanned..\\ Do you want to close Trolley?', TRUE) THEN BEGIN
                if P_BayNo <> '' then
                    messagetext := 'Bay'
                else
                    messagetext := 'Trolley';
                // IF CONFIRM(StrSubstNo(Text001, messagetext), TRUE) THEN BEGIN
                //UpdateDispatchedOnWebOrder.UpdatedDispatchOnWebOrderNew(RecDespatch, V_TrolleyNo, G_BayNo, Rec);
                CurrPage."Despatch Scan Subform".Page.TrolleyPostAndPrint(V_TrolleyNo, true);
                UpdateDispatchedOnShipment.SetCalledFromCLoseTrolly(true);
                UpdateDispatchedOnShipment.UpdateQtyOnWarehouseShipment(RecDespatch, Rec."Trolley No", Rec."Bay No.", Rec);
                //Clear(G_TotalNoofBayinTrolley);
                G_TotalNoofBayinTrolley := G_TotalNoofBayinTrolley - 1;
                if G_TotalNoofBayinTrolley <= 0 then
                    CurrPage.CLOSE
                else begin
                    Clear(G_BayNo);
                    IsBayNoEditable := true;
                    G_ItemNoEditable := false;
                    TrolleyEditable := false;
                end;
                // END;
            END;
        end;
    end;


    local procedure PrintDispatchReport(L_TrolleyNo: Code[20]; L_weborderNo: Code[20])
    var
        L_Despatch: Record "Despatch Scan Line";
        L_ArchieveDespatch: record "Archive Scanned Entries";
        L_InterimSalesLine: Record "Interim Sales Line";
        TotalSalesLines: Integer;
        TotalDespatchLines: Integer;
        R_CourierLabel: Report "Courier Label";
        L_InterimSalesHeader: Record "Interim Sales Header";
        FileOutStream: OutStream;
        FileInStream: InStream;
        outputFileName: Text[250];
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        L_ShipmentTracking: Record "Shipment Tracking";
        R_DeliveryNote: Report DelivryNoteNew;
        InStm: InStream;
        filename: Text;
        GeneralsetupOchannel: Record "General Setup - Channels";
        WebOrderMgt: Codeunit "Web Order Mgt";
    begin
        CLEAR(R_CourierLabel);
        CLEAR(TotalDespatchLines);
        CLEAR(TotalSalesLines);
        GeneralsetupOchannel.Get();

        L_Despatch.RESET;
        L_Despatch.SETRANGE("Trolley No", L_TrolleyNo);
        L_Despatch.SETRANGE(Scanned, TRUE);
        L_Despatch.SETRANGE("Order No", L_weborderNo);
        IF L_Despatch.FINDSET THEN
            TotalDespatchLines := L_Despatch.COUNT;

        L_ArchieveDespatch.RESET;
        L_ArchieveDespatch.SETRANGE(Scanned, TRUE);
        L_ArchieveDespatch.SETRANGE("Order No", L_weborderNo);
        IF L_ArchieveDespatch.FINDSET THEN
            TotalDespatchLines += L_ArchieveDespatch.COUNT;

        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("Document No", L_weborderNo);
        L_InterimSalesLine.SETFILTER("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Assembly);
        IF L_InterimSalesLine.FINDSET THEN
            TotalSalesLines := L_InterimSalesLine.COUNT;

        IF TotalDespatchLines = TotalSalesLines THEN BEGIN

            if Confirm('All the lines in the web order is scanned. Do you want to print the label', true) then begin
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
                L_InterimSalesHeader.SETRANGE("No.", L_weborderNo);
                L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
                IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
                    Clear(R_DeliveryNote);
                    R_DeliveryNote.SetTableView(L_InterimSalesHeader);
                    R_DeliveryNote.UseRequestPage(false);
                    R_DeliveryNote.Run();
                end;
            END;
        END;
    end;

    local procedure FindtotalWeborders(L_TrolleyNo: Code[20])
    var
        Q50013: Query "Total No Orders By Trolley";
        L_InterimSalesLine: Record "Interim Sales Line";
        TempInterimSalesLine: Record "Interim Sales Line" temporary;
        i: Integer;
    begin
        //Start_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
        CLEAR(Q50013);
        CLEAR(G_TotalWebOrders);
        CLEAR(i);
        //Q50013.TOPNUMBEROFROWS(1);
        Q50013.SETFILTER(Q50013.Trolley_No_, L_TrolleyNo);
        Q50013.OPEN;
        WHILE Q50013.READ DO BEGIN
            i := i + 1;
        END;

        Q50013.CLOSE;

        G_TotalWebOrders := FORMAT(i);

        //END_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
    end;

    local procedure FillPickedItemsForTrolley(P_TrolleyNo: Text; P_BayNo: Text)
    begin
        CLEAR(Query50016);
        Query50016.SETRANGE(Query50016.Trolley_No, P_TrolleyNo);
        //Query50016.SETRANGE(Query50016.Bay_No, P_BayNo); blocked to stop bay no feature
        Query50016.OPEN;
        WHILE Query50016.READ DO BEGIN
            TempPickedStock.RESET;
            TempPickedStock.SETRANGE("Item No.", Query50016.Item_No);
            TempPickedStock.SetRange("Variant Code", Query50016.Variant_Code);
            TempPickedStock.SETRANGE("Bin Code", Query50016.No);
            IF NOT TempPickedStock.FINDFIRST THEN BEGIN
                TempPickedStock.INIT;
                TempPickedStock."Item No." := Query50016.Item_No;
                TempPickedStock."Variant Code" := Query50016.Variant_Code;
                TempPickedStock."Bin Code" := Query50016.No;
                TempPickedStock."Qty. (Base)" := Query50016.Sum_Qty_Base;
                TempPickedStock."Lot No." := Query50016.Trolley_No;
                /*if Query50016.Bay_No <> '' then
                  TempPickedStock."Lot No." += ';' + Query50016.Bay_No;*/ //blocked to stop bay no
                TempPickedStock.INSERT;
            END ELSE BEGIN
                TempPickedStock."Qty. (Base)" += Query50016.Sum_Qty_Base;
                TempPickedStock.MODIFY;
            END;
        END;
        Query50016.CLOSE;
        /*IF USERID = 'PS-NAV1\ROBOSOL' THEN
          MESSAGE(FORMAT(TempPickedStock."Qty. (Base)"));*/

    end;

    // Irshad ++
    Local Procedure ValidateRegisteredScannedQty(P_TrolleyNo: Text; P_BayNo: Text; P_ItemNo: Code[20]; P_ChannelOrderId: Text[1024]; P_WebOrderNo: Code[20]);
    var
        L_DispatchedCount: Record "Despatch Scan Line";
        L_ItemNo: Code[20];
        L_VariantCode: Code[20];
    begin
        L_ItemNo := FindItem(P_ItemNo, 1);
        L_VariantCode := FindItem(P_ItemNo, 2);
        L_DispatchedCount.RESET;
        L_DispatchedCount.SETRANGE("Trolley No", P_TrolleyNo);
        if P_BayNo <> '' then
            L_DispatchedCount.SetRange("Bay No.", P_BayNo);
        L_DispatchedCount.SETRANGE("Item No.", L_ItemNo);
        if L_VariantCode <> '' then
            L_DispatchedCount.SetRange("Variant Code", L_VariantCode);
        L_DispatchedCount.SetRange("Channel Order Id", P_ChannelOrderId);
        if L_DispatchedCount.FindFirst() then begin
            if L_DispatchedCount."Scanned Quantity" >= L_DispatchedCount."Registered Qty." then
                ERROR('Quantity scanned is not picked');

        end;
    end;
    //Irshad--




    local procedure ValidateScannedQty(P_TrolleyNo: Text; P_BayNo: Text; P_ItemNo: Code[20])
    var
        L_ItemNo: Code[20];
        L_DispatchedCount: Record "Despatch Scan Line";
        L_VariantCode: Code[20];
    begin
        L_ItemNo := FindItem(P_ItemNo, 1);
        L_VariantCode := FindItem(P_ItemNo, 2);
        //if orderid is not `` then range set
        TempPickedStock.RESET;
        TempPickedStock.SETRANGE("Item No.", L_ItemNo);
        if L_VariantCode <> '' then
            TempPickedStock.SetRange("Variant Code", L_VariantCode);
        IF P_BayNo = '' then
            TempPickedStock.SETRANGE("Lot No.", P_TrolleyNo)
        else
            TempPickedStock.SETRANGE("Lot No.", P_TrolleyNo + ';' + P_BayNo);
        TempPickedStock.CALCSUMS("Qty. (Base)");

        L_DispatchedCount.RESET;
        L_DispatchedCount.SETRANGE("Trolley No", P_TrolleyNo);
        if P_BayNo <> '' then
            L_DispatchedCount.SetRange("Bay No.", P_BayNo);
        L_DispatchedCount.SETRANGE("Item No.", L_ItemNo);
        if L_VariantCode <> '' then
            L_DispatchedCount.SetRange("Variant Code", L_VariantCode);

        //L_DispatchedCount.SETRANGE(Scanned,TRUE);code blocked by alok on 201120
        L_DispatchedCount.CALCSUMS("Scanned Quantity", "Trolley closed Quantity");
        /*IF USERID = 'PS-NAV1\ROBOSOL' THEN
          MESSAGE(FORMAT(L_DispatchedCount."Scanned Quantity"));*/
        // IF L_DispatchedCount."Scanned Quantity" >= TempPickedStock."Qty. (Base)" THEN
        //     ERROR('Quantity scanned is not picked');

    end;

    local procedure CheckTrolleyisalreadyscanned(P_Trollet: Code[10]): Boolean
    var
        L_Despatch: Record "Despatch Scan Line";
    begin
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Trolley No", P_Trollet);
        IF L_Despatch.FINDSET THEN
            REPEAT
                EXIT(TRUE);

            UNTIL L_Despatch.NEXT = 0;
    end;

    local procedure CountBayNoInTrolley(P_RegisterPickHeader: Record "Registered Whse. Activity Hdr.")
    var
        L_RegisterPickLine: Record "Registered Whse. Activity Line";
    begin
        L_RegisterPickLine.Reset();
        L_RegisterPickLine.SetRange("No.", P_RegisterPickHeader."No.");
        L_RegisterPickLine.SetRange("Source Document", L_RegisterPickLine."Source Document"::" ");
        L_RegisterPickLine.SetRange("Action Type", L_RegisterPickLine."Action Type"::Take);
        L_RegisterPickLine.SetFilter("Bay No.", '<>%1', '');
        L_RegisterPickLine.SetRange("Bay Closed", false);
        if L_RegisterPickLine.FindFirst() then
            repeat
                L_RegisterPickLine.SetRange("Bay No.", L_RegisterPickLine."Bay No.");
                L_RegisterPickLine.FindLast();
                G_TotalNoofBayinTrolley += 1;
                L_RegisterPickLine.SetRange("Bay No.");
            until L_RegisterPickLine.Next() = 0
    end;

    local procedure checkifBayNoRequired(P_trolleyNo: Code[10]): Boolean
    var
        L_RegisterPickLine: Record "Registered Whse. Activity Line";
        RegisterPickHeader: Record "Registered Whse. Activity Hdr.";
    begin
        RegisterPickHeader.Reset();
        RegisterPickHeader.SetRange("Trolley No.", P_trolleyNo);
        RegisterPickHeader.SetRange("Trolley Closed", false);
        if RegisterPickHeader.FindFirst() then begin
            L_RegisterPickLine.Reset();
            L_RegisterPickLine.SetRange("No.", RegisterPickHeader."No.");
            L_RegisterPickLine.SetRange("Source Document", L_RegisterPickLine."Source Document"::" ");
            L_RegisterPickLine.SetFilter("Bay No.", '<>%1', '');
            IF L_RegisterPickLine.FindFirst() then begin
                CountBayNoInTrolley(RegisterPickHeader);
                exit(true)
            end else
                exit(false)
        end;
    end;


    local procedure CheckOrderPartiallyScann(var P_DespatchScanLine: Record "Despatch Scan Line")
    var
        DespatchScanLine: Record "Despatch Scan Line";
        InterimSalesLine: Record "Interim Sales Line";
        PartiallyDespatchScanCount: Integer;
        LineCount: Integer;

    begin
        Clear(PartiallyDespatchScanCount);
        Clear(LineCount);

        DespatchScanLine.Reset();
        DespatchScanLine.SetRange("Trolley No", P_DespatchScanLine."Trolley No");
        DespatchScanLine.SetRange("Order No", P_DespatchScanLine."Order No");
        DespatchScanLine.SetRange("Partially Scanned", true);
        DespatchScanLine.SetFilter("Scanned Quantity", '<>%1', 0);
        PartiallyDespatchScanCount := DespatchScanLine.Count;

        InterimSalesLine.Reset();
        InterimSalesLine.SetRange(Type, InterimSalesLine.Type::Item);
        InterimSalesLine.SetRange("Trolley No.", P_DespatchScanLine."Trolley No");
        InterimSalesLine.SetRange("Document No", P_DespatchScanLine."Order No");
        InterimSalesLine.SetFilter("Item Type", '<>%1', InterimSalesLine."Item Type"::Assembly);
        InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);
        InterimSalesLine.SETRANGE("Scanned Date", 0DT);
        InterimSalesLine.SetFilter("Line Status", '<>%1', InterimSalesLine."Line Status"::Cancelled);
        LineCount := InterimSalesLine.Count;
        if LineCount > 0 then begin
            if PartiallyDespatchScanCount = LineCount then begin
                CurrPage."Despatch Scan Subform".Page.PrintPartiallyDespatchReport(P_DespatchScanLine);
                // if Rec."Dispatch Order-Wise" = true then
                CurrPage."Despatch Scan Subform".Page.CLoseTrollyForPartiallyScanOrder(P_DespatchScanLine);
                CurrPage."Despatch Scan Int. Pick".Page.Update();
            end;
        end;
    end;

    local procedure CheckForSingleOrderDespatch()
    var
        DespatchScanLine: Record "Despatch Scan Line";
        ValidateDespScanLine: Record "Despatch Scan Line";
    begin
        DespatchScanLine.Reset();
        DespatchScanLine.SetRange("Document Type", DespatchScanLine."Document Type"::Order);
        DespatchScanLine.SETRANGE("Trolley No", V_TrolleyNo);
        // DespatchScanLine.SETRANGE(Scanned, false);
        if DespatchScanLine.FindSet() then begin
            ValidateDespScanLine.RESET;
            ValidateDespScanLine.SETRANGE("Document Type", ValidateDespScanLine."Document Type"::Order);
            ValidateDespScanLine.SETRANGE("Item No.", FindItem(G_ItemNo, 1));
            if FindItem(G_ItemNo, 2) <> '' then
                ValidateDespScanLine.SETRANGE("Variant Code", FindItem(G_ItemNo, 2));
            ValidateDespScanLine.SETRANGE("Trolley No", V_TrolleyNo);
            if G_BayNo <> '' then
                ValidateDespScanLine.SetRange("Bay No.", G_BayNo);
            ValidateDespScanLine.SETRANGE(Scanned, true);//SK
            ValidateDespScanLine.SetFilter("Line Status", '<>%1', ValidateDespScanLine."Line Status"::Cancelled);
            IF ValidateDespScanLine.FINDFIRST THEN BEGIN
                Error('Item is completely scanned');
            end else begin
                Error('Please Post and Print the Order %1', ValidateDespScanLine."Order No");
            end;
        end
    end;
}

