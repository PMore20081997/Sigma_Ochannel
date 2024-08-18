pageextension 90025 "OC Customer Trend Subform" extends "Customer Trends Subform"
{
    layout
    {
        // Add changes to page layout here
        modify("Qty. to be added to SO")
        {
            trigger OnAfterValidate()
            begin
                CurrPage.Update();
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
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
        G_Colour: Text;


    trigger OnAfterGetCurrRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
    begin
        //Set Color For Special Items on Top Screen++
        Clear(G_Colour);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CustomerTrends.SetRange("Customer No.", Rec."Customer No.");
        L_CustomerTrends.SetRange("Special Promotion", false); //For Top SCreen
        L_CustomerTrends.SetRange("Item No.", Rec."Item No.");
        if L_CustomerTrends.FindFirst() then begin
            if L_CustomerTrends."Special Item on Top SCreen" = true then
                G_Colour := 'Favorable';
        end;
    end;

    trigger OnAfterGetRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
    begin
        //Set Color For Special Items on Top Screen++
        Clear(G_Colour);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CustomerTrends.SetRange("Customer No.", Rec."Customer No.");
        L_CustomerTrends.SetRange("Special Promotion", false); //For Top SCreen
        L_CustomerTrends.SetRange("Item No.", Rec."Item No.");
        if L_CustomerTrends.FindFirst() then begin
            if L_CustomerTrends."Special Item on Top SCreen" = true then
                G_Colour := 'Favorable';
        end;
    end;
}