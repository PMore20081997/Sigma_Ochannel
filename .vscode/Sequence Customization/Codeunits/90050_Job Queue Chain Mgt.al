codeunit 90050 "Job Queue Chain Mgt."
{
    //Job Queue chain within the same Job Queue Category++
    //Order of the chain is maintained in "Chain Sequence No." on Job Queue Entry (0 = Not part of the chain)
    //Example for LFE:
    //1. Report 90000 Process Web Orders (Consolidate)
    //2. Codeunit 90025 Manual/KNAAP SO Process - Release (Knapp)
    //3. Codeunit 90025 Manual/KNAAP SO Process - Release (Non Knapp)
    //4. Report 60056 LFE Export
    //If any earlier job in the chain is in Error, the later job raises an error so its Job Queue Entry also goes into Error++
    //Check is done for every Codeunit and Report job in the OnBeforeRun subscriber of "Job Queue Start Codeunit", no code needed in the job itself++
    //When a chain job finishes successfully, the later jobs which went into Error because of the chain are restarted++

    var
        ChainTagTok: Label '[Job Queue Chain]', Locked = true;
        EarlierJobInErrorMsg: Label 'Earlier job "%1" in Job Queue Category %2 is in Error.', Comment = '%1 = Job Queue Entry Description, %2 = Job Queue Category Code';
        EarlierJobLastRunFailedMsg: Label 'Last run of earlier job "%1" in Job Queue Category %2 failed.', Comment = '%1 = Job Queue Entry Description, %2 = Job Queue Category Code';
        ChainStoppedErr: Label '%1 This job was not executed. It will be restarted automatically when the earlier job finishes successfully.', Comment = '%1 = Reason';

    procedure StopIfEarlierJobFailed(_JobQueueEntry: Record "Job Queue Entry")
    var
        L_Reason: Text;
    begin
        if EarlierJobFailed(_JobQueueEntry, L_Reason) then
            Error('%1 %2', ChainTagTok, StrSubstNo(ChainStoppedErr, L_Reason));
    end;

    procedure EarlierJobFailed(_JobQueueEntry: Record "Job Queue Entry"; var _Reason: Text): Boolean
    var
        L_CurrentJobQueueEntry: Record "Job Queue Entry";
        L_EarlierJobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(_Reason);

        //Read the latest values of the Job Queue Entry++
        if not L_CurrentJobQueueEntry.Get(_JobQueueEntry.ID) then
            exit(false);

        //Chain works only within a Job Queue Category++
        if L_CurrentJobQueueEntry."Job Queue Category Code" = '' then
            exit(false);

        //First job or job not part of the chain++
        if L_CurrentJobQueueEntry."Chain Sequence No." <= 1 then
            exit(false);

        L_EarlierJobQueueEntry.Reset();
        L_EarlierJobQueueEntry.SetRange("Job Queue Category Code", L_CurrentJobQueueEntry."Job Queue Category Code");
        L_EarlierJobQueueEntry.SetRange("Chain Sequence No.", 1, L_CurrentJobQueueEntry."Chain Sequence No." - 1);
        if L_EarlierJobQueueEntry.FindSet() then
            repeat
                if JobFailed(L_EarlierJobQueueEntry, _Reason) then
                    exit(true);
            until L_EarlierJobQueueEntry.Next() = 0;

        exit(false);
    end;

    local procedure JobFailed(_JobQueueEntry: Record "Job Queue Entry"; var _Reason: Text): Boolean
    var
        L_JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        //Job Queue Entry in Error after all attempts++
        if _JobQueueEntry.Status = _JobQueueEntry.Status::Error then begin
            _Reason := StrSubstNo(EarlierJobInErrorMsg, _JobQueueEntry.Description, _JobQueueEntry."Job Queue Category Code");
            exit(true);
        end;

        //Last run failed but Job Queue Entry is still Ready (waiting for next attempt or restarted but not executed yet)++
        L_JobQueueLogEntry.Reset();
        L_JobQueueLogEntry.SetRange(ID, _JobQueueEntry.ID);
        if L_JobQueueLogEntry.FindLast() then
            if L_JobQueueLogEntry.Status = L_JobQueueLogEntry.Status::Error then begin
                _Reason := StrSubstNo(EarlierJobLastRunFailedMsg, _JobQueueEntry.Description, _JobQueueEntry."Job Queue Category Code");
                exit(true);
            end;

        exit(false);
    end;

    local procedure RestartLaterJobsStoppedByChain(_JobQueueEntry: Record "Job Queue Entry")
    var
        L_CurrentJobQueueEntry: Record "Job Queue Entry";
        L_LaterJobQueueEntry: Record "Job Queue Entry";
        L_RestartJobQueueEntry: Record "Job Queue Entry";
        L_Reason: Text;
    begin
        //Read the latest values of the Job Queue Entry++
        if not L_CurrentJobQueueEntry.Get(_JobQueueEntry.ID) then
            exit;

        //Only for jobs which are part of a chain++
        if (L_CurrentJobQueueEntry."Job Queue Category Code" = '') or (L_CurrentJobQueueEntry."Chain Sequence No." <= 0) then
            exit;

        L_LaterJobQueueEntry.Reset();
        L_LaterJobQueueEntry.SetRange("Job Queue Category Code", L_CurrentJobQueueEntry."Job Queue Category Code");
        L_LaterJobQueueEntry.SetFilter("Chain Sequence No.", '>%1', L_CurrentJobQueueEntry."Chain Sequence No.");
        L_LaterJobQueueEntry.SetRange(Status, L_LaterJobQueueEntry.Status::Error);
        if L_LaterJobQueueEntry.FindSet() then
            repeat
                //Restart only jobs stopped by the chain, not jobs failed by their own error++
                if StrPos(L_LaterJobQueueEntry."Error Message", ChainTagTok) = 1 then
                    //Restart only when all earlier jobs are fine now, the rest will be restarted when their earlier job finishes++
                    if not EarlierJobFailed(L_LaterJobQueueEntry, L_Reason) then
                        if L_RestartJobQueueEntry.Get(L_LaterJobQueueEntry.ID) then
                            L_RestartJobQueueEntry.SetStatus(L_RestartJobQueueEntry.Status::Ready); //Same as "Set Status to Ready" action++
            until L_LaterJobQueueEntry.Next() = 0;
    end;

    //Any job (Codeunit or Report) before it is executed - stop with an error if an earlier job in the chain failed++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Start Codeunit", 'OnBeforeRun', '', false, false)]
    local procedure OnBeforeRunStopIfEarlierJobFailed(var JobQueueEntry: Record "Job Queue Entry")
    begin
        StopIfEarlierJobFailed(JobQueueEntry);
    end;

    //Any job (Codeunit or Report) finished successfully - restart the later jobs stopped by the chain++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", 'OnAfterSuccessExecuteJob', '', false, false)]
    local procedure OnAfterSuccessExecuteJobRestartLaterJobs(var JobQueueEntry: Record "Job Queue Entry")
    begin
        RestartLaterJobsStoppedByChain(JobQueueEntry);
    end;
}
