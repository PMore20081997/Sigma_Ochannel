page 90093 "Channel Pay. Reconciliations"
{
    ApplicationArea = All;
    Caption = 'Channel Payment Reconciliations';
    CardPageID = "Channel Pay. Reconciliation";
    PageType = List;
    SourceTable = "Channel Payment Header";
    UsageCategory = Lists;
    DeleteAllowed = false;
    InsertAllowed = true;
    ModifyAllowed = true;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Statement No."; Rec."Statement No.")
                {
                    ApplicationArea = All;
                }
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;

                }
                field("Payment Service Provider"; Rec."Payment Service Provider")
                {
                    ApplicationArea = All;
                }
                field("Transaction From"; Rec."Transaction From")
                {
                    ApplicationArea = All;
                }
                field("Transaction To"; Rec."Transaction To")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }


}

