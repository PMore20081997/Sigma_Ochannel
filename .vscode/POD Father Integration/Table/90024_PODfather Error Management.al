table 90024 "PODFather Error Management"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Shipment Date"; Date)
        {

        }
        field(3; "Document Type"; Option)
        {
            OptionMembers = " ","Sales Invoice","Sales Shipment","Sales Return";
        }
        field(4; "Document No."; Code[20])
        {

        }
        field(5; Error; Text[2048])
        {

        }
        field(6; "Version No."; Integer)
        {

        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

}