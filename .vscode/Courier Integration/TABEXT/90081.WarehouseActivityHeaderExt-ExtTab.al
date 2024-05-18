tableextension 90081 "Warehouse Activity Header Ext" extends "Warehouse Activity Header"
{
    fields
    {
        field(90000; "No. of Boxes"; Decimal)
        {
        }
        field(90001; "Total weight (consignment)"; Decimal)
        {
        }
        field(90002; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent".Code;
        }
        field(90003; "Shipping Agent Service Code"; Code[20])
        {
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(90004; "PO No."; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Warehouse Activity Line"."Source No." where("Activity Type" = filter("Put-away"), "No." = field("No."), "Source Document" = filter("Purchase Order")));
        }
        field(90005; "SO No."; Code[20])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Warehouse Activity Line"."Source No." where("Activity Type" = filter(Pick), "No." = field("No."), "Source Document" = filter("Sales Order")));
        }
        field(90006; "Trolley No."; Code[20])
        {
            Editable = true;
        }
        field(90007; "Trolley Closed"; Boolean)
        {
            Caption = '"Trolley Closed"';
        }
        field(90008; "Created Date"; Date)
        {
            Editable = false;
        }
        field(90009; Comments; Text[250])
        {
            Caption = 'Comments';
            DataClassification = ToBeClassified;
        }
        field(90010; "No. of Take lines"; Integer)
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
        field(90011; "Total Outstanding Qty"; Decimal)
        {
            FieldClass = FlowField;
            Caption = 'Total No of Items';
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
    }
}