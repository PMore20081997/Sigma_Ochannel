pageextension 90036 "Item Journal Ex" extends "Item Journal"
{
    layout
    {
        // Add changes to page layout here
    }
    
    actions
    {
        // Add changes to page actions here
        modify("&Calculate Warehouse Adjustment")
        {
         Visible = false;
        }
        addafter("&Calculate Warehouse Adjustment")
        {
          action("Calculate Warehouse Adjustment")
          {
                   ApplicationArea = Warehouse;
                    Caption = '&Calculate Warehouse Adjustment';
                    Ellipsis = true;
                    Image = CalculateWarehouseAdjustment;
                    ToolTip = 'Calculate adjustments in quantity based on the warehouse adjustment bin for each item in the journal. New lines are added for negative and positive quantities.';

                    trigger OnAction()
                    begin
                        CalcWhseAdjmt.SetItemJnlLine(Rec);
                        CalcWhseAdjmt.RunModal;
                        Clear(CalcWhseAdjmt);
                    end;
          }
        }
        
    }
    
    var
        CalcWhseAdjmt: Report "Calculate Whse. Adj. - Robosol";
}