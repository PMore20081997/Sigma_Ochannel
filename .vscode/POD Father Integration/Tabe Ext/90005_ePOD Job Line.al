tableextension 90005 "OC ePOD Job Line" extends "ePOD Job Line"
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

    // trigger OnDelete()
    // var
    //     L_ePODJobLine: Record "ePOD Job Line";
    //     L_SalesInvoiceHeader: Record "Sales Invoice Header";
    //     PODFatherIntegration: Codeunit "POD Father Integration";
    // begin
    //     //Check if job exist in POD father system+++
    //     if PODFatherIntegration.CheckDeleteJobinPODFather(Rec."ePOD ID", 'EPOD') = false then begin
    //         L_SalesInvoiceHeader.Reset();
    //         L_SalesInvoiceHeader.SetRange("No.", Rec."BC Invoice Number");
    //         if L_SalesInvoiceHeader.FindFirst() then begin
    //             L_SalesInvoiceHeader."ePOD Job Consolidated" := false;
    //             if L_SalesInvoiceHeader.Modify() then
    //                 Rec.Delete();
    //         end;
    //     end else
    //         Error('You cannot delete this job because it exists in the POD Father system');
    // end;
}