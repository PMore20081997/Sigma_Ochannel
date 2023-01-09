table 90098 "Channel Payment Line"
{
    fields
    {
        field(1; "Statement No."; Integer)
        {
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }

        field(5; "Posting Date"; Date)
        {

        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';

        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(10; "Source Type"; Enum "Gen. Journal Source Type")
        {
            Caption = 'Source Type';


        }
        field(11; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Source Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Source Type" = CONST(Employee)) Employee;


        }
        field(12; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
        }
        field(13; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                          Blocked = CONST(false))
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Account Type" = CONST("IC Partner")) "IC Partner"
            ELSE
            IF ("Account Type" = CONST(Employee)) Employee;
        }
        field(14; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(15; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(16; Amount; Decimal)
        {

        }
        field(17; "Bal. Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
        }
        field(18; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account" WHERE("Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF ("Bal. Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Bal. Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Bal. Account Type" = CONST("IC Partner")) "IC Partner"
            ELSE
            IF ("Bal. Account Type" = CONST(Employee)) Employee;
        }
        field(19; Reconciled; Boolean)
        {

        }
        field(20; "Order Amount (System)"; Decimal)
        {
            Editable = false;
        }
        field(21; Diffrance; Decimal)
        {
            Editable = false;
        }
        field(22; Fees; Decimal)
        {
            //Editable = false;
        }
        field(23; "Journal Created"; Boolean)
        {

        }
        field(24; "Channel Code"; Code[10])
        {

        }
        field(25; "Moved to Archive"; Boolean)
        {

        }
        field(26; "Discount Amount"; Decimal)
        {

        }
        field(27; "Payment Type"; Option)
        {
            OptionMembers = Payment,Refund;
        }

        field(28; IsError; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(29; Error; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key1; "Statement No.", "Line No.")
        {
            Clustered = true;

        }
    }
    trigger OnDelete()
    var
        L_PaymentDetail: Record "Payment Detail";
    begin
        L_PaymentDetail.Reset();
        L_PaymentDetail.SetRange("Order No.", Rec."External Document No.");
        if L_PaymentDetail.FindFirst() then begin
            L_PaymentDetail.Validate("Journal Created", false);
            L_PaymentDetail.Validate(Reconciled, false);
            L_PaymentDetail.Modify(true);
        end;
    end;
}