pageextension 90077 "Vendor Ledger Entry" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("Document Date"; Rec."Document Date")
            {
                ApplicationArea = All;
            }
        }
    }
}