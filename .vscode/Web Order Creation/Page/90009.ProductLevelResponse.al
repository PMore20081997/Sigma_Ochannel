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

    }


}