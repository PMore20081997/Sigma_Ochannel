page 90091 "Archive Channel Pay. Recon"
{
    Caption = 'Archived Channel Payment Reconciliation';
    PageType = List;
    SourceTable = "Archive Channel Payment";
    Editable = false;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;

                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;

                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;

                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;

                }
                field("Order Amount (System)"; Rec."Order Amount (System)")
                {
                    ApplicationArea = All;

                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;

                }
                field(Fees; Rec.Fees)
                {
                    ApplicationArea = All;

                }
                field(Diffrance; Rec.Diffrance)
                {
                    ApplicationArea = All;

                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;

                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;

                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;

                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;

                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = All;

                }
                field("Journal Created"; Rec."Journal Created")
                {
                    ApplicationArea = All;
                }
            }


        }

    }

}



