pageextension 90081 "Ware Rcpt Card Ext" extends "Whse. Receipt Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("No. of Copies"; Rec."No. of Copies")
            {
                ApplicationArea = All;


            }
        }
    }
}