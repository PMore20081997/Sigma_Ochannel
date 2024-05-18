tableextension 90011 "Warehouse Ship Line Ext" extends "Warehouse Shipment Line"
{
    fields
    {
        field(90000; "Trolley No."; Code[20])
        {
        }
        field(90001; "Channel Order ID"; Code[50])
        {
            Editable = false;
        }
        field(90002; "Channel Code"; Code[20])
        {
            Caption = 'Channel Code';
        }
        field(90003; "Parked"; Boolean)
        {
        }
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
}