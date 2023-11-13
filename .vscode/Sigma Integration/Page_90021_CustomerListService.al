page 90021 "Customer List Service"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Interim Customer";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Sell to Customer No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Sell to Customer Name"; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                }
                field("Bill to Customer No."; Rec."Bill to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Bill to Customer Name"; Rec."Bill to Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 1"; Rec."Customer Price Group 1")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 2"; Rec."Customer Price Group 2")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 3"; Rec."Customer Price Group 3")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}