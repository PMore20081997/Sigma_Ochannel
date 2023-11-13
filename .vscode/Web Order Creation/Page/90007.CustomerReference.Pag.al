page 90007 "Customer Reference"
{
    Caption = 'Customer Reference List';
    PageType = List;
    SourceTable = "Customer Reference";
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("ET Access Code"; Rec."ET Access Code")
                {
                    ApplicationArea = Planning;
                }
            }
        }
    }
}