page 90080 "Archive Shipment Tracking"
{
    PageType = List;
    SourceTable = "Archive Shipment Tracking";
    ApplicationArea = All;
    UsageCategory = Administration;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                }

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Code';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Service Code';
                }
                field("Agent Shipment No."; Rec."Agent Shipment No.")
                {
                    ApplicationArea = All;
                    Caption = 'Agent Shipment No.';
                }
                field("Tracking No."; Rec."Tracking No.")
                {
                    ApplicationArea = All;
                    Caption = 'Tracking No.';
                }
                field(Label; Rec.Label)
                {
                    ApplicationArea = All;
                    Caption = 'Label';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    Caption = 'Weight';
                }
                field("Shipment Label Handled"; Rec."Shipment Label Handled")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Entry Created"; Rec."Entry Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

            }

        }

    }

}