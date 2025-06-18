pageextension 90027 "OCH ePOD Run List" extends "ePOD Run List"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Processing)
        {
            action("Create & Sync Consolidated Job")
            {
                ApplicationArea = All;
                Image = New;

                trigger OnAction()
                var
                    L_ePODrun: Record "ePOD Runs";
                    L_ePODJobHeader: Record "ePOD Job Header";
                    L_PODFatherIntegration: Codeunit "POD Father Integration";
                begin
                    L_ePODrun.Reset();
                    CurrPage.SetSelectionFilter(L_ePODrun);
                    if L_ePODrun.FindSet() then begin
                        repeat
                            //Create Consolidated JOB+++
                            L_PODFatherIntegration.CreateConsolidatedJob(L_ePODrun."Run ID", L_ePODrun.Date, L_ePODrun."Agent Code", L_ePODrun."Agent Service Code", true);


                            //Sync to POD portal++
                            L_ePODJobHeader.Reset();
                            L_ePODJobHeader.SetRange("ePOD RunID", L_ePODrun."Run ID");
                            L_ePODJobHeader.SetRange("Shipment Date", L_ePODrun.Date);
                            L_ePODJobHeader.SetRange("Shipping Agent Code", L_ePODrun."Agent Code");
                            L_ePODJobHeader.SetRange("Shipping Agent Service Code", L_ePODrun."Agent Service Code");
                            L_ePODJobHeader.SetRange("Synced to ePOD", false);
                            if L_ePODJobHeader.FindSet() then begin
                                repeat
                                    L_PODFatherIntegration.ConsolidatedJob_OnPODFatherPortal('EPOD', L_ePODJobHeader);
                                until L_ePODJobHeader.Next() = 0;
                            end;
                        until L_ePODrun.Next() = 0;
                    end;
                end;
            }
            action("Consolidated Job")
            {
                ApplicationArea = All;
                Image = Navigate;
                RunObject = page "ePOD Job List";
                RunPageLink = "ePOD RunID" = field("Run ID");
            }

            action(Test)
            {
                ApplicationArea = All;
                Image = New;
                trigger OnAction()
                var
                    L_SalesInvoiceHeader: Record "Sales Invoice Header";
                    PODFatherIntegration: Codeunit "POD Father Integration";
                begin
                    L_SalesInvoiceHeader.Reset();
                    L_SalesInvoiceHeader.SetFilter("No.", '%1|%2|%3', '5001077915', '5001077916', '5001080558');
                    if L_SalesInvoiceHeader.FindSet() then begin
                        repeat
                            PODFatherIntegration.UpdateePODJobConsolidatedFeild_PostedsalesInvoiceHeader(L_SalesInvoiceHeader."No.");
                        until L_SalesInvoiceHeader.Next() = 0;
                    end;
                end;

            }
        }
    }

    var
        myInt: Integer;
}