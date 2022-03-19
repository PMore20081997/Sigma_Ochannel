table 90092 "Return Label"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Channel Code"; Code[10])
        {
            TableRelation = "Trade Partner".Code;
        }
        field(3; "User ID"; Code[250])
        {

        }
    }
    keys
    {
        key(pk; "Entry No.", "User ID")
        {

        }
    }
}