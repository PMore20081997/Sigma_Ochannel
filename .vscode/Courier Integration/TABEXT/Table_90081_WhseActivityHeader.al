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
        field(50007; "Created Date"; Date)
        {
            Editable = false;
        }
        field(90002; Comments; Text[250])
        {
            Caption = 'Comments';
            DataClassification = ToBeClassified;
        }
        field(90003; "No. of Take lines"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("Warehouse Activity Line" WHERE("Activity Type" = FIELD(Type),
                                                                "Action Type" = filter(Take),
                                                                 "No." = FIELD("No."),
                                                                 "Source Type" = FIELD("Source Type Filter"),
                                                                 "Source Subtype" = FIELD("Source Subtype Filter"),
                                                                 "Source No." = FIELD("Source No. Filter"),
                                                                 "Location Code" = FIELD("Location Filter")));
            Editable = false;

        }
        field(90004; "Total Outstanding Qty"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Warehouse Activity Line"."Qty. Outstanding" WHERE("Activity Type" = FIELD(Type),
                                                                "Action Type" = filter(Take),
                                                                 "No." = FIELD("No."),
                                                                 "Source Type" = FIELD("Source Type Filter"),
                                                                 "Source Subtype" = FIELD("Source Subtype Filter"),
                                                                 "Source No." = FIELD("Source No. Filter"),
                                                                 "Location Code" = FIELD("Location Filter")));
            Editable = false;
            DecimalPlaces = 0 : 0;

        }
        //Ochannel--
    }
}