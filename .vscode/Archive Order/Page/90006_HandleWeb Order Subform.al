page 90006 "Handled Web Order Subpage"
{
    Editable = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Handled Interim Sales Line";
    CaptionML = ENU = 'Handle Web Order Subpage', ENG = 'Handle Web Order Subpage';


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("NAV Variant"; Rec."NAV Variant code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Shipping Price"; Rec."Shipping Price")
                {
                    ApplicationArea = All;
                }
                field("Gift Wrap Price"; Rec."Gift Wrap Price")
                {
                    ApplicationArea = All;
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }                
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
                field(SKU; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("Gift Wrap"; Rec."Gift Wrap")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

