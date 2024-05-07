page 90002 "Web Customer"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    //UsageCategory = Documents;
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
                    Visible = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';

                }
                field("Concerto Customer No."; Rec."Concerto Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Process; Rec.Process)
                {
                    ApplicationArea = All;
                    Caption = 'Process';
                    Visible = false;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    Visible = false;
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
                }
                field("Address 2"; Rec."Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Address 2';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    Caption = 'City';
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


                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Caption = 'Responsibility Center';
                    Visible = false;
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
                }
                field("Shipping Address 2"; Rec."Shipping Address 2")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Address 2';
                }
                field("Shipping Address 3"; Rec."Shipping Address 3")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Address 3';
                }
                field("Shipping City"; Rec."Shipping City")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping City';
                }
                field("Shipping Post Code"; Rec."Shipping Post Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Post Code';
                }
                field("Shipping County"; Rec."Shipping County")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping County';
                }
                field("Shipping Country"; Rec."Shipping Country")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Country';
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
                field("Listing Status Setting"; Rec."Listing Status Setting")
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

            // action("Update Customer")
            // {
            //     ApplicationArea = All;

            //     trigger OnAction();
            //     var
            //         L_Customer: Record Customer;
            //         L_InterimCustomer: Record "Interim Customer";
            //     begin
            //         L_InterimCustomer.Reset();
            //         L_InterimCustomer.SetRange("Channel Code", 'SIGCONNECT');
            //         if L_InterimCustomer.FindSet() then
            //             repeat
            //                 L_Customer.Reset();
            //                 L_Customer.SetRange("No.", L_InterimCustomer."Customer No.");
            //                 if L_Customer.FindFirst() then begin
            //                     L_InterimCustomer."Concerto Customer No." := L_Customer."Concerto Customer No.";
            //                     L_InterimCustomer.Modify();
            //                 end;
            //             until L_InterimCustomer.Next() = 0;
            //     end;
            // }
        }
    }
}