tableextension 90016 WarehouseSourceFilter extends "Warehouse Source Filter"
{
    fields
    {
        field(90000; "No. Of Orders to Process"; Integer)
        {
            Caption = 'No. Of Orders to Process';
            DataClassification = ToBeClassified;
        }
        field(90001; "Default No. Of Orders"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(90002; "No of Document"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    procedure CheckNoOfOrdersValidationToCreateMultipleShipment(var WarehouseSourceFilter: Record "Warehouse Source Filter")
    var
        WhseSrcFilter: Record "Warehouse Source Filter";
    begin
        if WarehouseSourceFilter."No of Document" > WarehouseSourceFilter."No. Of Orders to Process" then begin
            Error('%1 can not be greater than %2', WarehouseSourceFilter.FieldCaption("No of Document"), WarehouseSourceFilter.FieldCaption("No. Of Orders to Process"));
        end;
    end;
}
