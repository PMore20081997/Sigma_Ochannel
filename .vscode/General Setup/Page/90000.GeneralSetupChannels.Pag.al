page 90000 "General Setup - Channels"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = Card;
    SourceTable = "General Setup - Channels";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Sales Channel Order Id"; Rec."Web Order Nos")
                {
                    ApplicationArea = All;
                }
                field("Shipping G/L No."; Rec."Shipping G/L No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


    trigger OnOpenPage()
    var
    begin
        Rec.RESET;
        IF NOT Rec.GET THEN BEGIN
            Rec.INIT;
            Rec.INSERT;
        END;
    end;
}