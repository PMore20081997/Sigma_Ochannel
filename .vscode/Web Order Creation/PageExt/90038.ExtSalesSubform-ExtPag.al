pageextension 90038 "Ext Sales Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter(Allocated)
        {
            field("Total Free"; TotalAvailableQty(rec))
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
            field("Free"; TotalAvailableQtyForSaleable(Rec))
            {
                ApplicationArea = All;
                Editable = false;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Physical - Allocated on SO - Web Orders Qty';
                //Caption = 'Total Available Quantity(Saleable)';
                Caption = 'Free';
            }
        }
        addbefore("Variant Code mandatory")
        {
            field("Web Orders Qty"; Rec."Web Orders Qty")
            {
                ApplicationArea = All;
                DecimalPlaces = 0 : 5;
                ToolTip = 'Sucessfull Electronic Orders';
            }
        }
        modify("Net Weight")
        {
            Visible = true;

            trigger OnAfterValidate()
            begin
                Rec.TestStatusOpen();
            end;
        }

    }

    // actions
    // {
    //     addafter("Related Information")
    //     {
    //         group("Integration")
    //         {
    //             action("Web Order")
    //             {
    //                 ApplicationArea = All;
    //                 Image = Navigate;

    //                 trigger OnAction()
    //                 var
    //                     L_WebOrderList: Page "Web Order List";
    //                     L_InterimSalesHeader: Record "Interim Sales Header";
    //                 begin
    //                     Clear(L_WebOrderList);
    //                     L_InterimSalesHeader.Reset();
    //                     L_InterimSalesHeader.SetFilter("No.", SetWeborderFilter(Rec."Document No."));
    //                     L_WebOrderList.SetTableView(L_InterimSalesHeader);
    //                     L_WebOrderList.Run();
    //                 end;
    //             }
    //         }
    //     }
    // }

    local procedure SetWeborderFilter(_SalesOrderNo: Code[20]): Text
    var
        L_WebBuffer: Record "Web Buffer";
        WebOrderNo: Text;
    begin
        Clear(WebOrderNo);
        L_WebBuffer.Reset();
        L_WebBuffer.SetRange("Sales Document No.", _SalesOrderNo);
        L_WebBuffer.SetCurrentKey("Web Document No.");
        L_WebBuffer.Ascending(true);
        if L_WebBuffer.FindSet() then begin
            repeat
                if WebOrderNo <> '' then begin
                    WebOrderNo := WebOrderNo + '|' + L_WebBuffer."Web Document No.";
                end else
                    WebOrderNo := L_WebBuffer."Web Document No.";
            until L_WebBuffer.Next() = 0;
        end;
        exit(WebOrderNo);

    end;

    trigger OnDeleteRecord(): Boolean
    var
        HandledInterimSalesLine: Record "Handled Interim Sales Line";
        SalesOrderPage: Page "Sales Order";
    begin
        HandledInterimSalesLine.Reset();
        HandledInterimSalesLine.SetRange("Document No", Rec."Document No.");
        HandledInterimSalesLine.SetRange("Line No.", Rec."Line No.");
        if HandledInterimSalesLine.FindFirst() then begin
            HandledInterimSalesLine.Delete(true);
            SalesOrderPage.UpdateHandledInterimSalesHeader(Rec);
        end;
    end;

    local procedure TotalAvailableQty(_Rec: Record "Sales Line"): Decimal
    var
        L_ILE: Record "Item Ledger Entry";
    begin
        //+++++Formula:- Total Free => "Total Physical - Total SO Allocated - Web Orders Qty"
        //Inventory is Total Physical
        //Total SO Allocated is Allocated
        //Web Orders Qty is Web order Qty------
        _Rec.CalcFields(Inventory, Allocated, "Web Orders Qty");
        if (_Rec.Inventory - _Rec.Allocated - _Rec."Web Orders Qty") > 0 then
            exit(_Rec.Inventory - _Rec.Allocated - _Rec."Web Orders Qty")
        else
            exit(0);
    end;

    local procedure TotalAvailableQtyForSaleable(_Rec: Record "Sales Line"): Decimal
    var
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
    begin
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory", "Web Orders Qty");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)" - _Rec."Web Orders Qty")
            else
                exit(0)
        else
            exit(0);
    end;
}