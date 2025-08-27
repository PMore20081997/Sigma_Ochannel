page 90052 "Handled Orders"
{
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    SourceTable = "Handled Interim Sales Header";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                Editable = false;
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(ChannelOrderID; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("ET Access Code"; Rec."ET Access Code")
                {
                    ApplicationArea = all;
                }

                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = all;
                }
                field("Order Placed At"; Rec."Order Placed At")
                {
                    ApplicationArea = all;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = all;
                }
                field(status; Rec.status)
                {
                    ApplicationArea = all;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Reason Message"; Rec."Reason Message")
                {
                    ApplicationArea = All;
                }
            }

        }
    }
}