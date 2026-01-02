page 90002 "Web Customer"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
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
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                }
                field("Concerto Customer No."; Rec."Concerto Customer No.")
                {
                    ApplicationArea = All;
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
                    Caption = 'Blocked';
                }
                field("Listing Status Setting"; Rec."Listing Status Setting")
                {
                    ApplicationArea = All;
                    ToolTip = 'This is a user-editable field to enable/disable BC Customers in the portal';
                }
                field("Listing Status"; Rec."Listing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Status to show if the Customer is Listed in the Portal or not';
                }
                field("Customer Sync"; Rec."Customer Sync")
                {
                    ApplicationArea = All;
                    ToolTip = 'Acknowledgment from Portal that Customer has synced on their side';
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
                Visible = false;

                trigger OnAction();
                var
                    WebOrderMgt: Codeunit "Web Order Mgt";
                begin
                    WebOrderMgt.CreateCustomer();
                end;
            }
            action("Update Customer Price Group")
            {
                ApplicationArea = All;
                Image = UpdateDescription;

                trigger OnAction()
                var
                    L_InterimCustomer: Record "Interim Customer";
                    L_Customer: Record Customer;
                    L_Modified: Boolean;
                begin
                    L_InterimCustomer.Reset();
                    if L_InterimCustomer.FindSet() then begin
                        repeat
                            Clear(L_Modified);
                            L_Customer.Reset();
                            L_Customer.SetRange("No.", L_InterimCustomer."No.");
                            if L_Customer.FindFirst() then begin
                                if L_Customer."Customer Price Group" <> L_InterimCustomer."Customer Price Group 1" then begin
                                    L_InterimCustomer."Customer Price Group 1" := L_Customer."Customer Price Group";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 2" <> L_Customer."Customer Price Group 2" then begin
                                    L_InterimCustomer."Customer Price Group 2" := L_Customer."Customer Price Group 2";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 3" <> L_Customer."Customer Price Group 3" then begin
                                    L_InterimCustomer."Customer Price Group 3" := L_Customer."Customer Price Group 3";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 4" <> L_Customer."Customer Price Group 4" then begin
                                    L_InterimCustomer."Customer Price Group 4" := L_Customer."Customer Price Group 4";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 5" <> L_Customer."Customer Price Group 5" then begin
                                    L_InterimCustomer."Customer Price Group 5" := L_Customer."Customer Price Group 5";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 6" <> L_Customer."Customer Price Group 6" then begin
                                    L_InterimCustomer."Customer Price Group 6" := L_Customer."Customer Price Group 6";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 7" <> L_Customer."Customer Price Group 7" then begin
                                    L_InterimCustomer."Customer Price Group 7" := L_Customer."Customer Price Group 7";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 8" <> L_Customer."Customer Price Group 8" then begin
                                    L_InterimCustomer."Customer Price Group 8" := L_Customer."Customer Price Group 8";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 9" <> L_Customer."Customer Price Group 9" then begin
                                    L_InterimCustomer."Customer Price Group 9" := L_Customer."Customer Price Group 9";
                                    L_Modified := true;
                                end;

                                if L_InterimCustomer."Customer Price Group 10" <> L_Customer."Customer Price Group 10" then begin
                                    L_InterimCustomer."Customer Price Group 10" := L_Customer."Customer Price Group 10";
                                    L_Modified := true;
                                end;

                                if L_Modified then begin
                                    L_InterimCustomer."Customer Sync" := false;
                                    L_InterimCustomer.Modify();
                                end;
                            end;
                        until L_InterimCustomer.Next() = 0;
                    end;

                    Message('Process Completed');
                end;
            }
        }
    }
}