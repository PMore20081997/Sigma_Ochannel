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
                field("Web Payment Method"; REc."Web Payment Method")
                {
                    ApplicationArea = All;
                }
                field("NAV Payment Method 2"; Rec."NAV Payment Method 2")
                {
                    ApplicationArea = All;
                    Caption = 'NAV Payment Method';
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

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}