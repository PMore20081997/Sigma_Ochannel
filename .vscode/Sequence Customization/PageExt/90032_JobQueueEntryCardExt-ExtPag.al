pageextension 90032 "OC Job Queue Entry Card" extends "Job Queue Entry Card"
{
    layout
    {
        addafter("Job Queue Category Code")
        {
            field("Chain Sequence No."; Rec."Chain Sequence No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the order of this job in the Job Queue Category chain. If an earlier job in the chain is in Error, this job also goes into Error. 0 = Not part of the chain.';
            }
        }
    }
}
