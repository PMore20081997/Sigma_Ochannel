page 90024 "Handled Customer"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Handled Customer";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Web Customer No."; Rec."Web Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Web Customer No.';

                }
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                    Caption = 'Trade Partner Code';

                }
                field("Nav Customer No."; Rec."Nav Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nav Customer No.';

                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';

                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Posting Group';

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
                field("Credit Limit (LCY)"; Rec."Credit Limit (LCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Credit Limit (LCY)';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = All;
                    Caption = 'Responsibility Center';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                }
                field("Company Type"; Rec."Company Type")
                {
                    ApplicationArea = All;
                    Caption = 'Company Type';
                }
                field("Company Reg No"; Rec."Company Reg No")
                {
                    ApplicationArea = All;
                    Caption = 'Company Reg No';
                }
                field("VAT No"; Rec."VAT No")
                {
                    ApplicationArea = All;
                    Caption = 'VAT No';
                }
                field("Business Type"; Rec."Business Type")
                {
                    ApplicationArea = All;
                    Caption = 'Business Type';
                }
                field("Website"; Rec."Website")
                {
                    ApplicationArea = All;
                    Caption = 'Website';
                }
                field("Address 3"; Rec."Address 3")
                {
                    ApplicationArea = All;
                    Caption = 'Address 3';
                }
                field("County"; Rec."County")
                {
                    ApplicationArea = All;
                    Caption = 'County';
                }
                field("Country"; Rec."Country")
                {
                    ApplicationArea = All;
                    Caption = 'Country';
                }
                field("Shipping Contact"; Rec."Shipping Contact")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Contact';
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
                field("Shipping Phone No."; Rec."Shipping Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Phone No.';
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
                field("AccountNo"; Rec."AccountNo")
                {
                    ApplicationArea = All;
                    Caption = 'AccountNo';
                }
                field("Job Title"; Rec."Job Title")
                {
                    ApplicationArea = All;
                    Caption = 'Job Title';
                }
                field("Country Name"; Rec."Country Name")
                {
                    ApplicationArea = All;
                    Caption = 'Country Name';
                }
                field("Shipping Country Name"; Rec."Shipping Country Name")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Country Name';
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