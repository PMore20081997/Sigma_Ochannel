pageextension 90006 FilterstoGetSourceDocsExt extends "Filters to Get Source Docs."
{
    layout
    {
        addafter(General)
        {
            field(TotalNoOfOrders; TotalNoOfOrders)
            {
                ApplicationArea = Warehouse;
                Caption = 'Total No. Of Orders';
                Editable = false;
            }
            field(NoofOrderstoProcess; NoofOrderstoProcess)
            {
                ApplicationArea = Warehouse;
                Caption = 'No. Of Orders to Process';
                trigger OnValidate()
                begin
                    Rec."No. Of Orders to Process" := NoofOrderstoProcess;
                end;
            }
        }

    }

    trigger OnAfterGetCurrRecord()
    var
        WarehouseRequest: Record "Warehouse Request";
    begin
        Clear(TotalNoOfOrders);
        if Rec."Sales Orders" then Begin
            WarehouseRequest.Reset();
            if Rec."Shipping Agent Code Filter" <> '' then
                WarehouseRequest.SetRange("Shipping Agent Code", Rec."Shipping Agent Code Filter");
            if Rec."Shipping Agent Service Filter" <> '' then
                WarehouseRequest.SetRange("Shipping Agent Service Code", Rec."Shipping Agent Service Filter");
            if Rec."Customer No. Filter" <> '' then
                WarehouseRequest.SetRange("Destination No.", Rec."Customer No. Filter");
            WarehouseRequest.SetFilter("Shipment Created", '%1', false);
            WarehouseRequest.SetRange("Document Status", WarehouseRequest."Document Status"::Released);
            If WarehouseRequest.FindSet() then begin
                TotalNoOfOrders := WarehouseRequest.Count;
            end;
            Rec."No. Of Orders to Process" := Rec."Default No. Of Orders";
            NoofOrderstoProcess := Rec."Default No. Of Orders";
            CurrPage.Update(false);
        End
    end;

    var
        NoofOrderstoProcess: Integer;
        TotalNoOfOrders: Integer;
}
