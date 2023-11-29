table 90007 "Customer Reference"
{
    LookupPageId = "Customer Reference";
    fields
    {
        field(1; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(2; "ET Access Code"; Code[20])
        {

        }
        field(3; Locked; Boolean)
        {

        }
    }
    keys
    {
        key(PK; "Customer No.", "ET Access Code")
        {
            Clustered = true;

        }
    }
}