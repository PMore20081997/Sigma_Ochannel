tableextension 90081 "Warehouse Activity Header Ext" extends "Warehouse Activity Header"
{
    fields
    {
        field(50000; "No. of Boxes"; Decimal)
        {

        }
        field(50001; "Total weight (consignment)"; Decimal)
        {

        }
        field(50002; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent".Code;

        }
        field(50004; "Shipping Agent Service Code"; Code[20])
        {
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(50005; "PO No."; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Warehouse Activity Line"."Source No." where("Activity Type" = filter("Put-away"), "No." = field("No."), "Source Document" = filter("Purchase Order")));
        }
        field(50006; "SO No."; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Warehouse Activity Line"."Source No." where("Activity Type" = filter(Pick), "No." = field("No."), "Source Document" = filter("Sales Order")));
        }
        //Ochannel++
        field(90001; "Trolley No."; Code[20])
        {
            Editable = false;
        }
        //Ochannel--
    }
}