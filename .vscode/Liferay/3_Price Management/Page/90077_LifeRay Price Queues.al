page 90077 "LifeRay Price Queues"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Price Push Queue";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;

                }
                field("Price List Code"; Rec."Price List Code")
                {
                    ApplicationArea = All;

                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;

                }
                field("Trigger Source"; Rec."Trigger Source")
                {
                    ApplicationArea = All;

                }
                field(Action; Rec.Action)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;

                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;

                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }

            }

        }
    }
}
