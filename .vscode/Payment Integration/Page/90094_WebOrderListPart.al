page 90094 "Web Order Detail"
{

    Caption = 'Matched Order Details';
    DeleteAllowed = false;
    Editable = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    ModifyAllowed = false;
    SourceTable = "Handled Interim Sales Header";
    SourceTableView = WHERE(Reconciled = const(true));
    InsertAllowed = false;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Trade Partner Code"; Rec."Trade Partner Code")
                {
                    ApplicationArea = all;
                }
                field("Channel Order ID"; Rec."Channel Order ID")
                {
                    ApplicationArea = all;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = all;
                }


            }
        }
    }


}

