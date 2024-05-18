table 90015 "Web Buffer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Web Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Sales Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Web Document No.", "Sales Document No.")
        {
            Clustered = true;
        }
    }
}