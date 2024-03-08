page 90009 "Product Response"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Product Level Response";
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
        if UpperCase(UserId) = UpperCase('ABDUL.K') then
            CurrPage.Editable := true
        else
            CurrPage.Editable := false;

    end;


}