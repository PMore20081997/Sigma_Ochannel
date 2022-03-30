page 90100 "Scanned Header Entries"
{
    ApplicationArea = All;
    Caption = 'Scanned Header Entries';
    PageType = List;
    SourceTable = "Despatch Scan Header";
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Trolley No"; Rec."Trolley No")
                {
                    ApplicationArea = All;
                }
                field("Order No."; Rec."Order No")
                {
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Scan Date Time field';
                    ApplicationArea = All;
                }
                field(Scanned; Rec.Scanned)
                {
                    ToolTip = 'Specifies the value of the Scanned field';
                    ApplicationArea = All;
                }
                field("Bay No."; Rec."Bay No.")
                {
                    ToolTip = 'Specifies the value of the Scanned Quantity field';
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field';
                    ApplicationArea = All;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field';
                    ApplicationArea = All;
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field';
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field';
                    ApplicationArea = All;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field';
                    ApplicationArea = All;
                }
            }
        }
    }
}