page 90088 "Shipping Rule Card"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Shipping Rule";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Channel Code"; Rec."Channel Code")// Need to Changes this Field PS 181119
                {
                    ApplicationArea = All;
                }

                field("BC Shipment Method"; Rec."BC Shipment Method")
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
                field("Shipping Charge"; Rec."Shipping Charge")
                {
                    ApplicationArea = All;
                }

                field(Weigth; Rec.Weight)
                {
                    ApplicationArea = All;
                }

                field("Child Client Id"; Rec."Child Client Id")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                    begin
                        Message('"Child Client ID" has been updated.\Please eliminate error on web order list manually to update it on order.');
                    end;
                }
                field("Child Client Name"; Rec."Child Client Name")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                    begin
                        Message('"Child Client Name" has been updated.\Please eliminate error on web order list manually to update it on order.');
                    end;
                }

            }
        }
    }


}