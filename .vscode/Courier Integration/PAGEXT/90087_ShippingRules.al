page 90087 "Shipping Rules"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Shipping Rule";
    CardPageId = "Shipping Rule Card";

    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field(" Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;

                }

                field("NAV Shipment Method"; Rec."NAV Shipment Method")
                {
                    ApplicationArea = All;

                }
                field("Web Shipment Method"; Rec."Web Shipment Method")
                {
                    ApplicationArea = All;

                }
                field("Country To Deliver"; Rec."Country To Deliver")
                {
                    ApplicationArea = All;

                }
                field("Order Value"; Rec."Order Value")
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Minimum Order Value', ENG = 'Minimum Order Value';

                }
                field("Item Shipping Group"; Rec."Item Shipping Group")
                {
                    ApplicationArea = All;

                }
                field("Shipping Agent"; Rec."Shipping Agent")
                {
                    ApplicationArea = All;

                }
                field("Shipping Agent Service"; Rec."Shipping Agent Service")
                {
                    ApplicationArea = All;

                }
                field("Web Shipping Agent"; Rec."Web Shipping Agent")
                {
                    ApplicationArea = All;

                }
                field(Preference; Rec.Preference)
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
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}