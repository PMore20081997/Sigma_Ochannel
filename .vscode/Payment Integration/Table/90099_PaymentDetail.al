table 90099 "Payment Detail"
{
    fields
    {
        field(90001; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(90002; "Payment Service Code"; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Not In Use';
        }
        field(90003; "Web Payment Method Code"; Code[100])
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Replaced by new field';

        }
        field(90004; "NAV Payment Method Code"; Code[20])
        {

        }
        field(90005; "Order No."; Code[20])
        {

        }
        field(90006; "Transaction No."; Code[20])
        {

        }
        field(90007; "Channel Code"; Code[20])
        {

        }
        field(90008; "Transaction Date"; Date)
        {

        }
        field(90009; Amount; Decimal)
        {

        }
        field(90010; "Journal Created"; Boolean)
        {

        }
        field(90011; Fees; Decimal)
        {

        }
        field(90012; "Gross Amount"; Decimal)
        {
            trigger OnValidate()
            var
                Handledish: Record "Handled Interim Sales Header";
            begin
                if "Channel Code" = '' then begin
                    Handledish.Reset();
                    Handledish.SetRange("Document Type", Handledish."Document Type"::Order);
                    Handledish.SetRange("Channel Order ID", Rec."Order No.");
                    if Handledish.FindFirst() then
                        rec."Channel Code" := Handledish."Trade Partner Code";
                end;

            end;
        }
        field(90013; Reconciled; Boolean)
        {

        }
        field(90014; "Web Payment Method Code 2"; Text[50])
        {
            trigger OnValidate()
            var
                WebPayment: Record "Web Payment";
            begin
                WebPayment.Reset();
                WebPayment.SetRange("Channel Code", Rec."Channel Code");
                WebPayment.SetRange("Web Payment Method", Rec."Web Payment Method Code 2");
                if WebPayment.FindFirst() then
                    Rec."NAV Payment Method Code" := WebPayment."NAV Payment Method 2";
            end;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {

        }
    }
}