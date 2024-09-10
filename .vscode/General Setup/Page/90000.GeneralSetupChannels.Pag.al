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
                field("Consolidated Sales No. Series"; Rec."Consolidated Sales No. Series")
                {
                    ApplicationArea = All;
                    Caption = 'Consolidated Sales Order No. Series';
                }
                field("Shipping G/L No."; Rec."Shipping G/L No.")
                {
                    ApplicationArea = All;
                }
                field("Knapp Consolidation Counter"; Rec."Knapp Consolidation Counter")
                {
                    ApplicationArea = All;
                    Caption = 'Knapp Web Order Consolidation Counter';
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