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
                field("TOS Checked"; Rec."TOS Checked")
                {
                    ApplicationArea = All;
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Update Created At Date")
            {
                ApplicationArea = All;
                Visible = false;

                trigger OnAction()
                var
                    WebBuffer: Record "Web Buffer";
                begin
                    Clear(WebBuffer);
                    WebBuffer := Rec;
                    CurrPage.SetSelectionFilter(WebBuffer);

                    if WebBuffer.FindSet() then begin
                        repeat
                            WebBuffer."Created At" := Today;
                            WebBuffer.Modify();
                        until WebBuffer.Next() = 0;
                    end;
                end;
            }
        }
    }
}