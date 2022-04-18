page 90023 "Posted Web Sales Invoice"
{

    Caption = 'Posted Web Sales Invoice';
    PageType = Card;
    SourceTable = "Posted Web Sales Invoice";
    Editable = false;

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
                    Visible = false;
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
                field("Invoice Posted"; Rec."Invoice Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
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

            }
            part("WebSalesInvoiceSubForm"; "Posted Web Sales Inv. Subform")
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
            action(OpenInvoice)
            {
                ApplicationArea = All;
                Image = Invoice;
                PromotedIsBig = true;
                Promoted = true;
                Caption = 'Open Posted Invoice';
                RunObject = Page "Posted Sales Invoice";
                RunPageLink = "External Document No." = field("Web Sales Invoice No.");
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
                    If L_HISL.FindSet() then begin
                        L_HandledLinePage.SetTableView(L_HISL);
                        L_HandledLinePage.Run();
                    end;
                end;
            }
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
                    If L_HISH.FindSet() then begin
                        L_HandledHeaderPage.SetTableView(L_HISH);
                        L_HandledHeaderPage.Run();
                    end;
                end;
            }
        }
    }

}
