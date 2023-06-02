codeunit 90017 NoOfOrders
{
    SingleInstance = true;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse.-Create Source Document", 'OnAfterCreateShptLineFromSalesLine', '', false, false)]
    local procedure OnAfterCreateShptLineFromSalesLine(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        WarehouseRequest: Record "Warehouse Request";
        WhseShptHdr: Record "Warehouse Shipment Header";
    begin
        WarehouseRequest.Reset();
        WarehouseRequest.SetRange("Source No.", SalesHeader."No.");
        WarehouseRequest.SetRange("Source Document", WarehouseRequest."Source Document"::"Sales Order");
        if WarehouseRequest.FindFirst() then begin
            WarehouseRequest."Shipment Created" := True;
            WarehouseRequest.Modify();
        end;

        // Inserting into temp table to create Pick 
        if AutoReleaseWarehouseShipment then begin
            TempSalesHeader.Reset();
            TempSalesHeader.SetRange("No.", WarehouseShipmentHeader."No.");
            if not TempSalesHeader.FindFirst() then begin
                TempSalesHeader.Init();
                TempSalesHeader."No." := WarehouseShipmentHeader."No.";
                TempSalesHeader.Insert()
            end;
        end;
    end;



    [EventSubscriber(ObjectType::Table, DataBase::"Warehouse Shipment Line", 'OnBeforeCreatePickDoc', '', false, false)]
    local procedure OnBeforeCreatePickDoc(var WarehouseShipmentLine: Record "Warehouse Shipment Line"; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; HideValidationDialog: Boolean; var IsHandled: Boolean)
    begin

        // To hid request page of pick report
        if AutoReleaseWarehouseShipment then begin
            HideValidationDialog := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Warehouse Source Filter", 'OnBeforeSetTableView', '', false, false)]
    local procedure OnBeforeSetTableView(var WarehouseRequest: Record "Warehouse Request"; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var PurchaseLine: Record "Purchase Line"; var TransferLine: Record "Transfer Line"; var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line"; var WarehouseSourceFilter: Record "Warehouse Source Filter"; var PurchaseHeader: Record "Purchase Header")
    begin
        WarehouseRequest.SetFilter("Shipment Created", '%1', false);
        NoOfOrderToProcess := WarehouseSourceFilter."No. Of Orders to Process";
        ServiceCode := WarehouseSourceFilter."Shipping Agent Service Filter";
        AgentCode := WarehouseSourceFilter."Shipping Agent Code Filter";
        CustomerCode := WarehouseSourceFilter."Sell-to Customer No. Filter";

        // To create multiple warhouse shipment 
        if WarehouseSourceFilter."No of Document" > 1 then begin
            NoOfDocument := WarehouseSourceFilter."No of Document";
            NoOfDocumnetCreated := 1;
            BreakLoop := Round(WarehouseSourceFilter."No. Of Orders to Process" / WarehouseSourceFilter."No of Document", 1, '<');
            BreakLoopCopy := BreakLoop;
            CreateMultipleShipment := true;
        end else
            CreateMultipleShipment := false;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnAfterSalesHeaderOnAfterGetRecord', '', false, false)]
    local procedure OnAfterSalesHeaderOnAfterGetRecord(SalesHeader: Record "Sales Header"; var SkipRecord: Boolean; var BreakReport: Boolean; var WarehouseRequest: Record "Warehouse Request")

    begin
        // Orders += SalesHeader."No." + '|';
        if (AgentCode = WarehouseRequest."Shipping Agent Code") and (CustomerCode = SalesHeader."Sell-to Customer No.") then begin
            if (ServiceCode = WarehouseRequest."Shipping Agent Service Code") or (ServiceCode = '') then begin
                if NoOfOrderToProcess <= 0 then
                    BreakReport := true;
                NoOfOrderToProcess -= 1;

                // To create multiple warhouse shipment 
                if CreateMultipleShipment then begin
                    BreakLoopCopy -= 1;
                    if NoOfDocument <> NoOfDocumnetCreated then begin
                        if BreakLoopCopy < 0 then begin
                            CreateShipmentHeadr := true;
                            BreakLoopCopy := BreakLoop - 1;
                            NoOfDocumnetCreated += 1;
                        end
                        else
                            CreateShipmentHeadr := false;
                    end else
                        CreateShipmentHeadr := false;
                end;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforePostReport', '', false, false)]
    local procedure OnBeforePostReport(WhseRequest: Record "Warehouse Request"; RequestType: Option; OneHeaderCreated: Boolean; var WhseShptHeader: Record "Warehouse Shipment Header"; var WhseHeaderCreated: Boolean; var ErrorOccured: Boolean; var LineCreated: Boolean; var ActivitiesCreated: Integer; Location: record Location; var WhseShptLine: record "Warehouse Shipment Line"; var WhseReceiptHeader: Record "Warehouse Receipt Header"; var HideDialog: Boolean)
    begin
        //  To update the Warehose shipment pop up message
        if IncreaseWhsDocumentNo then
            ActivitiesCreated += 1;
    end;

    //Bug 12946++
    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnBeforeWhseShptHeaderInsert', '', false, false)]
    local procedure OnBeforeWhseShptHeaderInsert(var WarehouseShipmentHeader: Record "Warehouse Shipment Header")
    begin
        Clear(WarehouseShipmentHeader."External Document No.");
    end;
    //Bug 12946--

    [EventSubscriber(ObjectType::Report, Report::"Get Source Documents", 'OnSalesLineOnAfterGetRecordOnBeforeCreateShptHeader', '', false, false)]
    local procedure OnSalesLineOnAfterGetRecordOnBeforeCreateShptHeader(SalesLine: Record "Sales Line"; var WarehouseRequest: Record "Warehouse Request"; var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WhseHeaderCreated: Boolean; var OneHeaderCreated: Boolean; var IsHandled: Boolean)

    begin
        // To create multiple warhouse shipment 
        if CalledFromMultipleShipment then begin
            if CreateShipmentHeadr then
                OneHeaderCreated := false
            else
                OneHeaderCreated := true;
        end;
    end;

    procedure UpdateWarehouseRequestOnDeleteWhseShipmentLines(var WhseShipmentLine: Record "Warehouse Shipment Line"; Created: Boolean)
    var
        WarehouseRequest: Record "Warehouse Request";
    begin
        WarehouseRequest.Reset();
        WarehouseRequest.SetRange(WarehouseRequest."Source No.", WhseShipmentLine."Source No.");
        WarehouseRequest.SetFilter(WarehouseRequest."Shipment Created", '%1', true);
        WarehouseRequest.SetFilter(WarehouseRequest."Completely Handled", '%1', false);
        if WarehouseRequest.FindFirst() then begin
            WarehouseRequest."Shipment Created" := Created;
            WarehouseRequest.modify();
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Warehouse Shipment Header", 'OnBeforeWhseShptLineDelete', '', false, false)]
    local procedure OnBeforeWhseShptLineDelete(var WarehouseShipmentLine: Record "Warehouse Shipment Line")
    begin
        UpdateWarehouseRequestOnDeleteWhseShipmentLines(WarehouseShipmentLine, false);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Filters to Get Source Docs.", 'OnAfterActionEvent', 'Run', false, false)]
    local procedure OnAfterActionEvent()
    var
        WhseShptHdr: Record "Warehouse Shipment Header";
        WhseShptLn: Record "Warehouse Shipment Line";
        WhseShipmentRelease: Codeunit "Whse.-Shipment Release";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        WarehouseActivityLine: Record "Warehouse Activity Line";
        TempWarehouseActivityHeader: Record "Warehouse Activity Header" temporary;
    begin
        Clear(PickNo);
        CalledFromMultipleShipment := false;
        IncreaseWhsDocumentNo := false;
        AutoReleaseWarehouseShipment := false;
        // Create pick from temporary warehouse shipment table
        TempSalesHeader.Reset();
        if TempSalesHeader.FindSet() then begin
            repeat
                if WhseShptHdr.Get(TempSalesHeader."No.") then begin
                    WhseShptHdr.Validate(Comments, Comments);
                    WhseShptHdr.Modify();
                    WhseShipmentRelease.Release(WhseShptHdr);
                    WhseShptLn.Reset();
                    WhseShptLn.SetRange("No.", WhseShptHdr."No.");
                    if WhseShptLn.FindSet() then begin
                        if not CreatePickDocFromWhseShpt(WhseShptLn, WhseShptHdr, true) then begin
                            WhseShptHdr."Pick Remarks" := CopyStr(GetLastErrorText(), 1, 250);
                            WhseShptHdr.Modify();

                        end else begin
                            WarehouseActivityLine.Reset();
                            WarehouseActivityLine.SetRange("Whse. Document No.", WhseShptLn."No.");
                            if WarehouseActivityLine.FindFirst() then begin
                                WarehouseActivityHeader.Reset();
                                WarehouseActivityHeader.SetRange("No.", WarehouseActivityLine."No.");
                                if WarehouseActivityHeader.FindFirst() then begin
                                    WarehouseActivityHeader.Validate("Sorting Method", WarehouseActivityHeader."Sorting Method"::"Bin Ranking");
                                    WarehouseActivityHeader.Modify(true);
                                    PickNo += WarehouseActivityHeader."No." + '|';
                                end;
                            end;
                        end;
                    end;
                end;
            until TempSalesHeader.Next() = 0;

            PickNo := DelStr(PickNo, StrLen(PickNo), StrLen(PickNo));
            WarehouseActivityHeader.Reset();
            WarehouseActivityHeader.SetFilter("No.", PickNo);
            if WarehouseActivityHeader.FindSet() then begin
                Report.Run(5752, false, false, WarehouseActivityHeader);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Filters to Get Source Docs.", 'OnBeforeActionEvent', 'Run', false, false)]
    local procedure OnBeforeActionEvent(var Rec: Record "Warehouse Source Filter")
    begin
        Clear(NoOfDocumnetCreated);
        Clear(NoOfDocument);
        CalledFromMultipleShipment := true;
        Comments := Rec.Description;
        AutoReleaseWarehouseShipment := true;
        CreateMultipleShipment := false;
        CreateShipmentHeadr := false;
        if Rec."No of Document" > 1 then
            IncreaseWhsDocumentNo := true;

        TempSalesHeader.Reset();
        if TempSalesHeader.FindSet() then
            TempSalesHeader.DeleteAll(true);
    end;

    var
        IncreaseWhsDocumentNo: Boolean;
        NoOfOrderToProcess: Integer;
        ServiceCode: code[100];
        AgentCode: code[100];
        CustomerCode: Code[100];
        BreakLoop: Integer;
        NoOfDocumnetCreated: Integer;
        NoOfDocument: Integer;
        BreakLoopCopy: Integer;
        CreateShipmentHeadr: Boolean;
        CreateMultipleShipment: Boolean;
        Orders: Text;
        AutoReleaseWarehouseShipment: Boolean;
        TempWarehouseShipmentHeader: Record "Warehouse Shipment Header" temporary;
        Comments: Text;
        PickNo: Text;
        TempSalesHeader: Record "Sales Header" temporary;

        CalledFromMultipleShipment: Boolean;


    [TryFunction]
    local procedure CreatePickDocFromWhseShpt(var WhseShptLine: Record "Warehouse Shipment Line"; WhseShptHeader: Record "Warehouse Shipment Header"; HideValidationDialog: Boolean)
    var
        WhseShipmentCreatePick: Report "Whse.-Shipment - Create Pick";
        SortActivity2: Enum "Whse. Activity Sorting Method";
    begin
        WhseShipmentCreatePick.SetWhseShipmentLine(WhseShptLine, WhseShptHeader);
        WhseShipmentCreatePick.SetHideValidationDialog(false);
        WhseShipmentCreatePick.UseRequestPage(not HideValidationDialog);
        WhseShipmentCreatePick.RunModal();
        Clear(WhseShipmentCreatePick);

    end;

}
