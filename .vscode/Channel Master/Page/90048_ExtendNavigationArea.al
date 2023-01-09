pageextension 90048 ExtendNavigationArea extends "Order Processor Role Center"
{
    layout
    {
        addbefore(Control1901851508)
        {
            part(OChannelBusinessChart; "O-Channel Business Chart")
            {
                Caption = 'O-Channel Business Chart';
                ApplicationArea = All;
            }
            part("Ochannel Activities"; "Ochannel Activities")
            {
                Caption = 'O-Channel Activities';
                ApplicationArea = All;
            }

        }
    }


    actions
    {
        addfirst(sections)
        {
            group(Action39)
            {
                Caption = 'Finance';
                Image = Journals;
                ToolTip = 'Post financial transactions, manage budgets, analyze G/L  data, and prepare financial statements.';
                action(GeneralJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Journals';
                    Image = Journal;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(false));
                    ToolTip = 'Post financial transactions directly to general ledger accounts and other accounts, such as bank, customer, vendor, and employee accounts. Posting with a general journal always creates entries on general ledger accounts. This is true even when, for example, you post a journal line to a customer account, because an entry is posted to a general ledger receivables account through a posting group.';
                }
                action(Action3)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chart of Accounts';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Chart of Accounts";
                    ToolTip = 'View or organize the general ledger accounts that store your financial data. All values from business transactions or internal adjustments end up in designated G/L accounts. Business Central includes a standard chart of accounts that is ready to support businesses in your country, but you can change the default accounts and add new ones.';
                }
                action("G/L Account Categories")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Account Categories';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "G/L Account Categories";
                    ToolTip = 'Personalize the structure of your financial statements by mapping general ledger accounts to account categories. You can create category groups by indenting subcategories under them. Each grouping shows a total balance. When you choose the Generate Account Schedules action, the account schedules for the underlying financial reports are updated. The next time you run one of these reports, such as the balance statement, new totals and subentries are added, based on your changes.';
                }
                action("G/L Budgets")
                {
                    ApplicationArea = Suite;
                    Caption = 'G/L Budgets';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "G/L Budget Names";
                    ToolTip = 'View summary information about the amount budgeted for each general ledger account in different time periods.';
                }
                action(Action2)
                {
                    ApplicationArea = FixedAssets;
                    Caption = 'Fixed Assets';
                    RunObject = Page "Fixed Asset List";
                    ToolTip = 'Manage periodic depreciation of your machinery or machines, keep track of your maintenance costs, manage insurance policies related to fixed assets, and monitor fixed asset statistics.';
                }
                action("Account Schedules")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Schedules';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Account Schedule Names";
                    ToolTip = 'Get insight into the financial data stored in your chart of accounts. Account schedules analyze figures in G/L accounts, and compare general ledger entries with general ledger budget entries. For example, you can view the general ledger entries as percentages of the budget entries. Account schedules provide the data for core financial statements and views, such as the Cash Flow chart.';
                }
                action("Intrastat Journals")
                {
                    ApplicationArea = BasicEU;
                    Caption = 'Intrastat Journals';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Intrastat Jnl. Batches";
                    ToolTip = 'Summarize the value of your purchases and sales with business partners in the EU for statistical purposes and prepare to send it to the relevant authority.';
                }
                action("Sales Budgets")
                {
                    ApplicationArea = SalesBudget;
                    Caption = 'Sales Budgets';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Budget Names Sales";
                    ToolTip = 'Enter item sales values of type amount, quantity, or cost for expected item sales in different time periods. You can create sales budgets by items, customers, customer groups, or other dimensions in your business. The resulting sales budgets can be reviewed here or they can be used in comparisons with actual sales data in sales analysis reports.';
                }
                action("Purchase Budgets")
                {
                    ApplicationArea = PurchaseBudget;
                    Caption = 'Purchase Budgets';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Budget Names Purchase";
                    ToolTip = 'Enter item purchases values of type amount, quantity, or cost for expected item purchases in different time periods. You can create purchase budgets by items, vendors, vendor groups, or other dimensions in your business. The resulting purchase budgets can be reviewed here or they can be used in comparisons with actual purchases data in purchase analysis reports.';
                }
                action("Sales Analysis Reports")
                {
                    ApplicationArea = SalesAnalysis;
                    Caption = 'Sales Analysis Reports';
                    RunObject = Page "Analysis Report Sale";
                    ToolTip = 'Analyze the dynamics of your sales according to key sales performance indicators that you select, for example, sales turnover in both amounts and quantities, contribution margin, or progress of actual sales against the budget. You can also use the report to analyze your average sales prices and evaluate the sales performance of your sales force.';
                }
                action("Purchase Analysis Reports")
                {
                    ApplicationArea = PurchaseAnalysis;
                    Caption = 'Purchase Analysis Reports';
                    RunObject = Page "Analysis Report Purchase";
                    ToolTip = 'Analyze the dynamics of your purchase volumes. You can also use the report to analyze your vendors'' performance and purchase prices.';
                }
                action("Inventory Analysis Reports")
                {
                    ApplicationArea = InventoryAnalysis;
                    Caption = 'Inventory Analysis Reports';
                    RunObject = Page "Analysis Report Inventory";
                    ToolTip = 'Analyze the dynamics of your inventory according to key performance indicators that you select, for example inventory turnover. You can also use the report to analyze your inventory costs, in terms of direct and indirect costs, as well as the value and quantities of your different types of inventory.';
                }
                action("VAT Returns")
                {
                    ApplicationArea = VAT;
                    Caption = 'VAT Returns';
                    RunObject = Page "VAT Report List";
                    ToolTip = 'Prepare the VAT Return report so you can submit VAT amounts to a tax authority.';
                }
                action(Currencies)
                {
                    ApplicationArea = Suite;
                    Caption = 'Currencies';
                    Image = Currency;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page Currencies;
                    ToolTip = 'View the different currencies that you trade in or update the exchange rates by getting the latest rates from an external service provider.';
                }
                action(Employees)
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Employees';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Employee List";
                    ToolTip = 'View or modify employees'' details and related information, such as qualifications and pictures, or register and analyze employee absence. Keeping up-to-date records about your employees simplifies personnel tasks. For example, if an employee''s address changes, you register this on the employee card.';
                }
                action("VAT Statements")
                {
                    ApplicationArea = VAT;
                    Caption = 'VAT Statements';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "VAT Statement Names";
                    ToolTip = 'View a statement of posted VAT amounts, calculate your VAT settlement amount for a certain period, such as a quarter, and prepare to send the settlement to the tax authorities.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page Dimensions;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action(PostedGeneralJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted General Journals';
                    RunObject = Page "Posted General Journal";
                    ToolTip = 'Open the list of posted general journal lines.';
                }
            }
        }
        addlast(sections)
        {

            group("Integration")
            {

                Enabled = true;

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
                    Visible = false;

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
                    Visible = false;
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
    }
    var
        p: Page 9022;

}
