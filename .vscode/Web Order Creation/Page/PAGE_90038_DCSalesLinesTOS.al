page 90038 "DC TOS Line Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Sales Line TOS";

    layout
    {
        area(Content)
        {
            repeater("TOS Lines")
            {
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(PIP_Code; Rec."PIP Code")
                {
                    ApplicationArea = All;
                }
                field(ET_Access_Code; Rec."ET Access Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Quantity_Shipped; Rec."Quantity Shipped")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Web_Order_No; Rec."Web Order No.")
                {
                    ApplicationArea = All;
                }
                field(Sales_Order_No; Rec."Sales Order No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        Codeunit.Run(90021);
    end;
}