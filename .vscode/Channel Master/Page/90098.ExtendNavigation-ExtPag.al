pageextension 90098 "ExtendNavigation" extends "Whse. Worker WMS Role Center"
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
                    Caption = 'Channel Items';
                    RunObject = page "Channel Item Listing";
                    ApplicationArea = All;
                }
                action("Despatch Scan")
                {
                    RunObject = page "New Despatch Scan";
                    ApplicationArea = all;
                    Caption = 'Dispatch Scan';
                    //Visible = ShowDespatchScanButton;
                    Visible = false;
                }
                action("Ochannel Return Order")
                {
                    RunObject = page "Return Order Screen";
                    ApplicationArea = all;
                    Caption = 'Return Scan';
                }
                action("Web Customer")
                {
                    Caption = 'Channel Customers';
                    RunObject = page "Web Customer";
                    ApplicationArea = all;
                }
                action("Channel Prices")
                {
                    RunObject = page "Sales Price Lists";
                    ApplicationArea = All;
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
                action("Web Payment Method")
                {
                    RunObject = page "Web Payments";
                    ApplicationArea = all;
                }
                action("Web Buffer")
                {
                    Caption = 'Web Buffer';
                    RunObject = page "Web Buffer";
                    ApplicationArea = all;
                }
                action("Order Response")
                {
                    RunObject = page "Order Response";
                    ApplicationArea = all;
                }
                action("Product Response")
                {
                    RunObject = page "Product Response";
                    ApplicationArea = all;
                }
                group(ScannedEntries)
                {
                    Caption = 'Scanned Entries';

                    action("Scanned Entries")
                    {
                        RunObject = page "Scanned Header Entries";
                        ApplicationArea = all;
                    }
                    action("Archived Scanned Entries")
                    {
                        RunObject = page "Archived Scanned Entries";
                        ApplicationArea = all;
                    }
                }
            }
        }
    }
}
