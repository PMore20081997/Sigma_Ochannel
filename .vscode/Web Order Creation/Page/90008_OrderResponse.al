page 90008 "Order Response"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Order Level Response";
    Editable = true;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Sequence No.';
                }
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                }
                field(Reason; Rec.Reason)
                {
                    ApplicationArea = All;
                }
                field(Message; Rec.Message)
                {
                    ApplicationArea = All;
                }
            }
        }

        area(FactBoxes)
        {
            // systempart(Control1900383207; Links)
            // {
            //     ApplicationArea = RecordLinks;
            // }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = All;
            }
        }
    }


    trigger OnOpenPage()
    begin
        G_UserSetup.Reset();
        if G_UserSetup.Get(UserId) then;
        if G_UserSetup."Allow Edit Order/Product Resp." = true then
            CurrPage.Editable := true
        else
            CurrPage.Editable := false;
    end;

    var
        G_UserSetup: Record "User Setup";
}