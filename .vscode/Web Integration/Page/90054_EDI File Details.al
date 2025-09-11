page 90054 "EDI File Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "EDI File Details";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Synced Date"; Rec."Synced Date")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field(Sync; Rec.Sync)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {

                trigger OnAction()
                begin

                end;
            }
        }
    }
}