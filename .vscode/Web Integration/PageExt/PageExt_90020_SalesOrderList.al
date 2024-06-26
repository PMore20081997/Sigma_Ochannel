pageextension 90020 SalesOrdListExt extends "Sales Order List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // addafter("&Print")
        // {
        //     action("EDI File 2")
        //     {
        //         ApplicationArea = All;
        //         Image = Journal;
        //         PromotedCategory = Process;
        //         Promoted = true;

        //         trigger OnAction()
        //         var
        //             EDIInvoiceCOD: Codeunit "EDI Invoice";
        //             JobQueueEntry: Record "Job Queue Entry" temporary;
        //             SalesHeader: Record "Sales Header";
        //             customer: Record "Customer";
        //         begin
        //             Clear(SalesHeader);
        //             SalesHeader := Rec;
        //             CurrPage.SetSelectionFilter(SalesHeader);

        //             if SalesHeader.FindSet() then begin
        //                 repeat
        //                     Clear(customer);
        //                     customer.Reset();
        //                     if customer.get(SalesHeader."Buy-from Vendor No.") then
        //                         EDIInvoiceCOD.ProcessEDIFile1(SalesHeader, customer);
        //                 until SalesHeader.Next() = 0;
        //             end;
        //         end;
        //     }
        // }

        addafter(Release)
        {
            action("Custom Release")
            {
                ApplicationArea = ALl;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
                    RecRef: RecordRef;
                begin
                    L_SalesHeader.Reset();
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    BatchProcessingMgt.BatchProcess(L_SalesHeader, Codeunit::"Sales Manual Release", Enum::"Error Handling Options"::"Show Notification", L_SalesHeader.Count, 0);
                    // RecRef.GetTable(L_SalesHeader);
                    // BatchProcessingMgt.BatchProcess(RecRef);
                end;
            }



            //GHST Customization++
            action("Update Variant On Lines")
            {
                ApplicationArea = All;
                Image = Insert;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_SalesHeader: Record "Sales Header";
                    UdateVariantonSO: Codeunit "Udate Variant on SO";
                begin
                    L_SalesHeader.Reset();
                    CurrPage.SetSelectionFilter(L_SalesHeader);
                    L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
                    L_SalesHeader.SetRange("Web Order", true);
                    if L_SalesHeader.FindSet() then
                        UdateVariantonSO.UpdateVariantOnSalesOrder(L_SalesHeader);

                end;
            }
        }
    }

    var
        myInt: Integer;
}