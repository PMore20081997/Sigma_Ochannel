page 90015 "Customer Price Service"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = 7001;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Item No."; rec."Product No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                }
                field("Variant Code"; rec."Variant Code")
                {
                    ApplicationArea = all;
                }
                field("Source No."; rec."Source No.")
                {
                    ApplicationArea = all;
                }
                field("Unit Price"; rec."Unit Price")
                {
                    ApplicationArea = all;
                }
                field(Status; rec.Status)
                {
                    ApplicationArea = all;
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