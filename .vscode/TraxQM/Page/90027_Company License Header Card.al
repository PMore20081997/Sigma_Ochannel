pageextension 90027 "OCH Company License Card" extends "Company License Header Card"
{
    layout
    {


    }

    actions
    {
        addlast(Processing)
        {
            action("Sync GPHC License (TraxQM)")
            {
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = false;
                trigger OnAction();
                var
                    companyLicsync: Codeunit "TraxQM License Sync";
                begin
                    companyLicsync.SyncGPHCLicense(Rec);
                end;
            }

        }
    }
}
