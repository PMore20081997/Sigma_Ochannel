page 90020 "Handled Web Order Line"
{

    PageType = List;
    SourceTable = "Handled Interim Sales Line";


    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                }
                // field("Unit of Measure Code";"Unit of Measure Code")
                // {
                // }
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
                field("VAT amount"; Rec."VAT amount")
                {
                    ApplicationArea = All;
                }
                field(SKU; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                }
                field("Gift Wrap"; Rec."Gift Wrap")
                {
                    Editable = true;
                    Enabled = true;
                    ApplicationArea = All;
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
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT%"; Rec."VAT%")
                {
                    ApplicationArea = All;
                }
                field(Remarks; Rec.Remarks)
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec."Ordser Status")
                {
                    ApplicationArea = All;
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

