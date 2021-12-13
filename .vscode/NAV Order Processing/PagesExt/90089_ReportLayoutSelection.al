pageextension 90089 "Report Layout Ext" extends "Report Selection - Sales"
{
    layout
    {
        addbefore(Sequence)
        {
            field(Usage; Rec.Usage)
            {
                ApplicationArea = All;
            }
        }
    }
}