page 90081 "Scanned Header Entries"
{
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Despatch Scan Header";
    PageType = List;
    Editable = true;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Trolley No"; Rec."Trolley No")
                {
                    ApplicationArea = All;
                }
                field("Order No"; Rec."Order No")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}