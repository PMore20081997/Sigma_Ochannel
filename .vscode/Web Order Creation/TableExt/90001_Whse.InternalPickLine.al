tableextension 90001 "Whse. Internal Pick Line Ext" extends "Whse. Internal Pick Line"
{

    fields
    {
        field(90000; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
        }
        field(90001; "Existing Order"; Boolean)
        {
            Caption = '"Existing Order"';
        }
        field(90002; "Channel Order ID"; Code[50])
        {

        }
        field(90003; "Bay No."; Code[20])
        {

        }
        field(90004; "Trolley No."; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Whse. Internal Pick Header"."Trolley No." where("No." = field("No.")));
        }
        field(90005; "Quantity Scanned"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Despatch Scan Line"."Scanned Quantity" where("Trolley No" = field("Trolley No."),
                                                                            "Item No." = field("Item No."),
                                                                            "Channel Order Id" = field("Channel Order ID")));
        }
        field(90006; "Line Status"; Option)
        {
            OptionMembers = " ","No Stock",Cancelled;
            OptionCaptionML = ENU = ' ,"No Stock",Cancelled',
                              ENG = ' ,"No Stock",Cancelled';
            Editable = false;
        }

    }
    keys
    {
        key(Key8; "Bay No.")
        {

        }
    }
    var
        myInt: Integer;
}