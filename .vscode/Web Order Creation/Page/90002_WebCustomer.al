page 90002 "Web Customer"
{
    PageType = List;
    ApplicationArea = All;
    //UsageCategory = Lists;
    UsageCategory = Documents;
    SourceTable = "Interim Customer";


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                    Caption = 'Channel Code';

                }


                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';

                }
                field(Process; Rec.Process)
                {
                    ApplicationArea = All;
                    Caption = 'Process';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    Caption = 'Address';
                    Visible = false;
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Address 2';
                    Visible = false;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Caption = 'City';
                    Visible = false;
                }
                field("Phone No"; Rec."Phone No")
                {
                    ApplicationArea = All;
                    Caption = 'Phone No';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Post Code';
                    Visible = false;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'E-Mail';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Caption = 'Blocked';
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Caption = 'Gen. Bus. Posting Group';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Bus. Posting Group';
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Posting Group';
                }


                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Caption = 'Responsibility Center';
                }
                field("Credit Limit (LCY)"; Rec."Credit Limit (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Credit Limit (LCY)';
                    Visible = false;
                }
                field("VAT No"; Rec."VAT No")
                {
                    ApplicationArea = All;
                    Caption = 'VAT No';
                    Visible = false;
                }
                field("Shipping Address"; Rec."Shipping Address")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Address';
                    Visible = false;
                }
                field("Shipping Address 2"; Rec."Shipping Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Address 2';
                    Visible = false;
                }
                field("Shipping Address 3"; Rec."Shipping Address 3")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Address 3';
                    Visible = false;
                }
                field("Shipping City"; Rec."Shipping City")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping City';
                    Visible = false;
                }
                field("Shipping Post Code"; Rec."Shipping Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Post Code';
                    Visible = false;
                }
                field("Shipping County"; Rec."Shipping County")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping County';
                    Visible = false;
                }
                field("Shipping Country"; Rec."Shipping Country")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Country';
                    Visible = false;
                }
                field(AccountNo; Rec.AccountNo)
                {
                    ApplicationArea = All;
                    Caption = 'AccountNo';
                    Visible = false;
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                    Caption = 'Job Title';
                    Visible = false;
                }

            }
        }
        area(Factboxes)
        {

        }
    }
    //var
    //OrderRead: Codeunit "Process Order File-Innox";

    actions
    {
        area(Processing)
        {
            action("Process Customer")
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    InterimCustomer: Record "Interim Customer";
                    WebOrderMgt: Codeunit "Web Order Mgt";
                begin
                    WebOrderMgt.CreateCustomer();
                end;
            }
        }
    }
}