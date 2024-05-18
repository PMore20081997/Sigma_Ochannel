tableextension 90080 "Reg Whse. Activity Hdr" extends "Registered Whse. Activity Hdr."
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
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Service Code"));
        }
        field(90004; "PO No."; Code[20])
        {
            Editable = false;
        }
        field(90005; "SO No."; Code[20])
        {
            Editable = false;
        }
        field(90006; "Trolley No."; Code[20])
        {
            Caption = 'Trolley No.';
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
            Editable = false;
        }
        field(90011; "Total Outstanding Qty"; Decimal)
        {
            Caption = 'Total No of Items';
            Editable = false;
            DecimalPlaces = 0 : 0;
        }
    }
}