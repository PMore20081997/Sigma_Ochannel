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
            group("Integration")
            {
                action("Add to Channel Customer List")
                {
                    ApplicationArea = All;
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

                action("Open Channel Customer")
                {
                    ApplicationArea = All;
                    Image = Navigate;
                    trigger OnAction()
                    var
                        Page_ChannelCustomer: Page "Web Customer";
                        Table_ChannelCustomer: Record "Interim Customer";
                    begin
                        Clear(Page_ChannelCustomer);
                        Table_ChannelCustomer.Reset();
                        Table_ChannelCustomer.SetRange("Customer No.", Rec."No.");
                        Page_ChannelCustomer.SetTableView(Table_ChannelCustomer);
                        Page_ChannelCustomer.RunModal();
                    end;
                }

            }
            group("EPOD")
            {
                action("Sync Customer & Site")
                {
                    ApplicationArea = All;
                    Image = New;

                    trigger OnAction()
                    var
                        L_customer: Record Customer;
                        ePODIntegration: Codeunit "POD Father Integration";
                    begin
                        L_customer.Reset();
                        CurrPage.SetSelectionFilter(L_customer);
                        L_customer.SetRange("Podfather Customer", true);
                        if L_customer.FindSet() then begin
                            repeat
                                ePODIntegration.CustomerAndSite_OnPODFatherPortal(L_customer."No.", 'EPOD')
                            until L_customer.Next() = 0;
                        end;

                    end;
                }
                action("Update Customer & Site")
                {
                    ApplicationArea = All;
                    Image = Change;

                    trigger OnAction()
                    var
                        L_customer: Record Customer;
                        ePODIntegration: Codeunit "POD Father Integration";
                    begin
                        L_customer.Reset();
                        CurrPage.SetSelectionFilter(L_customer);
                        L_customer.SetRange("Podfather Customer", true);
                        if L_customer.FindSet() then begin
                            repeat
                                ePODIntegration.UpdateCustomerAndSites_OnPODFatherPortal(L_customer."No.", 'EPOD')
                            until L_customer.Next() = 0;
                        end;

                    end;
                }
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
}