pageextension 90002 AssemblyOrderCardExt extends "Assembly Order"
{
    layout
    {
        addafter(Description)
        {
            field("Channel Order Id"; Rec."Description 2")
            {
                Editable = false;
                ApplicationArea = All;
                Caption = 'Channel Order Id';
            }
        }
        addbefore(Lines)
        {
            field(Comments; Rec.Comments)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Comments field.';
            }
        }
    }
}