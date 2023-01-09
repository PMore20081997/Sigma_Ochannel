tableextension 90002 "Sales Cue Ext" extends "Sales Cue"
{
    fields
    {
        // Add changes to table fields here
        field(90000; "Orders Received Today"; Integer)
        {
            AccessByPermission = TableData "Interim Sales Header" = R;
            CalcFormula = Count("Interim Sales Header" WHERE("Document Type" = const(Order),
                                                      "Document Date" = field("Channel Date Filter")));

            Caption = 'Orders Received Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90001; "Released for Pick Today"; Integer)
        {
            AccessByPermission = TableData "Whse. Internal Pick Header" = R;
            CalcFormula = Count("Whse. Internal Pick Header" WHERE("Created Date" = field("Channel Date Filter")));
            Caption = 'Released for Pick Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90002; "In Pick Today"; Integer)
        {
            AccessByPermission = TableData "Warehouse Activity Header" = R;
            CalcFormula = Count("Warehouse Activity Header" WHERE(Type = const(Pick), "Created Date" = field("Channel Date Filter")));

            Caption = 'In Pick Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90003; "Picked Today"; Integer)
        {
            AccessByPermission = TableData "Registered Whse. Activity Hdr." = R;
            CalcFormula = Count("Registered Whse. Activity Hdr." WHERE(Type = const(Pick), "Created Date" = field("Channel Date Filter")));

            Caption = 'Picked Today';
            Editable = false;
            FieldClass = FlowField;
        }

        field(90004; "Shipments Today"; Integer)
        {
            AccessByPermission = TableData "Handled Interim Sales Header" = R;
            CalcFormula = Count("Handled Interim Sales Header" WHERE("Document Type" = const(Order), "Order Date" = field("Channel Date Filter")));

            Caption = 'Shipments Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90005; "Returns Today"; Integer)
        {
            AccessByPermission = TableData "Sales Header" = R;
            CalcFormula = Count("Sales Header" WHERE("Document Type" = const("Return Order"), "Order Date" = field("Channel Date Filter")));

            Caption = 'Returns Today';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90006; "Total Outstanding"; Integer)
        {
            AccessByPermission = TableData "Interim Sales Header" = R;
            CalcFormula = Count("Interim Sales Header" WHERE("Destination Doc No." = const('')));

            Caption = 'Total Outstanding';
            Editable = false;
            FieldClass = FlowField;
        }
        field(90007; "Channel Date Filter"; Date)
        {
        }
    }


    var
        myInt: Integer;

    procedure GetInPickToday()
    var
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        TodayDate: Date;
        TodayTime: Time;
        CreateDate: DateTime;
    begin
        TodayDate := Today;
        TodayTime := Time;
        CreateDate := CreateDateTime(TodayDate, Time);
        WarehouseActivityHeader.Reset();
        WarehouseActivityHeader.SetRange(Type, WarehouseActivityHeader.Type::Pick);
        WarehouseActivityHeader.SetFilter(SystemCreatedAt, '');
        if WarehouseActivityHeader.FindSet() then;
        Rec."In Pick Today" := WarehouseActivityHeader.Count;
        Rec.Modify();
    end;
}