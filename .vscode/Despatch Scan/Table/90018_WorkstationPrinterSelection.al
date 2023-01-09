table 90018 "Workstation Printer Selection"
{
    Caption = 'Workstation Printer Selection';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Workstation; Code[30])
        {
            Caption = 'Workstation';
            DataClassification = ToBeClassified;
        }
        field(2; "Label Printer"; Text[250])
        {
            Caption = 'Label Printer';
            DataClassification = ToBeClassified;
            TableRelation = Printer;
        }
        field(3; "Despatch Note Printer"; Text[250])
        {
            Caption = 'Despatch Note Printer';
            DataClassification = ToBeClassified;
            TableRelation = Printer;
        }
        field(4; "DPD Label Printer"; Text[250])
        {
            Caption = 'DPD Label Printer';
            DataClassification = ToBeClassified;
            TableRelation = Printer;
        }
    }
    keys
    {
        key(PK; Workstation)
        {
            Clustered = true;
        }
    }
}
