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
            field("Total Free"; TotalFree(Rec))
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
            field(Free; Free(Rec))
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

    local procedure TotalFree(_Rec: Record "Purchase Line") _TotalFree: Decimal
    begin
        _Rec.CalcFields("Total Physical", "Total Allocated on SO", "Web Orders Qty");
        _TotalFree := _Rec."Total Physical" - (_Rec."Total Allocated on SO" + _Rec."Web Orders Qty");
        if _TotalFree > 0 then
            exit(_TotalFree)
        else
            exit(0);
    end;


    local procedure Free(_Rec: Record "Purchase Line") _Free: Decimal
    begin
        _Rec.CalcFields("Allocated on SO", Physical, "Web Orders Qty");
        _Free := _Rec.Physical - (_Rec."Allocated on SO" + _Rec."Web Orders Qty");
        if _Free > 0 then
            exit(_Free)
        else
            exit(0);
    end;
}