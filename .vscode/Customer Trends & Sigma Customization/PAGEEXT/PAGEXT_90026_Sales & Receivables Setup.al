pageextension 90026 "OC Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Check Variant on Consolidation"; Rec."Check Variant on Consolidation")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast(Payment)
        {
            action("Revalidate Variant On SO")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    Rec_SalesHeader: Record "Sales Header";
                    UdateVariantonSO: Codeunit "Udate Variant on SO";
                    L_SalesLine: Record "Sales Line";
                    NoSeriesManagement: Codeunit "No. Series";
                    Rec_SalesLine: Record "Sales Line";
                    CU_ReleaseSalesDoc: Codeunit "Release Sales Document";
                    KnappOrder: Boolean;
                    ItemList: List of [Text];
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    L_Location: Record Location;

                    MinOrder_Header: Record "Sales Header";
                    L_SumMin: Decimal;
                    L_RequiredRelease: Boolean;
                    L_ReleaseSalesHeader: Record "Sales Header";
                begin
                    Commit();
                    L_SalesHeader.Reset();
                    L_SalesHeader.CalcFields("Sent to Knapp");
                    L_SalesHeader.SetRange("Knapp Order", true);
                    L_SalesHeader.SetFilter("Shipment Date", '%1..%2', CalcDate('-1D', WorkDate()), 20990101D);
                    L_SalesHeader.SetRange("Sent to Knapp", false);
                    if L_SalesHeader.FindSet() then begin
                        repeat
                            Clear(L_RequiredRelease);
                            Rec_SalesHeader.Reset();
                            Rec_SalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type"::Order);
                            Rec_SalesHeader.SetRange("No.", L_SalesHeader."No.");
                            if Rec_SalesHeader.FindFirst() then begin
                                //Open SO
                                if Rec_SalesHeader.Status = Rec_SalesHeader.Status::Released then begin
                                    Rec_SalesHeader.PerformManualReopen(Rec_SalesHeader);
                                    L_RequiredRelease := true;
                                end;

                                //Revalidate Variant++
                                UdateVariantonSO.RevalidateVariantOnSalesOrder(Rec_SalesHeader);

                                //Send for Release order if Approval not required
                                if L_RequiredRelease = true then begin
                                    L_ReleaseSalesHeader.Reset();
                                    L_ReleaseSalesHeader.SetRange("No.", Rec_SalesHeader."No.");
                                    L_ReleaseSalesHeader.SetRange("Document Type", Rec_SalesHeader."Document Type");
                                    if L_ReleaseSalesHeader.FindFirst() then begin
                                        Rec_SalesHeader.CalcFields("Zero Price Approval", "SO Min Order Approval Required", Amount);
                                        if (Rec_SalesHeader."Zero Price Approval" = false) AND (Rec_SalesHeader."Sales Quota Approval" = false) AND (Rec_SalesHeader."SO Approval Required" = false) AND (Rec_SalesHeader."Shortcut Dimension 3 Code" <> 'M – EXPORT') AND (Rec_SalesHeader."Credit Limit Approval" = false) then begin
                                            Clear(L_SumMin);
                                            MinOrder_Header.Reset();
                                            MinOrder_Header.SetRange("Document Type", MinOrder_Header."Document Type"::Order);
                                            MinOrder_Header.SetRange("Sell-to Customer No.", Rec_SalesHeader."Sell-to Customer No.");
                                            MinOrder_Header.SetRange("Document Date", Rec_SalesHeader."Document Date");
                                            MinOrder_Header.SetFilter("Min Order Value", '<>%1', 0);
                                            if MinOrder_Header.FindSet() then begin
                                                repeat
                                                    MinOrder_Header.CalcFields(Amount);
                                                    L_SumMin += MinOrder_Header.Amount;
                                                until MinOrder_Header.Next() = 0;
                                            end;

                                            if Rec_SalesHeader."Min Order Value" <> 0 then begin
                                                if L_SumMin >= Rec_SalesHeader.Amount then begin
                                                    CU_ReleaseSalesDoc.PerformManualRelease(L_ReleaseSalesHeader);
                                                    Commit();
                                                end;
                                            end else begin
                                                CU_ReleaseSalesDoc.PerformManualRelease(L_ReleaseSalesHeader);
                                                Commit();
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        until L_SalesHeader.Next() = 0;
                    end;
                    Message('Process Completed');
                end;
            }
        }
    }

    var
        myInt: Integer;
}