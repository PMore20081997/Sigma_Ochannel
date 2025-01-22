page 90039 "Web Buffer TOS Modify"
{
    PageType = API;
    APIPublisher = 'Robosol';
    APIGroup = 'webBufferTOS';
    APIVersion = 'beta';
    EntityName = 'webBuffer';
    EntitySetName = 'webBuffers';
    UsageCategory = Lists;
    SourceTable = "Web Buffer";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Web_Document_No; Rec."Web Document No.")
                {
                    ApplicationArea = All;
                }
                field(Sales_Document_No; Rec."Sales Document No.")
                {
                    ApplicationArea = All;
                }
                field(TOS_Checked; Rec."TOS Checked")
                {
                    ApplicationArea = All;
                }
                field(Created_At; Rec."Created At")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}