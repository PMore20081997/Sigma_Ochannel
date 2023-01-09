page 90027 "Ochannel Rolecentre"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    UsageCategory = Administration;

    actions
    {
        area(Sections)
        {
            group(Setup)
            {
                action("Channel Partner")
                {
                    RunObject = page "Trade Partner List";
                    ApplicationArea = All;
                }
                action("General Setup - Channels")
                {
                    RunObject = page "General Setup - Channels";
                    ApplicationArea = all;
                }
                action("Channel Item Listing")
                {
                    Caption = 'Items';
                    RunObject = page "Channel Item Listing";
                    ApplicationArea = All;
                }
                action("Web Customer")
                {
                    Caption = 'Customers';
                    Visible = false;  // Irshad
                    RunObject = page "Web Customer";
                    ApplicationArea = all;
                }
                action("Workstation Selection")
                {
                    RunObject = codeunit WorkstationSelection;
                    ApplicationArea = All;
                    Caption = 'Workstations';
                }
                action("Shipping Agents")
                {
                    RunObject = page "Shipping Agents";
                    ApplicationArea = all;
                }
                action("Shipping Rule")
                {
                    RunObject = page "Shipping Rules";
                    ApplicationArea = all;
                }
                action("Web Payment Method")
                {
                    Caption = 'Payments';
                    RunObject = page "Web Payments";
                    ApplicationArea = all;
                    Visible = true;    // Irshad -Payment Integrations ?? 1496
                }
            }
            group(Orders)
            {
                action("Web Order List")
                {
                    Caption = 'Order List';
                    RunObject = page "Web Order List";
                    ApplicationArea = All;
                }
                action("Web Order Line List")
                {
                    Caption = 'Order Lines';
                    RunObject = page "Web Order Line List";
                    ApplicationArea = All;
                }
                action("Handled Web Order List")
                {
                    Caption = 'Handled Order List';
                    RunObject = page "Handled Web Order List";
                    ApplicationArea = All;
                }
                action("Handled Web Order Line")
                {
                    Caption = 'Handled Order Lines';
                    RunObject = page "Handled Web Order Line";
                    ApplicationArea = All;
                }
            }

            Group(Warehouse)
            {
                action("Shipment Tracking")
                {
                    RunObject = page "Shipment Tracking";
                    ApplicationArea = all;
                }
                action("Despatch Scan")
                {
                    RunObject = page "New Despatch Scan";
                    ApplicationArea = all;
                    Caption = 'Dispatch Scan';
                }
                action("Scanned Header Entries")
                {
                    RunObject = page "Scanned Header Entries";
                    ApplicationArea = all;
                    Caption = 'Scanned Header Entries';
                }
                action("Scanned Lines Entries")
                {
                    RunObject = page "Scanned Entries";
                    ApplicationArea = all;
                    Caption = 'Scanned Lines Entries';
                }
                action("Handled Scanned Entries")
                {
                    RunObject = page "Archived Scanned Entries";
                    ApplicationArea = all;
                    Caption = 'Handled Scanned Entries';
                }
                action("Ochannel Return Order")
                {
                    RunObject = page "Return Order Screen";
                    ApplicationArea = all;
                    Caption = 'B2C Return';
                }
                action("Download Return Label")
                {
                    Caption = 'Download Return Label';
                    ApplicationArea = All;
                    RunObject = page "Download Return Label";
                }
            }
            group(WebSalesInvoices)
            {
                Caption = 'Invoice';

                action(WebSalesInvoice)
                {
                    Caption = 'Sales Invoice';
                    RunObject = page "Web Sales Invoices";
                    ApplicationArea = all;
                }
                action("Posted Web Sales Invoices")
                {
                    Caption = 'Handled Sales Invoice';
                    RunObject = page "Posted Web Sales Invoices";
                    ApplicationArea = all;
                }
            }

            group(Payment)
            {
                Caption = 'Payment';
                Visible = true;   // Irshad -Payment Integrations ?? 1496

                action("Payment Detail")
                {
                    RunObject = page "Payment Detail";
                    ApplicationArea = all;
                }
                action("Channel Payment Reconciliations")
                {
                    Caption = 'Payment Reconciliation';
                    RunObject = page "Channel Pay. Reconciliations";
                    ApplicationArea = all;
                }
                action("Archive Payment Details")
                {
                    Caption = 'Handled Payment Details';
                    ApplicationArea = All;
                    RunObject = page "Archive Payment Detail";
                }

                action("Archived Channel Payment Reconciliation")
                {
                    Caption = 'Handled Payment Reconciliation';
                    RunObject = page "Archive Channel Pay. Recon";
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        myInt: Integer;
}