page 90063 "PS Postal Route Setup List"
{
    PageType = List;
    SourceTable = "PS Route Setup";
    ApplicationArea = All;
    Caption = 'PS Postal Route Setup List';
    UsageCategory = Administration;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Postcode"; rec."Postcode")
                {
                    ApplicationArea = All;
                }
                field("Area"; rec."Area")
                {
                    ApplicationArea = All;
                }
                field("Zone"; rec."Zone")
                {
                    ApplicationArea = All;
                }
                field("Depot"; rec."Depot")
                {
                    ApplicationArea = All;
                }
                field("Del Days SMTWTFS"; rec."Del Days SMTWTFS")
                {
                    ApplicationArea = All;
                }
                field("Lead Time"; rec."Lead Time")
                {
                    ApplicationArea = All;
                }
                field("Allowance Type"; rec."Allowance Type")
                {
                    ApplicationArea = All;
                }
                field("Carrier Zone"; rec."Carrier Zone")
                {
                    ApplicationArea = All;
                }
                field("Service"; rec."Service")
                {
                    ApplicationArea = All;
                }
                field("Window"; rec."Window")
                {
                    ApplicationArea = All;
                }
                field("Deleted"; rec."Deleted")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}