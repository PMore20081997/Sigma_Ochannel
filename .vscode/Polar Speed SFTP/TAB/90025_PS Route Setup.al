table 90025 "PS Route Setup"
{
    DataClassification = ToBeClassified;
    Caption = 'PS Route Setup';


    fields
    {
        field(1; "Postcode"; Code[20])
        {
            Caption = 'Postcode';
        }
        field(2; "Area"; Text[50])
        {
            Caption = 'Area';
        }
        field(3; "Zone"; Code[10])
        {
            Caption = 'Zone';
        }
        field(4; "Depot"; Code[20])
        {
            Caption = 'Depot';
        }
        field(5; "Del Days SMTWTFS"; Text[10])
        {
            Caption = 'Del Days SMTWTFS';
        }
        field(6; "Lead Time"; Integer)
        {
            Caption = 'Lead Time';
        }
        field(7; "Allowance Type"; Text[100])
        {
            Caption = 'Allowance Type';
            //OptionMembers = None,Fixed,Flexible;
        }
        field(8; "Carrier Zone"; Code[20])
        {
            Caption = 'Carrier Zone';
        }
        field(9; "Service"; Code[20])
        {
            Caption = 'Service';
        }
        field(10; "Window"; Text[30])
        {
            Caption = 'Window';
        }
        field(11; "Deleted"; Integer)
        {
            Caption = 'Deleted';
        }
    }


    keys
    {
        key(PK; "Postcode")
        {
            Clustered = true;
        }
    }
}