table 90097 "Channel Payment Header"
{
    fields
    {
        field(1; "Statement No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Channel Code"; Code[10])
        {
            TableRelation = "Trade Partner";
        }
        field(3; "Payment Service Provider"; Code[10])
        {
            TableRelation = "Payment Method";
        }
        field(4; "Transaction From"; Date)
        {

        }
        field(5; "Transaction To"; Date)
        {

        }
    }
    keys
    {
        key(PK; "Statement No.")
        {
            Clustered = true;
        }
    }
}