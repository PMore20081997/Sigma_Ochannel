page 90068 "Channel Item Reference List"
{
    Caption = 'Channel Item Reference List';
    PageType = List;
    AboutTitle = 'About Channel Item Reference List';
    SourceTable = "Item Reference";
    SourceTableView = where("Reference Type" = const("PIP Code"));
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
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Editable = false;
                    Visible = false;
                }
                field("Reference Type"; Rec."Reference Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the reference entry.';
                    Editable = false;
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the referenced item number. If you enter a reference between yours and your vendor''s or customer''s item number, then this number will override the standard item number when you enter the reference number on a sales or purchase document.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {

    }
}

