table 90009 "Despatch Scan Header"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; "Trolley No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Bay No."; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Scanned; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Order No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}