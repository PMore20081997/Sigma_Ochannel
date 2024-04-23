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
            trigger OnValidate()
            var
                L_CustomerRef: Record "Customer Reference";
            begin
                L_CustomerRef.Reset();
                L_CustomerRef.SetRange("ET Access Code", Rec."ET Access Code");
                if L_CustomerRef.FindFirst() then
                    Error('This ET Access Code is already defined for Customer ' + L_CustomerRef."Customer No.");
            end;
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