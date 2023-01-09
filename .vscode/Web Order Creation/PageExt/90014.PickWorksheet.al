pageextension 90014 "Pick Worksheet" extends "Pick Worksheet"
{
    layout
    {
        addbefore(Control1)
        {
            field(Comments; Rec.Comments)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Comments field.';
            }
        }
    }
}
