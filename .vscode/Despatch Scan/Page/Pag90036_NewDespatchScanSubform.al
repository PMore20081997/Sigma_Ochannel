page 90036 "Despatch Lines"
{
    DelayedInsert = true;
    DeleteAllowed = false;
    PageType = ListPart;
    InsertAllowed = false;
    SourceTable = "Warehouse Shipment Line";
    SourceTableView = where("Dispatch Scan" = filter(false), Parked = filter(false));
    layout
    {
        area(content)
        {
            repeater("Group")
            {
                Editable = false;
                field("Channel Code"; Rec."Channel Code")
                {
                    Caption = 'Channel Partner Code';
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Channel Order ID"; rec."Channel Order ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Item No."; rec."Item No.")
                {
                    StyleExpr = Styletext;
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                    Visible = false;

                }
                field(Description; rec.Description)
                {

                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Bay No."; Rec."Bay No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bay No. field.';
                }

                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Order Quantity';
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Qty. Picked"; rec."Qty. Picked")
                {
                    Caption = 'Total Picked Quantity';
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scanned Quantity"; Rec."Scanned Quantity")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }

                field("Scan Status"; Rec."Scan Status")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scanned By"; Rec."Scanned By")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scan Station"; Rec."Scan Station")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
                field("Scanned Date"; Rec."Scanned Date")
                {
                    ApplicationArea = All;
                    StyleExpr = Styletext;
                }
            }
        }

    }

    trigger OnOpenPage()
    begin

        //Rec.RESET;
        // Rec.SETRANGE("Scanned By", USERID);
        Rec.SetRange("User ID", UserId);
        Rec.SetRange(Parked, false);
        Rec.SetFilter("Scan Status", '<>%1', Rec."Scan Status"::Cancelled);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.SetFilter("Scan Status", '<>%1', Rec."Scan Status"::Cancelled);
        Rec.SetRange(Parked, false);
        if Rec."Scan Status" = Rec."Scan Status"::Scanned then
            Styletext := 'Favorable'
        else
            Styletext := 'Standard';

        if Rec."Scan Status" = Rec."Scan Status"::Parked then
            Styletext := 'Attention';


        CurrPage.Update(false);
    end;

    procedure Setfilter(P_TrolleyNo: Code[20]; P_UserID: Code[50]; P_OrderNo: Code[20])
    var

    begin
        Rec.RESET;
        //  Rec.ASCENDING(FALSE);
        Rec.SETRANGE("Scanned By", P_UserID);
        Rec.SetRange("Trolley No.", P_TrolleyNo);
        if P_OrderNo <> '' then
            Rec.SetRange("Channel Order ID", P_OrderNo);
    end;

    procedure GetDetailsFromHeader()
    var
        WSL: Record "Warehouse Shipment Line";
    begin
        Clear(WSL);
        WSL := Rec;
        CurrPage.SetSelectionFilter(WSL);
        if WSL.FindSet() then
            repeat
                if WSL."Scanned Quantity" > 0 then begin
                    WSL."Scanned Quantity" -= 1;
                    WSL."Scan Status" := WSL."Scan Status"::" ";
                    WSL."Dispatch Scan" := false;
                    Clear(WSL."Scanned Date");
                    if WSL."Scanned Quantity" = 0 then begin
                        Clear(WSL."Scanned By");
                        Clear(WSL."User ID");
                    end;
                    WSL.Modify();
                end
            until WSL.Next() = 0;
    end;

    procedure CancelLine()
    var
        WSL: Record "Warehouse Shipment Line";
        HISL: Record "Handled Interim Sales Line";
        WSL2: Record "Warehouse Shipment Line";
        WsL3: Record "Warehouse Shipment Line";
        OrderCount: Integer;
        CancelLineCount: Integer;
        P_DispatchHeader: Record "Despatch Scan Header";
        WhseRelease: Codeunit "Whse.-Shipment Release";
        SalesRelease: Codeunit "Release Sales Document";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        WhseShptLnDelte: Record "Warehouse Shipment Line";
    begin
        Clear(WSL);
        Clear(OrderCount);
        Clear(CancelLineCount);
        WarehouseShipmentHeader.Get(Rec."No.");
        WhseRelease.Reopen(WarehouseShipmentHeader);
        SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Source No.");
        SalesRelease.Reopen(SalesHeader);
        WSL := Rec;
        CurrPage.SetSelectionFilter(WSL);
        if WSL.FindSet() then begin
            repeat
                WSL."Scan Status" := WSL."Scan Status"::Cancelled;
                WSL."Scanned Quantity" := 0;
                WSL.Modify();
                HISL.Reset();
                HISL.SetRange("Document Type", HISL."Document Type"::Order);
                HISL.SetRange("Channel Order ID", WSL."Channel Order ID");
                HISL.SetRange("No.", WSL."Item No.");
                if HISL.FindFirst() then begin
                    HISL."Line Status" := HISL."Line Status"::Cancelled;
                    HISL.Modify();
                end;
            until WSL.Next() = 0;
        end;
        WSL2.Reset();
        WSL2.SetRange("Trolley No.", WSL."Trolley No.");
        WSL2.SetRange("Channel Order ID", WSL."Channel Order ID");
        if WSL2.FindSet() then
            OrderCount := WSL2.Count;

        WsL3.Reset();
        WsL3.SetRange("Trolley No.", WSL."Trolley No.");
        WsL3.SetRange("Channel Order ID", WSL."Channel Order ID");
        WsL3.SetRange("Scan Status", WSL."Scan Status"::Cancelled);
        if WsL3.FindSet() then
            CancelLineCount := WsL3.Count;

        if OrderCount > 0 then
            if OrderCount = CancelLineCount then begin
                P_DispatchHeader.SetRange("Trolley No", WSL."Trolley No.");
                P_DispatchHeader.SetRange("User ID", UserId);
                if P_DispatchHeader.FindFirst() then begin
                    Clear(P_DispatchHeader."Order No");
                    P_DispatchHeader.Modify();
                end;
            end;

        repeat
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", WsL3."Source No.");
            SalesLine.SetRange("Line No.", WsL3."Source Line No.");
            if SalesLine.FindFirst() then begin
                WsL3.Delete(true);
                SalesLine.Validate(Quantity, 0);
                SalesLine.Modify(true)
            end;
        until WsL3.Next() = 0;
        WhseRelease.Release(WarehouseShipmentHeader);
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", WsL3."Source No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>%1', 0);
        if SalesLine.FindFirst() then
            SalesRelease.ReleaseSalesHeader(SalesHeader, false)

    end;

    procedure OpenWebOrder()
    var
        L_HandledInterimSalesHdr: Record "Handled Interim Sales Header";
        L_ScanLine: Record "Warehouse Shipment Line";
        Page_L_HandledWebCard: Page "Handle Web Order";
    begin
        Clear(L_ScanLine);
        L_ScanLine := Rec;
        CurrPage.SetSelectionFilter(L_ScanLine);

        if L_ScanLine.FindSet() then begin
            if L_ScanLine.Count = 1 then begin
                Clear(Page_L_HandledWebCard);
                L_HandledInterimSalesHdr.Reset();
                L_HandledInterimSalesHdr.SetRange("No.", Rec."Source No.");
                if L_HandledInterimSalesHdr.FindFirst() then begin
                    Page_L_HandledWebCard.SetTableView(L_HandledInterimSalesHdr);
                    Page_L_HandledWebCard.Run();
                end;
            end;
        end;
    end;

    var
        Styletext: Text;

}

