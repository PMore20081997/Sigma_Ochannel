pageextension 90021 "OC Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addbefore("Total Physical")
        {
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Sucessfull Electronic Orders';
            }
        }
        addafter("Total Allocated on SO")
        {
            field("Total Free"; G_CT_Function.Purchase_TotalFree(Rec))
            {
                Caption = 'Total Free';
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Total Physical - Total SO Allocated - Web Order Qty';
            }
        }
        addafter("Allocated on SO")
        {
            field(Free; G_CT_Function.Purchase_Free(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
                Caption = 'Free';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        G_CT_Function: Codeunit "Inventory Calculation";
}