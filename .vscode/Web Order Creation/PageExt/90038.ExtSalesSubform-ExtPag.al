pageextension 90038 "Ext Sales Subform" extends "Sales Order Subform"
{
    layout
    {
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
}