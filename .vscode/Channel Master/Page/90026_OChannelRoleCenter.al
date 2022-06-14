page 90026 "Ochannel Role Center"
{
    PageType = RoleCenter;
    ApplicationArea = All;
    UsageCategory = Administration;

    
    layout
    {
        area(RoleCenter)
        {
          part(Control104; "Ochannel RoleCenter Headlines")
          {
                ApplicationArea = Basic, Suite;
          }
          part(Activity; "Ochannel Cue Group" )
          {
                AccessByPermission = TableData "Despatch Scan Line" = I;
                ApplicationArea = Basic, Suite;
                Caption = 'Activities';
          }
          part(Control98; "Power BI Report Spinner Part")
          {
                AccessByPermission = TableData "Power BI User Configuration" = I;
                ApplicationArea = Basic, Suite;
          }
        }
    }
    
    actions
    {
        area(embedding) 
        {
            
            action("Channel Partner")
            {
                ApplicationArea = All;
                Caption = 'Channel Partners';
                RunObject = Page "Trade Partner List";                
            }
            action("Web Order List")
            {
                ApplicationArea = All;
                Caption = 'Web Order List';
                RunObject = Page "Web Order List";                
            }
            action(Items)
            {
                ApplicationArea = All;
                Caption = 'Items';
                RunObject = Page "Item List";              
            } 
            action("Shipping Agents")
            {
                ApplicationArea = All;
                Caption = 'Shipping Agents';
                RunObject = Page "Shipping Agents";           
            }
            action("General Setup - Ochannel")
            {
                ApplicationArea = All;
                Caption = 'General Setup - Ochannel';
                RunObject = Page "General Setup - Channels";           
            }
  
        }
        area(Sections)
        {
            group("Web Sales")   
            {
               action("Web Orders")
               {
                   ApplicationArea = All;
                   Caption = 'Web Order List';
                   RunObject = Page "Web Order List";                
               }

               action("Web Order Line List")
               {
                   ApplicationArea = All;
                   Caption = 'Web Order Line List';
                   RunObject = Page "Web Order Line List";            
               }
               
               action("Web Sales Invoice")
               {
                   ApplicationArea = All;
                   Caption = 'Web Sales Invoice';
                   RunObject = Page "Web Sales Invoices";         
               }
               action("Web Customer")
               {
                   ApplicationArea = All;
                   Caption = 'Web Customer';
                   RunObject = Page "Web Customer";         
               }
                action("Scanned Entries")
               {
                   ApplicationArea = All;
                   Caption = 'Scanned Entries';
                   RunObject = Page "Scanned Entries";        
               } 

            }
            group(Inventory)
            {
               action("Item")
               {
                   ApplicationArea = All;
                   Caption = 'Items';
                   RunObject = Page "Item List";         
               }
               action("Channel Item List")
               {
                   ApplicationArea = All;
                   Caption = 'Channel Item Listing';
                   RunObject = Page "Channel Item Listing";      
               }
               action("Item Referance")
               {
                   ApplicationArea = All;
                   Caption = 'Item Referance';
                   RunObject = Page "Item Reference Entries";     
               }
            }
            group("Courier Integration")
            {
                action("Shipping Agent")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agents';
                    RunObject = Page "Shipping Agents";           
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
            }
            group(Payment)
            {
                Caption = 'Payments';

                    action("Payment Detail")
                    {
                        RunObject = page "Payment Detail";
                        ApplicationArea = all;
                    }
                    action("Archive Payment Details")
                    {
                        ApplicationArea = All;
                        RunObject = page "Archive Payment Detail";
                    }
                    action("Channel Payment Reconciliations")
                    {
                        RunObject = page "Channel Pay. Reconciliations";
                        ApplicationArea = all;
                    }
                    action("Archived Channel Payment Reconciliation")
                    {
                        RunObject = page "Archive Channel Pay. Recon";
                        ApplicationArea = All;
                    }
                    action("Web Payment Method")
                    {
                        RunObject = page "Web Payments";
                        ApplicationArea = all;
                    }
            }
            group("Posted Document") 
            {
                action("Handled Web Order List")
                {
                    RunObject = page "Handled Web Order List";
                    ApplicationArea = All;                    
                }
                action("Handled Web Order Line List")
                {
                    RunObject = page "Handled Web Order Line";
                    ApplicationArea = All;                    
                }
                action("Posted Web Sales Invoice")
                {
                    RunObject =  page "Posted Web Sales Invoices";
                    ApplicationArea = All;
                }
                action("Archived Channel Payment Reconciliation.")
                {
                    RunObject = page "Archive Channel Pay. Recon";
                    ApplicationArea = All;
                }
                action("Archived Scanned Entries")
                {
                    RunObject = page "Archieved Scanned Entries";
                    ApplicationArea = All;
                }
            }      
        }
    }
    
    var
      
}