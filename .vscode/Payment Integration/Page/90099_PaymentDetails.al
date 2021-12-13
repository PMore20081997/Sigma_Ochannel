page 90099 "Payment Detail"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Payment Detail";
    Editable = true;
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
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                }

                field("Web Payment Method Code"; Rec."Web Payment Method Code 2")
                {
                    ApplicationArea = All;
                    Caption = 'Web Payment Method Code';
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
    var
        test: Page 379;

}