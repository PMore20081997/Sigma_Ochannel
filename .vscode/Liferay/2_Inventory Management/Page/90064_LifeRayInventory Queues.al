page 90064 "LifeRay Inventory Queues"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Inventory Push Queue";
    // Editable = false;
    // InsertAllowed = false;
    // ModifyAllowed = false;
    // DeleteAllowed = false;

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
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = ALl;
                }
                field("Trigger Source"; Rec."Trigger Source")
                {
                    ApplicationArea = ALl;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = ALl;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = ALl;
                }
            }
        }
    }
}