table 90095 "Archive Payment Detail"
{
    fields
    {
        field(90001; "Entry No."; Integer)
        {

        }

        field(90003; "Web Payment Method Code"; Text[50])
        {

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

        }
        field(90013; Reconciled; Boolean)
        {

        }
    }
    keys
    {
        key(PK; "Entry No.")
        {

        }
    }
}