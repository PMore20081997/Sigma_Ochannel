pageextension 90008 "Source Doc Filter Card Ext" extends "Source Document Filter Card"
{
    layout
    {
        addafter("Shipping Agent Service Filter")
        {

            field("Default No. Of Orders"; Rec."Default No. Of Orders")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Number of the No. Of Orders to processed by Default.';
            }
        }
    }
}
