//CAS-26633-Z8W1Y1.MH

codeunit 90030 EventSubscribers
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Jnl.-Register Line", 'OnInitWhseEntryCopyFromWhseJnlLine', '', true, true)]
    local procedure UpdateChannelCode(var WarehouseEntry: Record "Warehouse Entry"; var WarehouseJournalLine: Record "Warehouse Journal Line")
    begin
        WarehouseEntry."Trade Partner Code" := WarehouseJournalLine."Trade Partner Code";
    end;
   
    

    
    var
        myInt: Integer;
}