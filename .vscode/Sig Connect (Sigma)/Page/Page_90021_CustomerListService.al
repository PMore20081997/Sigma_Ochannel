page 90021 "Customer List Service"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Interim Customer";
    SourceTableView = where("Channel Code" = filter('SIGCONNECT'));

    layout
    {
        area(Content)
        {
            repeater("Customer List")
            {
                field("Sell to Customer No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Concerto Customer No."; Rec."Concerto Customer No.")
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
                field("Customer Price Group 4"; Rec."Customer Price Group 4")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 5"; Rec."Customer Price Group 5")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 6"; Rec."Customer Price Group 6")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 7"; Rec."Customer Price Group 7")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 8"; Rec."Customer Price Group 8")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 9"; Rec."Customer Price Group 9")
                {
                    ApplicationArea = All;
                }
                field("Customer Price Group 10"; Rec."Customer Price Group 10")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }
                field("Listing Status Setting"; Rec."Listing Status Setting")
                {
                    ApplicationArea = All;
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                }
                field("Customer Sync"; Rec."Customer Sync")
                {
                    ApplicationArea = All;
                }
                field("Last Modified By"; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                }
                field("Last Modified At"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}