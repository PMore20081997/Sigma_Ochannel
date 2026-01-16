page 90059 "PODFather Error List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "PODFather Error Management";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document Type"; Rec."Document Type")
                {

                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Error; Rec.Error)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}