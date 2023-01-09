page 90013 "Posted Web Sales Invoices"
{

    ApplicationArea = All;
    Caption = 'Posted Web Sales Invoices';
    PageType = List;
    CardPageId = "Posted Web Sales Invoice";
    SourceTable = "Posted Web Sales Invoice";
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
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
                    Visible = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
