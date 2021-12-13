page 90092 "Channel Pay. Reconciliation"
{
    PageType = ListPlus;
    PromotedActionCategories = 'New,Process,Report,Bank,Matching,Posting';
    SaveValues = false;
    SourceTable = "Channel Payment Header";
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Channel Code"; Rec."Channel Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

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
            group(Control8)
            {
                ShowCaption = false;
                part("Channel Pay. Recon Lines"; "Channel Pay. Recon Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Channel Payment Reconciliation Lines';
                    SubPageLink = "Statement No." = FIELD("Statement No.");
                }
                part("Web Order Detail"; "Web Order Detail")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Matched Order Details';
                    Provider = "Channel Pay. Recon Lines";
                    SubPageLink = "Channel Order ID" = field("External Document No.");
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SuggestchannelpaymentLines)
            {
                ApplicationArea = All;
                Caption = 'Suggest Channel Payment Lines';
                Image = SuggestLines;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.TestField("Channel Code");
                    InsertLines(Rec);
                end;
            }
            action(Reconcilechannelpaymentlines)
            {
                ApplicationArea = All;
                Caption = 'Reconcile Channel Payment Lines';
                Image = Reconcile;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    L_ChannelLine: Record "Channel Payment Line";
                    ChannelSetup: Record "General Setup - Channels";
                begin
                    L_ChannelLine.Reset();
                    L_ChannelLine.SetRange("Statement No.", Rec."Statement No.");
                    L_ChannelLine.SetRange(Reconciled, false);
                    if L_ChannelLine.FindSet() then begin
                        repeat
                            UpdateReconcileLine(L_ChannelLine, ChannelSetup."Threshold Value", 0);
                        until L_ChannelLine.Next() = 0;
                    end;

                end;
            }

        }
    }
    local procedure InsertLines(P_ChannelHeader: Record "Channel Payment Header")
    var
        PaymentDetail: Record "Payment Detail";
        L_ChannelLine: Record "Channel Payment Line";
        L_LineNo: Integer;
        ChannelSetup: Record "General Setup - Channels";
        L_Customer: Record Customer;
        L_HISL: Record "Handled Interim Sales Line";
        BankAccount: Record "Bank Account";
        WebPayment: Record "Web Payment";
        L_HISH: Record "Handled Interim Sales Header";
    begin
        ChannelSetup.Get();
        Clear(L_LineNo);
        L_ChannelLine.Reset();
        L_ChannelLine.SetRange("Statement No.", P_ChannelHeader."Statement No.");
        if L_ChannelLine.FindLast() then
            L_LineNo := L_ChannelLine."Line No."
        else
            L_LineNo := 10000;

        PaymentDetail.Reset();
        PaymentDetail.SetRange("Journal Created", false);
        if P_ChannelHeader."Channel Code" <> '' then
            PaymentDetail.SetRange("Channel Code", P_ChannelHeader."Channel Code");
        if P_ChannelHeader."Payment Service Provider" <> '' then
            PaymentDetail.SetRange("NAV Payment Method Code", P_ChannelHeader."Payment Service Provider");
        if ((P_ChannelHeader."Transaction From" <> 0D) AND (P_ChannelHeader."Transaction To" <> 0D)) then
            PaymentDetail.SetFilter("Transaction Date", '%1|%2', P_ChannelHeader."Transaction From", P_ChannelHeader."Transaction To");
        if PaymentDetail.FindSet() then begin
            repeat
                L_ChannelLine.Init();
                L_ChannelLine."Statement No." := P_ChannelHeader."Statement No.";
                L_ChannelLine."Line No." += L_LineNo;
                L_ChannelLine.Validate("Posting Date", PaymentDetail."Transaction Date");
                L_ChannelLine.Validate("Document No.", PaymentDetail."Transaction No.");
                L_ChannelLine.Validate("Document Type", L_ChannelLine."Document Type"::Payment);
                L_ChannelLine.Validate("External Document No.", PaymentDetail."Order No.");
                L_ChannelLine.Validate("Account Type", L_ChannelLine."Account Type"::"Bank Account");
                L_ChannelLine.Validate("Account No.", ChannelSetup."Bank Account No.");
                if ChannelSetup."Bank Account No." <> '' then begin
                    BankAccount.Reset();
                    BankAccount.SetRange("No.", ChannelSetup."Bank Account No.");
                    if BankAccount.FindFirst() then
                        L_ChannelLine.Validate(Description, BankAccount.Name);
                end;
                L_ChannelLine.Validate(Amount, PaymentDetail.Amount);
                L_ChannelLine.Validate("Bal. Account Type", L_ChannelLine."Bal. Account Type"::Customer);
                L_Customer.Reset();
                L_Customer.SetRange("Payment Service Code", PaymentDetail."Web Payment Method Code 2");
                if L_Customer.FindFirst() then
                    L_ChannelLine.Validate("Bal. Account No.", L_Customer."No.");

                WebPayment.Reset();
                WebPayment.SetRange("Channel Code", PaymentDetail."Channel Code");
                WebPayment.SetRange("Web Payment Method", PaymentDetail."Web Payment Method Code 2");
                if WebPayment.FindFirst() then
                    L_ChannelLine."Payment Method Code" := WebPayment."NAV Payment Method 2";
               
                L_ChannelLine.Fees := PaymentDetail.Fees;
                L_HISL.Reset();
                L_HISL.SetRange("Document Type", L_HISL."Document Type"::Order);
                L_HISL.SetRange("Channel Order ID", L_ChannelLine."External Document No.");
                if L_HISL.FindSet() then
                    repeat
                        L_ChannelLine."Order Amount (System)" += L_HISL."Amount Including VAT";//     Amount;
                    until L_HISL.Next() = 0;
                L_HISH.Get(L_HISL."Document Type",L_HISL."Document No");   
                L_ChannelLine."Discount Amount" := L_HISH."Order Discount Amount"; 
                L_ChannelLine.Diffrance := L_ChannelLine."Order Amount (System)" - L_ChannelLine."Discount Amount"  - (L_ChannelLine.Amount + abs(L_ChannelLine.Fees));
                L_ChannelLine."Channel Code" := PaymentDetail."Channel Code";
                L_ChannelLine.Insert(true);
                PaymentDetail.Validate("Journal Created", true);
                PaymentDetail.Modify(true);
            until PaymentDetail.Next() = 0;
        end;
    end;

    procedure UpdateReconcileLine(P_ChannelPaymentLine: Record "Channel Payment Line"; P_ThresholdValue: Decimal; calledfrom: Integer)
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
            P_ChannelPaymentLine.Validate(Reconciled, true);
            P_ChannelPaymentLine.Modify(true);
            L_PaymentDetail.Reset();
            L_PaymentDetail.SetRange("Order No.", P_ChannelPaymentLine."External Document No.");
            L_PaymentDetail.SetRange("Journal Created", true);
            L_PaymentDetail.SetRange(Reconciled, false);
            if L_PaymentDetail.FindFirst() then
                repeat
                    L_PaymentDetail.Reconciled := true;
                    L_PaymentDetail.Modify(true);
                until L_PaymentDetail.Next() = 0;
            L_HISH.Reset();
            L_HISH.SetRange("Document Type", L_HISH."Document Type"::Order);
            L_HISH.SetRange("Channel Order ID", P_ChannelPaymentLine."External Document No.");
            if L_HISH.FindFirst() then begin
                L_HISH.Validate(Reconciled, true);
                L_HISH.Modify(true);
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
                        L_PaymentDetail.Modify(true);
                    until L_PaymentDetail.Next() = 0;
            end;
            //ThresholdValue--
        end;
    end;
}


