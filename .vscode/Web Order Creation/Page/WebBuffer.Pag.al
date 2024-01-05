page 90023 "Web Buffer"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Web Buffer";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Web Document No."; Rec."Web Document No.")
                {
                    ApplicationArea = All;

                }
                field("Sales Document No."; Rec."Sales Document No.")
                {
                    ApplicationArea = All;
                }
            }
        }

    }
}