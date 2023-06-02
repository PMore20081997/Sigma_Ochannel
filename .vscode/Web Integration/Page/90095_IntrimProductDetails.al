page 90095 "Interim Product Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Interim Product Details";

    layout
    {
        area(Content)
        {
            repeater(general)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    Caption = 'Channel Code';
                }
                field("Item No."; rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Last Availability"; rec."Last Availability")
                {
                    ApplicationArea = All;
                }
                field("Current Availability"; rec."Current Availability")
                {
                    ApplicationArea = All;
                }
                field("Last Stock Status"; rec."Last Stock Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Current Stock Status"; rec."Current Stock Status")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

            }
        }
    }


}