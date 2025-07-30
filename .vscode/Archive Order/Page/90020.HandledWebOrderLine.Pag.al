page 90020 "Handled Web Order Line"
{

    PageType = List;
    SourceTable = "Handled Interim Sales Line";
    Editable = false;
    ApplicationArea = All;
    Caption = 'Handled Order Lines';
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = All;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("NAV Variant code"; Rec."NAV Variant code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Description2; Rec.Description2)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Channel Variant"; Rec."Channel Variant")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                // field("Unit of Measure Code";"Unit of Measure Code")
                // {
                // }
                field("Shipping Price"; Rec."Shipping Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gift Wrap Price"; Rec."Gift Wrap Price")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT amount"; Rec."VAT amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(SKU; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gift Wrap"; Rec."Gift Wrap")
                {
                    Editable = true;
                    Enabled = true;
                    ApplicationArea = All;
                    CaptionML = ENU = 'Gift', ENG = 'Gift';
                    Visible = false;
                }
                field("Channel Identifier"; Rec."Channel Identifier")
                {
                    Visible = false;
                    ApplicationArea = All;

                }
                field("Channel Item Id"; Rec."Channel Item Id")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("VAT%"; Rec."VAT%")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field("Line Status"; Rec."Line Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Scanned Date"; Rec."Scanned Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("Gift Card"; Rec."Gift Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gift Card field.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        IF Item.GET(Rec."No.") THEN;
    end;

    var
        // CreateConsollidatedOrder : Codeunit "80011";
        Item: Record 27;
}

