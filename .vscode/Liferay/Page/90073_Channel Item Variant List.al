page 90073 "Channel Item Variant List"
{
    Caption = 'Channel Item Variant List';
    PageType = List;
    AboutTitle = 'About Channel Item Variant List';
    SourceTable = "Item Variant";
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number on the item card from which you opened the Item Reference Entries window.';
                    Editable = false;
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Blocked"; Rec."Sales Blocked")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {

    }
}

