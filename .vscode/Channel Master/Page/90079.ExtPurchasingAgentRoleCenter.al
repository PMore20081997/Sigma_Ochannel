pageextension 90028 PurchasingAgentRoleCenter extends "Purchasing Agent Role Center"
{
    layout
    {
        addafter("Job Queue Tasks Activities")
        {
            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
        }
    }

    actions
    {


    }

    var
        myInt: Integer;
}