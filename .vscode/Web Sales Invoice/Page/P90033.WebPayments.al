//Robosol.MH

page 90033 "Web Payments"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Web Payment";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;

                }
                field("Web Payment Method"; Rec."Web Payment Method")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field("NAV Payment Method"; rec."NAV Payment Method")
                {
                    ApplicationArea = All;
                    Caption = 'PK';
                }
                field("NAV Payment Method 2"; Rec."NAV Payment Method 2")
                {
                    ApplicationArea = All;
                    Caption = 'BC Payment Method';
                }
                field("Payment Service Customer No."; Rec."Payment Service Customer No.")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }
}