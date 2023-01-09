codeunit 90018 TransferAssemblyCommentsToPick
{
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnBeforeWhseActivHeaderInsert', '', false, false)]
    // local procedure OnCreateWhseActivHeaderOnAfterWhseActivHeaderInsert(var TempWhseActivLine: Record "Warehouse Activity Line"; var WhseActivHeader: Record "Warehouse Activity Header")
    local procedure OnBeforeWhseActivHeaderInsert(var WarehouseActivityHeader: Record "Warehouse Activity Header"; var TempWhseActivityLine: Record "Warehouse Activity Line" temporary; CreatePickParameters: Record "Create Pick Parameters"; WhseShptLine: Record "Warehouse Shipment Line")
    var
        AssemblyHeader: Record "Assembly Header";
        trs: Page 7345;
    begin
        if TempWhseActivityLine.FindFirst() then begin
            if (TempWhseActivityLine."Whse. Document Type" = TempWhseActivityLine."Whse. Document Type"::Assembly) And (FromWorksheet = true) then begin
                WarehouseActivityHeader.Validate(Comments, Comments);
            end
            else
                if TempWhseActivityLine."Whse. Document Type" = TempWhseActivityLine."Whse. Document Type"::Assembly then begin
                    AssemblyHeader.Reset();
                    AssemblyHeader.SetRange("No.", TempWhseActivityLine."Source No.");
                    if AssemblyHeader.FindFirst() then begin
                        WarehouseActivityHeader.Comments := AssemblyHeader.Comments;
                    end;
                end;
        end;
        FromWorksheet := false;
        Clear(Comments);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Create Pick", 'OnBeforeOnRun', '', false, false)]
    local procedure OnBeforeOnRun(var WhseWorksheetLine: Record "Whse. Worksheet Line"; var IsHandled: Boolean);
    begin
        Comments := WhseWorksheetLine.Comments;
        FromWorksheet := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Pick", 'OnCreateAssemblyPickLineOnAfterCalcQtyToPick', '', false, false)]
    local procedure OnCreateAssemblyPickLineOnAfterCalcQtyToPick(var AsmLine: Record "Assembly Line"; var QtyToPickBase: Decimal; var QtyToPick: Decimal)
    begin
        Clear(Comments);
        Clear(FromWorksheet);
    end;

    var
        Comments: Text[250];
        FromWorksheet: Boolean;
        Reports: Report "Create Pick";
        p: page "Assembly Order";
}
