page 90098 "Channel Pay. Recon Lines"
{
    AutoSplitKey = true;
    Caption = 'Channel Payment Reconciliation Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Channel Payment Line";
    //Editable = false;
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
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                    Visible = false;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Order Amount (System)"; Rec."Order Amount (System)")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    trigger OnValidate()
                    begin
                     Rec.Diffrance := Rec."Order Amount (System)" - Rec."Discount Amount" - (Rec.Amount + abs(Rec.Fees));   
                    end;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field(Fees; Rec.Fees)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    trigger OnValidate()
                    begin
                     Rec.Diffrance := Rec."Order Amount (System)" - Rec."Discount Amount" - (Rec.Amount + abs(Rec.Fees));   
                    end;
                }
                field(Diffrance; Rec.Diffrance)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Journal Created"; Rec."Journal Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }


        }

    }
    actions
    {
        area(Processing)
        {

            action(AutoMatch)
            {
                ApplicationArea = All;
                Caption = 'Manual Match';
                Image = Reconcile;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_PaymentDetail: Record "Payment Detail";
                    OchannelGenSetup: record "General Setup - Channels";
                    L_ChannelLine: Record "Channel Payment Line";
                begin
                    OchannelGenSetup.Get();
                    CurrPage.SetSelectionFilter(L_ChannelLine);
                    L_ChannelLine.SetRange(Reconciled, false);
                    if L_ChannelLine.FindFirst() then
                        repeat
                            L_PaymentDetail.Reset();
                            L_PaymentDetail.SetRange("Order No.", L_ChannelLine."External Document No.");
                            L_PaymentDetail.SetRange("Journal Created", true);
                            if L_PaymentDetail.FindFirst() then
                                repeat
                                    UpdateReconcileLine(L_ChannelLine, OchannelGenSetup."Threshold Value", 1);
                                until L_PaymentDetail.Next() = 0;
                        until L_ChannelLine.Next() = 0;
                end;
            }
            action(removematch)
            {
                ApplicationArea = All;
                Caption = 'Remove Match';
                Image = RemoveLine;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_HISH: Record "Handled Interim Sales Header";
                    L_PaymentDetail: Record "Payment Detail";
                    L_ChannelPayLines: Record "Channel Payment Line";
                begin
                    CurrPage.SetSelectionFilter(L_ChannelPayLines);
                    if L_ChannelPayLines.FindFirst() then
                        repeat
                            L_HISH.Reset();
                            L_HISH.SetRange("Document Type", L_HISH."Document Type"::Order);
                            L_HISH.SetRange("Channel Order ID", L_ChannelPayLines."External Document No.");
                            if L_HISH.FindFirst() then begin
                                L_HISH.Reconciled := false;
                                L_HISH.Modify(true);
                            end;
                            L_PaymentDetail.Reset();
                            L_PaymentDetail.SetRange("Order No.", L_ChannelPayLines."External Document No.");
                            L_PaymentDetail.SetRange("Journal Created", true);
                            L_PaymentDetail.SetRange(Reconciled, true);
                            if L_PaymentDetail.FindFirst() then
                                repeat
                                    L_PaymentDetail.Reconciled := false;
                                    //L_PaymentDetail."Journal Created" := false;
                                    L_PaymentDetail.Modify();
                                until L_PaymentDetail.Next() = 0;
                            L_ChannelPayLines.Reconciled := false;
                            L_ChannelPayLines.Modify();
                        until L_ChannelPayLines.next() = 0;

                end;
            }
            action(MoveToJournalAndPost)
            {
                ApplicationArea = All;
                Caption = 'Move To Journal And Post';
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ChannelPayLine: Record "Channel Payment Line";
                begin
                    ChannelPayLine.Reset();
                    ChannelPayLine.SetRange("Statement No.", Rec."Statement No.");
                    ChannelPayLine.SetRange(Reconciled, true);
                    ChannelPayLine.SetRange("Journal Created", false);
                    if ChannelPayLine.FindSet() then begin
                        repeat
                            CreateJournal(ChannelPayLine);
                            //CreateFeeJournal(ChannelPayLine);
                        until ChannelPayLine.Next() = 0;
                        PostJournal();
                        ArchiveChannelPayment();
                    end;
                end;
            }
            action("Get Source Document")
            {
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_CPL: Record "Channel Payment Line";
                    HISH: Record "Handled Interim Sales Header";
                    PageHandledWebOrder: Page "Handled Web Order List";
                begin
                    L_CPL.Reset();
                    L_CPL.SetRange("Statement No.", Rec."Statement No.");
                    L_CPL.SetRange("Line No.", Rec."Line No.");
                    L_CPL.SetRange(Reconciled, false);
                    if L_CPL.FindFirst() then begin
                        HISH.Reset();
                        HISH.SetRange("Document Type", HISH."Document Type"::Order);
                        HISH.SetRange("Channel Order ID", L_CPL."External Document No.");
                        if HISH.FindFirst() then begin
                            Clear(PageHandledWebOrder);
                            PageHandledWebOrder.SetTableView(HISH);
                            PageHandledWebOrder.Run();
                        end;

                    end;
                end;
            }
        }
    }
    var
        StyleTxt: Text;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := SetStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        StyleTxt := SetStyle();
    end;

    local procedure SetStyle() Style: Text
    var
        IsHandled: Boolean;
    begin

        if IsHandled Then
            exit(Style);

        if Rec.Reconciled then
           exit('favorable');
        
        if rec.IsError then
           exit('Attention');
    end;

    local procedure UpdateReconcileLine(P_ChannelPaymentLine: Record "Channel Payment Line"; P_ThresholdValue: Decimal; calledfrom: Integer)
    var
        L_HISL: Record "Handled Interim Sales Line";
        L_Amount: Decimal;
        L_HISH: Record "Handled Interim Sales Header";
        L_PaymentMethod: Record "Web Payment";
        L_PaymentDetail: Record "Payment Detail";
        L_fees: Decimal;
        recon: Boolean;
        updaterecon: Boolean;
    begin
        Clear(L_Amount);
        Clear(updaterecon);

        L_Amount := P_ChannelPaymentLine."Order Amount (System)";
        L_PaymentDetail.Reset();
        L_PaymentDetail.SetRange("Order No.", P_ChannelPaymentLine."External Document No.");
        if L_PaymentDetail.FindFirst() then
            repeat
                L_fees := L_fees + L_PaymentDetail.Fees;
            until L_PaymentDetail.Next() = 0;



        if L_Amount = P_ChannelPaymentLine.Amount + abs(L_fees) then
            updaterecon := true
        else
            if calledfrom = 1 then
                updaterecon := true;

        if updaterecon then begin
          L_HISH.Reset();
          L_HISH.SetRange("Document Type", L_HISH."Document Type"::Order);
          L_HISH.SetRange("Channel Order ID", P_ChannelPaymentLine."External Document No.");
          if L_HISH.FindFirst() then begin
            IF L_HISH.Reconciled = false then begin   
              L_HISH.Validate(Reconciled, true);
              L_HISH.Modify(true);            
           
              P_ChannelPaymentLine.Validate(Reconciled, true);
              P_ChannelPaymentLine.Modify(true);
            
              L_PaymentDetail.Reset();
              L_PaymentDetail.SetRange("Order No.", P_ChannelPaymentLine."External Document No.");
              L_PaymentDetail.SetRange("Journal Created", true);
              L_PaymentDetail.SetRange(Reconciled, false);
              if L_PaymentDetail.FindFirst() then
                repeat
                    L_PaymentDetail.Reconciled := true;
                until L_PaymentDetail.Next() = 0;           
            end else begin
              P_ChannelPaymentLine.IsError := true;
              P_ChannelPaymentLine.Error := StrSubstNo('Order %1 already reconciled',P_ChannelPaymentLine."External Document No.");
              P_ChannelPaymentLine.Modify(true);   
            end;  
         end;

        end else begin
            L_Amount := L_Amount - P_ChannelPaymentLine.Amount;

            if recon then begin
                P_ChannelPaymentLine.Validate(Reconciled, true);
                P_ChannelPaymentLine.Modify(true);
                L_HISH.Reset();
                L_HISH.SetRange("Document Type", L_HISH."Document Type"::Order);
                L_HISH.SetRange("No.", L_HISL."Document No");
                if L_HISH.FindFirst() then begin
                    //L_ISH.Validate(Reconciled, true);
                    L_HISH.Modify(true);
                end;
                L_PaymentDetail.Reset();
                L_PaymentDetail.SetRange("Order No.", P_ChannelPaymentLine."External Document No.");
                L_PaymentDetail.SetRange("Journal Created", true);
                L_PaymentDetail.SetRange(Reconciled, true);
                if L_PaymentDetail.FindFirst() then
                    repeat
                        L_PaymentDetail.Reconciled := true;
                    until L_PaymentDetail.Next() = 0;
            end;
            //ThresholdValue--
        end;
    end;

    local procedure CreateJournal(P_ChannelPayLines: Record "Channel Payment Line")
    var
        L_GenJournLine: Record "Gen. Journal Line";
        L_GenJournLine1: Record "Gen. Journal Line";
        L_LineNo: Integer;
        ChannelSetup: Record "General Setup - Channels";
        L_Customer: Record Customer;
        L_HISL: Record "Handled Interim Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        ChannelSetup.Get();
        ChannelSetup.TestField("Payment Journal Template");
        ChannelSetup.TestField("Payment Jounal Batch");
        GenJournalBatch.Get(ChannelSetup."Payment Journal Template",ChannelSetup."Payment Jounal Batch");
        Clear(L_LineNo);
        L_GenJournLine.Reset();
        L_GenJournLine.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
        L_GenJournLine.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
        if L_GenJournLine.FindLast() then
            L_LineNo := L_GenJournLine."Line No."
        else
            L_LineNo := 10000;

        L_GenJournLine.Reset();
        L_GenJournLine.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
        L_GenJournLine.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
        L_GenJournLine.SetRange("Posting Date", P_ChannelPayLines."Posting Date");
        if P_ChannelPayLines."Payment Method Code" <> '' then
            L_GenJournLine.SetRange("Payment Method Code", P_ChannelPayLines."Payment Method Code");
        L_GenJournLine.SetRange("Creditor No.", P_ChannelPayLines."Channel Code");
        if P_ChannelPayLines."Payment Type" = P_ChannelPayLines."Payment Type"::Payment then
            L_GenJournLine.SetRange("Account Type", L_GenJournLine."Account Type"::"Bank Account")
        else
            L_GenJournLine.SetRange("Account Type", L_GenJournLine."Account Type"::Customer);
        if NOT L_GenJournLine.FindFirst() then begin
            L_GenJournLine.Init();
            L_GenJournLine.Validate("Journal Template Name", ChannelSetup."Payment Journal Template");
            L_GenJournLine.Validate("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
            L_GenJournLine."Line No." += L_LineNo;
            L_GenJournLine.Validate("Posting Date", P_ChannelPayLines."Posting Date");

            if P_ChannelPayLines."Document No." <>'' then
              L_GenJournLine.Validate("Document No.", P_ChannelPayLines."Document No.")
            else
              L_GenJournLine.Validate("Document No.", NoSeriesMgt.GetNextNo(GenJournalBatch."No. Series",WorkDate(),true));

            L_GenJournLine.Validate("External Document No.", P_ChannelPayLines."External Document No.");
            if P_ChannelPayLines."Payment Type" = P_ChannelPayLines."Payment Type"::Payment then begin
                L_GenJournLine.Validate("Document Type", L_GenJournLine."Document Type"::Payment);
                L_GenJournLine.Validate("Account Type", L_GenJournLine."Account Type"::"Bank Account");
                L_GenJournLine.Validate("Account No.", ChannelSetup."Bank Account No.");
                L_GenJournLine.Validate("Bal. Account Type", L_GenJournLine."Bal. Account Type"::Customer);
                L_GenJournLine.Validate("Bal. Account No.", P_ChannelPayLines."Bal. Account No.");
            end else begin
                L_GenJournLine.Validate("Document Type", L_GenJournLine."Document Type"::Refund);
                L_GenJournLine.Validate("Account Type", L_GenJournLine."Account Type"::Customer);
                L_GenJournLine.Validate("Account No.", P_ChannelPayLines."Bal. Account No.");
                L_GenJournLine.Validate("Bal. Account Type", L_GenJournLine."Bal. Account Type"::"Bank Account");
                L_GenJournLine.Validate("Bal. Account No.", ChannelSetup."Bank Account No.");
            end;
            L_GenJournLine.Validate("Payment Method Code", P_ChannelPayLines."Payment Method Code");
            L_GenJournLine.Validate("Creditor No.", P_ChannelPayLines."Channel Code");
            L_GenJournLine.Validate(Amount, P_ChannelPayLines.Amount);
            L_GenJournLine.Insert(true);
            if P_ChannelPayLines.Fees <> 0 then begin
              L_GenJournLine1.Init();
              L_GenJournLine1 := L_GenJournLine;
              L_GenJournLine1."Line No." := L_GenJournLine1."Line No." + 1;
              L_GenJournLine1.Validate("Account Type", L_GenJournLine."Account Type"::"G/L Account");
              L_GenJournLine1.Validate("Account No.",ChannelSetup."G/L Account No.");
              if P_ChannelPayLines.Fees < 0 then
                L_GenJournLine1.Validate(Amount,-P_ChannelPayLines.Fees)
              else
                L_GenJournLine1.Validate(Amount,P_ChannelPayLines.Fees);

              L_GenJournLine1.Insert(true); 
            end;
            P_ChannelPayLines.Validate("Journal Created", true);
            P_ChannelPayLines.Modify(true);
        end else begin
            L_GenJournLine.Validate(Amount, L_GenJournLine.Amount + P_ChannelPayLines.Amount);
            L_GenJournLine.Modify(true);
            if P_ChannelPayLines.Fees <> 0 then begin
              L_GenJournLine1.Reset();
              L_GenJournLine1.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
              L_GenJournLine1.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
              L_GenJournLine1.SetRange("Posting Date", P_ChannelPayLines."Posting Date");
              if P_ChannelPayLines."Payment Method Code" <> '' then
                L_GenJournLine1.SetRange("Payment Method Code", P_ChannelPayLines."Payment Method Code");
              L_GenJournLine1.SetRange("Creditor No.", P_ChannelPayLines."Channel Code");        
              L_GenJournLine1.SetRange("Account No.", ChannelSetup."G/L Account No.");
              if L_GenJournLine1.FindFirst() then begin
                 if P_ChannelPayLines.Fees < 0 then 
                   L_GenJournLine1.Validate(Amount,L_GenJournLine1.amount+(P_ChannelPayLines.Fees*-1))
                 else
                    L_GenJournLine1.Validate(Amount,L_GenJournLine1.amount+(P_ChannelPayLines.Fees));
                L_GenJournLine1.Modify(true);
              end;  
            end;
            P_ChannelPayLines.Validate("Journal Created", true);
            P_ChannelPayLines.Modify(true);
        end;

    end;

    local procedure PostJournal()
    var
        L_GenJourn: Record "Gen. Journal Line";
        ChannelSetup: Record "General Setup - Channels";
    begin
        ChannelSetup.Get();
        ChannelSetup.TestField("Payment Journal Template");
        ChannelSetup.TestField("Payment Jounal Batch");
        L_GenJourn.Reset();
        L_GenJourn.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
        L_GenJourn.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
        if L_GenJourn.FindSet() then begin
            CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", L_GenJourn);
        end;
    end;

    local procedure ArchiveChannelPayment()
    var
        L_ChannelPayLine: Record "Channel Payment Line";
        L_Count: Integer;
        L_GenJnl: Record "Gen. Journal Line";
        CheckLine: Boolean;
        REP_ArchiveLines: Report "Move Channel Pay. to Archive";
        ChannelSetup: Record "General Setup - Channels";
    begin
        ChannelSetup.Get();
        ChannelSetup.TestField("Payment Journal Template");
        ChannelSetup.TestField("Payment Jounal Batch");
        Clear(L_Count);
        Clear(CheckLine);
        L_ChannelPayLine.Reset();
        L_ChannelPayLine.SetRange("Statement No.", Rec."Statement No.");
        L_ChannelPayLine.SetRange(Reconciled, true);
        L_ChannelPayLine.SetRange("Journal Created", true);
        if L_ChannelPayLine.FindSet() then
            L_Count := L_ChannelPayLine.Count;

        if Rec.Count = L_Count then begin
            L_GenJnl.Reset();
            L_GenJnl.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
            L_GenJnl.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
            if L_GenJnl.FindSet() then begin
                repeat
                    if L_GenJnl."External Document No." = Rec."External Document No." then
                        CheckLine := true;
                until L_GenJnl.Next() = 0;
            end;
            if CheckLine = false then begin
                Clear(REP_ArchiveLines);
                REP_ArchiveLines.SetTableView(Rec);
                REP_ArchiveLines.UseRequestPage(false);
                REP_ArchiveLines.Run();
            end;
        end;
    end;

    local procedure CreateFeeJournal(P_ChannelPayLines: Record "Channel Payment Line")
    var
        L_GenJournLine: Record "Gen. Journal Line";
        L_LineNo: Integer;
        ChannelSetup: Record "General Setup - Channels";
        L_Customer: Record Customer;
        L_HISL: Record "Handled Interim Sales Line";
    begin
        ChannelSetup.Get();
        ChannelSetup.TestField("Payment Journal Template");
        ChannelSetup.TestField("Payment Jounal Batch");
        Clear(L_LineNo);
        L_GenJournLine.Reset();
        L_GenJournLine.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
        L_GenJournLine.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
        if L_GenJournLine.FindLast() then
            L_LineNo := L_GenJournLine."Line No."
        else
            L_LineNo := 10000;

        L_GenJournLine.Reset();
        L_GenJournLine.SetRange("Journal Template Name", ChannelSetup."Payment Journal Template");
        L_GenJournLine.SetRange("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
        L_GenJournLine.SetRange("Posting Date", P_ChannelPayLines."Posting Date");
        if P_ChannelPayLines."Payment Method Code" <> '' then
            L_GenJournLine.SetRange("Payment Method Code", P_ChannelPayLines."Payment Method Code");
        L_GenJournLine.SetRange("Creditor No.", P_ChannelPayLines."Channel Code");
        L_GenJournLine.SetRange("Account Type", L_GenJournLine."Account Type"::"G/L Account");
        if NOT L_GenJournLine.FindFirst() then begin
            L_GenJournLine.Init();
            L_GenJournLine.Validate("Journal Template Name", ChannelSetup."Payment Journal Template");
            L_GenJournLine.Validate("Journal Batch Name", ChannelSetup."Payment Jounal Batch");
            L_GenJournLine."Line No." += L_LineNo;
            L_GenJournLine.Validate("Posting Date", P_ChannelPayLines."Posting Date");
            L_GenJournLine.Validate("Document No.", P_ChannelPayLines."Document No.");
            L_GenJournLine.Validate("External Document No.", P_ChannelPayLines."External Document No.");
            if P_ChannelPayLines."Payment Type" = P_ChannelPayLines."Payment Type"::Payment then begin
                L_GenJournLine.Validate("Document Type", L_GenJournLine."Document Type"::Payment);
                L_GenJournLine.Validate("Account Type", L_GenJournLine."Account Type"::"G/L Account");
                L_GenJournLine.Validate("Account No.", ChannelSetup."G/L Account No.");
                L_GenJournLine.Validate("Bal. Account Type", L_GenJournLine."Bal. Account Type"::Customer);
                L_GenJournLine.Validate("Bal. Account No.", P_ChannelPayLines."Bal. Account No.");
            end else begin
                L_GenJournLine.Validate("Document Type", L_GenJournLine."Document Type"::Refund);
                L_GenJournLine.Validate("Account Type", L_GenJournLine."Account Type"::"G/L Account");
                L_GenJournLine.Validate("Account No.", ChannelSetup."G/L Account No.");
                L_GenJournLine.Validate("Bal. Account Type", L_GenJournLine."Bal. Account Type"::"Bank Account");
                L_GenJournLine.Validate("Bal. Account No.", ChannelSetup."Bank Account No.");
            end;
            L_GenJournLine.Validate("Payment Method Code", P_ChannelPayLines."Payment Method Code");
            L_GenJournLine.Validate("Creditor No.", P_ChannelPayLines."Channel Code");
            L_GenJournLine.Validate(Amount, P_ChannelPayLines.Amount);
            L_GenJournLine.Insert(true);
        end else begin
            L_GenJournLine.Validate(Amount, L_GenJournLine.Amount + P_ChannelPayLines.Amount);
            L_GenJournLine.Modify(true);
        end;

    end;

}



