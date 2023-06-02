pageextension 90015 "Pick Selection" extends "Pick Selection"
{
    layout
    {
        // Add changes to page layout here
        addafter("Location Code")
        {

            field("Channel Order ID"; Rec."Channel Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Channel Order ID field.';
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        L_AssemblyHeader: Record "Assembly Header";
    begin
        if Rec."Document Type" = Rec."Document Type"::Assembly then begin
            L_AssemblyHeader.Reset();
            L_AssemblyHeader.SetRange("Document Type", L_AssemblyHeader."Document Type"::Order);
            L_AssemblyHeader.SetRange("No.", Rec."Document No.");
            if NOT L_AssemblyHeader.FindFirst() then
                Rec.Delete(true);
        end;
    end;

}