pageextension 90023 "OC Special Promotions" extends "Special Promotions"
{
    layout
    {
        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            var
                RecUserSetup: Record "User Setup";
                CustomerTrendSalesQuota: Codeunit "Customer Trend Sales Quota New";
            begin
                CurrPage.Update();

                //Check Item Sales Quota (For Both Promotion and Normal Item)++
                if Rec."Qty. to be added to SO" > 0 then begin
                    IF RecUserSetup.GET(USERID) THEN BEGIN
                        IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                            CustomerTrendSalesQuota.CheckExceededQty(Rec);
                        END;
                    END ELSE BEGIN
                        CustomerTrendSalesQuota.CheckExceededQty(Rec);
                    END;
                end;
            end;
        }

        // addafter("Total Allocated on SO")
        // {
        //     field("Total Free"; G_CT_Function.CT_TotalFree(rec))
        //     {
        //         Caption = 'Total Free';
        //         ApplicationArea = All;
        //         Editable = false;
        //         DecimalPlaces = 0 : 5;
        //         ToolTip = 'Total Physical - Total SO Allocated - Web Order Qty';
        //     }
        // }

        // addafter("Allocated on SO")
        // {
        //     field(Free; G_CT_Function.CT_Free(Rec))
        //     {
        //         ApplicationArea = All;
        //         Editable = false;
        //         DecimalPlaces = 0 : 5;
        //         ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
        //         Caption = 'Free';
        //     }
        // }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        G_CT_Function: Codeunit "Inventory Calculation";


}