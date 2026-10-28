tableextension 90019 "OC Job Queue Entry" extends "Job Queue Entry"
{
    fields
    {
        field(90000; "Chain Sequence No."; Integer)
        {
            Caption = 'Chain Sequence No.';
            DataClassification = CustomerContent;
            MinValue = 0;
            //0 = Not part of the chain, 1 = First job in the Job Queue Category chain++
        }
    }
}
