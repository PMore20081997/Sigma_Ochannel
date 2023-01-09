//CAS-26633-Z8W1Y1.MH
page 90032 "Web Sales Invoice"
{
    PageType = Document;
    SourceTable = "Web Sales Invoice";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Web Sales Invoice No."; Rec."Web Sales Invoice No.")
                {
                    ApplicationArea = All;
                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Document Creation DateTime"; Rec."Document Creation DateTime")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }

                field("Stock Posted"; Rec."Stock Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Invoice Created"; Rec."Invoice Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Invoice Posted"; Rec."Invoice Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Payment Posted"; Rec."Payment Posted")
                {
                    ApplicationArea = All;
                }
                field("No of Error"; rec."No of Error")
                {
                    ApplicationArea = All;
                }
                field("From Date"; Rec."From Date")
                {
                    ApplicationArea = All;
                }
                field("To Date"; Rec."To Date")
                {
                    ApplicationArea = All;
                }

                field("Processing Error"; Rec."Processing Error")
                {
                    ApplicationArea = All;
                }
                field("Total Qty. to post"; Rec."Total Qty. to post")
                {
                    ApplicationArea = All;
                }
                field("Total Amt. to post"; Rec."Total Amt. to post")
                {
                    ApplicationArea = All;
                    Caption = 'Total Amt. to post(Ex. VAT)';
                }
                field("Total Amt. to post(Inl. VAT)"; Rec."Total Amt. to post(Inl. VAT)")
                {
                    ApplicationArea = All;
                }
                field("Total Invoice Discount"; Rec."Total Invoice Discount")
                {
                    ApplicationArea = All;
                }
            }
            part("WebSalesInvoiceSubForm"; "Web Sales Invoice SubForm")
            {
                SubPageLink = "Web Sales Invoice No." = field("Web Sales Invoice No.");
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

        }

    }

    actions
    {
        area(Processing)
        {
          group(Posting) 
          {
            action(StockPosting)
            {
                ApplicationArea = All;
                Image = PostingEntries;
                //PromotedIsBig = true;
                //Promoted = true;
                Caption = 'Post Stock & Invoice';
                ToolTip = 'Post stock and create and Post Sales invoice';
                trigger OnAction()
                var
                    StockPost: Codeunit "Post Stock and Invoice";
                    salesin: Page "Sales Invoice";
                    ErrorLog: Record "Incoming/Outgoing Error Log";
                    errorlogpage: Page "Web Order Error Log";
                    SalesInvoice: page "Sales Invoice";
                begin
                    if not StockPost.CheckHeaderData(Rec."Web Sales Invoice No.")then begin
                      StockPost.ProcessItemJournalPosting(Rec."Web Sales Invoice No.");
                      StockPost.CreateNPostSalesInvoice(Rec."Web Sales Invoice No.");
                    end else begin
                      Rec.CalcFields("No of Error");
                      if Rec."No of Error" > 0 then  begin
                        Clear(errorlogpage);
                        ErrorLog.Reset();
                        ErrorLog.SetRange("Document No.",Rec."Web Sales Invoice No."); 
                        Commit();
                        errorlogpage.SetTableView(ErrorLog);
                        errorlogpage.RunModal();
                      end;
                    end;

                end;
            }

            action(InvoicePosting)
            {
                ApplicationArea = All;
                Image = PostingEntries;
                //PromotedIsBig = true;
                //Promoted = true;
                Caption = 'Post Invoice';
                ToolTip = 'Create and post Sales invoice if item journal is aleady posted';
                trigger OnAction()
                var
                    StockPost: Codeunit "Post Stock and Invoice";
                begin
                    Rec.TestField("Stock Posted", true);
                    if not StockPost.CheckHeaderData(Rec."Web Sales Invoice No.")then begin
                      StockPost.CreateNPostSalesInvoice(Rec."Web Sales Invoice No.");
                    end; 
                end;
            }
            action(PaymentPosting)
            {
                ApplicationArea = All;
                Image = PostingEntries;
                //PromotedIsBig = true;
                //Promoted = true;
                Caption = 'Post Payment';
                ToolTip = 'Post payment coming from Channel';
                trigger OnAction()
                var
                    StockPost: Codeunit "Post Stock and Invoice";
                begin
                    Rec.TestField("Invoice Posted", true);
                    if not StockPost.CheckHeaderData(Rec."Web Sales Invoice No.")then begin
                      if StockPost.CreatenPostCashRcptJnl(Rec."Web Sales Invoice No.",Rec."Trade Partner Code") then
                        StockPost.MoveWebInvoiceToPosted(Rec."Web Sales Invoice No.");
                    end;  
                    
                end;
            }
            action(MoveInvoice)
            {
                ApplicationArea = Suite;
                Caption = 'Move Web Invoice to Posted';
                ToolTip = 'Move the Web Sales invoice to Posted Web Sales invoice if posted';
                Ellipsis = true;
                Image = Shipment;
                Visible = false;
                trigger OnAction()
                var
                    L_Posted: Codeunit "Post Stock and Invoice";
                begin
                    Rec.TestField(Posted, true);
                    L_Posted.MoveWebInvoiceToPosted(Rec."Web Sales Invoice No.");
                end;
            }
            /*action(HaxValue)
            {
                ApplicationArea = All;                
                trigger OnAction()
                var
                 StockPost: Codeunit "Post Stock and Invoice";
                begin
                 StockPost.TextToHex();       
                end;
            }*/
          }
          group(Prepare) 
          {
            action("Clear calculate lines")
            {
                ApplicationArea = All;
                
                trigger OnAction()
                begin
                  clearvalues();        
                end;
            }
            action(GetShipmentLines)
            {
                AccessByPermission = TableData "Sales Shipment Header" = R;
                ApplicationArea = Suite;
                Caption = 'Get &Trolley Lines';
                Ellipsis = true;
                Image = Shipment;

                trigger OnAction()
                var
                 GetTrolleyDetails: report "Get Scanned Lines";
                begin
                   GetTrolleyDetails.SetChannelcode(Rec."Web Sales Invoice No.", Rec."Trade Partner Code");
                   GetTrolleyDetails.Run();
                end;
            }
          }   
         }

         area(Navigation)
         {
            action(OpenInvoice)
            {
                ApplicationArea = All;
                Image = Invoice;
                //PromotedIsBig = true;
                //Promoted = true;
                Caption = 'Open Posted Invoice';
                RunObject = Page "Posted Sales Invoice";
                                RunPageLink = "External Document No." = field("Web Sales Invoice No.");
            }
          group("Handled Orders")
          {  
            action(WebOrders)
            {
                ApplicationArea = Suite;
                Caption = 'Show Web Orders';
                Ellipsis = true;
                Image = Shipment;                
                trigger OnAction()
                var
                    L_HISH: Record "Handled Interim Sales Header";
                    L_HandledHeaderPage: Page "Handled Web Order List";
                begin
                    L_HISH.Reset();
                    L_HISH.SetRange("Invoice No.", Rec."Web Sales Invoice No.");
                    L_HandledHeaderPage.SetTableView(L_HISH);
                    L_HandledHeaderPage.Run();
                end;  
            }
            action(WebOrderLines)
            {
                ApplicationArea = Suite;
                Caption = 'Show Web Orders Lines';
                Ellipsis = true;
                Image = Shipment;

                trigger OnAction()
                var
                    L_HISL: Record "Handled Interim Sales Line";
                    L_HandledLinePage: Page "Handled Web Order Line";
                    
                begin
                    L_HISL.Reset();
                    L_HISL.SetRange("Web Sales Invoice No.", Rec."Web Sales Invoice No.");
                    L_HandledLinePage.SetTableView(L_HISL);
                    L_HandledLinePage.Run();

                end;
            }
           } 
           
        }

    }

    trigger OnDeleteRecord(): Boolean
    var
        L_ArchiveEntry: Record "Archive Scanned Entries";
        L_HISH: Record "Handled Interim Sales Header";
        L_HISL: Record "Handled Interim Sales Line";
    begin
      clearvalues();  
    end;
    
    local procedure clearvalues()
    var        
        L_ArchiveEntry: Record "Archive Scanned Entries";
        L_HISH: Record "Handled Interim Sales Header";
        L_HISL: Record "Handled Interim Sales Line";
        L_WebsalesinvL: Record "Web Sales Invoice Line";
    begin
      If Not Rec.Posted then begin
            If Rec."Stock Posted" then
                Error('You can not delete this document as invetory adjustment is posted');


            L_WebsalesinvL.Reset();
            L_WebsalesinvL.SetRange("Web Sales Invoice No.",Rec."Web Sales Invoice No.");
            L_WebsalesinvL.SetRange("Trade Partner Code",Rec."Trade Partner Code");
            if L_WebsalesinvL.FindSet() then begin
              L_ArchiveEntry.Reset();
              L_ArchiveEntry.SetRange("Web Inv No", Rec."Web Sales Invoice No.");
              L_ArchiveEntry.SetRange("Item Journal Posted", false);
              If L_ArchiveEntry.FindSet() then
                repeat
                    L_ArchiveEntry."Item Journal Posted" := false;
                    clear(L_ArchiveEntry."Web Inv No");
                    L_ArchiveEntry.Modify();
                until L_ArchiveEntry.Next() = 0;

              L_HISL.Reset();
              L_HISL.SetRange("Web Sales Invoice No.", Rec."Web Sales Invoice No.");
              If L_HISL.FindSet() then
                repeat
                    Clear(L_HISL."Web Sales Invoice No.");
                    L_HISL.Modify();
                until L_HISL.Next() = 0;

              L_HISH.Reset();
              L_HISH.SetRange("Invoice No.", Rec."Web Sales Invoice No.");
              If L_HISH.FindSet() then
                repeat
                    clear(L_HISH."Invoice No.");
                    L_HISH.Modify();
                until L_HISH.Next() = 0;
            
              L_WebsalesinvL.DeleteAll();
              Clear(Rec."Total Invoice Discount");
              Rec.Modify();
            end;
      end;  
    end;
    var
        myInt: Integer;
}