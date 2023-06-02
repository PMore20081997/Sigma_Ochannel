tableextension 90011 "Warehouse Ship Line Ext" extends "Warehouse Shipment Line"
{
    fields
    {
        field(90000; "Trolley No."; Code[20])
        {
            //Editable = false;
            //     FieldClass = FlowField;
            //   CalcFormula = lookup("Warehouse Shipment Header"."Trolley No." where("No." = field("No.")));
        }
        field(90001; "Channel Order ID"; Code[50])
        {
            Editable = false;
        }
        field(90002; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
        }
        // field(90003; "Quantity Scanned"; Decimal)
        // {
        //     FieldClass = FlowField;
        //     CalcFormula = sum("Despatch Scan Line"."Scanned Quantity" where("Trolley No" = field("Trolley No."),
        //                                                                     "Item No." = field("Item No."),
        //                                                                     "Channel Order Id" = field("Channel Order ID")));
        // }
        field(90004; "Line Status"; Option)
        {
            OptionMembers = " ","No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
            Editable = false;
        }
        field(90005; "Dispatch Scan"; Boolean)
        {
            Caption = 'Hide from Dispatch Scan';
        }
        field(90006; "Scanned Date"; DateTime)
        {

        }
        field(90007; "Trolley Closed Quantity"; Decimal)
        {

        }
        field(90008; "Bay No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(90003; "Parked"; Boolean)
        {
            // FieldClass = FlowField;
            // CalcFormula = lookup("Interim Sales Line".Parked where("Channel Order ID" = field("Channel Order ID"), "No." = field("Item No."), "Document Type" = filter(Order), "Trolley No." = field("Trolley No.")));
        }

        field(90009; "Scanned Quantity"; Decimal)
        {

        }
        field(90010; "Scanned By"; Code[250])
        {

        }
        field(90011; "Scan Station"; Code[250])
        {

        }
        field(90012; "Scan Status"; Option)
        {
            OptionMembers = " ",Scanned,Parked,Cancelled;
            OptionCaptionML = ENU = ' ,Scanned,Parked,Cancelled',
                              ENG = ' ,Scanned,Parked,Cancelled';
        }
        field(90013; "User ID"; Code[250])
        {

        }

    }
    trigger OnDelete()
    var
        NoofOrders: Codeunit NoOfOrders;
    
    begin
        NoofOrders.UpdateWarehouseRequestOnDeleteWhseShipmentLines(Rec, false);
    end;
}