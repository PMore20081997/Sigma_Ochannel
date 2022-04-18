page 90090 "Archive Payment Detail"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Archive Payment Detail";
    Editable = false;
    Caption = 'Archive Payment Details';
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                }

                field("Web Payment Method Code"; Rec."Web Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("NAV Payment Method Code"; Rec."NAV Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Gross Amount"; Rec."Gross Amount")
                {
                    ApplicationArea = All;
                }
                field(Fees; Rec.Fees)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 2;
                    Caption = 'Net Amount';
                }
                field("Journal Created"; Rec."Journal Created")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Lines Created';
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = All;
                }

            }
        }
    }


}