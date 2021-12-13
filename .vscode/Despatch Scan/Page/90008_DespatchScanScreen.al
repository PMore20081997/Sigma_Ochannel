page 90008 "Despatch Scan Screen"
{
    Caption = 'B2C Dispatch Scan';
    DeleteAllowed = true;
    PageType = Card;
    SourceTable = "Despatch Scan Header";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

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
                            G_TrolleyScanned := true;
                            if IsBayNoEditable = true then
                                G_ScanText := 'SCAN BAY NO.'
                            else
                                G_ScanText := 'SCAN ITEM BARCODE';
                            G_Scan := '';
                        end;

                        /*  if G_Count = 2 then begin//block bay no feature
                              G_BayNo := G_Scan;
                              FillPickedItemsForTrolley(V_TrolleyNo, G_BayNo);
                              IsBayNoEditable := false;
                              G_ItemNoEditable := true;
                              G_BayScanned := true;
                              G_ScanText := 'SCAN ITEM BARCODE';
                              G_Scan := '';
                          end;
                        */
                        if G_Count = 3 then begin
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
                            G_DespatchScanLine.Reset();
                            G_DespatchScanLine.SetRange("Trolley No", V_TrolleyNo);
                            G_DespatchScanLine.SetRange(Scanned, true);
                            if G_DespatchScanLine.FindSet() then
                                CurrPage."Despatch Scan Subform".Page.Setfilter(V_TrolleyNo, UserId);
                            SLEEP(2000);
                            CheckTrolleyScanCompleted(V_TrolleyNo, G_BayNo);
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
                    end;
                }
                field("Trolley No."; V_TrolleyNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
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
                field("Bay No."; G_BayNo)
                {
                    Caption = 'Bay No.';
                    ApplicationArea = All;
                    // Editable = IsBayNoEditable;
                    Visible = false;
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
                    //Editable = G_ItemNoEditable;
                    ApplicationArea = All;
                    Visible = false;
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
                }

            }
            part("Despatch Scan Subform"; "Despatch Scan Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Trolley No" = field("Trolley No");
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
        L_Despatch.SetRange("Line exist",false);
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
                rec.SetRange("Trolley No",V_TrolleyNo);
            end;
        END
        ELSE BEGIN
            L_Despatch.Reset();
            if L_Despatch.FindLast() then begin
                L_Despatch.Init();
                L_Despatch."Entry No." := L_Despatch."Entry No." + 1;
                L_Despatch."User ID" := UserId;
                L_Despatch.Insert(true);
            end
            else begin
                L_Despatch.Init();
                L_Despatch."Entry No." := 1;
                L_Despatch."User ID" := UserId;
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
                InsertLineIntoDespatchTable(L_InterimSalesLine."Document No");
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
                L_Despatch."Bay No." := L_InterimSalesLine."Bay No."; //G_BayNo;
                L_Despatch."Channel Parter Code" := L_InterimSalesLine."Trade Partner Code";
                L_Despatch.INSERT;
                Clear(G_EntryNo);                
                L_DespatchH.Reset();
                L_DespatchH.SetRange("Trolley No",V_TrolleyNo);
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
                PrintDispatchReport(V_TrolleyNo, L_Despatch."Order No");//Start_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
            UNTIL L_InterimSalesLine.NEXT = 0;
        /*   L_Despatch.RESET;
           L_Despatch.SETCURRENTKEY("Entry No.");
           L_Despatch.ASCENDING(FALSE);
           L_Despatch.SETRANGE("User ID", USERID);
           L_Despatch.SETRANGE("Order No", L_WebDocNo);
           L_Despatch.SetRange(Scanned, true);
           L_Despatch.FINDLAST;*///Chandan++030620//Sofyan++
                                 //CurrPage.UPDATE(TRUE);//blocked by alok becuase of this code system is asking do you wnat to renam whiel scan same item mre than one
        CurrPage.UPDATE(FALSE);
        //PrintPick(L_WebDocNo);

        //CreateJobQueue(L_WebDocNo);

        L_Despatch.SETRANGE("Order No");
        CurrPage.UPDATE(FALSE);
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
        L_Despatch.SETRANGE("Variant Code", FindItem(G_ItemNo, 2));
        L_Despatch.SETRANGE("Trolley No", V_TrolleyNo);
        if G_BayNo <> '' then
            L_Despatch.SetRange("Bay No.", G_BayNo);
        L_Despatch.SETRANGE(Scanned, FALSE);
        IF L_Despatch.FINDFIRST THEN BEGIN
            L_Despatch."Scanned Quantity" += 1;
            IF L_Despatch.Quantity = L_Despatch."Scanned Quantity" + L_Despatch."Trolley closed Quantity" THEN BEGIN
                L_Despatch.Scanned := TRUE;
                L_Despatch."Scan Date Time" := CURRENTDATETIME;
            END;//Previous Code

            L_Despatch.MODIFY;
            PrintDispatchReport(V_TrolleyNo, L_Despatch."Order No");//Start_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
                                                                    //PrintPick(L_WebDocNo);
                                                                    // CreateJobQueue(L_WebDocNo);
                                                                    // rec.GET(L_Despatch."Entry No.");//Chadan++030720//Causing Issue
        END ELSE BEGIN
            InsertLineIntoDespatchTable(FindNextWebOrder);
        END;
        //CurrPage.UPDATE(FALSE);
    end;

    local procedure FindNextWebOrder(): Code[20]
    var
        L_InterimSalesLine: Record "Interim Sales Line";
        L_Despatch: Record "Despatch Scan Line";
    begin
        L_InterimSalesLine.RESET;
        //L_InterimSalesLine.SetCurrentKey("Bay No.");
        L_InterimSalesLine.SETRANGE("Document Type", L_InterimSalesLine."Document Type"::Order);
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("No.", FindItem(G_ItemNo, 1));
        L_InterimSalesLine.SETRANGE("NAV Variant code", FindItem(G_ItemNo, 2));
        L_InterimSalesLine.SETRANGE("Trolley No.", V_TrolleyNo);
        if G_BayNo <> '' then
            L_InterimSalesLine.SetRange("Bay No.", G_BayNo);
        L_InterimSalesLine.SETRANGE("Dispatch Scan", FALSE);
        IF L_InterimSalesLine.FINDSET THEN
            REPEAT
                L_Despatch.RESET;
                L_Despatch.SETRANGE("Order No", L_InterimSalesLine."Document No");
                IF NOT L_Despatch.FINDFIRST THEN
                    EXIT(L_InterimSalesLine."Document No");
            UNTIL L_InterimSalesLine.NEXT = 0;
    end;

    /*local procedure PrintPick(L_WebDocNo: Code[20])
    var
        L_InterimSalesHeader: Record "Interim Sales Header";
        L_Despatch: Record "Despatch Scan Line";
    begin
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Document Type", L_Despatch."Document Type"::Order);
        L_Despatch.SETRANGE("Order No", L_WebDocNo);
        L_Despatch.SETRANGE(Scanned, FALSE);
        IF NOT L_Despatch.FINDFIRST THEN BEGIN
            L_InterimSalesHeader.RESET;
            L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
            L_InterimSalesHeader.SETRANGE("No.", L_WebDocNo);
            IF L_InterimSalesHeader.FINDFIRST THEN
                REPORT.RUN(90054, FALSE, TRUE, L_InterimSalesHeader);
        END;
    end;*///NG_no_need

    local procedure CreateJobQueue(L_WebDocNo: Code[20])
    var
        JobQueueEntry: Record "Job Queue Entry";
        L_Despatch: Record "Despatch Scan Line";
    begin
        /*JobQueueEntry.INIT;
        JobQueueEntry."Last Ready State" := CURRENTDATETIME;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
        JobQueueEntry."Object ID to Run" := 90054;
        JobQueueEntry.INSERT(TRUE);*/
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Document Type", L_Despatch."Document Type"::Order);
        L_Despatch.SETRANGE("Order No", L_WebDocNo);
        L_Despatch.SETRANGE(Scanned, FALSE);
        IF NOT L_Despatch.FINDFIRST THEN BEGIN
            JobQueueEntry.VALIDATE(ID, CREATEGUID);
            //JobQueueEntry.VALIDATE("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);//NG_Error
            //JobQueueEntry.VALIDATE("Object ID to Run", CODEUNIT::"Dispatch Pick Report - Job");
            JobQueueEntry.VALIDATE("Record ID to Process", rec.RECORDID);
            //JobQueueEntry.VALIDATE("Job Queue Category Code",'NOTIFYNOW');
            //JobQueueEntry.VALIDATE(Priority, 1000);//NG_Error
            //JobQueueEntry.VALIDATE("Parameter String",L_WebDocNo);
            CODEUNIT.RUN(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);

            /*JobQueueEntry.VALIDATE(ID,CREATEGUID);
            JobQueueEntry.VALIDATE("Object Type to Run",JobQueueEntry."Object Type to Run"::Report);
            JobQueueEntry.VALIDATE("Object ID to Run", 90054);
            JobQueueEntry.VALIDATE("Record ID to Process", RECORDID);
            //JobQueueEntry.VALIDATE("Job Queue Category Code",'NOTIFYNOW');
            JobQueueEntry.VALIDATE(Priority,1000);
            JobQueueEntry.VALIDATE("Parameter String",L_WebDocNo);
            JobQueueEntry.VALIDATE("Report Output Type",JobQueueEntry."Report Output Type"::PDF);
            CODEUNIT.RUN(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry);*///Working

        END;

    end;//NG_no_need

    local procedure GetItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        Item.RESET;
        Item.SETRANGE("No.", G_ItemNo);
        IF Item.FINDFIRST THEN
            EXIT(Item."No.");
    end;//NG_no_need

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
    begin
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
        //ak 011220 --
        IF RecInterimSalesLine.FINDSET THEN
            OrderLnneCount := RecInterimSalesLine.COUNT;

        RecDespatch.RESET;
        RecDespatch.SETRANGE("Trolley No", P_TrolleyNo);
        if P_BayNo <> '' then
            RecDespatch.SetRange("Bay No.", P_BayNo);
        RecDespatch.SETRANGE(Scanned, TRUE);
        DespatchCount := RecDespatch.COUNT;

        IF RecDespatch.COUNT = RecInterimSalesLine.COUNT THEN BEGIN
            //IF CONFIRM('All items in this trolley are scanned..\\ Do you want to close Trolley?', TRUE) THEN BEGIN
            if P_BayNo <> '' then
                messagetext := 'Bay'
            else
                messagetext := 'Trolley';
            IF CONFIRM(StrSubstNo(Text001, messagetext), TRUE) THEN BEGIN
                UpdateDispatchedOnWebOrder.UpdatedDispatchOnWebOrderNew(RecDespatch, V_TrolleyNo, G_BayNo, Rec);

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
            END;
        END;

    end;

    local procedure ChangeStyle(L_TrolleyNo: Code[20]; L_weborderNo: Code[20]): Text
    var
        L_Despatch: Record "Despatch Scan Line";
        L_InterimSalesLine: Record "Interim Sales Line";
        TotalSalesLines: Integer;
        TotalDespatchLines: Integer;
    begin
        //Start_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
        CLEAR(TotalDespatchLines);
        CLEAR(TotalSalesLines);
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Trolley No", L_TrolleyNo);
        L_Despatch.SETRANGE(Scanned, TRUE);
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
            EXIT('Ambiguous');

        //END_(CAS-20546-N9C8Y6)_Nikhil_24/06/2020
    end;

    local procedure PrintDispatchReport(L_TrolleyNo: Code[20]; L_weborderNo: Code[20])
    var
        L_Despatch: Record "Despatch Scan Line";
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
        R_DeliveryNote: Report 90072;
        InStm: InStream;
        filename: Text;
    begin
        CLEAR(R_CourierLabel);
        CLEAR(TotalDespatchLines);
        CLEAR(TotalSalesLines);
        L_Despatch.RESET;
        L_Despatch.SETRANGE("Trolley No", L_TrolleyNo);
        L_Despatch.SETRANGE(Scanned, TRUE);
        L_Despatch.SETRANGE("Order No", L_weborderNo);
        IF L_Despatch.FINDSET THEN
            TotalDespatchLines := L_Despatch.COUNT;

        L_InterimSalesLine.RESET;
        L_InterimSalesLine.SETRANGE(Type, L_InterimSalesLine.Type::Item);
        L_InterimSalesLine.SETRANGE("Document No", L_weborderNo);
        L_InterimSalesLine.SETFILTER("Item Type", '<>%1', L_InterimSalesLine."Item Type"::Assembly);
        IF L_InterimSalesLine.FINDSET THEN
            TotalSalesLines := L_InterimSalesLine.COUNT;

        IF TotalDespatchLines = TotalSalesLines THEN BEGIN
            Clear(FileInStream);
            Clear(FileOutStream);
            Clear(outputFileName);
            Clear(TempBlob);
            Clear(FileMgt);
            L_InterimSalesHeader.RESET;
            L_InterimSalesHeader.SETRANGE("No.", L_weborderNo);
            L_InterimSalesHeader.SETRANGE("Document Type", L_InterimSalesHeader."Document Type"::Order);
            IF L_InterimSalesHeader.FINDFIRST THEN BEGIN
                L_ShipmentTracking.Reset();
                L_ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                L_ShipmentTracking.SetRange("Shipping Agent Code", L_InterimSalesHeader."Shipping Agent Code");
                if L_ShipmentTracking.FindFirst() then begin
                    TempBlob.CREATEOUTSTREAM(FileOutStream);
                    R_CourierLabel.SETTABLEVIEW(L_ShipmentTracking);
                    R_CourierLabel.USEREQUESTPAGE(FALSE);
                    R_CourierLabel.SaveAs('', ReportFormat::Pdf, FileOutStream);
                    FileMgt.BLOBExport(TempBlob, L_InterimSalesHeader."No." + '.pdf', true);
                end;
                /* if L_InterimSalesHeader."Trade Partner Code" = 'SHOPDIRECT' then begin
                     L_ShipmentTracking.Reset();
                     L_ShipmentTracking.SetRange("Document No.", L_InterimSalesHeader."No.");
                     if L_ShipmentTracking.FindFirst() then begin
                         L_ShipmentTracking.CalcFields("A6 Label1");
                         L_ShipmentTracking."A6 Label1".CreateInStream(InStm);
                         filename := 'DespatchNote' + '-' + L_InterimSalesHeader."Channel Order ID" + '.pdf';
                         DownloadFromStream(InStm, '', '', '', filename);
                     end;
                 end;*/
                Clear(R_DeliveryNote);
                R_DeliveryNote.SetTableView(L_InterimSalesHeader);
                R_DeliveryNote.UseRequestPage(false);
                R_DeliveryNote.Run();
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

    local procedure ValidateScannedQty(P_TrolleyNo: Text; P_BayNo: Text; P_ItemNo: Code[20])
    var
        L_ItemNo: Code[20];
        L_DispatchedCount: Record "Despatch Scan Line";
        L_VariantCode: Code[20];
    begin
        L_ItemNo := FindItem(P_ItemNo, 1);
        L_VariantCode := FindItem(P_ItemNo, 2);

        TempPickedStock.RESET;
        TempPickedStock.SETRANGE("Item No.", L_ItemNo);
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
        L_DispatchedCount.SetRange("Variant Code", L_VariantCode);

        //L_DispatchedCount.SETRANGE(Scanned,TRUE);code blocked by alok on 201120
        L_DispatchedCount.CALCSUMS("Scanned Quantity", "Trolley closed Quantity");
        /*IF USERID = 'PS-NAV1\ROBOSOL' THEN
          MESSAGE(FORMAT(L_DispatchedCount."Scanned Quantity"));*/
        IF L_DispatchedCount."Scanned Quantity" >= TempPickedStock."Qty. (Base)" THEN
            ERROR('Quantity scanned is not picked');

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



}

