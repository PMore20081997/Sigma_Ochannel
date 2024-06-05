page 90006 "Handled Web Order Subpage"
{
    Editable = true;
    ModifyAllowed = true;
    InsertAllowed = true;
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "Handled Interim Sales Line";
    CaptionML = ENU = 'Handle Web Order Subpage', ENG = 'Handle Web Order Subpage';
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Qty. to Deliver"; Rec."Qty. to Deliver")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Reason Message"; Rec."Reason Message")
                {
                    ApplicationArea = All;
                }
                field("Channel SKU"; Rec."Channel SKU")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}