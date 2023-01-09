//CAS-26633-Z8W1Y1.MH
#pragma implicitwith disable
page 90030 "Web Sales Invoices"
{
    PageType = List;
    ApplicationArea = All;
    CardPageId = "Web Sales Invoice";
    UsageCategory = Lists;
    SourceTable = "Web Sales Invoice";
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater("Web Sales Invoices")
            {
                field("Web Sales Invoice No."; Rec."Web Sales Invoice No.")
                {
                    ApplicationArea = All;
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
                field("Stock Posted"; Rec."Stock Posted")
                {
                    ApplicationArea = All;
                }
                field("Invoice Created"; Rec."Invoice Created")
                {
                    ApplicationArea = All;
                }
                field("Invoice Posted"; Rec."Invoice Posted")
                {
                    ApplicationArea = All;
                }
                field("Payment Posted"; Rec."Payment Posted")
                {
                    ApplicationArea = All;
                }

                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        // area(Factboxes)
        // {

        // }
    }

    actions
    {
        area(Processing)
        {
            action(OpenInvoice)
            {
                ApplicationArea = All;
                Image = Invoice;
                //PromotedIsBig = true;
                //Promoted = true;
                Caption = 'Open Posted Invoice';
                RunObject = Page "Posted Sales Invoice";
                RunPageLink = "No." = field("Web Sales Invoice No.");
            }

            /*  action(TEST)
              {
                  ApplicationArea = All;

                  trigger OnAction()
                  var
                      L_post: Codeunit "Post Stock and Invoice";
                  begin
                      L_post.CreateandpostItemJournal;
                  end;
              }*/
        }
    }
}
#pragma implicitwith restore
