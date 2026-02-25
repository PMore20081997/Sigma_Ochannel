page 90062 "PS Label Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Polar Speed Barcode";
    Editable = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Order Category"; rec."Order Category")
                {
                    ApplicationArea = all;
                }
                field("Sales Invoice No"; rec."Sales Invoice No.")
                {
                    ApplicationArea = all;
                }
                field("Customer No."; rec."Customer No.")
                {
                    ApplicationArea = all;
                }
                field("Tote No"; rec."Tote No.")
                {
                    ApplicationArea = all;
                }
                field("Box No"; rec."Box No.")
                {
                    ApplicationArea = all;
                }
                field("Barcode No."; rec."Barcode No.")
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
            action("Polar Item Label")
            {
                Caption = 'Polar Item Label';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    L_Barcode: Record "Polar Speed Barcode";
                    Report_PolarItemLabel: Report "Polar Item Label";
                begin
                    Clear(Report_PolarItemLabel);
                    L_Barcode.Reset();
                    CurrPage.SetSelectionFilter(L_Barcode);
                    Report_PolarItemLabel.SetTableView(L_Barcode);
                    Report_PolarItemLabel.UseRequestPage(true);
                    Report_PolarItemLabel.RunModal();
                end;
            }
        }
    }

    var
        myInt: Integer;
}