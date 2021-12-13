report 90099 "Move Channel Pay. to Archive"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("Channel Payment Line"; "Channel Payment Line")
        {

            trigger OnAfterGetRecord()
            begin
                MovingData("Channel Payment Line");
            end;

            trigger OnPostDataItem()
            var
                tempcount: Integer;
                L_CPL: Record "Channel Payment Line";
                L_CPH: Record "Channel Payment Header";
            begin
                L_CPL.Reset();
                L_CPL.SetRange("Moved to Archive", true);
                If L_CPL.FindSet() then begin
                    repeat
                        L_CPH.Reset();
                        L_CPH.SetRange("Statement No.", L_CPL."Statement No.");
                        if L_CPH.FindFirst() then
                            L_CPH.Delete();
                    until L_CPL.Next() = 0;
                    L_CPL.DeleteAll();
                end;

            end;

            trigger OnPreDataItem()
            begin
                Window.OPEN('Processing data... @1@@@@@@@@@@');
                NoOfRecs := "Channel Payment Line".COUNT;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Window.CLOSE;
    end;

    var
        NoOfRecs: Integer;
        CurrRec: Integer;
        Window: Dialog;
        GenSetupChannels: Record "General Setup - Channels";
        skipfilter: Boolean;

    local procedure MovingData(CPL: Record "Channel Payment Line")
    var
        AchivePayLine: Record "Archive Channel Payment";
        ArchivePaymentDetail: Record "Archive Payment Detail";
        PaymentDetail: Record "Payment Detail";
    begin
        AchivePayLine.INIT;
        AchivePayLine.TransferFields(CPL);
        AchivePayLine.Insert(true);
        CPL."Moved to Archive" := TRUE;
        CPL.MODIFY;
        //ArchivePayment++
        PaymentDetail.Reset();
        PaymentDetail.SetRange("Order No.", CPL."External Document No.");
        if PaymentDetail.FindFirst() then begin
            ArchivePaymentDetail.Init();
            ArchivePaymentDetail.TransferFields(PaymentDetail);
            ArchivePaymentDetail.Insert();
            PaymentDetail.Delete();
        end;
        //ArchivePayment--
    end;




}

