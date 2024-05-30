pageextension 90023 "OC Special Promotions" extends "Special Promotions"
{
    layout
    {
        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
            end;
        }

        addafter("Total Allocated on SO")
        {
            field("Total Free"; G_CT_Function.CT_TotalFree(rec))
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
            field(Free; G_CT_Function.CT_Free(Rec))
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