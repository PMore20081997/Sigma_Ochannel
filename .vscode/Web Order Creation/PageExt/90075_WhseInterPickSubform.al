pageextension 90075 "Whse Internal Pick Subform" extends "Whse. Internal Pick Line"
{
    layout
    {
        addafter("Qty. per Unit of Measure")
        {
            field("Bay No."; Rec."Bay No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("Channel Order ID"; Rec."Channel Order ID")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
    actions
    {
        addafter("Item &Tracking Lines")
        {
            action("Web Orders")
            {
                ApplicationArea = All;
                Image = OrderList;
                ToolTip = 'Show Related Web Orders';
                trigger OnAction()
                var
                    WhseInternalPickHeader: Record "Whse. Internal Pick Header";
                    CU90005: Codeunit "Process Web Order";
                begin
                    WhseInternalPickHeader.RESET;
                    WhseInternalPickHeader.SETRANGE("No.", Rec."No.");
                    IF WhseInternalPickHeader.FINDFIRST THEN
                        CU90005.ShowWebOrderLines(WhseInternalPickHeader, Rec, TRUE);
                end;
            }
        }
    }

}