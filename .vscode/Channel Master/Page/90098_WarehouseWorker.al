pageextension 90098 ExtendNavigation extends "Whse. Worker WMS Role Center"
{

    actions
    {
        addlast(sections)
        {


            group("Integration")
            {


                action("Channel Partner")
                {
                    RunObject = page "Trade Partner List";
                    ApplicationArea = All;
                }
                action("Web Order List")
                {
                    RunObject = page "Web Order List";
                    ApplicationArea = All;
                }
                action("Channel Item Listing")
                {
                    RunObject = page "Channel Item Listing";
                    ApplicationArea = All;

                }
                action("Despatch Scan")
                {
                    RunObject = page "Despatch Scan Screen";
                    ApplicationArea = all;
                    Caption = 'B2C Dispatch Scan';
                    //Visible = ShowDespatchScanButton;
                }
                action("Ochannel Return Order")
                {
                    RunObject = page "Return Order Screen";
                    ApplicationArea = all;
                    Caption = 'B2C Return Order Scan';
                }
                action("Web Customer")
                {
                    RunObject = page "Web Customer";
                    ApplicationArea = all;
                }
                action("General Setup - Channels")
                {
                    RunObject = page "General Setup - Channels";
                    ApplicationArea = all;
                }
                action("Shipping Agents2")
                {
                    Caption = 'Shipping Agents';
                    RunObject = page "Shipping Agents";
                    ApplicationArea = all;
                }

                action("Shipment Tracking")
                {
                    RunObject = page "Shipment Tracking";
                    ApplicationArea = all;
                }
                action("Shipping Rule")
                {
                    RunObject = page "Shipping Rules";
                    ApplicationArea = all;
                }
                group(ScannedEntries)
                {
                    Caption = 'Scanned Entries';

                    action("Scanned Entries")
                    {
                        RunObject = page "Scanned Entries";
                        ApplicationArea = all;
                    }
                    action("Archieved Scanned Entries")
                    {
                        RunObject = page "Archieved Scanned Entries";
                        ApplicationArea = all;
                    }
                }

                group(WebSalesInvoices)
                {
                    Caption = 'Web Sales Invoice';

                    action(WebSalesInvoice)
                    {
                        Caption = 'Web Sales Invoices';
                        RunObject = page "Web Sales Invoices";
                        ApplicationArea = all;
                    }
                    action("Posted Web Sales Invoices")
                    {
                        RunObject = page "Posted Web Sales Invoices";
                        ApplicationArea = all;
                    }
                }
                action("Web Payment Method")
                {
                    RunObject = page "Web Payments";
                    ApplicationArea = all;
                }
                group(Payment)
                {
                    Caption = 'Payment';

                    action("Payment Detail")
                    {
                        RunObject = page "Payment Detail";
                        ApplicationArea = all;
                    }
                    action("Channel Payment Journal")
                    {
                        RunObject = page "Channel Pay. Reconciliations";
                        ApplicationArea = all;
                    }
                }
            }
        }
    }

}
