page 90009 "Scanned Entries"
{

    ApplicationArea = All;
    Caption = 'Scanned Entries';
    PageType = List;
    SourceTable = "Despatch Scan Line";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Bay No."; Rec."Bay No.")
                {
                    ToolTip = 'Specifies the value of the Bay No. field';
                    ApplicationArea = All;
                }
                field("Channel Parter Code"; Rec."Channel Parter Code")
                {
                    ToolTip = 'Specifies the value of the Channel Parter Code field';
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = All;
                }
                field("Item Desciption"; Rec."Item Desciption")
                {
                    ToolTip = 'Specifies the value of the Item Desciption field';
                    ApplicationArea = All;
                }
                field("Item Journal Posted"; Rec."Item Journal Posted")
                {
                    ToolTip = 'Specifies the value of the Item Journal Posted field';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = All;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ToolTip = 'Specifies the value of the Order Line No. field';
                    ApplicationArea = All;
                }
                field("Order No"; Rec."Order No")
                {
                    ToolTip = 'Specifies the value of the Order No field';
                    ApplicationArea = All;
                }
                field("Pick Printed"; Rec."Pick Printed")
                {
                    ToolTip = 'Specifies the value of the Pick Printed field';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = All;
                }
                field("Scan Date Time"; Rec."Scan Date Time")
                {
                    ToolTip = 'Specifies the value of the Scan Date Time field';
                    ApplicationArea = All;
                }
                field(Scanned; Rec.Scanned)
                {
                    ToolTip = 'Specifies the value of the Scanned field';
                    ApplicationArea = All;
                }
                field("Scanned Quantity"; Rec."Scanned Quantity")
                {
                    ToolTip = 'Specifies the value of the Scanned Quantity field';
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
                field("Trolley No"; Rec."Trolley No")
                {
                    ToolTip = 'Specifies the value of the Trolley No field';
                    ApplicationArea = All;
                }
                field("Trolley closed Quantity"; Rec."Trolley closed Quantity")
                {
                    ToolTip = 'Specifies the value of the Quantity Handeled field';
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = All;
                }
                field("Warehouse Journal Posted"; Rec."Warehouse Journal Posted")
                {
                    ToolTip = 'Specifies the value of the Warehouse Journal Posted field';
                    ApplicationArea = All;
                }
                field("Web order updated"; Rec."Web order updated")
                {
                    ToolTip = 'Specifies the value of the Web order updated field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
