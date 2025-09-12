table 90015 "Web Buffer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Web Document No."; Code[250])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Sales Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "TOS Checked"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Created At"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Trade Partner Code"; Code[250])
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