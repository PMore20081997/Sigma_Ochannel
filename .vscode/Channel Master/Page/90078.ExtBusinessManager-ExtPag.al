pageextension 90078 "Ext Business Manager" extends "Business Manager Role Center"
{
    actions
    {
        addlast(sections)
        {
            group("Integration")
            {
                Enabled = true;

                group(CustomSetup)
                {
                    Caption = 'Setup';

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
                        Caption = 'Channel Items';
                        RunObject = page "Channel Item Listing";
                        ApplicationArea = All;
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
                    action("Channel Item References")
                    {
                        RunObject = page "Channel Item Reference";
                        ApplicationArea = All;
                    }
                    action("Shipping Agents")
                    {
                        RunObject = page "Shipping Agents";
                        ApplicationArea = all;
                        Visible = false;
                    }
                    action("Shipping Rule")
                    {
                        RunObject = page "Shipping Rules";
                        ApplicationArea = all;
                        Visible = false;
                    }
                    action("Web Payment Method")
                    {
                        Caption = 'Payments';
                        RunObject = page "Web Payments";
                        ApplicationArea = all;
                        Visible = false;
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
                    Visible = false;
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
                        RunObject = page "Scanned Header Entries";
                        ApplicationArea = all;
                        Caption = 'Scanned Entries';
                        Visible = false;
                    }
                    action("Handled Scanned Entries")
                    {
                        RunObject = page "Archived Scanned Entries";
                        ApplicationArea = all;
                        Caption = 'Handled Scanned Entries';
                        Visible = false;
                    }
                    action("Ochannel Return Order")
                    {
                        RunObject = page "Return Order Screen";
                        ApplicationArea = all;
                        Caption = 'Return Scan';
                    }
                }
            }
        }
    }
}
