pageextension 90009 "CustomerListExt" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
            field("Web Customer No. 2"; Rec."Web Customer No. 2")
            {
                ApplicationArea = All;
            }
            field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {

        // Add changes to page actions here
        addlast(processing)
        {
            action("Add to Channel Customer List")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = Process;
                trigger OnAction()
                var
                    G_Customer: Record Customer;
                    ManageCustomerListing: Codeunit "Manage Channel Customer List";
                begin
                    G_Customer := Rec;
                    CurrPage.SETSELECTIONFILTER(G_Customer);
                    ManageCustomerListing.CreateChannelCustomerlistingForMultipleSelection(G_Customer);
                end;
            }
        }
        addafter(ApplyTemplate)
        {
            action("Customer Re&ferences")
            {
                AccessByPermission = tabledata "Customer Reference" = R;
                ApplicationArea = All;
                Caption = 'Customer Re&ferences';
                Image = Change;
                RunObject = Page "Customer Reference";
                RunPageLink = "Customer No." = FIELD("No.");
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
            }
        }
    }

    var
        myInt: Integer;
}