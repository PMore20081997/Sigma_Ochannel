page 90084 "Shipment Tracking"
{
    PageType = List;
    SourceTable = "Shipment Tracking";
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
                field("A6 Label1"; Rec."A6 Label1")
                {
                    ApplicationArea = All;
                    Caption = 'Return Label';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    Caption = 'Weight';
                }
                field("Entry Created"; Rec."Entry Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Shipment Label Handled"; Rec."Shipment Label Handled")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("RAW Text"; Rec."RAW Text")
                {
                    ApplicationArea = All;
                    Editable = false;

                }

            }

        }

    }

    actions
    {
        area(Processing)
        {
            action("Direct Printing Label")
            {

                ApplicationArea = All;
                Caption = 'Label Print';
                Image = Print;
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    HandledInterimSalesHeader: Record "Handled Interim Sales Header";
                    WebMgt: Codeunit "Web Order Mgt";
                    ShippingAgent: Record "Shipping Agent";
                    L_ShipmentTracking: Record "Shipment Tracking";
                begin
                    ShippingAgent.Reset();
                    ShippingAgent.SetRange(Code, Rec."Shipping Agent Code");
                    if ShippingAgent.FindFirst() then begin
                        if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::RAW) then begin
                            //RAW Printing Option Means it is For DPD EPL Label and PDF labels
                            WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90084, FORMAT(ShippingAgent."Printing Options")); // 90084 - DPD Label printer (RAW)
                        end;
                        if (ShippingAgent."Printing Options" = ShippingAgent."Printing Options"::PDF) then begin
                            WebMgt.SendDirectPrintRequest(HandledInterimSalesHeader."No.", 90081, FORMAT(ShippingAgent."Printing Options")); // 90081 - PDF Label Printer (Windows Driver)
                        end;
                    end;
                end;
            }
        }
    }
}