tableextension 90002 "OC ePOD Job Header" extends "ePOD Job Header"
{
    fields
    {
        // Add changes to table fields here
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnDelete()
    var
        L_ePODJobLine: Record "ePOD Job Line";
        L_SalesInvoiceHeader: Record "Sales Invoice Header";
        PODFatherIntegration: Codeunit "POD Father Integration";
    begin
        //Check if job exist in POD father system+++
        if PODFatherIntegration.CheckDeleteJobinPODFather(Rec."ePOD ID", 'EPOD') = true then begin
            L_ePODJobLine.Reset();
            L_ePODJobLine.SetRange("Document No.", Rec."No.");
            if L_ePODJobLine.FindSet() then begin
                repeat
                    L_SalesInvoiceHeader.Reset();
                    L_SalesInvoiceHeader.SetRange("No.", L_ePODJobLine."BC Invoice Number");
                    if L_SalesInvoiceHeader.FindFirst() then begin
                        PODFatherIntegration.UpdateStatus_PostedsalesInvoiceHeader(L_SalesInvoiceHeader."No.");
                    end;
                until L_ePODJobLine.Next() = 0;
            end;

            L_ePODJobLine.Reset();
            L_ePODJobLine.SetRange("Document No.", Rec."No.");
            if L_ePODJobLine.FindSet() then
                L_ePODJobLine.DeleteAll();
        end else
            Error('You cannot delete this job because it exists in the POD Father system.');
    end;
}